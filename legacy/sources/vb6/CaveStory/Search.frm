VERSION 5.00
Begin VB.Form Search 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Поиск"
   ClientHeight    =   1530
   ClientLeft      =   45
   ClientTop       =   315
   ClientWidth     =   4905
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1530
   ScaleWidth      =   4905
   ShowInTaskbar   =   0   'False
   StartUpPosition =   1  'CenterOwner
   WhatsThisHelp   =   -1  'True
   Begin VB.CommandButton Command1 
      Caption         =   "Отмена"
      Height          =   255
      Left            =   3840
      TabIndex        =   8
      Top             =   480
      Width           =   975
   End
   Begin VB.Frame Frame2 
      Caption         =   "Параметры:"
      Height          =   735
      Left            =   1800
      TabIndex        =   6
      Top             =   720
      Width           =   3015
      Begin VB.CheckBox Check2 
         Caption         =   "Искать только целые слова"
         Enabled         =   0   'False
         Height          =   375
         Left            =   120
         TabIndex        =   7
         Top             =   240
         Width           =   2655
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Направление"
      Height          =   975
      Left            =   120
      TabIndex        =   3
      Top             =   480
      Width           =   1575
      Begin VB.OptionButton Option1 
         Caption         =   "Вперёд"
         Height          =   255
         Left            =   120
         TabIndex        =   5
         Top             =   600
         Value           =   -1  'True
         Width           =   975
      End
      Begin VB.OptionButton Up 
         Caption         =   "Назад"
         Enabled         =   0   'False
         Height          =   255
         Left            =   120
         TabIndex        =   4
         Top             =   240
         Width           =   975
      End
   End
   Begin VB.CommandButton FindButton1 
      Caption         =   "Найти"
      Height          =   255
      Left            =   3840
      TabIndex        =   2
      Top             =   120
      Width           =   975
   End
   Begin VB.TextBox FText 
      Height          =   285
      Left            =   720
      TabIndex        =   0
      Top             =   120
      Width           =   3015
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Правая привязка
      Caption         =   "Искать:"
      Height          =   255
      Left            =   0
      TabIndex        =   1
      Top             =   120
      Width           =   615
   End
End
Attribute VB_Name = "Search"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Me.Hide
End Sub

Private Sub FindButton1_Click()
Call FindButton
End Sub

Private Sub Form_Load()
Form1.Enabled = False
End Sub

Private Sub Form_Unload(Cancel As Integer)
Form1.Enabled = True
End Sub

Private Sub FText_Change()
Form1.mFindNext = Len(FText) > 0
End Sub
