#include "StaffWidget.h"
#include "TransparentLabel.h"
#include <core.h>
#include <QTextStream>
#include <QFile>
#include <QVBoxLayout>

const int StaffWidget::s_animationDuration = 1000;
const int StaffWidget::s_delayDuration = 2500;
const int StaffWidget::s_introDuration = 3000;
const int StaffWidget::s_reinitializingDelay = 5000;
const int StaffWidget::s_categoryInterval = 800;
const int StaffWidget::s_nameInterval = 700;
const int StaffWidget::s_nameAppearingDelta = 1000;

StaffWidget::StaffWidget(QWidget* parent)
	: QWidget(parent)
	, m_categoryState(Uninitialized)
	, m_nameState(NameUninitialized)
	, m_currentCategory(NULL)
{
	loadStaff();

	QVBoxLayout* layout = new QVBoxLayout(this);

	m_categoryLabel = new TransparentLabel(this);
	QFont font = m_categoryLabel->font();
	font.setBold(true);
	m_categoryLabel->setFont(font);
	m_categoryLabel->setAlignment(Qt::AlignCenter);
	m_nameLabel = new TransparentLabel(this);
	m_nameLabel->setAlignment(Qt::AlignCenter);
	layout->addWidget(m_categoryLabel);
	layout->addWidget(m_nameLabel);
	setLayout(layout);

	m_categoryTimer.setSingleShot(true);
	m_nameTimer.setSingleShot(true);
	VERIFY(connect(&m_categoryAnimation, SIGNAL(finished()), SLOT(processCategoryAnimationState()), Qt::QueuedConnection));
	VERIFY(connect(&m_categoryTimer, SIGNAL(timeout()), SLOT(processCategoryAnimationState()), Qt::QueuedConnection));
	VERIFY(connect(&m_nameAnimation, SIGNAL(finished()), SLOT(processNameAnimationState()), Qt::QueuedConnection));
	VERIFY(connect(&m_nameTimer, SIGNAL(timeout()), SLOT(processNameAnimationState()), Qt::QueuedConnection));
}

void StaffWidget::loadStaff()
{
	QFile staffFile(":/staff.txt");
	VERIFY(staffFile.open(QIODevice::ReadOnly | QIODevice::Text));
	QTextStream textStream(&staffFile);
	m_introLine = textStream.readLine();

	while (!textStream.atEnd())
	{
		textStream.skipWhiteSpace();
		StaffItem item;
		item.category = textStream.readLine().trimmed();
		while (true)
		{
			const QString name = textStream.readLine().trimmed();
			if (name.isEmpty())
			{
				break;
			}
			item.members << name;
		}
		m_staff << item;
	}
}

void StaffWidget::start()
{
	DLOG << "Staff started";
	initialize();
}

void StaffWidget::stop()
{
	DLOG << "Staff stopped";
	m_categoryState = Stop;
	m_nameState = NameStop;
}

void StaffWidget::initialize()
{	
	ASSERT(!m_staff.isEmpty());
	m_categoryIterator = m_staff.constBegin();

	ASSERT(!m_staff.first().members.isEmpty());
	m_nameIterator = m_staff.first().members.constBegin();

	m_categoryLabel->setText(m_introLine);
	m_categoryLabel->setOpacity(0);
	m_nameLabel->setOpacity(0);
	m_nameLabel->setVisible(false);

	m_categoryAnimation.setDirection(QPropertyAnimation::Forward);
	m_categoryAnimation.setTargetObject(m_categoryLabel);
	m_categoryAnimation.setPropertyName("opacity");
	m_categoryAnimation.setStartValue(0.0);
	m_categoryAnimation.setEndValue(1.0);
	m_categoryAnimation.setDuration(s_animationDuration);
	m_categoryAnimation.start();

	m_nameAnimation.setTargetObject(m_nameLabel);
	m_nameAnimation.setPropertyName("opacity");
	m_nameAnimation.setStartValue(0.0);
	m_nameAnimation.setEndValue(1.0);
	m_nameAnimation.setDuration(s_animationDuration);
	m_categoryAnimation.setDuration(s_animationDuration);
	m_nameState = NameUninitialized;

	m_categoryState = IntroFadeIn;
}

void StaffWidget::processCategoryAnimationState()
{
	if (m_categoryState == Uninitialized)
	{
		initialize();
	}
	else if (m_categoryState == IntroFadeIn)
	{
		m_categoryTimer.start(s_introDuration);
		m_categoryState = IntroDelay;
	}
	else if (m_categoryState == IntroDelay)
	{
		m_categoryAnimation.setDirection(QPropertyAnimation::Backward);
		m_categoryAnimation.start();
		m_categoryState = IntroFadeOut;
	}
	else if (m_categoryState == IntroFadeOut)
	{
		m_categoryTimer.start(s_categoryInterval);
		m_nameLabel->setVisible(true);
		m_categoryState = CategoryWaitingForNext;
	}
	else if (m_categoryState == CategoryWaitingForNext)
	{
		if (!fetchNextCategory())
		{
			m_categoryState = Reinitializing;
			m_categoryTimer.start(0);
			return;
		}
		m_categoryAnimation.setDirection(QPropertyAnimation::Forward);
		m_categoryAnimation.start();
		m_nameTimer.start(s_nameAppearingDelta);
		m_categoryState = CategoryFadeIn;
	}
	else if (m_categoryState == CategoryFadeIn)
	{
		m_categoryState = CategoryDelay;
	}
	else if (m_categoryState == CategoryDelay)
	{
		m_categoryAnimation.setDirection(QPropertyAnimation::Backward);
		m_categoryAnimation.start();
		m_categoryState = CategoryFadeOut;
	}
	else if (m_categoryState == CategoryFadeOut)
	{
		m_categoryTimer.start(s_categoryInterval);
		m_categoryState = CategoryWaitingForNext;
	}
	else if (m_categoryState == Reinitializing)
	{
		m_categoryTimer.start(s_introDuration);
		m_categoryState = Uninitialized;
	}
	else if (m_categoryState == Stop)
	{
		m_categoryState = Uninitialized;
	}
	else
	{
		ASSERT(!"Invalid category state!");
	}
}

void StaffWidget::processNameAnimationState()
{
	if (m_nameState == NameUninitialized)
	{
		if (!fetchNextName())
		{
			m_categoryTimer.start(0);
			return;
		}
		m_nameAnimation.setDirection(QPropertyAnimation::Forward);
		m_nameAnimation.start();
		m_nameState = NameFadeIn;
	}
	else if (m_nameState == NameFadeIn)
	{
		m_nameTimer.start(s_delayDuration);
		m_nameState = NameDelay;
	}
	else if (m_nameState == NameDelay)
	{
		m_nameAnimation.setDirection(QPropertyAnimation::Backward);
		m_nameAnimation.start();
		m_nameState = NameFadeOut;
	}
	else if (m_nameState == NameFadeOut)
	{
		m_nameTimer.start(m_nameIterator == m_currentCategory->members.end() ? 0 : s_nameInterval);
		m_nameState = NameUninitialized;
	}
	else if (m_nameState == Stop)
	{
		m_nameState = NameUninitialized;
	}
	else
	{
		ASSERT("!Invalid name state!");
	}
}

bool StaffWidget::fetchNextCategory()
{
	if (m_categoryIterator == m_staff.end())
	{
		return false;
	}
	m_categoryLabel->setText(m_categoryIterator->category);
	m_currentCategory = &(*m_categoryIterator);
	m_categoryIterator++;
	m_nameIterator = m_currentCategory->members.constBegin();
	return true;
}

bool StaffWidget::fetchNextName()
{
	ASSERT(m_currentCategory != NULL);
	if (m_nameIterator == m_currentCategory->members.end())
	{
		return false;
	}

	m_nameLabel->setText(*m_nameIterator);
	m_nameIterator++;
	return true;
}
