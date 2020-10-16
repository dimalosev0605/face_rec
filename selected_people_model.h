#ifndef SELECTED_PEOPLE_MODEL_H
#define SELECTED_PEOPLE_MODEL_H

#include <QAbstractListModel>
#include <QDebug>
#include <QUrl>

class Selected_people_model: public QAbstractListModel
{
    Q_OBJECT
    QHash<int, QByteArray> roles;
    QVector<std::tuple<QString, QString>> model_data; // 1 -> individual name, 2 -> avatar path.

private:
    QHash<int, QByteArray> roleNames() const override;
    void clear();

public:
    enum class RolesNames {
        individual_name = Qt::UserRole,
        avatar_path
    };
    explicit Selected_people_model(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    void accept_item(const QString& name, const QString& avatar_path);
    void delete_item(const int index);
    void delete_all_items();

signals:
    void item_deleted(const QString& name, const QString& avatar_path);
};

#endif // SELECTED_PEOPLE_MODEL_H
