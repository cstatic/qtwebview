TEMPLATE = subdirs

android {
    SUBDIRS += android
} else:ios {
    SUBDIRS += ios
} else:osx_webview_experimental {
    SUBDIRS += osx
} else: winrt {
    SUBDIRS += winrt
} else:qtHaveModule(webengine) {
    SUBDIRS += webengine
}

# else:qtHaveModule(webengine) {
#    QT += webengine webengine-private
#    DEFINES += QT_WEBVIEW_WEBENGINE_BACKEND
#    SOURCES += \
#        qwebview_default.cpp

#}

#HEADERS += $$PUBLIC_HEADERS $$PRIVATE_HEADERS
