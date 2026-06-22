DELETE FROM mst_coop_layout
where ctl_no between 6001 and 7000;

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
'TK2020',
'101',
'101',
'R',
'pre',
'text',
'繰り返し回数テスト2',
'TEX-SOL',
'動作確認用(pre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <item name="hospPatId" len="4" col="pat_personal_main.hosp_pat_id" />
  <item name="姓" len="10" col="pat_personal_main.pat_last_name" />
  <item name="名" len="10" col="pat_personal_main.pat_first_name" />
  <item name="原疾患" len="4" col="pat_personal_main.primary_disease_cd" />
  <item name="連携オーダ番号1" len="4" col="pat_exam_main.cop_order_no1" />
  <item name="登録時検査日時" len="10" col="pat_exam_main.reg_exam_date" />
  <item name="登録時検査区分" len="1" col="pat_exam_main.reg_order_class" />

  <occ name="検査結果情報" len="0" repeat="5">
    <item name="表示順" len="4" col="pat_exam_main.exam_result_info.disp_order" />
    <item name="検査項目コード" len="4" col="pat_exam_main.exam_result_info.exam_item_cd" />
    <item name="結果値" len="4" col="pat_exam_main.exam_result_info.exam_result" />
    <item name="結果判定" len="1" col="pat_exam_main.exam_result_info.exam_check" />
    <item name="結果コメントコード" len="4" col="pat_exam_main.exam_result_info.exam_comment" />
    <item name="結果フリーコメント" len="20" col="pat_exam_main.exam_result_info.exam_free_comment" />
    <item name="結果値受信日時" len="8" col="pat_exam_main.exam_result_info.exam_result_date" />
    <item name="検査時検査項目名" len="4" col="pat_exam_main.exam_result_info.exam_item_name" />
    <item name="検査時データ形式" len="4" col="pat_exam_main.exam_result_info.data_type" />
    <item name="検査時単位" len="4" col="pat_exam_main.exam_result_info.unit" />
    <item name="検査時正常値上限" len="4" col="pat_exam_main.exam_result_info.normal_value_upper" />
    <item name="検査時正常値下限" len="4" col="pat_exam_main.exam_result_info.normal_value_lower" />
    <item name="検査使用区分" len="2" col="pat_exam_main.exam_result_info.exam_class" />
  </occ>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20200107',
'20200107'
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
'TK2020',
'101',
'101',
'R',
'cre',
'text',
'繰り返し回数テスト2',
'TEX-SOL',
'動作確認用(cre)',
'0',
XMLPARSE(DOCUMENT '<?xml version="1.0" encoding="UTF-8" ?>
<root name="繰り返し要素抽出テスト">
  <item name="処理区分" len="2" key="shori_kbn" />
  <item name="hospPatId" len="4" col="pat_personal_main.hosp_pat_id" />
  <item name="姓" len="10" col="pat_personal_main.pat_last_name" />
  <item name="名" len="10" col="pat_personal_main.pat_first_name" />
  <item name="原疾患" len="4" col="pat_personal_main.primary_disease_cd" />
  <item name="連携オーダ番号1" len = "4" col="pat_exam_main.cop_order_no1" />
  <item name="登録時検査日時" len="10" col="pat_exam_main.reg_exam_date" />
  <item name="登録時検査区分" len="1" col="pat_exam_main.reg_order_class" />

  <occ name="検査結果情報" len="0" repeat="5" col="pat_exam_main.exam_result_info" >
    <item name="表示順" len="4" col="pat_exam_main.exam_result_info.disp_order" />
    <item name="検査項目コード" len="4" col="pat_exam_main.exam_result_info.exam_item_cd" />
    <item name="結果値" len="4" col="pat_exam_main.exam_result_info.exam_result" />
    <item name="結果判定" len="1" col="pat_exam_main.exam_result_info.exam_check" />
    <item name="結果コメントコード" len="4" col="pat_exam_main.exam_result_info.exam_comment" />
    <item name="結果フリーコメント" len="20" col="pat_exam_main.exam_result_info.exam_free_comment" />
    <item name="結果値受信日時" len="8" col="pat_exam_main.exam_result_info.exam_result_date" />
    <item name="検査時検査項目名" len="4" col="pat_exam_main.exam_result_info.exam_item_name" />
    <item name="検査時データ形式" len="4" col="pat_exam_main.exam_result_info.data_type" />
    <item name="検査時単位" len="4" col="pat_exam_main.exam_result_info.unit" />
    <item name="検査時正常値上限" len="4" col="pat_exam_main.exam_result_info.normal_value_upper" />
    <item name="検査時正常値下限" len="4" col="pat_exam_main.exam_result_info.normal_value_lower" />
    <item name="検査使用区分" len="2" col="pat_exam_main.exam_result_info.exam_class" />
  </occ>
</root>
'),
json_build_object('key', json_build_object('shori_kbn', json_build_object('01','cre','02','upd','03','del'))),
'1',
'0',
12345,
'20200107',
'20200107'
);
