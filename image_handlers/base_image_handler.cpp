#include "image_handlers/base_image_handler.h"

Base_image_handler::Base_image_handler(QObject* parent)
    : QObject(parent)
{
    auto initializer_thread_lambda = [](std::shared_ptr<Shared_data> shared_data_sp)
    {
        {
            std::lock_guard<std::mutex> lock(shared_data_sp->cnn_face_detector_mtx);
            dlib::deserialize("mmod_human_face_detector.dat") >> (shared_data_sp->cnn_face_detector);
        }
        {
            std::lock_guard<std::mutex> lock(shared_data_sp->shape_predictor_mtx);
            dlib::deserialize("shape_predictor_5_face_landmarks.dat") >> (shared_data_sp->shape_predictor);
        }
        {
            std::lock_guard<std::mutex> lock(shared_data_sp->hog_face_detector_mtx);
            shared_data_sp->hog_face_detector = dlib::get_frontal_face_detector();
        }
    };
    initializer_thread = std::thread(initializer_thread_lambda, shared_data);
    initializer_thread.detach();
}

bool Base_image_handler::check_img_existense(const QString& path)
{
    QFile check_existense;
    return check_existense.exists(path);
}

QString Base_image_handler::copy_selected_img_path(std::shared_ptr<Shared_data> shared_data_sp)
{
    std::lock_guard<std::mutex> lock(shared_data_sp->selected_img_path_mtx);
    return shared_data_sp->selected_img_path;
}

void Base_image_handler::set_worker_thread_id(std::shared_ptr<Shared_data> shared_data_sp)
{
    std::lock_guard<std::mutex> lock(shared_data_sp->worker_thread_id_mtx);
    shared_data_sp->worker_thread_id = std::this_thread::get_id();
}

void Base_image_handler::load_processing_image(std::shared_ptr<Shared_data> shared_data_sp, dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix)
{
    const auto processing_img_path = shared_data_sp->individual_file_manager.get_path_to_temp_file(prefix, QUrl(path).fileName());
    QFile img_file;
    if(img_file.exists(processing_img_path)) {
        dlib::load_image(img, processing_img_path.toStdString());
    }
    else {
        dlib::load_image(img, path.toStdString());
    }
}

QString Base_image_handler::save_processed_image(std::shared_ptr<Shared_data> shared_data_sp, dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix)
{
    cv::Mat cv_mat = dlib::toMat(img);
    QImage q_img(cv_mat.data, cv_mat.cols, cv_mat.rows, cv_mat.step, QImage::Format_RGB888);
    const auto q_img_path = shared_data_sp->individual_file_manager.get_path_to_temp_file(prefix, QUrl(path).fileName());
    if(q_img.save(q_img_path)) {
        return q_img_path;
    }
    else {
        return QString{};
    }
}

void Base_image_handler::update_processed_img(std::shared_ptr<Shared_data> shared_data_sp, const QString& processing_img_path, dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix)
{
    std::lock_guard<std::mutex> lock(shared_data_sp->worker_thread_id_mtx);
    if(shared_data_sp->worker_thread_id == std::this_thread::get_id()) {
        const auto path = save_processed_image(shared_data_sp, img, processing_img_path, prefix);
        if(!path.isEmpty()) {
            emit img_source_changed("file://" + path);
        }
    }
}

void Base_image_handler::pyr_up()
{
    // I capture [this] only for access to functions.
    auto lambda = [this](std::shared_ptr<Shared_data> shared_data_sp)
    {
        set_worker_thread_id(shared_data_sp);
        const auto processing_img_path = copy_selected_img_path(shared_data_sp);
        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(shared_data_sp, img, processing_img_path, "resized_");

        // actual work
        dlib::pyramid_up(img);

        update_processed_img(shared_data_sp, processing_img_path, img, "resized_");
    };
    worker_thread.reset(new std::thread(lambda, shared_data));
    worker_thread->detach();
}

void Base_image_handler::pyr_down()
{
    auto lambda = [this](std::shared_ptr<Shared_data> shared_data_sp)
    {
        set_worker_thread_id(shared_data_sp);
        const auto processing_img_path = copy_selected_img_path(shared_data_sp);
        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(shared_data_sp, img, processing_img_path, "resized_");

        // actual work
        dlib::pyramid_down<2> pyr;
        pyr(img);

        update_processed_img(shared_data_sp, processing_img_path, img, "resized_");
    };
    worker_thread.reset(new std::thread(lambda, shared_data));
    worker_thread->detach();
}

void Base_image_handler::resize(const int new_width, const int new_height)
{
    auto lambda = [this, new_width, new_height](std::shared_ptr<Shared_data> shared_data_sp)
    {
        set_worker_thread_id(shared_data_sp);
        const auto processing_img_path = copy_selected_img_path(shared_data_sp);
        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(shared_data_sp, img, processing_img_path, "resized_");

        // actual work
        dlib::matrix<dlib::rgb_pixel> resized_img(new_height, new_width);
        dlib::resize_image(img, resized_img);

        update_processed_img(shared_data_sp, processing_img_path, img, "resized_");
    };
    worker_thread.reset(new std::thread(lambda, shared_data));
    worker_thread->detach();
}

void Base_image_handler::set_selected_img_path(const QString& new_path)
{   
    std::lock_guard<std::mutex> lock(shared_data->selected_img_path_mtx);
    shared_data->selected_img_path = new_path;
    shared_data->selected_img_path.remove("file://");
}
