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

    std::unique_ptr<std::thread> worker_thread;
    std::thread::id worker_thread_id;
    std::mutex worker_thread_mutex;
    QString selected_img_path;
    dlib::rectangle rect_around_face;

    net_type cnn_face_detector;
    dlib::shape_predictor shape_predictor;
    Individual_file_manager individual_file_manager;

private:
    bool check_img_existense(const QString& path);
    void update_processed_img(const QString& processing_img_path, dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix);
    void load_processing_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& path);
    QString save_processed_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix, const QString& path);

public:
    explicit Image_handler(QObject* parent = nullptr);

public slots:
    void update_selected_img_path(const QString& new_path);
    void set_current_individual_name(const QString& name);
    void hog();
    void cnn();
    void pyr_up();
    void pyr_down();
    void cancel();
    void extract_face();

signals:
    void img_source_changed(const QString& source);
};

#endif // IMAGE_HANDLER_H
