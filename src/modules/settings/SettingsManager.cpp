#include "SettingsManager.h"

SettingsManager::SettingsManager(QObject *parent)
    : QObject(parent)
{
    QString configPath = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation) + "/config.ini";
    QFileInfo configFile(configPath);
    QDir configDir = configFile.absoluteDir();

    if (!configDir.exists()) {
        configDir.mkpath(".");
    }

    m_settings = new QSettings(configPath, QSettings::IniFormat, this);

    loadSettings();
}

QString SettingsManager::desktopBackground() const
{
    return m_desktopBackground;
}

void SettingsManager::setDesktopBackground(const QString &background)
{
    if (m_desktopBackground != background) {
        m_desktopBackground = background;
        emit desktopBackgroundChanged(background);
    }
}

void SettingsManager::saveSettings()
{
    m_settings->setValue("Desktop/Background", m_desktopBackground);
    m_settings->sync();

    qDebug() << "设置已保存 - 背景:" << m_desktopBackground;
}

void SettingsManager::loadSettings()
{
    m_desktopBackground = m_settings->value("Desktop/Background", "#1a1a1a").toString();

    qDebug() << "设置已加载 - 背景:" << m_desktopBackground;

    emit desktopBackgroundChanged(m_desktopBackground);
}

bool SettingsManager::isValidColor(const QString &color)
{
    if (color.isEmpty()) return false;

    QRegularExpression hexRegex("^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$");
    return hexRegex.match(color).hasMatch();
}