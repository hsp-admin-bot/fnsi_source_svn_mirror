--pat_personal_mainにカラムを追加
alter table pat_personal_main add primary_disease_cd integer;
COMMENT ON COLUMN "pat_personal_main"."primary_disease_cd" IS E'原疾患コード';
