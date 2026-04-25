// SettingsManager.h
#ifndef SETTINGSMANAGER_H
#define SETTINGSMANAGER_H

#include <QObject>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QColor>
#include <QRegularExpression>

class SettingsManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString desktopBackground READ desktopBackground WRITE setDesktopBackground NOTIFY desktopBackgroundChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);

    QString desktopBackground() const;
    void setDesktopBackground(const QString &background);

    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void loadSettings();
    Q_INVOKABLE bool isValidColor(const QString &color);

signals:
    void desktopBackgroundChanged(const QString &background);

private:
    QSettings *m_settings;
    QString m_desktopBackground;
};

#endif // SETTINGSMANAGER_H
