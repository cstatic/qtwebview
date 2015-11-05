TARGET = qtwebview_ios
QT += core-private

PLUGIN_TYPE = webview
PLUGIN_CLASS_NAME = QIosWebViewPlugin
LIBS_PRIVATE += -framework WebKit

load(qt_plugin)

HEADERS += \
    qioswebview_p.h

SOURCES += \
    qioswebviewplugin.cpp

OBJECTIVE_SOURCES += \
    qioswebview.mm

OTHER_FILES +=

DISTFILES += \
    ios.json
