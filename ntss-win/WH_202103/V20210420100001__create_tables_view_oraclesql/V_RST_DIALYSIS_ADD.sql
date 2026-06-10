-- ----------------------------
-- Table structure for V_RST_DIALYSIS_ADD
-- ----------------------------
DROP TABLE "V_RST_DIALYSIS_ADD";
CREATE TABLE "V_RST_DIALYSIS_ADD" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "DIALYSIS_DATE" VARCHAR2(8 BYTE),
  "DIALYSIS_NO" NUMBER,
  "CTL_NO" CHAR(7 BYTE),
  "UP_DATE" DATE,
  "EFFECT_FLG" CHAR(1 BYTE),
  "EFFECT_DATE" DATE,
  "ADDITION" VARCHAR2(1024 BYTE),
  "STAFF_CD" CHAR(10 BYTE),
  "STAFF_NAME" VARCHAR2(20 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_RST_DIALYSIS_ADD
-- ----------------------------
ALTER TABLE "V_RST_DIALYSIS_ADD" ADD CONSTRAINT "SYS_C007452" PRIMARY KEY ("PATID");
