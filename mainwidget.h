#ifndef MAINWIDGET_H
#define MAINWIDGET_H

#include <QWidget>
#include <QSystemTrayIcon>

class QSplitter;

class MainWidget : public QWidget
{
    Q_OBJECT

public:
    explicit MainWidget(QWidget *parent = 0);
    ~MainWidget();

public slots:
    void slot_activatedSysTrayIcon(QSystemTrayIcon::ActivationReason reason);

protected:
    virtual void closeEvent(QCloseEvent *event);

private:
    QSplitter *m_splitter;
    QSystemTrayIcon *m_systemTray;
};

#endif // MAINWIDGET_H
