DELETE FROM mst_coop_layout
WHERE ctl_no BETWEEN 5000 AND 6000;

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

DELETE FROM sys_coop_journal
WHERE ctl_no = 5002;

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
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
