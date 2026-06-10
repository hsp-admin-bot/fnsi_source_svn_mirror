-- 管理者アカウントの個人情報の削除
-- 既に登録されている場合はコメントアウトして下さい。
DELETE FROM mst_personal_user WHERE user_id = 1;
-- 管理者アカウントの個人情報を登録
INSERT INTO mst_personal_user(
    user_id,
    facility_cd,
    user_type,
    user_last_name,
    user_first_name,
    user_last_name_kana,
    user_first_name_kana,
    administrator,
    reg_date,
    up_date
)
VALUES(
    1,
    'nkknkk',
    1,
    personal_info_encrypt('初期'),
    personal_info_encrypt('管理者'),
    personal_info_encrypt('ショキ'),
    personal_info_encrypt('カンリシャ'),
    1,
    now(),
    now()
);
