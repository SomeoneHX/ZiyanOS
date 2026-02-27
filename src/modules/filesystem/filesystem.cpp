#include "filesystem.h"

FileSystem::FileSystem(QObject *parent) : QObject(parent)
{
}

// 新增：判断路径是否位于 X 盘（不区分大小写）
bool FileSystem::isRestrictedPath(const QString &path) const
{
    if (path.isEmpty())
        return false;
    // 取前两个字符，忽略大小写比较是否为 "X:"
    return QString::compare(path.left(2), "X:", Qt::CaseInsensitive) == 0;
}

QVariantList FileSystem::getDrives()
{
    QVariantList drives;

    try {
        QList<QStorageInfo> storageList = QStorageInfo::mountedVolumes();

        for (const QStorageInfo &storage : storageList) {
            if (storage.isValid() && storage.isReady()) {
                QVariantMap drive;
                QString rootPath = storage.rootPath();
                QString name = storage.name();
                if (name.isEmpty()) {
                    name = "本地磁盘 (" + rootPath.left(2) + ")";
                }
                drive["name"] = name;
                drive["path"] = rootPath;
                // 如果是 X 盘，标记为系统盘
                if (isRestrictedPath(rootPath)) {
                    drive["type"] = "system";
                } else {
                    drive["type"] = "drive";
                }
                drive["size"] = formatFileSize(storage.bytesTotal());

                drives.append(drive);
            }
        }
    } catch (const std::exception &e) {
        emit errorOccurred(QString("获取驱动器列表失败: %1").arg(e.what()));
    }

    return drives;
}

QVariantList FileSystem::getDirectoryContents(const QString &path)
{
    QVariantList contents;

    // 权限检查：如果路径在 X 盘，拒绝访问
    if (isRestrictedPath(path)) {
        emit errorOccurred("无权限访问系统盘 X:");
        return contents;
    }

    try {
        QDir dir(path);
        if (!dir.exists()) {
            emit errorOccurred("目录不存在: " + path);
            return contents;
        }

        QFileInfoList entries = dir.entryInfoList(QDir::AllEntries | QDir::NoDotAndDotDot, QDir::DirsFirst | QDir::Name);

        for (const QFileInfo &entry : entries) {
            QVariantMap item;
            item["name"] = entry.fileName();
            item["path"] = entry.absoluteFilePath();
            item["isDir"] = entry.isDir();
            item["size"] = entry.isDir() ? "" : formatFileSize(entry.size());
            item["type"] = entry.isDir() ? "文件夹" : "文件";
            item["modified"] = entry.lastModified().toString("yyyy-MM-dd hh:mm:ss");

            contents.append(item);
        }
    } catch (const std::exception &e) {
        emit errorOccurred(QString("读取目录失败: %1").arg(e.what()));
    }

    return contents;
}

bool FileSystem::isDir(const QString &path)
{
    // 权限检查：如果是 X 盘路径，直接返回 false（但通常不会调用到）
    if (isRestrictedPath(path)) {
        emit errorOccurred("无权限访问系统盘 X:");
        return false;
    }
    QFileInfo info(path);
    return info.isDir();
}

QString FileSystem::getFileName(const QString &path)
{
    // 路径操作，不涉及实际读取，可以不做权限检查
    QFileInfo info(path);
    return info.fileName();
}

QString FileSystem::getFileSize(const QString &path)
{
    // 权限检查
    if (isRestrictedPath(path)) {
        emit errorOccurred("无权限访问系统盘 X:");
        return "";
    }
    QFileInfo info(path);
    if (info.isDir()) {
        return "";
    }
    return formatFileSize(info.size());
}

QString FileSystem::getFileType(const QString &path)
{
    // 权限检查
    if (isRestrictedPath(path)) {
        emit errorOccurred("无权限访问系统盘 X:");
        return "";
    }
    QFileInfo info(path);
    return info.isDir() ? "文件夹" : "文件";
}

QString FileSystem::getParentDirectory(const QString &path)
{
    // 路径计算，不涉及实际访问，可不检查
    QDir dir(path);
    if (dir.isRoot()) {
        return "";
    }
    dir.cdUp();
    return dir.absolutePath();
}

QDateTime FileSystem::getFileModifiedTime(const QString &path)
{
    // 权限检查
    if (isRestrictedPath(path)) {
        emit errorOccurred("无权限访问系统盘 X:");
        return QDateTime();
    }
    QFileInfo info(path);
    return info.lastModified();
}

QString FileSystem::readFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.exists()) {
        emit errorOccurred("文件不存在: " + filePath);
        return "";
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        emit errorOccurred("无法打开文件: " + filePath);
        return "";
    }

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    return content;
}

bool FileSystem::writeFile(const QString &filePath, const QString &content)
{
    // 权限检查：写入目标在 X 盘则拒绝
    if (isRestrictedPath(filePath)) {
        emit errorOccurred("无权限写入系统盘 X:");
        return false;
    }

    QFile file(filePath);

    QFileInfo fileInfo(filePath);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            emit errorOccurred("无法创建目录: " + dir.absolutePath());
            return false;
        }
    }

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        emit errorOccurred("无法写入文件: " + filePath);
        return false;
    }

    QTextStream out(&file);
    out << content;
    file.close();

    return true;
}

bool FileSystem::createDirectory(const QString &path)
{
    // 权限检查
    if (isRestrictedPath(path)) {
        emit errorOccurred("无权限在系统盘 X: 创建目录");
        return false;
    }

    QDir dir;
    if (dir.mkpath(path)) {
        emit fileOperationCompleted("目录创建成功: " + path);
        return true;
    } else {
        emit errorOccurred("无法创建目录: " + path);
        return false;
    }
}

bool FileSystem::fileExists(const QString &filePath)
{
    // 权限检查
    if (isRestrictedPath(filePath)) {
        // 即使文件存在，我们也视为不可见，返回 false
        return false;
    }
    return QFile::exists(filePath);
}

bool FileSystem::deleteFile(const QString &filePath)
{
    // 权限检查
    if (isRestrictedPath(filePath)) {
        emit errorOccurred("无权限删除系统盘 X: 上的文件");
        return false;
    }

    QFileInfo fileInfo(filePath);

    if (fileInfo.isDir()) {
        return deleteDirectory(filePath);
    } else {
        if (QFile::remove(filePath)) {
            emit fileOperationCompleted("文件删除成功: " + getFileName(filePath));
            return true;
        } else {
            emit errorOccurred("无法删除文件: " + filePath);
            return false;
        }
    }
}

bool FileSystem::deleteDirectory(const QString &path)
{
    // 权限检查
    if (isRestrictedPath(path)) {
        emit errorOccurred("无权限删除系统盘 X: 上的文件夹");
        return false;
    }

    QDir dir(path);

    if (!dir.exists()) {
        emit errorOccurred("文件夹不存在: " + path);
        return false;
    }

    if (dir.removeRecursively()) {
        emit fileOperationCompleted("文件夹删除成功: " + getFileName(path));
        return true;
    } else {
        emit errorOccurred("无法删除文件夹: " + path);
        return false;
    }
}

bool FileSystem::renameFile(const QString &oldPath, const QString &newPath)
{
    // 权限检查：源或目标在 X 盘均拒绝
    if (isRestrictedPath(oldPath)) {
        emit errorOccurred("无权限重命名系统盘 X: 上的文件");
        return false;
    }
    if (isRestrictedPath(newPath)) {
        emit errorOccurred("无权限将文件重命名到系统盘 X:");
        return false;
    }

    if (oldPath.isEmpty() || newPath.isEmpty()) {
        emit errorOccurred("文件路径不能为空");
        return false;
    }

    QFileInfo oldInfo(oldPath);
    if (!oldInfo.exists()) {
        emit errorOccurred("文件或文件夹不存在: " + oldPath);
        return false;
    }

    QFileInfo newInfo(newPath);
    if (newInfo.exists()) {
        emit errorOccurred("目标文件或文件夹已存在: " + newPath);
        return false;
    }

    QFile file(oldPath);
    if (file.rename(newPath)) {
        QString operation = oldInfo.isDir() ? "文件夹" : "文件";
        emit fileOperationCompleted(operation + "重命名成功: " + getFileName(oldPath) + " -> " + getFileName(newPath));
        return true;
    } else {
        emit errorOccurred("重命名失败: " + oldPath);
        return false;
    }
}

QString FileSystem::formatFileSize(qint64 bytes) const
{
    if (bytes == 0) return "0 B";

    const QStringList units = {"B", "KB", "MB", "GB", "TB"};
    int unitIndex = 0;
    double size = bytes;

    while (size >= 1024.0 && unitIndex < units.size() - 1) {
        size /= 1024.0;
        unitIndex++;
    }

    return QString("%1 %2").arg(size, 0, 'f', 1).arg(units[unitIndex]);
}
