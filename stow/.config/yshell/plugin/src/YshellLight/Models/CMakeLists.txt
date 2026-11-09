qml_module(yshell-light-models
    URI YshellLight.Models
    SOURCES
        filesystemmodel.cpp
        appdb.cpp
    LIBRARIES
        Qt::Gui
        Qt::Multimedia
        Qt::Concurrent
        Qt::Sql
)
