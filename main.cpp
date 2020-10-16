#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "selected_images_model.h"
#include "image_handler.h"
#include "individual_manager.h"
#include "people_manager.h"
#include "selected_people_model.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);
    app.setOrganizationName("QtMAI");
    app.setOrganizationDomain("supernovaexplosion.ddns");

    qmlRegisterType<Selected_images_model>("Selected_images_model_qml", 1, 0, "Selected_images_model");
    qmlRegisterType<Image_handler>("Image_handler_qml", 1, 0, "Image_handler");
    qmlRegisterType<Individual_manager>("Individual_manager_qml", 1, 0, "Individual_manager");
    qmlRegisterType<People_manager>("People_manager_qml", 1, 0, "People_manager");
    qmlRegisterType<Selected_people_model>("Selected_people_model_qml", 1, 0, "Selected_people_model");

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
