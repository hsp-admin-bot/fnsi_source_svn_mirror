-- 以下のCREATE TABLE文は、マスタメンテナンス機能開発用のモード2のサンプル用テーブルです。

-- テーブル削除（モード2サンプル用マスタ）
DROP TABLE IF EXISTS mst_test_mode2;
-- テーブル作成（モード2サンプル用マスタ）
CREATE TABLE mst_test_mode2 (
  facility_cd character varying(6) not null
  , mode2_cd bigserial not null
  , mode2_name character varying(80) not null
  , reg_date timestamp(6) without time zone
  , up_date timestamp(6) without time zone
  , primary key (mode2_cd)
);
