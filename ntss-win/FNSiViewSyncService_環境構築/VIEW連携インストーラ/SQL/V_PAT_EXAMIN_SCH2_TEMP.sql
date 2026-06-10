DROP TABLE V_PAT_EXAMIN_SCH2_TEMP
;
CREATE TABLE V_PAT_EXAMIN_SCH2_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    "update" VARCHAR2(4000),
    examdate VARCHAR2(4000),
    examtime VARCHAR2(4000),
    examsetcd VARCHAR2(4000),
    examsetname VARCHAR2(4000),
    examdivision VARCHAR2(4000),
    examproccd VARCHAR2(4000),
    userid VARCHAR2(4000),
    doctorcode VARCHAR2(4000),
    doctorname VARCHAR2(4000),
    regstaff VARCHAR2(4000),
    orderstaff VARCHAR2(4000),
    ordername VARCHAR2(4000),
    upstaff VARCHAR2(4000),
    updatecode VARCHAR2(4000),
    updatename VARCHAR2(4000),
    examno VARCHAR2(4000),
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
            "update" CHAR(4000),
            examdate CHAR(4000),
            examtime CHAR(4000),
            examsetcd CHAR(4000),
            examsetname CHAR(4000),
            examdivision CHAR(4000),
            examproccd CHAR(4000),
            userid CHAR(4000),
            doctorcode CHAR(4000),
            doctorname CHAR(4000),
            regstaff CHAR(4000),
            orderstaff CHAR(4000),
            ordername CHAR(4000),
            upstaff CHAR(4000),
            updatecode CHAR(4000),
            updatename CHAR(4000),
            examno CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_EXAMIN_SCH2_TEMP.csv')
);
