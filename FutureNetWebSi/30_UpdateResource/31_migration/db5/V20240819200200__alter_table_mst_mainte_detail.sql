ALTER TABLE mst_mainte_detail
ADD COLUMN IF NOT EXISTS fn_mainte_type character varying(1);
COMMENT ON COLUMN "ntss"."mst_mainte_detail"."fn_mainte_type" IS 'FNW+で点検種別コード';

ALTER TABLE "ntss"."mst_mainte_detail" ALTER COLUMN fn_mainte_detail_cd TYPE VARCHAR (1000);

ALTER TABLE mst_mainte_category
ADD COLUMN IF NOT EXISTS fn_mainte_type character varying(1);
COMMENT ON COLUMN "ntss"."mst_mainte_category"."fn_mainte_type" IS 'FNW+で点検種別コード';

ALTER TABLE "ntss"."mst_mainte_category" ALTER COLUMN fn_mainte_category_cd TYPE VARCHAR (1000);