Type
  TFieldName = Array[0..7] of Char;
  TOVLName   = Array[0..3] of Char;

const
(*
cHeaderNames: Array[0..132] of String = (
'',         '',            '',         '', '', '', '', '', '',           '',           // 0-9
'',         '',            '',         '', '', '', '', '', '',           '',           // 10-19
'',         'menu\mngrp.bin','init.out','', '', '', '', '', '',           '',          // 20-29
'',         '',            '',         '', '', '', '', '', '',           '',           // 30-39
'',         '',            '',         '', '', '', '', '', '',           '',           // 40-49
'',         '',            '',         '', '', '', '', '', '',           '',           // 50-59
'',         '',            '',         '', '', '', '', '', '',           '',           // 60-69
'',         '',            '',         '', '', '', '', '', '',           '',           // 70-79
'',         '',            '',         '', '', '', '', '', '',           '',           // 80-89
'',         '',            '',         '', '', '', '', '', '',           '',           // 90-99
'',         '',            '',         '', '', '', '', '', '',           '',           // 100-109
'',         '',            '',         '', '', '', '', '', '',           '',           // 110-119
'',         '',            '',         '', '', '', '', '', 'kernel.bin', 'sysfnt.tdw', // 120-129
'icon.tim', 'namedic.bin', ''); // 130-132
*)

cOVLNames: Array[4..20] of TOVLName = (
                              'main', 'cfg', 'pty', 'sts',  'abl',  'shop',
  'ext', 'item', 'mgc', 'gf', 'jnc2', 'sav', 'crd', 'tuto', 'tmag', 'tips',
  'test'
);

// world\dat\
cWorldNames: Array[0..11] of String = (
  'dat\wmx.obj',    'dat\wmy.obj',    'dat\texl.obj',   'dat\rail.obj',
  'dat\wmset.obj',  'esk\chara.one',  'dat\music0.obj', 'dat\music1.obj',
  'dat\music2.obj', 'dat\music3.obj', 'dat\music4.obj', 'dat\music5.obj'
);

cMainNames: Array[0..35] of String = (
  'discimg1.lzs', 'discimg2.lzs', 'discimg3.lzs', 'discimg4.lzs', 'square.lzs', // 0-4
  'name01.lzs',   'name02.lzs',   'loop01.lzs',   'loop02.lzs',   'name03.lzs', // 5-9
  'name04.lzs',   'loop03.lzs',   'loop04.lzs',   'name05.lzs',   'name06.lzs', // 10-14
  'loop05.lzs',   'loop06.lzs',   'name07.lzs',   'name08.lzs',   'loop07.lzs', // 15-19
  'loop08.lzs',   'name09.lzs',   'name10.lzs',   'loop09.lzs',   'loop10.lzs', // 20-24
  'name11.lzs',   'name12.lzs',   'loop11.lzs',   'loop12.lzs',   'name13.lzs', // 25-29
  'name14.lzs',   'loop13.lzs',   'loop14.lzs',   'ff8.lzs',      'discerr.lzs',// 30-34
  'published.lzs'                                                               // 35
);

cDatNamesCD1: Array[0..308] of TFieldName = (
  'testno',  'start',   'start0',  'gover',   'test',    'test1',   'test2',   'test3',
  'test3',   'test5',   'test5',   'test6',   'test8',   'test9',   'test13',  'test14',  
  'testbl0', 'testbl1', 'testbl2', 'testbl3', 'testbl4', 'testbl5', 'testbl6', 'testbl7', 
  'testbl8', 'testbl13','testbl14','testmv',  'bccent_1','bcform_1','bcgate_1','bchtl_1', 
  'bchtr_1', 'bcmin1_1','bcmin2_1','bcmin2_2','bcmin2_3','bcport_1','bcport1a','bcport_2',
  'bcsaka_1','bcsta_1', 'bdenter1','bdifrit1','bdin1',   'bdin2',   'bdin3',   'bdin4',   
  'bdin5',   'bdview1', 'bg2f_1',  'bg2f_2',  'bg2f_4',  'bgbook_1','bgbook_2','bgbook_3',
  'bgeat_1', 'bgeat_2', 'bgeat_3', 'bggate_1','bggate_2','bggate_4','bggate_5','bggate_6',
  'bghall_1','bghall_2','bghall_3','bghall_4','bghall_5','bghall_6','bghall_7','bghall_8',
  'bghoke_1','bghoke_2','bghoke_3','bgkote_1','bgkote_3','bgmon_1', 'bgmon_2', 'bgmon_4', 
  'bgmon_5', 'bgmon_6', 'bgpark_1','bgpaty_1','bgpaty_2','bgrank1', 'bgroad_1','bgroad_2',
  'bgroad_3','bgroad_4','bgroad_5','bgroad_6','bgroad_7','bgroad_9','bgroom_1','bgroom_4',
  'bgroom_5','bgroom_6','bgryo1_1','bgryo1_2','bgryo1_3','bgryo1_4','bgryo1_5','bgryo1_6',
  'bgryo1_7','bgryo1_8','bgryo2_1','bgryo2_2','bgsecr_1','bgsecr_2','bgsido_1','bgsido_2',
  'bvboat_1','bvboat_2','bvcar_1', 'bvtr_1',  'bvtr_2',  'bvtr_3',  'bvtr_4',  'bvtr_5',  
  'cdfield1','cdfield2','cdfield3','cdfield4','cdfield5','cdfield6','cdfield7','cdfield8',
  'doan1_1', 'doan1_2', 'doani1_1','doani1_2','doani3_1','doani3_2','doani4_1','doani4_2',
  'dogate_1','dogate1a','dogate_2','dohtl_1', 'dohtr_1', 'domin2_1','domt1_1', 'domt2_1', 
  'domt3_1', 'domt3_2', 'domt3_3', 'domt3_4', 'domt4_1', 'domt5_1', 'domt6_1', 'doopen_1',
  'doopen1a','doopen_2','doopen2a','doport_1','dopub_1', 'dopub_2', 'dopub_3', 'dosea_1', 
  'dosea_2', 'dotown_1','dotown1a','dotown_2','dotown2a','dotown_3','dotown3a','ebexit1', 
  'ebexit2', 'ebexit3', 'ebexit4', 'ebexit5', 'ebroad11','ebroad21','ebroad31','ebroad41',
  'ebroad5', 'ggele1',  'gggate1', 'gggate3', 'gggro1',  'gggroen1','gggroen2','gggym2',  
  'gghall1', 'gghall2', 'ggkodo1', 'ggroad1', 'ggroad2', 'ggroad3', 'ggroad8a','ggroad9a',
  'ggroom1', 'ggroom2', 'ggroom3', 'ggsta1',  'ggview1', 'ggview2', 'glclock1','glclub1', 
  'glclub3', 'glclub4', 'glform1', 'glfurin1','glfurin4','glfurin5','glfurin2','glfurin3',
  'glfury1', 'glfuryb1','glgate1', 'glgate2', 'glgate2a','glgate3', 'glgate3a','glgateb1',
  'glgatei1','glgatei2','glhtl1',  'glhtr1',  'glhtr1a', 'glkara1', 'glkara2', 'glmall1', 
  'glmall2', 'glprefr1','glprefr2','glprefr3','glprein1','glpreo1', 'glpreo2', 'glpreo3', 
  'glrent1', 'glroad1', 'glsta1',  'glsta2',  'glstage1','glstage3','glstaup1','glstaup4',
  'glstaup2','glstaup5','glstaup3','gltown1', 'glwater1','glwater2','glwater3','glwater4',
  'glwater5','glwitch1','glyagu1', 'gmout1',  'gnroad1', 'gnroad2', 'gnroad3', 'gnroad4', 
  'gnroad5', 'gnroom1', 'gnroom2', 'gnroom3', 'gnroom4', 'gnview1', 'gwbrook1','gwenter1',
  'gwgrass1','gwpool1', 'gwpool2', 'gwroad1', 'tiagit1', 'tiagit2', 'tiagit3', 'tiagit4', 
  'tiagit5', 'tiback1', 'tiback2', 'tigate1', 'tihtl1',  'tihtr1',  'tilink1', 'tilink2', 
  'timania1','timania2','timania3','timania4','timania5','timin1',  'timin21', 'timin22', 
  'tipub1',  'tistud1', 'tistud21','tistud22','titown1', 'titown2', 'titown3', 'titown4', 
  'titown51','titown52','titown6', 'titown7', 'titown8', 'titrain1','titv1',   'titvout1',
  'tivisi1', 'tivisi2', 'tiyane1', 'tiyane2', 'tiyane3'
);

cDatNamesCD2: Array[0..482] of TFieldName = (
  'testno',  'start',   'start0',  'gover',   'test',    'test1',   'test2',   'test3',
  'test3',   'test5',   'test5',   'test6',   'test8',   'test9',   'test13',  'test14',  
  'testbl0', 'testbl1', 'testbl2', 'testbl3', 'testbl4', 'testbl5', 'testbl6', 'testbl7', 
  'testbl8', 'testbl13','testbl14','testmv',  'bccent_1','bccent1a','bcform_1','bcform1a',
  'bcgate_1','bcgate1a','bchtl_1', 'bchtl1a', 'bchtr_1', 'bcmin1_1','bcmin11a','bcmin2_1',
  'bcmin21a','bcmin2_2','bcmin22a','bcmin2_3','bcmin23a','bcport_1','bcport1a','bcport1b',
  'bcport_2','bcport2a','bcsaka_1','bcsaka1a','bcsta_1', 'bcsta1a', 'bdenter1','bdifrit1',
  'bdin1',   'bdin2',   'bdin3',   'bdin4',   'bdin5',   'bdview1', 'bg2f_1',  'bg2f_11', 
  'bg2f_2',  'bg2f_21', 'bg2f_22', 'bg2f_3',  'bg2f_31', 'bgbook_1','bgbook1a','bgbook1b',
  'bgbook_2','bgbook2a','bgbook_3','bgbook3a','bgbtl_1', 'bgcrash1','bgeat_1', 'bgeat1a', 
  'bgeat_2', 'bgeat2a', 'bgeat_3', 'bggate_1','bggate_2','bggate_4','bggate_5','bggate_6',
  'bggate6a','bghall_1','bghall1a','bghall1b','bghall_2','bghall2a','bghall3a','bghall_4',
  'bghall4a','bghall_5','bghall_6','bghall6b','bghall_7','bghall_8','bghoke_1','bghoke_2',
  'bghoke_3','bgkote_1','bgkote1a','bgkote_2','bgkote_3','bgkote3a','bgkote_4','bgkote_5',
  'bgmast_1','bgmast_2','bgmast_3','bgmast_4','bgmast_5','bgmd1_1', 'bgmd1_2', 'bgmd1_3', 
  'bgmd1_4', 'bgmd2_1', 'bgmd2_3', 'bgmd2_4', 'bgmd2_5', 'bgmd2_6', 'bgmd2_7', 'bgmd2_8', 
  'bgmd3_1', 'bgmd3_2', 'bgmd4_1', 'bgmd4_2', 'bgmd4_3', 'bgmdele1','bgmdele2','bgmdele3',
  'bgmdele4','bgmon_1', 'bgmon_2', 'bgmon_4', 'bgmon_5', 'bgmon_6', 'bgpark_1','bgroad_1',
  'bgroad_2','bgroad_3','bgroad_4','bgroad_5','bgroad_6','bgroad_7','bgroad_9','bgroom_1',
  'bgroom_3','bgroom_4','bgroom_5','bgroom_6','bgryo2_1','bgryo2_2','bgsido_1','bgsido1a',
  'bgsido_2','bgsido_3','bgsido_4','bgsido_5','bgsido5a','bgsido_6','bgsido_7','bgsido_8',
  'bgsido_9','bvboat_1','bvboat_2','bvcar_1', 'crenter1','crodin1', 'cropen1', 'crpower1',
  'crroof1', 'crsanc1', 'crsphi1', 'crtower1','crtower2','crtower3','crview1', 'cwwood1', 
  'cwwood2', 'cwwood3', 'cwwood4', 'cwwood5', 'cwwood6', 'cwwood7', 'dogate1a','dogate_2',
  'dohtl_1', 'dohtr_1', 'domin2_1','domt1_1', 'domt2_1', 'domt5_1', 'domt6_1', 'doopen1a',
  'doport_1','dopub_1', 'dopub_2', 'dopub_3', 'dosea_1', 'dotown1a','dotown2a','dotown3a',
  'ehback1', 'ehback2', 'ehblan1', 'ehblan2', 'ehblan3', 'ehdrug1', 'ehenter1','ehenter2',
  'ehhana1', 'ehnoki1', 'ehroom1', 'ehsea1',  'ehsea2',  'fhbrdg1', 'fhdeck1', 'fhdeck2', 
  'fhdeck3', 'fhdeck4', 'fhdeck4a','fhdeck5', 'fhdeck6', 'fhdeck7', 'fhdeck7a','fhedge1', 
  'fhedge11','fhedge2', 'fhfish1', 'fhform1', 'fhhtl1',  'fhhtr1',  'fhmin1',  'fhpanel1',
  'fhpara11','fhpara12','fhparar1','fhparar2','fhroof1', 'fhtown1', 'fhtown21','fhtown22',
  'fhtown23','fhview1', 'fhwater1','fhwise11','fhwise12','fhwise13','fhwise15','fhwisef1',
  'fhwisef2','gdsand3', 'gdsta1',  'gdtrain1','gfcar1',  'gfcross1','gfcross2','gfelone1',
  'gfelone3','gfelone2','gfelone4','gfhtl1',  'gfhtl1a', 'gfhtr1',  'gfhtr1a', 'gflain1', 
  'gflain1a','gflain11','gflain2', 'gflain2a','gfmin1',  'gfmin1a', 'gfmin2',  'gfmin2a', 
  'gfrich1', 'gfrich1a','gfview1', 'gfview1a','gfvill1', 'gfvill1a','gfvill21','gfvill24',
  'gfvill22','gfvill23','gfvill31','gfvill32','ggback1', 'ggele1',  'gggate2', 'gggate3', 
  'gggro1',  'gggroen1','gggroen2','gggym1',  'gggym2',  'gghall1', 'gghall2', 'ggkodo1', 
  'ggkodo2', 'ggkodo4', 'ggroad1', 'ggroad2', 'ggroad3', 'ggroad5', 'ggroad6', 'ggroad7', 
  'ggroad8', 'ggroad8a','ggroad8b','ggroad9', 'ggroad9a','ggroad9b','ggroom1', 'ggroom2', 
  'ggroom3', 'ggroom4', 'ggroom6', 'ggroom7', 'ggsta1',  'ggstaen1','ggstaen3','ggstand1',
  'ggwitch1','ggwitch2','glclub1', 'glclub3', 'glclub4', 'glform1', 'glfurin1','glfurin2',
  'glfurin3','glfury1', 'glfuryb1','glgate1', 'glgate2', 'glgate3', 'glgateb1','glgatei1',
  'glgatei2','glhtl1',  'glhtr1',  'glmall1', 'glmall2', 'glprefr1','glpreo1', 'glrent1', 
  'glroad1', 'glsta1',  'glsta2',  'glstaup1','glstaup2','glstaup3','gltown1', 'glwater1',
  'glwater2','glwater3','glwater4','glwater5','gmcont1', 'gmcont2', 'gmden1',  'gmhouse1',
  'gmmoni1', 'gmout1',  'gmpark1', 'gmpark2', 'gmshoot1','gmtika1', 'gmtika2', 'gmtika3', 
  'gmtika4', 'gmtika5', 'gnroad1', 'gnroad2', 'gnroad3', 'gnroad4', 'gnroad5', 'gnroom1', 
  'gnroom2', 'gnroom3', 'gnroom4', 'gnview1', 'gparm1',  'gpbig1',  'gpbig1a', 'gpbig2',  
  'gpbig2a', 'gpbig3',  'gpbigin1','gpbigin3','gpbigin2','gpbigin4','gpbigin5','gpcell1', 
  'gpcont1', 'gpcont2', 'gpescap1','gpexit1', 'gpexit2', 'gpgmn1',  'gpgmn1a', 'gpgmn2',  
  'gpgmn3',  'gppark1', 'gproof1', 'gproof2', 'rgcock2', 'rgguest1','rgguest4','seback1', 
  'seback2', 'secont1', 'secont2', 'sefront1','sefront2','sefront3','sefront4','seroom1', 
  'seroom2', 'tgcourt1','tgcourt5','tgcourt2','tgcourt3','tgcourt4','tgfront1','tggara1', 
  'tggate1', 'tggrave1','tgroom1', 'tgroom2', 'tgstage1','tgview1', 'tiback1', 'tiback2',
  'tigate1', 'tihtl1',  'tihtr1',  'timania1','timania2','timania3','timania4','timania5',
  'timin1',  'timin21', 'timin22', 'tipub1',  'titown1', 'titown2', 'titown3', 'titown4',
  'titown51','titown52','titown6', 'titown7', 'titown8', 'titv1',   'titvout1','tmdome1',
  'tmdome2', 'tmelder1','tmele1',  'tmgate1', 'tmhtl1',  'tmhtr1',  'tmkobo1', 'tmkobo2',
  'tmmin1',  'tmmura1', 'tmmura2', 'tmsand1', 'tvglen1', 'tvglen2', 'tvglen3', 'tvglen4',
  'tvglen5', 'gpbigin6','fhtown24'
);

cDatNamesCD3: Array[0..595] of TFieldName = (
  'testno',  'start',   'start0',  'gover',   'test',    'test1',   'test2',   'test3',
  'test3',   'test5',   'test5',   'test6',   'test8',   'test9',   'test13',  'test14',
  'testbl0', 'testbl1', 'testbl2', 'testbl3', 'testbl4', 'testbl5', 'testbl6', 'testbl7',
  'testbl8', 'testbl9', 'testbl13','testbl14','testmv',  'bccent_1','bcform_1','bcgate_1',
  'bchtl_1', 'bchtr_1', 'bcmin1_1','bcmin2_1','bcmin2_2','bcmin2_3','bcport_1','bcport1a',
  'bcport_2','bcsaka_1','bcsta_1', 'bdenter1','bdifrit1','bdin1',   'bdin2',   'bdin3',
  'bdin4',   'bdin5',   'bdview1', 'bg2f_1',  'bg2f_2',  'bg2f_22', 'bg2f_3',  'bgbook_1',
  'bgbook1a','bgbook1b','bgbook_2','bgbook2a','bgbook_3','bgbook3a','bgeat_1', 'bgeat1a',
  'bgeat_2', 'bgeat2a', 'bgeat_3', 'bggate_6','bghall_1','bghall1b','bghall_2','bghall2a',
  'bghall3a','bghall_4','bghall_5','bghall_6','bghall6b','bghall_7','bghall_8','bghoke_1',
  'bghoke_2','bghoke_3','bgkote1a','bgkote_3','bgkote3a','bgkote_4','bgkote_5','bgmast_1',
  'bgmast_2','bgmast_3','bgmast_4','bgmast_5','bgmd1_1', 'bgmd1_2', 'bgmd1_3', 'bgmd1_4',
  'bgmd2_1', 'bgmd2_3', 'bgmd2_4', 'bgmd2_5', 'bgmd2_6', 'bgmd2_7', 'bgmd2_8', 'bgmd3_1',
  'bgmd3_2', 'bgmdele1','bgmdele2','bgmdele3','bgmdele4','bgmon_1', 'bgmon_2', 'bgmon_4',
  'bgmon_5', 'bgmon_6', 'bgpark_1','bgroad_1','bgroad_2','bgroad_3','bgroad_4','bgroad_5',
  'bgroad_6','bgroad_7','bgroom_1','bgroom_4','bgroom_5','bgroom_6','bgryo2_1','bgryo2_2',
  'bgsido_1','bgsido_5','bgsido_7','bvboat_1','bvboat_2','bvcar_1', 'crenter1','crodin1',
  'cropen1', 'crpower1','crroof1', 'crsanc1', 'crsphi1', 'crtower1','crtower2','crtower3',
  'crview1', 'cwwood1', 'cwwood2', 'cwwood3', 'cwwood4', 'cwwood5', 'cwwood6', 'cwwood7',
  'ddruins1','ddruins2','ddruins3','ddruins4','ddruins5','ddruins6','ddsteam1','ddtower1',
  'ddtower2','ddtower3','ddtower4','ddtower5','ddtower6','dogate1a','dogate_2','dohtl_1',
  'dohtr_1', 'domin2_1','domt1_1', 'domt2_1', 'domt5_1', 'domt6_1', 'doopen1a','doport_1',
  'dopub_1', 'dopub_2', 'dopub_3', 'dosea_1', 'dotown1a','dotown2a','dotown3a','eaplane1',
  'eapod1',  'ebadele1','ebadele2','ebadele3','ebadele5','ebcont1', 'ebcont2', 'ebexit6',
  'ebgate1', 'ebgate1a','ebgate2', 'ebgate2a','ebgate3', 'ebgate3a','ebgate4', 'ebgate4a',
  'ebinhi1', 'ebinhi1a','ebinlow1','ebinlow2','ebinmid1','ebinmid4','ebinmid2','ebinmid5',
  'ebinmid3','ebinto1', 'ebinto2', 'ebinto3', 'ebroad12','ebroad13','ebroad22','ebroad23',
  'ebroad32','ebroad33','ebroad42','ebroad43','ebroad6', 'ebroad6a','ebroad7', 'ebroad7a',
  'ebroad8', 'ebroad8a','ebroad9', 'ebroad9a','eccway11','eccway15','eccway12','eccway16',
  'eccway13','eccway14','eccway21','eccway22','eccway23','eccway31','eccway32','eccway33',
  'eccway41','eccway42','eccway43','ecenc1',  'ecenc2',  'ecenc3',  'ecenter1','ecenter4',
  'ecenter2','ecenter5','ecenter3','eciway11','eciway15','eciway12','eciway16','eciway13',
  'eciway14','ecmall1', 'ecmall1a','ecmall1b','ecmview1','ecmview2','ecmview3','ecmway1',
  'ecmway1a','ecmway1b','ecopen1', 'ecopen1a','ecopen1b','ecopen2', 'ecopen2a','ecopen2b',
  'ecopen3', 'ecopen3a','ecopen3b','ecopen4', 'ecopen4a','ecopen4b','ecoway1', 'ecoway1a',
  'ecoway1b','ecoway2', 'ecoway2a','ecoway2b','ecoway3', 'ecoway3a','ecoway3b','ecpview1',
  'ecpview2','ecpview3','ecpway1', 'ecpway1a','ecpway1b','ectake1', 'ectake2', 'ectake3',
  'edlabo1', 'edlabo1a','edlabo1b','edmoor1', 'edview1', 'edview1a','edview1b','edview2',
  'eein1',   'eein11',  'eein12',  'eein3',   'eein31',  'eein32',  'eeview1', 'eeview2',
  'eeview3', 'efbig1',  'efenter1','efenter2','efenter3','efpod1',  'efpod1a', 'efpod1b',
  'efview1', 'efview1a','efview1b','efview2', 'ehback1', 'ehback2', 'ehblan1', 'ehblan2',
  'ehblan3', 'ehdrug1', 'ehenter1','ehenter2','ehhana1', 'ehnoki1', 'ehroom1', 'ehsea1',
  'ehsea2',  'elroad1', 'elroad2', 'elroad3', 'elstop1', 'elview1', 'elview2', 'elwall1',
  'elwall2', 'elwall3', 'elwall4', 'embind1', 'embind1a','embind2', 'emlabo1', 'emlabo1a',
  'emlabo1b','emlabo2', 'emlobby1','emlobby3','emlobby2','emlobby4','ephall1', 'ephall2',
  'epmeet1', 'eproad1', 'eproad2', 'epwork1', 'epwork2', 'epwork3', 'escont1', 'escouse1',
  'escouse2','esform1', 'esfreez1','esview1', 'esview2', 'etsta1',  'etsta2',  'ewbrdg1',
  'ewdoor1', 'ewele1',  'ewele2',  'ewele3',  'ewpanel1','ewpanel2','ffbrdg1', 'ffhill1',
  'ffhole1', 'ffseed1', 'fhbrdg1', 'fhdeck2', 'fhdeck3', 'fhdeck4', 'fhdeck4a','fhdeck5',
  'fhdeck7', 'fhdeck7a','fhedge1', 'fhedge2', 'fhfish1', 'fhform1', 'fhhtl1',  'fhhtr1',
  'fhmin1',  'fhpara11','fhparar1','fhrail2', 'fhrail3', 'fhroof1', 'fhtown1', 'fhtown21',
  'fhtown22','fhtown23','fhview1', 'fhwater1','fhwise11','fhwisef1','fhwisef2','gdsand1',
  'gdsand2', 'gfcross2','gfelone3','gfelone4','gfhtl1a', 'gfhtr1a', 'gflain1a','gflain2a',
  'gfmin1a', 'gfmin2a', 'gfrich1a','gfview1a','gfvill1a','gfvill24','gfvill32','ggkodo4',
  'ggsta1',  'glclub1', 'glclub3', 'glclub4', 'glform1', 'glfurin1','glfurin2','glfurin3',
  'glfury1', 'glfuryb1','glgate1', 'glgate2', 'glgate3', 'glgateb1','glgatei1','glgatei2',
  'glhtl1',  'glhtr1',  'glmall1', 'glmall2', 'glprefr1','glpreo1', 'glrent1', 'glroad1',
  'glsta1',  'glsta2',  'glstaup1','glstaup2','glstaup3','gltown1', 'glwater1','glwater2',
  'glwater3','glwater4','glwater5','gnroad1', 'gnroad2', 'gnroad3', 'gnroad4', 'gnroad5',
  'gnroom1', 'gnroom2', 'gnroom3', 'gnroom4', 'gnview1', 'rgair1',  'rgair2',  'rgair3',
  'rgcock1', 'rgcock2', 'rgcock3', 'rgexit1', 'rgexit2', 'rgguest1','rgguest2','rgguest3',
  'rgguest4','rgguest5','rghang1', 'rghang11','rghang2', 'rghatch1','rgroad1', 'rgroad11',
  'rgroad2', 'rgroad21','rgroad3', 'rgroad31','sdcore1', 'sdcore2', 'sdisle1', 'seback1',
  'seback2', 'secont1', 'secont2', 'sefront1','sefront2','sefront3','sefront4','seroom1',
  'seroom2', 'ssadel1', 'ssadel2', 'ssblock1','sscont1', 'sscont2', 'ssdock1', 'sselone1',
  'sslock1', 'ssmedi1', 'ssmedi2', 'sspack1', 'sspod1',  'sspod2',  'sspod3',  'ssroad1',
  'ssroad2', 'ssroad3', 'ssspace1','ssspace2','ssspace3','tgcourt1','tgcourt5','tgcourt2',
  'tgcourt3','tgcourt4','tgfront1','tggara1', 'tggate1', 'tggrave1','tgroom1', 'tgroom2',
  'tgstage1','tgview1', 'tiback1', 'tiback2', 'tigate1', 'tihtl1',  'tihtr1',  'timania1',
  'timania2','timania3','timania4','timania5','timin1',  'timin21', 'timin22', 'tipub1',
  'titown1', 'titown2', 'titown3', 'titown4', 'titown51','titown52','titown6', 'titown7',
  'titown8', 'titv1',   'titvout1','tmdome1', 'tmdome2', 'tmelder1','tmele1',  'tmgate1',
  'tmhtl1',  'tmhtr1',  'tmkobo1', 'tmkobo2', 'tmmin1',  'tmmura1', 'tmmura2', 'tmsand1',
  'tvglen1', 'tvglen2', 'tvglen3', 'tvglen4', 'tvglen5', 'fhtown24','rgcock4', 'rgcock5',
  'ehblan1a','ehenter3','ehroom1a','eproad1a'
);

cDatNamesCD4: Array[0..204] of TFieldName = (
  'testno',  'start',   'start0',  'gover',   'ending',  'test',    'test1',   'test2',   
  'test3',   'test3',   'test5',   'test5',   'test6',   'test8',   'test9',   'test13',  
  'test14',  'testbl0', 'testbl1', 'testbl2', 'testbl3', 'testbl4', 'testbl5', 'testbl6', 
  'testbl7', 'testbl8', 'testbl9', 'testbl13','testbl14','testmv',  'bchtr1a', 'bdenter1',
  'bdifrit1','bdin1',   'bdin2',   'bdin3',   'bdin4',   'bdin5',   'bdview1', 'bgmon_3', 
  'crenter1','crodin1', 'cropen1', 'crpower1','crroof1', 'crsanc1', 'crsphi1', 'crtower1',
  'crtower2','crtower3','crview1', 'cwwood1', 'cwwood2', 'cwwood3', 'cwwood4', 'cwwood5', 
  'cwwood6', 'cwwood7', 'ddruins1','ddruins2','ddruins3','ddruins4','ddruins5','ddruins6',
  'ddsteam1','ddtower1','ddtower2','ddtower3','ddtower4','ddtower5','ddtower6','eaplane1',
  'eapod1',  'ebadele1','ebadele2','ebadele3','ebadele5','ebcont1', 'ebcont2', 'ebgate1a',
  'ebgate2a','ebgate3a','ebgate4a','ebinhi1a','ebinlow2','ebinmid4','ebinmid5','ebinmid6',
  'ebinto1', 'ebinto2', 'ebinto3', 'ebroad13','ebroad23','ebroad33','ebroad43','ebroad6a',
  'ebroad7a','ebroad8a','ebroad9a','eein1',   'eein3',   'eeview1', 'fe2f1',   'feart1f1',
  'feart1f2','feart2f1','febarac1','febrdg1', 'feclock1','feclock2','feclock3','feclock4',
  'feclock5','feclock6','fegate1', 'fehall1', 'fehall2', 'fein1',   'fejail1', 'felast1', 
  'felfst1', 'felrele1','feopen1', 'feopen2', 'feout1',  'fepic1',  'fepic2',  'fepic3',  
  'ferfst1', 'feroad1', 'feroad2', 'ferrst1', 'feteras1','fetre1',  'feware1', 'fewater1',
  'fewater2','fewater3','fewine1', 'fewor1',  'fewor2',  'feyard1', 'ffbrdg1', 'ffhill1', 
  'ffhole1', 'ffseed1', 'gnroad1', 'gnroad2', 'gnroad3', 'gnroad4', 'gnroad5', 'gnroom1',
  'gnroom2', 'gnroom3', 'gnroom4', 'gnview1', 'rgair1',  'rgair2',  'rgcock1', 'rgcock2',
  'rgcock3', 'rgexit1', 'rgexit2', 'rgguest3','rgguest4','rgguest5','rghang11','rghang2',
  'rgroad11','rgroad21','rgroad31','sdcore1', 'sdcore2', 'sdisle1', 'tvglen1', 'tvglen2',
  'tvglen3', 'tvglen4', 'tvglen5', 'laguna01','laguna02','laguna03','laguna04','laguna05',
  'laguna06','laguna07','laguna08','laguna09','laguna10','laguna11','laguna12','laguna13',
  'laguna14','ffhole1a','ehblan1a','ehenter3','ehroom1a','fewhite1','feblack1','glwitch3',
  'ehback1a','ehblan1b','ehenter4','ehroom1b','ehsea1a'
);

cDatNamesPtrs: Array[1..4] of PChar = (@cDatNamesCD1, @cDatNamesCD2, @cDatNamesCD3, @cDatNamesCD4);

cVideoNamesCD1: Array[0..31] of String = (
  'video.ovl',
  'Balamb_Garden',
  'Qustis_Trepe',
  'Zell_Dincht',
  'Destantion_Dollet',
  'Selphie_Tilmitt',
  'The_Comm_Tower',
  'X-ATM092_and_a_Car',
  'Escape_from_Dollet',
  'A_Shooting_Star',
  'Dancing_with_Rinoa',
  'Speeding_Train',
  'A_Stolen_Wagon',
  'Static_Translation',
  'Tilted_Camera',
  'Galbadia_Garden',
  'Irvine_Kinneas',
  'Deling_City',
  'Sorceress_Edea',
  'Edeas_Speech',
  'Huuuge_Crowd',
  'Lively_Statues',
  'Edeas_Parade',
  'More_of_the_Parade',
  'Seifer_Looking_Happy',
  '22_00',
  'Trapped',
  'Take_the_Shot',
  'Squall_Steals_a_Car',
  'The_Sorceress_Knight',
  'Edeas_Magic',
  'Opening'
);

cVideoNamesCD2: Array[0..34] of String = (
  'video.ovl',
  'Prison_Elevator',
  'Desert_Prison',
  'Hazardous_Bridge',
  'Now_Thats_a_Drill',
  'Missile_Launch',
  'Self_Destruct',
  'Just_the_Boom',
  'More_Missiles',
  'Target_Acquired',
  'Shelter_Mechanism',
  'Garden_Transformed',
  'Missiles_Inbound',
  'Its_a_Hit',
  'No_Longer_in_Danger',
  'Rinoa_in_the_Wind',
  'Close_Call',
  'Garden_put_to_Sea',
  'Drifting_Away',
  'White_SeeD_Ship',
  'Crashing_into_FH',
  'Fishermans_Horizon',
  'Galbadias_Coming',
  'Through_the_Woods',
  'Seifer_Again',
  'Motorcycles',
  'Rinoas_in_Trouble',
  'Galbadia_Passes_by',
  'Theyre_Turning',
  'Head-on_Collision',
  'Jetpacks',
  'Another_Collision',
  'Playback_Time',
  'Escape_Hatch',
  'Saving_Rinoa'
);

cVideoNamesCD3: Array[0..33] of String = (
  'video.ovl',
  'De-cloaking_Esthar',
  'Speed-lifts',
  'Leaving_the_City',
  'Entering_the_City',
  'Leaving_the_Palace',
  'Entering_the_Palace',
  'Taking_the_Elevator',
  'Lunar_Gate',
  'Leaving_the_Planet',
  'Lunar_Base',
  'Lunar_Monsters',
  'Closer_Look',
  'Lunatic_Pandora',
  'Tears_Point',
  'The_Probe_Destroyed',
  'Adel_Swallowed',
  'Escape_Pod',
  'Running_Out_of_Air',
  'No_Time_Left',
  'Ran_Out_of_Air',
  'The_Rings',
  'Backup_System',
  'More_Lunar_City',
  'Whats_That',
  'The_Ragnarok',
  'Open_the_Hatch',
  'Break_the_Seal',
  'Attacking_Pandora',
  'Shipping_Off_Adel',
  'Breaching_Pandora',
  'Adel_Enters_Pandora',
  'The_Lunar_Cry',
  'Unk_CD3'
);

cVideoNamesCD4: Array[0..8] of String = (
  'video.ovl',
  'Adel_Seizes_Rinoa',
  'Time_Compression',
  'Ultimecia_Castle',
  'Ultimecia_Herself',
  'Ending',
  'Final_Credits',
  'Ending_and_Credits',
  'Unk_CD4'
);

cGrpIndexes: Array[0..117] of Byte = (
  0,   1,   2,   3,   7,   9,   10,  12,  16,  20,
  24,  28,  29,  30,  31,  32,  33,  34,  44,  45,
  48,  49,  50,  51,  52,  53,  54,  55,  56,  57,
  63,  64,  65,  71,  72,  73,  74,  75,  87,  88,
  89,  90,  95,  96,  97,  98,  99,  100, 101, 102,
  103, 104, 105, 106, 107, 108, 109, 110, 111, 112,
  113, 114, 115, 116, 117, 118, 119, 120, 121, 122,
  123, 124, 125, 126, 127, 128, 129, 130, 131, 132,
  133, 160, 161, 162, 163, 164, 165, 166, 167, 168,
  169, 170, 171, 172, 173, 174, 175, 176, 177, 178,
  179, 180, 181, 182, 183, 184, 188, 189, 190, 191,
  192, 196, 197, 198, 199, 200, 204, 205
);

Type
  TPatchData = Record
    Pos: Integer;  
    Len: Integer;
    Data: Array[1..4] of Integer;
  end;
  PPatchData = ^TPatchData;
  TPatchList = Record
    Patch: PPatchData;
    Count: Integer;
  end;

const
  cPatchOVLMain: Array[0..4] of TPatchData = // 4
  ( //                           CD1        CD2        CD3        CD4
    (Pos: $8617; Len: 1; Data: ($00,       $DF,       $26,       $00)),
    (Pos: $8774; Len: 4; Data: ($02000000, $A27D7D00, $00010500, $00000000)),
    (Pos: $8796; Len: 2; Data: ($8979,     $B5B9,     $4D42,     $0000)),
    (Pos: $87AE; Len: 2; Data: ($0000,     $A6B5,     $A8EF,     $0000)),
    (Pos: $AA76; Len: 2; Data: ($1213,     $B980,     $0000,     $4348))
  );

  cPatchOVLPty: Array[0..1] of TPatchData = // 6
  ( //                           CD1        CD2        CD3        CD4
    (Pos: $3D2E; Len: 2; Data: ($0000,     $655E,     $4B4B,     $8E42)),
    (Pos: $3D3C; Len: 4; Data: ($00000000, $4666D08E, $00000000, $006E6021))
  );

  cPatchOVLShop: Array[0..2] of TPatchData = // 9
  ( //                           CD1        CD2        CD3        CD4
    (Pos: $4306; Len: 2; Data: ($0000,     $29FE,     $8C83,     $0000)),
    (Pos: $4363; Len: 1; Data: ($00,       $7D,       $8C,       $8C)),
    (Pos: $439F; Len: 1; Data: ($00,       $1C,       $AC,       $30))
  );

  cPatchOVLSav: Array[0..2] of TPatchData =  // 15
  ( //                           CD1        CD2        CD3        CD4
    (Pos: $9532; Len: 2; Data: ($0000,     $0C40,     $0200,     $AD8B)),
    (Pos: $955A; Len: 2; Data: ($0000,     $3F25,     $7382,     $B1EE)),
    (Pos: $9A8C; Len: 4; Data: ($00001110, $8057BA89, $00000000, $181B1D1F))
  );

  cPatchOVLCrd: Array[0..0] of TPatchData = // 16
  ( //                           CD1        CD2        CD3        CD4
    (Pos: $206F; Len: 1; Data: ($00,       $06,       $CF,       $82))
  );


  cPatchOVLTmag: Array[0..0] of TPatchData = // 18
  ( //                           CD1        CD2        CD3        CD4
    (Pos: $0BF4; Len: 4; Data: ($00000000, $30612400,  $0B0B1100, $00000100))
  );

  cOVLPatches: Array[Low(cOVLNames)..High(cOVLNames)] of TPatchList= (
    (Patch: @cPatchOVLMain; Count: Length(cPatchOVLMain)), // 4
    (),
    (Patch: @cPatchOVLPty;  Count: Length(cPatchOVLPty) ), // 6
    (), (),
    (Patch: @cPatchOVLShop; Count: Length(cPatchOVLShop)), // 9
    (), (), (), (), (),
    (Patch: @cPatchOVLSav;  Count: Length(cPatchOVLSav) ), // 15
    (Patch: @cPatchOVLCrd;  Count: Length(cPatchOVLCrd) ), // 16
    (),
    (Patch: @cPatchOVLTmag; Count: Length(cPatchOVLTmag)), // 18
    (), ()
  );

Type
  TResInfo = Record
    Pos:  DWord;
    Size: DWord;
    Name: String;
    Max:  DWord;
  end;
  PResInfo = ^TResInfo;

  TResourses = Record
    Name: String;
    Count:   Integer;
    Info:    PResInfo;
  end;

const

  cResMain: Array[0..0] of TResInfo = (
    (Pos: $000960; Size: $0032; Name: 'packcode.bin')
  );

  cResMenuMain: Array[0..3] of TResInfo = (
    (Pos: $0087B0; Size: $0800; Name: 'tknmes1.bin'),
    (Pos: $008FB8; Size: $00E4; Name: 'mmagic.bin'),
    (Pos: $00909C; Size: $031C; Name: 'mitem.bin'),
    (Pos: $0093B8; Size: $12BE; Name: 'areames.dc1'; Max: $16BC)
  );

  cResMenuSts: Array[0..2] of TResInfo = (
    (Pos: $003E48; Size: $031C; Name: 'mitem.bin'),
    (Pos: $004164; Size: $0048; Name: 'pet_exp.bin'),
    (Pos: $0041AC; Size: $0136; Name: 'pet_exp.msg'; Max: $0538)
  );

  cResMenuMgc: Array[0..0] of TResInfo = (
    (Pos: $007030; Size: $01C0; Name: 'magsort.bin')
  );

  cResMenuShop: Array[0..4] of TResInfo = ( 
    (Pos: $0043A0; Size: $018C; Name: 'mwepon.bin'),
    (Pos: $00452C; Size: $0044; Name: 'mwepon.msg'; Max: $0444),
    (Pos: $004970; Size: $0280; Name: 'shop.bin'),
    (Pos: $004BF0; Size: $031C; Name: 'price.bin'),
    (Pos: $004F0C; Size: $031C; Name: 'mitem.bin')
  );

  cResMenuSav: Array[0..1] of TResInfo = (
    (Pos: $00955C; Size: $0330; Name: 'mmag2.bin'),
    (Pos: $00988C; Size: $0200; Name: 'cyocobo.bin')
  );

  cResMenuItem: Array[0..2] of TResInfo = (
    (Pos: $008B30; Size: $018C; Name: 'mwepon.bin'),
    (Pos: $008CBC; Size: $1254; Name: 'mmag.bin'),
    (Pos: $009F10; Size: $0010; Name: 'mthomas.bin'; Max: $0510)
  );

  cResMenuCrd:  Array[0..1] of TResInfo = (
    (Pos: $001980; Size: $0564; Name: 'card1.msg'; Max: $058C),
    (Pos: $001F0C; Size: $0160; Name: 'card2.msg'; Max: $0164)
  );

  cResMenuTmag: Array[0..0] of TResInfo = (
    (Pos: $000BF8; Size: $1254; Name: 'mmag.bin')
  );

  cResources: Array[0..8] of TResourses = (
    (Name: 'main.ovl';     Count: Length(cResMain);     Info: @cResMain),
    (Name: 'menumain.ovl'; Count: Length(cResMenuMain); Info: @cResMenuMain),
    (Name: 'menusts.ovl';  Count: Length(cResMenuSts);  Info: @cResMenuSts),
    (Name: 'menumgc.ovl';  Count: Length(cResMenuMgc);  Info: @cResMenuMgc),
    (Name: 'menushop.ovl'; Count: Length(cResMenuShop); Info: @cResMenuShop),
    (Name: 'menusav.ovl';  Count: Length(cResMenuSav);  Info: @cResMenuSav),
    (Name: 'menuitem.ovl'; Count: Length(cResMenuItem); Info: @cResMenuItem),
    (Name: 'menucrd.ovl';  Count: Length(cResMenuCrd);  Info: @cResMenuCrd),
    (Name: 'menutmag.ovl'; Count: Length(cResMenuTmag); Info: @cResMenuTmag)
  );
