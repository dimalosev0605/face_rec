#include "people_manager.h"

const QString People_manager::data_folder_name = "people";
const QString People_manager::temp_files_folder_name = "temp";
const QString People_manager::processed_files_folder_name = "processed_files";

People_manager::People_manager(QObject* parent)
    : QAbstractListModel(parent)
{
    create_data_folder();
}

QHash<int, QByteArray> People_manager::roleNames() const
{
    return roles;
}

void People_manager::create_data_folder() const
{
    const auto data_folder_path = QCoreApplication::applicationDirPath() + '/' + data_folder_name;
    QDir data_folder;
    data_folder.mkdir(data_folder_name);
}

QString People_manager::get_path_to_data_folder() const
{
    const auto path = QCoreApplication::applicationDirPath() + '/' + data_folder_name;
    return path;
}

bool People_manager::create_folder_for_temp_files() const
{
    const auto folder_path = get_path_to_data_folder() + '/' + new_person_name + '/' + temp_files_folder_name;
    QDir temp_files_folder;
    return temp_files_folder.mkdir(folder_path);
}

bool People_manager::create_folder_for_processed_files() const
{
    const auto folder_path = get_path_to_data_folder() + '/' + new_person_name + '/' + processed_files_folder_name;
    QDir processed_files_folder;
    return processed_files_folder.mkdir(folder_path);
}

bool People_manager::create_nominal_folder(const QString& name)
{
    const auto nominal_folder_path = get_path_to_data_folder() + '/' + name;
    new_person_name = name;
    QDir nominal_folder(nominal_folder_path);
    if(nominal_folder.exists()) {
        emit message("Such person already exists!");
        cancel_nominal_creation();
        return false;
    }
    else {
        if(nominal_folder.mkdir(nominal_folder_path)) {
            if(create_folder_for_temp_files() && create_folder_for_processed_files()) {
                return true;
            }
            else {
                emit message("Can't create some directories!");
                cancel_nominal_creation();
                return false;
            }
        }
        else {
            emit message("Can't create directory for processed images!");
            cancel_nominal_creation();
            return false;
        }
    }
}

void People_manager::cancel_nominal_creation()
{
    const auto nominal_folder_path = get_path_to_data_folder() + '/' + new_person_name;
    QDir nominal_folder(nominal_folder_path);
    nominal_folder.removeRecursively();
    new_person_name.clear();
}

int People_manager::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant People_manager::data(const QModelIndex &index, int role) const
{
    return QVariant{};
}
