VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Universal GBA FFFont Editor"
   ClientHeight    =   8805
   ClientLeft      =   150
   ClientTop       =   720
   ClientWidth     =   10860
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8805
   ScaleWidth      =   10860
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton ButtonLang 
      Caption         =   "En"
      Height          =   375
      Left            =   1080
      TabIndex        =   269
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton SaveAsButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   720
      Picture         =   "Form1.frx":0000
      Style           =   1  'Graphical
      TabIndex        =   268
      ToolTipText     =   "Сохранить как..."
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton SaveButton 
      Enabled         =   0   'False
      Height          =   375
      Left            =   360
      Picture         =   "Form1.frx":0442
      Style           =   1  'Graphical
      TabIndex        =   267
      ToolTipText     =   "Сохранить..."
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton OpenButton 
      Height          =   375
      Left            =   0
      Picture         =   "Form1.frx":0884
      Style           =   1  'Graphical
      TabIndex        =   266
      ToolTipText     =   "Открыть..."
      Top             =   0
      Width           =   375
   End
   Begin VB.CommandButton Command1 
      Caption         =   "S"
      Height          =   435
      Left            =   10680
      TabIndex        =   265
      Top             =   1320
      Visible         =   0   'False
      Width           =   135
   End
   Begin VB.CommandButton Command2 
      Caption         =   "L"
      Height          =   375
      Left            =   10680
      TabIndex        =   264
      Top             =   960
      Visible         =   0   'False
      Width           =   135
   End
   Begin VB.HScrollBar Scroll 
      Enabled         =   0   'False
      Height          =   255
      Left            =   2640
      Max             =   15
      TabIndex        =   263
      Top             =   8520
      Width           =   8175
   End
   Begin VB.Frame Frame1 
      Height          =   615
      Left            =   8040
      TabIndex        =   258
      Top             =   0
      Width           =   2535
      Begin VB.OptionButton Col 
         Height          =   375
         Index           =   3
         Left            =   1920
         Style           =   1  'Graphical
         TabIndex        =   262
         Top             =   120
         Width           =   495
      End
      Begin VB.OptionButton Col 
         Height          =   375
         Index           =   2
         Left            =   1320
         Style           =   1  'Graphical
         TabIndex        =   261
         Top             =   120
         Width           =   495
      End
      Begin VB.OptionButton Col 
         Height          =   375
         Index           =   1
         Left            =   720
         Style           =   1  'Graphical
         TabIndex        =   260
         Top             =   120
         Width           =   495
      End
      Begin VB.OptionButton Col 
         Height          =   375
         Index           =   0
         Left            =   120
         Style           =   1  'Graphical
         TabIndex        =   259
         Top             =   120
         Value           =   -1  'True
         Width           =   495
      End
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   255
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   257
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   254
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   256
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   253
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   255
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   252
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   254
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   251
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   253
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   250
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   252
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   249
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   251
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   248
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   250
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   247
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   249
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   246
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   248
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   245
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   247
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   244
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   246
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   243
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   245
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   242
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   244
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   241
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   243
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   240
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   242
      Top             =   7920
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   239
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   241
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   238
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   240
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   237
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   239
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   236
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   238
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   235
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   237
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   234
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   236
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   233
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   235
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   232
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   234
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   231
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   233
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   230
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   232
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   229
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   231
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   228
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   230
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   227
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   229
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   226
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   228
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   225
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   227
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   224
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   226
      Top             =   7440
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   223
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   225
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   222
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   224
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   221
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   223
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   220
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   222
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   219
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   221
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   218
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   220
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   217
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   219
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   216
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   218
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   215
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   217
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   214
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   216
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   213
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   215
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   212
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   214
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   211
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   213
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   210
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   212
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   209
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   211
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   208
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   210
      Top             =   6960
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   207
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   209
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   206
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   208
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   205
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   207
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   204
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   206
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   203
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   205
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   202
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   204
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   201
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   203
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   200
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   202
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   199
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   201
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   198
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   200
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   197
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   199
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   196
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   198
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   195
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   197
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   194
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   196
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   193
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   195
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   192
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   194
      Top             =   6480
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   191
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   193
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   190
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   192
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   189
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   191
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   188
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   190
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   187
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   189
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   186
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   188
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   185
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   187
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   184
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   186
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   183
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   185
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   182
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   184
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   181
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   183
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   180
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   182
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   179
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   181
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   178
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   180
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   177
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   179
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   176
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   178
      Top             =   6000
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   175
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   177
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   174
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   176
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   173
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   175
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   172
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   174
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   171
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   173
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   170
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   172
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   169
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   171
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   168
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   170
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   167
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   169
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   166
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   168
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   165
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   167
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   164
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   166
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   163
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   165
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   162
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   164
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   161
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   163
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   160
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   162
      Top             =   5520
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   159
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   161
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   158
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   160
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   157
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   159
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   156
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   158
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   155
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   157
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   154
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   156
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   153
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   155
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   152
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   154
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   151
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   153
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   150
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   152
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   149
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   151
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   148
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   150
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   147
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   149
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   146
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   148
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   145
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   147
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   144
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   146
      Top             =   5040
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   143
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   145
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   142
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   144
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   141
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   143
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   140
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   142
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   139
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   141
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   138
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   140
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   137
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   139
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   136
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   138
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   135
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   137
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   134
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   136
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   133
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   135
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   132
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   134
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   131
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   133
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   130
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   132
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   129
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   131
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   128
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   130
      Top             =   4560
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   127
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   129
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   126
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   128
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   125
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   127
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   124
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   126
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   123
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   125
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   122
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   124
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   121
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   123
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   120
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   122
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   119
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   121
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   118
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   120
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   117
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   119
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   116
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   118
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   115
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   117
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   114
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   116
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   113
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   115
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   112
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   114
      Top             =   4080
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   111
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   113
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   110
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   112
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   109
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   111
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   108
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   110
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   107
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   109
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   106
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   108
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   105
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   107
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   104
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   106
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   103
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   105
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   102
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   104
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   101
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   103
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   100
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   102
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   99
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   101
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   98
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   100
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   97
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   99
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   96
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   98
      Top             =   3600
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   95
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   97
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   94
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   96
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   93
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   95
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   92
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   94
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   91
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   93
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   90
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   92
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   89
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   91
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   88
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   90
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   87
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   89
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   86
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   88
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   85
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   87
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   84
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   86
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   83
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   85
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   82
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   84
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   81
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   83
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   80
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   82
      Top             =   3120
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   79
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   81
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   78
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   80
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   77
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   79
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   76
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   78
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   75
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   77
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   74
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   76
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   73
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   75
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   72
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   74
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   71
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   73
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   70
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   72
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   69
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   71
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   68
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   70
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   67
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   69
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   66
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   68
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   65
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   67
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   64
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   66
      Top             =   2640
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   63
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   65
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   62
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   64
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   61
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   63
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   60
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   62
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   59
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   61
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   58
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   60
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   57
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   59
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   56
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   58
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   55
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   57
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   54
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   56
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   53
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   55
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   52
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   54
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   51
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   53
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   50
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   52
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   49
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   51
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   48
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   50
      Top             =   2160
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   47
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   49
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   46
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   48
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   45
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   47
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   44
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   46
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   43
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   45
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   42
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   44
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   41
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   43
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   40
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   42
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   39
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   41
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   38
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   40
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   37
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   39
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   36
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   38
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   35
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   37
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   34
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   36
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   33
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   35
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   32
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   34
      Top             =   1680
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   31
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   33
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   30
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   32
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   29
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   31
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   28
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   30
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   27
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   29
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   26
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   28
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   25
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   27
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   24
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   26
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   23
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   25
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   22
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   24
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   21
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   23
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   20
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   22
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   19
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   21
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   18
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   20
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   17
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   19
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   16
      Left            =   2880
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   18
      Top             =   1200
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   15
      Left            =   10080
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   17
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   14
      Left            =   9600
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   16
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   13
      Left            =   9120
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   15
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   12
      Left            =   8640
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   14
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   11
      Left            =   8160
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   13
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   10
      Left            =   7680
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   12
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   9
      Left            =   7200
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   11
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   8
      Left            =   6720
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   10
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   7
      Left            =   6240
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   9
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   6
      Left            =   5760
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   8
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   5
      Left            =   5280
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   7
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   4
      Left            =   4800
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   6
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   3
      Left            =   4320
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   5
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   2
      Left            =   3840
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   4
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      HasDC           =   0   'False
      Height          =   512
      Index           =   1
      Left            =   3360
      OLEDragMode     =   1  'Авто
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   3
      Top             =   720
      Width           =   512
   End
   Begin VB.PictureBox p 
      Appearance      =   0  'Плоска
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   512
      Index           =   0
      Left            =   2880
      ScaleHeight     =   528.516
      ScaleMode       =   0  'Пользовательское
      ScaleWidth      =   512
      TabIndex        =   2
      Top             =   720
      Width           =   512
   End
   Begin VB.ListBox List 
      Height          =   7860
      ItemData        =   "Form1.frx":0CC6
      Left            =   120
      List            =   "Form1.frx":0CC8
      TabIndex        =   1
      Top             =   480
      Width           =   2535
   End
   Begin VB.TextBox file1 
      Height          =   285
      Left            =   120
      Locked          =   -1  'True
      TabIndex        =   0
      Text            =   "ff6\mainfont.chr"
      Top             =   8400
      Width           =   2535
   End
   Begin VB.Label TW 
      Height          =   255
      Left            =   6960
      TabIndex        =   270
      Top             =   360
      Width           =   975
   End
   Begin VB.Menu mFile 
      Caption         =   "Файл"
      Begin VB.Menu mExportW 
         Caption         =   "3"
      End
      Begin VB.Menu mOpen 
         Caption         =   "Открыть..."
         Shortcut        =   ^O
      End
      Begin VB.Menu mSave 
         Caption         =   "Сохранить"
         Shortcut        =   ^S
      End
      Begin VB.Menu mSave_as 
         Caption         =   "Сохранить как..."
         Shortcut        =   ^J
      End
      Begin VB.Menu mImport 
         Caption         =   "Импортировать из файла..."
         Shortcut        =   ^I
      End
      Begin VB.Menu mExport 
         Caption         =   "Экспортировать в файл..."
         Shortcut        =   ^E
      End
      Begin VB.Menu mExportG 
         Caption         =   "Экспорт графики..."
      End
      Begin VB.Menu mImportG 
         Caption         =   "Импорт графики..."
      End
      Begin VB.Menu mClose 
         Caption         =   "Закрыть"
      End
      Begin VB.Menu mExit 
         Caption         =   "Выход"
      End
   End
   Begin VB.Menu mEdit 
      Caption         =   "Правка"
      Begin VB.Menu mCopy 
         Caption         =   "Копировать"
         Shortcut        =   ^C
      End
      Begin VB.Menu mCopyB 
         Caption         =   "Копировать в буфер"
         Shortcut        =   ^B
      End
      Begin VB.Menu mCut 
         Caption         =   "Вырезать"
         Shortcut        =   ^X
      End
      Begin VB.Menu mPaste 
         Caption         =   "Вставить"
         Enabled         =   0   'False
         Shortcut        =   ^V
      End
      Begin VB.Menu mPasteB 
         Caption         =   "Вставить из буфера"
         Shortcut        =   ^P
      End
      Begin VB.Menu mClear 
         Caption         =   "Очистить"
         Shortcut        =   ^D
      End
      Begin VB.Menu mFlipW 
         Caption         =   "Отразить по-горизонтали"
      End
      Begin VB.Menu mFlipH 
         Caption         =   "Отразить по-вертикали"
      End
      Begin VB.Menu mColor 
         Caption         =   "Цвет"
         Begin VB.Menu mC1 
            Caption         =   "1"
            Shortcut        =   {F1}
         End
         Begin VB.Menu mC2 
            Caption         =   "2"
            Shortcut        =   {F2}
         End
         Begin VB.Menu mC3 
            Caption         =   "3"
            Shortcut        =   {F3}
         End
         Begin VB.Menu mC4 
            Caption         =   "4"
            Shortcut        =   {F4}
         End
      End
      Begin VB.Menu mRotate 
         Caption         =   "Повернуть"
         Begin VB.Menu mRR 
            Caption         =   "Вправо"
            Shortcut        =   ^R
         End
         Begin VB.Menu mRL 
            Caption         =   "Влево"
            Shortcut        =   ^L
         End
         Begin VB.Menu mR180 
            Caption         =   "180"
         End
      End
      Begin VB.Menu mMove 
         Caption         =   "Сдвинуть"
         Begin VB.Menu mMoveU 
            Caption         =   "Вверх"
            Shortcut        =   {F5}
         End
         Begin VB.Menu mMoveD 
            Caption         =   "Вниз"
            Shortcut        =   {F6}
         End
         Begin VB.Menu mMoveL 
            Caption         =   "Влево"
            Shortcut        =   {F7}
         End
         Begin VB.Menu mMoveR 
            Caption         =   "Вправо"
            Shortcut        =   {F8}
         End
      End
      Begin VB.Menu mAddCode 
         Caption         =   "Добавить символ"
      End
   End
   Begin VB.Menu mHelp 
      Caption         =   "Помощь"
      Begin VB.Menu mAbout 
         Caption         =   "О программе..."
      End
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub ButtonLang_Click()
If Lang = False Then
    mFile.Caption = "File"
    mOpen.Caption = "Open"
    mSave.Caption = "Save"
    mSave_as.Caption = "Save As..."
    mClose.Caption = "Close"
    mExit.Caption = "Exit"
    ButtonLang.Caption = "Ru"
    mEdit.Caption = "Edit"
    mCopy.Caption = "Copy"
    mCut.Caption = "Cut"
    mPaste.Caption = "Paste"
    mClear.Caption = "Clear"
    mFlipH.Caption = "Flip Horisontal"
    mFlipW.Caption = "Flip Vertical"
    mColor.Caption = "Color"
    mRotate.Caption = "Rotate"
    mRR.Caption = "Right"
    mRL.Caption = "Left"
    mMove.Caption = "Move"
    mMoveR.Caption = "Right"
    mMoveL.Caption = "Left"
    mMoveU.Caption = "Up"
    mMoveD.Caption = "Down"
    mHelp.Caption = "Help"
    mAbout.Caption = "About..."
    mImport.Caption = "Import from file..."
    mExport.Caption = "Export to file..."
    lng.lAllFiles = "All Files"
    lng.lFileOpening = "Select file to open..."
    lng.lFileSaving = "Select file to save..."
    lng.lFileExporting = "Select file to export..."
    lng.lFileImporting = "Select file to import..."
    lng.lAbout = "Final Fantasy GBA versions font editor by HoRRoR." & vbCrLf & "Respect to Djinn :)"
    lng.lWidth = "Width: "
    Lang = True
Else
    mFile.Caption = "Файл"
    mOpen.Caption = "Открыть"
    mSave.Caption = "Сохранить"
    mSave_as.Caption = "Сохранить как..."
    mClose.Caption = "Закрыть"
    mExit.Caption = "Выход"
    ButtonLang.Caption = "En"
    mEdit.Caption = "Правка"
    mCopy.Caption = "Копировать"
    mCut.Caption = "Вырезать"
    mPaste.Caption = "Вставить"
    mClear.Caption = "Очистить"
    mFlipH.Caption = "Отразить по-горизонтали"
    mFlipW.Caption = "Отразить по-вертикали"
    mColor.Caption = "Цвет"
    mRotate.Caption = "Повернуть"
    mRR.Caption = "Вправо"
    mRL.Caption = "Влево"
    mMove.Caption = "Сдвинуть"
    mMoveR.Caption = "Вправо"
    mMoveL.Caption = "Влево"
    mMoveU.Caption = "Вверх"
    mMoveD.Caption = "Вниз"
    mHelp.Caption = "Помощь"
    mAbout.Caption = "О программе..."
    mImport.Caption = "Импортировать из файла..."
    mExport.Caption = "Экспортировать в файл..."
    lng.lAbout = "Редактор шрифтов для GBA-версий Final Fantasy от HoRRoR'а." & vbCrLf & "Респект Джинну :)"
    lng.lFileOpening = "Открытие файла"
    lng.lFileSaving = "Сохранение файла"
    lng.lFileExporting = "Экспорт шрифта в файл..."
    lng.lFileImporting = "Импорт шрифта из файла..."
    lng.lAllFiles = "Все файлы"
    lng.lWidth = "Ширина: "
    Lang = False
End If
If Opened = True Then
    TW.Caption = lng.lWidth & Tile.W(List.ListIndex)
End If
End Sub

Private Sub Command1_Click()
If Imported = True Then GoTo KillZone:

Open file1 For Binary As 1
Dim Ncnt As Integer
Dim Ppos As Long
Dim Npos As Long
Dim Gpos As Long
Dim PutW As Byte
Dim PutBit As String
Dim PutByte As String
Put #1, 5, "FONT"
Put #1, 9, Head
'Put #1, 11, ptr.Ncnt
Ppos = 13 + ptr.Ncnt * 2
Npos = 15
Gpos = Ppos + Head.PCount * 4
'Ncnt = 4
'For n = Ppos To Ppos + &H9C * 4 - 4
' Put #1, n, Gpos - 1
'Next n
'Gpos = Gpos + 112
l = 1
For n = Npos To Npos - 2 + ptr.Ncnt * 2 Step 2
    Put #1, n, ptr.nbr(l): l = l + 1
Next n
Put #1, 11 + ptr.Ncnt * 2, "яя"
For n = 0 To Head.PCount - 1
    'Put #1, Npos, Ncnt: Ncnt = Ncnt + 1: Npos = Npos + 2
    Put #1, Ppos, Gpos - 1: Ppos = Ppos + 4
    Put #1, Gpos, Tile.W(n): Gpos = Gpos + 1
    PutW = Kr(Tile.W(n), 4) / 4
    Put #1, Gpos, PutW: Gpos = Gpos + 1
    For m = 0 To Head.H - 1 'PutW * 4 - 1
        For l = 0 To PutW * 4 - 1 'Head.H - 1
            If T(n, l, m) = 0 Then PutBit = "00" Else If T(n, l, m) = 1 Then PutBit = "01" _
            Else If T(n, l, m) = 2 Then PutBit = "10" Else PutBit = "11"
            PutByte = PutBit & PutByte
            If Len(PutByte) >= 8 Then
                Put #1, Gpos, GetByte(PutByte): Gpos = Gpos + 1
                PutByte = ""
            End If
        Next l
    Next m
Next n
Put #1, 13, 4
Close
Exit Sub
KillZone:
Call mSave_as_Click
End Sub

Private Sub Command2_Click()
For l = 0 To 255
    p(l).BackColor = Clr.c(0)
Next l
List.Clear
Dim posW As Integer
Dim posH As Integer
Dim m As Integer
Open file1 For Binary As 1
fsz = LOF(1)
ReDim fil(LOF(1) - 1) As Byte
Get #1, 1, fil()
Close 1
'--Читаем заголовок
Head.H = fil(8)
Head.Bpp = fil(9)
Head.PCount = fil(10) + fil(11) * 256
ReDim ptr.pnt(Head.PCount - 1)
'--Определяем размерность первой таблицы
ptr.Ncnt = 0
For n = 12 To fsz Step 2
    ptr.Ncnt = ptr.Ncnt + 1
    If fil(n) = 255 And fil(n + 1) = 255 Then
        ptr.PBegin = n + 2
        Exit For
    End If
Next n
'--Загружаем первую таблицу
s = 0
'ReDim ptr.nbr(ptr.Ncnt)
ReDim ptr.nbr(Head.PCount - 1)
For n = 12 To ptr.Ncnt * 2 + 9 Step 2
    ptr.nbr(s) = fil(n) + fil(n + 1) * 256: s = s + 1
Next n
'--Загружаем поинтеры
s = 0
For n = ptr.PBegin To ptr.PBegin + Head.PCount * 4 - 1 Step 4
    For l = 0 To 3
        ptr.pnt(s) = ptr.pnt(s) + fil(n + l) * 256 ^ l
    Next l
    s = s + 1
Next n
'--
'MsgBox Hex(ptr.PBegin)
'MsgBox Hex(ptr.pnt(0))
'--Загрузка графики
GoTo NewP:
For n = 0 To ptr.Ncnt - 1
    posW = 0: posH = 0
    Tile.Bpp(n) = fil(ptr.pnt(ptr.nbr(n)) + 1)
    Tile.W(n) = fil(ptr.pnt(ptr.nbr(n)))
        For l = ptr.pnt(ptr.nbr(n)) + 2 To ptr.pnt(ptr.nbr(n)) + 1 + Head.H / 4 * Kr(Tile.W(n), Tile.Bpp(n) * 4)
            For m = 1 To 4
                T(n, posW, posH) = Get2(fil(l), m)
                'Call SetP(posW, posH, T(n, posW, posH))
                If posW >= Kr(Tile.W(n), Tile.Bpp(n) * 4) - 1 Then 'Tile.W(n) - 1 Then
                    posW = 0: posH = posH + 1
                Else
                    posW = posW + 1
                End If
            Next m
        Next l
        'MsgBox n & "/" & ptr.Ncnt & " - 2bpp"
        'MsgBox "!"
Next n
GoTo skp:
NewP:
For n = 0 To Head.PCount - 1
    posW = 0: posH = 0
    Tile.Bpp(n) = fil(ptr.pnt(n) + 1)
    Tile.W(n) = fil(ptr.pnt(n))
        For l = ptr.pnt(n) + 2 To ptr.pnt(n) + 1 + Head.H / 4 * Kr(Tile.W(n), Tile.Bpp(n) * 4)
            For m = 1 To 4
                T(n, posW, posH) = Get2(fil(l), m)
                'Call SetP(posW, posH, T(n, posW, posH))
                If posW >= Kr(Tile.W(n), Tile.Bpp(n) * 4) - 1 Then 'Tile.W(n) - 1 Then
                    posW = 0: posH = posH + 1
                Else
                    posW = posW + 1
                End If
            Next m
        Next l
        'MsgBox n & "/" & ptr.Ncnt & " - 2bpp"
        'MsgBox "!"
Next n
skp:
'--Добавление элементов в список
For n = 1 To Head.PCount
    List.AddItem Right("00" & Hex(n - 1), 2)
Next n
List.ListIndex = 0
End Sub



Private Sub Exit_Click()
End
End Sub



Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
'MsgBox Shift
If Opened = True Then
    If Shift = 1 Then ris = True
End If
End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
'If Shift = 1 Then
ris = False
End Sub

Private Sub Form_Load()
For n = 0 To 255
    p(n).BackColor = n * 255 + 255
Next n

Clr.c(0) = &HAE1C19
Clr.c(1) = &HFFFFFF
Clr.c(2) = &H8F9E8F
Clr.c(3) = &H8000000A
For n = 0 To 3
    Col(n).BackColor = Clr.c(n)
Next n

Lang = True
Call ButtonLang_Click
End Sub

Private Sub Form_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
'ris = True
End Sub

Private Sub List_Click()
Call LoadTile(List.ListIndex)
Scroll = Tile.W(List.ListIndex)
End Sub

Private Sub mAbout_Click()
MsgBox lng.lAbout
End Sub

Private Sub mAddCode_Click()
List.AddItem Hex(List.ListCount)
'ppnt() = ptr.pnt()
'ReDim ptr.pnt(Head.PCount)
'For n = 0 To Head.PCount
'    ptr.pnt=
Head.PCount = Head.PCount + 1


End Sub

Private Sub mC1_Click()
Col(0).Value = True
End Sub

Private Sub mC2_Click()
Col(1).Value = True
End Sub

Private Sub mC3_Click()
Col(2).Value = True
End Sub

Private Sub mC4_Click()
Col(3).Value = True
End Sub

Private Sub mClear_Click()
Clear (List.ListIndex)
End Sub

Private Sub mCopy_Click()
For l = 0 To 15
    For m = 0 To 15
        Buffer(l, m) = T(List.ListIndex, l, m)
    Next m
Next l
BufW = Tile.W(List.ListIndex)
Coped = True
mPaste.Enabled = True
End Sub

Private Sub mCopyB_Click()
Open "~fffe_.tmp" For Binary As 1
Dim pos As Integer
For l = 0 To 15
    For m = 0 To 15
        Put #1, pos + 1, T(List.ListIndex, l, m): pos = pos + 1
    Next m
Next l
Put #1, pos + 1, Tile.W(List.ListIndex)
mPasteB.Enabled = True
Close 1
End Sub

Private Sub mCut_Click()
Call mCopy_Click
Call mClear_Click
End Sub

Private Sub mExit_Click()
End
End Sub

Private Sub mExportG_Click()
Dial.Backup = Dial.file

Dial.Form = Me.hWnd
Dial.Filter = lng.lAllFiles & " (*.*)" + Chr$(0) + "*.*"
Dial.Title = lng.lFileSaving
Dial.file = ShowSave
If Not InStr(1, Dial.file, "\") = 0 Then
    Dial.Dir = Right(Dial.file, Len(Dial.file) - InStrRev(Dial.file, "\"))
End If
If Dial.file = "" Then
    Dial.file = Dial.Backup
Else
    FileG = Dial.file
    Imported = False
    Call ExportGrafic
End If
End Sub

Private Sub mExportW_Click()
Dial.Backup = Dial.file

Dial.Form = Me.hWnd
Dial.Filter = lng.lAllFiles & " (*.*)" + Chr$(0) + "*.*"
Dial.Title = lng.lFileSaving
Dial.file = ShowSave
If Not InStr(1, Dial.file, "\") = 0 Then
    Dial.Dir = Right(Dial.file, Len(Dial.file) - InStrRev(Dial.file, "\"))
End If
If Dial.file = "" Then
    Dial.file = Dial.Backup
Else
    Open Dial.file For Output As 1
    For n = 0 To List.ListCount - 1
        Print #1, Tile.W(n)
    Next n
    Close 1
End If
End Sub

Private Sub mFlipH_Click()
For n = 0 To 15
    For l = 0 To 15
        Temp(n, l) = T(List.ListIndex, 15 - n, l)
    Next l
Next n
For n = 0 To 15
    For m = 0 To 15
        T(List.ListIndex, n, m) = Temp(n, m)
        Call SetP(n, m, Temp(n, m))
    Next m
Next n
End Sub

Private Sub mFlipW_Click()
For n = 0 To 15
    For l = 0 To 15
        Temp(n, l) = T(List.ListIndex, n, 15 - l)
    Next l
Next n
For n = 0 To 15
    For m = 0 To 15
        T(List.ListIndex, n, m) = Temp(n, m)
        Call SetP(n, m, Temp(n, m))
    Next m
Next n
End Sub

Private Sub mMoveD_Click()
For n = 0 To 15
    For l = 1 To 15
        Temp(n, l - 1) = T(List.ListIndex, n, l)
    Next l
Next n
For n = 0 To 15
    Temp(n, 15) = T(List.ListIndex, n, 0)
Next n
For n = 0 To 15
    For m = 0 To 15
        T(List.ListIndex, n, m) = Temp(n, m)
        Call SetP(n, m, Temp(n, m))
    Next m
Next n
End Sub

Private Sub mMoveL_Click()
For n = 1 To 15
    For l = 0 To 15
        Temp(n - 1, l) = T(List.ListIndex, n, l)
    Next l
Next n
For n = 0 To 15
    Temp(15, n) = T(List.ListIndex, 0, n)
Next n
For n = 0 To 15
    For m = 0 To 15
        T(List.ListIndex, n, m) = Temp(n, m)
        Call SetP(n, m, Temp(n, m))
    Next m
Next n
End Sub

Private Sub mMoveR_Click()
For n = 1 To 15
    For l = 0 To 15
        Temp(n, l) = T(List.ListIndex, n - 1, l)
    Next l
Next n
For n = 0 To 15
    Temp(0, n) = T(List.ListIndex, 15, n)
Next n
For n = 0 To 15
    For m = 0 To 15
        T(List.ListIndex, n, m) = Temp(n, m)
        Call SetP(n, m, Temp(n, m))
    Next m
Next n
End Sub

Private Sub mMoveU_Click()
For n = 0 To 15
    For l = 1 To 15
        Temp(n, l) = T(List.ListIndex, n, l - 1)
    Next l
Next n
For n = 0 To 15
    Temp(n, 0) = T(List.ListIndex, n, 15)
Next n
For n = 0 To 15
    For m = 0 To 15
        T(List.ListIndex, n, m) = Temp(n, m)
        Call SetP(n, m, Temp(n, m))
    Next m
Next n
End Sub

Private Sub mOpen_Click()
If Opened = True Then
For n = 0 To 512
    For l = 0 To 15
        For m = 0 To 15
            T(n, l, m) = 0
        Next m
    Next l
Next n
End If

Dial.Backup = Dial.file

Dial.Form = Me.hWnd
Dial.Filter = lng.lAllFiles & " (*.*)" + Chr$(0) + "*.*"
Dial.Title = lng.lFileOpening
Dial.file = ShowOpen
If Not InStr(1, Dial.file, "\") = 0 Then
    Dial.Dir = Right(Dial.file, Len(Dial.file) - InStrRev(Dial.file, "\"))
End If
If Dial.file = "" Then
    Dial.file = Dial.Backup
Else
    file1 = Dial.file
    Call Command2_Click
    Opened = True
    SaveButton.Enabled = True
    SaveAsButton.Enabled = True
    mSave.Enabled = True
    mSave_as.Enabled = True
    mEdit.Enabled = True
    Scroll.Enabled = True
End If
End Sub

Private Sub mPaste_Click()
    For l = 0 To 15
        For m = 0 To 15
            T(List.ListIndex, l, m) = Buffer(l, m)
            Call SetP(l, m, Buffer(l, m))
        Next m
    Next l
    Tile.W(List.ListIndex) = BufW
    Scroll.Value = BufW
End Sub

Private Sub mPasteB_Click()
Open "~fffe_.tmp" For Binary As 1
Dim pos As Integer
For l = 0 To 15
    For m = 0 To 15
        Get #1, pos + 1, T(List.ListIndex, l, m): pos = pos + 1
        Call SetP(l, m, T(List.ListIndex, l, m))
    Next m
Next l
Get #1, pos + 1, Tile.W(List.ListIndex)
Scroll.Value = Tile.W(List.ListIndex)
Close 1
End Sub

Private Sub mR180_Click()
Call mRR_Click
Call mRR_Click
End Sub

Private Sub mRL_Click()
For n = 0 To 15
    For m = 0 To 15
        Temp(n, 15 - m) = T(List.ListIndex, m, n)
    Next m
Next n
For n = 0 To 15
    For m = 0 To 15
        T(List.ListIndex, n, m) = Temp(n, m)
        Call SetP(n, m, Temp(n, m))
    Next m
Next n
End Sub

Private Sub mRR_Click()
For n = 0 To 15
    For m = 0 To 15
        Temp(n, m) = T(List.ListIndex, m, 15 - n)
    Next m
Next n
For n = 0 To 15
    For m = 0 To 15
        T(List.ListIndex, n, m) = Temp(n, m)
        Call SetP(n, m, Temp(n, m))
    Next m
Next n
End Sub

Private Sub mSave_as_Click()
Dial.Backup = Dial.file

Dial.Form = Me.hWnd
Dial.Filter = lng.lAllFiles & " (*.*)" + Chr$(0) + "*.*"
Dial.Title = lng.lFileSaving
Dial.file = ShowSave
If Not InStr(1, Dial.file, "\") = 0 Then
    Dial.Dir = Right(Dial.file, Len(Dial.file) - InStrRev(Dial.file, "\"))
End If
If Dial.file = "" Then
    Dial.file = Dial.Backup
Else
    file1 = Dial.file
    Imported = False
    Call mSave_Click
End If
End Sub

Private Sub mSave_Click()
Call Command1_Click
End Sub

Private Sub OpenButton_Click()
Call mOpen_Click
End Sub

Private Sub p_Click(Index As Integer)
'ris = True
'Select Case Button
'Case vbLeftButton
'Call SetP(Index - Kr2(Index, 16), Index \ 16, 1)
'Case vbRightButton'
'
'Case vbMiddleButton'
'
'End Select
End Sub

Private Sub p_DragDrop(Index As Integer, Source As Control, X As Single, Y As Single)
MsgBox "1"
End Sub

Private Sub p_KeyPress(Index As Integer, KeyAscii As Integer)
Call SetP(Index - Kr2(Index, 16), Index \ 16, 1)
End Sub

Private Sub p_MouseDown(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
ris = True
End Sub

Private Sub p_MouseMove(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim colr As Byte
If Col(0).Value = True Then
    colr = 0
ElseIf Col(1).Value = True Then
    colr = 1
ElseIf Col(2).Value = True Then
    colr = 2
Else
    colr = 3
End If
If ris = True Then
    Call SetP(Index - Kr2(Index, 16), Index \ 16, colr)
End If
End Sub

Private Sub p_MouseUp(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
ris = False
End Sub

Private Sub p_OLEDragDrop(Index As Integer, Data As DataObject, Effect As Long, Button As Integer, Shift As Integer, X As Single, Y As Single)
MsgBox "1"
End Sub

Private Sub p_OLEGiveFeedback(Index As Integer, Effect As Long, DefaultCursors As Boolean)
MsgBox "1"
End Sub

Private Sub SaveAsButton_Click()
Dial.Backup = Dial.file

Dial.Form = Me.hWnd
Dial.Filter = "Все файлы (*.*)" _
        + Chr$(0) + "*.*"
Dial.Title = "Сохранение файла"
Dial.file = ShowSave
If Not InStr(1, Dial.file, "\") = 0 Then
    Dial.Dir = Right(Dial.file, Len(Dial.file) - InStrRev(Dial.file, "\"))
End If
If Dial.file = "" Then
    Dial.file = Dial.Backup
Else
    file2 = Dial.file
End If
End Sub

Private Sub SaveButton_Click()
Call Command1_Click
End Sub

Private Sub Scroll_Change()
Tile.W(List.ListIndex) = Scroll
TW.Caption = lng.lWidth & Tile.W(List.ListIndex)
End Sub

Public Function Clear(s)
For m = 0 To 15
    For n = 0 To 15
        Call SetP(m, n, 0)
        T(s, m, n) = 0
    Next n
Next m
End Function

Public Sub ExportGrafic()
pos = 0
cnt = 0
Dim k(3)
ReDim fil(List.ListCount * 64 - 1)
For n = 0 To List.ListCount - 1
els:
    If cnt >= 4 Then
        cnt = 0
        GoTo skip
    Else
        cnt = cnt + 1
        If cnt = 1 Then
            k(0) = 0: k(1) = 7: k(2) = 0: k(3) = 7
        ElseIf cnt = 2 Then
            k(0) = 8: k(1) = 15: k(2) = 0: k(3) = 7
        ElseIf cnt = 3 Then
            k(0) = 0: k(1) = 7: k(2) = 8: k(3) = 15
        ElseIf cnt = 4 Then
            k(0) = 8: k(1) = 15: k(2) = 8: k(3) = 15
        End If
    End If
    For l = k(0) To k(1)
        For m = k(2) To k(3)
            bt = DB(T(n, m, l)) & bt
            If Len(bt) >= 8 Then
                fil(pos) = GetByte(bt): pos = pos + 1
                bt = ""
            End If
        Next m
    Next l
    GoTo els:
skip:
Next n
Open FileG For Binary As 1
Put #1, 1, fil()
Close 1
End Sub
