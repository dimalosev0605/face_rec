#include "base_image_handler.h"

Base_image_handler::Base_image_handler(QObject* parent)
    : QObject(parent)
{
    std::thread load_model_thread([this]()
    {
        dlib::deserialize("mmod_human_face_detector.dat") >> cnn_face_detector;
        dlib::deserialize("shape_predictor_5_face_landmarks.dat") >> shape_predictor;
    });
    load_model_thread.detach();
}

bool Base_image_handler::check_img_existense(const QString& path)
{
    QFile check_existense;
    return check_existense.exists(path);
}

QString Base_image_handler::copy_selected_img_path()
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    return selected_img_path;
}

void Base_image_handler::set_worker_thread_id()
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    worker_thread_id = std::this_thread::get_id();
}

void Base_image_handler::load_processing_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix)
{
    const auto processing_img_path = individual_file_manager.get_path_to_temp_file(prefix, QUrl(path).fileName());
    QFile img_file;
    if(img_file.exists(processing_img_path)) {
        dlib::load_image(img, processing_img_path.toStdString());
    }
    else {
        dlib::load_image(img, path.toStdString());
    }
}

QString Base_image_handler::save_processed_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix)
{
    cv::Mat cv_mat = dlib::toMat(img);
    QImage q_img(cv_mat.data, cv_mat.cols, cv_mat.rows, cv_mat.step, QImage::Format_RGB888);
    const auto q_img_path = individual_file_manager.get_path_to_temp_file(prefix, QUrl(path).fileName());
    if(q_img.save(q_img_path)) {
        return q_img_path;
    }
    else {
        return QString{};
    }
}

void Base_image_handler::update_processed_img(const QString& processing_img_path, dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix)
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    if(worker_thread_id == std::this_thread::get_id()) {
        const auto path = save_processed_image(img, processing_img_path, prefix);
        if(!path.isEmpty()) {
            emit img_source_changed("file://" + path);
        }
    }
}

void Base_image_handler::pyr_up()
{
    worker_thread.reset(new std::thread([this]()
    {
        const auto processing_img_path = copy_selected_img_path();
        set_worker_thread_id();
        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        dlib::pyramid_up(img);

        update_processed_img(processing_img_path, img, "resized_");

    }));
    worker_thread->detach();
}

void Base_image_handler::pyr_down()
{
    worker_thread.reset(new std::thread([this]()
    {
        const auto processing_img_path = copy_selected_img_path();
        set_worker_thread_id();
        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        dlib::pyramid_down<2> pyr;
        pyr(img);

        update_processed_img(processing_img_path, img, "resized_");

    }));
    worker_thread->detach();
}

void Base_image_handler::resize(const int new_width, const int new_height)
{
    worker_thread.reset(new std::thread([this, new_width, new_height]()
    {
        const auto processing_img_path = copy_selected_img_path();
        set_worker_thread_id();
        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        dlib::matrix<dlib::rgb_pixel> resized_img(new_height, new_width);
        dlib::resize_image(img, resized_img);

        update_processed_img(processing_img_path, resized_img, "resized_");

    }));
    worker_thread->detach();
}

void Base_image_handler::update_selected_img_path(const QString& new_path)
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    selected_img_path = new_path;
    selected_img_path.remove("file://");
}
