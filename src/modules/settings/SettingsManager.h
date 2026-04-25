// SettingsManager.h
#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QImage>
#include <QDebug>
#include <QColor>

class SettingsManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString desktopBackground READ desktopBackground WRITE setDesktopBackground NOTIFY desktopBackgroundChanged)
    Q_PROPERTY(QString desktopWallpaper READ desktopWallpaper WRITE setDesktopWallpaper NOTIFY desktopWallpaperChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    QString desktopBackground() const;
    void setDesktopBackground(const QString &background);

    QString desktopWallpaper() const;
    void setDesktopWallpaper(const QString &wallpaper);

    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void loadSettings();

    Q_INVOKABLE QString saveWallpaperImage(const QString &sourcePath);
    Q_INVOKABLE bool removeWallpaperFile();
    Q_INVOKABLE QString getWallpaperPath() const;
    Q_INVOKABLE bool isValidColor(const QString &color);
    Q_INVOKABLE void setWallpaperInfo(const QString &name, const QString &description);
    Q_INVOKABLE QVariantMap getWallpaperInfo() const;
    Q_INVOKABLE QString getWallpaperDir() const;

signals:
    void desktopBackgroundChanged(const QString &background);
    void desktopWallpaperChanged(const QString &wallpaper);
    void wallpaperInfoChanged(const QString &name, const QString &description);

private:
    QSettings *m_settings;
    QString m_desktopBackground;
    QString m_desktopWallpaper;

    QString m_wallpaperPath;
    static const QString WALLPAPER_FILENAME;
    void initializeWallpaperDir();
    QString getImageExtension(const QString &sourcePath);

    QString m_currentWallpaperName;
    QString m_currentWallpaperDescription;
};

#endif // SETTINGSMANAGER_H
