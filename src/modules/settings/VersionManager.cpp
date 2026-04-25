#include "VersionManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QCoreApplication>

VersionManager::VersionManager(QObject *parent)
    : QObject(parent)
    , m_allowRealShutdown(true)
    , m_requiresConfirmation(false)
{
    loadConfig();
}

VersionManager::~VersionManager()
{
}

VersionManager* VersionManager::instance()
{
    static VersionManager instance;
    return &instance;
}

void VersionManager::loadConfig()
{
    QString configPath = QString(ZIYANOS_VERSION_JSON_PATH);
    QFile file(configPath);
    if (file.exists() && file.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        QJsonObject root = doc.object();

        m_version = root.value("version").toString();
        m_buildType = root.value("build_type").toString();

        QJsonObject buildInfo = root.value("build_info").toObject();
        m_buildTime = buildInfo.value("build_time").toString();
        m_gitCommit = buildInfo.value("git_commit").toString();
        m_gitBranch = buildInfo.value("git_branch").toString();

        QJsonObject shutdown = root.value("shutdown").toObject();
        m_allowRealShutdown = shutdown.value("allow_real_shutdown").toBool(true);
        m_requiresConfirmation = shutdown.value("requires_confirmation").toBool(false);

        m_loaded = true;
        file.close();

        qDebug() << "VersionManager: Loaded config from" << configPath;
        qDebug() << "VersionManager: version =" << m_version
                 << "buildTime =" << m_buildTime
                 << "allowRealShutdown =" << m_allowRealShutdown;
        return;
    }

    qWarning() << "VersionManager: Failed to load config, using defaults";
    m_loaded = false;
}

QString VersionManager::version() const
{
    return m_version;
}

QString VersionManager::buildTime() const
{
    return m_buildTime;
}

QString VersionManager::gitCommit() const
{
    return m_gitCommit;
}

QString VersionManager::gitBranch() const
{
    return m_gitBranch;
}

QString VersionManager::buildType() const
{
    return m_buildType;
}

bool VersionManager::allowRealShutdown() const
{
    return m_allowRealShutdown;
}

bool VersionManager::requiresConfirmation() const
{
    return m_requiresConfirmation;
}

bool VersionManager::isValid() const
{
    return m_loaded;
}