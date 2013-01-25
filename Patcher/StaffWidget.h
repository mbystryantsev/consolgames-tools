#pragma once
#include <QWidget>
#include <QPropertyAnimation>
#include <QTimer>

class TransparentLabel;

class StaffWidget : public QWidget
{
	Q_OBJECT

public:
	StaffWidget(QWidget* parent = NULL);
	Q_SLOT void start();
	Q_SLOT void stop();

private:
	void loadStaff();

private:
	struct StaffItem
	{
		QString category;
		QStringList members;
	};

	enum MainState
	{
		Uninitialized,
		IntroFadeIn,
		IntroDelay,
		IntroFadeOut,
		CategoryWaitingForNext,
		CategoryFadeIn,
		CategoryDelay,
		CategoryFadeOut,
		Reinitializing,
		Stop
	};

	enum NameState
	{
		NameUninitialized,
		NameFadeIn,
		NameDelay,
		NameFadeOut,
		NameWaitingForNext,
		NameStop
	};

private:
	void initialize();
	Q_SLOT void processCategoryAnimationState();
	Q_SLOT void processNameAnimationState();
	bool fetchNextCategory();
	bool fetchNextName();

private:
	MainState m_categoryState;
	NameState m_nameState;
	QString m_introLine;
	QList<StaffItem> m_staff;
	TransparentLabel* m_categoryLabel;
	TransparentLabel* m_nameLabel;
	QPropertyAnimation m_categoryAnimation;
	QPropertyAnimation m_nameAnimation;
	QTimer m_categoryTimer;
	QTimer m_nameTimer;
	QList<StaffItem>::ConstIterator m_categoryIterator;
	const StaffItem* m_currentCategory;
	QStringList::ConstIterator m_nameIterator;

	static const int s_animationDuration;
	static const int s_delayDuration;
	static const int s_introDuration;
	static const int s_reinitializingDelay;
	static const int s_categoryInterval;
	static const int s_nameInterval;
	static const int s_nameAppearingDelta;
};
