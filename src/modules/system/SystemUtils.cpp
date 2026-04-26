#include "SystemUtils.h"

SystemUtils::SystemUtils(QObject *parent) : QObject(parent)
{
    shutdownProcess = new QProcess(this);
}

bool SystemUtils::hasPecmdIni()
{
#ifdef Q_OS_WINDOWS
    QString windowsPath = getWindowsPath();
    if (windowsPath.isEmpty()) {
        qDebug() << "无法获取Windows目录路径";
        return false;
    }

    QString pecmdIniPath = windowsPath + "\\System32\\pecmd.ini";
    QFileInfo pecmdFile(pecmdIniPath);

    bool exists = pecmdFile.exists() && pecmdFile.isFile();
    qDebug() << "检测pecmd.ini文件:" << pecmdIniPath << "存在:" << exists;

    return exists;
#else
    qDebug() << "非Windows系统，视为实体机";
    return false;
#endif
}

bool SystemUtils::enableShutdownPrivilege()
{
#ifdef Q_OS_WINDOWS
    HANDLE hToken = NULL;
    TOKEN_PRIVILEGES tkp = {0};

    // 获取当前进程的令牌句柄
    if (!OpenProcessToken(GetCurrentProcess(),
                          TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY,
                          &hToken)) {
        qWarning() << "无法打开进程令牌，错误码:" << GetLastError();
        return false;
    }

    // 获取关机权限的LUID
    LookupPrivilegeValue(NULL, SE_SHUTDOWN_NAME, &tkp.Privileges[0].Luid);

    tkp.PrivilegeCount = 1;
    tkp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;

    // 调整令牌权限
    if (!AdjustTokenPrivileges(hToken, FALSE, &tkp, 0, NULL, NULL)) {
        qWarning() << "无法调整令牌权限，错误码:" << GetLastError();
        CloseHandle(hToken);
        return false;
    }

    CloseHandle(hToken);
    qDebug() << "已成功启用关机权限";
    return true;
#else
    return false;
#endif
}

bool SystemUtils::setResolution(int width, int height)
{
#ifdef Q_OS_WINDOWS
    // 保存原始分辨率（如果是第一次设置）
    if (!hasOriginalResolution) {
        QScreen *primaryScreen = QGuiApplication::primaryScreen();
        if (primaryScreen) {
            QSize size = primaryScreen->size();
            originalWidth = size.width();
            originalHeight = size.height();
            hasOriginalResolution = true;
            qDebug() << "保存原始分辨率:" << originalWidth << "x" << originalHeight;
        } else {
            qWarning() << "无法获取主屏幕，无法保存原始分辨率";
            return false;
        }
    }

    // 构造 pecmd 命令参数
    QStringList args;
    args << "DISP" << QString("W%1").arg(width) << QString("H%1").arg(height);

    // 执行命令
    bool success = executeCommand("pecmd", args);

    if (success) {
        qDebug() << "分辨率设置成功:" << width << "x" << height;
    } else {
        qWarning() << "分辨率设置失败:" << width << "x" << height;
    }

    return success;
#else
    return false;
#endif
}

bool SystemUtils::restoreOriginalResolution()
{
    if (!hasOriginalResolution) {
        qWarning() << "没有保存原始分辨率";
        return false;
    }

    return setResolution(originalWidth, originalHeight);
}

bool SystemUtils::startProgram(const QString &program, const QString &arguments)
{
    if (program.isEmpty()) {
        qWarning() << "程序路径为空";
        return false;
    }

    // 如果已有进程在运行，先终止
    if (currentProcess && currentProcess->state() != QProcess::NotRunning) {
        qWarning() << "已有程序在运行，请先终止";
        return false;
    }

    // 清理旧进程
    if (currentProcess) {
        currentProcess->deleteLater();
        currentProcess = nullptr;
    }

    currentProcess = new QProcess(this);

    // 将参数字符串分割为列表
    QStringList args = arguments.split(' ', Qt::SkipEmptyParts);

    // 连接信号
    connect(currentProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode, QProcess::ExitStatus exitStatus) {
                qDebug() << "程序结束，退出码:" << exitCode;
                emit programFinished();
            });

    // 启动程序
    currentProcess->start(program, args);

    if (!currentProcess->waitForStarted(3000)) {
        qWarning() << "程序启动失败:" << program;
        currentProcess->deleteLater();
        currentProcess = nullptr;
        return false;
    }

    qDebug() << "程序启动成功:" << program << args;
    emit programStarted();
    return true;
}

bool SystemUtils::isProgramRunning()
{
    return currentProcess && currentProcess->state() != QProcess::NotRunning;
}

bool SystemUtils::terminateProgram()
{
    if (!currentProcess || currentProcess->state() == QProcess::NotRunning) {
        qWarning() << "没有程序在运行";
        return false;
    }

    // 尝试正常终止
    currentProcess->terminate();

    // 等待最多3秒，如果未结束则强制杀死
    if (!currentProcess->waitForFinished(3000)) {
        qWarning() << "程序未响应，强制终止";
        currentProcess->kill();
    }

    // 清理
    currentProcess->deleteLater();
    currentProcess = nullptr;

    emit programFinished();
    return true;
}

// 执行命令行
bool SystemUtils::executeCommand(const QString& command, const QStringList& arguments)
{
#ifdef Q_OS_WINDOWS
    QProcess process;
    process.setProgram(command);
    process.setArguments(arguments);

    // 隐藏命令行窗口
    process.setCreateProcessArgumentsModifier([](QProcess::CreateProcessArguments *args) {
        args->flags |= CREATE_NO_WINDOW;
    });

    // 执行命令
    process.start();

    // 等待命令执行完成
    if (!process.waitForStarted(3000)) {
        qWarning() << "命令启动失败:" << command << arguments;
        return false;
    }

    // 等待命令执行完成（最多30秒）
    if (!process.waitForFinished(30000)) {
        qWarning() << "命令执行超时:" << command << arguments;
        process.kill();
        return false;
    }

    int exitCode = process.exitCode();
    if (exitCode != 0) {
        qWarning() << "命令执行失败，退出码:" << exitCode << "错误输出:" << process.readAllStandardError();
        return false;
    }

    qDebug() << "命令执行成功:" << command << arguments;
    return true;
#else
    // 非Windows平台，使用系统命令
    QString fullCommand = command + " " + arguments.join(" ");
    int result = system(fullCommand.toStdString().c_str());
    return result == 0;
#endif
}

// 执行关机命令
bool SystemUtils::executeShutdownCommand(const QString& arguments)
{
#ifdef Q_OS_WINDOWS
    // Windows使用shutdown命令
    QStringList args;
    args << arguments << "/t" << "0";  // 立即执行

    // 如果需要管理员权限，先尝试提权
    if (!enableShutdownPrivilege()) {
        qWarning() << "提权失败，可能无法执行关机操作";
    }

    return executeCommand("shutdown", args);
#else
    // Linux/Mac使用相应的命令
    QStringList args;
    args << "-h" << "now";
    return executeCommand("shutdown", args);
#endif
}

// 执行重启命令
bool SystemUtils::executeRebootCommand()
{
#ifdef Q_OS_WINDOWS
    // Windows使用shutdown /r命令
    QStringList args;
    args << "/r" << "/t" << "0";  // 立即重启

    // 如果需要管理员权限，先尝试提权
    if (!enableShutdownPrivilege()) {
        qWarning() << "提权失败，可能无法执行重启操作";
    }

    return executeCommand("shutdown", args);
#else
    // Linux/Mac使用相应的命令
    QStringList args;
    args << "-r" << "now";
    return executeCommand("shutdown", args);
#endif
}

void SystemUtils::shutdownWithCommand()
{
    qDebug() << "执行关机命令";
#ifdef Q_OS_WINDOWS
    emit shutdownStarted();
    bool success = executeShutdownCommand("/s");
    if (success) {
        qDebug() << "关机命令已发送成功";
        QTimer::singleShot(3000, []() {
            QCoreApplication::quit();
        });
    } else {
        qWarning() << "关机命令执行失败";
        emit shutdownFailed("关机命令执行失败");
        QCoreApplication::quit();
    }
#else
    qDebug() << "非Windows系统，尝试执行关机命令";
    emit shutdownStarted();
    bool success = executeShutdownCommand("");
    if (success) {
        qDebug() << "关机命令已发送成功";
        QTimer::singleShot(3000, []() {
            QCoreApplication::quit();
        });
    } else {
        qWarning() << "关机命令执行失败";
        emit shutdownFailed("关机命令执行失败");
        QCoreApplication::quit();
    }
#endif
}

void SystemUtils::rebootWithCommand()
{
    qDebug() << "执行重启命令";
#ifdef Q_OS_WINDOWS
    emit rebootStarted();
    bool success = executeRebootCommand();
    if (success) {
        qDebug() << "重启命令已发送成功";
        QTimer::singleShot(3000, []() {
            QCoreApplication::exit(1);
        });
    } else {
        qWarning() << "重启命令执行失败";
        emit rebootFailed("重启命令执行失败");
        QCoreApplication::exit(1);
    }
#else
    qDebug() << "非Windows系统，尝试执行重启命令";
    emit rebootStarted();
    bool success = executeRebootCommand();
    if (success) {
        qDebug() << "重启命令已发送成功";
        QTimer::singleShot(3000, []() {
            QCoreApplication::exit(1);
        });
    } else {
        qWarning() << "重启命令执行失败";
        emit rebootFailed("重启命令执行失败");
        QCoreApplication::exit(0);
    }
#endif
}

void SystemUtils::normalQuit()
{
    qDebug() << "正常退出应用，返回码: 0";

    // 正常退出，返回码0
    QCoreApplication::exit(0);
}

QString SystemUtils::getWindowsPath()
{
#ifdef Q_OS_WINDOWS
    // 尝试从环境变量获取Windows目录
    wchar_t windowsPath[MAX_PATH] = {0};

    // 方法1: 使用SHGetFolderPath获取Windows目录
    if (SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_WINDOWS, NULL, 0, windowsPath))) {
        return QString::fromWCharArray(windowsPath);
    }

    // 方法2: 使用GetWindowsDirectory API
    if (GetWindowsDirectoryW(windowsPath, MAX_PATH) > 0) {
        return QString::fromWCharArray(windowsPath);
    }

    // 方法3: 尝试从环境变量获取
    QString windir = qEnvironmentVariable("SystemRoot");
    if (!windir.isEmpty()) {
        return windir;
    }

    windir = qEnvironmentVariable("WINDIR");
    if (!windir.isEmpty()) {
        return windir;
    }

    // 方法4: 尝试常见的Windows目录路径
    QStringList possiblePaths = {
        "C:\\Windows",
        "D:\\Windows"
    };

    for (const QString &path : possiblePaths) {
        QDir dir(path);
        if (dir.exists()) {
            return path;
        }
    }
#endif

    return QString();
}
