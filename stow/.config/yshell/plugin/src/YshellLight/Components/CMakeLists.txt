qml_module(yshell-light-components
    URI YshellLight.Components
    SOURCES
        animatedrepeater.cpp
        lazylistview.cpp
        wavyline.cpp
        buttonrow.cpp
        circularindicatormanager.cpp
        linearindicatormanager.cpp
        sparklineitem.cpp
        visualiserbars.cpp
        roundedmask.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        yshell-light-core
    DEPENDENCIES
        YshellLight
)

qt_add_shaders(yshell-light-components "components_shaders"
    BATCHABLE OPTIMIZED NOHLSL NOMSL
    GLSL "300es,330"
    PREFIX "/"
    FILES
        shaders/roundedmask.frag
        shaders/roundedmask.vert
)
