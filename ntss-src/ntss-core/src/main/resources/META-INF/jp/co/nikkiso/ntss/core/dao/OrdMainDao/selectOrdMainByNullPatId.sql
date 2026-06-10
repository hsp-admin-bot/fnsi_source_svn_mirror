-- add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
select ord_main.* from ord_main
where facility_cd = /*facilityCd*/'000000'
  and rst_dialysis_state between '1' and '5'
  and
  treat_date between to_char(date_trunc('day', ( /*fromDate*/'000000'
    )::timestamp), 'yyyymmdd') and to_char(date_trunc('day', ( /*toDate*/'000000'
    )::timestamp) + '1 days - 1 milliseconds', 'yyyymmdd')
  and
    is_del = '0'
  and pat_id IS NULL
-- add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end
