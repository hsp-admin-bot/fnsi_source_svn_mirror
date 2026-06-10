DROP TABLE V_PAT_INFECT_TEMP
;
CREATE TABLE V_PAT_INFECT_TEMP (
    hosppatid VARCHAR2(4000),
    infectioncd VARCHAR2(4000),
    infectionname VARCHAR2(4000),
    "update" VARCHAR2(4000),
    infect VARCHAR2(4000),
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
            infectioncd CHAR(4000),
            infectionname CHAR(4000),
            "update" CHAR(4000),
            infect CHAR(4000),
            patid CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_INFECT_TEMP.csv')
);
