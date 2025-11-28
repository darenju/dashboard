#ifndef TRACKER_H
#define TRACKER_H

#define Q_STEP 0.01
#define EPS_DEC 0.005
#define EPS_INC_NOISE 0.1
#define REFUEL_THRESHOLD 2.0
#define WARMUP_TICKS 3

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QJsonObject>

class Tracker : public QObject {
    Q_OBJECT

public:
    Tracker(QString);
    void checkPluginPresence();
    void establishCommunication();
    bool restoreSave();
    enum LogLevel { INFO, ERROR, WARNING };

private:
    QTcpSocket *socket = nullptr;
    QString ip;
    QTimer *timer = nullptr;
    QByteArray buffer;
    int lastGear;
    bool lastElectricity;

    void processFrame(QByteArray);
    void log(QString,LogLevel = INFO);

private slots:
    void onErrorOccurred(QAbstractSocket::SocketError);
    void retryConnection();

public slots:
    void frameReceived();
signals:
    void communicationEstablished(bool);
    void gearChanged(int);
    void electricityChanged(bool);
    void dataChanged(int,int,int,double,double,bool,bool,bool,bool,bool,bool,bool,bool,QString,QString,QString,int);
};

#endif // TRACKER_H
