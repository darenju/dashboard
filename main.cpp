#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QTimer>
#include <QDebug>
#include <QSettings>
#include <iostream>
#include "Tracker.h"

void animateNeedles(QObject *rootObject) {
    rootObject->setProperty("speed", QVariant(120.0));
    rootObject->setProperty("rpm", QVariant(30.0));
    rootObject->setProperty("displayIcons", true);

    QTimer::singleShot(2000, [rootObject]() {
        rootObject->setProperty("speed", QVariant(0.0));
        rootObject->setProperty("rpm", QVariant(0.0));
        rootObject->setProperty("displayIcons", false);
    });
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QSettings settings("config.ini", QSettings::IniFormat);
    settings.beginGroup("Config");
    QString mode    = settings.value("Mode", "release").toString();
    QString ip      = settings.value("IP", "127.0.0.1").toString();
    QString truck   = settings.value("Truck", "generic").toString();
    bool fullscreen = settings.value("Fullscreen", true).toBool();
    settings.endGroup();

    QQmlApplicationEngine engine;
    engine.loadFromModule("Dashboard", "Main");

    QList<QScreen *> screens = QGuiApplication::screens();
    QScreen *target = screens.at(mode == "release" && screens.length() > 1 ? 1 : 0);

    Tracker *tracker = new Tracker(ip);
    if (mode == "release") {
        tracker->establishCommunication();
    }

    QObject *rootObject  = engine.rootObjects().first();
    QQuickWindow *window = qobject_cast<QQuickWindow*>(rootObject);
    window->setProperty("truck", truck);
    window->setProperty("mode", mode);
    window->setPosition(target->geometry().topLeft());

    if (mode == "debug") {
        window->show();

        animateNeedles(rootObject);
        rootObject->setProperty("electricityOn", true);
        rootObject->setProperty("cruiseControl", 50);
    } else {
        window->show();
        if (fullscreen) {
            window->showFullScreen();
        }
    }

    QObject::connect(tracker, &Tracker::communicationEstablished, [rootObject, tracker](bool result) {
        rootObject->setProperty("connected", result);

        if (!result) {
            return;
        }

        QObject::connect(tracker, &Tracker::gearChanged, [rootObject](int gear) {
            QString displayedGear = "N";
            if (gear < 0) {
                displayedGear = QString("R") + QString::number(-gear);
            } else if (gear > 0) {
                displayedGear = QString("D") + QString::number(gear);
            }
            rootObject->setProperty("displayedGear", displayedGear);
        });

        QObject::connect(tracker, &Tracker::electricityChanged, [rootObject](bool electricity) {
            rootObject->setProperty("electricityOn", electricity);

            if (electricity) {
                animateNeedles(rootObject);
            }
        });

        QObject::connect(tracker, &Tracker::dataChanged, [rootObject]
            (int speed, int speedLimit, int cruiseControl, int rpm, double fuelPercentage, double adbluePercentage, bool retarder, bool engineBrake, bool leftBlinker, bool rightBlinker, bool lowBeam, bool highBeam, bool parkingBrake, bool pressureWarning, QString time, QString deliveryTime, QString restTime, int odometer, int deliveryDistance, QString cargo, int cargoWeight, int oilTemperature, QString truckBrand) {
            rootObject->setProperty("speed", QVariant(speed));
            rootObject->setProperty("speedLimit", QVariant(speedLimit));
            rootObject->setProperty("cruiseControl", QVariant(cruiseControl));
            rootObject->setProperty("rpm", QVariant(rpm));
            rootObject->setProperty("fuelPercentage", QVariant(fuelPercentage));
            rootObject->setProperty("adbluePercentage", QVariant(adbluePercentage));
            rootObject->setProperty("retarder", QVariant(retarder));
            rootObject->setProperty("engineBrake", QVariant(engineBrake));
            rootObject->setProperty("leftBlinker", QVariant(leftBlinker));
            rootObject->setProperty("rightBlinker", QVariant(rightBlinker));
            rootObject->setProperty("lowBeam", QVariant(lowBeam));
            rootObject->setProperty("highBeam", QVariant(highBeam));
            rootObject->setProperty("parkingBrake", QVariant(parkingBrake));
            rootObject->setProperty("time", time);
            rootObject->setProperty("deliveryTime", deliveryTime);
            rootObject->setProperty("restTime", restTime);
            rootObject->setProperty("odometer", odometer);
            rootObject->setProperty("deliveryDistance", deliveryDistance);
            rootObject->setProperty("cargo", cargo);
            rootObject->setProperty("cargoWeight", cargoWeight);
            rootObject->setProperty("oilTemperature", oilTemperature);
            rootObject->setProperty("truckBrand", truckBrand);
        });
    });

    return app.exec();
}
