with ord_no_list as (select unnest(string_to_array(/*allOrdNo*/null, ',')) as ono),
     kur_cd_before as (select om.ord_no,
                              om.ind_kur_cd,
                              om.ind_treat_start_time,
                         /*userId*/null        as userId,
                         /*userLastName*/null  as userLastName,
                         /*userFirstName*/null as userFirstName,
                         /*updUserId*/null     as updUserId,
                         /*updUserLastName*/null  as updUserLastName,
                         /*updUserFirstName*/null as updUserFirstName
                       from ord_main om,
                            ord_no_list onl
                       where om.ord_no = onl.ono::int)
update ord_main
set ind_kur_cd             = 0,
    ind_treat_start_time   = null,
    up_user_id             = /*updUserId*/null,
    up_ind_user_id         = /*userId*/null,
    ind_schedule_user_info = jsonb_build_object(
                                                -- mod 10860 ind_schedule_user_infoのデータ不正 zhao start
                                                -- 'ind_kur_cd', kur_cd_before.ind_kur_cd,
                                                'ind_kur_cd_before', kur_cd_before.ind_kur_cd,
                                                -- mod 10860 ind_schedule_user_infoのデータ不正 zhao end
                                                'ind_user_id', kur_cd_before.userId,
                                                'upd_user_id', kur_cd_before.updUserId,
                                                'ind_user_last_name', kur_cd_before.userLastName,
                                                'upd_user_last_name', kur_cd_before.updUserLastName,
                                                'ind_user_first_name', kur_cd_before.userFirstName,
                                                'upd_user_first_name', kur_cd_before.updUserFirstName,
                                                -- mod 10860 ind_schedule_user_infoのデータ不正 zhao start
                                                -- 'ind_treat_start_time', kur_cd_before.ind_treat_start_time),
                                                'ind_treat_start_time_before', kur_cd_before.ind_treat_start_time),
                                                -- mod 10860 ind_schedule_user_infoのデータ不正 zhao end
    up_date = CURRENT_TIMESTAMP
from ord_no_list,
     kur_cd_before
where ord_main.ord_no = ord_no_list.ono::int
  and ord_main.ord_no = kur_cd_before.ord_no;
