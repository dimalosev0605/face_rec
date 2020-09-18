#include "image_handler.h"

Image_handler::Image_handler(QObject* parent)
    : QObject(parent)
{
    qDebug() << this << " Created";
    dlib::deserialize("mmod_human_face_detector.dat") >> cnn_face_detector;
    dlib::deserialize("shape_predictor_5_face_landmarks.dat") >> shape_predictor;
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

void Image_handler::hog()
{
    // Когда юзверь нажимает hog, то надо блочить кнопки для обработки изображений.
    // кнопку exract_face перенесьт под processed_image

    worker_thread.reset(new std::thread([this]()
    {
        if(!check_file_existense()) {
            qDebug() << selected_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        dlib::load_image(img, selected_img_path.remove("file://").toStdString());
        qDebug() << "dlib img size = " << img.nc() << " X " << img.nr();

        auto rects_around_faces = hog_face_detector(img);

        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0});
        }

        cv::Mat cv_mat = dlib::toMat(img);
        QImage q_img(cv_mat.data, cv_mat.cols, cv_mat.rows, cv_mat.step, QImage::Format_RGB888);
        const auto q_img_path = individual_file_manager.get_path_to_temp_files_dir("hog_", QUrl(selected_img_path).fileName());
        q_img.save(q_img_path);
        emit img_source_changed("file://" + q_img_path);
    }));
    worker_thread->detach();
}

void Image_handler::Image_handler::pyr_up()
{
    worker_thread.reset(new std::thread([this]()
    {
        if(!check_file_existense()) {
            qDebug() << selected_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        dlib::load_image(img, selected_img_path.remove("file://").toStdString());
        dlib::pyramid_up(img);

        cv::Mat cv_mat = dlib::toMat(img);
        QImage q_img(cv_mat.data, cv_mat.cols, cv_mat.rows, cv_mat.step, QImage::Format_RGB888);
        const auto q_img_path = individual_file_manager.get_path_to_temp_files_dir("pyr_up_", QUrl(selected_img_path).fileName());
        q_img.save(q_img_path);
        emit img_source_changed("file://" + q_img_path);
    }));
    worker_thread->detach();
}
