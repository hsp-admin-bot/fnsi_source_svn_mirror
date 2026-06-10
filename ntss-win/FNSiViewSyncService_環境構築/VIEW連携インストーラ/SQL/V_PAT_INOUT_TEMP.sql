DROP TABLE V_PAT_INOUT_TEMP
;
CREATE TABLE V_PAT_INOUT_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    ctlno VARCHAR2(4000),
    regdate VARCHAR2(4000),
    inoutcd VARCHAR2(4000),
    facilityname VARCHAR2(4000),
    userid VARCHAR2(4000),
    drname VARCHAR2(4000),
    memo VARCHAR2(4000),
    codename VARCHAR2(4000),
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
            ctlno CHAR(4000),
            regdate CHAR(4000),
            inoutcd CHAR(4000),
            facilityname CHAR(4000),
            userid CHAR(4000),
            drname CHAR(4000),
            memo CHAR(4000),
            codename CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_INOUT_TEMP.csv')
);
