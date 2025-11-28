#include "Tracker.h"
#include <QDebug>
#include <iostream>
#include <cmath>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QSysInfo>
#include <QDir>
#include <QFile>

using namespace std;

const double SPEED_MULTIPLIER = 3.6f;

Tracker::Tracker(QString ip) : QObject()
    , timer(new QTimer(this))
    , lastGear(0)
    , lastElectricity(false)
    , ip(ip)
{
    this->socket = new QTcpSocket(this);

    connect(this->socket, &QTcpSocket::connected, [this]() {
        emit communicationEstablished(true);
        this->timer->stop();
    });
    connect(this->socket, &QTcpSocket::errorOccurred, this, &Tracker::onErrorOccurred);
    connect(this->socket, &QTcpSocket::disconnected, this->socket, &QTcpSocket::deleteLater);
    connect(this->socket, &QTcpSocket::readyRead, this, &Tracker::frameReceived);

    connect(this->timer, &QTimer::timeout, this, &Tracker::retryConnection);
}

void Tracker::onErrorOccurred(QAbstractSocket::SocketError socketError) {
    emit communicationEstablished(false);
    this->timer->start(1000);
}

void Tracker::retryConnection() {
    this->establishCommunication();
}

void Tracker::establishCommunication() {
    this->socket->connectToHost(this->ip, 3101);
}

void Tracker::frameReceived() {
    QByteArray data = this->socket->readAll();
    this->buffer.append(data);

    int index;

    while ((index = buffer.indexOf('\0')) != -1) {
        QByteArray frame = buffer.left(index);
        buffer.remove(0, index + 1);
        this->processFrame(frame);
    }
}

QString valueToTime(qint64 value) {
    QDate baseDate(1, 1, 1);

    const qint64 secsToAdd = value * qint64(60);

    QDateTime baseDt(baseDate, QTime(0,0), QTimeZone::utc());

    QDateTime result = baseDt.addSecs(secsToAdd);
    if (!result.isValid()) {
        return QString("0:0");
    }

    return result.toString("hh:mm");
}

QString valueToRemainingTime(qint64 value) {
    double fullHours;
    double remainingMinutes = std::modf(value / 60.0, &fullHours);

    int hours   = static_cast<int>(fullHours);
    int minutes = static_cast<int>(remainingMinutes * 60);

    return QString::number(hours) + ":" + QString::number(minutes).rightJustified(2, '0');
}

void Tracker::processFrame(QByteArray frame) {
    QJsonDocument document = QJsonDocument::fromJson(frame);
    QJsonObject data = document.object();
    std::string payloadType = data.value("payloadType").toString().toStdString();
    QJsonObject payload = data.value("payload").toObject();

    if (payloadType == "frame") {
        QJsonObject truck      = payload.value("truck").toObject();
        QJsonObject config     = truck.value("config").toObject();
        QJsonObject engine     = truck.value("engine").toObject();
        QJsonObject job        = payload.value("job").toObject();
        QJsonObject navigation = truck.value("navigation").toObject();

        int gear = truck.value("displayedGear").toInt();
        if (gear != this->lastGear) {
            emit gearChanged(gear);
            this->lastGear = gear;
        }

        bool electricity = truck.value("electricEnabled").toBool();
        if (electricity != this->lastElectricity) {
            emit electricityChanged(electricity);
            this->lastElectricity = electricity;
        }

        double speed = truck.value("speed").toDouble() * SPEED_MULTIPLIER;
        int speedFormatted = speed < 1.0 ? 0 : static_cast<int>(speed);
        int speedLimit     = static_cast<int>(navigation.value("speed_limit").toDouble() * SPEED_MULTIPLIER);
        int rpm = (int)(engine.value("rpm").toDouble() / 100);
        double fuelPercentage = truck.value("fuel").toObject().value("amount").toDouble() / config.value("fuelCapacity").toDouble();
        double adbluePercentage = truck.value("adblue").toObject().value("amount").toDouble() / config.value("adblueCapacity").toDouble();

        QJsonObject light = truck.value("light").toObject();
        bool leftBlinker = light.value("leftBlinker").toBool();
        bool rightBlinker = light.value("rightBlinker").toBool();
        bool lowBeam = light.value("lowBeam").toBool();
        bool highBeam = light.value("highBeam").toBool();

        QJsonObject brake = truck.value("brake").toObject();
        bool parking = brake.value("parking").toBool();
        bool pressureWarning = brake.value("airPressureWarning").toBool();
        bool retarder = brake.value("retarder").toInt() > 0;
        bool engineBrake = brake.value("motor").toBool();
        int gameTime = static_cast<int>(payload.value("gameTime").toDouble());
        int deliveryTime = static_cast<int>(navigation.value("time").toDouble());
        int restStop = static_cast<int>(payload.value("restStop").toDouble());

        int odometer = static_cast<int>(truck.value("odometer").toDouble());

        emit dataChanged(
            speed,
            speedLimit,
            rpm,
            fuelPercentage,
            adbluePercentage,
            retarder,
            engineBrake,
            leftBlinker,
            rightBlinker,
            lowBeam,
            highBeam,
            parking,
            pressureWarning,
            valueToTime(gameTime),
            valueToRemainingTime(deliveryTime / 60),
            valueToRemainingTime(restStop),
            odometer
        );
    }
}
