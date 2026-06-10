select
  --/*%expand */*
  report_cd
,facility_cd
,report_name
,report_path
,report_class
,is_disp
,is_del
,reg_date
,up_date
,report_type
,extraction_condition
,default_printer
,additional_info
,disp_order
,report_hst_info
from
  mst_report
where
  facility_cd = /*facilityCd*/null
  and is_del = '0'
  --add 7297 初回リリース対象外の機能とその関連機能を隠す 吉 start
  --del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
--   and is_disp = '1'
  --del #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
  --add 7297 初回リリース対象外の機能とその関連機能を隠す 吉 end
  --add 6502 装置帳票：定期・日常が分離されていない 吉 start
  /*%if vorcFlag != null */
--   del #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
--  and (report_type >0  or report_type is null)
--   del #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    /*%end */
  --add 6502 装置帳票：定期・日常が分離されていない 吉 start
order by disp_order asc, report_class, report_name, is_del, is_disp desc, report_cd
;
