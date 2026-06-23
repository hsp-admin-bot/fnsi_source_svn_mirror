-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 29;
insert
into sys_system_define (
  ctl_no, 
  service_cd, 
  name, 
  value, 
  description, 
  is_enable, 
  up_date
) values ( 
  29
  , '003'
  , '施設解約設定'
  , '{"expiration": 120, "max_delete_limit": 1000, "exclude_table_list": ["mnt_facility_cancel_manage", "mst_user_authentication", "mst_facility_hash"]}'
  , '施設解約で使用する定数値を設定する。
Expiration : 処理開始から処理終了までの制限時間（分）
max_delete_limit : delete処理のコミットカウント
exclude_table_list : 削除処理対象外のテーブル'
  , '1'
  , current_timestamp
);
