--ord_weight_scaleに列を追加
ALTER TABLE
  ord_weight_scale
ADD COLUMN device_mode numeric(2,0);  --装置モード

COMMENT ON COLUMN "ord_weight_scale"."device_mode" IS E'装置モード';

ALTER TABLE
  ord_weight_scale
ADD COLUMN print_content jsonb;  --レシート内容
COMMENT ON COLUMN "ord_weight_scale"."print_content" IS E'レシート内容';
ALTER TABLE
  ord_weight_scale
ADD COLUMN print_status smallint;  --印刷結果
COMMENT ON COLUMN "ord_weight_scale"."print_status" IS E'印刷結果';
ALTER TABLE
  ord_weight_scale
ADD COLUMN print_error_message character varying(256);  --印刷エラーメッセージ
COMMENT ON COLUMN "ord_weight_scale"."print_error_message" IS E'印刷エラーメッセージ';



