DELETE FROM mst_user_authentication WHERE user_id = 100;
-- テスト用の認証情報を登録
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
    100,
    '012345',
    'test01',
    'test99',
    0,
    '2020-03-16 13:00:00.000',
    '2020-03-16 13:05:00.000'
);
