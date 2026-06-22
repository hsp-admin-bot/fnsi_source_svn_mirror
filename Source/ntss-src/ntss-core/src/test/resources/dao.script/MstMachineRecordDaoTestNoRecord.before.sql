DELETE FROM mst_machine_record;

-- テスト前にダミー列を追加
ALTER TABLE
  mst_machine_record
ADD COLUMN dummy character varying(1) -- ダミー列
;
