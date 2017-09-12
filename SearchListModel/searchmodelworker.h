#ifndef SEARCHMODELWORKER_H
#define SEARCHMODELWORKER_H

#include <QObject>
#include <QThread>

class QNetworkAccessManager;

class SearchModelWorker : public QObject
{
    Q_OBJECT
public:
    explicit SearchModelWorker(QObject *parent = Q_NULLPTR);
    ~SearchModelWorker();

signals:
    void signal_dataDone(const QString &list);

public slots:
    //获取HTML文件并解析，返回json格式字符串
    void doWork(const QString &url);

private:
    QNetworkAccessManager *m_pManager;
};

#endif // SEARCHMODELWORKER_H
