-- ----------------------------
-- Table structure for V_IND_DIALYSIS_ADD
-- ----------------------------
DROP TABLE "V_IND_DIALYSIS_ADD";
CREATE TABLE "V_IND_DIALYSIS_ADD" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "DIALYSIS_DATE" VARCHAR2(8 BYTE),
  "PLURAL" NUMBER,
  "CTL_NO" CHAR(7 BYTE),
  "UP_DATE" DATE,
  "ADDITION" VARCHAR2(1024 BYTE),
  "INDICATOR_CD" CHAR(10 BYTE),
  "OPE_IND_PLAN" CHAR(1 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_IND_DIALYSIS_ADD
-- ----------------------------
ALTER TABLE "V_IND_DIALYSIS_ADD" ADD CONSTRAINT "SYS_C007465" PRIMARY KEY ("PATID");

-- ----------------------------
-- Checks structure for table V_IND_DIALYSIS_ADD
-- ----------------------------
ALTER TABLE "V_IND_DIALYSIS_ADD" ADD CONSTRAINT "SYS_C007464" CHECK ("PATID" IS NOT NULL) NOT DEFERRABLE INITIALLY IMMEDIATE NORELY VALIDATE;
