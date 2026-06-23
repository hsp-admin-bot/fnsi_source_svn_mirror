--ord_mainに列を追加
ALTER TABLE
  ord_main
ADD COLUMN weight_scale_no bigint  --実績：体重測定記録番号
;


COMMENT ON COLUMN "ord_main"."weight_scale_no" IS E'実績：体重測定記録番号';
