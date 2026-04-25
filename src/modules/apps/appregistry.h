#ifndef APPREGISTRY_H
#define APPREGISTRY_H

#include <QObject>
#include <QQmlEngine>
#include "appmodel.h"
#include "activewindowsmodel.h"

class AppRegistry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(AppModel* appModel READ appModel CONSTANT)
    Q_PROPERTY(ActiveWindowsModel* activeWindowsModel READ activeWindowsModel NOTIFY activeWindowsChanged)

public:
    static AppRegistry* instance();
    static void setQmlEngine(QQmlEngine *engine);

    AppModel* appModel() const { return m_appModel; }
    ActiveWindowsModel* activeWindowsModel() const { return m_activeWindowsModel; }

    Q_INVOKABLE void launchApp(const QString &appId, const QVariantMap &parameters = QVariantMap());
    Q_INVOKABLE QObject* getWindowByIndex(int index) const;
    Q_INVOKABLE QString getAppEmoji(const QString &appId) const;
    Q_INVOKABLE void registerWindow(QObject *window, const QString &appId);
    Q_INVOKABLE void unregisterWindow(QObject *window);
    Q_INVOKABLE void updateAllWindowsSettings();

signals:
    void activeWindowsChanged();

private:
    explicit AppRegistry(QObject *parent = nullptr);
    void loadBuiltinApps();
    void loadUserApps();
    void addApp(const AppInfo &app);
    QObject* createQmlWindow(const AppInfo &info, const QVariantMap &params);
    void updateActiveWindowsModel();

    static AppRegistry *s_instance;
    static QQmlEngine *s_qmlEngine;

    QList<AppInfo> m_apps;
    AppModel *m_appModel;
    ActiveWindowsModel *m_activeWindowsModel;
    QList<QObject*> m_activeWindows;
    QHash<QObject*, QString> m_windowToAppId;
};

#endif // APPREGISTRY_H