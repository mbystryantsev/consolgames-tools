#include "PatcherWorker.h"
#include <vector>
#include <string>
#include <QDir>
#include <QThread>
#include <QApplication>

LOG_CATEGORY("PatcherWorker");

ProgressHandler::ProgressHandler()
: QObject()
, m_stopRequested(false)
{

}

void ProgressHandler::init(int size)
{
	emit progressInit(size);
	m_timer.start();
}

void ProgressHandler::progress(int value, const char* message)
{
	emit progressChanged(value, message);

	if (m_timer.elapsed() >= 300)
	{
		m_timer.restart();
		QApplication::processEvents();
	}
}

void ProgressHandler::finish()
{
	emit progressFinish();
}

bool ProgressHandler::stopRequested()
{
	return m_stopRequested;
}

void ProgressHandler::requestStop()
{
	m_stopRequested = true;
}

//////////////////////////////////////////////////////////////////////////

const QString PatcherWorker::s_paksDirName = "~cgmp3c";
QStringList PatcherWorker::s_pakList;

PatcherWorker::PatcherWorker()
	: QObject()
	, m_tempDirCreated(false)
{
	if (s_pakList.isEmpty())
	{
		s_pakList
#if !defined(_DEBUG) || defined(ALL_PAKS_IN_DEBUG)
			<< "Metroid1.pak"
			<< "Metroid3.pak"
			<< "Metroid4.pak"
			<< "Metroid5.pak"
			<< "Metroid6.pak"
			<< "Metroid7.pak"
#endif
			<< "Metroid8.pak"
			<< "GuiDVD.pak"
			<< "GuiNAND.pak"
			<< "Logbook.pak"
			<< "FrontEnd.pak"
			<< "NoARAM.pak"
			<< "MiscData.pak"
			<< "Worlds.pak"
			<< "UniverseArea.pak";
	}

	VERIFY(connect(&m_actionProgressHandler, SIGNAL(progressInit(int)), SIGNAL(actionInit(int))));
	VERIFY(connect(&m_actionProgressHandler, SIGNAL(progressChanged(int, const QString&)), SIGNAL(actionProgress(int, const QString&))));
	VERIFY(connect(&m_actionProgressHandler, SIGNAL(progressFinish()), SIGNAL(actionFinish())));
	VERIFY(connect(&m_subActionProgressHandler, SIGNAL(progressInit(int)), SIGNAL(subActionInit(int))));
	VERIFY(connect(&m_subActionProgressHandler, SIGNAL(progressChanged(int, const QString&)), SIGNAL(subActionProgress(int, const QString&))));
	VERIFY(connect(&m_subActionProgressHandler, SIGNAL(progressFinish()), SIGNAL(subActionFinish())));
}

PatcherWorker::~PatcherWorker()
{
	DLOG << "Worker destroyed";
}

void PatcherWorker::setImagePath(const QString& path)
{
	ASSERT(thread() == QThread::currentThread());
	m_imagePath = QDir::toNativeSeparators(path);
}

void PatcherWorker::addResourcesPath(const QString& path)
{
	ASSERT(thread() == QThread::currentThread());
	m_resourcesPaths << path;
}

void PatcherWorker::setTempPath(const QString& path)
{
	ASSERT(thread() == QThread::currentThread());
	m_tempPath = path;
	m_pakTempPath = QDir::toNativeSeparators(QDir(path + "/" + s_paksDirName).absolutePath());
}

//////////////////////////////////////////////////////////////////////////

void PatcherWorker::initialize()
{
	ASSERT(thread() == QThread::currentThread());
	m_paster.reset(new DataPaster(m_imagePath));
	m_paster->setActionProgressHandler(&m_actionProgressHandler);
	m_paster->setProgressHandler(&m_subActionProgressHandler);

	if (!m_paster->open())
	{
		if (m_paster->errorCode() == DataPaster::Open_InvalidDiscId)
		{
			return processError(
				QString::fromLocal8Bit("Выбран неверный бэкап-образ."),
				QString::fromLocal8Bit("Убедитесь, что выбран бэкап-образ игры Metrpoid Prime 3: Corruption для PAL-региона."));
		}
		return processError(
			QString::fromLocal8Bit("Невозможно открыть файл образа."),
			QString::fromLocal8Bit("Убедитесь, что указан правильный путь к файлу бэкап-образа и он доступен для записи.")
		);
	}
	
	emit stepCompleted();
}

void PatcherWorker::rebuildPaks()
{
	if (!QDir(m_pakTempPath).exists())
	{
		if (!QDir().mkpath(m_pakTempPath))
		{
			return processError(
				QString::fromLocal8Bit("Невозможно создать директорию для временных файлов."),
				QString::fromLocal8Bit("Убедитесь, что у Вас достаточно прав для записи в выбранную директорию.")
			);
		}
		m_tempDirCreated = true;
	}

	ASSERT(thread() == QThread::currentThread());
	
	std::vector<std::string> inputDirs;
	inputDirs.reserve(m_resourcesPaths.size());
	foreach (const QString& path, m_resourcesPaths)
	{
		inputDirs.push_back(path.toStdString());
	}

	if (!m_paster->rebuildPaks(s_pakList, inputDirs, m_pakTempPath))
	{
		return processError(
			QString::fromLocal8Bit("Ошибка при обработке файлов игры."),
			QString::fromLocal8Bit("")
		);
	}

	emit stepCompleted();
}

void PatcherWorker::checkData()
{	
	ASSERT(thread() == QThread::currentThread());
	if (!m_paster->checkData(s_pakList, m_resourcesPaths, m_pakTempPath, m_pakTempPath))
	{
		return processError(
			QString::fromLocal8Bit("Файлы игры не прошли проверку на правильность установки патча."),
			QString::fromLocal8Bit("")
		);
	}

	emit stepCompleted();
}

void PatcherWorker::replacePaks()
{
	ASSERT(thread() == QThread::currentThread());
	if (!m_paster->replacePaks(s_pakList, m_pakTempPath))
	{
		return processError(
			QString::fromLocal8Bit("Ошибка при замене данных в бэкап-образе."),
			QString::fromLocal8Bit("")
		);
	}

	emit stepCompleted();
}

void PatcherWorker::checkPaks()
{
	ASSERT(thread() == QThread::currentThread());
	if (!m_paster->checkPaks(s_pakList, m_pakTempPath))
	{
		return processError(
			QString::fromLocal8Bit("Бэкап-образ не прошёл проверку на правильность установки патча."),
			QString::fromLocal8Bit("")
		);
	}

	emit stepCompleted();
}

void PatcherWorker::checkImage()
{
	ASSERT(thread() == QThread::currentThread());
	if (!m_paster->checkImage())
	{
		return processError(
			QString::fromLocal8Bit("Бэкап-образ не прошёл проверку на правильность установки патча."),
			QString::fromLocal8Bit("")
		);
	}

	emit stepCompleted();
}

void PatcherWorker::finalize()
{
	ASSERT(thread() == QThread::currentThread());
	emit stepCompleted();
	finalizeInternal();
}

void PatcherWorker::requestStop()
{
	VERIFY(QMetaObject::invokeMethod(&m_actionProgressHandler, "requestStop", Qt::QueuedConnection));
	VERIFY(QMetaObject::invokeMethod(&m_subActionProgressHandler, "requestStop", Qt::QueuedConnection));
	DLOG << "Stop requested";
}

void PatcherWorker::processError(const QString& errorMessage, const QString& description)
{
	ASSERT(thread() == QThread::currentThread());
	emit stepFailed(m_paster->errorCode(), m_paster->errorData(), errorMessage, description);
	m_paster->resetProgressHandlers();
	finalizeInternal();
}

void PatcherWorker::finalizeInternal()
{
	ASSERT(thread() == QThread::currentThread());
	if (m_paster.get() == NULL)
	{
		return;
	}

	removeTempFiles();
	m_paster.reset();
}

void PatcherWorker::removeTempFiles()
{
	DLOG << "removeTempFiles executed";
	ASSERT(thread() == QThread::currentThread());
	if (!m_paster->removeTempFiles(m_pakTempPath))
	{
		DLOG << "Unable to delete temporary files!";
	}
}
