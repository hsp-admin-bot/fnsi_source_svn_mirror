-- #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
update pat_main
set
  is_same = /* is_same */null,
  up_date = CURRENT_TIMESTAMP
where
  pat_id in /* patIdList */(0)
  and facility_cd = /* facilityCd */'X'
;
-- #11205 -ペンテスト2－4認可制御の不備  add 20260427 end
