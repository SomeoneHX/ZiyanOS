#include "activewindowsmodel.h"
#include "appregistry.h"

ActiveWindowsModel::ActiveWindowsModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_appRegistry(nullptr)
{
}

int ActiveWindowsModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_windows.size();
}

QVariant ActiveWindowsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_windows.size())
        return QVariant();

    QObject *window = m_windows.at(index.row());
    switch (role) {
    case WindowObjectRole:
        return QVariant::fromValue(window);
    case TitleRole:
        return window->property("windowTitle");
    case IconRole:
    case AppIdRole: {
        QString appId = window->property("appId").toString();
        if (m_appRegistry)
            return m_appRegistry->getAppEmoji(appId);
        return "📄";
    }
    case DisplayIconRole: {
        QString appId = window->property("appId").toString();
        if (m_appRegistry)
            return m_appRegistry->getAppEmoji(appId);
        return "📄";
    }
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ActiveWindowsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[WindowObjectRole] = "windowObject";
    roles[TitleRole] = "title";
    roles[IconRole] = "icon";
    roles[EmojiRole] = "emoji";
    roles[AppIdRole] = "appId";
    roles[DisplayIconRole] = "displayIcon";
    return roles;
}

void ActiveWindowsModel::setWindows(const QList<QObject*> &windows)
{
    beginResetModel();
    m_windows = windows;
    endResetModel();
}

void ActiveWindowsModel::setAppRegistry(AppRegistry *registry)
{
    m_appRegistry = registry;
}

QObject* ActiveWindowsModel::getWindow(int index) const
{
    if (index >= 0 && index < m_windows.size())
        return m_windows.at(index);
    return nullptr;
}