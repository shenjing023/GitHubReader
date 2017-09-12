#ifndef FILEMODEL_H
#define FILEMODEL_H

#include <QFileSystemModel>

class FileModel : public QFileSystemModel
{
    Q_OBJECT
public:
    explicit FileModel(QObject *parent=Q_NULLPTR);
    ~FileModel();

    //通过https获取文件数据，并保存到临时文件夹
    Q_INVOKABLE void getFileData(const QString &url);

    enum Roles{
            UrlStringRole=Qt::UserRole+7
        };
        Q_ENUM(Roles)
    QVariant data(const QModelIndex &index, int role=Qt::DisplayRole) const Q_DECL_OVERRIDE;

private:
    //删除临时文件夹
    void deleteTmpDir(const QString &dirName);
};

#endif // FILEMODEL_H
