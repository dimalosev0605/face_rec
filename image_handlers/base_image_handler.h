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

using cnn_face_detector_type = dlib::loss_mmod<dlib::con<1,9,9,1,1,rcon5<rcon5<rcon5<downsampler<dlib::input_rgb_image_pyramid<dlib::pyramid_down<6>>>>>>>>;

using hog_face_detector_type = dlib::object_detector<dlib::scan_fhog_pyramid<dlib::pyramid_down<6>, dlib::default_fhog_feature_extractor>>;

class Base_image_handler: public QObject
{
    Q_OBJECT

protected:
    struct Shared_data {
        QString selected_img_path;
        std::mutex selected_img_path_mtx;

        std::thread::id worker_thread_id;
        std::mutex worker_thread_id_mtx;

        // need mtx?
        Individual_file_manager individual_file_manager;

        hog_face_detector_type hog_face_detector;
        std::mutex hog_face_detector_mtx;

        cnn_face_detector_type cnn_face_detector;
        std::mutex cnn_face_detector_mtx;

        dlib::shape_predictor shape_predictor;
        std::mutex shape_predictor_mtx;
    };

    std::shared_ptr<Shared_data> shared_data = std::make_shared<Shared_data>();

    std::unique_ptr<std::thread> worker_thread;
    std::thread initializer_thread;

protected:
    bool check_img_existense(const QString& path);
    QString copy_selected_img_path(std::shared_ptr<Shared_data> shared_data_sp);
    void set_worker_thread_id(std::shared_ptr<Shared_data> shared_data_sp);

    void load_processing_image(std::shared_ptr<Shared_data> shared_data_sp, dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix);
    QString save_processed_image(std::shared_ptr<Shared_data> shared_data_sp, dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix);
    void update_processed_img(std::shared_ptr<Shared_data> shared_data_sp, const QString& processing_img_path, dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix);

public:
    explicit Base_image_handler(QObject* parent = nullptr);

public slots:
    void pyr_up();
    void pyr_down();
    void resize(const int new_width, const int new_height);

    virtual void hog() = 0;
    virtual void cnn() = 0;
    virtual void cancel() = 0;

    void set_selected_img_path(const QString& new_path);

signals:
    void img_source_changed(const QString& source);
};

#endif // BASE_IMAGE_HANDLER_H
