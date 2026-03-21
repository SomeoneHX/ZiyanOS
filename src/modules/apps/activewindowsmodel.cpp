#include "activewindowsmodel.h"

ActiveWindowsModel::ActiveWindowsModel(QObject *parent)
    : QAbstractListModel(parent)
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
        return window->property("icon");
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
    return roles;
}

void ActiveWindowsModel::setWindows(const QList<QObject*> &windows)
{
    beginResetModel();
    m_windows = windows;
    endResetModel();
}

QObject* ActiveWindowsModel::getWindow(int index) const
{
    if (index >= 0 && index < m_windows.size())
        return m_windows.at(index);
    return nullptr;
}