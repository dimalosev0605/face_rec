#include "people_models/available_people_model.h"


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
    if(available_people != nullptr) {
        available_people = std::unique_ptr<QVector<std::tuple<QString, QString>>>(new QVector<std::tuple<QString, QString>>(model_data));
    }
}

void Available_people_model::delete_individual(const int index)
{
    if(index < 0 || index >= model_data.size()) return;

    Individual_file_manager individual_file_manager;
    beginRemoveRows(QModelIndex(), index, index);
    QString nickname_for_removal = std::get<0>(model_data[index]).remove("<b>").remove("</b>");
    individual_file_manager.set_name(nickname_for_removal);
    individual_file_manager.delete_dir();
    if(available_people != nullptr) {
        for(int i = 0; i < available_people->size(); ++i) {
            if(nickname_for_removal == std::get<0>(available_people->operator[](i))) {
                available_people->remove(i);
                break;
            }
        }
    }
    model_data.remove(index);
    endRemoveRows();
}

void Available_people_model::search_individual(const QString& input)
{
    if(input.isEmpty()) return;
    if(available_people == nullptr) {
        available_people = std::unique_ptr<QVector<std::tuple<QString, QString>>>(new QVector<std::tuple<QString, QString>>(model_data));
    }

    QVector<std::tuple<QString, QString>> results;
    for(int i = 0; i < available_people->size(); ++i) {
        if(std::get<0>(available_people->operator[](i)).contains(input)) {
            const QString str = std::get<0>(available_people->operator[](i));
            int start = str.indexOf(input);
            QString bold_str;
            for(int j = 0; j < start; ++j) {
                bold_str.push_back(str[j]);
            }
            bold_str += "<b>" + input + "</b>";
            for(int j = start + input.size(); j < str.size(); ++j) {
                bold_str.push_back(str[j]);
            }
            results.push_back(std::make_tuple(bold_str, std::get<1>(available_people->operator[](i))));
        }
    }
    clear();
    if(results.isEmpty()) return;
    beginInsertRows(QModelIndex(), 0, results.size() - 1);
    model_data = results;
    endInsertRows();
}

void Available_people_model::cancel_search()
{
    clear();
    if(available_people == nullptr) return;
    if(available_people->isEmpty()) return;
    beginInsertRows(QModelIndex(), 0, available_people->size() - 1);
    model_data = *available_people;
    endInsertRows();
}
