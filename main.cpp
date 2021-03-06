#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "other/selected_images_model.h"
#include "other/individual_manager.h"
#include "people_models/available_people_model.h"
#include "people_models/selected_people_model.h"
#include "image_handlers/add_new_face_image_handler.h"
#include "image_handlers/face_recognition_image_handler.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("QtMAI");
    app.setOrganizationDomain("supernovaexplosion.ddns");

    qmlRegisterType<Selected_images_model>("Selected_images_model_qml", 1, 0, "Selected_images_model");
    qmlRegisterType<Individual_manager>("Individual_manager_qml", 1, 0, "Individual_manager");

    qmlRegisterType<Available_people_model>("Available_people_model_qml", 1, 0, "Available_people_model");
    qmlRegisterType<Selected_people_model>("Selected_people_model_qml", 1, 0, "Selected_people_model");

    qmlRegisterType<Add_new_face_image_handler>("Add_new_face_image_handler_qml", 1, 0, "Add_new_face_image_handler");
    qmlRegisterType<Face_recognition_image_handler>("Face_recognition_image_handler_qml", 1, 0, "Face_recognition_image_handler");

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/qml/main/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
