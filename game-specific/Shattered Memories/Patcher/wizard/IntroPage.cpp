#include "IntroPage.h"
#include "PatchWizard.h"
#include "PatchSpec.h"
#include "Configurator.h"

IntroPage::IntroPage() : Page()
{
#if !defined(PRODUCTION)
	m_ui.introLabel->setText(m_ui.introLabel->text() + QString("\r\n\r\n")
		+ tr("ДАННАЯ ВЕРСИЯ ПАТЧА ПРЕДНАЗНАЧЕНА ТОЛЬКО ДЛЯ ВНУТРЕННЕГО ИСПОЛЬЗОВАНИЯ И ТЕСТИРОВАНИЯ ПЕРЕВОДА!"));
#endif

	const Configurator& configurator = Configurator::instance();
	const QString fullGameTitle = configurator.availablePlatforms().size() == 1
		? QString(tr("%1 для %2").arg(GAME_TITLE).arg(Configurator::platformName(*configurator.availablePlatforms().begin())))
		: QString(GAME_TITLE);

	const QString windowGameTitle = configurator.availablePlatforms().size() == 1
		? QString("%1 (%2)").arg(GAME_TITLE).arg(Configurator::platformAbbr(*configurator.availablePlatforms().begin()))
		: QString();

	setTitle(title().replace("{GAME_TITLE}", GAME_TITLE));
	setWindowTitle(windowTitle().replace("{GAME_TITLE}", windowGameTitle));
	m_ui.introLabel->setText(m_ui.introLabel->text().replace("{GAME_TITLE}", fullGameTitle));
}

int IntroPage::nextId() const 
{
	return PatchWizard::PageEula;
}