#include "filesystem.h"
#include <QDir>
#include <QFileInfo>
#include <QStorageInfo>
#include <QTextStream>
#include <QDateTime>
#include <QDebug>

FileSystem::FileSystem(QObject *parent) : QObject(parent)
{
}

// 判断路径是否受保护（目前仅禁止对根目录 / 的写入操作）
bool FileSystem::isRestrictedPath(const QString &path) const
{
    if (path.isEmpty())
        return false;
    QString normalized = QDir::cleanPath(path);
    return normalized == "/";
}

QVariantList FileSystem::getDrives()
{
    QVariantList drives;

    try {
        // 1. 添加主目录（/home/用户名）作为一个特殊条目
        QVariantMap homeDrive;
        QString homePath = QDir::homePath();
        homeDrive["name"] = "主目录 (" + homePath + ")";
        homeDrive["path"] = homePath;
        homeDrive["type"] = "home";
        homeDrive["size"] = "";
        drives.append(homeDrive);

        // 2. 获取所有挂载卷，只保留 /mnt 下的挂载点
        QList<QStorageInfo> storageList = QStorageInfo::mountedVolumes();

        for (const QStorageInfo &storage : storageList) {
            if (!storage.isValid() || !storage.isReady())
                continue;

            QString rootPath = storage.rootPath();
            // 排除根目录自身
            if (rootPath == "/")
                continue;

            // 只保留挂载点以 /mnt 开头的（包括 /mnt 本身，但 /mnt 通常不是挂载点）
            if (!rootPath.startsWith("/mnt") && !rootPath.startsWith("/media"))
                continue;

            // 过滤掉虚拟文件系统（虽然 /mnt 下一般不会有，但保留安全检查）
            QString fsType = storage.fileSystemType();
            if (fsType == "proc" || fsType == "sysfs" || fsType == "tmpfs" ||
                fsType == "devtmpfs" || fsType == "cgroup" || fsType == "pstore" ||
                fsType == "debugfs" || fsType == "tracefs" || fsType == "configfs" ||
                fsType == "fusectl" || fsType == "securityfs" || fsType == "bpf")
                continue;

            QVariantMap drive;
            QString name = storage.name();
            if (name.isEmpty()) {
                name = "挂载点 (" + rootPath + ")";
            }
            drive["name"] = name;
            drive["path"] = rootPath;
            drive["type"] = "drive";
            drive["size"] = formatFileSize(storage.bytesTotal());

            drives.append(drive);
        }
    } catch (const std::exception &e) {
        emit errorOccurred(QString("获取驱动器列表失败: %1").arg(e.what()));
    }

    return drives;
}

QVariantList FileSystem::getDirectoryContents(const QString &path)
{
    QVariantList contents;

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
    QFileInfo info(path);
    return info.isDir();
}

QString FileSystem::getFileName(const QString &path)
{
    QFileInfo info(path);
    return info.fileName();
}

QString FileSystem::getFileSize(const QString &path)
{
    QFileInfo info(path);
    if (info.isDir()) {
        return "";
    }
    return formatFileSize(info.size());
}

QString FileSystem::getFileType(const QString &path)
{
    QFileInfo info(path);
    return info.isDir() ? "文件夹" : "文件";
}

QString FileSystem::getParentDirectory(const QString &path)
{
    QDir dir(path);
    if (dir.isRoot()) {
        return "";
    }
    dir.cdUp();
    return dir.absolutePath();
}

QDateTime FileSystem::getFileModifiedTime(const QString &path)
{
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
    if (isRestrictedPath(filePath)) {
        emit errorOccurred("无权限写入系统根目录");
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
    if (isRestrictedPath(path)) {
        emit errorOccurred("无权限在系统根目录创建目录");
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
    return QFile::exists(filePath);
}

bool FileSystem::deleteFile(const QString &filePath)
{
    if (isRestrictedPath(filePath)) {
        emit errorOccurred("无权限删除系统根目录上的文件");
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
    if (isRestrictedPath(path)) {
        emit errorOccurred("无权限删除系统根目录");
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
    if (isRestrictedPath(oldPath)) {
        emit errorOccurred("无权限重命名系统根目录上的文件");
        return false;
    }
    if (isRestrictedPath(newPath)) {
        emit errorOccurred("无权限将文件重命名到系统根目录");
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