#ifndef PEOPLE_MANAGER_H
#define PEOPLE_MANAGER_H

#include <QAbstractListModel>
#include <QDebug>
#include <QUrl>

#include "individual_file_manager.h"

class People_manager: public QAbstractListModel
{
    Q_OBJECT
    QHash<int, QByteArray> roles;
    QVector<std::tuple<QString, QString>> model_data; // 1 -> individual name, 2 -> avatar path.
    Individual_file_manager individual_file_manager;

private:
    QHash<int, QByteArray> roleNames() const override;
    void load_people();

public:
    enum class RolesNames {
        individual_name = Qt::UserRole,
        avatar_path
    };
    explicit People_manager(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
//    void add_new_individual();
//    void delete_individual();

};

#endif // PEOPLE_MANAGER_H
