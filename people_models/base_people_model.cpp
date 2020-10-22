#include "people_models/base_people_model.h"

Base_people_model::Base_people_model(QObject *parent):
    QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::individual_name)] = "individual_name";
    roles[static_cast<int>(RolesNames::avatar_path)] = "avatar_path";
}

QHash<int, QByteArray> Base_people_model::roleNames() const
{
    return roles;
}

int Base_people_model::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant Base_people_model::data(const QModelIndex& index, int role) const
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

void Base_people_model::clear()
{
    if(!model_data.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, model_data.size() - 1);
        model_data.clear();
        endRemoveRows();
    }
}

void Base_people_model::accept_item(const QString& individual_name, const QString& avatar_path)
{
    beginInsertRows(QModelIndex(), model_data.size(), model_data.size());
    model_data.push_back(std::tuple<QString, QString>(individual_name, avatar_path));
    endInsertRows();
}

void Base_people_model::pass_item(const int index)
{
    if(index < 0 || index >= model_data.size()) return;

    const QString individual_name = std::get<0>(model_data[index]);
    const QString avatar_path = std::get<1>(model_data[index]);

    beginRemoveRows(QModelIndex(), index, index);
    model_data.remove(index);
    endRemoveRows();

    emit item_passed(individual_name, avatar_path);
}

void Base_people_model::pass_all_items()
{
    for(int i = 0; i < model_data.size(); ++i) {
        emit item_passed(std::get<0>(model_data[i]), std::get<1>(model_data[i]));
    }
    clear();
}
