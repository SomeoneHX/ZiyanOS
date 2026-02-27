#ifndef SYSTEMUTILS_H
#define SYSTEMUTILS_H

#include <QObject>
#include <QString>
#include <QDebug>
#include <QCoreApplication>
#include <QGuiApplication>
#include <QScreen>
#include <QFileInfo>
#include <QDir>
#include <QTimer>
#include <QProcess>

#ifdef Q_OS_WINDOWS
#include <windows.h>
#include <shlobj.h>
#include <shellapi.h>
#include <tchar.h>
#endif

class SystemUtils : public QObject
{
    Q_OBJECT

public:
    explicit SystemUtils(QObject *parent = nullptr);

    // 检测是否存在 pecmd.ini 文件
    Q_INVOKABLE bool hasPecmdIni();

    // 使用命令行执行关机
    Q_INVOKABLE void shutdownWithCommand();

    // 使用命令行执行重启
    Q_INVOKABLE void rebootWithCommand();

    // 正常退出应用
    Q_INVOKABLE void normalQuit();

    Q_INVOKABLE bool setResolution(int width, int height);
    Q_INVOKABLE bool restoreOriginalResolution();

    // 启动程序并跟踪进程
    Q_INVOKABLE bool startProgram(const QString &program, const QString &arguments);

    // 检查程序是否正在运行
    Q_INVOKABLE bool isProgramRunning();

    // 终止正在运行的程序
    Q_INVOKABLE bool terminateProgram();

signals:
    void shutdownStarted();
    void shutdownFailed(const QString& error);
    void rebootStarted();
    void rebootFailed(const QString& error);

    // 程序状态信号
    void programStarted();
    void programFinished();

private:
    QString getWindowsPath();
    bool executeCommand(const QString& command, const QStringList& arguments);
    bool executeShutdownCommand(const QString& arguments);
    bool executeRebootCommand();
    bool enableShutdownPrivilege();

    int originalWidth = 0;
    int originalHeight = 0;
    bool hasOriginalResolution = false;
    QProcess* shutdownProcess = nullptr;

    // 当前运行的进程
    QProcess* currentProcess = nullptr;
};

#endif // SYSTEMUTILS_H
