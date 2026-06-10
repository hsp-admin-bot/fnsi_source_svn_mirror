--施設設定にスケールベッド設定項目を追加する。
--データ追加(sys_facility_settingへのデータ追加)										
--データ削除
DELETE FROM sys_facility_setting WHERE facility_setting_no = '3145' or facility_setting_no = '3146';
--データ追加
insert into sys_facility_setting
(
facility_setting_no, setting_name, function_name, default_value, input_type, option_value, maker_setting, description, disp_order, reg_date, up_date,system_use_disp
) 
values (
'3145','スケールベッド自動更新間隔（秒）','スケールベッド',30,2,'[{min:10,  max:600}]',0,'スケールベッドリスト自動更新の間隔(秒)を設定します。',121,current_timestamp,current_timestamp,2
), (
'3146','スケールベッド患者切り替えタイミング','スケールベッド',2,4,'[{id:1,name:1:後体重測定},{id:2,name:2:実績初版確定}]',0,'スケールベッドリスト上で治療終了患者がスケールベッドを離れるタイミングを設定します。',122,current_timestamp,current_timestamp,2
);
