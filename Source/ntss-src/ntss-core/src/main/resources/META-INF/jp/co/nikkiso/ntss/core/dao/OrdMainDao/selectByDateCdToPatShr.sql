with shr_pat as (
  SELECT
    from_facility_cd,
    from_pat_id
  FROM
    shr_pat_info
  WHERE
    to_facility_cd = /*facility_cd*/''
    AND to_pat_id = /*pat_id*/0
    AND is_from_consent = '1'
    AND is_to_consent = '1'
    AND is_pat_consent = '1'
    AND is_disp = '1'
    AND is_del = '0'
)
select
  B.ord_no
  ,B.pat_id
  ,B.facility_cd
  ,B.treat_date
  ,medi_info.medi_info as ind_medi_info
  ,B.rst_medi_info
  ,B.rst_dialysis_state
from
  ord_main B
  INNER JOIN shr_pat s ON s.from_facility_cd = B.facility_cd AND s.from_pat_id = B.pat_id
  LEFT JOIN LATERAL (
        SELECT jsonb_agg(
            jsonb_set(
                  jsonb_set(
                    jsonb_set(
                        jsonb_set(
                            elem,
                            '{unit}',
                            to_jsonb(
                                COALESCE(m3.unit,m4.unit,'')
                            )
                        ),
                        '{name}',
                        to_jsonb(
                            COALESCE(m3.medicine_name,m4.medicine_mix_name,'')
                        )
                    ),
                    '{class_name}',
                    to_jsonb(
                          COALESCE(c3.class_name,c4.class_name,'')
                      )
                ),
                '{decPoint}',
                to_jsonb(
                    COALESCE(m3.unit_decimal_point,m4.unit_decimal_point, 0)
                )
            )
        ) AS medi_info
        FROM jsonb_array_elements(B.ind_medi_info) elem
        LEFT JOIN mst_medicine m3
          ON (elem->>'medicine_type')::int = 1
         AND m3.medicine_cd = (elem->>'cd')::int
        LEFT join mst_medicine_class c3
          on m3.class_cd = c3.class_cd

        LEFT JOIN mst_medicine_mix m4
          ON (elem->>'medicine_type')::int = 2
         AND m4.medicine_mix_cd = (elem->>'cd')::int
        LEFT join mst_medicine_class c4
          on m4.class_cd = c4.class_cd

   ) medi_info ON TRUE
 where
  B.treat_date >= /*dialysis_date_from*/'20260301'
 and
  B.treat_date <= /*dialysis_date_to*/'20260330'
 and
  B.is_del = '0'
 and
  B.rst_dialysis_state = '0'
 union all
 select
   B.ord_no
  ,B.pat_id
  ,B.facility_cd
  ,B.treat_date
  ,B.ind_medi_info
  ,B.rst_medi_info
  ,B.rst_dialysis_state
 from
   ord_main B
   INNER JOIN shr_pat s ON s.from_facility_cd = B.facility_cd AND s.from_pat_id = B.pat_id
 where
   B.treat_date >= /*dialysis_date_from*/'20260301'
 and
   B.treat_date <= /*dialysis_date_to*/'20260330'
 and
   B.is_del = '0'
 and
   B.rst_dialysis_state <> '0'
;