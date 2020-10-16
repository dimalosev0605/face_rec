#ifndef BASE_PEOPLE_MODEL_H
#define BASE_PEOPLE_MODEL_H

#include <QAbstractListModel>
#include <QDebug>
#include <QUrl>

class Base_people_model: public QAbstractListModel
{
    Q_OBJECT
    QHash<int, QByteArray> roles;

private:
    QHash<int, QByteArray> roleNames() const override;

protected:
    QVector<std::tuple<QString, QString>> model_data; // 1 -> individual name, 2 -> avatar path.

protected:
    void clear();

public:
    enum class RolesNames {
        individual_name = Qt::UserRole,
        avatar_path
    };
    explicit Base_people_model(QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;

public slots:
    void accept_item(const QString& individual_name, const QString& avatar_path);
    void pass_item(const int index);
    void pass_all_items();

signals:
    void item_passed(const QString& individual_name, const QString& avatar_path);
};

#endif // BASE_PEOPLE_MODEL_H
