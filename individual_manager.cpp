#include "individual_manager.h"

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

bool Individual_manager::create_individual_dir(const QString& name)
{
    individual_file_manager.set_individual_name(name);

    auto status_code = individual_file_manager.create_individual_dir();

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

void Individual_manager::cancel_individual_creation()
{
    individual_file_manager.cancel_individual_dir_creation();
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

bool Individual_manager::add_individual_face(const QString& source_img_path, const QString& extracted_face_img_path)
{
    const auto src_files_path = individual_file_manager.get_path_to_source_files_dir();

    QDir dir(src_files_path);
    dir.setFilter(QDir::Files);
    const auto number_of_files = dir.count();

    const QString src_copy_path = src_files_path + '/' +
            individual_file_manager.get_individual_name() + '_' + QString::number(number_of_files);

    const auto extracted_faces_path = individual_file_manager.get_path_to_extracted_faces_dir();
    const QString extracted_face_copy_path = extracted_faces_path + '/' +
            individual_file_manager.get_individual_name() + '_' + QString::number(number_of_files);

    QFile src_img(QString{source_img_path}.remove("file://"));
    QFile extracted_face_img(QString{extracted_face_img_path}.remove("file://"));

    if(src_img.copy(src_copy_path) && extracted_face_img.copy(extracted_face_copy_path)) {
        qDebug() << "Success copied!";
        beginInsertRows(QModelIndex(), model_data.size(), model_data.size());
        model_data.push_back(std::tuple<QString, QString, QString>{src_copy_path, extracted_face_copy_path, QUrl(src_copy_path).fileName()});
        endInsertRows();
        return true;
    }
    else {
        qDebug() << "Copy error.";
        src_img.remove(src_copy_path);
        extracted_face_img.remove(extracted_face_img_path);
        return false;
    }
}

void Individual_manager::delete_individual_face(const int index)
{
    if(index < 0 || index >= model_data.size()) return;

    const auto src_path = std::get<0>(model_data[index]);
    const auto extracted_face_path = std::get<1>(model_data[index]);

    QFile src_file;
    QFile extr_face_file;
    auto model_copy = model_data;
    if(src_file.remove(src_path) && extr_face_file.remove(extracted_face_path)) {
        beginRemoveRows(QModelIndex(), 0, model_data.size() - 1);
        model_data.clear();
        endRemoveRows();
        model_copy.removeAt(index);
    }
    else {
        qDebug() << "remove error";
    }

    for(int i = index; i < model_copy.size(); ++i) {
        QString new_name = individual_file_manager.get_path_to_source_files_dir() +
                '/' + individual_file_manager.get_individual_name() + '_' + QString::number(i);
        QFile file(std::get<0>(model_copy[i]));
        std::get<0>(model_copy[i]) = new_name;
        file.rename(new_name);
    }

    for(int i = index; i < model_copy.size(); ++i) {
        QString new_name = individual_file_manager.get_path_to_extracted_faces_dir() +
                '/' + individual_file_manager.get_individual_name() + '_' + QString::number(i);
        QFile file(std::get<1>(model_copy[i]));
        std::get<1>(model_copy[i]) = new_name;
        file.rename(new_name);
    }

    for(int i = index; i < model_copy.size(); ++i) {
        QString new_name = individual_file_manager.get_individual_name() + '_' + QString::number(i);
        std::get<2>(model_copy[i]) = new_name;
    }

    beginInsertRows(QModelIndex(), 0, model_copy.size() - 1);
    model_data = model_copy;
    endInsertRows();
}
