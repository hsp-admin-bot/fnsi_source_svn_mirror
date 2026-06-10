--mst_facilityに列を追加
ALTER TABLE
  mst_facility
  ADD COLUMN sales_email_address character varying(255)  --担当営業メールアドレス
;

COMMENT ON COLUMN "mst_facility"."sales_email_address" IS E'担当営業メールアドレス';
