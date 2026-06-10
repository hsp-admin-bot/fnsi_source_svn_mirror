DROP TABLE V_PAT_TABOO_TEMP
;
CREATE TABLE V_PAT_TABOO_TEMP (
  hosppatid VARCHAR2(4000),
  name VARCHAR2(4000),
  ctlno VARCHAR2(4000),
  "update" VARCHAR2(4000),
  taboo CLOB,
  memo CLOB,
  patid VARCHAR2(4000),
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
            name CHAR(4000),
            ctlno CHAR(4000),
            "update" CHAR(4000),
            taboo CHAR(40000),
            memo CHAR(40000),
            patid CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_TABOO_TEMP.csv')
);
