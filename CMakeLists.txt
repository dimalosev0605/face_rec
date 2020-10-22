cmake_minimum_required(VERSION 3.5)

project(face_rec LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D USE_AVX_INSTRUCTIONS=ON -D USE_SSE2_INSTRUCTIONS=ON -D USE_SSE4_INSTRUCTIONS=ON")

find_package(Qt5 COMPONENTS Core Quick REQUIRED)
find_package(dlib REQUIRED)
find_package(OpenCV REQUIRED)

include_directories(${OpenCV_INCLUDE_DIRS})

add_executable(face_rec
    main.cpp

    other/selected_images_model.h
    other/selected_images_model.cpp
    other/individual_manager.h
    other/individual_manager.cpp
    other/individual_file_manager.h
    other/individual_file_manager.cpp

    people_models/base_people_model.h
    people_models/base_people_model.cpp
    people_models/available_people_model.h
    people_models/available_people_model.cpp
    people_models/selected_people_model.h
    people_models/selected_people_model.cpp

    image_handlers/base_image_handler.h
    image_handlers/base_image_handler.cpp
    image_handlers/add_new_face_image_handler.h
    image_handlers/add_new_face_image_handler.cpp
    image_handlers/face_recognition_image_handler.h
    image_handlers/face_recognition_image_handler.cpp

    qml.qrc)

target_compile_definitions(face_rec
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(face_rec
  PRIVATE Qt5::Core Qt5::Quick dlib::dlib ${OpenCV_LIBS})
