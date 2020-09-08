#include "left_vertical_menu_bar_model.h"

const QString Left_vertical_menu_bar_model::path_to_icons_folder = "qrc:/left_vertical_menu_bar_icons/";

Left_vertical_menu_bar_model::Left_vertical_menu_bar_model (QObject* parent)
    : QAbstractListModel(parent)
{
    roles[static_cast<int>(RolesNames::menu_option_text)] = "menu_option_text";
    roles[static_cast<int>(RolesNames::menu_option_icon_path)] = "menu_option_icon_path";
    roles[static_cast<int>(RolesNames::menu_option_action)] = "menu_option_action";

    menu_data.push_back(std::make_tuple("People", path_to_icons_folder + "people.png", MenuBarAction::Action::ADD_PEOPLE));
    menu_data.push_back(std::make_tuple("Recognition", path_to_icons_folder + "recognition.png", MenuBarAction::Action::RECOGNITION));
    menu_data.push_back(std::make_tuple("Exit", path_to_icons_folder + "exit.png", MenuBarAction::Action::EXIT));
    menu_data.push_back(std::make_tuple("Help", path_to_icons_folder + "help.jpg", MenuBarAction::Action::HELP));
}

QHash<int, QByteArray> Left_vertical_menu_bar_model::roleNames() const
{
    return roles;
}

int Left_vertical_menu_bar_model::rowCount([[maybe_unused]]const QModelIndex& index) const
{
    return menu_data.size();
}

QVariant Left_vertical_menu_bar_model::data(const QModelIndex& index, int role) const
{
    const int row = index.row();
    if(row < 0 || row >= menu_data.size()) return QVariant{};

    switch(role) {
    case static_cast<int>(RolesNames::menu_option_text): {
        return std::get<0>(menu_data[row]);
    }

    case static_cast<int>(RolesNames::menu_option_icon_path): {
        return std::get<1>(menu_data[row]);
    }

    case static_cast<int>(RolesNames::menu_option_action): {
        return static_cast<int>(std::get<2>(menu_data[row]));
    }
    }

    return QVariant{};
}

