#ifndef FACE_RECOGNITION_IMAGE_HANDLER_H
#define FACE_RECOGNITION_IMAGE_HANDLER_H

#include "base_image_handler.h"

class Face_recognition_image_handler: public Base_image_handler
{
    Q_OBJECT
    double threshold = 0.5;
    std::vector<dlib::rectangle> faces;

public:
    explicit Face_recognition_image_handler(QObject* parent = nullptr);

public slots:
    void hog();
    void cnn();
    void cancel();

    void set_threshold(const double new_threshold);
};

#endif // FACE_RECOGNITION_IMAGE_HANDLER_H
