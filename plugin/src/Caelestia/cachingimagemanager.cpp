#include "cachingimagemanager.hpp"

#include <qobject.h>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickWindow>
#include <QCryptographicHash>
#include <QThreadPool>
#include <QFile>

qreal CachingImageManager::effectiveScale() const {
    if (m_item->window() && m_item->window()->screen()) {
        return m_item->window()->screen()->devicePixelRatio();
    }

    return 1.0;
}

int CachingImageManager::effectiveWidth() const {
    int width = std::ceil(m_item->width() * effectiveScale());
    m_item->setProperty("sourceWidth", width);
    return width;
}

int CachingImageManager::effectiveHeight() const {
    int height = std::ceil(m_item->height() * effectiveScale());
    m_item->setProperty("sourceHeight", height);
    return height;
}

QQuickItem* CachingImageManager::item() const {
    return m_item;
}

void CachingImageManager::setItem(QQuickItem* item) {
    if (m_item == item) {
        return;
    }

    m_item = item;
    emit itemChanged();
}

QUrl CachingImageManager::cacheDir() const {
    return m_cacheDir;
}

void CachingImageManager::setCacheDir(const QUrl& cacheDir) {
    if (m_cacheDir == cacheDir) {
        return;
    }

    m_cacheDir = cacheDir;
    emit cacheDirChanged();
}

QString CachingImageManager::path() const {
    return m_path;
}

void CachingImageManager::setPath(const QString& path) {
    if (m_path == path) {
        return;
    }

    m_path = path;
    emit pathChanged();

    if (!path.isEmpty()) {
        QThreadPool::globalInstance()->start([path, this] {
            const QString filename = QString("%1@%2x%3.png")
                .arg(sha256sum(path))
                .arg(effectiveWidth())
                .arg(effectiveHeight());

            m_cachePath = m_cacheDir.resolved(QUrl(filename));
            emit cachePathChanged();

            if (!m_cachePath.isLocalFile()) {
                qWarning() << "CachingImageManager::setPath: cachePath" << m_cachePath << "is not a local file";
                return;
            }

            if (QFile::exists(m_cachePath.toLocalFile())) {
                QMetaObject::invokeMethod(m_item, [this]() {
                    m_item->setProperty("source", m_cachePath);
                }, Qt::QueuedConnection);

                m_usingCache = true;
                emit usingCacheChanged();
            } else {
                QMetaObject::invokeMethod(m_item, [path, this]() {
                    m_item->setProperty("source", QUrl::fromLocalFile(path));
                }, Qt::QueuedConnection);

                m_usingCache = false;
                emit usingCacheChanged();
            }
        });
    }
}

QUrl CachingImageManager::cachePath() const {
    return m_cachePath;
}

bool CachingImageManager::usingCache() const {
    return m_usingCache;
}

QString CachingImageManager::sha256sum(const QString& path) const {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "CachingImageManager::sha256sum: failed to open" << path;
        return "";
    }

    QCryptographicHash hash(QCryptographicHash::Sha256);
    hash.addData(&file);
    file.close();

    return hash.result().toHex();
}
