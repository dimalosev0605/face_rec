#ifndef BASE_IMAGE_HANDLER_H
#define BASE_IMAGE_HANDLER_H

#include <QObject>
#include <QDebug>
#include <QThread>
#include <QImage>
#include <QUrl>

#include <dlib/image_io.h>
#include <dlib/image_processing/frontal_face_detector.h>
#include <dlib/image_processing.h>
#include <dlib/dnn.h>
#include <dlib/image_io.h>
#include <dlib/opencv.h>
#include <opencv2/imgproc.hpp>
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>

#include <thread>
#include <utility>

#include "other/individual_file_manager.h"

template <long num_filters, typename SUBNET> using con5d = dlib::con<num_filters,5,5,2,2,SUBNET>;
template <long num_filters, typename SUBNET> using con5  = dlib::con<num_filters,5,5,1,1,SUBNET>;

template <typename SUBNET> using downsampler  = dlib::relu<dlib::affine<con5d<32, dlib::relu<dlib::affine<con5d<32, dlib::relu<dlib::affine<con5d<16,SUBNET>>>>>>>>>;
template <typename SUBNET> using rcon5  = dlib::relu<dlib::affine<con5<45,SUBNET>>>;

using net_type = dlib::loss_mmod<dlib::con<1,9,9,1,1,rcon5<rcon5<rcon5<downsampler<dlib::input_rgb_image_pyramid<dlib::pyramid_down<6>>>>>>>>;

class Base_image_handler: public QObject
{
    Q_OBJECT

protected:
    QString selected_img_path;

    std::unique_ptr<std::thread> worker_thread;
    std::mutex worker_thread_mutex;
    std::thread::id worker_thread_id;

    std::shared_ptr<net_type> cnn_face_detector = std::make_shared<net_type>();
    std::shared_ptr<dlib::shape_predictor> shape_predictor = std::make_shared<dlib::shape_predictor>();
    Individual_file_manager individual_file_manager;

    std::thread load_models_thread;

protected:
    bool check_img_existense(const QString& path);
    QString copy_selected_img_path();
    void set_worker_thread_id();

    void load_processing_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix);
    QString save_processed_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix);
    void update_processed_img(const QString& processing_img_path, dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix);

public:
    explicit Base_image_handler(QObject* parent = nullptr);
    ~Base_image_handler();

public slots:
    void pyr_up();
    void pyr_down();
    void resize(const int new_width, const int new_height);

    void update_selected_img_path(const QString& new_path);

signals:
    void img_source_changed(const QString& source);
};

#endif // BASE_IMAGE_HANDLER_H
