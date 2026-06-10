-- 初期ユーザー登録
-- 既に登録されている場合はUPDATEします.
INSERT INTO mst_user(
    user_id,
    user_settings,
    is_provisional,
    reg_date,
    up_date
)
VALUES(
    1,
    '{"theme": 0, "font_size": 2, "is_disp_menu": 1, "use_functions": ["005"], "initial_function": "005"}',
    0,
    now(),
    now()
)
ON CONFLICT (user_id)
DO UPDATE SET
    user_id = 1,
    user_settings = '{"theme": 0, "font_size": 2, "is_disp_menu": 1, "use_functions": ["005"], "initial_function": "005"}',
    is_provisional = 0,
    reg_date = now(),
    up_date = now()
;