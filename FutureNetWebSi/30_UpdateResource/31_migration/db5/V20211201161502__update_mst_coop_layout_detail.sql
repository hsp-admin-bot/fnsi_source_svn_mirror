delete from "mst_coop_layout_detail" where "ctl_no" in (-309000001,-309000002);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-309000001, 'N_hosp', 'exam_rst', 'R', '検査結果詳細', 'all', 'NEC想定検査結果受信', 'For test', '1', '<root name="検査結果詳細">
  <item name="病院番号" len="2" type="string"/>
  <item name="患者番号" len="10" type="string"/>
  <item name="採取日" len="8" type="string"/>
  <item name="採取時間" len="4" type="string"/>
  <item name="オーダ番号" len="13" type="string"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号" len="13" type="string"/>
  <item name="報告書区分" len="2" type="string"/>
  <item name="項目コード" len="6" col="$journal.detail.pat_exam_main.exam_result_info.item_cd" type="string"/>
  <item name="負荷時間" len="10" type="string"/>
  <item name="負荷時間ソート順" len="6" type="string"/>
  <item name="検査状況" len="1" type="string"/>
  <item name="緊急区分" len="1" type="string"/>
  <item name="検査結果値" len="8" type="string"/>
  <item name="付加コメント1" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd1" type="string"/>
  <item name="付加コメント2" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd2" type="string"/>
  <item name="基準値外マーク" len="1" col="$journal.detail.pat_exam_main.exam_result_info.hl" type="string"/>
  <item name="材料コード" len="3" type="string"/>
  <item name="編集結果値" len="12" col="$journal.detail.pat_exam_main.exam_result_info.result" type="string"/>
  <item name="更新日付" len="14" col="$journal.detail.pat_exam_main.exam_result_info.result_date" type="string"/>
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
  <item name="未使用" len="10" type="string"/>
  <item name="基準上限値" len="8" col="$journal.detail.pat_exam_main.exam_result_info.upper" type="string"/>
  <item name="基準下限値" len="8" col="$journal.detail.pat_exam_main.exam_result_info.lower" type="string"/>
  <item name="JLAC-10コード" len="20" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-309000002, 'N_hosp', 'exam_rst', 'R', '検査コメント詳細', 'all', 'NEC想定検査結果受信', 'For test', '1', '<root name="検査コメント詳細">
  <item name="病院番号" len="2" type="string"/>
  <item name="患者番号" len="10" type="string"/>
  <item name="採取日" len="8" type="string"/>
  <item name="採取時間" len="4" type="string"/>
  <item name="オーダ番号" len="13" type="string"/>
  <item name="オーダサブ番号" len="3" type="string"/>
  <item name="検体番号" len="13" type="string"/>
  <item name="報告書区分" len="2" type="string"/>
  <item name="検体コメントコード" len="2" type="string"/>
  <item name="検体コメント名称" len="200" col="$journal.detail.pat_exam_main.exam_result_info.freememo" type="string"/>
  <item name="更新日付" len="14" type="string"/>
  <item name="更新端末" len="10" type="string"/>
  <item name="更新者" len="10" type="string"/>
</root>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
