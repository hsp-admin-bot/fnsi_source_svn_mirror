-- ----------------------------
-- Table structure for V_PAT_INFECT
-- ----------------------------
DROP TABLE "V_PAT_INFECT";
CREATE TABLE "V_PAT_INFECT" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "INFECTION_CD" CHAR(20 BYTE),
  "INFECTION_NAME" VARCHAR2(100 BYTE),
  "UP_DATE" DATE,
  "INFECT" CHAR(1 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_PAT_INFECT
-- ----------------------------
ALTER TABLE "V_PAT_INFECT" ADD CONSTRAINT "SYS_C007428" PRIMARY KEY ("PATID");

-- ----------------------------
-- Checks structure for table V_PAT_INFECT
-- ----------------------------
ALTER TABLE "V_PAT_INFECT" ADD CONSTRAINT "SYS_C007427" CHECK ("PATID" IS NOT NULL) NOT DEFERRABLE INITIALLY IMMEDIATE NORELY VALIDATE;
