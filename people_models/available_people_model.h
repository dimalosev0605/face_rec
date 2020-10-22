#ifndef AVAILABLE_PEOPLE_MODEL_H
#define AVAILABLE_PEOPLE_MODEL_H

#include "base_people_model.h"
#include "other/individual_file_manager.h"

class Available_people_model: public Base_people_model
{
    Q_OBJECT
private:
    void load_data();

public:
    explicit Available_people_model(QObject* parent = nullptr);

public slots:
    void update();
    void delete_individual(const int index);

};

#endif // AVAILABLE_PEOPLE_MODEL_H
