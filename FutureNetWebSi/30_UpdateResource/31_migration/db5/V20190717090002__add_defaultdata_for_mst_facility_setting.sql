-- 施設設定マスタ
delete from mst_facility_setting where ctl_no = 4;
insert into mst_facility_setting (facility_cd, ctl_no, function_cd, name, value, description, is_editable, reg_date, up_date) select facility_cd, 4, '007', '透析困難リセット機能', '0', '透析困難リセット機能の使用設定。（0：OFF、1：ON）\n　「1：ON」に設定した場合、患者情報画面で入外区分を入院から外来に切り替えて登録する際に、透析困難情報をリセットします。リセットを行う際は処理前に確認メッセージが表示され、リセットを行うか否か選択することが出来ます。', '1', current_timestamp, current_timestamp from mst_facility;
