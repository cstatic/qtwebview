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

#ifndef QWEBVIEWCERTIFICATEERRORPRIVATE_P_H
#define QWEBVIEWCERTIFICATEERRORPRIVATE_P_H

//
//  W A R N I N G
//  -------------
//
// This file is not part of the Qt API.  It exists purely as an
// implementation detail.  This header file may change from version to
// version without notice, or even be removed.
//
// We mean it.
//

#include <QtWebView/private/qwebview_p.h>

#include <QtCore/qstring.h>
#include <QtCore/qurl.h>

QT_BEGIN_NAMESPACE

class Q_WEBVIEW_EXPORT QWebViewCertificateErrorPrivate
{
public:
    enum Error {
        SslPinnedKeyNotInCertificateChain = -150,
        CertificateCommonNameInvalid = -200,
        CertificateDateInvalid = -201,
        CertificateAuthorityInvalid = -202,
        CertificateContainsErrors = -203,
        CertificateNoRevocationMechanism = -204,
        CertificateUnableToCheckRevocation = -205,
        CertificateRevoked = -206,
        CertificateInvalid = -207,
        CertificateWeakSignatureAlgorithm = -208,
        CertificateNonUniqueName = -210,
        CertificateWeakKey = -211,
        CertificateNameConstraintViolation = -212,
    };

    QWebViewCertificateErrorPrivate();
    ~QWebViewCertificateErrorPrivate();

    void defer();
    void ignoreCertificateError();
    void rejectCertificate();
    QUrl url() const;
    Error error() const;
    QString description() const;
    bool overridable() const;
    bool deferred() const;
    bool answered() const;
    bool rejected() const;

private:
    QUrl m_url;
    Error m_error;
    QString m_description;
    bool m_rejected;
    bool m_deferred;
    bool m_answered;
    bool m_overridable;
};

Q_DECLARE_METATYPE(QWebViewCertificateErrorPrivate)

QT_END_NAMESPACE

#endif // QWEBVIEWCERTIFICATEERRORPRIVATE_P_H
