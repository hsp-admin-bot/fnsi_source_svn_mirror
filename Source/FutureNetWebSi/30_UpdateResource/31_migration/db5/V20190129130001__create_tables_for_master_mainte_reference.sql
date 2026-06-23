-- マスタメンテナンス機能開発用の仮テーブルへの列の追加
ALTER TABLE mst_test_table ADD COLUMN combo1a character varying(3);
ALTER TABLE mst_test_table ADD COLUMN combo1b numeric(3);
ALTER TABLE mst_test_table ADD COLUMN combo2 bigint;

-- 以下のCREATE TABLE文は、マスタメンテナンス機能開発用の仮参照用テーブルです。

-- テーブル削除（参照テスト用マスタ）
DROP TABLE IF EXISTS mst_test_ref_table;
-- テーブル作成（参照テスト用マスタ）
CREATE TABLE mst_test_ref_table (
  facility_cd character varying(6) not null
  , ref_cd bigserial not null
  , ref_name character varying(80) not null
  , is_disp character varying(1)
  , is_del character varying(1) default '0'
  , reg_date timestamp(6) without time zone
  , up_date timestamp(6) without time zone
  , primary key (ref_cd)
);
