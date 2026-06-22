DELETE FROM mst_coop_layout
WHERE ctl_no < 1000;

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
10,
'1',
'1',
'1',
'R',
'pre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <item name="送信先システムコード"  len="2" col = ""/>
    <item name="発信元システムコード"  len="2" col = ""/>
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""  key="shori_kbn"/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col = ""/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
20,
'1',
'1',
'1',
'R',
'cre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = "table_1.column_1"/>
    <item name="送信先システムコード"  len="2" col = "table_4.column_1" />
    <item name="発信元システムコード"  len="2" col = "table_2.column_2" />
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col = ""/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
30,
'11',
'11',
'11',
'R',
'pre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <item name="送信先システムコード"  len="2" col = ""/>
    <item name="発信元システムコード"  len="2" col = ""/>
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""  key="shori_kbn"/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col = ""/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
40,
'11',
'11',
'11',
'R',
'cre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = "table_1.column_1"/>
    <item name="送信先システムコード"  len="2" col = "" />
    <item name="発信元システムコード"  len="2" col = "table_2.column_2" />
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" value = "const:PPPPP" col="table_3.column_3"/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
50,
'12',
'12',
'12',
'R',
'pre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <item name="送信先システムコード"  len="2" col = ""/>
    <item name="発信元システムコード"  len="2" col = ""/>
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""  key="shori_kbn"/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col = ""/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
60,
'12',
'12',
'12',
'R',
'cre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = "table_1.column_1"/>
    <item name="送信先システムコード"  len="2"/>
    <item name="発信元システムコード"  len="2" col = "table_2.column_2" />
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" value = "json:errCd" col = "table_3.column_3"/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
'{"key":{"shori_kbn":{"01":"cre", "02":"upd", "03":"del"}}, "json-key":{"errCd":{"00000":"99999"}}}',
'1',
'0',
12345,
'20191118',
'20191118'
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
70,
'13',
'13',
'13',
'R',
'pre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <item name="送信先システムコード"  len="2" col = ""/>
    <item name="発信元システムコード"  len="2" col = ""/>
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""  key="shori_kbn"/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col = ""/>
    <item name="ダミーオーダ番号"  len="1" col = ""/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
80,
'13',
'13',
'13',
'R',
'cre',
'text',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = "table_1.column_1"/>
    <item name="送信先システムコード"  len="2" col = "" />
    <item name="発信元システムコード"  len="2" col = "table_2.column_2" />
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col = ""/>
    <item name="ダミーオーダ番号"  len="1" col = "table_3.column_3"
       value="dataset:{&quot;sqlCode&quot;:&quot;2&quot;,&quot;dataKey&quot;:{&quot;ordNo&quot;:&quot;%VALUE%&quot;}}" />
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
90,
'21',
'21',
'21',
'R',
'pre',
'csv',
'サンプル1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <item name="送信先システムコード"  len="2" col = ""/>
    <item name="発信元システムコード"  len="2" col = ""/>
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""  key="shori_kbn"/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col = ""/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
100,
'21',
'21',
'21',
'R',
'cre',
'csv',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = "table_1.column_1"/>
    <item name="送信先システムコード"  len="2" col = "" />
    <item name="発信元システムコード"  len="2" col = "table_2.column_2" />
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col="table_3.column_3"/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
110,
'22',
'22',
'22',
'R',
'pre',
'csv',
'サンプル1',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = ""/>
    <item name="送信先システムコード"  len="2" col = ""/>
    <item name="発信元システムコード"  len="2" col = ""/>
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""  key="shori_kbn"/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col = ""/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
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
120,
'22',
'22',
'22',
'R',
'cre',
'csv',
'サンプル1',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="透析初回申し込み">
    <item name="電文種別"  len="2" col = ""/>
    <item name="レコード継続指示"  len="1" col = "table_1.column_1"/>
    <item name="送信先システムコード"  len="2" col = "" />
    <item name="発信元システムコード"  len="2" col = "table_2.column_2" />
    <item name="処理情報.処理年月日"  len="8" col = ""/>
    <item name="処理情報.処理時刻"  len="6" col = ""/>
    <item name="端末名"  len="8" col = ""/>
    <item name="利用者番号"  len="8" col = ""/>
    <item name="処理区分"  len="2" col = ""/>
    <item name="応答種別"  len="2" col = ""/>
    <item name="電文長"  len="6" col = ""/>
    <item name="エラーコード"  len="5" col="table_3.column_3"/>
    <item name="予備"  len="12" col = ""/>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20191118',
'20191118'
);

DELETE FROM mst_coop_layout_detail;

INSERT INTO mst_coop_layout_detail values(
10,
'1', '1', 'R', 'detail_cre_001', 'pre', '', '',  '0', XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root>
  <item name="子要素1" len="2" />
  <item name="子要素2" len="3" />
</root>
'), null, '1', '0', 12345, '20191126', '20191116'
);

INSERT INTO mst_coop_layout_detail values(
11,
'11', '11', 'R', 'detail_cre_001', 'pre', '', '', '0', XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root>
  <item name="子要素1" len="2" />
  <item name="子要素2" len="3" />
</root>
'), null, '1', '0', 12345, '20191126', '20191116'
);

INSERT INTO mst_coop_layout_detail values(
12,
'12', '12', 'R', 'detail_cre_001', 'pre', '', '', '0', XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root>
  <item name="子要素1" len="2" />
  <item name="子要素2" len="3" />
</root>
'), null, '1', '0', 12345, '20191126', '20191116'
);

INSERT INTO mst_coop_layout_detail values(
13,
'13', '13', 'R', 'detail_cre_001', 'pre', '', '', '0', XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root>
  <item name="子要素1" len="2" />
  <item name="子要素2" len="3" />
</root>
'), null, '1', '0', 12345, '20191126', '20191116'
);

INSERT INTO mst_coop_layout_detail values(
14,
'21', '21', 'R', 'detail_cre_001', 'pre', '', '', '0', XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root>
  <item name="子要素1" len="2" />
  <item name="子要素2" len="3" />
</root>
'), null, '1', '0', 12345, '20191126', '20191116'
);

DELETE FROM sys_coop_journal
WHERE ctl_no > 0;

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
201, '1', '1', '1','C','R',1,1,1,1,0,
'0','20191119','20191119',
'9','20191119','20191119',
'',
'10C11222019111900112212345678ABCDEFGH01AA00008000000ABCDEFGHIJKLZ',
'0', '0', 12345,'20191119','20191119'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
211, '11','11','11','C','R',1,1,1,1,0,
'0','20191119','20191119',
'9','20191119','20191119',
'',
'11C11222019111900112212345678ABCDEFGH01AA00008000000ABCDEFGHIJKLZ',
'0', '0', 12345,'20191119','20191119'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
212, '12','12','12','C','R',1,1,1,1,0,
'0','20191119','20191119',
'9','20191119','20191119',
'',
'12C11222019111900112212345678ABCDEFGH01AA00008000000ABCDEFGHIJKLZ',
'0','0',12345,'20191119','20191119'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
213, '13','13','13','C','R',1,1,1,1,0,
'0','20191119','20191119',
'9','20191119','20191119',
'',
'13C11222019111900112212345678ABCDEFGH01AA000080000007ABCDEFGHIJKLZ',
'0','0',12345,'20191119','20191119'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
221,'21','21','21','C','R',1,1,1,1,0,
'0','20191119','20191119',
'9','20191119','20191119',
'',
'21,C,21,22,20191119,001122,12345678,ABCDEFGH,01,AA,000080,00000,ABCDEFGHIJKLZ',
'0','0',12345,'20191119','20191119'
);

INSERT INTO sys_coop_journal
(ctl_no,facility_cd,coop_cd,coop_cd_index,crud,direction,ord_no,coop_ord_no,hosp_pat_id,pat_id,accept_no
,ana_result,in_ana_date,out_ana_date
,coop_result,in_reg_date,out_reg_date
,dump_path
,dump
,is_editable,is_del,user_id,reg_date,up_date)
VALUES(
222,'22','22','22','U','R',1,1,1,1,0,
'0','20191119','20191119',
'9','20191119','20191119',
'',
'"22","U","22","33","20191119",001122,"12345678","ABCDEFGH","01","AA",000080,00001,"ABCDEFGHIJKLZ"',
'0','0',12345,'20191119','20191119'
);
