#ifndef PROCESSED_IMAGES_PROVIDER_H
#define PROCESSED_IMAGES_PROVIDER_H

#include <QQuickImageProvider>
#include <QDebug>

class Processed_images_provider: public QQuickImageProvider
{
public:
    explicit Processed_images_provider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
};

#endif // PROCESSED_IMAGES_PROVIDER_H
