//---------------------------------------------------------------------------
                   
#include "gldraw.h"
#include <vcl.h>

#include "map_editor.h"
//#include "application.h"
#include "MapForm.h"
#include "map.h"
#include "font.h"
#include "stdio.h"
#include "gl\gl.h"
#include "gl\glu.h"

#pragma hdrstop
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TMainForm *MainForm;
//CApplication *app;
CMap map;
bool EditAllow = false;
SCaption UndoCaption;
int CaptionIndex = -1;


/*
void __fastcall TMainForm::FillCaptions(int layer){

}
*/

void __fastcall TMainForm::Open(String FileName){

  int i;
  SColor* c;
  FFileName = FileName;
  map.LoadFromFile((char*)FileName.data());

  eLayers->Enabled = true;
  eLayers->Clear();
  for(i = 0; i < map.getLayerCount(); i++){
    //eLayers->Items->Add("Layer " + IntToStr(i));
    eLayers->Items->Add((char*)map.layers[i]->name.data());
  }
  eLayers->ItemIndex = 0;
  eCaptions->Enabled = true;
  eCaption->Enabled = true;
  ASaveAs->Enabled = true;
  ASave->Enabled = true;

  eColors->Clear();
  for(i = 0; i < map.getColorCount(); i++){
    c = &map.colors[i];
    eColors->Items->Add(IntToHex(i, 2) + " #" + IntToHex(c->r, 2)
      + IntToHex(c->g, 2) + IntToHex(c->b, 2) + IntToHex(c->a, 2));
  }
              
  eLayersChange(NULL);
  FormMap->Show();

}

void __fastcall TMainForm::Save(String FileName){
  FFileName = FileName;
  map.SaveToFile((char*)FileName.data());
}

//---------------------------------------------------------------------------

LRESULT CALLBACK FWndProc( HWND  hWnd,
    UINT  uMsg,
    WPARAM  wParam,
    LPARAM  lParam)
{
  return 0;
}


__fastcall TMainForm::TMainForm(TComponent* Owner)
        : TForm(Owner)
{

}
//---------------------------------------------------------------------------
void __fastcall TMainForm::Button1Click(TObject *Sender)
{
      if(eLayers->ItemIndex < 0 || eCaptions->ItemIndex < 0) return;
      map.layers[eLayers->ItemIndex]->captions[eCaptions->ItemIndex] = UndoCaption;
      eCaptionsClick(NULL);
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::AOnTopExecute(TObject *Sender)
{
        AOnTop->Checked = !AOnTop->Checked;
        MainForm->FormStyle = AOnTop->Checked ? fsStayOnTop : fsNormal;
}
//---------------------------------------------------------------------------
void __fastcall TMainForm::Showcurrentlayeronly1Click(TObject *Sender)
{
        ACurOnly->Checked = !ACurOnly->Checked;
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::FloatKeyPress(TObject *Sender, char &Key){
        if(Key == '.') Key = ',';
        if(Key >= ' ' && ((Key < '0' || Key > '9') && Key != ',')) Key = 0;
}





void __fastcall TMainForm::AOpenExecute(TObject *Sender)
{
    if(!OpenDialog->Execute()) return;
    Open(OpenDialog->FileName);
    //map.SaveToFile("test.rws"); 
    //ShowMessage(IntToHex(map.getMapSize(), 8));
}
//---------------------------------------------------------------------------





void __fastcall TMainForm::FormActivate(TObject *Sender)
{
        FormMap->map = &map;
        //if(FileExists(DEFAULT_MAP_FILE)) MainForm->Open(DEFAULT_MAP_FILE);
}
//---------------------------------------------------------------------------



void __fastcall TMainForm::eLayersChange(TObject *Sender)
{
    int i, l;
    //EditAllow = false;
    eCaptions->Clear();
    if((l = eLayers->ItemIndex) < 0) return;
    for(i = 0; i < map.layers[l]->getCaptionCount(); i++){
      eCaptions->Items->Add(AnsiString((char*)map.layers[l]->names[i]->data()));
    }
    if(map.layers[l]->getCaptionCount()){
      if(CaptionIndex == -1)  eCaptions->ItemIndex = 0;
      else eCaptions->ItemIndex = CaptionIndex;
      eCaptionsClick(NULL);
    }
    FormMap->FormPaint(NULL);
    CaptionIndex = -1;
    //EditAllow = true;
}
//---------------------------------------------------------------------------

int GREY_PALETTE[] = {
        0x00000000, 0x11FFFFFF, 0x22FFFFFF, 0x33FFFFFF,
        0x44FFFFFF, 0x55FFFFFF, 0x66FFFFFF, 0x77FFFFFF,
        0x88FFFFFF, 0x99FFFFFF, 0xAAFFFFFF, 0xBBFFFFFF,
        0xCCFFFFFF, 0xDDFFFFFF, 0xEEFFFFFF, 0xFFFFFFFF
};

extern SCharData* chars;
extern int char_count;
extern CGLDraw draw;
int __fastcall TMainForm::LoadFont(String FileName){
    FILE* f;
    f = fopen((char*)FileName.data(), "rb");
    fseek(f, 0, SEEK_END);
    int size = ftell(f);
    fseek(f, 0, SEEK_SET);
    SFontHeader header;
    fread(&header, sizeof(header), 1, f);
    fseek(f, 48, SEEK_SET);
    chars = (SCharData*)malloc(sizeof(SCharData) * header.count);
    fread(chars, sizeof(SCharData) * header.count, 1, f);
    char_count = header.count;
    //int font_height = header.height;

    size = size - ftell(f);
    char *tbuf = (char*)malloc(size);
    fread(tbuf, size, 1, f);
    fclose(f);

    int* img = (int*)malloc(512 * 512 * 4);
    int i;
    memset(img, 0, 4 * 512 * 512);
    for(i = 0; i < header.count && i < 256; i++){
      DecodeChar(img + (i / 16) * 512 * 32 + (i % 16) * 32, 512, chars[i].w,
      chars[i].h, header.height + chars[i].y, tbuf + chars[i].pos, chars[i].size, GREY_PALETTE);
    }
    int font_tex = draw.AddTexture(512, 512, img, DRAW_COLOR_RGBA);
    free(img);
    free(tbuf);
    return font_tex;
}
void __fastcall TMainForm::ACurOnlyExecute(TObject *Sender)
{
    ACurOnly->Checked = !ACurOnly->Checked; 
    FormMap->FormPaint(NULL);
}
//---------------------------------------------------------------------------

SCaption* cur_capt;
void __fastcall TMainForm::eCaptionsClick(TObject *Sender)
{
    cur_capt = 0;
    EditAllow = false;
    if(eCaptions->ItemIndex >= 0){
      cur_capt = &map.layers[eLayers->ItemIndex]->captions[eCaptions->ItemIndex];
      UndoCaption = *cur_capt;
      eCaption->Text = (char*)map.layers[eLayers->ItemIndex]->names[eCaptions->ItemIndex]->data();
      FormMap->FormPaint(NULL);
      eX->Text = FloatToStr(cur_capt->x);
      eY->Text = FloatToStr(cur_capt->y);
      eSize->Text = FloatToStr(cur_capt->scale);
      eAngle->Text = FloatToStr(cur_capt->angle);
      eColors->ItemIndex = cur_capt->color;
    }
    EditAllow = true;
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::eCaptionChange(TObject *Sender)
{
    if(!EditAllow) return;
    int cur = eCaptions->ItemIndex;
    if(cur < 0) return;
    int layer = eLayers->ItemIndex;
    if(layer < 0) return;
    EditAllow = false;
    if(eCaption->Text.data())
      map.layers[layer]->names[cur]->assign((char*)eCaption->Text.data());
    else
      map.layers[layer]->names[cur]->assign("");
    eCaptions->Items->Strings[cur] = eCaption->Text;
    EditAllow = true;
    FormMap->FormPaint(NULL);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::ADeleteStringExecute(TObject *Sender)
{
  if(eCaptions->ItemIndex < 0 || eLayers->ItemIndex < 0) return;
  map.layers[eLayers->ItemIndex]->DeleteCaption(eCaptions->ItemIndex);
  CaptionIndex = eCaptions->ItemIndex;
  if(CaptionIndex >= map.layers[eLayers->ItemIndex]->getCaptionCount())
    CaptionIndex = map.layers[eLayers->ItemIndex]->getCaptionCount() - 1;
  eLayersChange(NULL);
}
//---------------------------------------------------------------------------




void __fastcall TMainForm::eXChange(TObject *Sender)
{
    if(cur_capt && EditAllow){
      if(eX->Text == "") cur_capt->x = 0;
      else               cur_capt->x = StrToFloat(eX->Text);
      FormMap->FormPaint(NULL);
    }
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::eYChange(TObject *Sender)
{
    if(cur_capt && EditAllow){
      if(eY->Text == "") cur_capt->y = 0;
      else               cur_capt->y = StrToFloat(eY->Text);
      FormMap->FormPaint(NULL);
    }
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::eSizeChange(TObject *Sender)
{
    if(cur_capt && EditAllow){
      if(eSize->Text == "") cur_capt->scale = 1;
      else               cur_capt->scale = StrToFloat(eSize->Text);
      FormMap->FormPaint(NULL);
    }
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::eAngleChange(TObject *Sender)
{
   if(cur_capt && EditAllow){
      if(eAngle->Text == "") cur_capt->angle = 0;
      else               cur_capt->angle = StrToFloat(eAngle->Text);
      FormMap->FormPaint(NULL);
    }
        
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::eColorsChange(TObject *Sender)
{
    if(cur_capt && EditAllow){
      cur_capt->color = eColors->ItemIndex;  
      FormMap->FormPaint(NULL);
    }
}
//---------------------------------------------------------------------------


void __fastcall TMainForm::AInsertStringExecute(TObject *Sender)
{
  if(eCaptions->ItemIndex < -1 || eLayers->ItemIndex < 0) return;
  if(eCaptions->ItemIndex == -1){
    map.layers[eLayers->ItemIndex]->InsertCaption(-1);
    CaptionIndex = 0;
  } else {
    map.layers[eLayers->ItemIndex]->InsertCaption(eCaptions->ItemIndex);
    CaptionIndex = eCaptions->ItemIndex + 1;
  }
  eLayersChange(NULL);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::Hotkeys1Click(TObject *Sender)
{
    ShowMessage("Left Mouse Button + Mouse Move - move map\n"
                "Mouse Wheel - scale change\n"
                "Right Mouse Button + Mouse Move - move caption\n"
                "Shift + Mouse Wheel - font size");
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::About1Click(TObject *Sender)
{
  ShowMessage("Silent Hill: Shattered Memories Map Editor by HoRRoR\n"
              "ho-rr-or@mail.ru, http://consolgames.ru/");
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::AViewMapExecute(TObject *Sender)
{
    if(FormMap->Showing) FormMap->Hide();
    else FormMap->Show();
}
//---------------------------------------------------------------------------



void __fastcall TMainForm::ASaveExecute(TObject *Sender)
{
  if(FFileName != "") Save(FFileName);
}
//---------------------------------------------------------------------------

void __fastcall TMainForm::ASaveAsExecute(TObject *Sender)
{
  SaveDialog->FileName = FFileName;
  if(!SaveDialog->Execute()) return;
  Save(SaveDialog->FileName);
}
//---------------------------------------------------------------------------

