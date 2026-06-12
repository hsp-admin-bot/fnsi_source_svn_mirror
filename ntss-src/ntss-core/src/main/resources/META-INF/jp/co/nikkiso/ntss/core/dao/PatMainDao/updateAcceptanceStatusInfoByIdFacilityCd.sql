-- #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
update pat_main
  set acceptance_status_info = /*acceptanceStatusInfo*/null
  where
    pat_id = /*patId*/null
    and facility_cd = /*facilityCd*/'X'
;
-- #11205 -ペンテスト2－4認可制御の不備  add 20260427 end
