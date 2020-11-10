#include "image_handlers/face_recognition_image_handler.h"

Face_recognition_image_handler::Face_recognition_image_handler(QObject* parent)
    : Base_image_handler(parent)
{
}

void Face_recognition_image_handler::set_selected_people_list(const QVector<QString>& list)
{
    selected_peoplet_list = std::make_shared<QVector<QString>>(list);
    qDebug() << "In set:";
    for(const auto& elem : *selected_peoplet_list.get()) {
        qDebug() << elem;
    }

    auto fill_known_people_lambda = [this](
            std::shared_ptr<QVector<QString>> known_people_list_sp,
            std::shared_ptr<std::map<dlib::matrix<float, 0, 1>, std::string>> known_people_sp,
            std::shared_ptr<anet_type> anet_sp)
    {
        dlib::deserialize("dlib_face_recognition_resnet_model_v1.dat") >> (*anet_sp.get());

        std::vector<dlib::matrix<dlib::rgb_pixel>> imgs;
        std::vector<std::string> names;

        Individual_file_manager individual_file_manager;

        for(int i = 0; i < known_people_list_sp->size(); ++i) {
            individual_file_manager.set_name(known_people_list_sp->operator[](i));

            const auto extr_faces_dir_path = individual_file_manager.get_path_to_extracted_faces_dir();
            dlib::directory extr_faces_dir(extr_faces_dir_path.toStdString());

            auto files = extr_faces_dir.get_files();
            for(const auto& file: files) {
                dlib::matrix<dlib::rgb_pixel> img;
                dlib::load_image(img, file.full_name());
                imgs.push_back(std::move(img));
                names.push_back(known_people_list_sp->operator[](i).toStdString());
                qDebug() << "Loaded: "
                         << QString(file.full_name().c_str())
                         << known_people_list_sp->operator[](i);
            }

        }

        if(imgs.size() != names.size()) {
            qDebug() << "Error.";
            return;
        }

        std::vector<dlib::matrix<float, 0, 1>> face_descriptors = anet_sp->operator()(imgs);
        for(std::size_t i = 0; i < names.size(); ++i) {
            known_people_sp->operator[](face_descriptors[i]) = names[i];
        }
        qDebug() << "fill_known_people_map() finised.";
        emit enable_btns();
    };

    // I don't use selected people list => I can move it.
    std::thread fill_known_people_thread = std::thread(fill_known_people_lambda, std::move(selected_peoplet_list), known_people, anet);
    fill_known_people_thread.detach();
}

void Face_recognition_image_handler::hog()
{
    auto lambda = [this](std::shared_ptr<Shared_data> shared_data_sp, std::shared_ptr<Detected_faces_stuff> detected_faces_stuff_sp, std::shared_ptr<std::mutex> detected_faces_stuff_mtx_sp)
    {
        set_worker_thread_id(shared_data_sp);
        const auto processing_img_path = copy_selected_img_path(shared_data_sp);
        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }
        clear_detected_faces_stuff(shared_data_sp, detected_faces_stuff_sp, detected_faces_stuff_mtx_sp);

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(shared_data_sp, img, processing_img_path, "resized_");

        std::vector<dlib::rectangle> rects_around_faces;
        if(shared_data_sp->hog_face_detector_mtx.try_lock()) {
            rects_around_faces = shared_data_sp->hog_face_detector.operator()(img);
            shared_data_sp->hog_face_detector_mtx.unlock();
        }
        else {
            auto thread_local_hog_face_detector = dlib::get_frontal_face_detector();
            rects_around_faces = thread_local_hog_face_detector(img);
        }

        {
            std::lock_guard<std::mutex> worker_thread_id_lock(shared_data_sp->worker_thread_id_mtx);
            if(shared_data_sp->worker_thread_id == std::this_thread::get_id()) {
                std::lock(shared_data_sp->shape_predictor_mtx, *detected_faces_stuff_mtx_sp);
                std::lock_guard<std::mutex> face_shape_lock(shared_data_sp->shape_predictor_mtx, std::adopt_lock);
                std::lock_guard<std::mutex> detected_face_stuff_lock(*detected_faces_stuff_mtx_sp, std::adopt_lock);
                for(const auto& rect: rects_around_faces) {
                    auto face_shape = shared_data_sp->shape_predictor.operator()(img, rect);
                    dlib::matrix<dlib::rgb_pixel> processed_face;
                    dlib::extract_image_chip(img, dlib::get_face_chip_details(face_shape, 150, 0.25), processed_face);
                    detected_faces_stuff_sp->detected_processed_faces.push_back(std::move(processed_face));
                    dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
                }
            }
        }

        update_processed_img(shared_data_sp, processing_img_path, img, "faces_");
        if(rects_around_faces.empty()) {
            qDebug() << "We did not find faces.";
        }
        else {
            std::lock_guard<std::mutex> lock(shared_data_sp->worker_thread_id_mtx);
            if(shared_data_sp->worker_thread_id == std::this_thread::get_id()) {
                std::lock_guard<std::mutex> another_lock(*detected_faces_stuff_mtx_sp);
                detected_faces_stuff_sp->faces = rects_around_faces;
                detected_faces_stuff_sp->detected_face_descriptors = anet->operator()(detected_faces_stuff_sp->detected_processed_faces);
            }
        }
    };
    worker_thread.reset(new std::thread(lambda, shared_data, detected_faces_stuff, detected_faces_stuff_mtx));
    worker_thread->detach();
}

void Face_recognition_image_handler::cnn()
{

    auto lambda = [this](std::shared_ptr<Shared_data> shared_data_sp, std::shared_ptr<Detected_faces_stuff> detected_faces_stuff_sp, std::shared_ptr<std::mutex> detected_faces_stuff_mtx_sp)
    {
        set_worker_thread_id(shared_data_sp);
        const auto processing_img_path = copy_selected_img_path(shared_data_sp);
        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }
        clear_detected_faces_stuff(shared_data_sp, detected_faces_stuff_sp, detected_faces_stuff_mtx_sp);

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

        {
            std::lock_guard<std::mutex> worker_thread_id_lock(shared_data_sp->worker_thread_id_mtx);
            if(shared_data_sp->worker_thread_id == std::this_thread::get_id()) {
                std::lock(shared_data_sp->shape_predictor_mtx, *detected_faces_stuff_mtx_sp);
                std::lock_guard<std::mutex> face_shape_lock(shared_data_sp->shape_predictor_mtx, std::adopt_lock);
                std::lock_guard<std::mutex> detected_face_stuff_lock(*detected_faces_stuff_mtx_sp, std::adopt_lock);
                for(const auto& rect: rects_around_faces) {
                    auto face_shape = shared_data_sp->shape_predictor.operator()(img, rect);
                    dlib::matrix<dlib::rgb_pixel> processed_face;
                    dlib::extract_image_chip(img, dlib::get_face_chip_details(face_shape, 150, 0.25), processed_face);
                    detected_faces_stuff_sp->detected_processed_faces.push_back(std::move(processed_face));
                    dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
                }
            }
        }

        update_processed_img(shared_data_sp, processing_img_path, img, "faces_");
        if(rects_around_faces.empty()) {
            qDebug() << "We did not find faces.";
        }
        else {
            std::lock_guard<std::mutex> lock(shared_data_sp->worker_thread_id_mtx);
            if(shared_data_sp->worker_thread_id == std::this_thread::get_id()) {
                std::lock_guard<std::mutex> another_lock(*detected_faces_stuff_mtx_sp);
                for(const auto& rect_around_face : rects_around_faces) {
                    detected_faces_stuff_sp->faces.push_back(rect_around_face.rect);
                }
                detected_faces_stuff_sp->detected_face_descriptors = anet->operator()(detected_faces_stuff_sp->detected_processed_faces);
            }
        }

    };
    worker_thread.reset(new std::thread(lambda, shared_data, detected_faces_stuff, detected_faces_stuff_mtx));
    worker_thread->detach();
}

void Face_recognition_image_handler::cancel()
{
    std::lock(shared_data->worker_thread_id_mtx, *detected_faces_stuff_mtx);
    std::lock_guard<std::mutex> lock(shared_data->worker_thread_id_mtx, std::adopt_lock);
    std::lock_guard<std::mutex> another_lock(*detected_faces_stuff_mtx, std::adopt_lock);
    shared_data->worker_thread_id = std::thread::id{};
    detected_faces_stuff->faces.clear();
    detected_faces_stuff->detected_processed_faces.clear();
    detected_faces_stuff->detected_face_descriptors.clear();
    shared_data->individual_file_manager.delete_temp_files();
}

void Face_recognition_image_handler::set_threshold(const double new_threshold)
{
    std::lock_guard<std::mutex> lock(*threshold_mtx);
    *threshold = new_threshold;
}

void Face_recognition_image_handler::clear_detected_faces_stuff(std::shared_ptr<Shared_data> shared_data_sp, std::shared_ptr<Detected_faces_stuff> detected_faces_stuff_sp, std::shared_ptr<std::mutex> detected_faces_stuff_mtx_sp)
{
    std::lock_guard<std::mutex> lock(shared_data_sp->worker_thread_id_mtx);
    if(shared_data_sp->worker_thread_id == std::this_thread::get_id()) {
        std::lock_guard<std::mutex> another_lock(*detected_faces_stuff_mtx_sp);
        detected_faces_stuff_sp->faces.clear();
        detected_faces_stuff_sp->detected_processed_faces.clear();
        detected_faces_stuff_sp->detected_face_descriptors.clear();
    }
}

void Face_recognition_image_handler::recognize()
{
    auto lambda = [this](std::shared_ptr<Shared_data> shared_data_sp, std::shared_ptr<Detected_faces_stuff> detected_faces_stuff_sp, std::shared_ptr<std::mutex> detected_faces_stuff_mtx_sp,
            std::shared_ptr<std::map<dlib::matrix<float, 0, 1>, std::string>> known_people_sp, std::shared_ptr<double> threshold_sp, std::shared_ptr<std::mutex> threshold_mtx_sp)
    {
        set_worker_thread_id(shared_data_sp);
        QString img_path;
        Individual_file_manager individual_file_manager;
        {
            std::lock_guard<std::mutex> lock(shared_data_sp->selected_img_path_mtx);
            img_path = individual_file_manager.get_path_to_temp_file("faces_", QUrl(shared_data_sp->selected_img_path).fileName());
        }
        dlib::matrix<dlib::rgb_pixel> dlib_img;
        dlib::load_image(dlib_img, img_path.toStdString());
        cv::Mat img = dlib::toMat(dlib_img);
        if(img.empty()) {
            qDebug() << "imread error.";
            return;
        }

        {
            std::lock_guard<std::mutex> detected_faces_stuff_lock(*detected_faces_stuff_mtx_sp);
            std::vector<bool> is_known(detected_faces_stuff_sp->faces.size(), false);

            for(std::size_t j = 0; j < detected_faces_stuff_sp->detected_face_descriptors.size(); ++j) {

                float min_diff = 1000.0f;
                std::string min_diff_name;

                for(const auto& entry : *known_people_sp) {
                    const auto diff = dlib::length(detected_faces_stuff_sp->detected_face_descriptors[j] - entry.first);
                    std::lock_guard<std::mutex> threshold_lock(*threshold_mtx_sp);
                    if(diff < *threshold_sp) {
                        if(diff < min_diff) {
                            min_diff = diff;
                            min_diff_name = entry.second;
                        }
                        is_known[j] = true;
                    }
                }

                if(is_known[j]) {
                    cv::rectangle(img, cv::Point(detected_faces_stuff_sp->faces[j].tl_corner().x(), detected_faces_stuff_sp->faces[j].tl_corner().y()),
                                       cv::Point(detected_faces_stuff_sp->faces[j].br_corner().x(), detected_faces_stuff_sp->faces[j].br_corner().y()),
                                       cv::Scalar(0, 255, 0), 2);
                    cv::putText(img, min_diff_name, cv::Point(detected_faces_stuff_sp->faces[j].tl_corner().x(), detected_faces_stuff_sp->faces[j].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(0, 255, 0), 2);
                }

            }

            for(std::size_t k = 0; k < is_known.size(); ++k) {
                if(!is_known[k]) {
                    cv::putText(img, "unknown", cv::Point(detected_faces_stuff_sp->faces[k].tl_corner().x(), detected_faces_stuff_sp->faces[k].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(255, 0, 0), 2);
                }
            }
        }

        std::lock_guard<std::mutex> worker_thread_id_lock(shared_data_sp->worker_thread_id_mtx);
        if(shared_data_sp->worker_thread_id != std::this_thread::get_id()) {
            return;
        }
        std::lock_guard<std::mutex> selected_img_path_lock(shared_data_sp->selected_img_path_mtx);
        QImage q_img(img.data, img.cols, img.rows, img.step, QImage::Format_RGB888);
        const QString recognized_img_path = individual_file_manager.get_path_to_temp_file("recognized_", QUrl(shared_data_sp->selected_img_path).fileName());
        if(q_img.save(recognized_img_path)) {
            emit recognition_finished("file://" + recognized_img_path);
        }
    };
    worker_thread.reset(new std::thread(lambda, shared_data, detected_faces_stuff, detected_faces_stuff_mtx, known_people, threshold, threshold_mtx));
    worker_thread->detach();
}
