UPDATE ord_material_save
SET 
    ind_rst_value = CASE 
                      WHEN ind_rst_value IS NOT NULL
                           AND ind_rst_value LIKE '%.%'
                           AND LENGTH(SPLIT_PART(ind_rst_value, '.', 2)) > 8 
                      THEN TO_CHAR(ROUND(ind_rst_value::numeric, 8), 'FM9999999990.00000000')
                      ELSE ind_rst_value
                  END,
    receipt_value = CASE
                WHEN receipt_value IS NOT NULL
                     AND receipt_value LIKE '%.%'
                     AND LENGTH(SPLIT_PART(receipt_value, '.', 2)) > 8
                      THEN TO_CHAR(ROUND(receipt_value::numeric, 8), 'FM9999999990.00000000')
                ELSE receipt_value
            END
WHERE 
    (ind_rst_value IS NOT NULL AND ind_rst_value LIKE '%.%' AND LENGTH(SPLIT_PART(ind_rst_value, '.', 2)) > 8)
    OR (receipt_value IS NOT NULL AND receipt_value LIKE '%.%' AND LENGTH(SPLIT_PART(receipt_value, '.', 2)) > 8);

UPDATE ord_material_save
SET receipt_conversion = jsonb_set(
             jsonb_set(
               receipt_conversion,
               '{unit_decimal_point}',
               to_jsonb(LEAST((receipt_conversion->>'unit_decimal_point')::int, 8))
             ),
             '{unit_decimal_point_second}',
             to_jsonb(LEAST((receipt_conversion->>'unit_decimal_point_second')::int, 8))
           )
WHERE 
  (receipt_conversion->>'unit_decimal_point')::int > 8
  OR (receipt_conversion->>'unit_decimal_point_second')::int > 8;

UPDATE ord_material_save
SET receipt_conversion = jsonb_set(
             jsonb_set(
               receipt_conversion,
               '{unit_converted_amount}',
               to_jsonb(
                 CASE
                   WHEN receipt_conversion->>'unit_converted_amount' LIKE '%.%'
                     AND LENGTH(SPLIT_PART(receipt_conversion->>'unit_converted_amount', '.', 2)) > 8
                   THEN ROUND((receipt_conversion->>'unit_converted_amount')::numeric, 8)
                   ELSE (receipt_conversion->>'unit_converted_amount')::numeric
                 END
               )
             ),
             '{unit_converted_amount_second}',
             to_jsonb(
               CASE
                 WHEN receipt_conversion->>'unit_converted_amount_second' LIKE '%.%'
                   AND LENGTH(SPLIT_PART(receipt_conversion->>'unit_converted_amount_second', '.', 2)) > 8
                 THEN ROUND((receipt_conversion->>'unit_converted_amount_second')::numeric, 8)
                 ELSE (receipt_conversion->>'unit_converted_amount_second')::numeric
               END
             )
           )
WHERE
  (receipt_conversion->>'unit_converted_amount' LIKE '%.%' AND LENGTH(SPLIT_PART(receipt_conversion->>'unit_converted_amount', '.', 2)) > 8)
  OR (receipt_conversion->>'unit_converted_amount_second' LIKE '%.%' AND LENGTH(SPLIT_PART(receipt_conversion->>'unit_converted_amount_second', '.', 2)) > 8);