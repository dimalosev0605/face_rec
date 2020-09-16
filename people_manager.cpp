#include "people_manager.h"

People_manager::People_manager(QObject* parent)
    : QAbstractListModel(parent)
{
}

QHash<int, QByteArray> People_manager::roleNames() const
{
    return roles;
}

bool People_manager::create_individual_dir(const QString& name)
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

void People_manager::cancel_individual_creation()
{
    individual_file_manager.cancel_individual_dir_creation();
}

int People_manager::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant People_manager::data(const QModelIndex &index, int role) const
{
    return QVariant{};
}
