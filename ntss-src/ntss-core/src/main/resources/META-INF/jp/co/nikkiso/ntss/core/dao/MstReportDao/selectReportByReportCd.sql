select
  /*%expand*/*
from
  mst_report
where
  report_cd = /*reportCd*/1
--del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
-- and
--   is_disp = '1'
--del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
and
  is_del = '0'
;
