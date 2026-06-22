--mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx start
-- with pat_phy_info as (
--     select
--         cast(jsonb_array_elements(physical_info)->>'ctl_no' as int) as ctl_no,
--         jsonb_array_elements(physical_info)->>'indicator_start_date' as indicator_start_date,
--     jsonb_array_elements(physical_info)->>'indicator_cd' as indicator_cd,
--     jsonb_array_elements(physical_info)->>'changer_cd' as changer_cd,
--     jsonb_array_elements(physical_info)->>'target_weight' as target_weight
-- from
--     pat_unique
-- where
--     pat_id = /*patId*/11782
--     ),
--     ranked_phy_info as (
-- select
--     ctl_no,
--     indicator_cd,
--     changer_cd,
--     indicator_start_date as start_date,
--     lead(indicator_start_date) over (order by ctl_no) as end_date,
--     target_weight
-- from
--     pat_phy_info
-- where
--     target_weight is not null
-- group by
--     ctl_no,
--     indicator_cd,
--     changer_cd,
--     indicator_start_date,
--     target_weight
--     ),
--     fixed_rank_phy as (
-- select
--     /*facilityCd*/'NKKSBR' as facility_cd ,
--     /*patId*/11782 as pat_id ,
--     indicator_cd,
--     changer_cd,
--     start_date,
--     case
--     when end_date is null then '99991231'
--     else to_char((end_date::date - interval '1 day'), 'YYYYMMDD') end as end_date,
--     target_weight
-- from
--     ranked_phy_info
-- where
--     end_date is null
--    or start_date < end_date
-- group by
--     indicator_cd,
--     changer_cd,
--     start_date,
--     end_date,
--     target_weight
--     )
-- select
--     distinct
--     om.ord_no ,
--     om.facility_cd ,
--     om.pat_id ,
--     om.treat_date ,
--     om.treat_week ,
--     om.ind_treatment_cd ,
--     om.ind_kur_cd ,
--     jsonb_extract_path_text(om.ind_cond_info, '3', 'value') as original_weight,
--     rpi.target_weight,
--     rpi.indicator_cd,
--     rpi.changer_cd
-- from
--     ord_main om
--         inner join fixed_rank_phy rpi
--                    on om.facility_cd = rpi.facility_cd
--                        and om.pat_id = rpi.pat_id
--                        and om.treat_date between rpi.start_date and rpi.end_date
-- where
--         om.facility_cd = /*facilityCd*/'NKKSBR'
--   and om.pat_id = /*patId*/11782
--   and om.rst_dialysis_state = '0'
--   and om.is_del = '0'
--     /*%if nowDateStr != null*/
--   and om.treat_date >= /*nowDateStr*/'20240508'
--     /*%end*/
-- order by
--     om.treat_date
select
    distinct
    om.ord_no ,
    om.facility_cd ,
    om.pat_id ,
    om.treat_date ,
    om.treat_week ,
    om.ind_treatment_cd ,
    om.ind_kur_cd ,
    jsonb_extract_path_text(om.ind_cond_info, '3', 'value') as original_weight
from
    ord_main om
where
  om.facility_cd = /*facilityCd*/'NKKSBR'
  and om.pat_id = /*patId*/11782
  and om.rst_dialysis_state = '0'
  and om.is_del = '0'
    /*%if nowDateStr != null*/
  and om.treat_date >= /*nowDateStr*/'20240508'
    /*%end*/
order by
    om.treat_date
--mod #12096 データリストにてDWおよび目標体重を登録するとサーバダウン zrx end
