#ifndef ADD_NEW_PERSON_IMAGE_HANDLER_H
#define ADD_NEW_PERSON_IMAGE_HANDLER_H

#include "base_image_handler.h"

class Add_new_person_image_handler: public Base_image_handler
{
    Q_OBJECT
    dlib::rectangle rect_around_face;
    dlib::shape_predictor shape_predictor;

public:
    explicit Add_new_person_image_handler(QObject* parent = nullptr);

public slots:
    void cnn();
    void hog();
    void set_current_individual_name(const QString& name);
    void extract_face();
    void cancel();

signals:
    void enable_extract_face_btn();
};

#endif // ADD_NEW_PERSON_IMAGE_HANDLER_H
