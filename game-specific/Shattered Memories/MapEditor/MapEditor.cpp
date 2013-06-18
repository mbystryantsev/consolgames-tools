//---------------------------------------------------------------------------
#define DEFAULT_MAP_FILE "UI_Map.rws"
#include <vcl.h>
#pragma hdrstop
//---------------------------------------------------------------------------
USEFORM("map_editor.cpp", MainForm);
USEFORM("MapForm.cpp", FormMap);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
        try
        {
                 Application->Initialize();
                 Application->Title = "Shattered Memories Map Editor";
                 Application->CreateForm(__classid(TMainForm), &MainForm);
                 Application->CreateForm(__classid(TFormMap), &FormMap);
                 Application->Run();
        }
        catch (Exception &exception)
        {
                 Application->ShowException(&exception);
        }
        catch (...)
        {
                 try
                 {
                         throw Exception("");
                 }
                 catch (Exception &exception)
                 {
                         Application->ShowException(&exception);
                 }
        }
        return 0;
}
//---------------------------------------------------------------------------
