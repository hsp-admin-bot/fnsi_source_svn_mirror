DELETE FROM mst_coop_layout
WHERE ctl_no between 1000 and 2000;

INSERT INTO mst_coop_layout values(
1001,
'31',
'22',
'R',
'pre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = "" key="shori_kbn"/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <occ name="繰り返し" len="2">
      <item name="キー" len="3" />
      <item name="値" len="5" />
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

INSERT INTO mst_coop_layout values(
1002,
'31',
'22',
'R',
'cre',
'text',
'繰り返し回数テスト1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <occ name="繰り返し" len="2" col="key-value-list" >
      <item name="キー" len="3" col="key" />
      <item name="値" len="5" col="value" />
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

INSERT INTO mst_coop_layout values(
1003,
'32',
'22',
'R',
'pre',
'text',
'繰り返し回数テスト2',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = "" key="shori_kbn"/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <occ name="繰り返し" len="0" repeat="5">
      <item name="キー" len="3" />
      <item name="値" len="5" />
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

INSERT INTO mst_coop_layout values(
1004,
'32',
'22',
'R',
'cre',
'text',
'繰り返し回数テスト2',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <occ name="繰り返し" len="0" col="key-value-list" repeat="5">
      <item name="キー" len="3" col="key" />
      <item name="値" len="5" col="value" />
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

INSERT INTO mst_coop_layout values(
1005,
'33',
'22',
'R',
'pre',
'text',
'繰り返し回数テスト2',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = "" key="shori_kbn"/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <occ name="繰り返し" len="2" repeat="5">
      <item name="キー" len="3" />
      <item name="値" len="5" />
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

INSERT INTO mst_coop_layout values(
1006,
'33',
'22',
'R',
'cre',
'text',
'繰り返し回数テスト2',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <occ name="繰り返し" len="2" col="key-value-list" repeat="5">
      <item name="キー" len="3" col="key" />
      <item name="値" len="5" col="value" />
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

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
1001,'31','22','22','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
'01C02ABC12345DEF67890',
'0','0',12345,'20191224','20191224'
);

INSERT INTO sys_coop_journal (ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
1002,'32','22','22','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
'01CABC12345DEF67890ABC12345DEF67890ABC12345',
'0','0',12345,'20191224','20191224'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
1003,'33','22','22','C','R',1,1,1,1,0,
'0','20191224','20191224',
'9','20191224','20191224',
'',
'01C02ABC12345DEF67890ABC12345DEF67890ABC12345',
'0','0',12345,'20191224','20191224'
);

