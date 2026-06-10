UPDATE ntss.sys_facility_setting
SET option_value = '[{"id":"0","name":"0：登録順"},{"id":"1","name":"1：薬剤分類マスタ表示順"},{"id":"2","name":"2：薬剤区分（通常薬剤＞セット薬剤(調整薬剤)）"},{"id":"3","name":"3：薬剤マスタ表示順"},{"id":"4","name":"4：投与時間帯"},{"id":"5","name":"5：手技"},{"id":"6","name":"6：投薬パターンコード"}]'
WHERE facility_setting_no LIKE '3007' ESCAPE '#';

UPDATE ntss.sys_facility_setting
SET option_value = '[{"id":"0","name":"0：登録順"},{"id":"1","name":"1：医療材料分類マスタ表示順"},{"id":"2","name":"2：医療材料マスタ表示順"}]'
WHERE facility_setting_no LIKE '3006' ESCAPE '#';