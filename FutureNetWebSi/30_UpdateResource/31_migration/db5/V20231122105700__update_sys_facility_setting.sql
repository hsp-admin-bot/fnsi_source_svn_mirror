-- パスワードポリシー適用レベル 設定説明修正
-- 「2:ポリシー低：英小文字 と数字を含む」->「2:ポリシー低：英字と数字を含む」
UPDATE sys_facility_setting 
SET
    description = REPLACE(description, '2:ポリシー低：英小文字 と数字を含む', '2:ポリシー低：英字と数字を含む'),
    up_date = CURRENT_TIMESTAMP
WHERE
    facility_setting_no = '1036';  -- パスワードポリシー適用レベル
