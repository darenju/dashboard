cmake_minimum_required(VERSION 3.16)

project(Dashboard VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Svg)

qt_standard_project_setup(REQUIRES 6.8)
set(CMAKE_AUTORCC ON)

qt_add_executable(appDashboard
    main.cpp
    qml.qrc
)

qt_add_qml_module(appDashboard
    URI Dashboard
    VERSION 1.0
    QML_FILES Main.qml CarGauge.qml
    SOURCES Tracker.cpp Tracker.h
    QML_FILES TopIcons.qml
    QML_FILES
    QML_FILES trucks/MANTGX.qml
)
# qt_add_resources(SOURCES qml.qrc)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appDashboard PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appDashboard
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appDashboard
    PRIVATE Qt6::Quick Qt6::Svg
)

include(GNUInstallDirs)
install(TARGETS appDashboard
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
