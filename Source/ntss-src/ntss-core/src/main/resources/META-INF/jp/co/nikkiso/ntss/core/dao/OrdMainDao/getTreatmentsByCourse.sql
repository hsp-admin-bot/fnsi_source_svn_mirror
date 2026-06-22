SELECT
    CAST(coalesce(nullif(ind.ind_kur_cd, NULL), rst.rst_kur_cd) AS bigint) AS kur_cd,
    CAST(coalesce(nullif(ind.ind_kur_name, NULL), rst.rst_kur_name) AS character varying) AS kur_name,
    CAST(coalesce(nullif(ind.treat_date, NULL), rst.treat_date) AS character varying) AS treat_date,
    coalesce(nullif(rst.rst_count, NULL), 0) AS rst_kur_count,
    coalesce(nullif(ind.ind_count, NULL), 0)  AS ind_kur_count
FROM (
		SELECT o.ind_kur_cd, k.kur_name as ind_kur_name, o.treat_date, count(o.ind_kur_cd) AS ind_count
    FROM
        ord_main AS o, mst_kur AS k
    WHERE coalesce(nullif(o.ind_kur_cd, NULL), 0) != 0 AND
        o.treat_date >= /*startDate*/NULL AND o.treat_date <= /*endDate*/NUll
        AND o.facility_cd = /*facilityCd*/NULL AND o.is_del = '0' AND o.ind_kur_cd = k.kur_cd AND k.facility_cd = /*facilityCd*/NULL AND k.is_del = '0'
    GROUP BY o.ind_kur_cd, o.treat_date, k.kur_name) AS ind
    FULL JOIN (
		SELECT o.rst_kur_cd, k.kur_name as rst_kur_name, o.treat_date, count(o.rst_kur_cd) AS rst_count
    FROM
        ord_main AS o, mst_kur AS k
    WHERE coalesce(nullif(o.rst_kur_cd, NULL), 0) != 0 AND
        o.treat_date >= /*startDate*/NULL AND o.treat_date <= /*endDate*/NUll
        AND o.facility_cd = /*facilityCd*/NULL AND o.is_del = '0' AND o.rst_kur_cd = k.kur_cd AND k.facility_cd = /*facilityCd*/NULL AND k.is_del = '0'
    GROUP BY o.rst_kur_cd, o.treat_date, k.kur_name
	) AS rst
    on ind.ind_kur_cd = rst.rst_kur_cd AND ind.treat_date = rst.treat_date


    