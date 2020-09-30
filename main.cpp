#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "left_vertical_menu_bar_model.h"
#include "selected_images_model.h"
#include "image_handler.h"
#include "people_manager.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<Left_vertical_menu_bar_model>("Left_vertical_menu_bar_model_qml", 1, 0, "Left_vertical_menu_bar_model");
    qmlRegisterType<Selected_images_model>("Selected_images_model_qml", 1, 0, "Selected_images_model");
    qmlRegisterType<Image_handler>("Image_handler_qml", 1, 0, "Image_handler");
    qmlRegisterType<People_manager>("People_manager_qml", 1, 0, "People_manager");

    qmlRegisterUncreatableMetaObject(MenuBarAction::staticMetaObject, "MenuBarActionNamespace_qml", 1, 0, "MenuBarAction", "Error, only enums!");

    QQmlApplicationEngine engine;

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
