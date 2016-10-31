VERSION 5.00
Begin VB.Form Help 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Помощь"
   ClientHeight    =   3975
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   6120
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3975
   ScaleWidth      =   6120
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command2 
      Caption         =   "Как пользоваться?"
      Height          =   375
      Left            =   3120
      TabIndex        =   2
      Top             =   3480
      Width           =   2895
   End
   Begin VB.CommandButton Command1 
      Caption         =   "О программе..."
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Top             =   3480
      Width           =   2895
   End
   Begin VB.TextBox Text1 
      Alignment       =   2  'Центровка
      Height          =   3255
      Left            =   120
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Вертикаль
      TabIndex        =   0
      Text            =   "Help.frx":0000
      Top             =   120
      Width           =   5895
   End
End
Attribute VB_Name = "Help"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
