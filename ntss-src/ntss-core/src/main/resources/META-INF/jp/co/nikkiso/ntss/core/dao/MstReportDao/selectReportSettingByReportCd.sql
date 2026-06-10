--  add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 start
select
    /*%expand*/*
  from
    mst_report
  where
      facility_cd = /*facilityCd*/null
    and
      report_cd = /*reportCd*/null
    --del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
--     and
--       is_disp = '1'
    --del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
    and
      is_del = '0'
;
--  add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 end
