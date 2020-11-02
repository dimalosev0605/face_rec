#include "image_handlers/add_new_face_image_handler.h"

Add_new_face_image_handler::Add_new_face_image_handler(QObject* parent)
    : Base_image_handler(parent)
{
    auto initializer_thread_lambda = [](std::shared_ptr<net_type> cnn_face_det_sp, std::shared_ptr<dlib::shape_predictor> shape_predictor_sp,
                                        std::shared_ptr<hog_face_detector_type> hog_face_detector_sp)
    {
        auto local_cnn_face_det_sp = cnn_face_det_sp;
        auto local_shape_predictor_sp = shape_predictor_sp;

        dlib::deserialize("mmod_human_face_detector.dat") >> (*local_cnn_face_det_sp.get());
        dlib::deserialize("shape_predictor_5_face_landmarks.dat") >> (*local_shape_predictor_sp.get());

        *hog_face_detector_sp.get() = dlib::get_frontal_face_detector();
    };
    initializer_thread = std::thread(initializer_thread_lambda, cnn_face_detector, shape_predictor, hog_face_detector);
}

void Add_new_face_image_handler::cnn()
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

        const auto rects_around_faces = cnn_face_detector->operator()(img);
        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{0, 255, 0}, 2);
        }

        update_processed_img(processing_img_path, img, "face_");
        if(rects_around_faces.size() != 1) {
            qDebug() << "We must find exactly one face on the image!";
            return;
        }
        else {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                rect_around_face = rects_around_faces[0];
                emit enable_extract_face_btn();
            }
        }

    }));
    worker_thread->detach();
}

void Add_new_face_image_handler::hog()
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

        std::vector<dlib::rectangle> rects_around_faces;
        if(hog_face_detector_mtx.try_lock()) {
            rects_around_faces = hog_face_detector->operator()(img);
            hog_face_detector_mtx.unlock();
        }
        else {
            auto thread_local_hog_face_detector = dlib::get_frontal_face_detector();
            rects_around_faces = thread_local_hog_face_detector(img);
        }

        for(const auto& rect : rects_around_faces) {
            dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
        }

        update_processed_img(processing_img_path, img, "face_");
        if(rects_around_faces.size() != 1) {
            qDebug() << "We must find exactly one face on the image!";
            return;
        }
        else {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                rect_around_face = rects_around_faces[0];
                emit enable_extract_face_btn();
            }
        }

    }));
    worker_thread->detach();
}

void Add_new_face_image_handler::set_current_individual_name(const QString &name)
{
    individual_file_manager.set_name(name);
}

void Add_new_face_image_handler::extract_face()
{
    // not thread safe.
    dlib::matrix<dlib::rgb_pixel> img;

    if(!check_img_existense(selected_img_path)) {
        qDebug() << selected_img_path << " NOT EXISTS!";
        return;
    }
    load_processing_image(img, selected_img_path, "resized_");

    auto face_shape = shape_predictor->operator()(img, rect_around_face);
    dlib::matrix<dlib::rgb_pixel> processed_face;
    dlib::extract_image_chip(img, dlib::get_face_chip_details(face_shape, 150, 0.25), processed_face);
    worker_thread_id = std::this_thread::get_id();
    update_processed_img(selected_img_path, processed_face, "extracted_face_");
}

void Add_new_face_image_handler::cancel()
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    worker_thread_id = std::thread::id{};
    rect_around_face = dlib::rectangle{};
    individual_file_manager.delete_temp_files();
}
