DELETE FROM mst_coop_layout
WHERE ctl_no >= 5000;

DELETE FROM mst_coop_layout_detail
WHERE ctl_no >= 5000;


DELETE FROM sys_coop_journal
WHERE ctl_no >= 5000;

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
5001,
'5031',
'22',
'22',
'R',
'pre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="5">
    <item name="名前" col="name" len="20" />
    <item name="住所" col="address" len="20" />
    <item name="電話番号" col="phone" len="15" />
  </occ>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
5002,
'5031',
'22',
'22',
'R',
'cre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="5">
    <item name="名前" col="table1.column1.name" len="20" />
    <item name="住所" col="table1.column1.address" len="20" />
    <item name="電話番号" col="table1.column1.phone" len="15" />
  </occ>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
6001,
'6001',
'6001',
'6001',
'R',
'pre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="5" detail="detail">
  </occ>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
6002,
'6001',
'6001',
'6001',
'R',
'cre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="5" detail="detail">
  </occ>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout_detail VALUES (
6001,'6001','6001','R','detail','pre','detail','','1',
'<root name="保険フェッチテスト">
  <item name="PATTERN" col="PATTERN" len="0" value="const:1234567" />
  <item name="PATTERNSEQ" col="PATTERNSEQ" len="0" value="const:abcdefg" />
  <item name="STDATE" col="STDATE" len="0" value="const:2020/02/19 12:00:00" />
  <item name="EDDATE" col="EDDATE" len="0" value="const:9999/12/31 23:59:59" />
  <item name="INS_NO" col="INS_NO" len="0" value="const:123456789012" />
  <item name="KOHI_1" col="KOHI_1" len="0" value="const:0" />
  <item name="KOHI_2" col="KOHI_2" len="0" value="const:0" />
  <item name="KOHI_3" col="KOHI_3" len="0" value="const:0" />
  <item name="KOHI_4" col="KOHI_4" len="0" value="const:0" />
  <item name="PER_FAM_CLASS" col="PER_FAM_CLASS" len="0" value="const:0" />
  <item name="BURDEN_RATIO GAIRAI" col="BURDEN_RATIO GAIRAI" len="0" value="const:0" />
  <item name="BURDEN_RATIO NYUIN" col="BURDEN_RATIO NYUIN" len="0" value="const:0" />
  <item name="INS_NAME" col="INS_NAME" len="0" value="const:xxxxxxx" />
 </root>
',json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),'1','0','4126','2019/12/13 9:30:47','2019/12/13 9:30:47'
);

INSERT INTO mst_coop_layout_detail VALUES (
6002,'6001','6001','R','detail','cre','detail','','1',
'<root name="保険フェッチテスト">
  <item name="PATTERN" col="PATTERN" len="0" value="const:1234567" />
  <item name="PATTERNSEQ" col="PATTERNSEQ" len="0" value="const:abcdefg" />
  <item name="STDATE" col="STDATE" len="0" value="const:2020/02/19 12:00:00" />
  <item name="EDDATE" col="EDDATE" len="0" value="const:9999/12/31 23:59:59" />
  <item name="INS_NO" col="INS_NO" len="0" value="const:123456789012" />
  <item name="KOHI_1" col="KOHI_1" len="0" value="const:0" />
  <item name="KOHI_2" col="KOHI_2" len="0" value="const:0" />
  <item name="KOHI_3" col="KOHI_3" len="0" value="const:0" />
  <item name="KOHI_4" col="KOHI_4" len="0" value="const:0" />
  <item name="PER_FAM_CLASS" col="PER_FAM_CLASS" len="0" value="const:0" />
  <item name="BURDEN_RATIO GAIRAI" col="BURDEN_RATIO GAIRAI" len="0" value="const:0" />
  <item name="BURDEN_RATIO NYUIN" col="BURDEN_RATIO NYUIN" len="0" value="const:0" />
  <item name="INS_NAME" col="INS_NAME" len="0" value="const:xxxxxxx" />
 </root>
','{}','1','0','4126','2019/12/13 9:30:47','2019/12/13 9:30:47'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
7001,
'7001',
'7001',
'7001',
'R',
'pre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="5" detail="detail" />
  <item name="ダミー" len="1" />
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
7002,
'7001',
'7001',
'7001',
'R',
'cre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="5" detail="detail" />
  <item name="ダミー" len="1" />
</root>
'),
'{}',
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
7003,
'7002',
'7002',
'7002',
'R',
'pre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="5">
    <item name="shori_kbn" key="shori_kbn" len="2" />
    <item name="PATTERN" len="0" />
    <item name="PATTERNSEQ" len="0" />
    <item name="STDATE" len="0" />
    <item name="EDDATE" len="0" />
    <item name="INS_NO" len="0" />
    <item name="KOHI_1" len="0" />
    <item name="KOHI_2" len="0" />
    <item name="KOHI_3" len="0" />
    <item name="KOHI_4" len="0" />
    <item name="PER_FAM_CLASS" len="0" value="const:0" />
    <item name="BURDEN_RATIO GAIRAI" len="0" value="const:0" />
    <item name="BURDEN_RATIO NYUIN" len="0" value="const:0" />
    <item name="INS_NAME" len="0" value="const:xxxxxxx" />
  </occ>
  <item name="ダミー" len="1" />
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
7004,
'7002',
'7002',
'7002',
'R',
'cre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="5">
    <item name="shori_kbn" key="shori_kbn" len="2" />
    <item name="PATTERN" col="pat_insurance.PATTERN" len="0" value="const:1234567" />
    <item name="PATTERNSEQ" col="pat_insurance.PATTERNSEQ" len="0" value="const:abcdefg" />
    <item name="STDATE" col="pat_insurance.STDATE" len="0" value="const:2020/02/19 12:00:00" />
    <item name="EDDATE" col="pat_insurance.EDDATE" len="0" value="const:9999/12/31 23:59:59" />
    <item name="INS_NO" col="pat_insurance.INS_NO" len="0" value="const:123456789012" />
    <item name="KOHI_1" col="pat_insurance.KOHI_1" len="0" value="const:0" />
    <item name="KOHI_2" col="pat_insurance.KOHI_2" len="0" value="const:0" />
    <item name="KOHI_3" col="pat_insurance.KOHI_3" len="0" value="const:0" />
    <item name="KOHI_4" col="pat_insurance.KOHI_4" len="0" value="const:0" />
    <item name="PER_FAM_CLASS" col="pat_insurance.PER_FAM_CLASS" len="0" value="const:0" />
    <item name="BURDEN_RATIO GAIRAI" col="pat_insurance.BURDEN_RATIO GAIRAI" len="0" value="const:0" />
    <item name="BURDEN_RATIO NYUIN" col="pat_insurance.BURDEN_RATIO NYUIN" len="0" value="const:0" />
    <item name="INS_NAME" col="pat_insurance.INS_NAME" len="0" value="const:xxxxxxx" />
  </occ>
  <item name="ダミー" len="1" />
</root>
'),
'{}',
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout_detail VALUES (
7001,'7001','7001','R','detail','pre','detail','','1',
'<root name="保険フェッチテスト">
  <item name="shori_kbn" key="shori_kbn" len="2" />
  <item name="PATTERN" len="0" />
  <item name="PATTERNSEQ" len="0" />
  <item name="STDATE" len="0" />
  <item name="EDDATE" len="0" />
  <item name="INS_NO" len="0" />
  <item name="KOHI_1" len="0" />
  <item name="KOHI_2" len="0" />
  <item name="KOHI_3" len="0" />
  <item name="KOHI_4" len="0" />
  <item name="PER_FAM_CLASS" len="0" value="const:0" />
  <item name="BURDEN_RATIO GAIRAI" len="0" value="const:0" />
  <item name="BURDEN_RATIO NYUIN" len="0" value="const:0" />
  <item name="INS_NAME" len="0" value="const:xxxxxxx" />
 </root>
',json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),'1','0','4126','2019/12/13 9:30:47','2019/12/13 9:30:47'
);

INSERT INTO mst_coop_layout_detail VALUES (
7002,'7001','7001','R','detail','cre','detail','','1',
'<root name="保険フェッチテスト">
  <item name="shori_kbn" key="shori_kbn" len="2" />
  <item name="PATTERN" col="pat_insurance.PATTERN" len="0" value="const:1234567" />
  <item name="PATTERNSEQ" col="pat_insurance.PATTERNSEQ" len="0" value="const:abcdefg" />
  <item name="STDATE" col="pat_insurance.STDATE" len="0" value="const:2020/02/19 12:00:00" />
  <item name="EDDATE" col="pat_insurance.EDDATE" len="0" value="const:9999/12/31 23:59:59" />
  <item name="INS_NO" col="pat_insurance.INS_NO" len="0" value="const:123456789012" />
  <item name="KOHI_1" col="pat_insurance.KOHI_1" len="0" value="const:0" />
  <item name="KOHI_2" col="pat_insurance.KOHI_2" len="0" value="const:0" />
  <item name="KOHI_3" col="pat_insurance.KOHI_3" len="0" value="const:0" />
  <item name="KOHI_4" col="pat_insurance.KOHI_4" len="0" value="const:0" />
  <item name="PER_FAM_CLASS" col="pat_insurance.PER_FAM_CLASS" len="0" value="const:0" />
  <item name="BURDEN_RATIO GAIRAI" col="pat_insurance.BURDEN_RATIO GAIRAI" len="0" value="const:0" />
  <item name="BURDEN_RATIO NYUIN" col="pat_insurance.BURDEN_RATIO NYUIN" len="0" value="const:0" />
  <item name="INS_NAME" col="pat_insurance.INS_NAME" len="0" value="const:xxxxxxx" />
 </root>
','{}','1','0','4126','2019/12/13 9:30:47','2019/12/13 9:30:47'
);


INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
7011,
'7011',
'7011',
'7011',
'R',
'pre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="1" detail="detail" />
  <item name="ダミー" len="1" />
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
7012,
'7011',
'7011',
'7011',
'R',
'cre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="1" detail="detail" />
  <item name="ダミー" len="1" />
</root>
'),
'{}',
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
7013,
'7012',
'7012',
'7012',
'R',
'pre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <occ col="contact-list" len="0" repeat="1">
    <item name="shori_kbn" key="shori_kbn" len="2" />
    <item name="PATTERN" len="0" />
    <item name="PATTERNSEQ" len="0" />
    <item name="STDATE" len="0" />
    <item name="EDDATE" len="0" />
    <item name="INS_NO" len="0" />
    <item name="KOHI_1" len="0" />
    <item name="KOHI_2" len="0" />
    <item name="KOHI_3" len="0" />
    <item name="KOHI_4" len="0" />
    <item name="PER_FAM_CLASS" len="0" value="const:0" />
    <item name="BURDEN_RATIO GAIRAI" len="0" value="const:0" />
    <item name="BURDEN_RATIO NYUIN" len="0" value="const:0" />
    <item name="INS_NAME" len="0" value="const:xxxxxxx" />
  </occ>
  <item name="ダミー" len="1" />
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
7014,
'7012',
'7012',
'7012',
'R',
'cre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <item name="DUMMY" col="pat_insurance.DUMMY_BEFORE" len="0" value="const:piyo" />
  <occ len="0" repeat="1">
    <item name="shori_kbn" key="shori_kbn" len="2" />
    <item name="PATTERN" col="pat_insurance.PATTERN" len="0" value="const:1234567" />
    <item name="PATTERNSEQ" col="pat_insurance.PATTERNSEQ" len="0" value="const:abcdefg" />
    <item name="STDATE" col="pat_insurance.STDATE" len="0" value="const:2020/02/19 12:00:00" />
    <item name="EDDATE" col="pat_insurance.EDDATE" len="0" value="const:9999/12/31 23:59:59" />
    <item name="INS_NO" col="pat_insurance.INS_NO" len="0" value="const:123456789012" />
    <item name="KOHI_1" col="pat_insurance.KOHI_1" len="0" value="const:0" />
    <item name="KOHI_2" col="pat_insurance.KOHI_2" len="0" value="const:0" />
    <item name="KOHI_3" col="pat_insurance.KOHI_3" len="0" value="const:0" />
    <item name="KOHI_4" col="pat_insurance.KOHI_4" len="0" value="const:0" />
    <item name="PER_FAM_CLASS" col="pat_insurance.PER_FAM_CLASS" len="0" value="const:0" />
    <item name="BURDEN_RATIO GAIRAI" col="pat_insurance.BURDEN_RATIO GAIRAI" len="0" value="const:0" />
    <item name="BURDEN_RATIO NYUIN" col="pat_insurance.BURDEN_RATIO NYUIN" len="0" value="const:0" />
    <item name="INS_NAME" col="pat_insurance.INS_NAME" len="0" value="const:xxxxxxx" />

    <item name="ANOTHER" col="pat_main.test" len="0" value="const:pat_main" />
    <item name="ANOTHER" col="pat_main.test2.test3" len="0" value="const:pat_main2" />
  </occ>
  <item name="DUMMY" col="pat_insurance.DUMMY_AFTER" len="0" value="const:ugeuge" />
  <occ len="0" repeat="3">
    <item col="pat_insurance.LOOP_DUMMY" len="0" value="const:A" />
  </occ>
  <item name="ダミー" len="1" />
</root>
'),
'{}',
'1',
'0',
12345,
'20191224',
'20191224'
);


INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
10000,
'10000',
'10000',
'10000',
'R',
'pre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <item name="table1.col1" len="0" />
  <item name="table1.col2" len="0" />
  <occ col="contact-list" len="0" repeat="1">
    <item name="shori_kbn" key="shori_kbn" len="2" />
    <item name="table1.col3.key1" len="0" />
    <item name="table1.col3.key2" len="0" />
    <item name="table1.col3.key3" len="0" />
  </occ>
  <item name="ダミー" len="1" />
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout (
ctl_no
, facility_cd
, coop_cd
, coop_cd_index
, direction
, coop_cd_sub
, coop_format
, coop_name
, coop_vender
, description
, is_editable
, coop_setting
, coop_ext_setting
, is_disp
, is_del
, user_id
, reg_date
, up_date
) VALUES (
10001,
'10000',
'10000',
'10000',
'R',
'cre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <item name="table1.col1" col="table1.col1" len="0" value="const:10001" />
  <item name="table1.col2" col="table1.col2" len="0" value="const:あいう"/>
  <occ col="contact-list" len="0" repeat="1">
    <item name="shori_kbn" key="shori_kbn" len="2" />
    <item name="table1.col3.key1" col="table1.col3.key1" len="0" value="const:αβγ" />
    <item name="table1.col3.key2" col="table1.col3.key2" len="0" value="const:88888" />
    <item name="table1.col3.key3" col="table1.col3.key3" len="0" value="const:132" />
  </occ>
  <item name="ダミー" len="1" />
</root>
'),
'{}',
'1',
'0',
12345,
'20191224',
'20191224'
);

INSERT INTO mst_coop_layout_detail VALUES (
7011,'7011','7011','R','detail','pre','detail','','1',
'<root name="保険フェッチテスト">
  <item name="shori_kbn" key="shori_kbn" len="2" />
  <item name="PATTERN" len="0" />
  <item name="PATTERNSEQ" len="0" />
  <item name="STDATE" len="0" />
  <item name="EDDATE" len="0" />
  <item name="INS_NO" len="0" />
  <item name="KOHI_1" len="0" />
  <item name="KOHI_2" len="0" />
  <item name="KOHI_3" len="0" />
  <item name="KOHI_4" len="0" />
  <item name="PER_FAM_CLASS" len="0" value="const:0" />
  <item name="BURDEN_RATIO GAIRAI" len="0" value="const:0" />
  <item name="BURDEN_RATIO NYUIN" len="0" value="const:0" />
  <item name="INS_NAME" len="0" value="const:xxxxxxx" />
 </root>
',json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),'1','0','4126','2019/12/13 9:30:47','2019/12/13 9:30:47'
);

INSERT INTO mst_coop_layout_detail VALUES (
7012,'7011','7011','R','detail','cre','detail','','1',
'<root name="保険フェッチテスト">
  <item name="shori_kbn" key="shori_kbn" len="2" />
  <item name="PATTERN" col="pat_insurance.PATTERN" len="0" value="const:1234567" />
  <item name="PATTERNSEQ" col="pat_insurance.PATTERNSEQ" len="0" value="const:abcdefg" />
  <item name="STDATE" col="pat_insurance.STDATE" len="0" value="const:2020/02/19 12:00:00" />
  <item name="EDDATE" col="pat_insurance.EDDATE" len="0" value="const:9999/12/31 23:59:59" />
  <item name="INS_NO" col="pat_insurance.INS_NO" len="0" value="const:123456789012" />
  <item name="KOHI_1" col="pat_insurance.KOHI_1" len="0" value="const:0" />
  <item name="KOHI_2" col="pat_insurance.KOHI_2" len="0" value="const:0" />
  <item name="KOHI_3" col="pat_insurance.KOHI_3" len="0" value="const:0" />
  <item name="KOHI_4" col="pat_insurance.KOHI_4" len="0" value="const:0" />
  <item name="PER_FAM_CLASS" col="pat_insurance.PER_FAM_CLASS" len="0" value="const:0" />
  <item name="BURDEN_RATIO GAIRAI" col="pat_insurance.BURDEN_RATIO GAIRAI" len="0" value="const:0" />
  <item name="BURDEN_RATIO NYUIN" col="pat_insurance.BURDEN_RATIO NYUIN" len="0" value="const:0" />
  <item name="INS_NAME" col="pat_insurance.INS_NAME" len="0" value="const:xxxxxxx" />
 </root>
','{}','1','0','4126','2019/12/13 9:30:47','2019/12/13 9:30:47'
);


INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES (
5002,'5031','22','22','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
--01
--名前０１２３４５６１
--住所０１２３４５６１
--phone0123456781
--名前０１２３４５６２
--住所０１２３４５６２
--phone0123456782
--名前０１２３４５６３
--住所０１２３４５６３
--phone0123456783
--名前０１２３４５６４
--住所０１２３４５６４
--phone0123456784
--名前０１２３４５６５
--住所０１２３４５６５
--phone0123456785
decode('3031
96bc914f824f8250825182528253825482558250
8f5a8f8a824f8250825182528253825482558250
70686f6e6530313233343536373831
96bc914f824f8250825182528253825482558251
8f5a8f8a824f8250825182528253825482558251
70686f6e6530313233343536373832
96bc914f824f8250825182528253825482558252
8f5a8f8a824f8250825182528253825482558252
70686f6e6530313233343536373833
96bc914f824f8250825182528253825482558253
8f5a8f8a824f8250825182528253825482558253
70686f6e6530313233343536373834
96bc914f824f8250825182528253825482558254
8f5a8f8a824f8250825182528253825482558254
70686f6e6530313233343536373835
', 'hex'),
'0','0',12345,'20191224','20191224'
);
-- 名前=96bc914f
-- 住所=8f5a8f8a

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES (
6001,'6001','6001','6001','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
--01
decode('3031', 'hex'),
'0','0',12345,'20191224','20191224'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES (
7001,'7001','7001','7001','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
--010101010101
decode('303130313031303130313031', 'hex'),
'0','0',12345,'20191224','20191224'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES (
7002,'7002','7002','7002','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
--010101010101
decode('303130313031303130313031', 'hex'),
'0','0',12345,'20191224','20191224'
);


INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES (
7011,'7011','7011','7011','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
--01
decode('30313031', 'hex'),
'0','0',12345,'20191224','20191224'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES (
7012,'7012','7012','7012','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
--010101010101
decode('303130313031303130313031', 'hex'),
'0','0',12345,'20191224','20191224'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES (
10000,'10000','10000','10000','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
--010101010101
decode('303130313031303130313031', 'hex'),
'0','0',12345,'20191224','20191224'
);
