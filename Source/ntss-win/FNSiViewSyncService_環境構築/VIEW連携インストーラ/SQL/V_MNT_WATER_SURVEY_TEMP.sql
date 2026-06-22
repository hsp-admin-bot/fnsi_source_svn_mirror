DROP TABLE V_MNT_WATER_SURVEY_TEMP
;
CREATE TABLE V_MNT_WATER_SURVEY_TEMP (
    surveypointcd VARCHAR2(4000),
    surveypointname VARCHAR2(4000),
    "update" VARCHAR2(4000),
    checkdate VARCHAR2(4000),
    result VARCHAR2(4000),
    unit VARCHAR2(4000),
    detail CLOB,
    surveyno VARCHAR2(4000),
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
            surveypointcd CHAR(4000),
            surveypointname CHAR(4000),
            "update" CHAR(4000),
            checkdate CHAR(4000),
            result CHAR(4000),
            unit CHAR(4000),
            detail CHAR(40000),
            surveyno CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_MNT_WATER_SURVEY_TEMP.csv')
);
