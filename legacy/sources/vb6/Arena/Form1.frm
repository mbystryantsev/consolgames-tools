VERSION 5.00
Begin VB.Form Main 
   Caption         =   "Arena Translation Tools"
   ClientHeight    =   3090
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3090
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.Label Label1 
      Alignment       =   2  '÷ентровка
      Caption         =   "∆ми сюда!"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   18
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   975
      Left            =   1200
      TabIndex        =   0
      Top             =   1560
      Width           =   1455
   End
   Begin VB.Line Line3 
      X1              =   4440
      X2              =   4440
      Y1              =   0
      Y2              =   360
   End
   Begin VB.Line Line2 
      X1              =   4320
      X2              =   3960
      Y1              =   0
      Y2              =   120
   End
   Begin VB.Line Line1 
      X1              =   4440
      X2              =   2160
      Y1              =   0
      Y2              =   1560
   End
End
Attribute VB_Name = "Main"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Load()
TabEdit.Show
QEdit.Show
Form1.Show
Me.Hide
End Sub
