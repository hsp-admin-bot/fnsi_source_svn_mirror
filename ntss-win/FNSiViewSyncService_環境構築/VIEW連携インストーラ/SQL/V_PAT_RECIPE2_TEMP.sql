DROP TABLE V_PAT_RECIPE2_TEMP
;
CREATE TABLE V_PAT_RECIPE2_TEMP (
    hosppatid VARCHAR2(4000),
    patid VARCHAR2(4000),
    prescriptno VARCHAR2(4000),
    "update" VARCHAR2(4000),
    executedate VARCHAR2(4000),
    ctlno VARCHAR2(4000),
    medicinename VARCHAR2(4000),
    medicinecd VARCHAR2(4000),
    medicinecd2 VARCHAR2(4000),
    quantity VARCHAR2(4000),
    unit VARCHAR2(4000),
    dosage VARCHAR2(4000),
    takemedicinecd VARCHAR2(4000),
    takemedicinename VARCHAR2(4000),
    daycount VARCHAR2(4000),
    prescriptercd VARCHAR2(4000),
    prescriptername VARCHAR2(4000),
    note CLOB,
    userid VARCHAR2(4000),
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
            prescriptno CHAR(4000),
            "update" CHAR(4000),
            executedate CHAR(4000),
            ctlno CHAR(4000),
            medicinename CHAR(4000),
            medicinecd CHAR(4000),
            medicinecd2 CHAR(4000),
            quantity CHAR(4000),
            unit CHAR(4000),
            dosage CHAR(4000),
            takemedicinecd CHAR(4000),
            takemedicinename CHAR(4000),
            daycount CHAR(4000),
            prescriptercd CHAR(4000),
            prescriptername CHAR(4000),
            note CHAR(40000),
            userid CHAR(4000),
            isfirst CHAR(4000)
        )
    )
    LOCATION ('V_PAT_RECIPE2_TEMP.csv')
);
