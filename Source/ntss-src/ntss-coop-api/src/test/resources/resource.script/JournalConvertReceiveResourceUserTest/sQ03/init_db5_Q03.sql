DELETE FROM mst_user
WHERE user_id > 1;

INSERT INTO mst_user (
  user_id
, user_settings
, is_provisional
, reg_date
, up_date
, is_disp
, is_del
, pat_id
, tmp_log_search_condition
, secret_key
, is_set_qr_code
, card_idm
, is_consent
, consent_date ) values (
  999
, '{"theme": 88, "font_size": 14, "is_disp_menu": 5, "use_functions": [], "is_split_frame": 1, "ind_rst_pattern": null, "initial_function": "", "personal_settings": [], "authorized_functions": [], "authorized_authorities": []}'
, 0
, '20200803'
, '20200803'
, '1'
, '0'
, '999'
, '[{"idFilter": "101", "condition": "{\"userId\":[{\"cd\":123,\"name\":\"NNNNN\",\"cdType\":732}]}", "nameFilter": "検索条件1"}]'
, 'T1ERC3E2S8'
, 0
, 'TE3124901'
, 1
, '2020-08-03'
);
