-- ----------------------------
-- Table structure for V_PAT_RECEIPT_MEMO
-- ----------------------------
DROP TABLE "V_PAT_RECEIPT_MEMO";
CREATE TABLE "V_PAT_RECEIPT_MEMO" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "UP_DATE" DATE,
  "DIVISION" CHAR(1 BYTE),
  "CODE" CHAR(4 BYTE),
  "CODE_UPDATE" DATE,
  "ADD_FLG" CHAR(1 BYTE),
  "ITEM_NAME" VARCHAR2(256 BYTE),
  "MAIN_DIAL_DIFF" CHAR(1 BYTE),
  "IN_HOSPITAL_CD" CHAR(20 BYTE),
  "IN_HOSPITAL_CD2" CHAR(20 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_PAT_RECEIPT_MEMO
-- ----------------------------
ALTER TABLE "V_PAT_RECEIPT_MEMO" ADD CONSTRAINT "SYS_C007430" PRIMARY KEY ("PATID");

-- ----------------------------
-- Checks structure for table V_PAT_RECEIPT_MEMO
-- ----------------------------
ALTER TABLE "V_PAT_RECEIPT_MEMO" ADD CONSTRAINT "SYS_C007429" CHECK ("PATID" IS NOT NULL) NOT DEFERRABLE INITIALLY IMMEDIATE NORELY VALIDATE;
