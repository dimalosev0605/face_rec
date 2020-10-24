#include "image_handlers/face_recognition_image_handler.h"

Face_recognition_image_handler::Face_recognition_image_handler(QObject* parent)
    : Base_image_handler(parent)
{
    std::thread load_model_thread([this]()
    {
        dlib::deserialize("dlib_face_recognition_resnet_model_v1.dat") >> anet;
        qDebug() << "Deserialization finised.";
    });
    load_model_thread.detach();
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
                    auto face_shape = shape_predictor(img, rect);
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
                detected_face_descriptors = anet(detected_processed_faces);
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
                rects_around_faces = cnn_face_detector(img);
                for(const auto& rect : rects_around_faces) {
                    auto face_shape = shape_predictor(img, rect.rect);
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
                detected_face_descriptors = anet(detected_processed_faces);
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
    known_people_names = people_list;
    std::thread th(&Face_recognition_image_handler::fill_known_people_map, this);
    th.detach();
}

void Face_recognition_image_handler::fill_known_people_map()
{
    std::vector<dlib::matrix<dlib::rgb_pixel>> imgs;
    std::vector<std::string> names;

    Individual_file_manager individual_file_manager;

    for(int i = 0; i < known_people_names.size(); ++i) {
        individual_file_manager.set_name(known_people_names[i]);

        const auto extr_faces_dir_path = individual_file_manager.get_path_to_extracted_faces_dir();
        dlib::directory extr_faces_dir(extr_faces_dir_path.toStdString());

        auto files = extr_faces_dir.get_files();
        for(const auto& file: files) {
            dlib::matrix<dlib::rgb_pixel> img;
            dlib::load_image(img, file.full_name());
            imgs.push_back(std::move(img));
            names.push_back(known_people_names[i].toStdString());
            qDebug() << "Loaded: "
                     << QString(file.full_name().c_str())
                     << known_people_names[i];
        }

    }

    if(imgs.size() != names.size()) {
        qDebug() << "Error.";
        return;
    }

    std::vector<dlib::matrix<float, 0, 1>> face_descriptors = anet(imgs);
    for(std::size_t i = 0; i < names.size(); ++i) {
        known_people[face_descriptors[i]] = names[i];
    }
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

        for(const auto& entry : known_people) {
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
