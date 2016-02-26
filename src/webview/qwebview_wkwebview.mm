/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the QtWebView module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "qwebview_ios_p.h"
#include "qwebview_p.h"
#include "qwebviewloadrequest_p.h"

#include <QtQuick/qquickwindow.h>
#include <QtQuick/qquickrendercontrol.h>
#include <QtCore/qmap.h>

#include <CoreFoundation/CoreFoundation.h>
#include <UIKit/UIKit.h>

#import <UIKit/UIView.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UITapGestureRecognizer.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

#import <WebKit/WKWebView.h>
#import <WebKit/WKNavigationDelegate.h>

QT_BEGIN_NAMESPACE

QWebViewPrivate *QWebViewPrivate::create(QWebView *q)
{
    return new QIosWebViewPrivate(q);
}

static inline CGRect toCGRect(const QRectF &rect)
{
    return CGRectMake(rect.x(), rect.y(), rect.width(), rect.height());
}

// -------------------------------------------------------------------------

@interface QIOSNativeViewSelectedRecognizer : UIGestureRecognizer <UIGestureRecognizerDelegate>
{
@public
    QNativeViewController *m_item;
}
@end

@implementation QIOSNativeViewSelectedRecognizer

- (id)initWithQWindowControllerItem:(QNativeViewController *)item
{
    self = [super initWithTarget:self action:@selector(nativeViewSelected:)];
    if (self) {
        self.cancelsTouchesInView = NO;
        self.delaysTouchesEnded = NO;
        m_item = item;
    }
    return self;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)other
{
    Q_UNUSED(other);
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)other
{
    Q_UNUSED(other);
    return NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    Q_UNUSED(touches);
    Q_UNUSED(event);
    self.state = UIGestureRecognizerStateRecognized;
}

- (void)nativeViewSelected:(UIGestureRecognizer *)gestureRecognizer
{
    Q_UNUSED(gestureRecognizer);
    m_item->setFocus(true);
}

@end

// -------------------------------------------------------------------------
@interface QWkNavigationDelegate : NSObject<WKNavigationDelegate> {
    QIosWebViewPrivate *qIosWebViewPrivate;
}
//
- (QWkNavigationDelegate *)initWithQAbstractWebView:(QIosWebViewPrivate *)webViewPrivate;

// Observing estimatedProgress, loading and title
- (void)observeValueForKeyPath:(NSString *)keyPath
                               ofObject:(id)object
                               change:(NSDictionary *)change
                               context:(void *)context;

// WKNavigationDelegate interface
- (void)webView:(WKWebView *)webView
  didCommitNavigation:(WKNavigation *)navigation;
- (void)webView:(WKWebView *)webView
  didFailNavigation:(WKNavigation *)navigation
  withError:(NSError *)error;
- (void)webView:(WKWebView *)webView
  didFailProvisionalNavigation:(WKNavigation *)navigation
  withError:(NSError *)error;
- (void)webView:(WKWebView *)webView
  didFinishNavigation:(WKNavigation *)navigation;
- (void)webView:(WKWebView *)webView
  didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
  completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
                     NSURLCredential *credential))completionHandler;
- (void)webView:(WKWebView *)webView
  didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;
- (void)webView:(WKWebView *)webView
  didStartProvisionalNavigation:(WKNavigation *)navigation;
@end // interface

@implementation QWkNavigationDelegate
- (QWkNavigationDelegate *)initWithQAbstractWebView:(QIosWebViewPrivate *)webViewPrivate
{
    qIosWebViewPrivate = webViewPrivate;
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                               ofObject:(id)object
                               change:(NSDictionary *)change
                               context:(void *)context {
    Q_UNUSED(change);
    Q_UNUSED(context);
    if ([keyPath isEqual:@"title"])
        Q_EMIT qIosWebViewPrivate->titleChanged(QString::fromNSString([(WKWebView *)object title]));

    const bool loadingChanged = [keyPath isEqual:@"loading"] || [keyPath isEqual:@"estimatedProgress"];
    if (!loadingChanged)
        return;

    WKWebView *webView = (WKWebView *)object;
    const int newProgress = [webView estimatedProgress] * 100;
    Q_EMIT qIosWebViewPrivate->loadProgressChanged(newProgress);
    if (newProgress == 100 && !webView.loading) {
        Q_EMIT qIosWebViewPrivate->loadingChanged(QWebViewLoadRequestPrivate(qIosWebViewPrivate->url(),
                                                                             QWebView::LoadSucceededStatus,
                                                                             QString()));
    }
}

- (void)webView:(WKWebView *)webView
  didCommitNavigation:(WKNavigation *)navigation
{
    Q_UNUSED(webView);
    Q_UNUSED(navigation);
}

- (void)webView:(WKWebView *)webView
  didFailNavigation:(WKNavigation *)navigation
  withError:(NSError *)error
{
    Q_UNUSED(webView);
    Q_UNUSED(navigation);
    NSString *errorString = [error localizedFailureReason];
    Q_EMIT qIosWebViewPrivate->loadingChanged(QWebViewLoadRequestPrivate(qIosWebViewPrivate->url(),
                                                                         QWebView::LoadFailedStatus,
                                                                         QString::fromNSString(errorString)));
}

- (void)webView:(WKWebView *)webView
  didFailProvisionalNavigation:(WKNavigation *)navigation
  withError:(NSError *)error
{
    Q_UNUSED(webView);
    Q_UNUSED(navigation);
    NSString *errorString = [error localizedFailureReason];
    Q_EMIT qIosWebViewPrivate->loadingChanged(QWebViewLoadRequestPrivate(qIosWebViewPrivate->url(),
                                                                         QWebView::LoadFailedStatus,
                                                                         QString::fromNSString(errorString)));
}

- (void)webView:(WKWebView *)webView
  didFinishNavigation:(WKNavigation *)navigation
{
    Q_UNUSED(webView);
    Q_UNUSED(navigation);
}

- (void)webView:(WKWebView *)webView
  didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
  completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
                     NSURLCredential *credential))completionHandler
{
    Q_UNUSED(webView);
    // TODO: We don't provide SSL handling, so this is just the same as the default behaviour...
    completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, [challenge proposedCredential]);
}

- (void)webView:(WKWebView *)webView
  didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    Q_UNUSED(webView);
    Q_UNUSED(navigation);
}

- (void)webView:(WKWebView *)webView
  didStartProvisionalNavigation:(WKNavigation *)navigation
{
    Q_UNUSED(webView);
    Q_UNUSED(navigation);
    Q_EMIT qIosWebViewPrivate->loadingChanged(QWebViewLoadRequestPrivate(qIosWebViewPrivate->url(),
                                                                         QWebView::LoadStartedStatus,
                                                                         QString()));
}
@end // implementation
// -------------------------------------------------------------------------

QIosWebViewPrivate::QIosWebViewPrivate(QObject *p)
    : QWebViewPrivate(p)
    , m_webView(0)
    , m_recognizer(0)
{
    CGRect frame = CGRectMake(0.0, 0.0, 400, 400);
    m_webView = [[WKWebView alloc] initWithFrame:frame];
    m_webView.navigationDelegate = [[QWkNavigationDelegate alloc] initWithQAbstractWebView:this];
    [m_webView addObserver:m_webView.navigationDelegate
               forKeyPath:@"estimatedProgress"
               options:(NSKeyValueObservingOptionNew)
               context:nil];
    [m_webView addObserver:m_webView.navigationDelegate
               forKeyPath:@"loading"
               options:(NSKeyValueObservingOptionNew)
               context:nil];
    [m_webView addObserver:m_webView.navigationDelegate
               forKeyPath:@"title"
               options:(NSKeyValueObservingOptionNew)
               context:nil];
    m_recognizer = [[QIOSNativeViewSelectedRecognizer alloc] initWithQWindowControllerItem:this];
    [m_webView addGestureRecognizer:m_recognizer];
}

QIosWebViewPrivate::~QIosWebViewPrivate()
{
    [m_webView removeObserver:m_webView.navigationDelegate forKeyPath:@"estimatedProgress"];
    [m_webView removeObserver:m_webView.navigationDelegate forKeyPath:@"loading"];
    [m_webView removeObserver:m_webView.navigationDelegate forKeyPath:@"title"];
    [m_webView.navigationDelegate release];
    m_webView.navigationDelegate = nil; // reset as per UIWebViewDelegate documentation
    [m_webView release];
    [m_recognizer release];
}

QUrl QIosWebViewPrivate::url() const
{
    NSURL *url = [m_webView URL];
    return QUrl::fromNSURL(url).toString();
}

void QIosWebViewPrivate::setUrl(const QUrl &url)
{
    // TODO: Does not work with local files (out-of-the-box).
    // Starting with iOS9 we can use allowingReadAccessToURL
    [m_webView loadRequest:[NSURLRequest requestWithURL:url.toNSURL()]];
}

void QIosWebViewPrivate::loadHtml(const QString &html, const QUrl &baseUrl)
{
    [m_webView loadHTMLString:html.toNSString() baseURL:baseUrl.toNSURL()];
}

bool QIosWebViewPrivate::canGoBack() const
{
    return m_webView.canGoBack;
}

bool QIosWebViewPrivate::canGoForward() const
{
    return m_webView.canGoForward;
}

QString QIosWebViewPrivate::title() const
{
    return QString::fromNSString(m_webView.title);
}

int QIosWebViewPrivate::loadProgress() const
{
    return [m_webView estimatedProgress] * 100;
}

bool QIosWebViewPrivate::isLoading() const
{
    return m_webView.loading;
}

void QIosWebViewPrivate::setParentView(QObject *view)
{
    m_parentView = view;

    if (!m_webView)
        return;

    QQuickWindow *qw = qobject_cast<QQuickWindow *>(view);
    if (qw) {
        // Before setting the parent view, make sure we have the real window.
        QWindow *rw = QQuickRenderControl::renderWindowFor(qw);
        UIView *parentView = reinterpret_cast<UIView *>(rw ? rw->winId() : qw->winId());
        [parentView addSubview:m_webView];
    } else {
        [m_webView removeFromSuperview];
    }
}

QObject *QIosWebViewPrivate::parentView() const
{
    if (!m_webView)
        return;

    QWindow *w = qobject_cast<QWindow *>(m_parentView);
    if (w == 0)
        return;

    // Find the top left position of this item in global coordinates.
    const QPoint &tl = w->mapToGlobal(geometry.topLeft());
    // Map the top left position to the render windows coordinates.
    QQuickWindow *qw = qobject_cast<QQuickWindow *>(m_parentView);
    QWindow *rw = QQuickRenderControl::renderWindowFor(qw);
    // New geometry
    const QRect &newGeometry = rw ? QRect(rw->mapFromGlobal(tl), geometry.size()) : geometry;
    // Sets location and size in the superviews coordinate system.
    [m_webView setFrame:toCGRect(newGeometry)];
}

void QIosWebViewPrivate::setGeometry(const QRect &geometry)
{
    [m_webView setFrame:toCGRect(geometry)];
}

void QIosWebViewPrivate::setVisibility(QWindow::Visibility visibility)
{
    Q_UNUSED(visibility);
}

void QIosWebViewPrivate::setVisible(bool visible)
{
    [m_webView setHidden:!visible];
}

void QIosWebViewPrivate::setFocus(bool focus)
{
    Q_EMIT requestFocus(focus);
}

void QIosWebViewPrivate::goBack()
{
    [m_webView goBack];
}

void QIosWebViewPrivate::goForward()
{
    [m_webView goForward];
}

void QIosWebViewPrivate::stop()
{
    [m_webView stopLoading];
}

void QIosWebViewPrivate::reload()
{
    [m_webView reload];
}

void QIosWebViewPrivate::runJavaScriptPrivate(const QString &script, int callbackId)
{
    void (^resultCb)(id, NSError *) = ^(id result, NSError *error)
    {
            if (callbackId != -1 && error == nil && result != nil)
                Q_EMIT javaScriptResult(callbackId, QString::fromNSString(result));
    };

    [m_webView evaluateJavaScript:script.toNSString() completionHandler:resultCb];
}

QT_END_NAMESPACE
