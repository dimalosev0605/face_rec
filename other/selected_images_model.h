#ifndef SELECTED_IMAGES_MODEL_H
#define SELECTED_IMAGES_MODEL_H

#include <QAbstractListModel>
#include <QDebug>
#include <QUrl>
#include <QFile>

class Selected_images_model: public QAbstractListModel
{
    Q_OBJECT
    QHash<int, QByteArray> roles;
    QVector<QUrl> model_data;

private:
    QHash<int, QByteArray> roleNames() const override;

public:
    enum class RolesNames {
        img_file_path = Qt::UserRole,
        img_file_name
    };
    explicit Selected_images_model(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    void accept_images(const QList<QUrl>& urls);
    void delete_image(const int index);
    void clear();
};

#endif // SELECTED_IMAGES_MODEL_H
