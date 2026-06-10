UPDATE "ntss"."sys_data_set" SET "sql" = ' select
  COALESCE(
(select count(*) from ord_main where  to_number(ind_cond_info->''5''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''6''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''7''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''8''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''9''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''10''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''11''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''12''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select count(*) from ord_main where  to_number(ind_cond_info->''13''->>''value'',''9999999999999999999'') = @id and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd) + 
(select 
  case
    when sum(to_number(equipInfo->>''amount'',''9999999999999999999'')) is not null then sum(to_number(equipInfo->>''amount'',''9999999999999999999'')) 
    else 0
  end
from ord_main
    cross join lateral  
      json_array_elements (ind_equip_info::json) equipInfo 
      where to_number(equipInfo->>''cd'',''9999999999999999999'')  = @id and to_number(equipInfo->>''equip_type'',''9'') = 0 and treat_date between @dateFrom and @dateTo AND is_del = ''0'' AND facility_cd = @facilityCd)
, 0) as count' WHERE "sql_cd" = -11005;