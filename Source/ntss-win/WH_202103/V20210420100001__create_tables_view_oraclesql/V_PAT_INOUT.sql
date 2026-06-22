-- ----------------------------
-- Table structure for V_PAT_INOUT
-- ----------------------------
DROP TABLE "V_PAT_INOUT";
CREATE TABLE "V_PAT_INOUT" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "CTL_NO" CHAR(3 BYTE),
  "REG_DATE" DATE,
  "INOUT_CD" CHAR(1 BYTE),
  "FACILITY_NAME" VARCHAR2(100 BYTE),
  "DR_NAME" VARCHAR2(20 BYTE),
  "MEMO" VARCHAR2(256 BYTE),
  "CODE_NAME" VARCHAR2(4 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_PAT_INOUT
-- ----------------------------
ALTER TABLE "V_PAT_INOUT" ADD CONSTRAINT "SYS_C007470" PRIMARY KEY ("PATID");
