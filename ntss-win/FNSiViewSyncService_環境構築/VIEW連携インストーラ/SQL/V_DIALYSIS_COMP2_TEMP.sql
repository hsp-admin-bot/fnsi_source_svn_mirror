DROP TABLE V_DIALYSIS_COMP2_TEMP
;
CREATE TABLE V_DIALYSIS_COMP2_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    occurdate VARCHAR2(4000),
    measureclass VARCHAR2(4000),
    reqcode VARCHAR2(4000),
    complaint VARCHAR2(4000),
    treatname VARCHAR2(4000),
    medicinecd1 VARCHAR2(4000),
    medicinecd2 VARCHAR2(4000),
    medicinename VARCHAR2(4000),
    amount VARCHAR2(4000),
    unit VARCHAR2(4000),
    procedurename VARCHAR2(4000),
    procedurecd1 VARCHAR2(4000),
    procedurecd2 VARCHAR2(4000),
    treatpersonname VARCHAR2(4000),
    "update" VARCHAR2(4000),
    ordno VARCHAR2(4000),
    compcd VARCHAR2(4000),
    treatcd VARCHAR2(4000),
    dialysisdate VARCHAR2(4000),
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
            occurdate CHAR(4000),
            measureclass CHAR(4000),
            reqcode CHAR(4000),
            complaint CHAR(4000),
            treatname CHAR(4000),
            medicinecd1 CHAR(4000),
            medicinecd2 CHAR(4000),
            medicinename CHAR(4000),
            amount CHAR(4000),
            unit CHAR(4000),
            procedurename CHAR(4000),
            procedurecd1 CHAR(4000),
            procedurecd2 CHAR(4000),
            treatpersonname CHAR(4000),
            "update" CHAR(4000),
            ordno CHAR(4000),
            compcd CHAR(4000),
            treatcd CHAR(4000),
            dialysisdate CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_DIALYSIS_COMP2_TEMP.csv')
);
