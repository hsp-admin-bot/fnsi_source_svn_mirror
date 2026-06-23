--------------------------------------------------
-- バイタルグラフマスタ
--------------------------------------------------
-- テーブル削除
DROP TABLE IF EXISTS mst_vital_graph;
-- テーブル作成
CREATE TABLE ntss.mst_vital_graph (
	vital_graph_cd serial NOT NULL, -- バイタルグラフコード
	facility_cd varchar(6) NULL, -- 施設コード
	vital_graph_name varchar(256) NULL, -- バイタルグラフ名
	vital_line_color varchar(7) NULL, -- 線色
	vital_line_size int NULL, -- 線サイズ
	vital_line_type varchar(1) NULL, -- 線タイプ
	vital_line_type_value varchar(2) NULL, -- 線タイプ値
	vital_point_color varchar(7) NULL, -- ポイント色
	vital_point_size int NULL, -- ポイントサイズ
	vital_point_type varchar(1) NULL, -- ポイントタイプ
	vital_point_type_value varchar(15) NULL, -- ポイントタイプ値
	is_disp varchar(1) NULL DEFAULT '1'::character varying, -- 表示フラグ
	is_del varchar(1) NULL DEFAULT '0'::character varying, -- 削除フラグ
	reg_date timestamp NULL, -- 登録日時
	up_date timestamp NULL, -- 更新日時
	CONSTRAINT unq_mst_vital_graph_01 PRIMARY KEY (vital_graph_cd),
	CONSTRAINT mst_vital_graph_facility_cd_fkey FOREIGN KEY (facility_cd) REFERENCES ntss.mst_facility(facility_cd)
);

-- コメント追加
COMMENT ON TABLE "mst_vital_graph" IS E'バイタルグラフマスタ';
COMMENT ON COLUMN "mst_vital_graph"."vital_graph_cd" IS E'バイタルグラフコード';
COMMENT ON COLUMN "mst_vital_graph"."facility_cd" IS E'施設コード';
COMMENT ON COLUMN "mst_vital_graph"."vital_graph_name" IS E'バイタルグラフ名';
COMMENT ON COLUMN "mst_vital_graph"."vital_line_color" IS E'線色';
COMMENT ON COLUMN "mst_vital_graph"."vital_line_size" IS E'線サイズ';
COMMENT ON COLUMN "mst_vital_graph"."vital_line_type" IS E'線タイプ';
COMMENT ON COLUMN "mst_vital_graph"."vital_line_type_value" IS E'線タイプ値';
COMMENT ON COLUMN "mst_vital_graph"."vital_point_color" IS E'ポイント色';
COMMENT ON COLUMN "mst_vital_graph"."vital_point_size" IS E'ポイントサイズ';
COMMENT ON COLUMN "mst_vital_graph"."vital_point_type" IS E'ポイントタイプ';
COMMENT ON COLUMN "mst_vital_graph"."vital_point_type_value" IS E'ポイントタイプ値';
COMMENT ON COLUMN "mst_vital_graph"."is_disp" IS E'表示フラグ';
COMMENT ON COLUMN "mst_vital_graph"."is_del" IS E'削除フラグ';
COMMENT ON COLUMN "mst_vital_graph"."reg_date" IS E'登録日時';
COMMENT ON COLUMN "mst_vital_graph"."up_date" IS E'更新日時';
