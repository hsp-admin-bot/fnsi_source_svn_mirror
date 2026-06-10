-- 以下のCREATE TABLE文は、マスタメンテナンス機能開発用の仮テーブルです。

-- テーブル削除（テスト用マスタ）
DROP TABLE IF EXISTS mst_test_table;
-- テーブル作成（テスト用マスタ）
CREATE TABLE mst_test_table (
  facility_cd character varying(6) not null
  , die_cd bigserial not null
  , die_name character varying(80) not null
  , memo character varying(256)
  , is_del character varying(1) default '0'
  , reg_date timestamp(6) without time zone
  , up_date timestamp(6) without time zone
  , test_numeric numeric(8)
  , test_date date
  , test_numeric2 numeric(10, 2)
  , is_disp character varying(1)
  , primary key (die_cd)
);
