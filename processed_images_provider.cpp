#include "processed_images_provider.h"

Processed_images_provider::Processed_images_provider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{

}

QImage Processed_images_provider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    qDebug() << "IN QImage Processed_images_provider::requestImage()";
    qDebug() << "id = " << id;
    QImage img(QUrl(id).toString(QUrl::PreferLocalFile));
    return img;
}
