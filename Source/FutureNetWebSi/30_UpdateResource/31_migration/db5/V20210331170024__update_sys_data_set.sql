UPDATE "ntss"."sys_data_set" SET "sql" = 'with tare_tbl as (
  select
    case when extract(dow from date) = 0 then tare_info->''7''
      when extract(dow from date) = 1 then tare_info->''1''
      when extract(dow from date) = 2 then tare_info->''2''
      when extract(dow from date) = 3 then tare_info->''3''
      when extract(dow from date) = 4 then tare_info->''4''
      when extract(dow from date) = 5 then tare_info->''5''
      when extract(dow from date) = 6 then tare_info->''6''
      else null
    end as tare_info
  from (
    select
      date_trunc(''day'', @date::timestamp) as date,
      tare_info
    from
      pat_main
    where
      pat_id = @patId and is_del = ''0''
  ) as pat_main
)

select
  tare_info->>''name_1'' as name_1,
  tare_info->>''weight_1'' as weight_1,
  tare_info->>''name_2'' as name_2,
  tare_info->>''weight_2'' as weight_2,
  tare_info->>''name_3'' as name_3,
  tare_info->>''weight_3'' as weight_3,
  tare_info->>''name_4'' as name_4,
  tare_info->>''weight_4'' as weight_4,
  tare_info->>''name_5'' as name_5,
  tare_info->>''weight_5'' as weight_5,
  to_number(tare_info->>''weight_1'', ''999999'')
    + to_number(tare_info->>''weight_2'', ''999999'')
    + to_number(tare_info->>''weight_3'', ''999999'')
    + to_number(tare_info->>''weight_4'', ''999999'')
    + to_number(tare_info->>''weight_5'', ''999999'')
 as weight_sum
from
  tare_tbl
;' WHERE "sql_cd" = 32;