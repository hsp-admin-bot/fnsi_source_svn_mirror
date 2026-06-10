with dev_log as (
  select
    event_reg_date
    , cast(1 as smallint) as record_kind
    , cast(null as smallint) as ctl_no
    , machine_record_message
    , cast(0 as bigint) as ord_no
  from
    mnt_motion_record
  where
    data_type = 1
    and facility_cd = /*facilityCd*/'1'
    and machine_type_cd = /*machineTypeCd*/'1'
    and machine_serial = /*machineSerial*/'1'
    and event_reg_date >= /*fromDate*/'1970/01/01 00:00:00'
)
, staff as (
  select
    cast(jae.elm ->> 'occur_date' as timestamp (3)) as event_reg_date
    , cast(2 as smallint) as record_kind
    , cast(jae.elm ->> 'ctl_no' as smallint) as ctl_no
    , '処置者:' || cast(jae.elm ->> 'treat_staff_name' as text) as machine_record_message
    , ord_no
  from
    (
      select
        jsonb_array_elements(rst_treat_staff_info) as elm
        , ord_no
      from
        ord_main
      where
        ord_no = /*ordNo*/1
    ) as jae
)
, treatment as (
  select
    cast(jae.elm ->> 'occur_date' as timestamp (3)) as event_reg_date
    , cast(3 as smallint) as record_kind
    , cast(jae.elm ->> 'ctl_no' as smallint) as ctl_no
    , case
      when bit_length(cast(jae.elm ->> 'oxygen_start' as text)) <> 0
        then case
        when bit_length(cast(jae.elm ->> 'oxygen_speed' as text)) <> 0
--         mod 10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない 関  start
--           then '酸素吸入開始 ' || to_char(cast(jae.elm ->> 'oxygen_speed' as numeric), 'FM9999.90') || 'L/min'
          then '酸素吸入開始 ' || to_char(cast(jae.elm ->> 'oxygen_speed' as numeric), 'FM9990.90') || 'L/min'
--           mod 10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない 関  end
        else '酸素吸入開始'
        end
      when bit_length(cast(jae.elm ->> 'oxygen_amount' as text)) <> 0
--       mod 10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない 関  start
--         then '酸素吸入終了 ' || to_char(cast(jae.elm ->> 'oxygen_amount' as numeric), 'FM9999.90') || 'L'
        then '酸素吸入終了 ' || to_char(cast(jae.elm ->> 'oxygen_amount' as numeric), 'FM9990.90') || 'L'
--         mod 10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない 関  end
      when bit_length(cast(jae.elm ->> 'electrocardiogram_type' as text)) <> 0
        then case
        when cast(jae.elm ->> 'electrocardiogram_type' as smallint) = 0 then '心電図測定開始'
        when cast(jae.elm ->> 'electrocardiogram_type' as smallint) = 1 then '心電図測定終了'
        else '処置区分 心電図'
        end
      else cast(jae.elm ->> 'treat_name' as text)
      end as machine_record_message
    , ord_no
  from
    (
      select
        jsonb_array_elements(rst_treatment_info) as elm
        , ord_no
      from
        ord_main
      where
        ord_no = /*ordNo*/1
    ) as jae
)
, complaint as (
  select
    cast(jae.elm ->> 'occur_date' as timestamp (3)) as event_reg_date
    , cast(4 as smallint) as record_kind
    , cast(jae.elm ->> 'ctl_no' as smallint) as ctl_no
    , cast(jae.elm ->> 'complaint' as text) as machine_record_message
    , ord_no
  from
    (
      select
        jsonb_array_elements(rst_complaint_info) as elm
        , ord_no
      from
        ord_main
      where
        ord_no = /*ordNo*/1
    ) as jae
)
select
  event_reg_date ,
  machine_record_message ,
  count(event_reg_date) over()
from
  (
    select
      *
    from
      dev_log
    union all
    select
      *
    from
      staff
    union all
    select
      *
    from
      treatment
    union all
    select
      *
    from
      complaint
  ) as union_tbl
-- add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
  where coalesce(union_tbl.machine_record_message, '') <> ''
-- add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
order by
  event_reg_date desc
  , record_kind
  , ctl_no desc
limit 10
offset /*offset*/0
;
