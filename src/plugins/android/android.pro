TARGET = qtwebview_android

PLUGIN_TYPE = webview
PLUGIN_CLASS_NAME = QAndroidWebViewPlugin
load(qt_plugin)

QT += core-private
LIBS += -ljnigraphics

HEADERS += \
    qandroidwebview_p.h


SOURCES += \
    qandroidwebviewplugin.cpp \
    qandroidwebviewplugin.cpp \
    qandroidwebview.cpp

OTHER_FILES +=

DISTFILES += \
    android.json
