#ifndef ACTIVEWINDOWSMODEL_H
#define ACTIVEWINDOWSMODEL_H

#include <QAbstractListModel>
#include <QList>
#include <QObject>

class ActiveWindowsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        WindowObjectRole = Qt::UserRole + 1,
        TitleRole,
        IconRole
    };

    explicit ActiveWindowsModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setWindows(const QList<QObject*> &windows);
    QObject* getWindow(int index) const;

private:
    QList<QObject*> m_windows;
};

#endif // ACTIVEWINDOWSMODEL_H