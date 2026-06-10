INSERT INTO mst_report (facility_cd,
report_name,
report_path,
report_class,
is_disp,
is_del,
reg_date,
up_date,
report_type,
extraction_condition,
default_printer,
additional_info,
disp_order,
report_hst_info,
-- mod #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy start
-- report_setting,
-- multi_total_defaul)   SELECT
report_setting)   SELECT
-- mod #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy end
/*facilityCd*/null as facility_cd,
report_name,
-- mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 start
--report_path,
-- mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 再修正 商 start
--/*mstReport.reportPath*/null,
report_path,
-- mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 再修正 商 end
-- mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 end
report_class,
--mod 7297 初回リリース対象外の機能とその関連機能を隠す 吉 start
--is_disp,
-- mod 7297 初回リリース対象外の機能とその関連機能を隠す 吉 start
-- case when report_class in (9,10,11) then 1 else 0 end as is_disp,
-- mod 7233  吉 start
-- case when report_class in (9,10,11) then 0 else 1 end as is_disp,
is_disp,
-- mod 7233  吉 end
--mod 7297 初回リリース対象外の機能とその関連機能を隠す 吉 end
--mod 7297 初回リリース対象外の機能とその関連機能を隠す 吉 end
is_del,
reg_date,
up_date,
report_type,
extraction_condition,
default_printer,
additional_info,
disp_order,
-- mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 商 start
--report_hst_info,
null,
-- mod #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 商 end
-- mod #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy start
-- report_setting,
-- multi_total_defaul
report_setting
-- mod #10983 mst_report の未使用カラム「multi_total_defaul」を廃止 sunsy end
 from mst_report
 where
 facility_cd ='nkknkk'
-- add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 start
-- del #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 再修正 商 start
 --and report_cd = /*mstReport.reportCd*/null
-- del #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 再修正 商 start
 and is_del = '0'
-- add #7922 新規施設のデフォルト帳票に作成者・更新者が登録されている / デフォルト帳票が編集できない 修正 商 end
