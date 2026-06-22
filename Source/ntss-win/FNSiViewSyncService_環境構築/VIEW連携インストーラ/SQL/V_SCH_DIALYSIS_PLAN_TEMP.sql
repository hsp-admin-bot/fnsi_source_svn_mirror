DROP TABLE V_SCH_DIALYSIS_PLAN_TEMP
;
CREATE TABLE V_SCH_DIALYSIS_PLAN_TEMP (
  hosppatid VARCHAR2(4000),
  patid VARCHAR2(4000),
  dialysisdate VARCHAR2(4000),
  bedno VARCHAR2(4000),
  bedname VARCHAR2(4000),
  kurcd VARCHAR2(4000),
  kurname VARCHAR2(4000),
  plural VARCHAR2(4000),
  "update" VARCHAR2(4000),
  resultdialysisno VARCHAR2(4000),
  opeindplan VARCHAR2(4000),
  dummyflg VARCHAR2(4000),
  starttime VARCHAR2(4000),
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
            bedno CHAR(4000),
            bedname CHAR(4000),
            kurcd CHAR(4000),
            kurname CHAR(4000),
            plural CHAR(4000),
            "update" CHAR(4000),
            resultdialysisno CHAR(4000),
            opeindplan CHAR(4000),
            dummyflg CHAR(4000),
            starttime CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_SCH_DIALYSIS_PLAN_TEMP.csv')
);
