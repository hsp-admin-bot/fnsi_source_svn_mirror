DROP TABLE V_PAT_STATUS_TEMP
;
CREATE TABLE V_PAT_STATUS_TEMP (
  patid VARCHAR2(4000),
  hosppatid VARCHAR2(4000),
  dialysisdate VARCHAR2(4000),
  dialysistime VARCHAR2(4000),
  startplandate VARCHAR2(4000),
  enterflg VARCHAR2(4000),
  enterdate VARCHAR2(4000),
  machinecheckflg VARCHAR2(4000),
  machinecheckdate VARCHAR2(4000),
  dialsisstartflg VARCHAR2(4000),
  dialsisstartdate VARCHAR2(4000),
  offwaterflg VARCHAR2(4000),
  offwaterdate VARCHAR2(4000),
  tefluidflg VARCHAR2(4000),
  tefluiddate VARCHAR2(4000),
  weightafterflg VARCHAR2(4000),
  weightafterdate VARCHAR2(4000),
  recoverybtnflg VARCHAR2(4000),
  recoverybtndate VARCHAR2(4000),
  "update" VARCHAR2(4000),
  dialysisno VARCHAR2(4000),
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
            patid CHAR(4000),
            hosppatid CHAR(4000),
            dialysisdate CHAR(4000),
            dialysistime CHAR(4000),
            startplandate CHAR(4000),
            enterflg CHAR(4000),
            enterdate CHAR(4000),
            machinecheckflg CHAR(4000),
            machinecheckdate CHAR(4000),
            dialsisstartflg CHAR(4000),
            dialsisstartdate CHAR(4000),
            offwaterflg CHAR(4000),
            offwaterdate CHAR(4000),
            tefluidflg CHAR(4000),
            tefluiddate CHAR(4000),
            weightafterflg CHAR(4000),
            weightafterdate CHAR(4000),
            recoverybtnflg CHAR(4000),
            recoverybtndate CHAR(4000),
            "update" CHAR(4000),
            dialysisno CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_STATUS_TEMP.csv')
);
