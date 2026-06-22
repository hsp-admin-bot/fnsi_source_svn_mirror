-- ----------------------------
-- Table structure for V_MNT_WATER_SURVEY
-- ----------------------------
DROP TABLE "V_MNT_WATER_SURVEY";
CREATE TABLE "V_MNT_WATER_SURVEY" (
  "SURVEY_POINT_CD" CHAR(5 BYTE) NOT NULL,
  "SURVEY_POINT_NAME" VARCHAR2(64 BYTE),
  "UP_DATE" DATE,
  "CHECK_DATE" CHAR(8 BYTE),
  "RESULT" NUMBER,
  "UNIT" VARCHAR2(64 BYTE),
  "DETAIL" VARCHAR2(2048 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_MNT_WATER_SURVEY
-- ----------------------------
ALTER TABLE "V_MNT_WATER_SURVEY" ADD CONSTRAINT "SYS_C007474" PRIMARY KEY ("SURVEY_POINT_CD");

-- ----------------------------
-- Checks structure for table V_MNT_WATER_SURVEY
-- ----------------------------
ALTER TABLE "V_MNT_WATER_SURVEY" ADD CONSTRAINT "SYS_C007473" CHECK ("SURVEY_POINT_CD" IS NOT NULL) NOT DEFERRABLE INITIALLY IMMEDIATE NORELY VALIDATE;
