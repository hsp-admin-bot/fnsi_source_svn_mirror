with
    shr_pat as (
        SELECT
            from_facility_cd,
            from_pat_id
        FROM
            shr_pat_info
        WHERE
          to_facility_cd = /*facility_cd*/'000000'
          AND to_pat_id = /*pat_id*/0
          AND is_from_consent = '1'
          AND is_to_consent = '1'
          AND is_pat_consent = '1'
          AND is_disp = '1'
          AND is_del = '0'
    ),
ord_info as (
        SELECT
              B.*
        FROM
            ord_main B INNER JOIN shr_pat s ON s.from_facility_cd = B.facility_cd AND s.from_pat_id = B.pat_id
           left outer join mst_kur on (B.ind_kur_cd = mst_kur.kur_cd and B.facility_cd = mst_kur.facility_cd and mst_kur.is_del = '0')
           left outer join mst_treatment on (B.ind_treatment_cd = mst_treatment.treatment_cd and B.facility_cd = mst_treatment.facility_cd and mst_treatment.is_del = '0')
        WHERE
                B.treat_date >= /*dialysis_date_from*/'20180220'
          and
                B.treat_date <= /*dialysis_date_to*/'20180220'
          /*%if weeksArry.get(0) != 0 */
          and B.treat_week in /* weeksArry */(1,2,3)
         /*%end */
        order by
            B.treat_date,
            mst_kur.kur_start_time nulls first,
            mst_treatment.device_mode,
            B.ord_no
    ),
cond_mst_info as (
select
    oi.*,
    cond_info.cond_info as cond_info_tmp,
    medi_info.medi_info ,
    equip_info.equip_info
FROM ord_info oi

    LEFT JOIN LATERAL (

    SELECT jsonb_object_agg(
    k,
    CASE
    WHEN k::int IN (2,5,6,7,8,9,10,11,13,15,19,25)
    THEN jsonb_set(
    jsonb_set(
    v,
    '{disp_name}',
    to_jsonb(
    COALESCE(m1.model_number,m2.equipment_name,m3.medicine_name,m3_25.medicine_name,m4.medicine_mix_name,m5.va_name,'')
    )
    ),
    '{disp_unit}',
    to_jsonb(
    case when m1.model_number is not null then '本' else
    COALESCE(m2.unit,m3.unit_second,m3_25.unit,m4.unit,'') end
    )
    )
    WHEN k::int = 1 THEN jsonb_set(v, '{disp_unit}', to_jsonb('分'::text))
    WHEN k::int = 3 THEN jsonb_set(v, '{disp_unit}', to_jsonb('Kg'::text))
    WHEN k::int IN (4,20) THEN jsonb_set(v, '{disp_unit}', to_jsonb('L'::text))
    WHEN k::int IN (14,16) THEN jsonb_set(v, '{disp_unit}', to_jsonb('mL/min'::text))
    WHEN k::int IN (18,23) THEN jsonb_set(v, '{disp_unit}', to_jsonb('℃'::text))
    WHEN k::int = 24 THEN jsonb_set(v, '{disp_unit}', to_jsonb('L/h'::text))
    WHEN k::int = 31 THEN jsonb_set(v, '{disp_unit}', to_jsonb('mL'::text))
    WHEN k::int IN (32,33) THEN jsonb_set(v, '{disp_unit}', to_jsonb('mL/h'::text))
    WHEN k::int IN (36,38) THEN jsonb_set(v, '{disp_unit}', to_jsonb('分前'::text))
    ELSE v
    END
    ) AS cond_info

    FROM jsonb_each(oi.ind_cond_info) t(k,v)

    LEFT JOIN mst_dialyzer m1
    ON k::int = 5
    AND m1.dialyzer_cd = ((NULLIF(v->>'value',''))::numeric)::int

    LEFT JOIN mst_equipment m2
    ON k::int IN (6,7,8,9,10,11,13)
    AND m2.equipment_cd = ((NULLIF(v->>'value',''))::numeric)::int

    LEFT JOIN mst_medicine m3
    ON k::int IN (15,19)
    AND m3.medicine_cd = ((NULLIF(v->>'value',''))::numeric)::int

        LEFT JOIN mst_medicine m3_25
        ON (k::int = 25 AND (v->>'medicine_type')::int = 1)
        AND m3_25.medicine_cd = ((NULLIF(v->>'value',''))::numeric)::int

    LEFT JOIN mst_medicine_mix m4
    ON k::int = 25
    AND (v->>'medicine_type')::int = 2
    AND m4.medicine_mix_cd = ((NULLIF(v->>'value',''))::numeric)::int

    LEFT JOIN mst_va m5
    ON k::int = 2
    AND m5.va_cd = ((NULLIF(v->>'value',''))::numeric)::int

    ) cond_info ON TRUE
    LEFT JOIN LATERAL (
    SELECT jsonb_agg(
    jsonb_set(
    jsonb_set(
    elem,
    '{disp_unit}',
    to_jsonb(
    COALESCE(m3.unit,m4.unit,'')
    )
    ),
    '{disp_name}',
    to_jsonb(
    COALESCE(m3.medicine_name,m4.medicine_mix_name,'')
    )
    )
    ) AS medi_info
    FROM jsonb_array_elements(oi.ind_medi_info) elem
    LEFT JOIN mst_medicine m3
    ON (elem->>'medicine_type')::int = 1
    AND m3.medicine_cd = (elem->>'cd')::int

    LEFT JOIN mst_medicine_mix m4
    ON (elem->>'medicine_type')::int = 2
    AND m4.medicine_mix_cd = (elem->>'cd')::int

    ) medi_info ON TRUE
    LEFT JOIN LATERAL (
    SELECT jsonb_agg(
    jsonb_set(
    jsonb_set(
    elem,
    '{disp_unit}',
    to_jsonb(
    case when m1.model_number is not null then '本' else COALESCE(m2.unit,'') end
    )
    ),
    '{disp_name}',
    to_jsonb(
    COALESCE(m1.model_number,m2.equipment_name,'')
    )
    )
    ) AS equip_info
    FROM jsonb_array_elements(oi.ind_equip_info) elem
    LEFT JOIN mst_dialyzer m1
    ON (elem->>'equip_type')::int = 1
    AND m1.dialyzer_cd = (elem->>'cd')::int

    LEFT JOIN mst_equipment m2
    ON (elem->>'equip_type')::int = 0
    AND m2.equipment_cd = (elem->>'cd')::int

    ) equip_info ON TRUE
    )
select
    cmi.ord_no
     ,cmi.pat_id
     ,cmi.fn_pat_id
     ,cmi.treat_date
     ,cmi.treat_week
     ,cmi.facility_cd
     ,cmi.facility_name
     ,cmi.ind_va_cd
     ,cmi.ind_treatment_cd
     ,case when cmi.rst_dialysis_state = '0' then mst_treatment.treatment_name else cmi.ind_treatment_name end as ind_treatment_name
     ,cmi.ind_kur_cd
     ,case when cmi.rst_dialysis_state = '0' then mst_kur.kur_name else cmi.ind_kur_name end as ind_kur_name
     ,cmi.ind_treat_start_time
     ,cmi.ind_bed_cd
     ,case when cmi.rst_dialysis_state = '0' then mst_bed.bed_name else cmi.ind_bed_name end as ind_bed_name
     ,cmi.ind_schedule_user_info
     ,cmi.ind_ind_comment_info
     ,cmi.ind_tare_info
     ,cmi.ind_off_water_info
     ,cmi.rst_fn_dialysis_no
     ,cmi.rst_relation_dialysis_no
     ,cmi.rst_edition
     ,cmi.rst_is_update_edition
     ,cmi.rst_input_class
     ,cmi.rst_dialysis_state
     ,cmi.rst_treatment_cd
     ,cmi.rst_treatment_name
     ,cmi.rst_kur_cd
     ,cmi.rst_kur_name
     ,cmi.rst_bed_cd
     ,cmi.rst_bed_name
     ,cmi.rst_machine_no
     ,cmi.rst_machine_name
     ,cmi.rst_cond_send_date
     ,cmi.rst_accept_date
     ,cmi.rst_start_date
     ,cmi.rst_end_date
     ,cmi.rst_return_home_date
     ,cmi.rst_in_out_class
     ,cmi.rst_dialysis_cnt
     ,cmi.rst_ward_cd
     ,cmi.rst_ward_name
     ,cmi.rst_course_cd
     ,cmi.rst_course_name
     ,cmi.rst_puncture_user_info
     ,cmi.rst_return_user_info
     ,cmi.rst_charge_user_info
     ,cmi.rst_blood_circulate_total
     ,cmi.rst_running_time
     ,cmi.rst_kt_v
     ,cmi.rec_set_date
     ,cmi.send_ctl_no
     ,cmi.blood_purifier_name
     ,cmi.pull_leave_amount
     ,cmi.rst_cond_info
     ,cmi.rst_medi_info
     ,cmi.rst_equip_info
     ,cmi.rst_ind_comment_info
     ,cmi.rst_tare_info
     ,cmi.rst_off_water_info
     ,cmi.rst_weight_info
     ,cmi.rst_complaint_info
     ,cmi.rst_treatment_info
     ,cmi.rst_treat_staff_info
     ,cmi.rst_rounds_info
     ,cmi.is_del
     ,cmi.up_date
     ,cmi.ind_device_set_info
     ,cmi.rst_dw
     ,cmi.treat_type
     ,cmi.ind_dw
     ,cmi.rst_purification_cnt
     ,cmi.addition_info

     ,jsonb_set(
        jsonb_set(
                jsonb_set(
                        jsonb_set(
                                jsonb_set(
                                        cond_info_tmp,
                                        '{17,disp_unit}',
                                        COALESCE(cond_info_tmp->'15'->'disp_unit','null'::jsonb),
                                        true
                                    ),
                                '{22,disp_unit}',
                                COALESCE(cond_info_tmp->'19'->'disp_unit','null'::jsonb),
                                true
                            ),
                        '{26,disp_unit}',
                        COALESCE(cond_info_tmp->'25'->'disp_unit','null'::jsonb),
                        true
                    ),
                '{28,disp_unit}',
                COALESCE(cond_info_tmp->'25'->'disp_unit','null'::jsonb),
                true
            ),
        '{27,disp_unit}',
        to_jsonb(
                    COALESCE(cond_info_tmp->'25'->>'disp_unit','') || '/h'
            ),
        true
    ) as ind_cond_info

     ,medi_info as ind_medi_info
     ,equip_info as ind_equip_info
from cond_mst_info cmi
left outer join mst_kur on (cmi.ind_kur_cd = mst_kur.kur_cd and cmi.facility_cd = mst_kur.facility_cd and mst_kur.is_del = '0')
left outer join mst_treatment on (cmi.ind_treatment_cd = mst_treatment.treatment_cd and cmi.facility_cd = mst_treatment.facility_cd and mst_treatment.is_del = '0')
left join mst_bed on mst_bed.bed_cd = cmi.ind_bed_cd
