#ifndef UTILS_H
#define UTILS_H

#include <QIcon>
#include <QFrame>

namespace Utils {
    bool isWindows10();
    QIcon getIcon(int type, int volume, bool muted);
    void setFrameColorBasedOnWindow(QWidget *window, QFrame *frame);
}

#endif // UTILS_H
