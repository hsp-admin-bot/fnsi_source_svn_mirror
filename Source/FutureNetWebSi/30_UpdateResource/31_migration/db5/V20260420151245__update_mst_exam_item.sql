UPDATE mst_exam_item
SET 
    normal_value_upper = CASE 
        WHEN normal_value_upper IS NOT NULL
             AND normal_value_upper LIKE '%.%'
             AND LENGTH(SPLIT_PART(normal_value_upper, '.', 2)) > 8
        THEN TO_CHAR(ROUND(normal_value_upper::numeric, 8), 'FM9999999990.00000000')
        ELSE normal_value_upper
		END,
    normal_value_lower = CASE
		WHEN normal_value_lower IS NOT NULL
			 AND normal_value_lower LIKE '%.%'
			 AND LENGTH(SPLIT_PART(normal_value_lower, '.', 2)) > 8
        THEN TO_CHAR(ROUND(normal_value_lower::numeric, 8), 'FM9999999990.00000000')
		ELSE normal_value_lower
	    END,
	normal_value_upper_m = CASE
		WHEN normal_value_upper_m IS NOT NULL
			 AND normal_value_upper_m LIKE '%.%'
			 AND LENGTH(SPLIT_PART(normal_value_upper_m, '.', 2)) > 8
        THEN TO_CHAR(ROUND(normal_value_upper_m::numeric, 8), 'FM9999999990.00000000')
		ELSE normal_value_upper_m
		END,
	normal_value_lower_m = CASE
		WHEN normal_value_lower_m IS NOT NULL
			 AND normal_value_lower_m LIKE '%.%'
			 AND LENGTH(SPLIT_PART(normal_value_lower_m, '.', 2)) > 8
        THEN TO_CHAR(ROUND(normal_value_lower_m::numeric, 8), 'FM9999999990.00000000')
		ELSE normal_value_lower_m
		END,
	normal_value_upper_w = CASE
		WHEN normal_value_upper_w IS NOT NULL
			 AND normal_value_upper_w LIKE '%.%'
			 AND LENGTH(SPLIT_PART(normal_value_upper_w, '.', 2)) > 8
        THEN TO_CHAR(ROUND(normal_value_upper_w::numeric, 8), 'FM9999999990.00000000')
		ELSE normal_value_upper_w
		END,
	normal_value_lower_w = CASE
		WHEN normal_value_lower_w IS NOT NULL
			 AND normal_value_lower_w LIKE '%.%'
			 AND LENGTH(SPLIT_PART(normal_value_lower_w, '.', 2)) > 8
        THEN TO_CHAR(ROUND(normal_value_lower_w::numeric, 8), 'FM9999999990.00000000')
		ELSE normal_value_lower_w
		END,
	input_upper = CASE
		WHEN input_upper IS NOT NULL
			 AND input_upper LIKE '%.%'
			 AND LENGTH(SPLIT_PART(input_upper, '.', 2)) > 8
        THEN TO_CHAR(ROUND(input_upper::numeric, 8), 'FM9999999990.00000000')
		ELSE input_upper
		END,
	input_lower = CASE
		WHEN input_lower IS NOT NULL
			 AND input_lower LIKE '%.%'
			 AND LENGTH(SPLIT_PART(input_lower, '.', 2)) > 8
        THEN TO_CHAR(ROUND(input_lower::numeric, 8), 'FM9999999990.00000000')
		ELSE input_lower
		END,
	graph_upper = CASE
		WHEN graph_upper IS NOT NULL
			 AND graph_upper LIKE '%.%'
			 AND LENGTH(SPLIT_PART(graph_upper, '.', 2)) > 8
        THEN TO_CHAR(ROUND(graph_upper::numeric, 8), 'FM9999999990.00000000')
		ELSE graph_upper
		END,
	graph_lower = CASE
		   WHEN graph_lower IS NOT NULL
				AND graph_lower LIKE '%.%'
				AND LENGTH(SPLIT_PART(graph_lower, '.', 2)) > 8
        THEN TO_CHAR(ROUND(graph_lower::numeric, 8), 'FM9999999990.00000000')
		   ELSE graph_lower
	   END
WHERE 
    (normal_value_upper IS NOT NULL AND normal_value_upper LIKE '%.%' AND LENGTH(SPLIT_PART(normal_value_upper, '.', 2)) > 8)
    OR (normal_value_lower IS NOT NULL AND normal_value_lower LIKE '%.%' AND LENGTH(SPLIT_PART(normal_value_lower, '.', 2)) > 8)
    OR (normal_value_upper_m IS NOT NULL AND normal_value_upper_m LIKE '%.%' AND LENGTH(SPLIT_PART(normal_value_upper_m, '.', 2)) > 8)
    OR (normal_value_lower_m IS NOT NULL AND normal_value_lower_m LIKE '%.%' AND LENGTH(SPLIT_PART(normal_value_lower_m, '.', 2)) > 8)
    OR (normal_value_upper_w IS NOT NULL AND normal_value_upper_w LIKE '%.%' AND LENGTH(SPLIT_PART(normal_value_upper_w, '.', 2)) > 8)
    OR (normal_value_lower_w IS NOT NULL AND normal_value_lower_w LIKE '%.%' AND LENGTH(SPLIT_PART(normal_value_lower_w, '.', 2)) > 8)
    OR (input_upper IS NOT NULL AND input_upper LIKE '%.%' AND LENGTH(SPLIT_PART(input_upper, '.', 2)) > 8)
    OR (input_lower IS NOT NULL AND input_lower LIKE '%.%' AND LENGTH(SPLIT_PART(input_lower, '.', 2)) > 8)
    OR (graph_upper IS NOT NULL AND graph_upper LIKE '%.%' AND LENGTH(SPLIT_PART(graph_upper, '.', 2)) > 8)
    OR (graph_lower IS NOT NULL AND graph_lower LIKE '%.%' AND LENGTH(SPLIT_PART(graph_lower, '.', 2)) > 8);

UPDATE mst_exam_item SET input_decimal_figure = 8 WHERE input_decimal_figure IS NOT NULL AND input_decimal_figure > 8;