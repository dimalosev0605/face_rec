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

void Image_handler::update_path(const QString& new_path)
{
    std::lock_guard<std::mutex> lock(selected_img_mutex);
    selected_img_path = new_path;
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

void Image_handler::load_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix, const QString& path)
{
    // try load pyramided image. If it is not exists -> load original image.
    const auto pyramided_img_path = individual_file_manager.get_path_to_temp_files_dir(prefix, QUrl(path).fileName());
    QFile pyramided_img;
    if(pyramided_img.exists(pyramided_img_path)) {
        dlib::load_image(img, pyramided_img_path.toStdString());
    }
    else {
        dlib::load_image(img, path.toStdString());
    }
}

QString Image_handler::save_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix, const QString& path)
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

QString Image_handler::copy_processing_img_path()
{
    std::lock_guard<std::mutex> lock(selected_img_mutex);
    return QString(selected_img_path.remove("file://"));
}

void Image_handler::hog()
{
    // Когда юзверь нажимает hog, то надо блочить кнопки для обработки изображений.
    // кнопку exract_face перенесьт под processed_image
    // юзер нажимает кнопки обработки, я блочу UI и запускаю анимацию.
    // добавить конопку hog + cnn.

    worker_thread.reset(new std::thread([this]()
    {
        const auto processing_img_path = copy_processing_img_path();

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        // сперва ищем в temp_dir файл, который был pyr_up или pyr_down
        // если его нет - ищу лицо на оригинале.

        dlib::matrix<dlib::rgb_pixel> img;
        load_image(img, "pyr_", processing_img_path);

        auto hog_face_detector = dlib::get_frontal_face_detector();
        const auto rects_around_faces = hog_face_detector(img);

        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
        }

        update_processed_img(processing_img_path, img, "hog_");
    }));
    worker_thread->detach();
}

void Image_handler::update_processed_img(const QString& processing_img_path, dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix)
{
    std::lock_guard<std::mutex> lock(selected_img_mutex);
    if(selected_img_path == processing_img_path) {
        const auto path = save_image(img, prefix, processing_img_path);
        qDebug() << "processed img saved, path = " << path;
        if(!path.isEmpty()) {
            emit img_source_changed("file://" + path);
        }
    }
    else {
        qDebug() << "NOT EQUAL!";
    }
}

void Image_handler::cnn()
{
    worker_thread.reset(new std::thread([this]()
    {
        const auto processing_img_path = copy_processing_img_path();

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_image(img, "pyr_", processing_img_path);

        const auto rects_around_faces = cnn_face_detector(img);
        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{0, 255, 0}, 2);
        }

        update_processed_img(processing_img_path, img, "cnn_");
    }));
    worker_thread->detach();
}

void Image_handler::pyr_up()
{
    worker_thread.reset(new std::thread([this]()
    {
        const auto processing_img_path = copy_processing_img_path();

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_image(img, "pyr_", processing_img_path);

        dlib::pyramid_up(img);

        update_processed_img(processing_img_path, img, "pyr_");
    }));
    worker_thread->detach();
}

void Image_handler::pyr_down()
{
    worker_thread.reset(new std::thread([this]()
    {
        const auto processing_img_path = copy_processing_img_path();

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_image(img, "pyr_", processing_img_path);

        dlib::pyramid_down<2> pyr;
        pyr(img);

        update_processed_img(processing_img_path, img, "pyr_");
    }));
    worker_thread->detach();
}

void Image_handler::delete_temp_files()
{
    individual_file_manager.delete_temp_files();
}
