unit FFTLen;

interface

Type
  TFFTLen = Record
    Index:  Integer;
    Count:  Integer;
    Hidden: Boolean;
  end;

  var FFTLens: Array[0..303] of TFFTLen = (
    (Index:   2; Count: 20; Hidden: False),
    (Index:   4; Count: 17; Hidden: False),
    (Index:   5; Count: 17; Hidden: True),
    (Index:   6; Count: 17; Hidden: True),
    (Index:   8; Count: 15; Hidden: False),
    (Index:  10; Count:  7; Hidden: False),
    (Index:  11; Count:  7; Hidden: True),
    (Index:  12; Count:  7; Hidden: True),
    (Index:  14; Count: 21; Hidden: False),
    (Index:  16; Count: 19; Hidden: False),
    (Index:  17; Count: 19; Hidden: True),
    (Index:  18; Count: 19; Hidden: True),
    (Index:  19; Count: 19; Hidden: True),
    (Index:  20; Count: 19; Hidden: True),
    (Index:  21; Count: 19; Hidden: True),
    (Index:  22; Count: 19; Hidden: True),
    (Index:  23; Count: 19; Hidden: True),
    (Index:  25; Count: 14; Hidden: False),
    (Index:  27; Count: 13; Hidden: False),
    (Index:  29; Count: 36; Hidden: False),
    (Index:  31; Count:  5; Hidden: False),
    (Index:  32; Count:  5; Hidden: True),
    (Index:  34; Count: 17; Hidden: False),
    (Index:  35; Count: 17; Hidden: True),
    (Index:  36; Count: 17; Hidden: True),
    (Index:  38; Count: 35; Hidden: False),
    (Index:  40; Count:  8; Hidden: False),
    (Index:  41; Count:  8; Hidden: True),
    (Index:  43; Count: 25; Hidden: False),
    (Index:  45; Count: 20; Hidden: False),
    (Index:  47; Count: 15; Hidden: False),
    (Index:  48; Count: 15; Hidden: True),
    (Index:  49; Count: 15; Hidden: True),
    (Index:  50; Count: 15; Hidden: True),
    (Index:  52; Count: 10; Hidden: False),
    (Index:  54; Count: 18; Hidden: False),
    (Index:  56; Count:  8; Hidden: False),
    (Index:  58; Count: 27; Hidden: False),
    (Index:  60; Count:  9; Hidden: False),
    (Index:  62; Count: 18; Hidden: False),
    (Index:  63; Count: 18; Hidden: True),
    (Index:  64; Count: 18; Hidden: True),
    (Index:  65; Count: 18; Hidden: True),
    (Index:  66; Count: 18; Hidden: True),
    (Index:  67; Count: 18; Hidden: True),
    (Index:  69; Count: 16; Hidden: False),
    (Index:  71; Count: 26; Hidden: False),
    (Index:  72; Count: 26; Hidden: True),
    (Index:  73; Count: 26; Hidden: True),
    (Index:  74; Count: 26; Hidden: True),
    (Index:  75; Count: 26; Hidden: True),
    (Index:  77; Count:  6; Hidden: False),
    (Index:  79; Count: 46; Hidden: False),
    (Index:  80; Count: 46; Hidden: True),
    (Index:  81; Count: 46; Hidden: True),
    (Index:  82; Count: 46; Hidden: True),
    (Index:  83; Count: 46; Hidden: True),
    (Index:  84; Count: 46; Hidden: True),
    (Index:  85; Count: 46; Hidden: True),
    (Index:  86; Count: 46; Hidden: True),
    (Index:  87; Count: 46; Hidden: True),
    (Index:  88; Count: 46; Hidden: True),
    (Index:  90; Count:  5; Hidden: False),
    (Index:  93; Count:  4; Hidden: False),
    (Index: 112; Count:  4; Hidden: True),
    (Index: 113; Count:  4; Hidden: True),
    (Index: 117; Count: 17; Hidden: False),
    (Index: 119; Count: 17; Hidden: False),
    (Index: 120; Count: 17; Hidden: True),
    (Index: 122; Count: 15; Hidden: False),
    (Index: 123; Count: 15; Hidden: True),
    (Index: 124; Count: 15; Hidden: True),
    (Index: 125; Count: 15; Hidden: True),
    (Index: 126; Count: 15; Hidden: True),
    (Index: 127; Count: 15; Hidden: True),
    (Index: 129; Count: 40; Hidden: False),
    (Index: 130; Count: 40; Hidden: True),
    (Index: 131; Count: 40; Hidden: True),
    (Index: 132; Count: 40; Hidden: True),
    (Index: 133; Count: 40; Hidden: True),
    (Index: 134; Count: 40; Hidden: True),
    (Index: 135; Count: 40; Hidden: True),
    (Index: 138; Count: 21; Hidden: False),
    (Index: 140; Count: 11; Hidden: False),
    (Index: 141; Count: 11; Hidden: True),
    (Index: 142; Count: 11; Hidden: True),
    (Index: 143; Count: 11; Hidden: True),
    (Index: 144; Count: 11; Hidden: True),
    (Index: 145; Count: 11; Hidden: True),
    (Index: 147; Count: 25; Hidden: False),
    (Index: 149; Count: 21; Hidden: False),
    (Index: 151; Count:  5; Hidden: False),
    (Index: 152; Count:  5; Hidden: True),
    (Index: 154; Count: 15; Hidden: False),
    (Index: 156; Count:  3; Hidden: False),
    (Index: 158; Count: 32; Hidden: False),
    (Index: 160; Count: 11; Hidden: False),
    (Index: 162; Count:  4; Hidden: False),
    (Index: 163; Count:  4; Hidden: True),
    (Index: 165; Count:  6; Hidden: False),
    (Index: 167; Count: 28; Hidden: False),
    (Index: 168; Count: 28; Hidden: True),
    (Index: 170; Count: 15; Hidden: False),
    (Index: 172; Count: 14; Hidden: False),
    (Index: 174; Count: 17; Hidden: False),
    (Index: 176; Count: 13; Hidden: False),
    (Index: 177; Count: 13; Hidden: True),
    (Index: 178; Count: 13; Hidden: True),
    (Index: 179; Count: 13; Hidden: True),
    (Index: 181; Count: 34; Hidden: False),
    (Index: 182; Count: 34; Hidden: True),
    (Index: 183; Count: 34; Hidden: True),
    (Index: 184; Count: 34; Hidden: True),
    (Index: 185; Count: 34; Hidden: True),
    (Index: 186; Count: 34; Hidden: True),
    (Index: 187; Count: 34; Hidden: True),
    (Index: 188; Count: 34; Hidden: True),
    (Index: 190; Count: 31; Hidden: False),
    (Index: 192; Count:  9; Hidden: False),
    (Index: 193; Count:  9; Hidden: True),
    (Index: 194; Count:  9; Hidden: True),
    (Index: 195; Count:  9; Hidden: True),
    (Index: 197; Count: 16; Hidden: False),
    (Index: 198; Count: 16; Hidden: True),
    (Index: 199; Count: 16; Hidden: True),
    (Index: 201; Count: 28; Hidden: False),
    (Index: 203; Count: 20; Hidden: False),
    (Index: 205; Count: 21; Hidden: False),
    (Index: 206; Count: 21; Hidden: True),
    (Index: 209; Count: 21; Hidden: True),
    (Index: 211; Count: 25; Hidden: False),
    (Index: 213; Count: 25; Hidden: True),
    (Index: 215; Count: 25; Hidden: False),
    (Index: 217; Count: 25; Hidden: True),
    (Index: 219; Count: 30; Hidden: False),
    (Index: 220; Count: 30; Hidden: True),
    (Index: 221; Count: 30; Hidden: True),
    (Index: 222; Count: 30; Hidden: True),
    (Index: 224; Count: 20; Hidden: False),
    (Index: 226; Count: 39; Hidden: False),
    (Index: 227; Count: 39; Hidden: True),
    (Index: 228; Count: 39; Hidden: True),
    (Index: 229; Count: 39; Hidden: True),
    (Index: 231; Count: 18; Hidden: False),
    (Index: 233; Count: 27; Hidden: False),
    (Index: 235; Count:  5; Hidden: False),
    (Index: 236; Count:  5; Hidden: True),
    (Index: 238; Count: 14; Hidden: False),
    (Index: 239; Count: 14; Hidden: True),
    (Index: 240; Count: 14; Hidden: True),
    (Index: 241; Count: 14; Hidden: True),
    (Index: 243; Count: 14; Hidden: False),
    (Index: 244; Count: 14; Hidden: True),
    (Index: 245; Count: 14; Hidden: True),
    (Index: 246; Count: 14; Hidden: True),
    (Index: 247; Count: 14; Hidden: True),
    (Index: 249; Count: 30; Hidden: False),
    (Index: 251; Count: 11; Hidden: False),
    (Index: 252; Count: 11; Hidden: True),
    (Index: 253; Count: 11; Hidden: True),
    (Index: 255; Count: 14; Hidden: False),
    (Index: 257; Count: 14; Hidden: False),
    (Index: 258; Count: 14; Hidden: True),
    (Index: 260; Count: 32; Hidden: False),
    (Index: 262; Count: 27; Hidden: False),
    (Index: 263; Count: 27; Hidden: True),
    (Index: 264; Count: 27; Hidden: True),
    (Index: 265; Count: 27; Hidden: True),
    (Index: 266; Count: 27; Hidden: True),
    (Index: 267; Count: 27; Hidden: True),
    (Index: 268; Count: 27; Hidden: True),
    (Index: 270; Count: 24; Hidden: False),
    (Index: 272; Count:  2; Hidden: False),
    (Index: 273; Count:  2; Hidden: True),
    (Index: 275; Count: 35; Hidden: False),
    (Index: 277; Count: 13; Hidden: False),
    (Index: 278; Count: 13; Hidden: True),
    (Index: 279; Count: 13; Hidden: True),
    (Index: 280; Count: 13; Hidden: True),
    (Index: 281; Count: 13; Hidden: True),
    (Index: 283; Count:  6; Hidden: False),
    (Index: 285; Count: 21; Hidden: False),
    (Index: 286; Count: 21; Hidden: True),
    (Index: 287; Count: 21; Hidden: True),
    (Index: 288; Count: 21; Hidden: True),
    (Index: 290; Count: 21; Hidden: False),
    (Index: 292; Count: 30; Hidden: False),
    (Index: 293; Count: 30; Hidden: True),
    (Index: 294; Count: 30; Hidden: True),
    (Index: 296; Count: 12; Hidden: False),
    (Index: 298; Count:  6; Hidden: False),
    (Index: 300; Count:  6; Hidden: False),
    (Index: 302; Count:  7; Hidden: False),
    (Index: 303; Count:  7; Hidden: True),
    (Index: 305; Count:  8; Hidden: False),
    (Index: 306; Count:  8; Hidden: True),
    (Index: 307; Count:  8; Hidden: True),
    (Index: 309; Count:  5; Hidden: False),
    (Index: 311; Count:  7; Hidden: False),
    (Index: 312; Count:  7; Hidden: True),
    (Index: 313; Count:  7; Hidden: True),
    (Index: 315; Count:  9; Hidden: False),
    (Index: 316; Count:  9; Hidden: True),
    (Index: 317; Count:  9; Hidden: True),
    (Index: 319; Count: 18; Hidden: False),
    (Index: 320; Count: 18; Hidden: True),
    (Index: 321; Count: 18; Hidden: True),
    (Index: 323; Count: 13; Hidden: False),
    (Index: 324; Count: 13; Hidden: True),
    (Index: 325; Count: 13; Hidden: True),
    (Index: 327; Count: 16; Hidden: False),
    (Index: 329; Count: 17; Hidden: False),
    (Index: 331; Count: 12; Hidden: False),
    (Index: 333; Count:  1; Hidden: False),
    (Index: 336; Count: 13; Hidden: False),
    (Index: 337; Count: 13; Hidden: True),
    (Index: 338; Count: 13; Hidden: True),
    (Index: 339; Count: 13; Hidden: True),
    (Index: 340; Count: 13; Hidden: True),
    (Index: 342; Count:  1; Hidden: False),
    (Index: 345; Count: 30; Hidden: False),
    (Index: 347; Count: 12; Hidden: False),
    (Index: 348; Count: 12; Hidden: True),
    (Index: 349; Count: 12; Hidden: True),
    (Index: 350; Count: 12; Hidden: True),
    (Index: 352; Count: 28; Hidden: False),
    (Index: 354; Count: 21; Hidden: False),
    (Index: 355; Count: 21; Hidden: True),
    (Index: 356; Count: 21; Hidden: True),
    (Index: 358; Count: 19; Hidden: False),
    (Index: 360; Count:  5; Hidden: False),
    (Index: 361; Count:  5; Hidden: True),
    (Index: 363; Count:  5; Hidden: True),
    (Index: 364; Count:  5; Hidden: True),
    (Index: 366; Count: 25; Hidden: False),
    (Index: 368; Count:  5; Hidden: False),
    (Index: 369; Count:  5; Hidden: True),
    (Index: 370; Count:  5; Hidden: True),
    (Index: 371; Count:  5; Hidden: True),
    (Index: 372; Count:  5; Hidden: True),
    (Index: 374; Count: 20; Hidden: False),
    (Index: 376; Count: 15; Hidden: False),
    (Index: 378; Count:  3; Hidden: False),
    (Index: 379; Count:  3; Hidden: True),
    (Index: 381; Count:  1; Hidden: False),
    (Index: 384; Count: 19; Hidden: False),
    (Index: 386; Count: 10; Hidden: False),
    (Index: 387; Count: 10; Hidden: True),
    (Index: 389; Count: 13; Hidden: False),
    (Index: 391; Count:  6; Hidden: False),
    (Index: 392; Count:  6; Hidden: True),
    (Index: 393; Count:  6; Hidden: True),
    (Index: 394; Count:  6; Hidden: True),
    (Index: 396; Count: 15; Hidden: False),
    (Index: 397; Count: 15; Hidden: True),
    (Index: 398; Count: 15; Hidden: True),
    (Index: 399; Count: 15; Hidden: True),
    (Index: 401; Count: 17; Hidden: False),
    (Index: 402; Count: 17; Hidden: True),
    (Index: 411; Count: 31; Hidden: False),
    (Index: 413; Count: 18; Hidden: False),
    (Index: 415; Count:  8; Hidden: False),
    (Index: 417; Count:  8; Hidden: False),
    (Index: 419; Count: 10; Hidden: False),
    (Index: 421; Count: 15; Hidden: False),
    (Index: 423; Count:  4; Hidden: False),
    (Index: 425; Count: 19; Hidden: False),
    (Index: 427; Count: 12; Hidden: False),
    (Index: 429; Count: 49; Hidden: False),
    (Index: 430; Count: 49; Hidden: True),
    (Index: 432; Count: 15; Hidden: False),
    (Index: 434; Count: 26; Hidden: False),
    (Index: 436; Count: 26; Hidden: True),
    (Index: 437; Count: 26; Hidden: True),
    (Index: 438; Count: 26; Hidden: True),
    (Index: 439; Count: 26; Hidden: True),
    (Index: 440; Count: 26; Hidden: True),
    (Index: 442; Count: 12; Hidden: False),
    (Index: 444; Count:  4; Hidden: False),
    (Index: 445; Count:  4; Hidden: True),
    (Index: 447; Count: 21; Hidden: False),
    (Index: 448; Count: 21; Hidden: True),
    (Index: 449; Count: 21; Hidden: True),
    (Index: 450; Count: 21; Hidden: True),
    (Index: 452; Count: 17; Hidden: False),
    (Index: 453; Count: 17; Hidden: True),
    (Index: 454; Count: 17; Hidden: True),
    (Index: 455; Count: 17; Hidden: True),
    (Index: 457; Count:  8; Hidden: False),
    (Index: 459; Count: 13; Hidden: False),
    (Index: 460; Count: 13; Hidden: True),
    (Index: 461; Count: 13; Hidden: True),
    (Index: 463; Count: 14; Hidden: False),
    (Index: 465; Count: 23; Hidden: False),
    (Index: 466; Count: 23; Hidden: True),
    (Index: 467; Count: 23; Hidden: True),
    (Index: 478; Count: 12; Hidden: False),
    (Index: 479; Count: 12; Hidden: True),
    (Index: 483; Count: 12; Hidden: True),
    (Index: 485; Count:  3; Hidden: False),
    (Index: 486; Count:  3; Hidden: True),
    (Index: 487; Count:  3; Hidden: True),
    (Index: 489; Count:  6; Hidden: False),
    (Index: 490; Count:  5; Hidden: True)
  );

implementation

end.
 