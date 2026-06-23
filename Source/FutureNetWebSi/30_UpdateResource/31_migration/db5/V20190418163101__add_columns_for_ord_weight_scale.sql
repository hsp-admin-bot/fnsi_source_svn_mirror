--ord_weight_scaleに列を追加
ALTER TABLE
  ord_weight_scale
ADD COLUMN treatment_cd integer;  --治療方法コード

COMMENT ON COLUMN "ord_weight_scale"."treatment_cd" IS E'治療方法コード';

ALTER TABLE
  ord_weight_scale
ADD COLUMN treatment_name character varying;  --治療方法名

COMMENT ON COLUMN "ord_weight_scale"."treatment_name" IS E'治療方法名';