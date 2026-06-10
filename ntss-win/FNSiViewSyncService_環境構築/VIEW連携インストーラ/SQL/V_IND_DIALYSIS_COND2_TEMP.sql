DROP TABLE V_IND_DIALYSIS_COND2_TEMP
;
CREATE TABLE V_IND_DIALYSIS_COND2_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    dialysisdate VARCHAR2(4000),
    plural VARCHAR2(4000),
    ctlno VARCHAR2(4000),
    "update" VARCHAR2(4000),
    dialysisitemname VARCHAR2(4000),
    value VARCHAR2(4000),
    valuename VARCHAR2(4000),
    unit VARCHAR2(4000),
    valuecd2 VARCHAR2(4000),
    indicatorcd VARCHAR2(4000),
    userid VARCHAR2(4000),
    opeindplan VARCHAR2(4000),
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
            hosppatid CHAR(4000),
            patid CHAR(4000),
            dialysisdate CHAR(4000),
            plural CHAR(4000),
            ctlno CHAR(4000),
            "update" CHAR(4000),
            dialysisitemname CHAR(4000),
            value CHAR(4000),
            valuename CHAR(4000),
            unit CHAR(4000),
            valuecd2 CHAR(4000),
            indicatorcd CHAR(4000),
            userid CHAR(4000),
            opeindplan CHAR(4000),
            dialysisno CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_IND_DIALYSIS_COND2_TEMP.csv')
);
