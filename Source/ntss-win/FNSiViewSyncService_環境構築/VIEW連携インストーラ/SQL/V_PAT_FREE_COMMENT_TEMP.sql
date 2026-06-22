DROP TABLE V_PAT_FREE_COMMENT_TEMP
;
CREATE TABLE V_PAT_FREE_COMMENT_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    ctlno VARCHAR2(4000),
    title VARCHAR2(4000),
    content CLOB,
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
            title CHAR(4000),
            content CHAR(40000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_FREE_COMMENT_TEMP.csv')
);
