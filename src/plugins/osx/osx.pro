TARGET = qtwebview_osx
QT += core-private

PLUGIN_TYPE = webview
PLUGIN_CLASS_NAME = QOsxWebViewPlugin

load(qt_plugin)

DEFINES += QT_WEBVIEW_EXPERIMENTAL
LIBS_PRIVATE += -framework Cocoa -framework WebKit

HEADERS += \
    qosxwebview_p.h

SOURCES += \
    qosxwebviewplugin.cpp

OBJECTIVE_SOURCES += \
    qosxwebview.mm

OTHER_FILES +=

DISTFILES += \
    osx.json
