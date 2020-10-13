#include "individual_file_manager.h"

const QString Individual_file_manager::data_dir = "data";
const QString Individual_file_manager::source_files_dir = "source_files";
const QString Individual_file_manager::temp_files_dir = "temp_files";
const QString Individual_file_manager::extracted_faces_dir = "extracted_faces";

Individual_file_manager::Individual_file_manager()
{
    create_data_dir();
}

void Individual_file_manager::create_data_dir() const
{
    const auto path = app_dir_path + '/' + data_dir;
    QDir dir(path);
    if(!dir.exists()) {
        dir.mkdir(path);
    }
}

bool Individual_file_manager::create_source_files_dir() const
{
    const auto path = path_to_individual_dir + '/' + source_files_dir;
    QDir dir;
    return dir.mkdir(path);
}

bool Individual_file_manager::create_temp_files_dir() const
{
    const auto path = path_to_individual_dir + '/' + temp_files_dir;
    QDir dir;
    return dir.mkdir(path);
}

bool Individual_file_manager::create_extracted_faces_dir() const
{
    const auto path = path_to_individual_dir + '/' + extracted_faces_dir;
    QDir dir;
    return dir.mkdir(path);
}

Individual_file_manager::Status Individual_file_manager::create_dir() const
{
    const auto path = path_to_individual_dir;
    QDir dir(path);
    if(dir.exists()) {
        return Status::such_individual_already_exists;
    }
    else {
        if(dir.mkdir(path)) {
            if(create_source_files_dir() && create_temp_files_dir() && create_extracted_faces_dir()) {
                return Status::success_individual_dir_creation;
            }
            else {
                delete_dir();
                return Status::dir_creation_error;
            }
        }
        else {
            return Status::dir_creation_error;
        }
    }
}

QString Individual_file_manager::get_path_to_data_dir() const
{
    const auto path = app_dir_path + '/' + data_dir;
    return path;
}

QString Individual_file_manager::get_path_to_source_files_dir() const
{
    const auto path = path_to_individual_dir + '/' + source_files_dir;
    return path;
}

QString Individual_file_manager::get_path_to_temp_files_dir() const
{
    const auto path = path_to_individual_dir + '/' + temp_files_dir;
    return path;
}

QString Individual_file_manager::get_path_to_temp_file(const QString& prefix, const QString& filename) const
{
    const auto path = path_to_individual_dir + '/' + temp_files_dir + '/' + prefix + filename;
    return path;
}

QString Individual_file_manager::get_path_to_extracted_faces_dir() const
{
    const auto path = path_to_individual_dir + '/' + extracted_faces_dir;
    return path;
}

QString Individual_file_manager::get_name() const
{
    return individual_name;
}

void Individual_file_manager::set_name(const QString& name)
{
    individual_name = name;
    path_to_individual_dir = get_path_to_data_dir() + '/' + individual_name;
}

void Individual_file_manager::delete_dir() const
{
    if(individual_name.isEmpty()) return;
    QDir dir(path_to_individual_dir);
    dir.removeRecursively();
}

void Individual_file_manager::delete_temp_files() const
{
    const auto path = get_path_to_temp_files_dir();
    QDir dir(path);
    dir.setFilter(QDir::Files);
    for(auto& file : dir.entryList()) {
        dir.remove(file);
    }
}
