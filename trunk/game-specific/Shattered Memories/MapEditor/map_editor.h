//---------------------------------------------------------------------------

#ifndef map_editorH
#define map_editorH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ActnList.hpp>
#include <Menus.hpp>
#include <Dialogs.hpp>
//---------------------------------------------------------------------------
class TMainForm : public TForm
{
__published:	// IDE-managed Components
        TGroupBox *Layers;
        TComboBox *eLayers;
        TCheckBox *eCurOnly;
        TGroupBox *GroupBox1;
        TGroupBox *GroupBox2;
        TEdit *eCaption;
        TListBox *eCaptions;
        TCheckBox *eOnTop;
        TMainMenu *MainMenu1;
        TMenuItem *File1;
        TMenuItem *Open1;
        TMenuItem *Save1;
        TMenuItem *SaveAs1;
        TActionList *ActionList1;
        TAction *AOpen;
        TAction *ASave;
        TAction *ASaveAs;
        TGroupBox *GroupBox3;
        TEdit *eX;
        TEdit *eY;
        TEdit *eAngle;
        TEdit *eSize;
        TAction *AOnTop;
        TMenuItem *View1;
        TMenuItem *OnTop1;
        TAction *ACurOnly;
        TMenuItem *Showcurrentlayeronly1;
        TLabel *Label1;
        TLabel *Label2;
        TLabel *Label3;
        TLabel *Label4;
        TOpenDialog *OpenDialog;
        TSaveDialog *SaveDialog;
        TAction *ADeleteString;
        TComboBox *eColors;
        TLabel *Label5;
        TMenuItem *Edit1;
        TMenuItem *DeleteString1;
        TPopupMenu *PopupMenu;
        TMenuItem *DeleteString2;
        TAction *AInsertString;
        TButton *Button1;
        TMenuItem *InsertString1;
        TMenuItem *InsertString2;
        TMenuItem *Help1;
        TMenuItem *Hotkeys1;
        TMenuItem *About1;
        TAction *AViewMap;
        TMenuItem *AViewMap1;
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall AOnTopExecute(TObject *Sender);
        void __fastcall Showcurrentlayeronly1Click(TObject *Sender);  
        void __fastcall FloatKeyPress(TObject *Sender, char &Key);
        void __fastcall AOpenExecute(TObject *Sender);
        void __fastcall FormActivate(TObject *Sender);
        void __fastcall eLayersChange(TObject *Sender);
        void __fastcall ACurOnlyExecute(TObject *Sender);
        void __fastcall eCaptionsClick(TObject *Sender);
        void __fastcall eCaptionChange(TObject *Sender);
        void __fastcall ADeleteStringExecute(TObject *Sender);
        void __fastcall eXChange(TObject *Sender);
        void __fastcall eYChange(TObject *Sender);
        void __fastcall eSizeChange(TObject *Sender);
        void __fastcall eAngleChange(TObject *Sender);
        void __fastcall eColorsChange(TObject *Sender);
        void __fastcall AInsertStringExecute(TObject *Sender);
        void __fastcall Hotkeys1Click(TObject *Sender);
        void __fastcall About1Click(TObject *Sender);
        void __fastcall AViewMapExecute(TObject *Sender);
        void __fastcall ASaveExecute(TObject *Sender);
        void __fastcall ASaveAsExecute(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall TMainForm(TComponent* Owner);
        void __fastcall Open(String FileName);
        int __fastcall LoadFont(String FileName);
        void __fastcall Save(String FileName);
        String FFileName;
};
//---------------------------------------------------------------------------
extern PACKAGE TMainForm *MainForm;
//---------------------------------------------------------------------------
#endif
