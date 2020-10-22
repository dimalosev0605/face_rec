#include "other/individual_manager.h"

Individual_manager::Individual_manager(QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::src_img_path)] = "src_img_path";
    roles[static_cast<int>(RolesNames::extracted_face_img_path)] = "extracted_face_img_path";
    roles[static_cast<int>(RolesNames::file_name)] = "file_name";
}

QHash<int, QByteArray> Individual_manager::roleNames() const
{
    return roles;
}

bool Individual_manager::add_new(const QString& name)
{
    individual_file_manager.set_name(name);

    auto status_code = individual_file_manager.create_dir();

    switch(status_code) {

    case Individual_file_manager::Status::success_individual_dir_creation: {
        emit message("Success!");
        return true;
    }
    case Individual_file_manager::Status::such_individual_already_exists: {
        emit message("Such individ already exists.");
        return false;
    }
    case Individual_file_manager::Status::dir_creation_error: {
        emit message("Can't create some directories.");
        return false;
    }

    }

    return false;
}

void Individual_manager::cancel_creation()
{
    individual_file_manager.delete_dir();
}

int Individual_manager::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant Individual_manager::data(const QModelIndex &index, int role) const
{
    const int row = index.row();
    if(row < 0 || row >= model_data.size()) return QVariant{};

    switch (role) {
    case static_cast<int>(RolesNames::src_img_path): {
        return std::get<0>(model_data[row]);
    }

    case static_cast<int>(RolesNames::extracted_face_img_path): {
        return std::get<1>(model_data[row]);
    }

    case static_cast<int>(RolesNames::file_name): {
        return std::get<2>(model_data[row]);
    }
    }

    return QVariant{};
}

bool Individual_manager::add_face(const QString& source_img_path, const QString& extracted_face_img_path)
{
    const auto src_copy_to_path = individual_file_manager.generate_path_for_copy_of_source_file();
    const auto extr_face_copy_to_path = individual_file_manager.generate_path_for_copy_of_extr_face_file();

    const QString src_copy_from_path = QString{source_img_path}.remove("file://");
    const QString extr_face_copy_from_path = QString{extracted_face_img_path}.remove("file://");

    QFile src_file(src_copy_from_path);
    QFile extr_face_file(extr_face_copy_from_path);

    if(src_file.copy(src_copy_to_path) && extr_face_file.copy(extr_face_copy_to_path)) {
        beginInsertRows(QModelIndex(), model_data.size(), model_data.size());
        model_data.push_back(std::tuple<QString, QString, QString>(src_copy_to_path, extr_face_copy_to_path, QUrl(src_copy_to_path).fileName()));
        endInsertRows();
        return true;
    }
    else {
        src_file.remove(src_copy_to_path);
        extr_face_file.remove(extr_face_copy_from_path);
        return false;
    }
}

void Individual_manager::delete_face(const int index)
{
    if(index < 0 || index >= model_data.size()) return;

    const auto src_path = std::get<0>(model_data[index]);
    const auto extracted_face_path = std::get<1>(model_data[index]);

    QFile src_file;
    QFile extr_face_file;
    if(src_file.remove(src_path) && extr_face_file.remove(extracted_face_path)) {
        beginRemoveRows(QModelIndex(), 0, model_data.size() - 1);
        endRemoveRows();
        model_data.removeAt(index);
    }

    for(int i = index; i < model_data.size(); ++i) {
        const QString new_src_file_name = individual_file_manager.get_path_to_source_file_by_number(i);
        QFile old_src_file(std::get<0>(model_data[i]));
        std::get<0>(model_data[i]) = new_src_file_name;
        old_src_file.rename(new_src_file_name);

        const QString new_extr_face_file_name = individual_file_manager.get_path_to_extr_face_file_by_number(i);
        QFile old_extr_face_file(std::get<1>(model_data[i]));
        std::get<1>(model_data[i]) = new_extr_face_file_name;
        old_extr_face_file.rename(new_extr_face_file_name);

        QString new_file_name = individual_file_manager.get_name() + '_' + QString::number(i);
        std::get<2>(model_data[i]) = new_file_name;
    }

    if(!model_data.isEmpty()) {
        beginInsertRows(QModelIndex(), 0, model_data.size() - 1);
        endInsertRows();
    }
}

void Individual_manager::load_data()
{
    individual_file_manager.set_name(edited_individual_name);

    QDir dir;
    dir.setFilter(QDir::Files);

    const auto src_files_dir_path = individual_file_manager.get_path_to_source_files_dir();
    dir.setPath(src_files_dir_path);
    const auto sources = dir.entryInfoList();

    const auto extr_faces_dir_path = individual_file_manager.get_path_to_extracted_faces_dir();
    dir.setPath(extr_faces_dir_path);
    const auto extr_faces = dir.entryInfoList();

    if(sources.isEmpty() || extr_faces.isEmpty()) return;
    if(sources.size() != extr_faces.size()) return;

    const int last_row_number = sources.size() - 1;
    beginInsertRows(QModelIndex(), 0, last_row_number);
    for(int i = 0; i < sources.size(); ++i) {
        std::tuple<QString, QString, QString> elem =
                std::tuple<QString, QString, QString>(sources[i].filePath(), extr_faces[i].filePath(), sources[i].fileName());
        model_data.push_back(elem);
    }
    endInsertRows();
}

void Individual_manager::clear()
{
    if(!model_data.isEmpty()) {
        beginRemoveRows(QModelIndex(), 0, model_data.size() - 1);
        model_data.clear();
        endRemoveRows();
    }
}

void Individual_manager::change_nickname(const QString& new_nickname)
{
    edited_individual_name = new_nickname;

    const auto data_dir_path = individual_file_manager.get_path_to_data_dir();
    QDir data_dir(data_dir_path);
    if(data_dir.exists(new_nickname)) {
        emit message("Such nick already exists.");
        return;
    }

    const QString old_individual_name = individual_file_manager.get_name();

    QDir dir;
    dir.setFilter(QDir::Files);

    const auto source_files_dir_path = individual_file_manager.get_path_to_source_files_dir();
    dir.setPath(source_files_dir_path);
    const auto sources = dir.entryInfoList();

    int number = 0;
    for(auto& file : sources) {
        QFile rename_file(file.filePath());
        QString new_source_file_name = file.path() + '/' + new_nickname + '_' + QString::number(number);
        rename_file.rename(new_source_file_name);
        ++number;
    }

    const auto extracted_faces_dir_path = individual_file_manager.get_path_to_extracted_faces_dir();
    dir.setPath(extracted_faces_dir_path);
    const auto extr_faces = dir.entryInfoList();

    number = 0;
    for(auto& file : extr_faces) {
        QFile rename_file(file.filePath());
        QString new_extracted_face_file_name = file.path() + '/' + new_nickname + '_' + QString::number(number);
        rename_file.rename(new_extracted_face_file_name);
        ++number;
    }

    data_dir.rename(old_individual_name, new_nickname);

    clear();
    load_data();
}

void Individual_manager::set_edited_individual_name(const QString& name)
{
    edited_individual_name = name;
    individual_file_manager.set_name(edited_individual_name);
    clear();
    load_data();
}
