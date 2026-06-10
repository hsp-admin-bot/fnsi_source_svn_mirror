select
  /*%if null != params.prefName */
    distinct city_name,
    city_name_kana
  /*%else*/
    city_cd,
    zip_cd_old,
    zip_cd,
    pref_name_kana,
    city_name_kana,
    town_name_kana,
    pref_name,
    city_name,
    town_name,
    flag1,
    flag2,
    flag3,
    flag4,
    flag5,
    flag6,
    address,
    address_kana
  /*%end */
from
  sys_address A
where
  /*%if null != params.searchString */
   -- modify by chamaojia 2024-04-03 [10473] database function changes used for data conversion --start
    address like '%' || address_data_type_translate(/*params.address*/'', true) || '%'
   or
    address_kana like '%' || address_data_type_translate(/*params.addressKana*/'', false) || '%'
   or
    zip_cd like '%' || /*params.zipCd*/'' || '%'
   -- modify by chamaojia 2024-04-03 [10473] database function changes used for data conversion --end
  /*%else*/
    /*%if null != params.prefName */
      pref_name = /*params.prefName*/null
    /*%end */
    /*%if null != params.cityName */
    and
      city_name = /*params.cityName*/null
    /*%end */
    /*%if null != params.townName */
    and
      town_name = /*params.townName*/null
    /*%end */
  /*%end */
order by
/*%if null != params.prefName */
  city_name_kana asc
/*%elseif null != params.cityName */
  town_name_kana asc
/*%else */
  address_kana asc
/*%end */
;
