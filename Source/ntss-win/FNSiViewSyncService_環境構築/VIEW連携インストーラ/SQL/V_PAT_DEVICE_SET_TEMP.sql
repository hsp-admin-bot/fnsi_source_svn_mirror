DROP TABLE V_PAT_DEVICE_SET_TEMP
;
CREATE TABLE V_PAT_DEVICE_SET_TEMP (
    patid VARCHAR2(4000),
    hosppatid VARCHAR2(4000),
    name VARCHAR2(4000),
    ctlno VARCHAR2(4000),
    setname VARCHAR2(4000),
    value VARCHAR2(4000),
    "update" VARCHAR2(4000),
    monvalue VARCHAR2(4000),
    monupdate VARCHAR2(4000),
    tuevalue VARCHAR2(4000),
    tueupdate VARCHAR2(4000),
    wedvalue VARCHAR2(4000),
    wedupdate VARCHAR2(4000),
    thuvalue VARCHAR2(4000),
    thuupdate VARCHAR2(4000),
    frivalue VARCHAR2(4000),
    friupdate VARCHAR2(4000),
    satvalue VARCHAR2(4000),
    satupdate VARCHAR2(4000),
    sunvalue VARCHAR2(4000),
    sunupdate VARCHAR2(4000),
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
            patid CHAR(4000),
            hosppatid CHAR(4000),
            name CHAR(4000),
            ctlno CHAR(4000),
            setname CHAR(4000),
            value CHAR(4000),
            "update" CHAR(4000),
            monvalue CHAR(4000),
            monupdate CHAR(4000),
            tuevalue CHAR(4000),
            tueupdate CHAR(4000),
            wedvalue CHAR(4000),
            wedupdate CHAR(4000),
            thuvalue CHAR(4000),
            thuupdate CHAR(4000),
            frivalue CHAR(4000),
            friupdate CHAR(4000),
            satvalue CHAR(4000),
            satupdate CHAR(4000),
            sunvalue CHAR(4000),
            sunupdate CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_DEVICE_SET_TEMP.csv')
);
