#ifndef INDIVIDUAL_MANAGER_H
#define INDIVIDUAL_MANAGER_H

#include <QAbstractListModel>
#include <QDebug>
#include <QUrl>

#include "individual_file_manager.h"

class Individual_manager: public QAbstractListModel
{
    Q_OBJECT
    QHash<int, QByteArray> roles;
    QVector<std::tuple<QString, QString, QString>> model_data; // 1 string - src img. path, 2 string - extr. face img. path, 3 string - file name.

private:
    QHash<int, QByteArray> roleNames() const override;
    Individual_file_manager individual_file_manager;

public:
    enum class RolesNames {
        src_img_path = Qt::UserRole,
        extracted_face_img_path,
        file_name
    };
    explicit Individual_manager(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    bool create_individual_dir(const QString& name);
    void cancel_individual_creation();
    bool add_individual_face(const QString& source_img_path, const QString& extracted_face_img_path);
    void delete_individual_face(const int index);

signals:
    void message(const QString& message);
};

#endif // INDIVIDUAL_MANAGER_H
