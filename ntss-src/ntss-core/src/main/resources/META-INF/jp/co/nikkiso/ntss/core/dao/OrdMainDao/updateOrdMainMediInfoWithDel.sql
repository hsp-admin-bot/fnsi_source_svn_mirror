WITH target_cd AS (
  SELECT
    (j->>'cd')::int AS cd,
    (j->>'medicine_type')::int AS medicine_type
  FROM (SELECT /*changeMediInfo*/'{"medicine_type":1,"no":152,"cd":1309,"amount":"6","isAmountchg":false,"class_cd":1}'::jsonb AS j) t
),
base_ord AS (
  SELECT
    ord_no,
    ind_medi_info::jsonb AS ind_medi_info,
    rst_medi_info::jsonb AS rst_medi_info
  FROM ord_main
  WHERE ord_no IN /*ordNoList*/(11346453,11346454)
),
upd_data AS (
  SELECT
    bo.ord_no,
    (SELECT COALESCE(jsonb_agg(e), '[]'::jsonb)
      FROM jsonb_array_elements(bo.ind_medi_info) e
      WHERE NOT EXISTS (
        SELECT 1 FROM target_cd t
        WHERE (e->>'cd')::int = t.cd
          AND (e->>'medicine_type')::int = t.medicine_type
      )
    ) AS new_ind_medi_info,
    case when bo.rst_medi_info is null THEN NULL
      else (SELECT COALESCE(jsonb_agg(e), '[]'::jsonb)
      FROM jsonb_array_elements(bo.rst_medi_info) e
      WHERE NOT EXISTS (
      SELECT 1 FROM target_cd t
      WHERE (e->>'cd')::int = t.cd
        AND (e->>'medicine_type')::int = t.medicine_type
      )
    ) end AS new_rst_medi_info
  FROM base_ord bo
)
UPDATE ord_main om
SET
  ind_medi_info = ud.new_ind_medi_info,
  /*%if "true" == isRstUpdate*/
  rst_medi_info = ud.new_rst_medi_info,
  is_confirm = CASE WHEN rst_dialysis_state = '6' THEN '0' ELSE is_confirm END,
  /*%end*/
  up_ind_user_id = /*upIndUserId*/NULL,
  up_user_id     = /*upUserId*/NULL,
  up_date        = CURRENT_TIMESTAMP
  FROM upd_data ud
WHERE om.ord_no = ud.ord_no
  AND (
  om.ind_medi_info IS DISTINCT FROM ud.new_ind_medi_info
   OR om.rst_medi_info IS DISTINCT FROM ud.new_rst_medi_info
  )
RETURNING om.*;
