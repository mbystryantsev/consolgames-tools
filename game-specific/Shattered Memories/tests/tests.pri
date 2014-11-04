#check Qt version
QT_VERSION = $$[QT_VERSION]
QT_VERSION = $$split(QT_VERSION, ".")
QT_VER_MAJ = $$member(QT_VERSION, 0)
QT_VER_MIN = $$member(QT_VERSION, 1)

lessThan(QT_VER_MAJ, 5) {
	CONFIG += qtestlib
} else {
	QT += testlib
}

QT -= gui
QT += core
TEMPLATE = app

include(../ShatteredMemories.pri)
