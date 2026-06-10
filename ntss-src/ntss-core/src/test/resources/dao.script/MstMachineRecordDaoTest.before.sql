DELETE FROM mst_machine_record;

INSERT INTO
  mst_machine_record
  (
    machine_record_cd,
    is_default,
    log_class,
    target_model
  )
VALUES
  (
    '0001',
    '0',
    '1',
    '1'
  ),
  (
    '0002',
    '0',
    '3',
    '4'
  ),
  (
    'FFFF',
    '1',
    '6',
    '6'
  )
;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_machine_record
ADD COLUMN dummy character varying(1) -- ダミー列
;
