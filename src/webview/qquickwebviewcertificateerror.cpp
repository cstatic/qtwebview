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

#include "qquickwebviewcertificateerror_p.h"
#include <QtWebView/private/qwebviewcertificateerror_p.h>

QQuickWebViewCertificateError::QQuickWebViewCertificateError(QObject *parent)
    : QObject(parent)
{
}

QQuickWebViewCertificateError::~QQuickWebViewCertificateError()
{

}

void QQuickWebViewCertificateError::defer()
{
    Q_D(QWebViewCertificateError);
    d->defer();
}

void QQuickWebViewCertificateError::ignoreCertificateError()
{
    Q_D(QWebViewCertificateError);
    d->ignoreCertificateError();
}

void QQuickWebViewCertificateError::rejectCertificate()
{
    Q_D(QWebViewCertificateError);
    d->rejectCertificate();
}

QUrl QQuickWebViewCertificateError::url() const
{
    Q_D(const QWebViewCertificateError);
    return d->url();
}

QQuickWebViewCertificateError::Error QQuickWebViewCertificateError::error() const
{
    Q_D(const QWebViewCertificateError);
    return static_cast<QQuickWebViewCertificateError::Error>(d->error());
}

QString QQuickWebViewCertificateError::description() const
{
    Q_D(const QWebViewCertificateError);
    return d->description();
}

bool QQuickWebViewCertificateError::overridable() const
{
    Q_D(const QWebViewCertificateError);
    return d->overridable();
}

bool QQuickWebViewCertificateError::deferred() const
{
    Q_D(const QWebViewCertificateError);
    return d->deferred();
}

bool QQuickWebViewCertificateError::answered() const
{
    Q_D(const QWebViewCertificateError);
    return d->answered();
}


