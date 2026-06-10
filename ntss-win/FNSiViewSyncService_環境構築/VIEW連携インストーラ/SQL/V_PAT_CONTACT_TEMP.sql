DROP TABLE V_PAT_CONTACT_TEMP
;
CREATE TABLE V_PAT_CONTACT_TEMP (
    hosppatid VARCHAR2(4000),
    name VARCHAR2(4000),
    ctlno VARCHAR2(4000),
    "update" VARCHAR2(4000),
    regdate VARCHAR2(4000),
    relationname VARCHAR2(4000),
    rname VARCHAR2(4000),
    zipcode VARCHAR2(4000),
    address VARCHAR2(4000),
    addressdetail VARCHAR2(4000),
    telno1 VARCHAR2(4000),
    telno2 VARCHAR2(4000),
    memo CLOB,
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
            hosppatid CHAR(40000),
            name CHAR(40000),
            ctlno CHAR(40000),
            "update" CHAR(40000),
            regdate CHAR(40000),
            relationname CHAR(40000),
            rname CHAR(40000),
            zipcode CHAR(40000),
            address CHAR(40000),
            addressdetail CHAR(40000),
            telno1 CHAR(40000),
            telno2 CHAR(40000),
            memo CHAR(400000),
            isfirst CHAR(40000)
        )
    )
    LOCATION ('V_PAT_CONTACT_TEMP.csv')
);
