#include "image_handlers/add_new_face_image_handler.h"

Add_new_face_image_handler::Add_new_face_image_handler(QObject* parent)
    : Base_image_handler(parent)
{
}

void Add_new_face_image_handler::cnn()
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

        std::vector<dlib::mmod_rect> rects_around_faces;
        if(shared_data_sp->cnn_face_detector_mtx.try_lock()) {
            rects_around_faces = shared_data_sp->cnn_face_detector.operator()(img);
            shared_data_sp->cnn_face_detector_mtx.unlock();
        }
        else {
            cnn_face_detector_type thread_local_cnn_face_detector;
            dlib::deserialize("mmod_human_face_detector.dat") >> (thread_local_cnn_face_detector);
            rects_around_faces = thread_local_cnn_face_detector.operator()(img);
        }

        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
        }

        update_processed_img(shared_data_sp, processing_img_path, img, "face_");
        if(rects_around_faces.size() != 1) {
            qDebug() << "We must find exactly one face on the image!";
            return;
        }
        else {
            std::lock_guard<std::mutex> lock(shared_data_sp->worker_thread_id_mtx);
            if(shared_data_sp->worker_thread_id == std::this_thread::get_id()) {
                {
                    std::lock_guard<std::mutex> another_lock(*rect_around_face_mtx);
                    *rect_around_face = rects_around_faces[0];
                }
                emit enable_extract_face_btn();
            }
        }
    };
    worker_thread.reset(new std::thread(lambda, shared_data));
    worker_thread->detach();
}

void Add_new_face_image_handler::hog()
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

        std::vector<dlib::rectangle> rects_around_faces;
        if(shared_data_sp->hog_face_detector_mtx.try_lock()) {
            rects_around_faces = shared_data_sp->hog_face_detector.operator()(img);
            shared_data_sp->hog_face_detector_mtx.unlock();
        }
        else {
            qDebug() << "temp HOG created!";
            auto thread_local_hog_face_detector = dlib::get_frontal_face_detector();
            rects_around_faces = thread_local_hog_face_detector(img);
        }

        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
        }

        update_processed_img(shared_data_sp, processing_img_path, img, "face_");
        if(rects_around_faces.size() != 1) {
            qDebug() << "We must find exactly one face on the image!";
            return;
        }
        else {
            std::lock_guard<std::mutex> lock(shared_data_sp->worker_thread_id_mtx);
            if(shared_data_sp->worker_thread_id == std::this_thread::get_id()) {
                {
                    std::lock_guard<std::mutex> another_lock(*rect_around_face_mtx);
                    *rect_around_face = rects_around_faces[0];
                }
                emit enable_extract_face_btn();
            }
        }
    };
    worker_thread.reset(new std::thread(lambda, shared_data));
    worker_thread->detach();
}

void Add_new_face_image_handler::set_current_individual_name(const QString& name)
{
    shared_data->individual_file_manager.set_name(name);
}

void Add_new_face_image_handler::extract_face()
{
    dlib::matrix<dlib::rgb_pixel> img;

    QString thread_local_selected_img_path;
    {
        std::lock_guard<std::mutex> lock(shared_data->selected_img_path_mtx);
        thread_local_selected_img_path = shared_data->selected_img_path;
    }

    if(!check_img_existense(thread_local_selected_img_path)) {
        qDebug() << thread_local_selected_img_path << " NOT EXISTS!";
        return;
    }

    load_processing_image(shared_data, img, thread_local_selected_img_path, "resized_");

    dlib::full_object_detection face_shape;
    {
        std::lock_guard<std::mutex> lock(*rect_around_face_mtx);
        face_shape = shared_data->shape_predictor.operator()(img, *rect_around_face);
    }

    dlib::matrix<dlib::rgb_pixel> processed_face;
    dlib::extract_image_chip(img, dlib::get_face_chip_details(face_shape, 150, 0.25), processed_face);
    {
        std::lock_guard<std::mutex> lock(shared_data->worker_thread_id_mtx);
        shared_data->worker_thread_id = std::this_thread::get_id();
    }

    update_processed_img(shared_data, thread_local_selected_img_path, processed_face, "extracted_face_");
}

void Add_new_face_image_handler::cancel()
{
    std::lock_guard<std::mutex> lock(shared_data->worker_thread_id_mtx);
    shared_data->worker_thread_id = std::thread::id{};
    {
        std::lock_guard<std::mutex> another_lock(*rect_around_face_mtx);
        *rect_around_face = dlib::rectangle{};
    }
    shared_data->individual_file_manager.delete_temp_files();
}
