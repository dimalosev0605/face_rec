#include "face_recognition_image_handler.h"

Face_recognition_image_handler::Face_recognition_image_handler(QObject* parent)
    : Base_image_handler(parent)
{

}


void Face_recognition_image_handler::hog()
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

        auto hog_face_detector = dlib::get_frontal_face_detector();
        const auto rects_around_faces = hog_face_detector(img);
        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
        }

        update_processed_img(processing_img_path, img, "faces_");
        if(rects_around_faces.empty()) {
            qDebug() << "We did not find faces.";
        }
        else  {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                faces = std::move(rects_around_faces);
            }
        }

    }));
    worker_thread->detach();
}

void Face_recognition_image_handler::cnn()
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

        const auto rects_around_faces = cnn_face_detector(img);
        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{0, 255, 0}, 2);
        }

        update_processed_img(processing_img_path, img, "faces_");
        if(rects_around_faces.empty()) {
            qDebug() << "We did not find faces.";
        }
        else {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                for(const auto& rect_around_face : rects_around_faces) {
                    faces.push_back(rect_around_face.rect);
                }
            }
        }

    }));
    worker_thread->detach();
}

void Face_recognition_image_handler::cancel()
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    worker_thread_id = std::thread::id{};
    faces.clear();
    individual_file_manager.delete_temp_files();
}

void Face_recognition_image_handler::set_threshold(const double new_threshold)
{
    threshold = new_threshold;
}
