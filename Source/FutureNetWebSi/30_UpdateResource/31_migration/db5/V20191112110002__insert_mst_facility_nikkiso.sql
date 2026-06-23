-- 日機装施設登録
-- 既に登録されている場合はUPDATEします.
INSERT INTO mst_facility(
    facility_cd,
    facility_name,
    facility_name_kana,
    prefectures_cd,
    department_cd,
    m_notice_mail_template,
    alive_moni_interval,
    use_function,
    reg_date,
    up_date
)
VALUES(
    'nkknkk',
    '日機装株式会社',
    'ニッキソウカブシキガイシャ',
    '22',
    'MG40',
    '各位

装置からの警報発生を以下の通り連絡致します。

■施設名：[施設名]
■装置名：[装置名]
■発生日時：[発生日時]
■型式：[型式]
■製造番号：[製造番号]
■装置記録メッセージ：[装置記録メッセージ]

■発報対象者名：[発報対象者名]

[URL]

サービスダイレクトコール
固定電話からの場合             ：0120-444-278
携帯電話・PHSからの場合  ：03-4520-5297
',
    null,
    '{"func_cds": [{"func_cd": "005"}]}',
    now(),
    now()
)
ON CONFLICT (facility_cd)
DO UPDATE SET
    facility_cd = 'nkknkk',
    facility_name = '日機装株式会社',
    facility_name_kana = 'ニッキソウカブシキガイシャ',
    prefectures_cd = '22',
    department_cd = 'MG40',
    m_notice_mail_template = '各位

装置からの警報発生を以下の通り連絡致します。

■施設名：[施設名]
■装置名：[装置名]
■発生日時：[発生日時]
■型式：[型式]
■製造番号：[製造番号]
■装置記録メッセージ：[装置記録メッセージ]

■発報対象者名：[発報対象者名]

[URL]

サービスダイレクトコール
固定電話からの場合             ：0120-444-278
携帯電話・PHSからの場合  ：03-4520-5297
',
    alive_moni_interval = null,
    use_function = '{"func_cds": [{"func_cd": "005"}]}',
    reg_date = now(),
    up_date = now()
;
