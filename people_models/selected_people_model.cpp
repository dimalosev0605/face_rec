#include "people_models/selected_people_model.h"

Selected_people_model::Selected_people_model(QObject *parent)
    : Base_people_model(parent)
{

}

QVector<QString> Selected_people_model::get_selected_people_list() const
{
    QVector<QString> selected_people;
    selected_people.reserve(model_data.size());
    for(int i = 0; i < model_data.size(); ++i) {
        selected_people.push_back(std::get<0>(model_data[i]));
    }
    return selected_people;
}
