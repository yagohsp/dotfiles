qml_module(yshell-light-core
    URI YshellLight
    INCLUDE_PREFIX core
    SOURCES
        cutils.cpp
        qalculator.cpp
        requests.cpp
        toaster.cpp
        circularbuffer.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
        PkgConfig::Qalculate
)
target_link_libraries(yshell-light-core PUBLIC yshell-light-util)

# Bake the shell version in so CUtils can expose it without spawning a process
target_compile_definitions(yshell-light-core PRIVATE YSHELL_LIGHT_VERSION="${VERSION}")

# Node macros expand to Q_OBJECT, automoc can't see it otherwise
list(APPEND CMAKE_AUTOMOC_MACRO_NAMES
    SETTINGS_NODE SETTINGS_NODE_NO_CTOR SETTINGS_LIST_TYPE SETTINGS_SINGLETON_DECL
    CONFIG_NODE CONFIG_NODE_NO_CTOR CONFIG_LIST_TYPE
    STATE_NODE_NO_CTOR
)

add_subdirectory(Settings)
add_subdirectory(Components)
add_subdirectory(Config)
add_subdirectory(State)
add_subdirectory(Models)
add_subdirectory(Services)
add_subdirectory(Blobs)
add_subdirectory(Images)
add_subdirectory(I18n)
add_subdirectory(Multimedia)
add_subdirectory(Shaders)
