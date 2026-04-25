#include "appmodel.h"

AppModel::AppModel(QObject *parent) : QAbstractListModel(parent)
{
}

int AppModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_apps.size();
}

QVariant AppModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_apps.size())
        return QVariant();

    const AppInfo &app = m_apps.at(index.row());
    switch (role) {
    case AppIdRole:
        return app.id;
    case NameRole:
        return app.name;
    case IconRole:
        return app.icon;
    case EmojiRole:
        return app.emoji;
    case DisplayIconRole: {
        QString icon = app.icon;
        if (icon.startsWith("qrc:") || icon.startsWith("file:") || icon.isEmpty())
            return app.emoji.isEmpty() ? "📄" : app.emoji;
        return icon;
    }
    case DesktopVisibleRole:
        return app.desktopVisible;
    case CategoriesRole:
        return app.categories;
    case IsSystemAppRole:
        return app.isSystemApp;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> AppModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[AppIdRole] = "appId";
    roles[NameRole] = "name";
    roles[IconRole] = "icon";
    roles[EmojiRole] = "emoji";
    roles[DisplayIconRole] = "displayIcon";
    roles[DesktopVisibleRole] = "desktopVisible";
    roles[CategoriesRole] = "categories";
    roles[IsSystemAppRole] = "isSystemApp";
    return roles;
}

void AppModel::setApps(const QList<AppInfo> &apps)
{
    beginResetModel();
    m_apps = apps;
    endResetModel();
}