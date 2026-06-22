ALTER TABLE ntss.ord_personal_prescription DROP COLUMN IF EXISTS insurance_name;
ALTER TABLE ntss.ord_personal_prescription ADD insurance_name varchar(256) NULL;
COMMENT ON COLUMN ntss.ord_personal_prescription.insurance_name IS '名前';

ALTER TABLE ntss.ord_personal_prescription DROP COLUMN IF EXISTS insu_name_short;
ALTER TABLE ntss.ord_personal_prescription ADD insu_name_short varchar(4) NULL;
COMMENT ON COLUMN ntss.ord_personal_prescription.insu_name_short IS '略称';

ALTER TABLE ntss.ord_personal_prescription DROP COLUMN IF EXISTS insu_info;
ALTER TABLE ntss.ord_personal_prescription ADD insu_info jsonb NULL;
COMMENT ON COLUMN ntss.ord_personal_prescription.insu_info IS '保険情報';

ALTER TABLE ntss.ord_personal_prescription DROP COLUMN IF EXISTS insu_pub_info;
ALTER TABLE ntss.ord_personal_prescription ADD insu_pub_info jsonb NULL;
COMMENT ON COLUMN ntss.ord_personal_prescription.insu_pub_info IS '公費情報';

ALTER TABLE ntss.ord_personal_prescription DROP COLUMN IF EXISTS insu_set_info;
ALTER TABLE ntss.ord_personal_prescription ADD insu_set_info jsonb NULL;
COMMENT ON COLUMN ntss.ord_personal_prescription.insu_set_info IS 'セット情報';

ALTER TABLE ntss.ord_personal_prescription DROP COLUMN IF EXISTS insu_self_info;
ALTER TABLE ntss.ord_personal_prescription ADD insu_self_info jsonb NULL;
COMMENT ON COLUMN ntss.ord_personal_prescription.insu_self_info IS '自費情報';

ALTER TABLE ntss.ord_personal_prescription DROP COLUMN IF EXISTS memo1;
ALTER TABLE ntss.ord_personal_prescription ADD memo1 varchar NULL;
COMMENT ON COLUMN ntss.ord_personal_prescription.memo1 IS '保険メモ1';

ALTER TABLE ntss.ord_personal_prescription DROP COLUMN IF EXISTS memo2;
ALTER TABLE ntss.ord_personal_prescription ADD memo2 varchar NULL;
COMMENT ON COLUMN ntss.ord_personal_prescription.memo2 IS '保険メモ2';
