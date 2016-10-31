VERSION 5.00
Begin VB.Form TabEdit 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Редактор таблиц"
   ClientHeight    =   5385
   ClientLeft      =   9945
   ClientTop       =   315
   ClientWidth     =   4335
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5385
   ScaleWidth      =   4335
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton Command10 
      Caption         =   "Сдвинуть вправо ->"
      Height          =   495
      Left            =   3120
      TabIndex        =   130
      ToolTipText     =   "Сдвинуть все символы на одну ячейку вправо."
      Top             =   3000
      Width           =   1095
   End
   Begin VB.CommandButton Command9 
      Caption         =   "  Сдвинуть    <- влево"
      Height          =   495
      Left            =   120
      TabIndex        =   129
      ToolTipText     =   "Сдвинуть все символы на одну ячейку влево."
      Top             =   3000
      Width           =   1095
   End
   Begin VB.CommandButton Command8 
      Caption         =   "Убрать свои"
      Height          =   255
      Left            =   3120
      TabIndex        =   128
      ToolTipText     =   "Убрать все нестандартные симолы."
      Top             =   2640
      Width           =   1095
   End
   Begin VB.CommandButton Command7 
      Caption         =   "Убрать стандартные"
      Height          =   495
      Left            =   1320
      TabIndex        =   127
      ToolTipText     =   "Убрать все стандартные символы."
      Top             =   3000
      Width           =   1695
   End
   Begin VB.CommandButton Command6 
      Caption         =   "Заполнить пустые "
      Height          =   255
      Left            =   1320
      TabIndex        =   126
      ToolTipText     =   "Заполнить пустые ячейки стандартными символами."
      Top             =   2640
      Width           =   1695
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Очистить"
      Height          =   255
      Left            =   120
      TabIndex        =   125
      ToolTipText     =   "Очистить редактируемую таблицу."
      Top             =   2640
      Width           =   1095
   End
   Begin VB.Frame Frame2 
      Caption         =   "Параметры:"
      Height          =   1695
      Left            =   120
      TabIndex        =   123
      Top             =   3600
      Width           =   4095
      Begin VB.CheckBox TxtChn 
         Caption         =   "Переходить в следующую ячейку при изменении символа."
         Height          =   375
         Left            =   120
         TabIndex        =   132
         Top             =   1200
         Value           =   1  'Отмечено
         Width           =   3615
      End
      Begin VB.CheckBox SndKys 
         Caption         =   "Автоматически выделять символ в ячейке"
         Height          =   375
         Left            =   120
         TabIndex        =   131
         Top             =   720
         Value           =   1  'Отмечено
         Width           =   3855
      End
      Begin VB.CheckBox ReTab 
         Caption         =   "При загрузке таблицы вместо отсутствующих символов загружать стандартные"
         Height          =   495
         Left            =   120
         TabIndex        =   124
         ToolTipText     =   "Если выбрана эта опция, то при загрузки таблицы вместо пустых ячеек будут загружаться стандартные символы."
         Top             =   240
         Width           =   3855
      End
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Обзор..."
      Height          =   255
      Left            =   3120
      TabIndex        =   122
      ToolTipText     =   "Выбрать файл в проводнике."
      Top             =   1920
      Width           =   1095
   End
   Begin VB.CommandButton Command3 
      Caption         =   "По умолчанию"
      Height          =   255
      Left            =   1320
      TabIndex        =   121
      ToolTipText     =   "Загрузить стандартные символы."
      Top             =   2280
      Width           =   1695
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Сохранить"
      Height          =   255
      Left            =   3120
      TabIndex        =   120
      ToolTipText     =   "Сохранить редактируемую таблицу в выбранный файл."
      Top             =   2280
      Width           =   1095
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Загрузить"
      Height          =   255
      Left            =   120
      TabIndex        =   119
      ToolTipText     =   "Загрузить выбранную таблицу для редактирования."
      Top             =   2280
      Width           =   1095
   End
   Begin VB.TextBox file1 
      BackColor       =   &H00FFFFFF&
      Height          =   285
      Left            =   120
      TabIndex        =   118
      Top             =   1920
      Width           =   2895
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      BackColor       =   &H8000000F&
      Enabled         =   0   'False
      Height          =   285
      Index           =   127
      Left            =   3960
      MaxLength       =   1
      TabIndex        =   113
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   112
      Left            =   360
      MaxLength       =   1
      TabIndex        =   112
      Text            =   "p"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   113
      Left            =   600
      MaxLength       =   1
      TabIndex        =   111
      Text            =   "q"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   114
      Left            =   840
      MaxLength       =   1
      TabIndex        =   110
      Text            =   "r"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   115
      Left            =   1080
      MaxLength       =   1
      TabIndex        =   109
      Text            =   "s"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   116
      Left            =   1320
      MaxLength       =   1
      TabIndex        =   108
      Text            =   "t"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   117
      Left            =   1560
      MaxLength       =   1
      TabIndex        =   107
      Text            =   "u"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   118
      Left            =   1800
      MaxLength       =   1
      TabIndex        =   106
      Text            =   "v"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   119
      Left            =   2040
      MaxLength       =   1
      TabIndex        =   105
      Text            =   "w"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   120
      Left            =   2280
      MaxLength       =   1
      TabIndex        =   104
      Text            =   "x"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   121
      Left            =   2520
      MaxLength       =   1
      TabIndex        =   103
      Text            =   "y"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   122
      Left            =   2760
      MaxLength       =   1
      TabIndex        =   102
      Text            =   "z"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   123
      Left            =   3000
      MaxLength       =   1
      TabIndex        =   101
      Text            =   "{"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   124
      Left            =   3240
      MaxLength       =   1
      TabIndex        =   100
      Text            =   "|"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   126
      Left            =   3720
      MaxLength       =   1
      TabIndex        =   99
      Text            =   "~"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   125
      Left            =   3480
      MaxLength       =   1
      TabIndex        =   98
      Text            =   "}"
      Top             =   1560
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   111
      Left            =   3960
      MaxLength       =   1
      TabIndex        =   97
      Text            =   "o"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   96
      Left            =   360
      MaxLength       =   1
      TabIndex        =   96
      Text            =   "`"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   97
      Left            =   600
      MaxLength       =   1
      TabIndex        =   95
      Text            =   "a"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   98
      Left            =   840
      MaxLength       =   1
      TabIndex        =   94
      Text            =   "b"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   99
      Left            =   1080
      MaxLength       =   1
      TabIndex        =   93
      Text            =   "c"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   100
      Left            =   1320
      MaxLength       =   1
      TabIndex        =   92
      Text            =   "d"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   101
      Left            =   1560
      MaxLength       =   1
      TabIndex        =   91
      Text            =   "e"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   102
      Left            =   1800
      MaxLength       =   1
      TabIndex        =   90
      Text            =   "f"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   103
      Left            =   2040
      MaxLength       =   1
      TabIndex        =   89
      Text            =   "g"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   104
      Left            =   2280
      MaxLength       =   1
      TabIndex        =   88
      Text            =   "h"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   105
      Left            =   2520
      MaxLength       =   1
      TabIndex        =   87
      Text            =   "i"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   106
      Left            =   2760
      MaxLength       =   1
      TabIndex        =   86
      Text            =   "j"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   107
      Left            =   3000
      MaxLength       =   1
      TabIndex        =   85
      Text            =   "k"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   108
      Left            =   3240
      MaxLength       =   1
      TabIndex        =   84
      Text            =   "l"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   110
      Left            =   3720
      MaxLength       =   1
      TabIndex        =   83
      Text            =   "n"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   109
      Left            =   3480
      MaxLength       =   1
      TabIndex        =   82
      Text            =   "m"
      Top             =   1320
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   95
      Left            =   3960
      MaxLength       =   1
      TabIndex        =   81
      Text            =   "_"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   80
      Left            =   360
      MaxLength       =   1
      TabIndex        =   80
      Text            =   "P"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   81
      Left            =   600
      MaxLength       =   1
      TabIndex        =   79
      Text            =   "Q"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   82
      Left            =   840
      MaxLength       =   1
      TabIndex        =   78
      Text            =   "R"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   83
      Left            =   1080
      MaxLength       =   1
      TabIndex        =   77
      Text            =   "S"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   84
      Left            =   1320
      MaxLength       =   1
      TabIndex        =   76
      Text            =   "T"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   85
      Left            =   1560
      MaxLength       =   1
      TabIndex        =   75
      Text            =   "U"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   86
      Left            =   1800
      MaxLength       =   1
      TabIndex        =   74
      Text            =   "V"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   87
      Left            =   2040
      MaxLength       =   1
      TabIndex        =   73
      Text            =   "W"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   88
      Left            =   2280
      MaxLength       =   1
      TabIndex        =   72
      Text            =   "X"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   89
      Left            =   2520
      MaxLength       =   1
      TabIndex        =   71
      Text            =   "Y"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   90
      Left            =   2760
      MaxLength       =   1
      TabIndex        =   70
      Text            =   "Z"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   91
      Left            =   3000
      MaxLength       =   1
      TabIndex        =   69
      Text            =   "["
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   92
      Left            =   3240
      MaxLength       =   1
      TabIndex        =   68
      Text            =   "\"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   94
      Left            =   3720
      MaxLength       =   1
      TabIndex        =   67
      Text            =   "^"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   93
      Left            =   3480
      MaxLength       =   1
      TabIndex        =   66
      Text            =   "]"
      Top             =   1080
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   79
      Left            =   3960
      MaxLength       =   1
      TabIndex        =   65
      Text            =   "O"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   64
      Left            =   360
      MaxLength       =   1
      TabIndex        =   64
      Text            =   "@"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   65
      Left            =   600
      MaxLength       =   1
      TabIndex        =   63
      Text            =   "A"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   66
      Left            =   840
      MaxLength       =   1
      TabIndex        =   62
      Text            =   "B"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   67
      Left            =   1080
      MaxLength       =   1
      TabIndex        =   61
      Text            =   "C"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   68
      Left            =   1320
      MaxLength       =   1
      TabIndex        =   60
      Text            =   "D"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   69
      Left            =   1560
      MaxLength       =   1
      TabIndex        =   59
      Text            =   "E"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   70
      Left            =   1800
      MaxLength       =   1
      TabIndex        =   58
      Text            =   "F"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   71
      Left            =   2040
      MaxLength       =   1
      TabIndex        =   57
      Text            =   "G"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   72
      Left            =   2280
      MaxLength       =   1
      TabIndex        =   56
      Text            =   "H"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   73
      Left            =   2520
      MaxLength       =   1
      TabIndex        =   55
      Text            =   "I"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   74
      Left            =   2760
      MaxLength       =   1
      TabIndex        =   54
      Text            =   "J"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   75
      Left            =   3000
      MaxLength       =   1
      TabIndex        =   53
      Text            =   "K"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   76
      Left            =   3240
      MaxLength       =   1
      TabIndex        =   52
      Text            =   "L"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   78
      Left            =   3720
      MaxLength       =   1
      TabIndex        =   51
      Text            =   "N"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   77
      Left            =   3480
      MaxLength       =   1
      TabIndex        =   50
      Text            =   "M"
      Top             =   840
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   63
      Left            =   3960
      MaxLength       =   1
      TabIndex        =   49
      Text            =   "?"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   48
      Left            =   360
      MaxLength       =   1
      TabIndex        =   46
      Text            =   "0"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   49
      Left            =   600
      MaxLength       =   1
      TabIndex        =   45
      Text            =   "1"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   50
      Left            =   840
      MaxLength       =   1
      TabIndex        =   44
      Text            =   "2"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   51
      Left            =   1080
      MaxLength       =   1
      TabIndex        =   43
      Text            =   "3"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   52
      Left            =   1320
      MaxLength       =   1
      TabIndex        =   42
      Text            =   "4"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   53
      Left            =   1560
      MaxLength       =   1
      TabIndex        =   41
      Text            =   "5"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   54
      Left            =   1800
      MaxLength       =   1
      TabIndex        =   40
      Text            =   "6"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   55
      Left            =   2040
      MaxLength       =   1
      TabIndex        =   39
      Text            =   "7"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   56
      Left            =   2280
      MaxLength       =   1
      TabIndex        =   38
      Text            =   "8"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   57
      Left            =   2520
      MaxLength       =   1
      TabIndex        =   37
      Text            =   "9"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   58
      Left            =   2760
      MaxLength       =   1
      TabIndex        =   36
      Text            =   ":"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   59
      Left            =   3000
      MaxLength       =   1
      TabIndex        =   35
      Text            =   ";"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   60
      Left            =   3240
      MaxLength       =   1
      TabIndex        =   34
      Text            =   "<"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   62
      Left            =   3720
      MaxLength       =   1
      TabIndex        =   33
      Text            =   ">"
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   61
      Left            =   3480
      MaxLength       =   1
      TabIndex        =   32
      Text            =   "="
      Top             =   600
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   46
      Left            =   3720
      MaxLength       =   1
      TabIndex        =   13
      Text            =   "."
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      BackColor       =   &H8000000F&
      Enabled         =   0   'False
      Height          =   285
      Index           =   32
      Left            =   360
      MaxLength       =   1
      TabIndex        =   15
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   47
      Left            =   3960
      MaxLength       =   1
      TabIndex        =   14
      Text            =   "/"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   45
      Left            =   3480
      MaxLength       =   1
      TabIndex        =   12
      Text            =   "-"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   44
      Left            =   3240
      MaxLength       =   1
      TabIndex        =   11
      Text            =   ","
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   43
      Left            =   3000
      MaxLength       =   1
      TabIndex        =   10
      Text            =   "+"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   42
      Left            =   2760
      MaxLength       =   1
      TabIndex        =   9
      Text            =   "*"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   41
      Left            =   2520
      MaxLength       =   1
      TabIndex        =   8
      Text            =   ")"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   40
      Left            =   2280
      MaxLength       =   1
      TabIndex        =   7
      Text            =   "("
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   39
      Left            =   2040
      MaxLength       =   1
      TabIndex        =   6
      Text            =   "'"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   38
      Left            =   1800
      MaxLength       =   1
      TabIndex        =   5
      Text            =   "&"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   37
      Left            =   1560
      MaxLength       =   1
      TabIndex        =   4
      Text            =   "%"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   36
      Left            =   1320
      MaxLength       =   1
      TabIndex        =   3
      Text            =   "$"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   35
      Left            =   1080
      MaxLength       =   1
      TabIndex        =   2
      Text            =   "#"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   34
      Left            =   840
      MaxLength       =   1
      TabIndex        =   1
      Text            =   """"
      Top             =   360
      Width           =   255
   End
   Begin VB.TextBox tabs 
      Alignment       =   2  'Центровка
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   33
      Left            =   600
      MaxLength       =   1
      TabIndex        =   0
      Text            =   "!"
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "7"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   21
      Left            =   120
      TabIndex        =   117
      Top             =   1560
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "6"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   20
      Left            =   120
      TabIndex        =   116
      Top             =   1320
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "5"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   19
      Left            =   120
      TabIndex        =   115
      Top             =   1080
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "4"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   18
      Left            =   120
      TabIndex        =   114
      Top             =   840
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "3"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   17
      Left            =   120
      TabIndex        =   48
      Top             =   600
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "2"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   16
      Left            =   120
      TabIndex        =   47
      Top             =   360
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "F"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   15
      Left            =   3960
      TabIndex        =   31
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "E"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   14
      Left            =   3720
      TabIndex        =   30
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "D"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   13
      Left            =   3480
      TabIndex        =   29
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "C"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   12
      Left            =   3240
      TabIndex        =   28
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "B"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   11
      Left            =   3000
      TabIndex        =   27
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "A"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   10
      Left            =   2760
      TabIndex        =   26
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "9"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   9
      Left            =   2520
      TabIndex        =   25
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "8"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   8
      Left            =   2280
      TabIndex        =   24
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "7"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   7
      Left            =   2040
      TabIndex        =   23
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "6"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   6
      Left            =   1800
      TabIndex        =   22
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "5"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   5
      Left            =   1560
      TabIndex        =   21
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "4"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   4
      Left            =   1320
      TabIndex        =   20
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "3"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   3
      Left            =   1080
      TabIndex        =   19
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "2"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   2
      Left            =   840
      TabIndex        =   18
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   1
      Left            =   600
      TabIndex        =   17
      Top             =   120
      Width           =   255
   End
   Begin VB.Label Hx 
      Alignment       =   2  'Центровка
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Index           =   0
      Left            =   360
      TabIndex        =   16
      Top             =   120
      Width           =   255
   End
End
Attribute VB_Name = "TabEdit"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
If file1 = "" Then GoTo er
pth = InStrRev(file1, "\")
If pth <> 0 Then
    pth2 = Right(file1, Len(file1) - pth)
Else
    pth2 = file1
End If
'MsgBox pth2 & "_-_" & Dir(file1)
If Not pth2 = Dir(file1) Then GoTo er
    
GoTo beg
er:
    MsgBox "Указанный файл не существует!", , "Ошибка!"
    GoTo error

beg:

Dim lin As String

Open file1 For Input As 1

For n = 33 To 126
    tabs(n) = ""
Next n

While Not EOF(1)
    Line Input #1, lin
    If Len(lin) = 4 Then
        If Mid(lin, 3, 1) = "=" Then
            If Val("&H" + Left(lin, 2)) > 32 And Val("&H" + Left(lin, 2)) < 127 Then
                tabs(Val("&H" + Left(lin, 2))) = Right(lin, 1)
            End If
        End If
    End If
Wend

Close
            
If Not ReTab = False Then
    For n = 33 To 126
        If tabs(n) = "" Then
            tabs(n) = Chr(n)
        End If
    Next n
End If
        
    
    


error:
End Sub



Private Sub Command10_Click()
Dim table(33 To 126) As Integer

For n = 33 To 125
    If tabs(n) <> "" Then
        table(n + 1) = Asc(tabs(n))
    Else
        table(n + 1) = 256
    End If
Next n

If tabs(126) = "" Then
    table(33) = 256
Else
    table(33) = Asc(tabs(126))
End If

For n = 33 To 126
    If table(n) < 256 Then
        tabs(n) = Chr(table(n))
    Else
        tabs(n) = ""
    End If
Next n

End Sub



Private Sub Command2_Click()



If file1 = "" Then
    MsgBox "Введите путь к файлу!", , "Ошибка!"
    GoTo error1
End If

pth = InStrRev(file1, "\")
If pth <> 0 Then
    pth2 = Right(file1, Len(file1) - pth)
Else
    pth2 = file1
End If

If pth2 = Dir(file1) Then
    q = MsgBox("Файл уже существует, перезаписать?", vbYesNo, "Файл уже существует")
    If q = 7 Then GoTo error1
End If



Open file1 For Output As 1

For n = 33 To 126
   If Not tabs(n) = "" Then
        Print #1, Hex(n) & "=" & tabs(n)
    End If
Next n
Close

error1:
End Sub

Private Sub Command3_Click()
For n = 33 To 126
    tabs(n) = Chr(n)
Next n
End Sub

Private Sub Command5_Click()
For n = 33 To 126
    tabs(n) = ""
Next n
End Sub

Private Sub Command6_Click()
For n = 33 To 126
    If tabs(n) = "" Then
        tabs(n) = Chr(n)
    End If
Next n
End Sub

Private Sub Command7_Click()
For n = 33 To 126
    If tabs(n) = Chr(n) Then
        tabs(n) = ""
    End If
Next n
End Sub

Private Sub Command8_Click()
For n = 33 To 126
    If Not tabs(n) = "" Then
        If Not Asc(tabs(n)) = n Then
            tabs(n) = ""
        End If
    End If
Next n
End Sub

Private Sub Command9_Click()
Dim table(33 To 126) As Integer

For n = 34 To 126
    If tabs(n) <> "" Then
        table(n - 1) = Asc(tabs(n))
    Else
        table(n - 1) = 256
    End If
Next n
'table(126) = Asc(tabs(33))

If tabs(126) = "" Then
    table(126) = 256
Else
    table(126) = Asc(tabs(33))
End If


For n = 33 To 126
    If table(n) < 256 Then
        tabs(n) = Chr(table(n))
    Else
        tabs(n) = ""
    End If
Next n
End Sub

Private Sub tabs_Change(Index As Integer)
If Not TxtChn = False Then
    If Not tabs(Index) = "" Then
        If Index = 126 Then
            tabs(33).SetFocus
        Else
            tabs(Index + 1).SetFocus
        End If
    End If
    If Not SndKys = False Then
        SendKeys "{Home}"
        SendKeys "+{End}" '+{Shift}"
    End If
End If
End Sub

Private Sub tabs_Click(Index As Integer)
'tabs.SetFocus
If Not SndKys = False Then
    SendKeys "{Home}"
    SendKeys "+{End}" '+{Shift}"
End If



End Sub

Private Sub tabs_GotFocus(Index As Integer)
    tabs(Index).BackColor = &HC0C0FF
    '---'
Hx((Index - 32) \ 16 + 16).ForeColor = &HC0&
Hx(Index - (Index \ 16) * 16).ForeColor = &HC0&
    '---'
For t = Index To 33 Step -16
    If Not Index = t Then
    If Not t = 32 Then
        tabs(t).BackColor = &H80000014
    End If
    End If
Next t

For t = (Index \ 16) * 16 To Index - 1
    If Not Index = t Then
    If Not t = 32 Then
        tabs(t).BackColor = &H80000014
        'MsgBox Index & "   " & t
    End If
    End If
Next t
    
End Sub

Private Sub tabs_LostFocus(Index As Integer)
tabs(Index).BackColor = &H80000005

Hx((Index - 32) \ 16 + 16).ForeColor = 0
Hx(Index - (Index \ 16) * 16).ForeColor = 0

For t = Index To 33 Step -16
    If Not Index = t Then
    If Not t = 32 Then
        tabs(t).BackColor = &H80000005
    End If
    End If
Next t

For t = (Index \ 16) * 16 To Index - 1
    If Not Index = t Then
    If Not t = 32 Then
        tabs(t).BackColor = &H80000005
    End If
    End If
Next t

End Sub
