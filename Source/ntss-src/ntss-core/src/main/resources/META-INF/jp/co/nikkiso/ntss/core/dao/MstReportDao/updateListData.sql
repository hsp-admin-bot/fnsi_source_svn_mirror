update mst_report
set
report_name = /*rec.reportName*/'透析レポート'
, is_disp = /*rec.isDisp*/'1'
, is_del = /*rec.isDel*/'0'
, up_date = /*rec.upDate*/null
/*%if rec.dispOrder != null */
   , disp_order = /*rec.dispOrder*/0
/*%end*/
   , default_printer = /*rec.defaultPrinter*/null
/*%if rec.additionalInfo != null */
    , additional_info = /*rec.additionalInfo*/null
/*%end*/
/*%if rec.reportPath != null */
    , report_path = /*rec.reportPath*/null
/*%end*/
/*%if rec.reportHstInfo != null */
    , report_hst_info = /*rec.reportHstInfo*/null
/*%end*/
   , report_type = /*rec.reportType*/null
   , extraction_condition = /*rec.extractionCondition*/null
--    del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy start
--    , multi_total_defaul = /*rec.multiTotalDefaul*/null
--    del #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy end
where
  report_cd = /*rec.reportCd*/1
;
