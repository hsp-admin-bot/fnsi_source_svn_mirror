WITH del_ctl_no AS (
  SELECT
    oc.checklist_ctl_no
  FROM
    ord_checklist oc
    LEFT JOIN ord_main om ON oc.ord_no = om.ord_no
    AND om.rst_dialysis_state = '0'
    AND jsonb_extract_path_text (om.ind_cond_info, oc.rst_checklist_info ->> 'class_cd', 'value') = (oc.rst_checklist_info ->> 'code')
    AND jsonb_extract_path_text (om.ind_cond_info, oc.rst_checklist_info ->> 'class_cd', 'medicine_type') IS NOT DISTINCT FROM (oc.rst_checklist_info ->> 'medicine_type')
    AND (
      oc.rst_checklist_info ->> 'class_cd' not in ('15', '19', '25')
      OR (oc.rst_checklist_info ->> 'class_cd' = '15' AND (oc.rst_checklist_info ->> 'amount') IS NOT DISTINCT FROM jsonb_extract_path_text(om.ind_cond_info, '17', 'value'))
      OR (oc.rst_checklist_info ->> 'class_cd' = '19' AND (oc.rst_checklist_info ->> 'amount') IS NOT DISTINCT FROM jsonb_extract_path_text(om.ind_cond_info, '22', 'value'))
      OR (
        oc.rst_checklist_info ->> 'class_cd' = '25'
        AND (
          COALESCE(NULLIF(oc.rst_checklist_info ->> 'amount', ''), '0')::numeric =
            COALESCE(NULLIF(jsonb_extract_path_text(om.ind_cond_info, '26', 'value'), ''), '0')::numeric +
            COALESCE(NULLIF(jsonb_extract_path_text(om.ind_cond_info, '28', 'value'), ''), '0')::numeric
        )
      )
    )
  WHERE oc.facility_cd = /*facilityCd*/''
  AND oc.ord_no IN /*ordNoList*/(null)
  AND oc.rst_class in (0, 1, 2)
  AND oc.func_class = 1
  AND om.ord_no IS NULL
UNION ALL
SELECT
  oc.checklist_ctl_no
FROM
  ord_checklist oc
    LEFT JOIN ord_main om ON oc.ord_no = om.ord_no
WHERE
  oc.facility_cd = /*facilityCd*/''
  AND oc.ord_no IN /*ordNoList*/(null)
  AND om.rst_dialysis_state = '0'
  AND oc.rst_class in (0, 1, 2)
  AND oc.func_class = 2
  AND NOT EXISTS (
  SELECT 1
  FROM jsonb_array_elements(om.ind_equip_info) AS elem
  WHERE
    (elem ->> 'cd')::int = (oc.rst_checklist_info ->> 'code')::int
    AND elem ->> 'amount' = oc.rst_checklist_info ->> 'amount'
    AND (elem ->> 'equip_type')::int = (oc.rst_checklist_info ->> 'equip_type')::int
)
UNION ALL
SELECT
  oc.checklist_ctl_no
FROM
  ord_checklist oc
    LEFT JOIN ord_main om ON oc.ord_no = om.ord_no
WHERE
  oc.facility_cd = /*facilityCd*/''
  AND oc.ord_no IN /*ordNoList*/(null)
  AND om.rst_dialysis_state = '0'
  AND oc.rst_class in (0, 1, 2)
  AND oc.func_class = 3
  AND NOT EXISTS (
  SELECT 1
  FROM jsonb_array_elements(om.ind_medi_info) AS elem
  WHERE
    (elem ->> 'cd')::int = (oc.rst_checklist_info ->> 'code')::int
    AND elem ->> 'amount' = oc.rst_checklist_info ->> 'amount'
    AND elem ->> 'no' = oc.rst_checklist_info ->> 'medicine_no'
    AND (elem ->> 'medicine_type')::int = (oc.rst_checklist_info ->> 'medicine_type')::int
)
)
DELETE FROM ord_checklist
WHERE checklist_ctl_no IN (SELECT checklist_ctl_no FROM del_ctl_no)
RETURNING ord_checklist.*
