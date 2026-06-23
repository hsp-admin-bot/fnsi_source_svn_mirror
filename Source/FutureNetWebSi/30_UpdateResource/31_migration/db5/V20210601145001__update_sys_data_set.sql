UPDATE "ntss"."sys_data_set" SET "sql" = 'WITH exchange AS ( SELECT unit_converted_amount, unit_converted_amount_second, is_exchange FROM mst_medicine WHERE medicine_cd = @id AND is_del = ''0'' AND facility_cd = @facilityCd ),
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
	SELECT 
	case
    when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) 
    else 0
  end AS ord2 
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
	SELECT 
	case
    when sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) is not null then sum(to_number( mediInfo ->> ''amount'', ''9999999999999999999'' )) 
    else 0
  end AS ord3
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
	ord3' WHERE "sql_cd" = -11043;