//---------------------------------------------------------------------------

#ifndef mainH
#define mainH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <CheckLst.hpp>
#include <ComCtrls.hpp>
#include <ActnList.hpp>
#include <Menus.hpp>
#include <Dialogs.hpp>
//---------------------------------------------------------------------------
class TMainForm : public TForm
{
__published:	// IDE-managed Components
        TCheckListBox *ePakList;
        TEdit *eImagePath;
        TButton *eSelectImage;
        TButton *bStart;
        TEdit *eFilesPath;
        TButton *eSelectPath;
        TProgressBar *eCommonProgress;
        TProgressBar *ePakProgress;
        TStatusBar *eStatusBar;
        TPopupMenu *PakListMenu;
        TActionList *ActionList;
        TAction *ASelectNone;
        TMenuItem *AClearPakList1;
        TMenuItem *Selectall1;
        TAction *ASelectAll;
        TOpenDialog *OpenImageDialog;
        TCheckBox *eKeepTemp;
        void __fastcall bStartClick(TObject *Sender);
        void __fastcall ePakListClickCheck(TObject *Sender);
        void __fastcall ASelectNoneExecute(TObject *Sender);
        void __fastcall ASelectAllExecute(TObject *Sender);
        void __fastcall eSelectPathClick(TObject *Sender);
        void __fastcall eSelectImageClick(TObject *Sender);
        void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
        void __fastcall FormCreate(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TMainForm(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TMainForm *MainForm;
//---------------------------------------------------------------------------
#endif
