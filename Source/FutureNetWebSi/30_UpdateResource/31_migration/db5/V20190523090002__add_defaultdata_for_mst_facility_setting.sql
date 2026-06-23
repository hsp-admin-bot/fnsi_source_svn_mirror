-- 施設設定マスタ
delete from mst_facility_setting where ctl_no = 1;
insert into mst_facility_setting (facility_cd, ctl_no, function_cd, name, value, description, is_editable, reg_date, up_date) select facility_cd, 1, '013', '次患者更新モード', '3', '次患者更新のモードを設定します。\n　1：次クールに治療予定がある患者を次患者とします。\n　　ただし、現在時刻が当日の最後のクールの場合は翌日（翌日が休日（日曜）の場合は次の営業日）の最初のクールに治療予定がある患者を次患者とします。\n　　また、休日（日曜）に治療予定がある場合は次クールでない場合でも次患者とします。（休日（日曜）のみモード２扱いとなります。））\n　2：休日（日曜）も含め、指定期間内（当日＋次患者検索日数）の直近に治療予定がある患者を次患者とします。\n　3：翌日（翌日が休日（日曜）の場合は次の営業日）までの直近に治療予定がある患者を次患者とします。', '1', current_timestamp, current_timestamp from mst_facility;

delete from mst_facility_setting where ctl_no = 2;
insert into mst_facility_setting (facility_cd, ctl_no, function_cd, name, value, description, is_editable, reg_date, up_date) select facility_cd, 2, '013', '次患者検索日数', '1', '翌日以降の検索日数を設定します。\n※次患者更新モードで「2」を設定時のみ有効となります。', '1', current_timestamp, current_timestamp from mst_facility;
