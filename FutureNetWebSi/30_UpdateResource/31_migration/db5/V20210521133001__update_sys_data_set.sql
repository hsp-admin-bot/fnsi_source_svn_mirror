UPDATE "ntss"."sys_data_set" SET "sql" = 'select
    weekmedi_info.cd as f_medi_cd,
    mmd.medicine_name as f_medi_name,
    weekmedi_info.amount as f_medi_amount,
    weekmedi_info.unit as f_medicine_unit,
    array_agg(weekmedi_info.week) as f_week
from
(select
    distinct
    medi ->> ''cd''  as cd,
    to_number(medi ->>''amount'',''99999.9999'') as amount,
    medi ->> ''unit'' as unit,
    medi ->> ''no''  as medi_no,
    case ord.treat_week
        when 1 then ''月''
        when 2 then ''火''
        when 3 then ''水''
        when 4 then ''木''
        when 5 then ''金''
        when 6 then ''土''
        when 7 then ''日''
        else  ''未''
    end as week
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.ind_medi_info :: json) medi
    where
      ord.facility_cd = @facilityCd and 
      ord.treat_date between @fromDate and @toDate and 
      ord.pat_id = @patId and 
      ord.is_del = ''0''
    order by medi_no,cd,amount,unit,week) as weekmedi_info
    left outer join
      mst_medicine as mmd
    on
      mmd.medicine_cd = TO_NUMBER (weekmedi_info.cd,''999999999999'')
      group by weekmedi_info.cd,mmd.medicine_name,weekmedi_info.amount,weekmedi_info.unit
;' WHERE "sql_cd" = 141;