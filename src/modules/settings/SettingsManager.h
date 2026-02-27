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
    Q_PROPERTY(QString windowTitleBarMode READ windowTitleBarMode WRITE setWindowTitleBarMode NOTIFY windowTitleBarModeChanged)
    Q_PROPERTY(QString windowTitleBarColor READ windowTitleBarColor WRITE setWindowTitleBarColor NOTIFY windowTitleBarColorChanged)
    // 新增：内容模糊开关
    Q_PROPERTY(bool contentBlurEnabled READ contentBlurEnabled WRITE setContentBlurEnabled NOTIFY contentBlurEnabledChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    QString desktopBackground() const;
    void setDesktopBackground(const QString &background);

    QString desktopWallpaper() const;
    void setDesktopWallpaper(const QString &wallpaper);

    QString windowTitleBarMode() const;
    void setWindowTitleBarMode(const QString &mode);

    QString windowTitleBarColor() const;
    void setWindowTitleBarColor(const QString &color);

    // 新增
    bool contentBlurEnabled() const;
    void setContentBlurEnabled(bool enabled);

    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void loadSettings();

    Q_INVOKABLE QString saveWallpaperImage(const QString &sourcePath);
    Q_INVOKABLE bool removeWallpaperFile();
    Q_INVOKABLE QString getWallpaperPath() const;
    Q_INVOKABLE bool isValidColor(const QString &color);
    Q_INVOKABLE void setWallpaperInfo(const QString &name, const QString &description);
    Q_INVOKABLE QVariantMap getWallpaperInfo() const;

signals:
    void desktopBackgroundChanged(const QString &background);
    void desktopWallpaperChanged(const QString &wallpaper);
    void windowTitleBarModeChanged(const QString &mode);
    void windowTitleBarColorChanged(const QString &color);
    void wallpaperInfoChanged(const QString &name, const QString &description);
    // 新增
    void contentBlurEnabledChanged(bool enabled);

private:
    QSettings *m_settings;
    QString m_desktopBackground;
    QString m_desktopWallpaper;
    QString m_windowTitleBarMode;
    QString m_windowTitleBarColor;
    // 新增
    bool m_contentBlurEnabled = false;

    QString m_wallpaperPath;
    static const QString WALLPAPER_FILENAME;
    void initializeWallpaperDir();
    QString getImageExtension(const QString &sourcePath);
    QString getWallpaperDir() const;

    QString m_currentWallpaperName;
    QString m_currentWallpaperDescription;
};

#endif // SETTINGSMANAGER_H
