SELECT o.treat_date AS date, count(o.rst_in_out_class) AS rst_count
FROM
    ord_main AS o
WHERE
    o.treat_date >= /*startDate*/NULL AND o.treat_date <= /*endDate*/NULL
    AND o.facility_cd = /*facilityCd*/NULL AND o.is_del = '0' AND o.rst_in_out_class = /*rstInOutClass*/999999
GROUP By o.treat_date
