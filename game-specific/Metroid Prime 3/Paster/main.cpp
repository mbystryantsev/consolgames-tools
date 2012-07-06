//---------------------------------------------------------------------------

#include <vcl.h>
#include <windows.h>
#include <registry.hpp>
#include <io.h>
#include <iostream.h>
#pragma hdrstop

#include "Stream.h"
#include "FileStream.h"
#include "WiiStream.h"
#include "pak.h"

#include "main.h"

#pragma comment(lib,"openssl.lib")
#pragma comment(lib,"minilzo.lib")
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"

TMainForm *MainForm;
//---------------------------------------------------------------------------


struct pakrec
{
        char* name, *caption;
        bool checked;
};                  
pakrec paks[] = {
        {"Metroid1.pak", "Olympus, Valhalla", false},
        {"Metroid3.pak", "Bryyo", false},
        {"Metroid4.pak", "SkyTown", false},
        {"Metroid5.pak", "Pirate Homeworld", false},
        {"Metroid6.pak", "Phaaze", false},
        {"Metroid7.pak", "Seeds", false},
        {"Metroid8.pak", "Ship", false},
        {"GuiDVD.pak", NULL, true},
        {"GuiNAND.pak", NULL, true},
        {"Logbook.pak", NULL, true}, 
        {"FrontEnd.pak", NULL, true},
        {"NoARAM.pak", NULL, true},
        {"MiscData.pak", NULL, true},
        {"Worlds.pak", NULL, true},
        {"UniverseArea.pak", NULL, true}
};



__fastcall TMainForm::TMainForm(TComponent* Owner)
        : TForm(Owner)
{

        for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
        {
                if(!paks[i].caption)
                        ePakList->Items->Add(paks[i].name);
                else
                        ePakList->Items->Add((AnsiString)paks[i].name + (AnsiString)" - " + (AnsiString)paks[i].caption);
                ePakList->Checked[i] = paks[i].checked;
        }
        
}
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------


bool Progress(int act, int val, char* str)
{
        switch(act)
        {
                case PROGR_SET_MAX:
                        MainForm->ePakProgress->Position = 0;
                        MainForm->ePakProgress->Max = val;
                        break;
                case PROGR_SET_CUR:                          
                        MainForm->ePakProgress->Position = val;
                        break;
        }
        Application->ProcessMessages();
        return false;
}


char* dirs[] = {"F:\\Temp\\", NULL};


bool running = false;
bool brk;


class CFormProgressBox: CProgressBox
{
        TProgressBar* bar;
        TStatusPanel* panel;
public:
        CFormProgressBox(TProgressBar* progress_bar, TStatusPanel* status_panel):CProgressBox()
        {
                bar = progress_bar;
                panel = status_panel;
        }
	void SetPosition(int position)
        {
                bar->Position = position;      
                Application->ProcessMessages();
        }
	void SetRange(int start, int end)
        {
                bar->Min = start;
                bar->Max = end;
                Application->ProcessMessages();
        }
	void SetWindowMessage(const char* message)
        {
                panel->Text = message;
                Application->ProcessMessages();
        }
};

void __fastcall TMainForm::bStartClick(TObject *Sender)
{

        //f4c734a1e191c45e9ac037d92e14485d
        //7dd194ae92e2c409201740607339dd04 - problem
        if(running)
        {
                brk = true;
                return;
        }


        running = true;

        CFormProgressBox progress_box(ePakProgress, eStatusBar->Panels->Items[1]);


        //FILE *f = fopen("C:\\mp3c_p_log.txt", "w");

        //fprintf(f, "Init...\n");

        char srcdir[MAX_PATH];
        strcpy(srcdir, (char*)eFilesPath->Text.data());
        if(srcdir[strlen(srcdir) - 1] != '\\') strcat(srcdir, "\\");

        brk = false;
        dirs[0] = srcdir;
        ePakList->Enabled = false;
        char temp_path[MAX_PATH], file_path[MAX_PATH];
        GetTempPath(MAX_PATH, temp_path);

        AnsiString filename = eImagePath->Text;
        CWIIStream *image = new CWIIStream(filename.c_str());
        image->setDataPartition();

        int count = 0;
        for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
                if(paks[i].checked) count++;
        eCommonProgress->Max = count * 3;
        eCommonProgress->Position = 0;

        //fprintf(f, "Rebuild paks...\n");
        //fflush(f);

        for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
        {
                if(brk) break;
                if(!paks[i].checked) continue;
                
                //fprintf(f, "Pak %d - %s... ", i, paks[i].name);
                //fflush(f);

                CImageFileStream* file = image->FindFile(paks[i].name);
                if(!file)
                {
                //        fprintf(f, "not opened!\n");
                //        fflush(f);
                        continue;
                }


                //fprintf(f, "opened.\n");
                //fflush(f);

                eStatusBar->Panels->Items[0]->Text = paks[i].name;
                eCommonProgress->StepBy(1);
                Application->ProcessMessages();
                strcpy(file_path, temp_path);
                strcat(file_path, paks[i].name);

                //fprintf(f, "Opening out file %s...\n", file_path);
                //fflush(f);

                CFileStream *sf = new CFileStream(file_path, OF_CREATE);


                //fprintf(f, "Rebuilding...\n");
                //fflush(f);

                if(!PakRebuild(file, sf, dirs, NULL, &Progress)) ShowMessage("Failed!");


                //fprintf(f, "Closing.\n\n");
                //fflush(f);

                delete sf;
                delete file;
        }


        //fprintf(f, "Inserting into image...\n");
        //fflush(f);

        for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
        {
                if(brk) break;
                if(!paks[i].checked) continue;

                //fprintf(f, "File %s...\n", paks[i].name);
                //fflush(f);

                strcpy(file_path, temp_path);
                strcat(file_path, paks[i].name);
                eStatusBar->Panels->Items[0]->Text = paks[i].name;   
                eCommonProgress->StepBy(2);    
                Application->ProcessMessages();
                PNode node = image->getDisc()->m_pParent->FindFile(image->getDisc()->m_pParent->FindDataPartition(), paks[i].name);
                if(!node) continue;
                image->getDisc()->LoadDecryptedFile(file_path, image->getImage(), image->getDataPartition(), node->data.offset, node->data.size, node->data.fst_reference, (CProgressBox*)&progress_box);
                if(!eKeepTemp->Checked) DeleteFile(file_path);
                image->Reparse();
        }
        eCommonProgress->Position = count * 3;

        delete image;  
        ePakList->Enabled = true;

        running = false;

        //fprintf(f, "Completed!\n");
        //fflush(f);
        //fclose(f);
}
//---------------------------------------------------------------------------


void __fastcall TMainForm::ePakListClickCheck(TObject *Sender)
{
        paks[ePakList->ItemIndex].checked = ePakList->Checked[ePakList->ItemIndex];
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::ASelectNoneExecute(TObject *Sender)
{

        for(int i = 0; i < ePakList->Count; i++)
        {
                ePakList->Checked[i] = paks[i].checked = false;
        }

}
//---------------------------------------------------------------------------

void __fastcall TMainForm::ASelectAllExecute(TObject *Sender)
{

        for(int i = 0; i < ePakList->Count; i++)
        {
                ePakList->Checked[i] = paks[i].checked = true;
        }

}
//---------------------------------------------------------------------------

void __fastcall TMainForm::eSelectPathClick(TObject *Sender)
{
        //SHGetPathFromIDListA(
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::eSelectImageClick(TObject *Sender)
{

        OpenImageDialog->FileName = eImagePath->Text;
        if(!OpenImageDialog->Execute()) return;
        eImagePath->Text = OpenImageDialog->FileName;


}
//---------------------------------------------------------------------------

unsigned int getCheckedMask()
{

        unsigned int ret = 0;
        for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
                ret |= paks[i].checked << i;
        return ret;

}

void setCheckedMask(unsigned int v)
{

        for(int i = 0; i < sizeof(paks) / sizeof(pakrec); i++)
        {
                paks[i].checked = (v >> i) & 1;
                MainForm->ePakList->Checked[i] = paks[i].checked;
        }

}

void __fastcall TMainForm::FormClose(TObject *Sender, TCloseAction &Action)
{


  TRegistry *Reg = new TRegistry();
  Reg->RootKey = HKEY_LOCAL_MACHINE;
  Reg->LazyWrite = false;
  if(!Reg->KeyExists("SOFTWARE\\MetroidPrime3Paster"))
        Reg->CreateKey("SOFTWARE\\MetroidPrime3Paster");
  Reg->OpenKey("SOFTWARE\\MetroidPrime3Paster", true);
  //if(!Reg->KeyExists("Checked")) Reg->CreateKey("Checked");
  Reg->WriteInteger("Checked", getCheckedMask());
  //if(!Reg->KeyExists("Image")) Reg->CreateKey("Image");
  Reg->WriteString("Image", eImagePath->Text);
  //if(!Reg->KeyExists("Directory")) Reg->CreateKey("Directory");
  Reg->WriteString("Directory", eFilesPath->Text);

  Reg->CloseKey();
  delete Reg;

}
//---------------------------------------------------------------------------

void __fastcall TMainForm::FormCreate(TObject *Sender)
{

  TRegistry *Reg = new TRegistry();
  Reg->RootKey = HKEY_LOCAL_MACHINE;
  Reg->LazyWrite = false;
  if(!Reg->KeyExists("SOFTWARE\\MetroidPrime3Paster")) return;
  Reg->OpenKey("SOFTWARE\\MetroidPrime3Paster", true);

  if(Reg->ValueExists("Checked"))
  {
        int mask = Reg->ReadInteger("Checked");
        setCheckedMask(mask);
  }
  if(Reg->ValueExists("Image"))
        eImagePath->Text = Reg->ReadString("Image");
  if(Reg->ValueExists("Directory"))
        eFilesPath->Text = Reg->ReadString("Directory");
  Reg->CloseKey();
  delete Reg;
       
}
//---------------------------------------------------------------------------


