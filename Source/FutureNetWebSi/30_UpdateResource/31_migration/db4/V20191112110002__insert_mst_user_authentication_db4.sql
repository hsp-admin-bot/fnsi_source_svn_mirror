-- 管理者アカウントの認証情報を削除
-- 既に登録されている場合はコメントアウトして下さい。
DELETE FROM mst_user_authentication WHERE user_id = 1;
-- 管理者アカウントの認証情報を登録
INSERT INTO mst_user_authentication(
    user_id,
    facility_cd,
    disp_user_id,
    user_password,
    failure_cnt,
    reg_date,
    up_date
)
VALUES(
    1,
    'nkknkk',
    '9900000081',
    '$2a$10$m7.ImQWlNPj.AtiIMDItKeYiDYC4WN9yFfKsRaEZv3dhLsR2Q87Si',
    0,
    now(),
    now()
);
