#include "cachingimagemanager.hpp"

#include <qobject.h>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickWindow>
#include <QCryptographicHash>
#include <QThreadPool>
#include <QFile>
#include <QDir>
#include <QImageReader>

qreal CachingImageManager::effectiveScale() const {
    if (m_item->window()) {
        return m_item->window()->devicePixelRatio();
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

    if (m_widthConn) {
        disconnect(m_widthConn);
    }
    if (m_heightConn) {
        disconnect(m_heightConn);
    }

    m_item = item;
    emit itemChanged();

    if (item) {
        m_widthConn = connect(item, &QQuickItem::widthChanged, this, [this]() { updateSource(); });
        m_heightConn = connect(item, &QQuickItem::heightChanged, this, [this]() { updateSource(); });
        updateSource();
    }
}

QUrl CachingImageManager::cacheDir() const {
    return m_cacheDir;
}

void CachingImageManager::setCacheDir(const QUrl& cacheDir) {
    if (m_cacheDir == cacheDir) {
        return;
    }

    m_cacheDir = cacheDir;
    if (!m_cacheDir.path().endsWith("/")) {
        m_cacheDir.setPath(m_cacheDir.path() + "/");
    }
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
        updateSource(path);
    }
}

void CachingImageManager::updateSource() {
    updateSource(m_path);
}

void CachingImageManager::updateSource(const QString& path) {
    if (path.isEmpty()) {
        return;
    }

    QThreadPool::globalInstance()->start([path, this] {
        const QString sha = sha256sum(path);

        QMetaObject::invokeMethod(this, [path, sha, this]() {
            int width = effectiveWidth();
            int height = effectiveHeight();
            const QString filename = QString("%1@%2x%3.png").arg(sha).arg(width).arg(height);

            const QUrl cache = m_cacheDir.resolved(QUrl(filename));
            if (m_cachePath == cache) {
                return;
            }

            m_cachePath = cache;
            emit cachePathChanged();

            if (!cache.isLocalFile()) {
                qWarning() << "CachingImageManager::updateSource: cachePath" << cache << "is not a local file";
                return;
            }

            bool cacheExists = QFile::exists(cache.toLocalFile());

            if (cacheExists) {
                m_item->setProperty("source", cache);
            } else {
                m_item->setProperty("source", QUrl::fromLocalFile(path));
                createCache(path, cache.toLocalFile(), QSize(width, height));
            }
        }, Qt::QueuedConnection);
    });
}

QUrl CachingImageManager::cachePath() const {
    return m_cachePath;
}

void CachingImageManager::createCache(const QString& path, const QString& cache, const QSize& size) const {
    QThreadPool::globalInstance()->start([path, cache, size] {
        QImageReader reader(path);

        QSize imgSize = reader.size();
        if (!imgSize.isValid()) {
            qWarning() << "CachingImageManager::createCache: unable to get size of" << path;
            return;
        }

        qreal scale = std::max(
            qreal(size.width()) / imgSize.width(),
            qreal(size.height()) / imgSize.height()
        );
        QSizeF scaledSize(imgSize.width() * scale, imgSize.height() * scale);
        qreal xOff = (scaledSize.width() - size.width()) / 2.0;
        qreal yOff = (scaledSize.height() - size.height()) / 2.0;

        reader.setScaledSize(scaledSize.toSize());
        reader.setScaledClipRect(QRectF(xOff, yOff, size.width(), size.height()).toRect());

        QImage image = reader.read();

        if (image.isNull()) {
            qWarning() << "CachingImageManager::createCache: failed to read" << path;
            return;
        }

        const QString parent = QFileInfo(cache).absolutePath();
        if (!QDir().mkpath(parent) || !image.save(cache)) {
            qWarning() << "CachingImageManager::createCache: failed to save to" << cache;
        }
    });
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
