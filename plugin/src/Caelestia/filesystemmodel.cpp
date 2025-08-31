#include "filesystemmodel.hpp"

#include <QObject>
#include <qqmlintegration.h>
#include <QAbstractListModel>
#include <QFileInfo>
#include <QDir>
#include <QDirIterator>
#include <QImageReader>

int FileSystemModel::rowCount(const QModelIndex& parent) const {
    Q_UNUSED(parent);
    return m_entries.size();
}

QVariant FileSystemModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= m_entries.size()) {
        return QVariant();
    }

    FileSystemEntry* file = m_entries.at(index.row());
    switch (role) {
    case FilePathRole:
        return file->path();
    case RelativeFilePathRole:
        return file->relativePath();
    case FileNameRole:
        return file->name();
    case ParentDirRole:
        return file->parentDir();
    case FileSizeRole:
        return file->size();
    case FileIsDirRole:
        return file->isDir();
    case FileIsImageRole:
        return file->isImage();
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> FileSystemModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[FilePathRole] = "filePath";
    roles[RelativeFilePathRole] = "relativeFilePath";
    roles[FileNameRole] = "fileName";
    roles[ParentDirRole] = "parentDir";
    roles[FileSizeRole] = "fileSize";
    roles[FileIsDirRole] = "fileIsDir";
    roles[FileIsImageRole] = "fileIsImage";
    return roles;
}

QString FileSystemModel::path() const {
    return m_path;
}

void FileSystemModel::setPath(const QString& path) {
    if (m_path == path) {
        return;
    }

    m_path = path;
    emit pathChanged();

    m_dir.setPath(m_path);
    update();
}

bool FileSystemModel::recursive() const {
    return m_recursive;
}

void FileSystemModel::setRecursive(bool recursive) {
    if (m_recursive == recursive) {
        return;
    }

    m_recursive = recursive;
    emit recursiveChanged();

    update();
}

FileSystemModel::Filter FileSystemModel::filter() const {
    return m_filter;
}

void FileSystemModel::setFilter(Filter filter) {
    if (m_filter == filter) {
        return;
    }

    m_filter = filter;
    emit filterChanged();

    update();
}

QList<FileSystemEntry*> FileSystemModel::entries() const {
    return m_entries;
}

void FileSystemModel::watchDirIfRecursive(const QString& path) {
    if (m_recursive) {
        QDirIterator iter(path, QDir::Dirs | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
        while (iter.hasNext()) {
            m_watcher.addPath(iter.next());
        }
    }
}

void FileSystemModel::update() {
    updateWatcher();
    updateEntries();
}

void FileSystemModel::updateWatcher() {
    if (!m_watcher.directories().isEmpty()) {
        m_watcher.removePaths(m_watcher.directories());
    }

    if (m_path.isEmpty()) {
        return;
    }

    m_watcher.addPath(m_path);
    watchDirIfRecursive(m_path);
}

void FileSystemModel::updateEntries() {
    if (m_path.isEmpty()) {
        if (!m_entries.isEmpty()) {
            beginResetModel();
            qDeleteAll(m_entries);
            m_entries.clear();
            emit entriesChanged();
            endResetModel();
        }

        return;
    }

    const auto flags = m_recursive ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags;

    std::optional<QDirIterator> iter;

    if (m_filter == Images) {
        QStringList filters;
        for (const auto& format : QImageReader::supportedImageFormats()) {
            filters << "*." + format;
        }

        iter.emplace(m_path, filters, QDir::Files, flags);
    } else if (m_filter == Files) {
        iter.emplace(m_path, QDir::Files, flags);
    } else {
        iter.emplace(m_path, QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot, flags);
    }

    QStringList newPaths;

    while (iter.value().hasNext()) {
        QString path = iter.value().next();

        if (m_filter == Images) {
            QImageReader reader(path);
            if (!reader.canRead()) {
                continue;
            }
        }

        newPaths << path;
    }

    QStringList oldPaths;
    for (const auto& entry : m_entries) {
        oldPaths << entry->path();
    }

    if (newPaths == oldPaths) {
        return;
    }

    beginResetModel();
    qDeleteAll(m_entries);
    m_entries.clear();

    for (const auto& path : newPaths) {
        m_entries << new FileSystemEntry(path, m_dir.relativeFilePath(path), this);
    }

    emit entriesChanged();

    endResetModel();
}
