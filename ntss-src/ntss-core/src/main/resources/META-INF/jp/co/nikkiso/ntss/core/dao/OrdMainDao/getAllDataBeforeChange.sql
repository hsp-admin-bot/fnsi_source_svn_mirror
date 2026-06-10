with ord_no_list as (select unnest(string_to_array(/*allOrdNo*/null, ',')) as ono)
select om.pat_id
     , om.treat_date
     , coalesce(mk.kur_name, '未登録') as kur_name
     , mb.bed_name
     , coalesce(om.ind_treat_start_time, '0') as ind_treat_start_time_before
     , '未登録' as ind_treat_start_time_after
from ord_main om
       left join mst_kur mk on om.facility_cd = mk.facility_cd and om.ind_kur_cd = mk.kur_cd
       inner join mst_bed mb on om.facility_cd = mb.facility_cd and om.ind_bed_cd = mb.bed_cd
, ord_no_list
where om.ord_no = ord_no_list.ono::int;
