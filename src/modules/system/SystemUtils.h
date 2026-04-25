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

#include "VersionManager.h"

class SystemUtils : public QObject
{
    Q_OBJECT

public:
    explicit SystemUtils(QObject *parent = nullptr);

    Q_INVOKABLE bool hasPecmdIni();

    Q_INVOKABLE void shutdownWithCommand();

    Q_INVOKABLE void rebootWithCommand();

    Q_INVOKABLE void normalQuit();

    Q_INVOKABLE bool setResolution(int width, int height);
    Q_INVOKABLE bool restoreOriginalResolution();

    Q_INVOKABLE bool startProgram(const QString &program, const QString &arguments);

    Q_INVOKABLE bool isProgramRunning();

    Q_INVOKABLE bool terminateProgram();

    Q_INVOKABLE bool canRealShutdown();

signals:
    void shutdownStarted();
    void shutdownFailed(const QString& error);
    void rebootStarted();
    void rebootFailed(const QString& error);

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

    QProcess* currentProcess = nullptr;
};

#endif // SYSTEMUTILS_H
