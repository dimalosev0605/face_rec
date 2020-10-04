#include "image_handler.h"

Image_handler::Image_handler(QObject* parent)
    : QObject(parent)
{
    std::thread load_models_thread([this]()
    {
        dlib::deserialize("mmod_human_face_detector.dat") >> cnn_face_detector;
        dlib::deserialize("shape_predictor_5_face_landmarks.dat") >> shape_predictor;
        qDebug() << "Models were deserialized";
    });
    load_models_thread.detach();
}

void Image_handler::update_selected_img_path(const QString& new_path)
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    selected_img_path = new_path;
    selected_img_path.remove("file://");
}

void Image_handler::set_current_individual_name(const QString& name)
{
    individual_file_manager.set_individual_name(name);
}

bool Image_handler::check_img_existense(const QString& path)
{
    QUrl url(path);
    QFile check_existense;
    return check_existense.exists(url.toString(QUrl::PreferLocalFile));
}

void Image_handler::load_processing_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix)
{
    const auto processing_img_path = individual_file_manager.get_path_to_temp_files_dir(prefix, QUrl(path).fileName());
    QFile img_file;
    if(img_file.exists(processing_img_path)) {
        dlib::load_image(img, processing_img_path.toStdString());
    }
    else {
        dlib::load_image(img, path.toStdString());
    }
}

QString Image_handler::save_processed_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& path, const QString& prefix)
{
    cv::Mat cv_mat = dlib::toMat(img);
    QImage q_img(cv_mat.data, cv_mat.cols, cv_mat.rows, cv_mat.step, QImage::Format_RGB888);
    const auto q_img_path = individual_file_manager.get_path_to_temp_files_dir(prefix, QUrl(path).fileName());
    if(q_img.save(q_img_path)) {
        return q_img_path;
    }
    else {
        return QString{};
    }
}

void Image_handler::update_processed_img(const QString& processing_img_path, dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix)
{
    const auto path = save_processed_image(img, processing_img_path, prefix);
    qDebug() << "processed img saved, path = " << path;
    if(!path.isEmpty()) {
        emit img_source_changed("file://" + path);
    }
}

void Image_handler::hog()
{
    worker_thread.reset(new std::thread([this]()
    {
        QString processing_img_path;
        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            worker_thread_id = std::this_thread::get_id();
            processing_img_path = selected_img_path;
        }

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        auto hog_face_detector = dlib::get_frontal_face_detector();
        const auto rects_around_faces = hog_face_detector(img);
        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
        }

        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                if(rects_around_faces.size() != 1) {
                    qDebug() << "We must find exactly one face on the image!";
                    update_processed_img(processing_img_path, img, "many_faces_");
                    return;
                }
            }
        }

        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                rect_around_face = rects_around_faces[0];
                update_processed_img(processing_img_path, img, "face_");
                emit enable_extract_face_btn();
            }
        }
    }));
    worker_thread->detach();
}


void Image_handler::cnn()
{
    worker_thread.reset(new std::thread([this]()
    {
        QString processing_img_path;
        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            worker_thread_id = std::this_thread::get_id();
            processing_img_path = selected_img_path;
        }

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        const auto rects_around_faces = cnn_face_detector(img);
        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{0, 255, 0}, 2);
        }

        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                if(rects_around_faces.size() != 1) {
                    qDebug() << "We must find exactly one face on the image!";
                    update_processed_img(processing_img_path, img, "many_faces_");
                    return;
                }
            }
        }

        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                rect_around_face = rects_around_faces[0];
                update_processed_img(processing_img_path, img, "face_");
                emit enable_extract_face_btn();
            }
        }
    }));
    worker_thread->detach();
}

void Image_handler::pyr_up()
{
    worker_thread.reset(new std::thread([this]()
    {
        QString processing_img_path;
        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            worker_thread_id = std::this_thread::get_id();
            processing_img_path = selected_img_path;
        }

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        dlib::pyramid_up(img);

        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                update_processed_img(processing_img_path, img, "resized_");
            }
        }
    }));
    worker_thread->detach();
}

void Image_handler::pyr_down()
{
    worker_thread.reset(new std::thread([this]()
    {
        QString processing_img_path;
        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            worker_thread_id = std::this_thread::get_id();
            processing_img_path = selected_img_path;
        }

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        dlib::pyramid_down<2> pyr;
        pyr(img);

        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                update_processed_img(processing_img_path, img, "resized_");
            }
        }
    }));
    worker_thread->detach();
}

void Image_handler::resize(const int new_width, const int new_height)
{
    worker_thread.reset(new std::thread([this, new_width, new_height]()
    {
        QString processing_img_path;
        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            worker_thread_id = std::this_thread::get_id();
            processing_img_path = selected_img_path;
        }

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        dlib::matrix<dlib::rgb_pixel> resized_img(new_height, new_width);
        dlib::resize_image(img, resized_img);

        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                update_processed_img(processing_img_path, resized_img, "resized_");
            }
        }
    }));
    worker_thread->detach();
}

void Image_handler::cancel()
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    worker_thread_id = std::thread::id{};
    rect_around_face = dlib::rectangle{};
    individual_file_manager.delete_temp_files();
}

void Image_handler::extract_face()
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    dlib::matrix<dlib::rgb_pixel> img;

    if(!check_img_existense(selected_img_path)) {
        qDebug() << selected_img_path << " NOT EXISTS!";
        return;
    }
    load_processing_image(img, selected_img_path, "resized_");

    auto face_shape = shape_predictor(img, rect_around_face);
    dlib::matrix<dlib::rgb_pixel> processed_face;
    dlib::extract_image_chip(img, dlib::get_face_chip_details(face_shape, 150, 0.25), processed_face);
    update_processed_img(selected_img_path, processed_face, "extracted_face_");
}
