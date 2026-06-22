DROP TABLE V_IND_DIALYSIS_MEDI_TEMP
;
CREATE TABLE V_IND_DIALYSIS_MEDI_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    dialysisdate VARCHAR2(4000),
    plural VARCHAR2(4000),
    ctlno VARCHAR2(4000),
    "update" VARCHAR2(4000),
    medicinecd VARCHAR2(4000),
    medicinecd2 VARCHAR2(4000),
    medicinename VARCHAR2(4000),
    mediclassname VARCHAR2(4000),
    amount VARCHAR2(4000),
    unit VARCHAR2(4000),
    timingname VARCHAR2(4000),
    procedurecd VARCHAR2(4000),
    procedurecd2 VARCHAR2(4000),
    procedurename VARCHAR2(4000),
    comments CLOB,
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
            medicinecd CHAR(4000),
            medicinecd2 CHAR(4000),
            medicinename CHAR(4000),
            mediclassname CHAR(4000),
            amount CHAR(4000),
            unit CHAR(4000),
            timingname CHAR(4000),
            procedurecd CHAR(4000),
            procedurecd2 CHAR(4000),
            procedurename CHAR(4000),
            comments CHAR(40000),
            indicatorcd CHAR(4000),
            userid CHAR(4000),
            opeindplan CHAR(4000),
            dialysisno CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_IND_DIALYSIS_MEDI_TEMP.csv')
);
