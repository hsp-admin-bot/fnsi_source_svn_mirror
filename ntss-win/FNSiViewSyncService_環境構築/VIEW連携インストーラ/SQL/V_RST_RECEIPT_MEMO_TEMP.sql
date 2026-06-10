DROP TABLE V_RST_RECEIPT_MEMO_TEMP
;
CREATE TABLE V_RST_RECEIPT_MEMO_TEMP (
  hosppatid VARCHAR2(4000),
  patid VARCHAR2(4000),
  dialysisdate VARCHAR2(4000),
  dialysisno VARCHAR2(4000),
  ctlno VARCHAR2(4000),
  "update" VARCHAR2(4000),
  division VARCHAR2(4000),
  code VARCHAR2(4000),
  codeupdate VARCHAR2(4000),
  addflg VARCHAR2(4000),
  itemname VARCHAR2(4000),
  maindialdiff VARCHAR2(4000),
  inhospitalcd VARCHAR2(4000),
  inhospitalcd2 VARCHAR2(4000),
  isfirst VARCHAR2(4000)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
   DEFAULT DIRECTORY EX_TABLE
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY '>ÅJj^q-(\r\n'
        SKIP 1
        NOLOGFILE
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        (
            hosppatid CHAR(4000),
            patid CHAR(4000),
            dialysisdate CHAR(4000),
            dialysisno CHAR(4000),
            ctlno CHAR(4000),
            "update" CHAR(4000),
            division CHAR(4000),
            code CHAR(4000),
            codeupdate CHAR(4000),
            addflg CHAR(4000),
            itemname CHAR(4000),
            maindialdiff CHAR(4000),
            inhospitalcd CHAR(4000),
            inhospitalcd2 CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_RST_RECEIPT_MEMO_TEMP.csv')
);
