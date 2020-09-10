#include "selected_images_model.h"

Selected_images_model::Selected_images_model(QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::file_path)] = "file_path";
    roles[static_cast<int>(RolesNames::file_name)] = "file_name";
}

QHash<int, QByteArray> Selected_images_model::roleNames() const
{
    return roles;
}

int Selected_images_model::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return model_data.size();
}

QVariant Selected_images_model::data(const QModelIndex& index, int role) const
{
    const int row = index.row();
    if(row < 0 || row >= model_data.size()) return QVariant{};

    switch (role) {
    case static_cast<int>(RolesNames::file_path): {
        return model_data[row].url();
    }

    case static_cast<int>(RolesNames::file_name): {
        return model_data[row].fileName();
    }
    }

    return QVariant{};
}

void Selected_images_model::accept_images(const QList<QUrl>& file_urls)
{
    if(file_urls.isEmpty()) return;

    // delete duplications!

    beginInsertRows(QModelIndex(), model_data.size(), model_data.size() + file_urls.size() - 1);
    for(const auto& i : file_urls) {
        model_data.push_back(i);
    }
    endInsertRows();
}

void Selected_images_model::delete_image(const int index)
{
    if(index < 0 || index >= model_data.size()) return;
    beginRemoveRows(QModelIndex(), index, index);
    model_data.removeAt(index);
    endRemoveRows();
}
