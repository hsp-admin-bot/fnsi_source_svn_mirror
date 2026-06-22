-- ----------------------------
-- Table structure for V_PAT_MEDICAL_HST
-- ----------------------------
DROP TABLE "V_PAT_MEDICAL_HST";
CREATE TABLE "V_PAT_MEDICAL_HST" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "CTL_NO" NUMBER,
  "UP_DATE" DATE,
  "DISEASE_CD" CHAR(20 BYTE),
  "DISEASE_NAME" VARCHAR2(100 BYTE),
  "DISEASE_DATE" DATE,
  "RECOVER_DATE" DATE,
  "MAIN_DISEASE" CHAR(1 BYTE),
  "STATUS" CHAR(1 BYTE),
  "NOTICE_FLG" CHAR(1 BYTE),
  "DOCTOR_NAME" VARCHAR2(20 BYTE),
  "MEMO" VARCHAR2(256 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_PAT_MEDICAL_HST
-- ----------------------------
ALTER TABLE "V_PAT_MEDICAL_HST" ADD CONSTRAINT "SYS_C007420" PRIMARY KEY ("PATID");

-- ----------------------------
-- Checks structure for table V_PAT_MEDICAL_HST
-- ----------------------------
ALTER TABLE "V_PAT_MEDICAL_HST" ADD CONSTRAINT "SYS_C007419" CHECK ("PATID" IS NOT NULL) NOT DEFERRABLE INITIALLY IMMEDIATE NORELY VALIDATE;
