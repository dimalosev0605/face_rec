#include "available_people_model.h"


Available_people_model::Available_people_model(QObject *parent)
    : Base_people_model(parent)
{
    load_data();
}

void Available_people_model::load_data()
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

void Available_people_model::update()
{
    clear();
    load_data();
}

void Available_people_model::delete_individual(const int index)
{
    if(index < 0 || index >= model_data.size()) return;

    Individual_file_manager individual_file_manager;

    beginRemoveRows(QModelIndex(), index, index);
    individual_file_manager.set_name(std::get<0>(model_data[index]));
    individual_file_manager.delete_dir();
    model_data.remove(index);
    endRemoveRows();
}
