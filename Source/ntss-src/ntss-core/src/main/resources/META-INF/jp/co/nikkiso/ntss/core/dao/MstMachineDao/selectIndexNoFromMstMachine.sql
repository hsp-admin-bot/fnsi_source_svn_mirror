-- mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
SELECT
  dmc.code_order
FROM
  mst_machine AS mc
    LEFT JOIN (
    SELECT
      index_no AS code_order,
      TO_NUMBER( order_cd ->> 'code', '999999999999' ) AS medi_class_code,
      order_cd ->> 'name' AS medi_class_code_name
    FROM
      mst_selector
      CROSS JOIN LATERAL jsonb_array_elements ( order_settings -> 'items' ) WITH ORDINALITY AS tmp ( order_cd, index_no )
    WHERE
      facility_cd = /*facilityCd*/''
      AND master_physical_name = 'mst_machine'
  ) AS dmc ON dmc.medi_class_code = mc.machine_no
WHERE
    mc.facility_cd = /*facilityCd*/''
  AND mc.machine_type_cd = /*machineTypeCd*/''
  AND mc.machine_serial = /*machineSerial*/''
-- mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
