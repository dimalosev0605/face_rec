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
    QString edited_individual_name;

private:
    QHash<int, QByteArray> roleNames() const override;
    Individual_file_manager individual_file_manager;

private:
    void load_data();
    void clear();

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
    bool add_new(const QString& name);
    void cancel_creation();
    bool add_face(const QString& source_img_path, const QString& extracted_face_img_path);
    void delete_face(const int index);
    void change_nickname(const QString& new_nickname);
    void set_edited_individual_name(const QString& name);

signals:
    void message(const QString& message);
};

#endif // INDIVIDUAL_MANAGER_H
