with is_same_1_list
       as (select distinct t1.pat_id
           from (select pat_id,
                        pat_last_name,
                        pat_first_name,
                        pat_last_name_kana,
                        pat_first_name_kana,
                        pat_last_name_alpha,
                        pat_first_name_alpha,
                        facility_cd
                 from pat_personal_main) t1
                  inner join (select pat_id,
                                     pat_last_name,
                                     pat_first_name,
                                     pat_last_name_kana,
                                     pat_first_name_kana,
                                     pat_last_name_alpha,
                                     pat_first_name_alpha,
                                     facility_cd
                              from pat_personal_main
                              where is_del = '0') t2
                             on t1.pat_id <> t2.pat_id and t1.facility_cd = t2.facility_cd and
                                ((t1.pat_last_name = t2.pat_last_name and t1.pat_first_name = t2.pat_first_name)
                                  or (t1.pat_last_name_kana = t2.pat_last_name_kana and
                                      t1.pat_first_name_kana = t2.pat_first_name_kana)
                                  or (t1.pat_last_name_alpha = t2.pat_last_name_alpha and
                                      t1.pat_first_name_alpha = t2.pat_first_name_alpha))
           where t1.facility_cd = /*facilityCd*/'')
select pat_id
from pat_personal_main
where facility_cd = /*facilityCd*/''
  and pat_id not in (select pat_id from is_same_1_list);


