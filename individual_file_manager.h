#ifndef INDIVIDUAL_FILE_MANAGER_H
#define INDIVIDUAL_FILE_MANAGER_H

#include <QDebug>
#include <QCoreApplication>
#include <QFile>
#include <QDir>

class Individual_file_manager
{    
    static const QString data_dir;
    static const QString source_files_dir;
    static const QString temp_files_dir;
    static const QString extracted_faces_dir;

    const QString app_dir_path = QCoreApplication::applicationDirPath();
    QString path_to_individual_dir;
    QString individual_name;

private:
    void create_data_dir() const;
    bool create_source_files_dir() const;
    bool create_temp_files_dir() const;
    bool create_extracted_faces_dir() const;

public:
    enum class Status {
        success_individual_dir_creation = 0,
        such_individual_already_exists,
        dir_creation_error
    };

    explicit Individual_file_manager();
    Status create_dir() const;

    QString get_path_to_data_dir() const;
    QString get_path_to_source_files_dir() const;
    QString get_path_to_temp_files_dir() const;
    QString get_path_to_temp_file(const QString& prefix, const QString& filename) const;
    QString get_path_to_extracted_faces_dir() const;

    QString get_name() const;
    void set_name(const QString& name);

    void delete_dir() const;
    void delete_temp_files() const;
};

#endif // INDIVIDUAL_FILE_MANAGER_H
