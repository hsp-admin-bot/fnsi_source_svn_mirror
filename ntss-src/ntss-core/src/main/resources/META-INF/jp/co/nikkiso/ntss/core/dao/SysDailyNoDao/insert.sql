--mod #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
insert into sys_daily_no (
  facility_cd,
  numbering_cd,
  current_no,
  is_disp,
  is_del,
  up_date,
  reg_date,
  base_date
) values (
  /*sysDailyNo.facilityCd*/null,
  /*sysDailyNo.numberingCd*/null,
/*sysDailyNo.currentNo*/0,
  /*sysDailyNo.isDisp*/null,
/*sysDailyNo.isDel*/null,
  to_timestamp(/* sysDailyNo.regDate */null, 'YYYY-MM-DD HH24:MI:SS'),
  to_timestamp(/* sysDailyNo.upDate */null, 'YYYY-MM-DD HH24:MI:SS'),
/* sysDailyNo.baseDate */null
)
ON CONFLICT ON CONSTRAINT unq_sys_daily_no_02 do update
set reg_date = CURRENT_TIMESTAMP where 1<>1;
--mod #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end
