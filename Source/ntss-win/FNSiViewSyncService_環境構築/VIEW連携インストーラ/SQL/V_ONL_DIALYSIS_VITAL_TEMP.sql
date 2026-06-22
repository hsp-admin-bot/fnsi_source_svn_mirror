DROP TABLE V_ONL_DIALYSIS_VITAL_TEMP
;
CREATE TABLE V_ONL_DIALYSIS_VITAL_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    startdate VARCHAR2(4000),
    occurdate VARCHAR2(4000),
    bpmax VARCHAR2(4000),
    bpmin VARCHAR2(4000),
    bpave VARCHAR2(4000),
    pulse VARCHAR2(4000),
    temperature VARCHAR2(4000),
    bloodsugarlevel VARCHAR2(4000),
    "update" VARCHAR2(4000),
    dialysisno VARCHAR2(4000),
    bpclass VARCHAR2(4000),
    ordno VARCHAR2(4000),
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
            startdate CHAR(4000),
            occurdate CHAR(4000),
            bpmax CHAR(4000),
            bpmin CHAR(4000),
            bpave CHAR(4000),
            pulse CHAR(4000),
            temperature CHAR(4000),
            bloodsugarlevel CHAR(4000),
            "update" CHAR(4000),
            dialysisno CHAR(4000),
            bpclass CHAR(4000),
            ordno CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_ONL_DIALYSIS_VITAL_TEMP.csv')
);
