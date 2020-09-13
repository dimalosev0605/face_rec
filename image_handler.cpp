#include "image_handler.h"

Image_handler::Image_handler(QObject* parent)
    : QObject(parent)
{

}

void Image_handler::update_path(const QString& new_path)
{
    selected_img_path = new_path;
}
