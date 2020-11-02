#include "image_handlers/face_recognition_image_handler.h"

Face_recognition_image_handler::Face_recognition_image_handler(QObject* parent)
    : Base_image_handler(parent)
{
    auto load_models_lambda = [](
            std::shared_ptr<net_type> cnn_face_det_sp,
            std::shared_ptr<dlib::shape_predictor> shape_predictor_sp,
            std::shared_ptr<anet_type> anet_sp
            )
    {
        auto local_cnn_face_det_sp = cnn_face_det_sp;
        auto local_shape_predictor_sp = shape_predictor_sp;
        auto local_anet_sp = anet_sp;

        dlib::deserialize("mmod_human_face_detector.dat") >> (*cnn_face_det_sp.get());
        dlib::deserialize("shape_predictor_5_face_landmarks.dat") >> (*shape_predictor_sp.get());
        dlib::deserialize("dlib_face_recognition_resnet_model_v1.dat") >> (*anet_sp.get());
    };

    initializer_thread = std::thread(load_models_lambda, cnn_face_detector, shape_predictor, anet);
}


void Face_recognition_image_handler::hog()
{
    worker_thread.reset(new std::thread([this]()
    {
        const auto processing_img_path = copy_selected_img_path();
        set_worker_thread_id();
        clear_data_structures();

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        auto hog_face_detector = dlib::get_frontal_face_detector();
        const auto rects_around_faces = hog_face_detector(img);

        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                for(const auto& rect : rects_around_faces) {
                    auto face_shape = shape_predictor->operator()(img, rect);
                    dlib::matrix<dlib::rgb_pixel> processed_face;
                    dlib::extract_image_chip(img, dlib::get_face_chip_details(face_shape, 150, 0.25), processed_face);
                    detected_processed_faces.push_back(std::move(processed_face));
                    dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
                }
            }
        }

        if(rects_around_faces.empty()) {
            qDebug() << "We did not find faces.";
        }
        else {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                faces = rects_around_faces;
                detected_face_descriptors = anet->operator()(detected_processed_faces);
            }
        }
        update_processed_img(processing_img_path, img, "faces_");

    }));
    worker_thread->detach();
}

void Face_recognition_image_handler::cnn()
{
    worker_thread.reset(new std::thread([this]()
    {
        const auto processing_img_path = copy_selected_img_path();
        set_worker_thread_id();
        clear_data_structures();

        if(!check_img_existense(processing_img_path)) {
            qDebug() << processing_img_path << " NOT EXISTS!";
            return;
        }

        dlib::matrix<dlib::rgb_pixel> img;
        load_processing_image(img, processing_img_path, "resized_");

        std::vector<dlib::mmod_rect> rects_around_faces;
        {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                rects_around_faces = cnn_face_detector->operator()(img);
                for(const auto& rect : rects_around_faces) {
                    auto face_shape = shape_predictor->operator()(img, rect.rect);
                    dlib::matrix<dlib::rgb_pixel> processed_face;
                    dlib::extract_image_chip(img, dlib::get_face_chip_details(face_shape, 150, 0.25), processed_face);
                    detected_processed_faces.push_back(std::move(processed_face));
                    dlib::draw_rectangle(img, rect, dlib::rgb_pixel{255, 0, 0}, 2);
                }
            }
        }

        if(rects_around_faces.empty()) {
            qDebug() << "We did not find faces.";
        }
        else {
            std::lock_guard<std::mutex> lock(worker_thread_mutex);
            if(worker_thread_id == std::this_thread::get_id()) {
                for(const auto& rect_around_face : rects_around_faces) {
                    faces.push_back(rect_around_face.rect);
                }
                detected_face_descriptors = anet->operator()(detected_processed_faces);
            }
        }
        update_processed_img(processing_img_path, img, "faces_");

    }));
    worker_thread->detach();
}

void Face_recognition_image_handler::cancel()
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    worker_thread_id = std::thread::id{};
    faces.clear();
    detected_processed_faces.clear();
    detected_face_descriptors.clear();
    individual_file_manager.delete_temp_files();
}

void Face_recognition_image_handler::set_threshold(const double new_threshold)
{
    std::lock_guard<std::mutex> lock(worker_thread_mutex);
    threshold = new_threshold;
}

void Face_recognition_image_handler::accept_people_for_recognition(const QVector<QString>& people_list)
{
    auto known_people_list = std::make_shared<QVector<QString>>(people_list);

    auto fill_known_people_lambda = [](
            std::shared_ptr<QVector<QString>> known_people_list_sp,
            std::shared_ptr<std::map<dlib::matrix<float, 0, 1>, std::string>> known_people_sp,
            std::shared_ptr<anet_type> anet_sp)
    {
        auto local_known_people_list_sp = known_people_list_sp;
        auto local_known_people_sp = known_people_sp;
        auto local_anet_sp = anet_sp;

        std::vector<dlib::matrix<dlib::rgb_pixel>> imgs;
        std::vector<std::string> names;

        Individual_file_manager individual_file_manager;

        for(int i = 0; i < local_known_people_list_sp->size(); ++i) {
            individual_file_manager.set_name(local_known_people_list_sp->operator[](i));

            const auto extr_faces_dir_path = individual_file_manager.get_path_to_extracted_faces_dir();
            dlib::directory extr_faces_dir(extr_faces_dir_path.toStdString());

            auto files = extr_faces_dir.get_files();
            for(const auto& file: files) {
                dlib::matrix<dlib::rgb_pixel> img;
                dlib::load_image(img, file.full_name());
                imgs.push_back(std::move(img));
                names.push_back(local_known_people_list_sp->operator[](i).toStdString());
                qDebug() << "Loaded: "
                         << QString(file.full_name().c_str())
                         << local_known_people_list_sp->operator[](i);
            }

        }

        if(imgs.size() != names.size()) {
            qDebug() << "Error.";
            return;
        }

        std::vector<dlib::matrix<float, 0, 1>> face_descriptors = local_anet_sp->operator()(imgs);
        for(std::size_t i = 0; i < names.size(); ++i) {
            local_known_people_sp->operator[](face_descriptors[i]) = names[i];
        }
        qDebug() << "fill_known_people_map() finised.";
    };
    std::thread fill_known_people_map_thread = std::thread(fill_known_people_lambda, known_people_list, known_people, anet);
    fill_known_people_map_thread.detach();
}

void Face_recognition_image_handler::clear_data_structures()
{
    if(worker_thread_id == std::this_thread::get_id()) {
        std::lock_guard<std::mutex> lock(worker_thread_mutex);
        faces.clear();
        detected_processed_faces.clear();
        detected_face_descriptors.clear();
    }
}

void Face_recognition_image_handler::recognize()
{    
    std::lock_guard<std::mutex> lock(worker_thread_mutex);

    Individual_file_manager individual_file_manager;
    const auto img_path = individual_file_manager.get_path_to_temp_file("faces_", QUrl(selected_img_path).fileName());
    dlib::matrix<dlib::rgb_pixel> dlib_img;
    dlib::load_image(dlib_img, img_path.toStdString());
    cv::Mat img = dlib::toMat(dlib_img);
    if(img.empty()) {
        qDebug() << "imread error.";
        return;
    }

    std::vector<bool> is_known(faces.size(), false);

    for(std::size_t j = 0; j < detected_face_descriptors.size(); ++j) {

        float min_diff = 1000.0f;
        std::string min_diff_name;

        for(const auto& entry : (*known_people.get())) {
            const auto diff = dlib::length(detected_face_descriptors[j] - entry.first);
            if(diff < threshold) {
                if(diff < min_diff) {
                    min_diff = diff;
                    min_diff_name = entry.second;
                }
                is_known[j] = true;
            }
        }

        if(is_known[j]) {
            cv::rectangle(img, cv::Point(faces[j].tl_corner().x(), faces[j].tl_corner().y()),
                               cv::Point(faces[j].br_corner().x(), faces[j].br_corner().y()),
                               cv::Scalar(0, 255, 0), 2);
            cv::putText(img, min_diff_name, cv::Point(faces[j].tl_corner().x(), faces[j].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(0, 255, 0), 2);
        }

    }

    for(std::size_t k = 0; k < is_known.size(); ++k) {
        if(!is_known[k]) {
            cv::putText(img, "unknown", cv::Point(faces[k].tl_corner().x(), faces[k].tl_corner().y()), cv::FONT_HERSHEY_DUPLEX, 0.70, cv::Scalar(255, 0, 0), 2);
        }
    }

    QImage q_img(img.data, img.cols, img.rows, img.step, QImage::Format_RGB888);
    const QString recognized_img_path = individual_file_manager.get_path_to_temp_file("recognized_", QUrl(selected_img_path).fileName());
    if(q_img.save(recognized_img_path)) {
        emit recognition_finished("file://" + recognized_img_path);
    }
}
