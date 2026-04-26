#ifndef VERSIONMANAGER_H
#define VERSIONMANAGER_H

#include <QObject>
#include <QString>
#include <QJsonObject>
#include <QDebug>

class VersionManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString version READ version CONSTANT)
    Q_PROPERTY(QString buildTime READ buildTime CONSTANT)
    Q_PROPERTY(QString gitCommit READ gitCommit CONSTANT)
    Q_PROPERTY(QString gitBranch READ gitBranch CONSTANT)
    Q_PROPERTY(QString buildType READ buildType CONSTANT)
    Q_PROPERTY(bool showExitButton READ showExitButton CONSTANT)

public:
    explicit VersionManager(QObject *parent = nullptr);
    ~VersionManager();

    static VersionManager* instance();

    QString version() const;
    QString buildTime() const;
    QString gitCommit() const;
    QString gitBranch() const;
    QString buildType() const;

    bool showExitButton() const;

    bool isValid() const;

private:
    void loadConfig();

    QString m_version;
    QString m_buildTime;
    QString m_gitCommit;
    QString m_gitBranch;
    QString m_buildType;

    bool m_showExitButton;

    bool m_loaded = false;
};

#endif