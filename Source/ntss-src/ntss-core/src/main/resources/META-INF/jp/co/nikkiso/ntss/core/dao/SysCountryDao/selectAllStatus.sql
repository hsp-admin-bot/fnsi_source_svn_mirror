SELECT
  country_cd_alpha3 AS "countryCdAlpha3",
  country_name AS "countryName",
  '' AS "deleted"
FROM sys_country
WHERE 1 = 1
  /*%if params.get("___noop") != null */
  AND 1 = 0
  /*%end*/
ORDER BY country_name
