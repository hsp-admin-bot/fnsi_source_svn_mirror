TRUNCATE TABLE mst_personal_tab_define;

INSERT INTO mst_personal_tab_define
  (facility_cd, tab_define_cd, display_name, contents_id, disp_order, is_disp, is_del, mode)
VALUES
  ('009999', 1, 'タブA', 'tab-contents-A', 5, '1', '0', '0')
  , ('009999', 2, 'タブB', 'tab-contents-B', 7, '0', '1', '0')
  , ('009999', 3, 'タブC', 'tab-contents-C', 2, '1', '0', '1')
  , ('009999', 4, 'タブD', 'tab-contents-D', 3, '1', '1', '1')
  , ('009999', 5, 'タブE', 'tab-contents-E', 4, '0', '0', '0')
  , ('000001', 6, 'タブF', 'tab-contents-F', 1, '1', '0', '1')
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_personal_tab_define
ADD COLUMN dummy character varying(1) -- ダミー列
;
