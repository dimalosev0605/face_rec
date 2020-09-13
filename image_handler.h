#ifndef IMAGE_HANDLER_H
#define IMAGE_HANDLER_H

#include <QObject>
#include <QDebug>

class Image_handler : public QObject
{
    Q_OBJECT
    QString selected_img_path;

public:
    explicit Image_handler(QObject* parent = nullptr);

public slots:
    void update_path(const QString& new_path);

signals:

};

#endif // IMAGE_HANDLER_H
