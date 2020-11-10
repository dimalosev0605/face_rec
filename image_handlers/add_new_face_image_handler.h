#ifndef ADD_NEW_FACE_IMAGE_HANDLER_H
#define ADD_NEW_FACE_IMAGE_HANDLER_H

#include "base_image_handler.h"

class Add_new_face_image_handler: public Base_image_handler
{
    Q_OBJECT
    std::shared_ptr<dlib::rectangle> rect_around_face = std::make_shared<dlib::rectangle>();
    std::shared_ptr<std::mutex> rect_around_face_mtx = std::make_shared<std::mutex>();

public:
    explicit Add_new_face_image_handler(QObject* parent = nullptr);

public slots:
    void cnn() override;
    void hog() override;
    void cancel() override;

    void set_current_individual_name(const QString& name);
    void extract_face();

signals:
    void enable_extract_face_btn();
};

#endif // ADD_NEW_FACE_IMAGE_HANDLER_H
