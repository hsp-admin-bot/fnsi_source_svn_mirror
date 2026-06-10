DROP TABLE V_PAT_LIFE_LIST2_TEMP
;
CREATE TABLE V_PAT_LIFE_LIST2_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    "update" VARCHAR2(4000),
    name VARCHAR2(4000),
    namekana VARCHAR2(4000),
    regdate VARCHAR2(4000),
    regtime VARCHAR2(4000),
    kindid VARCHAR2(4000),
    kindname VARCHAR2(4000),
    staffcd VARCHAR2(4000),
    staffid VARCHAR2(4000),
    staffname VARCHAR2(4000),
    editcd VARCHAR2(4000),
    editid VARCHAR2(4000),
    editname VARCHAR2(4000),
    detail1 CLOB,
    detail2 CLOB,
    detail3 CLOB,
    detail4 CLOB,
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
            "update" CHAR(4000),
            name CHAR(4000),
            namekana CHAR(4000),
            regdate CHAR(4000),
            regtime CHAR(4000),
            kindid CHAR(4000),
            kindname CHAR(4000),
            staffcd CHAR(4000),
            staffid CHAR(4000),
            staffname CHAR(4000),
            editcd CHAR(4000),
            editid CHAR(4000),
            editname CHAR(4000),
            detail1 CHAR(40000),
            detail2 CHAR(40000),
            detail3 CHAR(40000),
            detail4 CHAR(40000),
            dialysisno CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_LIFE_LIST2_TEMP.csv')
);
