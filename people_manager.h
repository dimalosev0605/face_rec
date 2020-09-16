#ifndef PEOPLE_MANAGER_H
#define PEOPLE_MANAGER_H

#include <QAbstractListModel>
#include <QDebug>

#include "individual_file_manager.h"


class People_manager: public QAbstractListModel
{
    Q_OBJECT
    QHash<int, QByteArray> roles;
    QVector<int> model_data;

private:
    QHash<int, QByteArray> roleNames() const override;
    Individual_file_manager individual_file_manager;

public:
    enum class RolesNames {
    };
    explicit People_manager(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    bool create_individual_dir(const QString& name);
    void cancel_individual_creation();

signals:
    void message(const QString& message);

};

#endif // PEOPLE_MANAGER_H
