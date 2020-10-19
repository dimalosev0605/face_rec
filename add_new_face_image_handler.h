#ifndef ADD_NEW_FACE_IMAGE_HANDLER_H
#define ADD_NEW_FACE_IMAGE_HANDLER_H

#include "base_image_handler.h"

class Add_new_face_image_handler: public Base_image_handler
{
    Q_OBJECT
    dlib::rectangle rect_around_face;

public:
    explicit Add_new_face_image_handler(QObject* parent = nullptr);

public slots:
    void cnn();
    void hog();
    void set_current_individual_name(const QString& name);
    void extract_face();
    void cancel();

signals:
    void enable_extract_face_btn();
};

#endif // ADD_NEW_FACE_IMAGE_HANDLER_H
