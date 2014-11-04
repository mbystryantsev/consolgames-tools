include(../ShatteredMemories.pri)

lessThan(QT_VER_MAJ, 5) {
	CONFIG += qtestlib
} else {
	QT += testlib
}

QT -= gui
QT += core
TEMPLATE = app
