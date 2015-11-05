load(qt_build_config)

TARGET = QtWebView

QT =
QT_FOR_PRIVATE = quick-private

include($$PWD/webview-lib.pri)

qtHaveModule(webengine) {
    QT += webengine
    DEFINES += QT_WEBVIEW_WEBENGINE_BACKEND
}

PUBLIC_HEADERS += \
    qwebview_global.h \
    qtwebviewfunctions.h

PRIVATE_HEADERS += \
    qwebview_p.h \
    qwebviewinterface_p.h \
    qquickwebview_p.h \
    qnativeviewcontroller_p.h \
    qwebview_p_p.h \
    qquickviewcontroller_p.h \
    qwebviewloadrequest_p.h \
    qquickwebviewloadrequest_p.h

SOURCES += \
    qtwebviewfunctions.cpp \
    qwebview.cpp \
    qquickwebview.cpp \
    qquickviewcontroller.cpp \
    qquickwebviewloadrequest.cpp \
    qwebviewloadrequest.cpp \
    qwebviewplugin.cpp

QMAKE_DOCS = \
             $$PWD/doc/qtwebview.qdocconf

ANDROID_BUNDLED_JAR_DEPENDENCIES = \
    jar/QtAndroidWebView-bundled.jar
ANDROID_JAR_DEPENDENCIES = \
    jar/QtAndroidWebView.jar
ANDROID_PERMISSIONS = \
    android.permission.ACCESS_FINE_LOCATION

HEADERS += $$PUBLIC_HEADERS $$PRIVATE_HEADERS \
    qwebviewplugin_p.h

load(qt_module)
