DROP TABLE V_RST_DIALYSIS_EQUIP_TEMP
;
CREATE TABLE V_RST_DIALYSIS_EQUIP_TEMP (
  hosppatid VARCHAR2(4000),
  patid VARCHAR2(4000),
  dialysisdate VARCHAR2(4000),
  dialysisno VARCHAR2(4000),
  ctlno VARCHAR2(4000),
  "update" VARCHAR2(4000),
  equipcd VARCHAR2(4000),
  equipcd2 VARCHAR2(4000),
  equipname VARCHAR2(4000),
  equipclassname VARCHAR2(4000),
  punctureclass VARCHAR2(4000),
  amount VARCHAR2(4000),
  unit VARCHAR2(4000),
  comments CLOB,
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
            equipcd CHAR(4000),
            equipcd2 CHAR(4000),
            equipname CHAR(4000),
            equipclassname CHAR(4000),
            punctureclass CHAR(4000),
            amount CHAR(4000),
            unit CHAR(4000),
            comments CHAR(40000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_RST_DIALYSIS_EQUIP_TEMP.csv')
);
