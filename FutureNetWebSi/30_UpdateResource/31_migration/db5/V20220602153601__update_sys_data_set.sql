DELETE FROM sys_data_set WHERE sql_cd = -400011;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400011, 'WITH ordMain AS (
select
 COALESCE
	(ord.rst_in_out_class, res.rst_in_out_class) AS in_out_class_code
from
  ord_main ord left join ord_main_restore res 
  on ord.ord_no = res.ord_no
where 
  ord.ord_no = @ordNo
)
SELECT case when in_out_class_code = 1 then 1 else 2  end as in_out_class FROM ordMain', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
