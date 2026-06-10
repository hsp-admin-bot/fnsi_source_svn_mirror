DROP TABLE V_PAT_EXAMIN_HST_TEMP
;
CREATE TABLE V_PAT_EXAMIN_HST_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    examdate VARCHAR2(4000),
    orderclass VARCHAR2(4000),
    itemupdate VARCHAR2(4000),
    examitemcode VARCHAR2(4000),
    examitemcode2 VARCHAR2(4000),
    examitemcode3 VARCHAR2(4000),
    examitemname VARCHAR2(4000),
    examrst VARCHAR2(4000),
    examclassrst VARCHAR2(4000),
    comments VARCHAR2(4000),
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
            examdate CHAR(4000),
            orderclass CHAR(4000),
            itemupdate CHAR(4000),
            examitemcode CHAR(4000),
            examitemcode2 CHAR(4000),
            examitemcode3 CHAR(4000),
            examitemname CHAR(4000),
            examrst CHAR(4000),
            examclassrst CHAR(4000),
            comments CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_EXAMIN_HST_TEMP.csv')
);
