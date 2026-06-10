SELECT
    ord_no
FROM
    ord_schedule
WHERE facility_cd = /*facilityCd*/'' AND
        ord_no IN /* ordNo */();
