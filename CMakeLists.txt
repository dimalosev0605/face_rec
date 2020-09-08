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

    left_vertical_menu_bar_model.h
    left_vertical_menu_bar_model.cpp

    qml.qrc)

target_compile_definitions(face_rec
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(face_rec
  PRIVATE Qt5::Core Qt5::Quick dlib::dlib ${OpenCV_LIBS})