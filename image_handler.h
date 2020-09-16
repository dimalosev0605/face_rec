#ifndef IMAGE_HANDLER_H
#define IMAGE_HANDLER_H

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

#include "individual_file_manager.h"

template <long num_filters, typename SUBNET> using con5d = dlib::con<num_filters,5,5,2,2,SUBNET>;
template <long num_filters, typename SUBNET> using con5  = dlib::con<num_filters,5,5,1,1,SUBNET>;

template <typename SUBNET> using downsampler  = dlib::relu<dlib::affine<con5d<32, dlib::relu<dlib::affine<con5d<32, dlib::relu<dlib::affine<con5d<16,SUBNET>>>>>>>>>;
template <typename SUBNET> using rcon5  = dlib::relu<dlib::affine<con5<45,SUBNET>>>;

using net_type = dlib::loss_mmod<dlib::con<1,9,9,1,1,rcon5<rcon5<rcon5<downsampler<dlib::input_rgb_image_pyramid<dlib::pyramid_down<6>>>>>>>>;

class Image_handler : public QObject
{
    Q_OBJECT
    QString selected_img_path;
    std::unique_ptr<std::thread> worker_thread;
    dlib::frontal_face_detector hog_face_detector = dlib::get_frontal_face_detector();
    net_type cnn_face_detector;
    dlib::shape_predictor shape_predictor;
    Individual_file_manager individual_file_manager;

public:
    explicit Image_handler(QObject* parent = nullptr);

public slots:
    void update_path(const QString& new_path);
    void set_current_individual_name(const QString& name);
    void hog();

signals:
    void img_source_changed(const QString& source);
};

#endif // IMAGE_HANDLER_H
