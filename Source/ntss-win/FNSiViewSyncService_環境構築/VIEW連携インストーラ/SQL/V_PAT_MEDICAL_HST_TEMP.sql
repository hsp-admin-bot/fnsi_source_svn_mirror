DROP TABLE V_PAT_MEDICAL_HST_TEMP
;
CREATE TABLE V_PAT_MEDICAL_HST_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    ctlno VARCHAR2(4000),
    "update" VARCHAR2(4000),
    diseasecd VARCHAR2(4000),
    diseasename VARCHAR2(4000),
    diseasedate VARCHAR2(4000),
    recoverdate VARCHAR2(4000),
    maindisease VARCHAR2(4000),
    status VARCHAR2(4000),
    noticeflg VARCHAR2(4000),
    doctorname VARCHAR2(4000),
    userid VARCHAR2(4000),
    memo VARCHAR2(4000),
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
            "update" CHAR(4000),
            diseasecd CHAR(4000),
            diseasename CHAR(4000),
            diseasedate CHAR(4000),
            recoverdate CHAR(4000),
            maindisease CHAR(4000),
            status CHAR(4000),
            noticeflg CHAR(4000),
            doctorname CHAR(4000),
            userid CHAR(4000),
            memo CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_MEDICAL_HST_TEMP.csv')
);
