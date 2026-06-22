--麻薬施用者免許証番号
ALTER TABLE mst_personal_user
    ADD COLUMN anesthesiologist_license_no character varying;

COMMENT ON COLUMN "mst_personal_user"."anesthesiologist_license_no" IS E'麻薬施用者免許証番号';