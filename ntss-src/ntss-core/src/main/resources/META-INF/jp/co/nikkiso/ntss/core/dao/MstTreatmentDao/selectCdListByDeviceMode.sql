  select
      treatment_cd
  from
    mst_treatment A
  where
    A.facility_cd = /*facilityCd*/0
  /*%if deviceModeList.size() != 0 */
  and
    A.device_mode in /* deviceModeList */(null)
  /*%end*/
