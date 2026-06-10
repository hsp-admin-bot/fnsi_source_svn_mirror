select
  staff_facility.facility_cd,
  facility.facility_name,
  facility.department_cd,
  facility.prefectures_cd,
  prefecture.pref_name as prefectures_name,
  facility.facility_name_kana

from
  mst_staff_facility staff_facility
    inner join mst_facility facility
      on staff_facility.facility_cd = facility.facility_cd
    left outer join sys_prefectures prefecture
      on facility.prefectures_cd = prefecture.pref_cd

where staff_facility.user_id = /*userId*/1

order by facility.prefectures_cd,facility.department_cd, facility.facility_name_kana
