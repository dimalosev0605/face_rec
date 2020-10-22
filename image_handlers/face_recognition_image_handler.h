#ifndef FACE_RECOGNITION_IMAGE_HANDLER_H
#define FACE_RECOGNITION_IMAGE_HANDLER_H

#include "base_image_handler.h"


template <template <int,template<typename>class,int,typename> class block, int N, template<typename>class BN, typename SUBNET>
using residual = dlib::add_prev1<block<N,BN,1,dlib::tag1<SUBNET>>>;

template <template <int,template<typename>class,int,typename> class block, int N, template<typename>class BN, typename SUBNET>
using residual_down = dlib::add_prev2<dlib::avg_pool<2,2,2,2,dlib::skip1<dlib::tag2<block<N,BN,2,dlib::tag1<SUBNET>>>>>>;

template <int N, template <typename> class BN, int stride, typename SUBNET>
using block  = BN<dlib::con<N,3,3,1,1,dlib::relu<BN<dlib::con<N,3,3,stride,stride,SUBNET>>>>>;

template <int N, typename SUBNET> using ares      = dlib::relu<residual<block,N,dlib::affine,SUBNET>>;
template <int N, typename SUBNET> using ares_down = dlib::relu<residual_down<block,N,dlib::affine,SUBNET>>;

template <typename SUBNET> using alevel0 = ares_down<256,SUBNET>;
template <typename SUBNET> using alevel1 = ares<256,ares<256,ares_down<256,SUBNET>>>;
template <typename SUBNET> using alevel2 = ares<128,ares<128,ares_down<128,SUBNET>>>;
template <typename SUBNET> using alevel3 = ares<64,ares<64,ares<64,ares_down<64,SUBNET>>>>;
template <typename SUBNET> using alevel4 = ares<32,ares<32,ares<32,SUBNET>>>;

using anet_type = dlib::loss_metric<dlib::fc_no_bias<128,dlib::avg_pool_everything<
                            alevel0<
                            alevel1<
                            alevel2<
                            alevel3<
                            alevel4<
                            dlib::max_pool<3,3,2,2,dlib::relu<dlib::affine<dlib::con<32,7,7,2,2,
                            dlib::input_rgb_image_sized<150>
                            >>>>>>>>>>>>;

class Face_recognition_image_handler: public Base_image_handler
{
    Q_OBJECT

    double threshold = 0.5;
    QVector<QString> known_people_names;
    anet_type anet;
    std::map<dlib::matrix<float, 0, 1>, std::string> known_people;

    std::vector<dlib::rectangle> faces;
    std::vector<dlib::matrix<dlib::rgb_pixel>> detected_processed_faces;
    std::vector<dlib::matrix<float, 0, 1>> detected_face_descriptors;

private:
    void fill_known_people_map();

public:
    explicit Face_recognition_image_handler(QObject* parent = nullptr);

public slots:
    void hog();
    void cnn();
    void cancel();

    void set_threshold(const double new_threshold);
    void accept_people_for_recognition(const QVector<QString>& people_list);

    void recognize();

signals:
    void recognition_finished(const QString& processed_img_path);
};

#endif // FACE_RECOGNITION_IMAGE_HANDLER_H
