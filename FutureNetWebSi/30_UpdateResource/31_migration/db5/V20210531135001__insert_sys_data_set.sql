INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11045, 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd
 ),
ord1 AS (
		SELECT COUNT
			( * ) as ord1
		FROM
			ord_main 
		WHERE
			to_number( ind_cond_info -> ''25'' ->> ''value'', ''9999999999999999999'' ) = @id
			AND treat_date BETWEEN @dateFrom
 
			AND @dateTo
 
			AND is_del = ''0'' 
			AND facility_cd = @facilityCd
),
ord2 AS (
		SELECT COUNT
			( * ) as ord2
		FROM
			ord_main
			CROSS JOIN LATERAL json_array_elements ( ind_medi_info :: json ) mediInfo 
		WHERE
			to_number( mediInfo ->> ''cd'', ''9999999999999999999'' ) = @id
			AND treat_date BETWEEN @dateFrom
 
			AND @dateTo
 
			AND is_del = ''0'' 
			AND facility_cd = @facilityCd

) 


SELECT COALESCE
	(
	case when exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 then
				round(((ord1.ord1 + ord2.ord2) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1)
when exchange.is_exchange = ''1'' 
					AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
					AND exchange.unit_converted_amount_second != 0 then
						CEILING ((ord1.ord1 + ord2.ord2) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second
when exchange.is_exchange = ''2'' 
							AND exchange.unit_converted_amount_second  is NOT NULL then
								exchange.unit_converted_amount_second 
ELSE 0 END
,0) as count
from
exchange,
ord1,
ord2
', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11044, 'select unit_second as unit from mst_medicine where medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-11043, 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd ),
ord1 AS (
	SELECT COUNT
		( * ) AS ord1 
	FROM
		ord_main 
	WHERE
		to_number( rst_cond_info -> ''25'' ->> ''value'', ''9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd 
	),
	ord2 AS (
	SELECT COUNT
		( * ) AS ord2 
	FROM
		ord_main
		CROSS JOIN LATERAL json_array_elements ( rst_medi_info :: json ) mediInfo 
	WHERE
		to_number( mediInfo ->> ''cd'', ''9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd 
	),
	ord3 AS (
	SELECT COUNT
		( * ) AS ord3 
	FROM
		ord_main
		CROSS JOIN LATERAL json_array_elements ( rst_treatment_info :: json ) mediInfo 
	WHERE
		to_number( mediInfo ->> ''treat_medicine_cd'', ''9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd 
	)
SELECT COALESCE
	(
	CASE
			
			WHEN exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 THEN
				round( ( ( ord1.ord1 + ord2.ord2 + ord3.ord3 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1 ) 
				WHEN exchange.is_exchange = ''1'' 
				AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
				AND exchange.unit_converted_amount_second != 0 THEN
					CEILING ( ( ord1.ord1 + ord2.ord2 + ord3.ord3 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second 
					WHEN exchange.is_exchange = ''2'' 
					AND exchange.unit_converted_amount_second IS NOT NULL THEN
						exchange.unit_converted_amount_second ELSE 0 
						END,
					0 
				) AS COUNT 
			FROM
				exchange,
				ord1,
			ord2,
	ord3', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2020-07-31 18:29:49', '2020-07-31 18:29:49', NULL);
