#ifndef SEARCHLISTMODEL_H
#define SEARCHLISTMODEL_H

#include "searchmodelworker.h"
#include <QObject>

class SearchListModel : public QObject
{
    Q_OBJECT
public:
    explicit SearchListModel(QObject *parent = Q_NULLPTR);
    ~SearchListModel();

    Q_INVOKABLE void getListData(const QString &url);

signals:
    void signal_listData(const QString &url);
    void signal_dataDone(const QString &list);

public slots:
    void slot_dataDone(const QString &list);

private:
    QScopedPointer<SearchModelWorker> pWork;
    QThread *m_thread;
    bool m_isRunning;   //当前线程是否正在运行
};

#endif // SEARCHLISTMODEL_H
