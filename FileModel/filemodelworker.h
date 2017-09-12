/*
 * 通过网络连接获取GitHub文件的线程
*/
#ifndef FILEMODELWORKER_H
#define FILEMODELWORKER_H

#include <QObject>
#include <QThread>

class QNetworkAccessManager;

class FileModelWorker : public QObject
{
    Q_OBJECT
public:
    explicit FileModelWorker(const QString &url,QObject *parent = Q_NULLPTR);
    ~FileModelWorker();

signals:
    void signal_finished();

public slots:
    void doWork();

private:
    //解析HTML文件，并将解析后的文本保存到本地临时文件夹
    void getHTMLData(const QString &url,const QString &path);
private:
    QNetworkAccessManager *m_pManager;
    QString m_url;
};

#endif // FILEMODELWORKER_H
