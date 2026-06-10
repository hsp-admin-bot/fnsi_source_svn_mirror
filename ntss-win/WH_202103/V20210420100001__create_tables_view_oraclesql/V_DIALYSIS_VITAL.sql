-- ----------------------------
-- Table structure for V_DIALYSIS_VITAL
-- ----------------------------
DROP TABLE "V_DIALYSIS_VITAL";
CREATE TABLE "V_DIALYSIS_VITAL" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "START_DATE" DATE,
  "OCCUR_DATE" DATE,
  "BP_MAX" NUMBER(5,0),
  "BP_MIN" NUMBER(5,0),
  "BP_AVE" NUMBER(5,0),
  "PULSE" NUMBER(5,0),
  "TEMPERATURE" NUMBER,
  "BLOOD_SUGAR_LEVEL" NUMBER(5,0),
  "UP_DATE" DATE,
  "DIADYSIS_NO" NUMBER(12,0),
  "BP_CLASS" CHAR(1 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_DIALYSIS_VITAL
-- ----------------------------
ALTER TABLE "V_DIALYSIS_VITAL" ADD CONSTRAINT "SYS_C007468" PRIMARY KEY ("PATID");
