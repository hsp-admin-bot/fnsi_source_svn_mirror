update ntss.sys_data_set set sql = 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd
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
			AND facility_cd = @facilityCd and pat_id is not null
),
ord2 AS (
		SELECT SUM
		( to_number( mediInfo ->> ''amount'', ''9999999999999999999'' ) ) as ord2
		FROM
			ord_main
			CROSS JOIN LATERAL json_array_elements ( ind_medi_info :: json ) mediInfo 
		WHERE
			to_number( mediInfo ->> ''cd'', ''9999999999999999999'' ) = @id
			AND treat_date BETWEEN @dateFrom
 
			AND @dateTo
 
			AND is_del = ''0'' 
			AND facility_cd = @facilityCd and pat_id is not null

) 


SELECT COALESCE (
(SELECT COALESCE
	(
	case when exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 then
				round(((ord1.ord1) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1)
when exchange.is_exchange = ''1'' 
					AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
					AND exchange.unit_converted_amount_second != 0 then
						CEILING ((ord1.ord1) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second
when exchange.is_exchange = ''2'' 
							AND exchange.unit_converted_amount_second  is NOT NULL then
								exchange.unit_converted_amount_second 
ELSE 0 END
, 0) as count
from
exchange,
ord1,
ord2) +
(SELECT COALESCE
	(
	case when exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 then
				round(((ord2.ord2) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1)
when exchange.is_exchange = ''1'' 
					AND ( exchange.unit_converted_amount_second is NOT NULL OR exchange.unit_converted_amount is NOT NULL ) 
					AND exchange.unit_converted_amount_second != 0 then
						CEILING ((ord2.ord2) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second
when exchange.is_exchange = ''2'' 
							AND exchange.unit_converted_amount_second  is NOT NULL then
								exchange.unit_converted_amount_second 
ELSE 0 END
, 0) as count
from
exchange,
ord1,
ord2)
, 0) as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11045;
update ntss.sys_data_set set sql = 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd ),
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
		AND facility_cd = @facilityCd  and pat_id is not null
	),
	ord2 AS (
	SELECT SUM
		( to_number( mediInfo ->> ''amount'', ''9999999999999999999'' ) ) AS ord2 
	FROM
		ord_main
		CROSS JOIN LATERAL json_array_elements ( rst_medi_info :: json ) mediInfo 
	WHERE
		to_number( mediInfo ->> ''cd'', ''9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd  and pat_id is not null
	),
	ord3 AS (
	SELECT SUM
		( to_number( mediInfo ->> ''amount'', ''9999999999999999999'' ) ) AS ord3 
	FROM
		ord_main
		CROSS JOIN LATERAL json_array_elements ( rst_treatment_info :: json ) mediInfo 
	WHERE
		to_number( mediInfo ->> ''treat_medicine_cd'', ''9999999999999999999'' ) =  @id 
		AND treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
		AND facility_cd = @facilityCd  and pat_id is not null
	)

 select
  COALESCE(
(SELECT COALESCE
	(
	CASE
			
			WHEN exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 THEN
				round( ( ( ord3.ord3 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1 ) 
				WHEN exchange.is_exchange = ''1'' 
				AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
				AND exchange.unit_converted_amount_second != 0 THEN
					CEILING ( ( ord3.ord3 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second 
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
	            ord3) +
(SELECT COALESCE
	(
	CASE
			
			WHEN exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 THEN
				round( ( ( ord1.ord1 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1 ) 
				WHEN exchange.is_exchange = ''1'' 
				AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
				AND exchange.unit_converted_amount_second != 0 THEN
					CEILING ( ( ord1.ord1 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second 
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
	            ord3) +
(SELECT COALESCE
	(
	CASE
			
			WHEN exchange.is_exchange = ''0'' 
			AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
			AND exchange.unit_converted_amount_second != 0 THEN
				round( ( ( ord2.ord2 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second, 1 ) 
				WHEN exchange.is_exchange = ''1'' 
				AND ( exchange.unit_converted_amount_second IS NOT NULL OR exchange.unit_converted_amount IS NOT NULL ) 
				AND exchange.unit_converted_amount_second != 0 THEN
					CEILING ( ( ord2.ord2 ) / exchange.unit_converted_amount ) * exchange.unit_converted_amount_second 
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
	            ord3), 0) 
as count', db_class = 2, detail = '[]', can_repeat = '0', use_application = '{"applications": []}', report_class = '{"classes": []}', memo = 'データリスト', reg_date = '2020/07/31 18:29:49', up_date = '2020/07/31 18:29:49', pre_sql_info = null where sql_cd = -11043;
