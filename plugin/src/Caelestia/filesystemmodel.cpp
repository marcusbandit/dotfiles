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
    return m_files.size();
}

QVariant FileSystemModel::data(const QModelIndex& index, int role) const {
    if (!index.isValid() || index.row() >= m_files.size()) {
        return QVariant();
    }

    const FileSystemEntry* file = m_files.at(index.row());
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

QList<FileSystemEntry*> FileSystemModel::files() const {
    return m_files;
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
    updateFiles();
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

void FileSystemModel::updateFiles() {
    if (m_path.isEmpty()) {
        beginResetModel();
        qDeleteAll(m_files);
        m_files.clear();
        emit filesChanged();
        endResetModel();

        return;
    }

    beginResetModel();
    qDeleteAll(m_files);
    m_files.clear();

    const auto flags = m_recursive ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags;

    std::optional<QDirIterator> iter;

    if (m_filter == ImagesOnly) {
        QStringList filters;
        for (const auto& format : QImageReader::supportedImageFormats()) {
            filters << "*." + format;
        }

        iter.emplace(m_path, filters, QDir::Files, flags);
    } else {
        iter.emplace(m_path, QDir::Files, flags);
    }

    while (iter.value().hasNext()) {
        QString file = iter.value().next();

        if (m_filter == ImagesOnly) {
            QImageReader reader(file);
            if (reader.canRead()) {
                m_files << new FileSystemEntry(file, m_dir.relativeFilePath(file), this);
            }
        } else {
            m_files << new FileSystemEntry(file, m_dir.relativeFilePath(file), this);
        }
    }

    emit filesChanged();

    endResetModel();
}
