#ifndef APPINFO_H
#define APPINFO_H

#include <QString>
#include <QSize>
#include <QStringList>

class AppInfo
{
public:
    enum LaunchType {
        QmlComponent,
        NativeProcess,
        WebView
    };

    QString id;
    QString name;
    QString icon;
    LaunchType launchType = QmlComponent;
    QString launchTarget;   // QML 文件路径、可执行文件路径或 URL
    QStringList categories;
    QSize defaultSize;
    QSize minimumSize;
    bool isSystemApp = false;
    QStringList permissions; // 未来扩展
};

#endif // APPINFO_H