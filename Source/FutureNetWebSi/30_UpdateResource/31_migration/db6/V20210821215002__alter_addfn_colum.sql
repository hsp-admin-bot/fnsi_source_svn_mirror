--コンバート用のfn_カラムを追加する

--ord_personal_prescription
ALTER TABLE ord_personal_prescription ADD COLUMN fn_ord_prescription_no varchar;
COMMENT ON COLUMN "ord_personal_prescription"."fn_ord_prescription_no" IS E'FNW+で管理する施設内の一意な薬剤グループコード';

--mst_personal_user
ALTER TABLE mst_personal_user ADD COLUMN fn_staff_cd character varying(10);
COMMENT ON COLUMN "mst_personal_user"."fn_staff_cd" IS E'FNW+で管理する施設内の一意なスタッフコード';