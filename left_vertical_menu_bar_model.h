#ifndef LEFT_VERTICAL_MENU_BAR_MODEL_H
#define LEFT_VERTICAL_MENU_BAR_MODEL_H

#include <QAbstractListModel>

namespace MenuBarAction {
Q_NAMESPACE
enum class Action {
    ADD_PEOPLE,
    RECOGNITION,
    EXIT,
    HELP
};
Q_ENUM_NS(Action)
}

class Left_vertical_menu_bar_model : public QAbstractListModel
{
    Q_OBJECT
    QHash<int, QByteArray> roles;
    QVector<std::tuple<QString, QString, MenuBarAction::Action>> menu_data; // 1-st QString - menu option text string, 2-nd QString - path to the icon.

    static const QString path_to_icons_folder;

private:
    QHash<int, QByteArray> roleNames() const override;

public:
    enum class RolesNames {
        menu_option_text = Qt::UserRole,
        menu_option_icon_path,
        menu_option_action
    };
    explicit Left_vertical_menu_bar_model (QObject* parent = nullptr);
    virtual int rowCount(const QModelIndex &index = QModelIndex()) const override;
    virtual QVariant data(const QModelIndex& index, int role) const override;
};

#endif // LEFT_VERTICAL_MENU_BAR_MODEL_H
