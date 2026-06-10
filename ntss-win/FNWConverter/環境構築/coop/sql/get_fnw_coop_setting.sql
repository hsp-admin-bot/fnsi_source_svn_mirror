SET COLSEP ','
SET PAGESIZE 0
SET LINESIZE 1000
SET FEEDBACK OFF
SET TRIMSPOOL ON
SET TRIMOUT ON
SPOOL sys_coop_no.csv

SELECT DISTINCT
    TRIM(mci.COOP_FUNCTION_ID) || ',' ||
    TRIM(mcfi.COOP_FUNCTION_NAME) || ',' ||
    TRIM(mci.IS_COOP_FLG) || ',' ||
    TRIM(mci.ORDER_NUMBER_MANAGE_ID)  || ',' ||
    TRIM(mci.SEND_LIMIT) || ',' ||
    TRIM(conm.ORDER_NUMBER)  || ',' ||
    TRIM(moni.ORDER_NUMBER_MIN) || ',' ||
    TRIM(moni.ORDER_NUMBER_MAX)  || ',' ||
    TO_CHAR(LENGTH(TRIM(moni.ORDER_NUMBER_MAX)))
FROM
    mst_coop_id mci 
    JOIN cop_order_number_manage conm ON mci.ORDER_NUMBER_MANAGE_ID = conm.ORDER_NUMBER_MANAGE_ID
    JOIN mst_order_number_id moni ON conm.ORDER_NUMBER_MANAGE_ID = moni.ORDER_NUMBER_MANAGE_ID
    JOIN mst_coop_function_id mcfi ON mcfi.COOP_FUNCTION_ID = mci.COOP_FUNCTION_ID
WHERE
    mci.IS_COOP_FLG = 1;

SPOOL OFF

EXIT;
