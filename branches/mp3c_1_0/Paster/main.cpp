#include "MainFrame.h"
#include "PasterThread.h"
#include <QApplication>
#include <QString>
#include <QSettings>

struct PakRecord
{
	const QString name;
	const QString caption;
	const bool defaultChecked;
};				  

static const PakRecord s_paks[] =
{
	{"Metroid1.pak",     "Olympus, Valhalla", false},
	{"Metroid3.pak",     "Bryyo",             false},
	{"Metroid4.pak",     "SkyTown",           false},
	{"Metroid5.pak",     "Pirate Homeworld",  false},
	{"Metroid6.pak",     "Phaaze",            false},
	{"Metroid7.pak",     "Seeds",             false},
	{"Metroid8.pak",     "Ship",              false},
	{"GuiDVD.pak",       "", true},
	{"GuiNAND.pak",      "", true},
	{"Logbook.pak",      "", true}, 
	{"FrontEnd.pak",     "", true},
	{"NoARAM.pak",       "", true},
	{"MiscData.pak",     "", true},
	{"Worlds.pak",       "", true},
	{"UniverseArea.pak", "", true}
};

static bool operator==(const PakRecord& rec, const QString& pakName)
{
	return rec.name == pakName;
}

void initPakList(MainFrame& mainFrame)
{
	QSettings settings;

	const QString selectedPaksKey = "selectedPaks";
	if (settings.contains(selectedPaksKey))
	{
		const QStringList selectedPaks = settings.value(selectedPaksKey).toStringList();

		for (int i = 0; i < _countof(s_paks); i++)
		{
			mainFrame.addPak(s_paks[i].name, s_paks[i].caption, selectedPaks.contains(s_paks[i].name));
		}
		return;
	}

	for (int i = 0; i < _countof(s_paks); i++)
	{
		mainFrame.addPak(s_paks[i].name, s_paks[i].caption, s_paks[i].defaultChecked);
	}	
}

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);
	QApplication::setOrganizationName("Consolgames");
	QApplication::setOrganizationDomain("consolgames.ru");
	QApplication::setApplicationName("MP3C Data Paster");

	MainFrame mainFrame;
	initPakList(mainFrame);
	mainFrame.show();
	return app.exec();
}


// char* dirs[] = {"F:\\Temp\\", NULL};
// 
// 
// bool running = false;
// bool brk;
// 

// 
// void __fastcall TMainForm::bStartClick(TObject *Sender)
// {
// 
// 		//f4c734a1e191c45e9ac037d92e14485d
// 		//7dd194ae92e2c409201740607339dd04 - problem
// 		if(running)
// 		{
// 				brk = true;
// 				return;
// 		}
// 
// 
// 		running = true;
// 
// 		CFormProgressBox progress_box(ePakProgress, eStatusBar->Panels->Items[1]);
// 
// 		char srcdir[MAX_PATH];
// 		strcpy(srcdir, (char*)eFilesPath->Text.data());
// 		if(srcdir[strlen(srcdir) - 1] != '\\') strcat(srcdir, "\\");
// 
// 		brk = false;
// 		dirs[0] = srcdir;
// 		ePakList->Enabled = false;
// 		char temp_path[MAX_PATH], file_path[MAX_PATH];
// 		GetTempPath(MAX_PATH, temp_path);
// 
// 		AnsiString filename = eImagePath->Text;
// 		CWIIStream *image = new CWIIStream(filename.c_str());
// 		image->setDataPartition();
// 
// 		int count = 0;
// 		for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
// 				if(paks[i].checked) count++;
// 		eCommonProgress->Max = count * 3;
// 		eCommonProgress->Position = 0;
// 
// 
// 
// 		for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
// 		{
// 				if(brk) break;
// 				if(!paks[i].checked) continue;
// 
// 				CImageFileStream* file = image->FindFile(paks[i].name);
// 				if(!file)
// 				{
// 						continue;
// 				}
// 
// 
// 				eStatusBar->Panels->Items[0]->Text = paks[i].name;
// 				eCommonProgress->StepBy(1);
// 				Application->ProcessMessages();
// 				strcpy(file_path, temp_path);
// 				strcat(file_path, paks[i].name);
// 
// 				CFileStream *sf = new CFileStream(file_path, OF_CREATE);
// 
// 				if(!PakRebuild(file, sf, dirs, NULL, &Progress)) ShowMessage("Failed!");
// 
// 				delete sf;
// 				delete file;
// 		}
// 
// 		for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
// 		{
// 				if(brk) break;
// 				if(!paks[i].checked) continue;
// 
// 				strcpy(file_path, temp_path);
// 				strcat(file_path, paks[i].name);
// 				eStatusBar->Panels->Items[0]->Text = paks[i].name;   
// 				eCommonProgress->StepBy(2);	
// 				Application->ProcessMessages();
// 				PNode node = image->getDisc()->m_pParent->FindFile(image->getDisc()->m_pParent->FindDataPartition(), paks[i].name);
// 				if(!node) continue;
// 				image->getDisc()->LoadDecryptedFile(file_path, image->getImage(), image->getDataPartition(), node->data.offset, node->data.size, node->data.fst_reference, (CProgressBox*)&progress_box);
// 				if(!eKeepTemp->Checked) DeleteFile(file_path);
// 				image->Reparse();
// 		}
// 		eCommonProgress->Position = count * 3;
// 
// 		delete image;  
// 		ePakList->Enabled = true;
// 
// 		running = false;
// }

// unsigned int getCheckedMask()
// {
// 
// 		unsigned int ret = 0;
// 		for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
// 				ret |= paks[i].checked << i;
// 		return ret;
// 
// }
// 
// void setCheckedMask(unsigned int v)
// {
// 
// 		for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
// 		{
// 				paks[i].checked = (v >> i) & 1;
// 				MainForm->ePakList->Checked[i] = paks[i].checked;
// 		}
// 
// }
// 
// void __fastcall TMainForm::FormClose(TObject *Sender, TCloseAction &Action)
// {
// 
// 
//   TRegistry *Reg = new TRegistry();
//   Reg->RootKey = HKEY_LOCAL_MACHINE;
//   Reg->LazyWrite = false;
//   if(!Reg->KeyExists("SOFTWARE\\MetroidPrime3Paster"))
// 		Reg->CreateKey("SOFTWARE\\MetroidPrime3Paster");
//   Reg->OpenKey("SOFTWARE\\MetroidPrime3Paster", true);
//   Reg->WriteInteger("Checked", getCheckedMask());
//   Reg->WriteString("Image", eImagePath->Text);
//   Reg->WriteString("Directory", eFilesPath->Text);
// 
//   Reg->CloseKey();
//   delete Reg;
// }
// 
// void __fastcall TMainForm::FormCreate(TObject *Sender)
// {
// 
//   TRegistry *Reg = new TRegistry();
//   Reg->RootKey = HKEY_LOCAL_MACHINE;
//   Reg->LazyWrite = false;
//   if(!Reg->KeyExists("SOFTWARE\\MetroidPrime3Paster")) return;
//   Reg->OpenKey("SOFTWARE\\MetroidPrime3Paster", true);
// 
//   if(Reg->ValueExists("Checked"))
//   {
// 		int mask = Reg->ReadInteger("Checked");
// 		setCheckedMask(mask);
//   }
//   if(Reg->ValueExists("Image"))
// 		eImagePath->Text = Reg->ReadString("Image");
//   if(Reg->ValueExists("Directory"))
// 		eFilesPath->Text = Reg->ReadString("Directory");
//   Reg->CloseKey();
//   delete Reg;
// 	   
// }
