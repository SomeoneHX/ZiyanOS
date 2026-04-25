#include "appregistry.h"
#include <QQuickWindow>
#include <QWindow>
#include <QCloseEvent>
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlContext>
#include <QStandardPaths>
#include <QDir>
#include <QFileSystemWatcher>
#include <QDebug>

AppRegistry* AppRegistry::s_instance = nullptr;
QQmlEngine* AppRegistry::s_qmlEngine = nullptr;

AppRegistry::AppRegistry(QObject *parent)
    : QObject(parent)
    , m_appModel(new AppModel(this))
    , m_activeWindowsModel(new ActiveWindowsModel(this))
{
    m_activeWindowsModel->setAppRegistry(this);
    loadBuiltinApps();
    loadUserApps();

    // 监视用户应用目录变化（可选）
    QString userAppDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/apps";
    QFileSystemWatcher *watcher = new QFileSystemWatcher(this);
    watcher->addPath(userAppDir);
    connect(watcher, &QFileSystemWatcher::directoryChanged, this, [this](){
        loadUserApps(); // 重新加载用户应用
    });
}

AppRegistry* AppRegistry::instance()
{
    if (!s_instance)
        s_instance = new AppRegistry();
    return s_instance;
}

void AppRegistry::setQmlEngine(QQmlEngine *engine)
{
    s_qmlEngine = engine;
}

void AppRegistry::loadBuiltinApps()
{
    QFile file(":/qt/qml/ZiyanOS/src/resources/config/builtin_apps.json");
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open builtin apps config";
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonArray appsArray = doc.array();

    for (const QJsonValue &val : appsArray) {
        QJsonObject obj = val.toObject();
        AppInfo info;
        info.id = obj["id"].toString();
        info.name = obj["name"].toString();
        info.icon = obj["icon"].toString();
        info.emoji = obj["emoji"].toString();
        info.desktopVisible = obj["desktopVisible"].toBool(true);
        QString type = obj["launchType"].toString();
        if (type == "qml")
            info.launchType = AppInfo::QmlComponent;
        else if (type == "native")
            info.launchType = AppInfo::NativeProcess;
        else if (type == "web")
            info.launchType = AppInfo::WebView;
        info.launchTarget = obj["launchTarget"].toString();
        if (obj.contains("categories")) {
            for (const QJsonValue &cat : obj["categories"].toArray())
                info.categories << cat.toString();
        }
        if (obj.contains("defaultSize")) {
            QJsonObject sizeObj = obj["defaultSize"].toObject();
            info.defaultSize = QSize(sizeObj["width"].toInt(), sizeObj["height"].toInt());
        }
        if (obj.contains("minimumSize")) {
            QJsonObject sizeObj = obj["minimumSize"].toObject();
            info.minimumSize = QSize(sizeObj["width"].toInt(), sizeObj["height"].toInt());
        }
        info.isSystemApp = obj["isSystemApp"].toBool();
        // 权限等暂不处理
        addApp(info);
    }
}

void AppRegistry::loadUserApps()
{
    QString userAppDir = QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) + "/apps";
    QDir dir(userAppDir);
    if (!dir.exists())
        return;

    QList<AppInfo> userApps;
    for (const QString &subdir : dir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        QString appDir = userAppDir + "/" + subdir;
        QFile infoFile(appDir + "/app.json");
        if (!infoFile.open(QIODevice::ReadOnly))
            continue;

        QJsonDocument doc = QJsonDocument::fromJson(infoFile.readAll());
        QJsonObject obj = doc.object();
        AppInfo info;
        info.id = obj["id"].toString();
        info.name = obj["name"].toString();
        info.icon = obj["icon"].toString();
        info.emoji = obj["emoji"].toString();
        info.desktopVisible = obj["desktopVisible"].toBool(true);
        if (info.icon.startsWith("."))
            info.icon = appDir + "/" + info.icon; // 转为绝对路径
        QString type = obj["launchType"].toString();
        if (type == "qml")
            info.launchType = AppInfo::QmlComponent;
        else if (type == "native")
            info.launchType = AppInfo::NativeProcess;
        else if (type == "web")
            info.launchType = AppInfo::WebView;
        info.launchTarget = obj["launchTarget"].toString();
        if (info.launchTarget.startsWith("."))
            info.launchTarget = appDir + "/" + info.launchTarget;
        // 其他字段可选
        info.isSystemApp = false;
        userApps.append(info);
    }

    // 合并到 m_apps，替换之前加载的用户应用（简单实现：重新构建整个列表）
    QList<AppInfo> allApps;
    for (const AppInfo &app : m_apps) {
        if (app.isSystemApp)
            allApps.append(app);
    }
    allApps.append(userApps);
    m_apps = allApps;
    m_appModel->setApps(m_apps);
}

void AppRegistry::addApp(const AppInfo &app)
{
    m_apps.append(app);
    m_appModel->setApps(m_apps);
}

void AppRegistry::launchApp(const QString &appId, const QVariantMap &parameters)
{
    // 查找应用
    auto it = std::find_if(m_apps.begin(), m_apps.end(),
                           [&appId](const AppInfo &info) { return info.id == appId; });
    if (it == m_apps.end()) {
        qWarning() << "Unknown app:" << appId;
        return;
    }
    const AppInfo &info = *it;

    QObject *window = nullptr;
    switch (info.launchType) {
    case AppInfo::QmlComponent:
        window = createQmlWindow(info, parameters);
        break;
    case AppInfo::NativeProcess:
        // 暂不支持，可后续扩展
        qWarning() << "Native process not yet supported";
        return;
    case AppInfo::WebView:
        // 暂不支持，可后续扩展
        qWarning() << "WebView not yet supported";
        return;
    }

    if (window) {
        registerWindow(window, info.id);
        // 调用窗口的 showWindow 方法（ZiyanWindow 已定义）
        QMetaObject::invokeMethod(window, "showWindow", Qt::QueuedConnection,
                                  Q_ARG(QVariant, QVariant()), Q_ARG(QVariant, QVariant()));
    }
}
QObject* AppRegistry::createQmlWindow(const AppInfo &info, const QVariantMap &params)
{
    if (!s_qmlEngine) {
        qWarning() << "QML engine not set";
        return nullptr;
    }

    QUrl url(info.launchTarget);
    if (url.isRelative()) {
        url = QUrl::fromLocalFile(info.launchTarget);
    }
    if (!url.isValid()) {
        qWarning() << "Invalid QML URL:" << info.launchTarget;
        return nullptr;
    }

    QQmlComponent component(s_qmlEngine, url);
    if (component.isError()) {
        qWarning() << "Failed to load QML component:" << component.errorString();
        return nullptr;
    }

    QQmlContext *context = s_qmlEngine->rootContext();
    QObject *obj = component.create(context);
    QQuickWindow *window = qobject_cast<QQuickWindow*>(obj);
    if (!window) {
        qWarning() << "Created object is not a QQuickWindow";
        delete obj;
        return nullptr;
    }

    // 设置应用 ID
    window->setProperty("appId", info.id);

    // 设置默认尺寸
    if (info.defaultSize.isValid()) {
        window->resize(info.defaultSize);
    }

    // 监听窗口关闭事件，自动注销
    connect(window, &QQuickWindow::closing, this, [this, window](QQuickCloseEvent*) {
        unregisterWindow(window);
    });

    return window;
}

void AppRegistry::registerWindow(QObject *window, const QString &appId)
{
    if (m_windowToAppId.contains(window))
        return;

    m_activeWindows.append(window);
    m_windowToAppId[window] = appId;
    updateActiveWindowsModel();
    emit activeWindowsChanged();
}

void AppRegistry::unregisterWindow(QObject *window)
{
    if (!m_windowToAppId.contains(window))
        return;

    m_activeWindows.removeOne(window);
    m_windowToAppId.remove(window);
    updateActiveWindowsModel();
    emit activeWindowsChanged();
}

void AppRegistry::updateActiveWindowsModel()
{
    m_activeWindowsModel->setWindows(m_activeWindows);
}

QObject* AppRegistry::getWindowByIndex(int index) const
{
    return m_activeWindowsModel->getWindow(index);
}

QString AppRegistry::getAppEmoji(const QString &appId) const
{
    auto it = std::find_if(m_apps.begin(), m_apps.end(),
                           [&appId](const AppInfo &info) { return info.id == appId; });
    if (it != m_apps.end() && !it->emoji.isEmpty()) {
        return it->emoji;
    }
    return "📄";
}

void AppRegistry::updateWindowSettings()
{
    for (QObject *window : m_activeWindows) {
        QMetaObject::invokeMethod(window, "updateWindowSettings", Qt::QueuedConnection);
    }
}