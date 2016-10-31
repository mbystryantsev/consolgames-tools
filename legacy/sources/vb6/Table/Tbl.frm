VERSION 5.00
Begin VB.Form MainForm 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Редактор обычных/DTE/MTE таблиц"
   ClientHeight    =   9690
   ClientLeft      =   1635
   ClientTop       =   780
   ClientWidth     =   11445
   Icon            =   "Tbl.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   9690
   ScaleWidth      =   11445
   Begin VB.CommandButton Command24 
      Caption         =   "Редактор DTE словаря"
      Height          =   435
      Left            =   120
      TabIndex        =   344
      Top             =   9120
      Width           =   1935
   End
   Begin VB.OptionButton Option5 
      Caption         =   ">"
      Height          =   255
      Left            =   8160
      Style           =   1  'Graphical
      TabIndex        =   321
      Top             =   6240
      Width           =   255
   End
   Begin VB.Frame Frame4 
      Caption         =   "Интерфейс:"
      Height          =   1215
      Left            =   6120
      TabIndex        =   341
      Top             =   7680
      Width           =   5175
      Begin VB.Label Label6 
         Alignment       =   2  'Центровка
         Caption         =   "Тута будут настройки цветов"
         Height          =   255
         Left            =   360
         TabIndex        =   342
         Top             =   600
         Width           =   4455
      End
   End
   Begin VB.CommandButton Command23 
      Caption         =   "^^^  Убрать длиной"
      Enabled         =   0   'False
      Height          =   255
      Left            =   9240
      TabIndex        =   339
      Top             =   6960
      Width           =   2055
   End
   Begin VB.CommandButton Command22 
      Caption         =   "Выделить длиной  ^^^"
      Enabled         =   0   'False
      Height          =   255
      Left            =   6960
      TabIndex        =   338
      Top             =   6960
      Width           =   2175
   End
   Begin VB.CommandButton Command21 
      Caption         =   "Выделить всё"
      Enabled         =   0   'False
      Height          =   255
      Left            =   4680
      TabIndex        =   337
      Top             =   6960
      Width           =   2175
   End
   Begin VB.CommandButton Command20 
      Caption         =   "Убрать"
      Enabled         =   0   'False
      Height          =   255
      Left            =   2400
      TabIndex        =   336
      Top             =   6960
      Width           =   2175
   End
   Begin VB.CommandButton Command19 
      Caption         =   "Инвертировать"
      Enabled         =   0   'False
      Height          =   255
      Left            =   240
      TabIndex        =   335
      Top             =   6960
      Width           =   2055
   End
   Begin VB.CheckBox Sel 
      Caption         =   "Режим выделения"
      ForeColor       =   &H00000040&
      Height          =   255
      Left            =   120
      TabIndex        =   332
      Top             =   6720
      Width           =   1815
   End
   Begin VB.CommandButton Command17 
      Caption         =   "-"
      Height          =   135
      Left            =   9120
      TabIndex        =   329
      Top             =   6360
      Width           =   255
   End
   Begin VB.CommandButton Command15 
      Caption         =   "+"
      Height          =   135
      Left            =   9120
      TabIndex        =   328
      Top             =   6240
      Width           =   255
   End
   Begin VB.TextBox ForClear 
      Height          =   285
      Left            =   9720
      TabIndex        =   326
      Top             =   6240
      Width           =   1695
   End
   Begin VB.TextBox LenForClear 
      Height          =   285
      Left            =   8520
      TabIndex        =   325
      Text            =   "0"
      Top             =   6240
      Width           =   615
   End
   Begin VB.OptionButton Option4 
      Caption         =   ">="
      Height          =   255
      Left            =   7800
      Style           =   1  'Graphical
      TabIndex        =   324
      Top             =   6240
      Width           =   375
   End
   Begin VB.OptionButton Option3 
      Caption         =   "="
      Height          =   255
      Left            =   7560
      Style           =   1  'Graphical
      TabIndex        =   323
      Top             =   6240
      Value           =   -1  'True
      Width           =   255
   End
   Begin VB.OptionButton Option2 
      Caption         =   "<="
      Height          =   255
      Left            =   7200
      Style           =   1  'Graphical
      TabIndex        =   322
      Top             =   6240
      Width           =   375
   End
   Begin VB.OptionButton Option1 
      Caption         =   "<"
      Height          =   255
      Left            =   6960
      Style           =   1  'Graphical
      TabIndex        =   320
      Top             =   6240
      Width           =   255
   End
   Begin VB.CommandButton Command16 
      Caption         =   "Заменить длиной >>>"
      Height          =   255
      Left            =   4680
      TabIndex        =   319
      Top             =   6240
      Width           =   2175
   End
   Begin VB.CommandButton Command14 
      Caption         =   "Помощь..."
      Height          =   255
      Left            =   2400
      TabIndex        =   318
      Top             =   6240
      Width           =   2175
   End
   Begin VB.CommandButton Command13 
      Caption         =   "Количество ячеек"
      Height          =   255
      Left            =   240
      TabIndex        =   317
      Top             =   6240
      Width           =   1935
   End
   Begin VB.CommandButton Command12 
      Caption         =   "Сдвинуть вправо ->"
      Height          =   255
      Left            =   9240
      TabIndex        =   316
      Top             =   5880
      Width           =   2175
   End
   Begin VB.CommandButton Command11 
      Caption         =   "<- Сдвинуть влево"
      Height          =   255
      Left            =   9240
      TabIndex        =   315
      Top             =   5520
      Width           =   2175
   End
   Begin VB.CommandButton Command10 
      Caption         =   "Очистить "
      Height          =   255
      Left            =   2400
      TabIndex        =   314
      Top             =   5880
      Width           =   2175
   End
   Begin VB.CommandButton Command9 
      Caption         =   "Сохранить таблицу..."
      Height          =   255
      Left            =   4680
      TabIndex        =   258
      Top             =   5880
      Width           =   2175
   End
   Begin VB.CommandButton Command8 
      Caption         =   "Показать всю таблицу"
      Height          =   255
      Left            =   6960
      TabIndex        =   260
      Top             =   5880
      Width           =   2175
   End
   Begin VB.CommandButton Command7 
      Caption         =   "Показать таблицу"
      Height          =   255
      Left            =   6960
      TabIndex        =   259
      Top             =   5520
      Width           =   2175
   End
   Begin VB.CommandButton Command6 
      Caption         =   "Нет"
      Height          =   255
      Left            =   1080
      TabIndex        =   311
      Top             =   5880
      Width           =   1095
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Загрузить таблицу..."
      Height          =   255
      Left            =   4680
      TabIndex        =   257
      Top             =   5520
      Width           =   2175
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Выбрать..."
      Height          =   255
      Left            =   1080
      TabIndex        =   309
      Top             =   5640
      Width           =   1095
   End
   Begin VB.TextBox FirstIndex 
      Alignment       =   2  'Центровка
      BackColor       =   &H8000000B&
      Height          =   285
      Left            =   240
      Locked          =   -1  'True
      MaxLength       =   2
      TabIndex        =   308
      Text            =   "--"
      Top             =   5640
      Width           =   735
   End
   Begin VB.TextBox Word2 
      BackColor       =   &H8000000B&
      Height          =   285
      Left            =   3960
      Locked          =   -1  'True
      TabIndex        =   300
      Top             =   5040
      Width           =   5415
   End
   Begin VB.TextBox Word 
      Height          =   285
      Left            =   3960
      TabIndex        =   256
      Top             =   4680
      Width           =   5415
   End
   Begin VB.CheckBox SndKys 
      Caption         =   "Автоматически выделять содержимое ячейки."
      Height          =   255
      Left            =   360
      TabIndex        =   295
      Top             =   8040
      Width           =   4695
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   255
      Left            =   10680
      TabIndex        =   255
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   254
      Left            =   9990
      TabIndex        =   254
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   253
      Left            =   9300
      TabIndex        =   253
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   252
      Left            =   8610
      TabIndex        =   252
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   251
      Left            =   7920
      TabIndex        =   251
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   250
      Left            =   7230
      TabIndex        =   250
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   249
      Left            =   6540
      TabIndex        =   249
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   248
      Left            =   5850
      TabIndex        =   248
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   247
      Left            =   5160
      TabIndex        =   247
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   246
      Left            =   4470
      TabIndex        =   246
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   245
      Left            =   3780
      TabIndex        =   245
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   244
      Left            =   3090
      TabIndex        =   244
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   243
      Left            =   2400
      TabIndex        =   243
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   242
      Left            =   1710
      TabIndex        =   242
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   241
      Left            =   1020
      TabIndex        =   241
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   240
      Left            =   330
      TabIndex        =   240
      Top             =   4320
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   239
      Left            =   10680
      TabIndex        =   239
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   238
      Left            =   9990
      TabIndex        =   238
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   237
      Left            =   9300
      TabIndex        =   237
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   236
      Left            =   8610
      TabIndex        =   236
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   235
      Left            =   7920
      TabIndex        =   235
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   234
      Left            =   7230
      TabIndex        =   234
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   233
      Left            =   6540
      TabIndex        =   233
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   232
      Left            =   5850
      TabIndex        =   232
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   231
      Left            =   5160
      TabIndex        =   231
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   230
      Left            =   4470
      TabIndex        =   230
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   229
      Left            =   3780
      TabIndex        =   229
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   228
      Left            =   3090
      TabIndex        =   228
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   227
      Left            =   2400
      TabIndex        =   227
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   226
      Left            =   1710
      TabIndex        =   226
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   225
      Left            =   1020
      TabIndex        =   225
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   224
      Left            =   330
      TabIndex        =   224
      Top             =   4050
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   223
      Left            =   10680
      TabIndex        =   223
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   222
      Left            =   9990
      TabIndex        =   222
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   221
      Left            =   9300
      TabIndex        =   221
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   220
      Left            =   8610
      TabIndex        =   220
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   219
      Left            =   7920
      TabIndex        =   219
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   218
      Left            =   7230
      TabIndex        =   218
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   217
      Left            =   6540
      TabIndex        =   217
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   216
      Left            =   5850
      TabIndex        =   216
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   215
      Left            =   5160
      TabIndex        =   215
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   214
      Left            =   4470
      TabIndex        =   214
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   213
      Left            =   3780
      TabIndex        =   213
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   212
      Left            =   3090
      TabIndex        =   212
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   211
      Left            =   2400
      TabIndex        =   211
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   210
      Left            =   1710
      TabIndex        =   210
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   209
      Left            =   1020
      TabIndex        =   209
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   208
      Left            =   330
      TabIndex        =   208
      Top             =   3780
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   207
      Left            =   10680
      TabIndex        =   207
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   206
      Left            =   9990
      TabIndex        =   206
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   205
      Left            =   9300
      TabIndex        =   205
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   204
      Left            =   8610
      TabIndex        =   204
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   203
      Left            =   7920
      TabIndex        =   203
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   202
      Left            =   7230
      TabIndex        =   202
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   201
      Left            =   6540
      TabIndex        =   201
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   200
      Left            =   5850
      TabIndex        =   200
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   199
      Left            =   5160
      TabIndex        =   199
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   198
      Left            =   4470
      TabIndex        =   198
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   197
      Left            =   3780
      TabIndex        =   197
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   196
      Left            =   3090
      TabIndex        =   196
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   195
      Left            =   2400
      TabIndex        =   195
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   194
      Left            =   1710
      TabIndex        =   194
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   193
      Left            =   1020
      TabIndex        =   193
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   192
      Left            =   330
      TabIndex        =   192
      Top             =   3510
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   191
      Left            =   10680
      TabIndex        =   191
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   190
      Left            =   9990
      TabIndex        =   190
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   189
      Left            =   9300
      TabIndex        =   189
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   188
      Left            =   8610
      TabIndex        =   188
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   187
      Left            =   7920
      TabIndex        =   187
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   186
      Left            =   7230
      TabIndex        =   186
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   185
      Left            =   6540
      TabIndex        =   185
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   184
      Left            =   5850
      TabIndex        =   184
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   183
      Left            =   5160
      TabIndex        =   183
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   182
      Left            =   4470
      TabIndex        =   182
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   181
      Left            =   3780
      TabIndex        =   181
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   180
      Left            =   3090
      TabIndex        =   180
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   179
      Left            =   2400
      TabIndex        =   179
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   178
      Left            =   1710
      TabIndex        =   178
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   177
      Left            =   1020
      TabIndex        =   177
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   176
      Left            =   330
      TabIndex        =   176
      Top             =   3240
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   175
      Left            =   10680
      TabIndex        =   175
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   174
      Left            =   9990
      TabIndex        =   174
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   173
      Left            =   9300
      TabIndex        =   173
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   172
      Left            =   8610
      TabIndex        =   172
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   171
      Left            =   7920
      TabIndex        =   171
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   170
      Left            =   7230
      TabIndex        =   170
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   169
      Left            =   6540
      TabIndex        =   169
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   168
      Left            =   5850
      TabIndex        =   168
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   167
      Left            =   5160
      TabIndex        =   167
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   166
      Left            =   4470
      TabIndex        =   166
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   165
      Left            =   3780
      TabIndex        =   165
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   164
      Left            =   3090
      TabIndex        =   164
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   163
      Left            =   2400
      TabIndex        =   163
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   162
      Left            =   1710
      TabIndex        =   162
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   161
      Left            =   1020
      TabIndex        =   161
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   160
      Left            =   330
      TabIndex        =   160
      Top             =   2970
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   159
      Left            =   10680
      TabIndex        =   159
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   158
      Left            =   9990
      TabIndex        =   158
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   157
      Left            =   9300
      TabIndex        =   157
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   156
      Left            =   8610
      TabIndex        =   156
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   155
      Left            =   7920
      TabIndex        =   155
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   154
      Left            =   7230
      TabIndex        =   154
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   153
      Left            =   6540
      TabIndex        =   153
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   152
      Left            =   5850
      TabIndex        =   152
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   151
      Left            =   5160
      TabIndex        =   151
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   150
      Left            =   4470
      TabIndex        =   150
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   149
      Left            =   3780
      TabIndex        =   149
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   148
      Left            =   3090
      TabIndex        =   148
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   147
      Left            =   2400
      TabIndex        =   147
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   146
      Left            =   1710
      TabIndex        =   146
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   145
      Left            =   1020
      TabIndex        =   145
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   144
      Left            =   330
      TabIndex        =   144
      Top             =   2700
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   143
      Left            =   10680
      TabIndex        =   143
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   142
      Left            =   9990
      TabIndex        =   142
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   141
      Left            =   9300
      TabIndex        =   141
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   140
      Left            =   8610
      TabIndex        =   140
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   139
      Left            =   7920
      TabIndex        =   139
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   138
      Left            =   7230
      TabIndex        =   138
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   137
      Left            =   6540
      TabIndex        =   137
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   136
      Left            =   5850
      TabIndex        =   136
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   135
      Left            =   5160
      TabIndex        =   135
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   134
      Left            =   4470
      TabIndex        =   134
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   133
      Left            =   3780
      TabIndex        =   133
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   132
      Left            =   3090
      TabIndex        =   132
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   131
      Left            =   2400
      TabIndex        =   131
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   130
      Left            =   1710
      TabIndex        =   130
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   129
      Left            =   1020
      TabIndex        =   129
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   128
      Left            =   330
      TabIndex        =   128
      Top             =   2430
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   127
      Left            =   10680
      TabIndex        =   127
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   126
      Left            =   9990
      TabIndex        =   126
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   125
      Left            =   9300
      TabIndex        =   125
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   124
      Left            =   8610
      TabIndex        =   124
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   123
      Left            =   7920
      TabIndex        =   123
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   122
      Left            =   7230
      TabIndex        =   122
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   121
      Left            =   6540
      TabIndex        =   121
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   120
      Left            =   5850
      TabIndex        =   120
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   119
      Left            =   5160
      TabIndex        =   119
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   118
      Left            =   4470
      TabIndex        =   118
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   117
      Left            =   3780
      TabIndex        =   117
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   116
      Left            =   3090
      TabIndex        =   116
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   115
      Left            =   2400
      TabIndex        =   115
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   114
      Left            =   1710
      TabIndex        =   114
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   113
      Left            =   1020
      TabIndex        =   113
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   112
      Left            =   330
      TabIndex        =   112
      Top             =   2160
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   111
      Left            =   10680
      TabIndex        =   111
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   110
      Left            =   9990
      TabIndex        =   110
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   109
      Left            =   9300
      TabIndex        =   109
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   108
      Left            =   8610
      TabIndex        =   108
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   107
      Left            =   7920
      TabIndex        =   107
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   106
      Left            =   7230
      TabIndex        =   106
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   105
      Left            =   6540
      TabIndex        =   105
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   104
      Left            =   5850
      TabIndex        =   104
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   103
      Left            =   5160
      TabIndex        =   103
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   102
      Left            =   4470
      TabIndex        =   102
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   101
      Left            =   3780
      TabIndex        =   101
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   100
      Left            =   3090
      TabIndex        =   100
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   99
      Left            =   2400
      TabIndex        =   99
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   98
      Left            =   1710
      TabIndex        =   98
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   97
      Left            =   1020
      TabIndex        =   97
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   96
      Left            =   330
      TabIndex        =   96
      Top             =   1890
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   95
      Left            =   10680
      TabIndex        =   95
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   94
      Left            =   9990
      TabIndex        =   94
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   93
      Left            =   9300
      TabIndex        =   93
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   92
      Left            =   8610
      TabIndex        =   92
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   91
      Left            =   7920
      TabIndex        =   91
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   90
      Left            =   7230
      TabIndex        =   90
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   89
      Left            =   6540
      TabIndex        =   89
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   88
      Left            =   5850
      TabIndex        =   88
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   87
      Left            =   5160
      TabIndex        =   87
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   86
      Left            =   4470
      TabIndex        =   86
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   85
      Left            =   3780
      TabIndex        =   85
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   84
      Left            =   3090
      TabIndex        =   84
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   83
      Left            =   2400
      TabIndex        =   83
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   82
      Left            =   1710
      TabIndex        =   82
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   81
      Left            =   1020
      TabIndex        =   81
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   80
      Left            =   330
      TabIndex        =   80
      Top             =   1620
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   79
      Left            =   10680
      TabIndex        =   79
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   78
      Left            =   9990
      TabIndex        =   78
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   77
      Left            =   9300
      TabIndex        =   77
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   76
      Left            =   8610
      TabIndex        =   76
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   75
      Left            =   7920
      TabIndex        =   75
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   74
      Left            =   7230
      TabIndex        =   74
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   73
      Left            =   6540
      TabIndex        =   73
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   72
      Left            =   5850
      TabIndex        =   72
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   71
      Left            =   5160
      TabIndex        =   71
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   70
      Left            =   4470
      TabIndex        =   70
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   69
      Left            =   3780
      TabIndex        =   69
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   68
      Left            =   3090
      TabIndex        =   68
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   67
      Left            =   2400
      TabIndex        =   67
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   66
      Left            =   1710
      TabIndex        =   66
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   65
      Left            =   1020
      TabIndex        =   65
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   64
      Left            =   330
      TabIndex        =   64
      Top             =   1350
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   63
      Left            =   10680
      TabIndex        =   63
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   62
      Left            =   9990
      TabIndex        =   62
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   61
      Left            =   9300
      TabIndex        =   61
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   60
      Left            =   8610
      TabIndex        =   60
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   59
      Left            =   7920
      TabIndex        =   59
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   58
      Left            =   7230
      TabIndex        =   58
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   57
      Left            =   6540
      TabIndex        =   57
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   56
      Left            =   5850
      TabIndex        =   56
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   55
      Left            =   5160
      TabIndex        =   55
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   54
      Left            =   4470
      TabIndex        =   54
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   53
      Left            =   3780
      TabIndex        =   53
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   52
      Left            =   3090
      TabIndex        =   52
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   51
      Left            =   2400
      TabIndex        =   51
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   50
      Left            =   1710
      TabIndex        =   50
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   49
      Left            =   1020
      TabIndex        =   49
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   48
      Left            =   330
      TabIndex        =   48
      Top             =   1080
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   47
      Left            =   10680
      TabIndex        =   47
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   46
      Left            =   9990
      TabIndex        =   46
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   45
      Left            =   9300
      TabIndex        =   45
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   44
      Left            =   8610
      TabIndex        =   44
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   43
      Left            =   7920
      TabIndex        =   43
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   42
      Left            =   7230
      TabIndex        =   42
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   41
      Left            =   6540
      TabIndex        =   41
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   40
      Left            =   5850
      TabIndex        =   40
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   39
      Left            =   5160
      TabIndex        =   39
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   38
      Left            =   4470
      TabIndex        =   38
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   37
      Left            =   3780
      TabIndex        =   37
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   36
      Left            =   3090
      TabIndex        =   36
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   35
      Left            =   2400
      TabIndex        =   35
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   34
      Left            =   1710
      TabIndex        =   34
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   33
      Left            =   1020
      TabIndex        =   33
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   32
      Left            =   330
      TabIndex        =   32
      Top             =   810
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   31
      Left            =   10680
      TabIndex        =   31
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   30
      Left            =   9990
      TabIndex        =   30
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   29
      Left            =   9300
      TabIndex        =   29
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   28
      Left            =   8610
      TabIndex        =   28
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   27
      Left            =   7920
      TabIndex        =   27
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   26
      Left            =   7230
      TabIndex        =   26
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   25
      Left            =   6540
      TabIndex        =   25
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   24
      Left            =   5850
      TabIndex        =   24
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   23
      Left            =   5160
      TabIndex        =   23
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   22
      Left            =   4470
      TabIndex        =   22
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   21
      Left            =   3780
      TabIndex        =   21
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   20
      Left            =   3090
      TabIndex        =   20
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   19
      Left            =   2400
      TabIndex        =   19
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   18
      Left            =   1710
      TabIndex        =   18
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   17
      Left            =   1020
      TabIndex        =   17
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   16
      Left            =   330
      TabIndex        =   16
      Top             =   540
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   15
      Left            =   10680
      TabIndex        =   15
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   14
      Left            =   9990
      TabIndex        =   14
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   13
      Left            =   9300
      TabIndex        =   13
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   12
      Left            =   8610
      TabIndex        =   12
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   11
      Left            =   7920
      TabIndex        =   11
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   10
      Left            =   7230
      TabIndex        =   10
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   9
      Left            =   6540
      TabIndex        =   9
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   8
      Left            =   5850
      TabIndex        =   8
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   7
      Left            =   5160
      TabIndex        =   7
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   6
      Left            =   4470
      TabIndex        =   6
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   5
      Left            =   3780
      TabIndex        =   5
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   4
      Left            =   3090
      TabIndex        =   4
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   3
      Left            =   2400
      TabIndex        =   3
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   2
      Left            =   1710
      TabIndex        =   2
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   1
      Left            =   1020
      TabIndex        =   1
      Top             =   285
      Width           =   700
   End
   Begin VB.TextBox Wr 
      Appearance      =   0  'Плоска
      Height          =   285
      Index           =   0
      Left            =   330
      TabIndex        =   0
      Top             =   285
      Width           =   700
   End
   Begin VB.CheckBox TxtChn 
      Caption         =   "При изменении содержимого ячейки переходить в следующую."
      Height          =   255
      Left            =   360
      TabIndex        =   278
      Top             =   7800
      Width           =   6735
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Стандартная кодировка"
      Height          =   255
      Left            =   2400
      TabIndex        =   261
      Top             =   5520
      Width           =   2175
   End
   Begin VB.Frame Frame2 
      Caption         =   "Опции:"
      Height          =   1575
      Left            =   120
      TabIndex        =   313
      Top             =   7440
      Width           =   11295
      Begin VB.CheckBox BckScp 
         Caption         =   "При пустой ячейке и нажатии Backspace переходить в предыдущую."
         Height          =   255
         Left            =   240
         TabIndex        =   343
         Top             =   840
         Width           =   5655
      End
   End
   Begin VB.CommandButton WrFCS 
      Caption         =   "ForeColor Sel"
      Height          =   255
      Left            =   4320
      TabIndex        =   330
      Top             =   7680
      Width           =   1815
   End
   Begin VB.CommandButton WrFCC 
      Caption         =   "WrForeColorCross"
      Height          =   255
      Left            =   4440
      TabIndex        =   331
      Top             =   8040
      Width           =   1695
   End
   Begin VB.CommandButton WrBSS 
      Caption         =   "WrSelSelBack"
      Height          =   255
      Left            =   4440
      TabIndex        =   333
      Top             =   8400
      Width           =   1695
   End
   Begin VB.CommandButton Command18 
      Caption         =   "Command18"
      Height          =   255
      Left            =   6360
      TabIndex        =   334
      Top             =   7920
      Width           =   615
   End
   Begin VB.Frame Frame3 
      Height          =   615
      Left            =   120
      TabIndex        =   340
      Top             =   6720
      Width           =   11295
   End
   Begin VB.CommandButton Command2 
      Caption         =   ">"
      Height          =   255
      Left            =   600
      TabIndex        =   307
      Top             =   5880
      Width           =   375
   End
   Begin VB.CommandButton Command3 
      Caption         =   "<"
      Height          =   255
      Left            =   240
      TabIndex        =   310
      Top             =   5880
      Width           =   375
   End
   Begin VB.Frame Frame1 
      Caption         =   "Старший байт:"
      Height          =   1215
      Left            =   120
      TabIndex        =   312
      Top             =   5400
      Width           =   2175
   End
   Begin VB.Label Label5 
      Caption         =   "На:"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   9400
      TabIndex        =   327
      Top             =   6240
      Width           =   375
   End
   Begin VB.Label Label4 
      Alignment       =   1  'Правая привязка
      Caption         =   "Ячейка с наведённым курсором:"
      Height          =   255
      Left            =   -120
      TabIndex        =   306
      Top             =   5090
      Width           =   2655
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Правая привязка
      Caption         =   "Текущая ячейка:"
      Height          =   255
      Left            =   240
      TabIndex        =   305
      Top             =   4725
      Width           =   2295
   End
   Begin VB.Label HexIndex2 
      Alignment       =   1  'Правая привязка
      Caption         =   "<Нет>"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   2400
      TabIndex        =   304
      Top             =   5040
      Width           =   975
   End
   Begin VB.Label Label22 
      Alignment       =   2  'Центровка
      Caption         =   "="
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   3360
      TabIndex        =   303
      Top             =   5040
      Width           =   615
   End
   Begin VB.Label Label32 
      Caption         =   "Длина строки:"
      Height          =   255
      Left            =   9480
      TabIndex        =   302
      Top             =   5040
      Width           =   1215
   End
   Begin VB.Label LenOfString2 
      Caption         =   "<Нет>"
      Height          =   255
      Left            =   10800
      TabIndex        =   301
      Top             =   5040
      Width           =   615
   End
   Begin VB.Label LenOfString 
      Caption         =   "<Нет>"
      Height          =   255
      Left            =   10800
      TabIndex        =   299
      Top             =   4680
      Width           =   615
   End
   Begin VB.Label Label3 
      Caption         =   "Длина строки:"
      Height          =   255
      Left            =   9480
      TabIndex        =   298
      Top             =   4680
      Width           =   1215
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Центровка
      Caption         =   "="
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   3480
      TabIndex        =   297
      Top             =   4680
      Width           =   375
   End
   Begin VB.Label HexIndex 
      Alignment       =   1  'Правая привязка
      Caption         =   "<Нет>"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   2520
      TabIndex        =   296
      Top             =   4680
      Width           =   855
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "F"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   15
      Left            =   10680
      TabIndex        =   294
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "E"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   14
      Left            =   9990
      TabIndex        =   293
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "D"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   13
      Left            =   9300
      TabIndex        =   292
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "C"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   12
      Left            =   8610
      TabIndex        =   291
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "B"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   11
      Left            =   7920
      TabIndex        =   290
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "A"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   10
      Left            =   7230
      TabIndex        =   289
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "9"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   9
      Left            =   6540
      TabIndex        =   288
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "8"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   8
      Left            =   5850
      TabIndex        =   287
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "7"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   7
      Left            =   5160
      TabIndex        =   286
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "6"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   6
      Left            =   4470
      TabIndex        =   285
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "5"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   5
      Left            =   3780
      TabIndex        =   284
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "4"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   4
      Left            =   3090
      TabIndex        =   283
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "3"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   3
      Left            =   2400
      TabIndex        =   282
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "2"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   2
      Left            =   1710
      TabIndex        =   281
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   1
      Left            =   1020
      TabIndex        =   280
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxx 
      Alignment       =   2  'Центровка
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   13.5
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   0
      Left            =   330
      TabIndex        =   279
      Top             =   0
      Width           =   705
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "F"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   15
      Left            =   0
      TabIndex        =   277
      Top             =   4320
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "E"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   14
      Left            =   0
      TabIndex        =   276
      Top             =   4050
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "D"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   13
      Left            =   0
      TabIndex        =   275
      Top             =   3780
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "C"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   12
      Left            =   0
      TabIndex        =   274
      Top             =   3510
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "B"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   11
      Left            =   0
      TabIndex        =   273
      Top             =   3240
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "A"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   10
      Left            =   0
      TabIndex        =   272
      Top             =   2970
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "9"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   9
      Left            =   0
      TabIndex        =   271
      Top             =   2700
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "8"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   8
      Left            =   0
      TabIndex        =   270
      Top             =   2430
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "7"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   7
      Left            =   0
      TabIndex        =   269
      Top             =   2160
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "6"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   6
      Left            =   0
      TabIndex        =   268
      Top             =   1890
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "5"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   5
      Left            =   0
      TabIndex        =   267
      Top             =   1620
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "4"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   4
      Left            =   0
      TabIndex        =   266
      Top             =   1350
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "3"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   3
      Left            =   0
      TabIndex        =   265
      Top             =   1080
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "2"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   2
      Left            =   0
      TabIndex        =   264
      Top             =   810
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "1"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   1
      Left            =   0
      TabIndex        =   263
      Top             =   540
      Width           =   375
   End
   Begin VB.Label hxy 
      Alignment       =   2  'Центровка
      Caption         =   "0"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   204
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Index           =   0
      Left            =   0
      TabIndex        =   262
      Top             =   270
      Width           =   375
   End
End
Attribute VB_Name = "MainForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False



Private Sub Command1_Click()
zapret = 1
For n = 32 To 255
    If Not Sel = False And SelWr(n) = True Or Sel = False Then
        Wr(n) = Chr(n)
    End If
Next
zapret = 0
End Sub






Private Sub Command10_Click()
If Not Sel = False Then
zapret = 1
For n = 0 To 255
    If SelWr(n) = True Then
        Wr(n) = ""
    End If
Next n
zapret = 0
Else
zapret = 1
For n = 0 To 255
    Wr(n) = ""
Next n
zapret = 0
End If
End Sub

Private Sub Command11_Click()
zapret = 1
If Not Sel = False Then
For n = 0 To 255
    If SelWr(n) = True Then
        w1 = n
        Exit For
    End If
Next n
For n = 255 To 0 Step -1
    If SelWr(n) = True Then
        w2 = n
        Exit For
    End If
Next n

'Next n

If Not w1 = w2 Then

For n = w1 + 1 To w2
    If SelWr(n) = True Then
        NEWtable(0, n) = Wr(n - 1)
    End If
Next n
If SelWr(w1) = True Then
    NEWtable(0, w1) = Wr(w2)
End If

For n = 0 To 255
    If SelWr(n) = True Then
        Wr(n) = NEWtable(0, n)
    End If
Next n

End If

Else
For n = 0 To 254
    NEWtable(0, n) = Wr(n + 1)
Next n

NEWtable(0, 255) = Wr(0)

For n = 0 To 255
    Wr(n) = NEWtable(0, n)
Next n
'Wr(0) = NEWtable(0, 256)
End If
zapret = 0
End Sub


Private Sub Command12_Click()
zapret = 1
For n = 0 To 255
    NEWtable(0, n + 1) = Wr(n)
Next n
For n = 1 To 255
    Wr(n) = NEWtable(0, n)
Next n
Wr(0) = NEWtable(0, 256)
zapret = 0
End Sub

Private Sub Command13_Click()
For n = 0 To 255
    If Not Table(TInd, n) = "" Then
        Sum = Sum + 1
    End If
Next n

If TInd = 256 Then
    If Sum = 0 Then
        MsgBox "Количество пустых ячеек без первого байта равно 256, заполненных нет"
    Else
        MsgBox "Количество заполненных ячеек без первого байта равно " & Sum & ", пустых " & 256 - Sum
    End If
Else
    If Sum = 0 Then
        MsgBox "Количество пустых ячеек с первым байтом " & Right("00" + Hex(TInd), 2) & " равно 256, заполненных нет"
    Else
        MsgBox "Количество заполненных ячеек с первым байтом " & Right("00" + Hex(TInd), 2) & " равно " & Sum & ", пустых " & 256 - Sum
    End If
End If
Sum = 0
End Sub

Private Sub Command14_Click()
Help.Show
End Sub

Private Sub Command15_Click()
LenForClear = Val(LenForClear) + 1
End Sub

Private Sub Command16_Click()

If Not Sel = False Then

If Option1 = True Then
    For n = 0 To 255
    If SelWr(n) = True Then
        If Len(Wr(n)) < LenForClear Then
            Wr(n) = ForClear
        End If
    End If
    Next n
ElseIf Option2 = True Then
    For n = 0 To 255
    If SelWr(n) = True Then
        If Len(Wr(n)) <= LenForClear Then
            Wr(n) = ForClear
        End If
    End If
    Next n
ElseIf Option3 = True Then
    For n = 0 To 255
    If SelWr(n) = True Then
        If Len(Wr(n)) = LenForClear Then
            Wr(n) = ForClear
        End If
    End If
    Next n
ElseIf Option4 = True Then
    For n = 0 To 255
    If SelWr(n) = True Then
        If Len(Wr(n)) >= LenForClear Then
            Wr(n) = ForClear
        End If
    End If
    Next n
ElseIf Option5 = True Then
    For n = 0 To 255
    If SelWr(n) = True Then
        If Len(Wr(n)) > LenForClear Then
            Wr(n) = ForClear
        End If
    End If
    Next n

End If

Else

If Option1 = True Then
    For n = 0 To 255
        If Len(Wr(n)) < LenForClear Then
            Wr(n) = ForClear
        End If
    Next n
ElseIf Option2 = True Then
    For n = 0 To 255
        If Len(Wr(n)) <= LenForClear Then
            Wr(n) = ForClear
        End If
    Next n
ElseIf Option3 = True Then
    For n = 0 To 255
        If Len(Wr(n)) = LenForClear Then
            Wr(n) = ForClear
        End If
    Next n
ElseIf Option4 = True Then
    For n = 0 To 255
        If Len(Wr(n)) >= LenForClear Then
            Wr(n) = ForClear
        End If
    Next n
ElseIf Option5 = True Then
    For n = 0 To 255
        If Len(Wr(n)) > LenForClear Then
            Wr(n) = ForClear
        End If
    Next n

End If

End If

End Sub

Private Sub Command17_Click()
If Val(LenForClear) > 0 Then
    LenForClear = Val(LenForClear) - 1
End If
End Sub





Private Sub Command18_Click()
s = ChoseC
End Sub

Private Sub Command19_Click()
For n = 0 To 255
    If SelWr(n) = True Then
        SelWr(n) = False
        Wr(n).BackColor = vid.StandartColor
    Else
        SelWr(n) = True
        Wr(n).BackColor = vid.BackColorSelSel
    End If
Next n
'MsgBox ""
End Sub

Private Sub Command2_Click()
If TInd = 255 Then
    TInd = 256
    FirstIndex = "--"
    SaveTable.FirstIndex = "--"
    Word = Wr(LostFocus)
ElseIf TInd = 256 Then
    FirstIndex = "00"
    SaveTable.FirstIndex = "00"
    TInd = 0
    Word = Wr(LostFocus)
Else
    TInd = TInd + 1
    FirstIndex = Right("00" + Hex(TInd), 2)
    SaveTable.FirstIndex = Right("00" + Hex(TInd), 2)
    Word = Wr(LostFocus)
End If
Call TableWr
End Sub

Private Sub Command20_Click()
For n = 0 To 255
    SelWr(n) = False
    Wr(n).BackColor = vid.StandartColor
Next n
End Sub

Private Sub Command21_Click()
For n = 0 To 255
    SelWr(n) = True
    Wr(n).BackColor = vid.BackColorSelSel
Next n
End Sub

Private Sub Command22_Click()
If Option1 = True Then
    For n = 0 To 255
        If Len(Wr(n)) < Val(LenForClear) Then
            SelWr(n) = True
            Wr(n).BackColor = vid.BackColorSelSel
        End If
    Next n
ElseIf Option2 = True Then
    For n = 0 To 255
        If Len(Wr(n)) <= Val(LenForClear) Then
            SelWr(n) = True
            Wr(n).BackColor = vid.BackColorSelSel
        End If
    Next n
ElseIf Option3 = True Then
    For n = 0 To 255
        If Len(Wr(n)) = Val(LenForClear) Then
            SelWr(n) = True
            Wr(n).BackColor = vid.BackColorSelSel
        End If
    Next n
ElseIf Option4 = True Then
    For n = 0 To 255
        If Len(Wr(n)) >= Val(LenForClear) Then
            SelWr(n) = True
            Wr(n).BackColor = vid.BackColorSelSel
        End If
    Next n
ElseIf Option5 = True Then
    For n = 0 To 255
        If Len(Wr(n)) > Val(LenForClear) Then
            SelWr(n) = True
            Wr(n).BackColor = vid.BackColorSelSel
        End If
    Next n
End If
End Sub

Private Sub Command23_Click()
If Option1 = True Then
    For n = 0 To 255
        If Len(Wr(n)) < Val(LenForClear) Then
            SelWr(n) = False
            Wr(n).BackColor = vid.StandartColor
        End If
    Next n
ElseIf Option2 = True Then
    For n = 0 To 255
        If Len(Wr(n)) <= Val(LenForClear) Then
            SelWr(n) = False
            Wr(n).BackColor = vid.StandartColor
        End If
    Next n
ElseIf Option3 = True Then
    For n = 0 To 255
        If Len(Wr(n)) = Val(LenForClear) Then
            SelWr(n) = False
            Wr(n).BackColor = vid.StandartColor
        End If
    Next n
ElseIf Option4 = True Then
    For n = 0 To 255
        If Len(Wr(n)) >= Val(LenForClear) Then
            SelWr(n) = False
            Wr(n).BackColor = vid.StandartColor
        End If
    Next n
ElseIf Option5 = True Then
    For n = 0 To 255
        If Len(Wr(n)) > Val(LenForClear) Then
            SelWr(n) = False
            Wr(n).BackColor = vid.StandartColor
        End If
    Next n
End If

End Sub

Private Sub Command24_Click()
DTEDicEditor.Show
End Sub

Private Sub Command3_Click()
If TInd = 0 Then
    TInd = 256
    FirstIndex = "--"
    SaveTable.FirstIndex = "--"
    Word = Wr(LostFocus)
Else
    TInd = TInd - 1
    FirstIndex = Right("00" + Hex(TInd), 2)
    SaveTable.FirstIndex = Right("00" + Hex(TInd), 2)
    Word = Wr(LostFocus)
End If
Call TableWr
End Sub

Private Sub Command4_Click()

sv = False
If SaveTable.Visible = True Then
    sv = True
    SaveTable.Hide
End If

    IndexSelect = True
    zapret = 1
    MainForm.Height = 5160
For n = 0 To 255
    Wr(n) = Right("00" + Hex(n), 2)
    Wr(n).BackColor = &H80000005
    Wr(n).ForeColor = &HFF&
    'Wr(n).FontBold = True
    Wr(n).Alignment = 2
    Wr(n).MousePointer = 1
Next n
End Sub

Private Sub Command5_Click()
LoadTable.Show
End Sub

Private Sub Command6_Click()
TInd = 256
FirstIndex = "--"
Call TableWr
End Sub

Private Sub Command7_Click()
Call ShowMeTable
End Sub

Private Sub Command8_Click()
Call ShowAllTable
End Sub

Private Sub Command9_Click()
SaveTable.Show
End Sub

Private Sub FirstIndex_Change()
If Not FirstIndex = "--" Then
    HxIndOne = FirstIndex
Else
    HxIndOne = ""
End If

HexIndex = HxIndOne + Right(HexIndex, 2)
HexIndex2 = HxIndOne + Right(HexIndex, 2)
End Sub

Private Sub Form_Load()
TInd = 256
End Sub


Private Sub Form_Unload(Cancel As Integer)
End
End Sub







Private Sub Sel_Click()
If Not Sel = False Then
'==
        Command11.Enabled = False
        Command12.Enabled = False
        Command11.Caption = "Пока недоступно"
        Command12.Caption = "Пока недоступно"
'==
        Command19.Enabled = True
        Command20.Enabled = True
        Command21.Enabled = True
        Command22.Enabled = True
        Command23.Enabled = True
    For n = 0 To 255
        Wr(n).MousePointer = 1
        Wr(n).Locked = True
        Wr(n).BackColor = &H80000005
    Next n
Else
'==
        Command11.Enabled = True
        Command12.Enabled = True
        Command11.Caption = "<- Сдвинуть влево"
        Command12.Caption = "Сдвинуть вправо ->"
'==
        Command19.Enabled = False
        Command20.Enabled = False
        Command21.Enabled = False
        Command22.Enabled = False
        Command23.Enabled = False
    For n = 0 To 255
        SelWr(n) = False
        Wr(n).MousePointer = 0
        Wr(n).Locked = False
        Wr(n).BackColor = &H80000005
    Next n
End If
    
End Sub

Private Sub Sel_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'If Not Sel = False Then
'n = 0
'End If
End Sub

Private Sub Word_Change()
If zapret = 0 Then
    Wr(LostFocus) = Word
End If
End Sub

Private Sub Wr_Change(Index As Integer)


If IndexSelect = False Then
    Table(TInd, Index) = Wr(Index)
End If

If Not TxtChn = False Then
    If Not Wr(Index) = "" Then
        If Index = 255 Then
            Wr(0).SetFocus
        Else
            Wr(Index + 1).SetFocus
        End If
    End If
    If Not SndKys = False Then
        SendKeys "{Home}"
        SendKeys "+{End}" '+{Shift}"
    End If
End If


LenOfString = Len(Wr(Index))
Word = Wr(Index)
If Val("&H" + Right(HexIndex2, 2)) = Index Then
    Word2 = Wr(Index)
    LenOfString2 = Len(Wr(Index))
End If
ending:
End Sub

Private Sub Wr_Click(Index As Integer)

'If Not vid.Index = Index Then
        vid.Index = Index
        vid.temp = Wr(Index).BackColor
'End If

Select Case Button
Case vbShiftMask
    MsgBox ""
End Select



If Not Sel = False And IndexSelect = False Then
    If SelWr(Index) = True Then
        SelWr(Index) = False
        Wr(Index).BackColor = &H80000005
    Else
        SelWr(Index) = True
        Wr(Index).BackColor = vid.BackColorSelSel
    End If
ElseIf IndexSelect = True Then
    TInd = Index
    IndexSelect = False
    FirstIndex = Wr(Index)
    For n = 0 To 255
        'Wr(n).BackColor = &H80000005
        Wr(n).ForeColor = &H80000008
        Wr(n) = Table(TInd, n)
        'Wr(n).FontBold = False
        Wr(n).Alignment = 0
        Wr(n).MousePointer = 0
    Next n
    MainForm.Height = vid.MFormHeight
    zapret = 0
    If Not Sel = False Then
        For n = 0 To 255
            If SelWr(n) = True Then
                Wr(n).BackColor = vid.BackColorSelSel
            End If
        Next n
    End If
    If sv = True Then
        SaveTable.Show
        SaveTable.FirstIndex = FirstIndex
    End If
    GoTo ending
End If

If Not SndKys = False Then
    SendKeys "{Home}"
    SendKeys "+{End}"
End If


ending:
End Sub

Private Sub Wr_GotFocus(Index As Integer)
'If Not LostFocus = Index Then
        'vid.Index = Index
'        vid.temp = Wr(Index).BackColor
'End If

If Not Sel = False Then
Else
If Not SndKys = False Then
    SendKeys "{Home}"
    SendKeys "+{End}"
End If

Wr(LostFocus).BackColor = &H80000005

hxx(LostFocus - (LostFocus \ 16) * 16).ForeColor = 0
hxy(LostFocus \ 16).ForeColor = 0
For n = LostFocus To 0 Step -16
    Wr(n).BackColor = &H80000005
Next n
For n = (LostFocus \ 16) * 16 To LostFocus - 1
    Wr(n).BackColor = &H80000005
Next n
'Static LostFocus As Integer

Wr(Index).BackColor = vid.BackColorSel

hxx(Index - (Index \ 16) * 16).ForeColor = &HD0&
hxy(Index \ 16).ForeColor = &HD0&
For n = Index To 0 Step -16
    If Not Index = n Then
        Wr(n).BackColor = vid.BackColorCross
    End If
Next n
For n = (Index \ 16) * 16 To Index - 1
    Wr(n).BackColor = vid.BackColorCross
Next n

'-----------------------------------------
zapret = 1

Word = Wr(Index)
LenOfString.Caption = Len(Wr(Index))
HexIndex = HxIndOne + Right("00" + Hex(Index), 2)
LostFocus = Index
    
zapret = 0
End If
End Sub

Private Sub Wr_KeyPress(Index As Integer, KeyAscii As Integer)
If Not BckScp = False Then
    If KeyAscii = 8 And Wr(Index) = "" Then
        If Index = 0 Then
            Wr(255).SetFocus
        Else
            Wr(Index - 1).SetFocus
        End If
    End If
End If
End Sub

Private Sub Wr_MouseMove(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
If Not Sel = False Then
If Shift = 2 Then
    If SelWr(Index) = True And Not vid.temp2 = Index Then
        SelWr(Index) = False
        Wr(Index).BackColor = vid.StandartColor
        vid.temp2 = Index
    ElseIf SelWr(Index) = False And Not vid.temp2 = Index Then
        SelWr(Index) = True
        Wr(Index).BackColor = vid.BackColorSelSel
        vid.temp2 = Index
    End If
ElseIf Shift = 1 Then
    Dim point As Integer
    point = -1
    Do Until Shift = 1
    
        
        If point <= -1 Then
            point = Index
            SelWr(Index) = True
            Wr(Index).BackColor = vid.BackColorSelSel
        End If
        If Not Index = vid.temp2 Then
            vid.temp2 = Index
            If Index > point Then stp = 1 Else stp = -1
            For n = point To Index Step stp
                Wr(n).BackColor = vid.BackColorSelSel
                SelWr(n) = True
            Next n
        End If
    Loop
    point = -1

    
ElseIf Shift = 4 Then
    If Not vid.temp2 = Index Then
        SelWr(Index) = True
        Wr(Index).BackColor = vid.BackColorSelSel
        vid.temp2 = Index
    End If
End If

End If

'If Not Sel = False Then
'Select Case Button
'Case vbLeftButton
'    If Not Index = vid.temp2 Then
'        SelWr(Index) = True
'        Wr(Index).BackColor = vid.BackColorSelSel
'        vid.temp2 = Index
'    End If
'End Select
'End If

If Sel = False And IndexSelect = False Then
If Not Index = vid.Index Then
        Wr(vid.Index).BackColor = vid.temp '&H80000015
        vid.Index = Index
        vid.temp = Wr(Index).BackColor
        If Not Index = LostFocus Then
            Wr(Index).BackColor = vid.NavColor
End If
End If
End If


If IndexSelect = True Then
    If Not Index = lostswr Then
            'MsgBox lostswr & " " & Index
            Wr(lostswr).BackColor = &H80000005
            lostswr = Index
            Wr(Index).BackColor = &H8000000D
    'Else
    '        lostswr = Index
    '        Wr(Index).BackColor = &H80000005
    End If
Else
'='
Word2 = Wr(Index)
LenOfString2 = Len(Wr(Index))
HexIndex2 = HxIndOne + Right("00" + Hex(Index), 2)
End If
End Sub


