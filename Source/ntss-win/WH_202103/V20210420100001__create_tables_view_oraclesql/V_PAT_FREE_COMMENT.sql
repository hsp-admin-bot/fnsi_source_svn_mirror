-- ----------------------------
-- Table structure for V_PAT_FREE_COMMENT
-- ----------------------------
DROP TABLE "V_PAT_FREE_COMMENT";
CREATE TABLE "V_PAT_FREE_COMMENT" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "CTL_NO" NUMBER(2,0),
  "TITLE" VARCHAR2(80 BYTE),
  "CONTENT" VARCHAR2(3500 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_PAT_FREE_COMMENT
-- ----------------------------
ALTER TABLE "V_PAT_FREE_COMMENT" ADD CONSTRAINT "SYS_C007481" PRIMARY KEY ("PATID");
