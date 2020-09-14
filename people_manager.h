#ifndef PEOPLE_MANAGER_H
#define PEOPLE_MANAGER_H

#include <QAbstractListModel>
#include <QDebug>
#include <QDir>
#include <QFile>
#include <QCoreApplication>

class People_manager: public QAbstractListModel
{
    Q_OBJECT
    QHash<int, QByteArray> roles;
    QVector<int> model_data;
    QString new_person_name;

    static const QString data_folder_name;
    static const QString temp_files_folder_name;
    static const QString processed_files_folder_name;

private:
    QHash<int, QByteArray> roleNames() const override;

    void create_data_folder() const;
    QString get_path_to_data_folder() const;

    bool create_folder_for_temp_files() const;
    bool create_folder_for_processed_files() const;

public:
    enum class RolesNames {
    };
    explicit People_manager(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    bool create_nominal_folder(const QString& name);
    void cancel_nominal_creation();

signals:
    void message(const QString& message);

};

#endif // PEOPLE_MANAGER_H
