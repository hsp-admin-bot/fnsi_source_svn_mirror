UPDATE mst_medicine
SET 
    unit_converted_amount = CASE 
		WHEN unit_converted_amount IS NOT NULL
		   AND unit_converted_amount::text LIKE '%.%'
		   AND LENGTH(SPLIT_PART(unit_converted_amount::text, '.', 2)) > 8 
		THEN ROUND(unit_converted_amount, 8)
		ELSE unit_converted_amount
		END,
    unit_converted_amount_second = CASE
		WHEN unit_converted_amount_second IS NOT NULL
			 AND unit_converted_amount_second::text LIKE '%.%'
			 AND LENGTH(SPLIT_PART(unit_converted_amount_second::text, '.', 2)) > 8
		THEN ROUND(unit_converted_amount_second, 8)
		ELSE unit_converted_amount_second
	    END,
	anticoagulant_original_quantity = CASE
		WHEN anticoagulant_original_quantity IS NOT NULL
			 AND anticoagulant_original_quantity::text LIKE '%.%'
			 AND LENGTH(SPLIT_PART(anticoagulant_original_quantity::text, '.', 2)) > 8
		THEN ROUND(anticoagulant_original_quantity, 8)
		ELSE anticoagulant_original_quantity
		END
WHERE 
    (unit_converted_amount IS NOT NULL AND unit_converted_amount::text LIKE '%.%' AND LENGTH(SPLIT_PART(unit_converted_amount::text, '.', 2)) > 8)
    OR (unit_converted_amount_second IS NOT NULL AND unit_converted_amount_second::text LIKE '%.%' AND LENGTH(SPLIT_PART(unit_converted_amount_second::text, '.', 2)) > 8)
    OR (anticoagulant_original_quantity IS NOT NULL AND anticoagulant_original_quantity::text LIKE '%.%' AND LENGTH(SPLIT_PART(anticoagulant_original_quantity::text, '.', 2)) > 8);

--指示単位小数部桁数
UPDATE mst_medicine SET unit_decimal_point = 8 WHERE unit_decimal_point IS NOT NULL AND unit_decimal_point > 8;
--レセ単位小数部桁数
UPDATE mst_medicine SET unit_decimal_point_second = 8 WHERE unit_decimal_point_second IS NOT NULL AND unit_decimal_point_second > 8;