-- ----------------------------
-- Table structure for V_PAT_CONTACT
-- ----------------------------
DROP TABLE "V_PAT_CONTACT";
CREATE TABLE "V_PAT_CONTACT" (
  "PATID" CHAR(12 BYTE) NOT NULL,
  "NAME" VARCHAR2(40 BYTE),
  "CTL_NO" NUMBER,
  "UP_DATE" DATE,
  "REG_DATE" DATE,
  "RELATION_NAME" VARCHAR2(50 BYTE),
  "RNAME" CHAR(40 BYTE),
  "ZIPCODE" CHAR(8 BYTE),
  "ADDRESS" VARCHAR2(256 BYTE),
  "ADDRESS_DETAIL" VARCHAR2(256 BYTE),
  "TELNO1" CHAR(25 BYTE),
  "TELNO2" CHAR(25 BYTE),
  "MEMO" VARCHAR2(2048 BYTE)
)
;

-- ----------------------------
-- Primary Key structure for table V_PAT_CONTACT
-- ----------------------------
ALTER TABLE "V_PAT_CONTACT" ADD CONSTRAINT "SYS_C007426" PRIMARY KEY ("PATID");

-- ----------------------------
-- Checks structure for table V_PAT_CONTACT
-- ----------------------------
ALTER TABLE "V_PAT_CONTACT" ADD CONSTRAINT "SYS_C007425" CHECK ("PATID" IS NOT NULL) NOT DEFERRABLE INITIALLY IMMEDIATE NORELY VALIDATE;
