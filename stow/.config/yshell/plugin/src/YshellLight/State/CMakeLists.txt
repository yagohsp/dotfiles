qml_module(yshell-light-state
    URI YshellLight.State
    INCLUDE_PREFIX state
    SOURCES
        common.cpp
        rootnodes.cpp
    DEPENDENCIES
        YshellLight.Settings
)
target_link_libraries(yshell-light-state PUBLIC yshell-light-settings)
