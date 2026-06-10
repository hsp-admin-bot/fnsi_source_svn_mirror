WITH base_ctl AS (
    SELECT COALESCE(MAX(ctl_no), 0) AS base_ctl
    FROM pat_treatment_pattern
    WHERE pat_id = /*patId*/160030
  )
  ,latest_pattern AS (
  SELECT
    w.week::int as treat_week
    ,base_ctl + row_number() OVER (ORDER BY w.week) as ctl_no
    ,CASE WHEN patch ?? 'treat_type' THEN (patch->>'treat_type')::numeric END AS treat_type
    ,CASE WHEN patch ?? 'ind_treat_start_date' THEN patch->>'ind_treat_start_date' END AS ind_treat_start_date
    ,CASE WHEN patch ?? 'ind_treatment_cd' THEN (patch->>'ind_treatment_cd')::numeric END AS ind_treatment_cd
    ,CASE WHEN patch ?? 'ind_kur_cd' THEN (patch->>'ind_kur_cd')::numeric END AS ind_kur_cd
    ,CASE WHEN patch ?? 'ind_sch_info' THEN (patch->>'ind_sch_info')::jsonb END AS ind_sch_info
    ,CASE WHEN patch ?? 'ind_cond_info' THEN (patch->>'ind_cond_info')::jsonb END AS ind_cond_info
    ,CASE WHEN patch ?? 'ind_medi_info' THEN (patch->>'ind_medi_info')::jsonb END AS ind_medi_info
    ,CASE WHEN patch ?? 'ind_equip_info' THEN (patch->>'ind_equip_info')::jsonb END AS ind_equip_info
    ,CASE WHEN patch ?? 'ind_ind_comment_info' THEN (patch->>'ind_ind_comment_info')::jsonb END AS ind_ind_comment_info
    ,CASE WHEN patch ?? 'ind_device_set_info' THEN (patch->>'ind_device_set_info')::jsonb END AS ind_device_set_info
  from unnest(string_to_array(/*dto.treatWeek*/'1,3,5', ',')) AS w(week)
    CROSS JOIN base_ctl
    CROSS JOIN (SELECT /*dto.patchJson*/'{}'::jsonb AS patch) p
)
insert into pat_treatment_pattern
(pat_id, ctl_no, facility_cd, treat_type, ind_treat_start_date, ind_treatment_cd, ind_kur_cd, treat_week,
 ind_sch_info, ind_cond_info, ind_medi_info, ind_equip_info, ind_ind_comment_info, ind_device_set_info,
 reg_date, up_date)
select
  /*patId*/160030
  ,ptp.ctl_no
  ,/*facilityCd*/'NKKSBR'
  ,ptp.treat_type
  ,ptp.ind_treat_start_date
  ,ptp.ind_treatment_cd
  ,ptp.ind_kur_cd
  ,ptp.treat_week
  ,ptp.ind_sch_info
  ,ptp.ind_cond_info
  ,ptp.ind_medi_info
  ,ptp.ind_equip_info
  ,ptp.ind_ind_comment_info
  ,ptp.ind_device_set_info
  ,CURRENT_TIMESTAMP
  ,CURRENT_TIMESTAMP
from latest_pattern ptp
  ON CONFLICT (pat_id, ind_treatment_cd, ind_kur_cd, treat_week) DO NOTHING
RETURNING *;
