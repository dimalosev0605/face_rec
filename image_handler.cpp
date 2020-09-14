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

void Image_handler::hog()
{
//    qDebug() << "MAIN THREAD! id = " << QThread::currentThreadId();
    worker_thread.reset(new std::thread([this]()
    {
//        qDebug() << "in another thread, sleep! id = " << QThread::currentThreadId();
//        std::this_thread::sleep_for(std::chrono::seconds(5));
//        qDebug() << "in another thread, awake! id = " << QThread::currentThreadId();
        dlib::matrix<dlib::rgb_pixel> img;
        dlib::load_image(img, selected_img_path.remove("file://").toStdString());
        qDebug() << "dlib img size = " << img.nc() << " X " << img.nr();

        auto rects_around_faces = hog_face_detector(img);

        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0});
        }

        cv::Mat cv_mat = dlib::toMat(img);
        QImage q_img(cv_mat.data, cv_mat.cols, cv_mat.rows, cv_mat.step, QImage::Format_RGB888);
        q_img.save("/home/dima/Documents/Qt_projects/build-face_rec-Desktop_Qt_5_15_0_GCC_64bit-Debug/people/test.jpg");

    }));
    worker_thread->detach();
}
