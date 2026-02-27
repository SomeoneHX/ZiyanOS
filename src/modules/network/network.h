#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QString>

class NetworkManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString localIP READ localIP NOTIFY localIPChanged)

public:
    explicit NetworkManager(QObject *parent = nullptr);
    QString localIP() const;

signals:
    void localIPChanged();

private:
    QString m_localIP;
    void updateLocalIP();
};

#endif
