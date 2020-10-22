#ifndef SELECTED_PEOPLE_MODEL_H
#define SELECTED_PEOPLE_MODEL_H

#include "base_people_model.h"

class Selected_people_model: public Base_people_model
{
    Q_OBJECT
public:
    explicit Selected_people_model(QObject* parent = nullptr);

public slots:
    QVector<QString> get_selected_people_list() const;
};

#endif // SELECTED_PEOPLE_MODEL_H
