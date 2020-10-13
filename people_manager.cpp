#include "people_manager.h"

People_manager::People_manager(QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::individual_name)] = "individual_name";
    roles[static_cast<int>(RolesNames::avatar_path)] = "avatar_path";
    load_people();
}

void People_manager::load_people()
{
    Individual_file_manager individual_file_manager;
    const auto data_dir_path = individual_file_manager.get_path_to_data_dir();

    QDir data_dir(data_dir_path);
    data_dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
    data_dir.setSorting(QDir::SortFlag::Name);

    const auto people_list = data_dir.entryList();
    if(people_list.isEmpty()) return;

    model_data.reserve(people_list.size());
    beginInsertRows(QModelIndex(), 0, people_list.size() - 1);
    for(const auto& individual_name : people_list) {
        individual_file_manager.set_name(individual_name);
        const auto random_avatar_path = individual_file_manager.get_path_to_random_source_file();
        model_data.push_back(std::tuple<QString, QString>(individual_name, random_avatar_path));
    }
    endInsertRows();
}

QHash<int, QByteArray> People_manager::roleNames() const
{
    return roles;
}


int People_manager::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant People_manager::data(const QModelIndex &index, int role) const
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

void People_manager::update_people_list()
{
    if(!model_data.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, model_data.size() - 1);
        model_data.clear();
        endRemoveRows();
    }

    load_people();
}

void People_manager::delete_individual(const int index)
{
    if(index < 0 || index >= model_data.size()) return;

    Individual_file_manager individual_file_manager;

    beginRemoveRows(QModelIndex(), index, index);
    individual_file_manager.set_name(std::get<0>(model_data[index]));
    individual_file_manager.delete_dir();
    model_data.remove(index);
    endRemoveRows();
}
