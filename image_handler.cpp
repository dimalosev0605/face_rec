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
    selected_img_path = new_path;
}

void Image_handler::set_current_individual_name(const QString& name)
{
    individual_file_manager.set_individual_name(name);
}

bool Image_handler::check_file_existense()
{
    QUrl url(selected_img_path);
    QFile check_existense;
    return check_existense.exists(url.toString(QUrl::PreferLocalFile));
}

void Image_handler::load_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix)
{
    // try load pyramided image. If it is not exists -> load original image.
    const auto pyramided_img_path = individual_file_manager.get_path_to_temp_files_dir(prefix, QUrl(selected_img_path).fileName());
    QFile pyramided_img;
    if(pyramided_img.exists(pyramided_img_path)) {
        dlib::load_image(img, pyramided_img_path.toStdString());
    }
    else {
        dlib::load_image(img, selected_img_path.remove("file://").toStdString());
    }
}

QString Image_handler::save_image(dlib::matrix<dlib::rgb_pixel>& img, const QString& prefix)
{
    cv::Mat cv_mat = dlib::toMat(img);
    QImage q_img(cv_mat.data, cv_mat.cols, cv_mat.rows, cv_mat.step, QImage::Format_RGB888);
    const auto q_img_path = individual_file_manager.get_path_to_temp_files_dir(prefix, QUrl(selected_img_path).fileName());
    if(q_img.save(q_img_path)) {
        return q_img_path;
    }
    else {
        return QString{};
    }
}

void Image_handler::hog()
{
    // Когда юзверь нажимает hog, то надо блочить кнопки для обработки изображений.
    // кнопку exract_face перенесьт под processed_image
    // юзер нажимает кнопки обработки, я блочу UI и запускаю анимацию.
    // добавить конопку hog + cnn.

    worker_thread.reset(new std::thread([this]()
    {
        if(!check_file_existense()) {
            qDebug() << selected_img_path << " NOT EXISTS!";
            return;
        }

        // сперва ищем в temp_dir файл, который был pyr_up или pyr_down
        // если его нет - ищу лицо на оригинале.

        dlib::matrix<dlib::rgb_pixel> img;
        load_image(img, "pyr_");

        auto rects_around_faces = hog_face_detector(img);

        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
        }

        const auto path = save_image(img, "hog_");
        if(!path.isEmpty()) {
            emit img_source_changed("file://" + path);
        }
    }));
    worker_thread->detach();
}

void Image_handler::cnn()
{
    worker_thread.reset(new std::thread([this]()
    {
        if(!check_file_existense()) {
            qDebug() << selected_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_image(img, "pyr_");

        auto rects_around_faces = cnn_face_detector(img);

        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{0, 255, 0}, 2);
        }

        const auto path = save_image(img, "cnn_");
        if(!path.isEmpty()) {
            emit img_source_changed("file://" + path);
        }
    }));
    worker_thread->detach();
}

void Image_handler::pyr_up()
{
    worker_thread.reset(new std::thread([this]()
    {
        if(!check_file_existense()) {
            qDebug() << selected_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_image(img, "pyr_");

        dlib::pyramid_up(img);

        const auto path = save_image(img, "pyr_");
        if(!path.isEmpty()) {
            emit img_source_changed("file://" + path);
        }
    }));
    worker_thread->detach();
}

void Image_handler::pyr_down()
{
    worker_thread.reset(new std::thread([this]()
    {
        if(!check_file_existense()) {
            qDebug() << selected_img_path << " NOT EXISTS!";
            return ;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_image(img, "pyr_");

        dlib::pyramid_down<2> pyr;
        pyr(img);

        const auto path = save_image(img, "pyr_");
        if(!path.isEmpty()) {
            emit img_source_changed("file://" + path);
        }
    }));
    worker_thread->detach();
}

void Image_handler::delete_temp_files()
{
    individual_file_manager.delete_temp_files();
}
