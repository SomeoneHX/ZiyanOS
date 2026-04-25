#ifndef APPMODEL_H
#define APPMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "appinfo.h"

class AppModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        AppIdRole = Qt::UserRole + 1,
        NameRole,
        IconRole,
        EmojiRole,
        DisplayIconRole,
        DesktopVisibleRole,
        CategoriesRole,
        IsSystemAppRole
    };

    explicit AppModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setApps(const QList<AppInfo> &apps);
    QList<AppInfo> apps() const { return m_apps; }

private:
    QList<AppInfo> m_apps;
};

#endif // APPMODEL_H