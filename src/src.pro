TEMPLATE = subdirs

android|ios|winrt|osx_webview_experimental|qtHaveModule(webengine) {
    SUBDIRS += webview imports plugins
    imports.depends = webview
}

android: SUBDIRS += jar
