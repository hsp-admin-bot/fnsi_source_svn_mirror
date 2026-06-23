DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-12074001,-12075001,-12076001);

INSERT INTO ntss.mst_coop_layout(ctl_no,facility_cd,coop_cd,coop_cd_index,direction,coop_cd_sub,coop_format,coop_name,coop_vender,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version)
 VALUES (-12074001,'F_SX','iji_dial','','S','cre','text','SX連携_医事実績','F_SX','医事実績','1','<root name="医事実績" multi="true:CR">
 <item name="処理種別"  len="2"   value="const:01"/>
 <item name="オーダ種別"  len="2"   value="const:D0"/>
 <item name="オーダ番号"  len="8"   value="$JOURNAL.coop_ord_no"/>
 <item name="患者番号"  len="10"   value="dataset:-1201007.hosp_pat_id"/>
 <item name="診療日付"  len="8"   value="dataset:-506.start_date8"/>
 <item name="診療科コード"  len="2"   value="const:01"/>
 <item name="入外区分"  len="1"   value="dataset:-1201001.in_out"/>
 <item name="病棟コード"  len="3"   value="$BLANK"/>
 <item name="病室番号"  len="5"   value="$BLANK"/>
 <item name="医科歯科区分"  len="1"   value="$BLANK"/>
 <item name="適用保険選択番号"  len="2"   value="const:00"/>
 <item name="ドクターコード"  len="8"   value="const:01"/>
 <item name="新生児区分"  len="1"   value="$BLANK"/>
 <item name="処方区分"  len="1"   value="$BLANK"/>
 <item name="部門番号"  len="8"   value="$BLANK"/>
 <item name="管理部予備"  len="2"   value="$BLANK"/>
 <item name="実施区分"  len="1"   value="$BLANK"/>
 <item name="実施日付"  len="8"   value="$BLANK"/>
 <item name="実施時刻"  len="4"   value="$BLANK"/>
 <item name="実施オペレータコード"  len="3"   value="$BLANK"/>
 <item name="実施更新フラグ"  len="1"   value="$BLANK"/>
 <item name="実施部予備"  len="15"   value="$BLANK"/>
 <item name="伝票コード"  len="3"   value="const:000"/>
 <item name="明細数"  len="2"   value="const:10"/>
 <occ  name="明細情報" repeat="10" detail="医事" sqlCode="-1202022"/>
 <item name="明細予備"  len="4"   value="$BLANK"/>
 <item name="改行定数" len="1" value="$CR"/>
</root>','{"dataset": [{"patId": "patId", "sqlCode": -1202021}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1202022, "facilityCd": "facility_cd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -506}, {"key0": "key0", "patId": "patId", "sqlCode": -1200000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -1201001, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1201007, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -1202023}}','1','0',1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'F_SX');

INSERT INTO ntss.mst_coop_layout(ctl_no,facility_cd,coop_cd,coop_cd_index,direction,coop_cd_sub,coop_format,coop_name,coop_vender,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES 
    (-12075001,'F_SX','iji_dial','','S','upd','text','SX連携_医事実績','F_SX','医事実績','1','<root name="医事実績" multi="true:CR">
 <item name="処理種別"  len="2"   value="const:02"/>
 <item name="オーダ種別"  len="2"   value="const:D0"/>
 <item name="オーダ番号"  len="8"   value="$JOURNAL.coop_ord_no"/>
 <item name="患者番号"  len="10"   value="dataset:-1201007.hosp_pat_id"/>
 <item name="診療日付"  len="8"   value="dataset:-506.start_date8"/>
 <item name="診療科コード"  len="2"   value="const:01"/>
 <item name="入外区分"  len="1"   value="dataset:-1201001.in_out"/>
 <item name="病棟コード"  len="3"   value="$BLANK"/>
 <item name="病室番号"  len="5"   value="$BLANK"/>
 <item name="医科歯科区分"  len="1"   value="$BLANK"/>
 <item name="適用保険選択番号"  len="2"   value="const:00"/>
 <item name="ドクターコード"  len="8"   value="const:01"/>
 <item name="新生児区分"  len="1"   value="$BLANK"/>
 <item name="処方区分"  len="1"   value="$BLANK"/>
 <item name="部門番号"  len="8"   value="$BLANK"/>
 <item name="管理部予備"  len="2"   value="$BLANK"/>
 <item name="実施区分"  len="1"   value="$BLANK"/>
 <item name="実施日付"  len="8"   value="$BLANK"/>
 <item name="実施時刻"  len="4"   value="$BLANK"/>
 <item name="実施オペレータコード"  len="3"   value="$BLANK"/>
 <item name="実施更新フラグ"  len="1"   value="$BLANK"/>
 <item name="実施部予備"  len="15"   value="$BLANK"/>
 <item name="伝票コード"  len="3"   value="const:000"/>
 <item name="明細数"  len="2"   value="const:10"/>
 <occ  name="明細情報" repeat="10" detail="医事" sqlCode="-1202022"/>
 <item name="明細予備"  len="4"   value="$BLANK"/>
 <item name="改行定数" len="1" value="$CR"/>
</root>','{"dataset": [{"patId": "patId", "sqlCode": -1202021}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1202022, "facilityCd": "facility_cd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -506}, {"key0": "key0", "patId": "patId", "sqlCode": -1200000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -1201001, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1201007, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -1202023}}','1','0',1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'F_SX');

INSERT INTO ntss.mst_coop_layout(ctl_no,facility_cd,coop_cd,coop_cd_index,direction,coop_cd_sub,coop_format,coop_name,coop_vender,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES 
    (-12076001,'F_SX','iji_dial','','S','del','text','SX連携_医事実績','F_SX','医事実績','1','<root name="医事実績" multi="true:CR">
 <item name="処理種別"  len="2"   value="const:03"/>
 <item name="オーダ種別"  len="2"   value="const:D0"/>
 <item name="オーダ番号"  len="8"   value="$JOURNAL.coop_ord_no"/>
 <item name="患者番号"  len="10"   value="dataset:-1201007.hosp_pat_id"/>
 <item name="診療日付"  len="8"   value="dataset:-506.start_date8"/>
 <item name="診療科コード"  len="2"   value="const:01"/>
 <item name="入外区分"  len="1"   value="dataset:-1201001.in_out"/>
 <item name="病棟コード"  len="3"   value="$BLANK"/>
 <item name="病室番号"  len="5"   value="$BLANK"/>
 <item name="医科歯科区分"  len="1"   value="$BLANK"/>
 <item name="適用保険選択番号"  len="2"   value="const:00"/>
 <item name="ドクターコード"  len="8"   value="const:01"/>
 <item name="新生児区分"  len="1"   value="$BLANK"/>
 <item name="処方区分"  len="1"   value="$BLANK"/>
 <item name="部門番号"  len="8"   value="$BLANK"/>
 <item name="管理部予備"  len="2"   value="$BLANK"/>
 <item name="実施区分"  len="1"   value="$BLANK"/>
 <item name="実施日付"  len="8"   value="$BLANK"/>
 <item name="実施時刻"  len="4"   value="$BLANK"/>
 <item name="実施オペレータコード"  len="3"   value="$BLANK"/>
 <item name="実施更新フラグ"  len="1"   value="$BLANK"/>
 <item name="実施部予備"  len="15"   value="$BLANK"/>
 <item name="伝票コード"  len="3"   value="const:000"/>
 <item name="明細数"  len="2"   value="const:10"/>
 <occ  name="明細情報" repeat="10" detail="医事" sqlCode="-1202022"/>
 <item name="明細予備"  len="4"   value="$BLANK"/>
 <item name="改行定数" len="1" value="$CR"/>
</root>','{"dataset": [{"patId": "patId", "sqlCode": -1202021}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1202022, "facilityCd": "facility_cd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -506}, {"key0": "key0", "patId": "patId", "sqlCode": -1200000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -1201001, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1201007, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -1202023}}','1','0',1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'F_SX');
