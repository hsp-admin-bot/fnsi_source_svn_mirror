DROP TABLE V_LOG_DEV_MENTE2_TEMP
;
CREATE TABLE V_LOG_DEV_MENTE2_TEMP (
    deviceno VARCHAR2(4000),
    devicename VARCHAR2(4000),
    deviceserial VARCHAR2(4000),
    meintedate VARCHAR2(4000),
    meintetime VARCHAR2(4000),
    meinteresult VARCHAR2(4000),
    meintegen VARCHAR2(4000),
    meintemore VARCHAR2(4000),
    meinteymore VARCHAR2(4000),
    meintejyo VARCHAR2(4000),
    meintebara VARCHAR2(4000),
    meinteetcf VARCHAR2(4000),
    meinteetcf2 VARCHAR2(4000),
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
            deviceno CHAR(4000),
            devicename CHAR(4000),
            deviceserial CHAR(4000),
            meintedate CHAR(4000),
            meintetime CHAR(4000),
            meinteresult CHAR(4000),
            meintegen CHAR(4000),
            meintemore CHAR(4000),
            meinteymore CHAR(4000),
            meintejyo CHAR(4000),
            meintebara CHAR(4000),
            meinteetcf CHAR(4000),
            meinteetcf2 CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_LOG_DEV_MENTE2_TEMP.csv')
);
