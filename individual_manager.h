#ifndef INDIVIDUAL_MANAGER_H
#define INDIVIDUAL_MANAGER_H

#include <QAbstractListModel>
#include <QDebug>
#include <QUrl>

#include "individual_file_manager.h"

class Individual_manager: public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QString individual_name READ individual_name WRITE setIndividual_name NOTIFY individual_nameChanged)

    QHash<int, QByteArray> roles;
    QVector<std::tuple<QString, QString, QString>> model_data; // 1 string - src img. path, 2 string - extr. face img. path, 3 string - file name.
    QString m_individual_name;

private:
    QHash<int, QByteArray> roleNames() const override;
    Individual_file_manager individual_file_manager;

private:
    void load_individual_data();
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

    QString individual_name() const { return m_individual_name; }
    void setIndividual_name(const QString& name) { m_individual_name = name; emit individual_nameChanged(); clear(); load_individual_data(); }

public slots:
    bool add_new(const QString& name);
    void cancel_creation();
    bool add_face(const QString& source_img_path, const QString& extracted_face_img_path);
    void delete_face(const int index);
    void change_nickname(const QString& new_nickname);

signals:
    void message(const QString& message);
    void individual_nameChanged();
    void update_people_model(const QString& new_nick);
};

#endif // INDIVIDUAL_MANAGER_H
