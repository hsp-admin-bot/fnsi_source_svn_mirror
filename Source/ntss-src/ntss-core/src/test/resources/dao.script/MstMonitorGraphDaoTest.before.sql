DELETE FROM mst_monitor_graph;
DELETE FROM mst_facility where facility_cd in ('1001', '1002', '9999');

INSERT INTO
  mst_facility
  (
    facility_cd
    , facility_name
  )
VALUES
  (
    '1001'
    , 'sisetu1'
  )
  , (
    '1002'
    , 'sisetu2'
  )
;

INSERT INTO
  mst_monitor_graph
  (
    monitor_graph_cd
    , facility_cd
    , monitor_graph_name
    , left_data_index
    , left_color
    , right_data_index
    , right_color
    , is_disp
    , is_del
  )
VALUES
  (
    1
    , '1001'
    , 'name1'
    , '11'
    , '#ff0001'
    , '21'
    , '#ff0011'
    , '1'
    , '0'
  )
  , (
    2
    , '1001'
    , 'name2'
    , '12'
    , '#ff0002'
    , '22'
    , '#ff0012'
    , '1'
    , '0'
  )
  , (
    3
    , '1001'
    , 'name3'
    , '13'
    , '#ff0003'
    , '23'
    , '#ff0013'
    , '0'
    , '0'
  )
  , (
    4
    , '1001'
    , 'name4'
    , '14'
    , '#ff0004'
    , '24'
    , '#ff0014'
    , '1'
    , '1'
   )
  , (
    5
    , '1002'
    , 'name5'
    , '15'
    , '#ff0005'
    , '25'
    , '#ff0015'
    , '1'
    , '0'
  )
;

-- テスト前にmst_m_noticeにダミー列を追加
ALTER TABLE
  mst_monitor_graph
ADD COLUMN dummy character varying(1) -- ダミー列
;
