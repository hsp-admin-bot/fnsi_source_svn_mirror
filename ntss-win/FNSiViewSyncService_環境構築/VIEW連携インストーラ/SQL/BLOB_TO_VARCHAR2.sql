CREATE OR REPLACE FUNCTION blob_to_varchar2(blob_data IN CLOB,amount IN INT) RETURN VARCHAR2 IS
    v_varchar2_data VARCHAR2(30000);
    amt BINARY_INTEGER := 15000;
BEGIN
    DBMS_LOB.READ(blob_data, amt, 1, v_varchar2_data);
    RETURN CASE WHEN LENGTHB(v_varchar2_data) > (amount * -1) THEN SUBSTRB(v_varchar2_data, amount) ELSE v_varchar2_data END;
EXCEPTION
    WHEN OTHERS THEN
        RETURN null; -- —áŠOˆ—‚ğ’Ç‰Á‚·‚é‚±‚Æ‚ÅˆÀ‘S«‚ğ‚‚ß‚Ü‚·
END blob_to_varchar2;
/