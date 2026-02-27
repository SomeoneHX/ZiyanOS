#include "network.h"
#include <QNetworkInterface>
#include <QDebug>

NetworkManager::NetworkManager(QObject *parent) : QObject(parent)
{
    updateLocalIP();
}

QString NetworkManager::localIP() const
{
    return m_localIP;
}

void NetworkManager::updateLocalIP()
{
    QString ip;
    const QList<QHostAddress> addresses = QNetworkInterface::allAddresses();
    for (const QHostAddress &address : addresses) {
        if (address.protocol() == QAbstractSocket::IPv4Protocol &&
            address != QHostAddress::LocalHost) {
            ip = address.toString();
            break;
        }
    }
    if (ip != m_localIP) {
        m_localIP = ip;
        emit localIPChanged();
    }
}
