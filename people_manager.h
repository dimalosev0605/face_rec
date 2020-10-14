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

private:
    QHash<int, QByteArray> roleNames() const override;
    void load_people();
    void clear();

public:
    enum class RolesNames {
        individual_name = Qt::UserRole,
        avatar_path
    };
    explicit People_manager(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    void update_people_list();
    void delete_individual(const int index);
};

#endif // PEOPLE_MANAGER_H
