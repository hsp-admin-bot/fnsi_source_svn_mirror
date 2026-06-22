-- 観察記録種別情報マスタ
TRUNCATE TABLE mst_obs_kind;
INSERT
INTO mst_obs_kind
( facility_cd, kind_name, kind_class, is_post_bbs, post_period, post_address_class,
  is_link_ord_no, is_disp, is_del, reg_date, up_date)
VALUES
('999900', '観察メモ', 0, 0, null, null, 0, 1, 0, '2019/01/31', '2019/01/31'),
('999900', 'SOAP', 1, 0, null, null, 0, 1, 0, '2019/01/31', '2019/01/31'),
('999900', 'FDAR', 2, 0, null, null, 0, 1, 0, '2019/01/31', '2019/01/31'),
('999900', 'メモ', 0, 0, null, null, 0, 1, 0, '2019/01/31', '2019/01/31'),
('999900', 'その他', 0, 0, null, null, 0, 1, 0, '2019/01/31', '2019/01/31'),
('999999', '看護メモ',  0, 0, null, null, 0, 1, 0, '2019/01/31', '2019/01/31'),
('999999', 'SOAP', 1, 0, null, null, 0, 1, 0, '2019/01/31', '2019/01/31'),
('999999', 'FDAR', 2,0, null, null, 0, 1, 0, '2019/01/31', '2019/01/31')
;