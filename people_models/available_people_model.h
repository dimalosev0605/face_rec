#ifndef AVAILABLE_PEOPLE_MODEL_H
#define AVAILABLE_PEOPLE_MODEL_H

#include "base_people_model.h"
#include "other/individual_file_manager.h"

class Available_people_model: public Base_people_model
{
    Q_OBJECT
    std::unique_ptr<QVector<std::tuple<QString, QString>>> available_people = nullptr;

private:
    void load_data();

public:
    explicit Available_people_model(QObject* parent = nullptr);

public slots:
    void update();
    void delete_individual(const int index);
    void search_individual(const QString& nickname);
    void cancel_search();
};

#endif // AVAILABLE_PEOPLE_MODEL_H
