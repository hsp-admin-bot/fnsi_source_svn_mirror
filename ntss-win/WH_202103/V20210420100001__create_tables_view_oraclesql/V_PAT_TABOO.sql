-- ----------------------------
-- Table structure for V_PAT_TABOO
-- ----------------------------
DROP TABLE "V_PAT_TABOO";
CREATE TABLE "V_PAT_TABOO" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "NAME" VARCHAR2(40 BYTE),
  "CTL_NO" NUMBER,
  "UP_DATE" DATE,
  "TABOO" VARCHAR2(512 BYTE),
  "MEMO" VARCHAR2(512 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_PAT_TABOO
-- ----------------------------
ALTER TABLE "V_PAT_TABOO" ADD CONSTRAINT "SYS_C007494" PRIMARY KEY ("PATID");
