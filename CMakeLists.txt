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

    selected_images_model.h
    selected_images_model.cpp
    
    image_handler.h
    image_handler.cpp

    individual_manager.h
    individual_manager.cpp

    individual_file_manager.h
    individual_file_manager.cpp

    base_people_model.h
    base_people_model.cpp

    available_people_model.h
    available_people_model.cpp

    selected_people_model.h
    selected_people_model.cpp

    base_image_handler.h
    base_image_handler.cpp

    add_new_person_image_handler.h
    add_new_person_image_handler.cpp

    qml.qrc)

target_compile_definitions(face_rec
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(face_rec
  PRIVATE Qt5::Core Qt5::Quick dlib::dlib ${OpenCV_LIBS})
