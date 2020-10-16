#include "selected_people_model.h"

Selected_people_model::Selected_people_model(QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::individual_name)] = "individual_name";
    roles[static_cast<int>(RolesNames::avatar_path)] = "avatar_path";
}

QHash<int, QByteArray> Selected_people_model::roleNames() const
{
    return roles;
}


int Selected_people_model::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant Selected_people_model::data(const QModelIndex& index, int role) const
{
    const int row = index.row();
    if(row < 0 || row >= model_data.size()) return QVariant{};

    switch(role) {
    case static_cast<int>(RolesNames::individual_name): {
        return std::get<0>(model_data[row]);
    }

    case static_cast<int>(RolesNames::avatar_path): {
        return std::get<1>(model_data[row]);
    }
    }

    return QVariant{};
}

void Selected_people_model::accept_item(const QString& name, const QString& avatar_path)
{
    std::tuple<QString, QString> elem(std::tuple<QString, QString>(name, avatar_path));
    beginInsertRows(QModelIndex(), model_data.size(), model_data.size());
    model_data.push_back(elem);
    endInsertRows();
}

void Selected_people_model::delete_item(const int index)
{
    if(index < 0 || index >= model_data.size()) return;

    const QString name = std::get<0>(model_data[index]);
    const QString avatar_path = std::get<1>(model_data[index]);

    beginRemoveRows(QModelIndex(), index, index);
    model_data.remove(index);
    endRemoveRows();

    emit item_deleted(name, avatar_path);
}

void Selected_people_model::clear()
{
    if(!model_data.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, model_data.size() - 1);
        model_data.clear();
        endRemoveRows();
    }
}

void Selected_people_model::delete_all_items()
{
    for(int i = 0; i < model_data.size(); ++i) {
        emit item_deleted(std::get<0>(model_data[i]), std::get<1>(model_data[i]));
    }
    clear();
}
