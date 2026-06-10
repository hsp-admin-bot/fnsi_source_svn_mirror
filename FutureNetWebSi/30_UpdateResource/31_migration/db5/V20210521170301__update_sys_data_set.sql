update ntss.sys_data_set set "sql"='with opt_day as (
   select op ->>''id'' ||'' day'' as days   from sys_facility_setting 
      cross join lateral
        json_array_elements (sys_facility_setting.option_value :: json) op
   where facility_setting_no= ''3008'' and op ->>''id'' = default_value
), medicine_tbl as (
  select
    *
  from
    mst_medicine
  where
    mst_medicine.facility_cd = @facilityCd
  and
    mst_medicine.is_disp = ''1''
  and
    mst_medicine.is_del = ''0''
), medicine_mix_tbl as (
  select
    *
  from
    mst_medicine_mix
  where
    mst_medicine_mix.facility_cd = @facilityCd
  and
    mst_medicine_mix.is_disp = ''1''
  and
    mst_medicine_mix.is_del = ''0''
), medicine_class_tbl as (
  select
    *
  from
    mst_medicine_class
  where
    mst_medicine_class.facility_cd = @facilityCd
  and
    mst_medicine_class.is_disp = ''1''
  and
    mst_medicine_class.is_del = ''0''
), timing_tbl as (
  select
    *
  from
    mst_medicate_timing
  where
    mst_medicate_timing.facility_cd = @facilityCd
  and
    mst_medicate_timing.is_disp = ''1''
  and
    mst_medicate_timing.is_del = ''0''
), procedure_tbl as (
  select
    *
  from
    mst_procedure
  where
    mst_procedure.facility_cd = @facilityCd
  and
    mst_procedure.is_disp = ''1''
  and
    mst_procedure.is_del = ''0''
), ord_tbl as (
  select
      pat_id
    , to_date(treat_date, ''yyyymmdd'') as treat_date
    , treat_week
    , info ->> ''no'' as no
    , info ->> ''medicine_type'' as medicine_type
    , info ->> ''cd'' as cd
    , info ->> ''amount'' as amount
    , to_date(info ->> ''init_date'', ''yyyymmdd'') as init_date
    , info ->> ''date_interval'' as date_interval
    , info ->> ''timing_cd'' as timing_cd
    , info ->> ''procedure_cd'' as procedure_cd
    , info ->> ''comment'' as comment
    , info ->> ''ind_user_id'' as ind_user_id
    , info ->> ''ind_user_last_name'' as ind_user_last_name
    , info ->> ''ind_user_first_name'' as ind_user_first_name
    , info ->> ''upd_user_id'' as upd_user_id
    , info ->> ''upd_user_last_name'' as upd_user_last_name
    , info ->> ''upd_user_first_name'' as upd_user_first_name
    , info ->> ''input_class'' as input_class
    , info ->> ''is_editable'' as is_editable
    , info ->> ''cop_order_no'' as cop_order_no 
from
    ord_main  
    cross join lateral json_array_elements(ind_medi_info ::json) info 
  where
    pat_id = @patId
    and to_date(info ->> ''init_date'', ''yyyymmdd'') <= treat_date ::timestamp 
    and is_del = ''0''
    and rst_dialysis_state = ''0''
    and ord.facility_cd = @facilityCd
)
select
  ord.*,
  case
    when medicine_type = ''2'' then mix.medicine_mix_name
    else med.medicine_name
  end as medicine_name,
  case
    when medicine_type = ''2'' then mix.unit
    else med.unit
  end as medicine_unit,
  case
    when medicine_type = ''2'' then mix.class_cd
    else med.class_cd
  end as class_cd,
  case
    when medicine_type = ''2'' then mix_cls.class_name
    else med_cls.class_name
  end as class_name,
  case
    when medicine_type = ''2'' then mix_cls.class_type
    else med_cls.class_type
  end as class_type,
  tim.medicate_timing_name,
  pro.pricedure_name
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_1 else mix.in_hospital_cd_1 end as medi_in_hospital_cd_1
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_2 else mix.in_hospital_cd_2 end as medi_in_hospital_cd_2
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_3 else mix.in_hospital_cd_3 end as medi_in_hospital_cd_3
  ,case when  ord.medicine_type = ''1'' then med.in_hospital_cd_4 else '''' end as medi_in_hospital_cd_4
  ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
   then  pro.in_hospital_cd_a1 else pro.in_hospital_cd_b1 end as procedure_in_hospital_cd_1
  ,case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_a_startdate )) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',pro.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
  then  pro.in_hospital_cd_a2 else pro.in_hospital_cd_b2 end as procedure_in_hospital_cd_2
from
  ord_tbl as ord
  left join medicine_tbl as med on ord.cd = med.medicine_cd::text
  left join medicine_mix_tbl as mix on ord.cd = mix.medicine_mix_cd::text
  left join medicine_class_tbl as med_cls on med.class_cd = med_cls.class_cd
  left join medicine_class_tbl as mix_cls on mix.class_cd = mix_cls.class_cd
  left join timing_tbl as tim on ord.timing_cd = tim.medicate_timing_cd::text
  left join procedure_tbl as pro on ord.procedure_cd = pro.procedure_cd::text
where
  ord.pat_id = @patId
  and ord.facility_cd = @facilityCd' where sql_cd=4;
  
  update ntss.sys_data_set set "sql"='with mstcp_tbl as (
    select 
    comp_treatment_cd
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_1 else mstMedic.in_hospital_cd_1 end as treatMdeci_in_hospital_cd_1
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_2 else mstMedic.in_hospital_cd_2 end as treatMdeci_in_hospital_cd_2
    ,case treat_class when ''0'' then mstMedicMix.in_hospital_cd_3 else mstMedic.in_hospital_cd_3 end as treatMdeci_in_hospital_cd_3
    ,case treat_class when ''0'' then '''' else mstMedic.in_hospital_cd_4 end as treatMdeci_in_hospital_cd_4
    from mst_comp_treatment mstCpt
    left join mst_medicine_mix  as mstMedicMix  on (mstCpt.treat_medicine_cd = mstMedicMix.medicine_mix_cd      and mstMedicMix.is_del = ''0'' and mstMedicMix.is_disp = ''1'')
    left join mst_medicine as  mstMedic  on (mstCpt.treat_medicine_cd = mstMedic.medicine_cd      and mstMedic.is_del = ''0'' and mstMedic.is_disp = ''1'')
    where mstCpt.treat_class != ''2''
     and mstCpt.is_del = ''0''
     and mstCpt.is_disp = ''1''
)
  select
  to_char(to_timestamp(coalesce(a.occur_date, b.occur_date, c.occur_date), ''YYYY-MM-DD"T"HH24:MI:SS"Z"'')::timestamp, ''HH24:MI'') as occur_time,
  a.complaint,
  b.treat_name,
  b.treat_medicine,
  b.treatMdeci_in_hospital_cd_1,
  b.treatMdeci_in_hospital_cd_2,
  b.treatMdeci_in_hospital_cd_3,
  treatMdeci_in_hospital_cd_4,
  b.amount,
  b.unit,
  b.procedure,
  c.treat_staff_name,
  c.treat_staff_cd
from
  (
    select
      ord.ord_no,
      complaint->>''occur_date'' as occur_date,
      complaint->>''complaint'' as complaint,
      complaint->>''row_no'' as row_no
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_complaint_info::json) complaint
    where ord.is_del = ''0'' and ord.rst_dialysis_state<>''0''
    and ord.ord_no = @ordNo
    and ord.facility_cd = @facilityCd
    order by
      ord_no,
      occur_date) a
  full outer join
  (
    select
      ord.ord_no,
      treatment->>''occur_date'' as occur_date,
      treatment->>''row_no'' as row_no,
      case
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is not null then concat(''酸素吸入開始 '', to_char(cast(treatment->>''oxygen_speed'' as numeric), ''FM999999.00''), ''L/min'')
        when treatment->>''treat_class'' = ''3'' and treatment->>''oxygen_start'' is null then concat(''酸素吸入終了 '' , to_char(cast(treatment->>''oxygen_amount'' as numeric), ''FM999999.00''), ''L'')
        else treatment->>''treat_name'' end
      as treat_name,
      treatment->>''treat_medicine_name'' as treat_medicine,
      treatment->>''amount'' as amount,
      treatment->>''unit'' as unit,
      treatment->>''procedure_name'' as procedure,
      mstcp_tbl.treatMdeci_in_hospital_cd_1,
      mstcp_tbl.treatMdeci_in_hospital_cd_2,
      mstcp_tbl.treatMdeci_in_hospital_cd_3,
      mstcp_tbl.treatMdeci_in_hospital_cd_4
    from
      ord_main as ord
      left join mstcp_tbl on (
      (select
            treatmentA ->> ''treat_cd'' as treat_cd
        from
            ntss.ord_main ordmain cross
        join lateral json_array_elements (ordmain.rst_treatment_info::json ) treatmentA
        where
            ordmain.ord_no = @ordNo
            and ordmain.rst_dialysis_state <> ''0'' ) = mstcp_tbl.comp_treatment_cd ::text)
    cross join lateral
      json_array_elements (ord.rst_treatment_info::json) treatment
    where ord.is_del = ''0'' and ord.rst_dialysis_state<>''0''
    and ord_no = @ordNo
    and facility_cd = @facilityCd
    order by
      ord_no,
      occur_date,
      row_no) b
  on a.ord_no = b.ord_no and a.occur_date = b.occur_date and a.row_no = b.row_no
  full outer join
  (
    select
      ord.ord_no,
      treat_staff->>''occur_date'' as occur_date,
      treat_staff->>''row_no'' as row_no,
      treat_staff->>''treat_staff_name'' as treat_staff_name,
      treat_staff->>''treat_staff_cd'' as treat_staff_cd
    from
      ord_main as ord
    cross join lateral
      json_array_elements (ord.rst_treat_staff_info::json) treat_staff
    where ord.is_del = ''0''  and ord.rst_dialysis_state<>''0''
    and ord_no = @ordNo
    and ord.facility_cd = @facilityCd
    order by
      ord_no,
      occur_date,
      row_no) c
  on COALESCE(a.ord_no,b.ord_no) = c.ord_no and COALESCE(a.occur_date,b.occur_date) = c.occur_date and COALESCE(a.row_no, b.row_no) = c.row_no
where
  coalesce(a.ord_no, b.ord_no, c.ord_no) = @ordNo
order by
  coalesce(a.occur_date, b.occur_date, c.occur_date), to_number(coalesce(a.row_no, b.row_no, c.row_no), ''9999999999'')' where sql_cd=6;

update ntss.sys_data_set set "sql"='select 
pm.device_set_info#>>''{"bp","dev","A","211"}'' as bp_dev_a_0211,--血圧警報点最高血圧上限
pm.device_set_info#>>''{"bp","dev","A","212"}'' as bp_dev_a_0212,--血圧警報点最高血圧下限
pm.device_set_info#>>''{"bp","dev","A","213"}'' as bp_dev_a_0213,--血圧警報点最低血圧上限
pm.device_set_info#>>''{"bp","dev","A","214"}'' as bp_dev_a_0214,--血圧警報点最低血圧下限
pm.device_set_info#>>''{"bp","dev","A","215"}'' as bp_dev_a_0215,--血圧警報点平均血圧上限
pm.device_set_info#>>''{"bp","dev","A","216"}'' as bp_dev_a_0216,--血圧警報点平均血圧下限
pm.device_set_info#>>''{"bp","dev","A","217"}'' as bp_dev_a_0217,--血圧警報点脈拍数上限
pm.device_set_info#>>''{"bp","dev","A","218"}'' as bp_dev_a_0218,--血圧警報点脈拍数下限
pm.device_set_info#>>''{"bp","dev","A","227"}'' as bp_dev_a_0227,--最高血圧上限警報_血液ポンプ_速度
pm.device_set_info#>>''{"bp","dev","A","219"}'' as bp_dev_a_0219,--最高血圧上限警報_血液ポンプ_動作選択
pm.device_set_info#>>''{"bp","dev","A","228"}'' as bp_dev_a_0228,--最高血圧下限警報_血液ポンプ_速度
pm.device_set_info#>>''{"bp","dev","A","220"}'' as bp_dev_a_0220,--最高血圧下限警報_血液ポンプ_動作選択
pm.device_set_info#>>''{"bp","dev","A","229"}'' as bp_dev_a_0229,--最高血圧上限警報_除水ポンプ_速度
pm.device_set_info#>>''{"bp","dev","A","221"}'' as bp_dev_a_0221,--最高血圧上限警報_除水ポンプ_動作選択
pm.device_set_info#>>''{"bp","dev","A","230"}'' as bp_dev_a_0230,--最高血圧下限警報_除水ポンプ_速度
pm.device_set_info#>>''{"bp","dev","A","222"}'' as bp_dev_a_0222,--最高血圧下限警報_除水ポンプ_動作選択
pm.device_set_info#>>''{"bp","dev","A","231"}'' as bp_dev_a_0231,--最高血圧上限警報_Na注入ポンプ_速度
pm.device_set_info#>>''{"bp","dev","A","223"}'' as bp_dev_a_0223,--最高血圧上限警報_Na注入ポンプ_動作選択
pm.device_set_info#>>''{"bp","dev","A","232"}'' as bp_dev_a_0232,--最高血圧下限警報_Na注入ポンプ_速度
pm.device_set_info#>>''{"bp","dev","A","224"}'' as bp_dev_a_0224,--最高血圧下限警報_Na注入ポンプ_動作選択
pm.device_set_info#>>''{"bp","dev","A","233"}'' as bp_dev_a_0233,--最高血圧上限警報_補液ポンプ_速度
pm.device_set_info#>>''{"bp","dev","A","225"}'' as bp_dev_a_0225,--最高血圧上限警報_補液ポンプ_動作選択
pm.device_set_info#>>''{"bp","dev","A","234"}'' as bp_dev_a_0234,--最高血圧下限警報_補液ポンプ_速度
pm.device_set_info#>>''{"bp","dev","A","226"}'' as bp_dev_a_0226,--最高血圧下限警報_補液ポンプ_動作選択
pm.device_set_info#>>''{"bp","dev","A","191"}'' as bp_dev_a_0191,--血圧カフ選択
pm.device_set_info#>>''{"bp","dev","A","190"}'' as bp_dev_a_0190,--血圧自動測定間隔
pm.device_set_info#>>''{"bp","dev","A","192"}'' as bp_dev_a_0192,--昇圧値
pm.device_set_info#>>''{"bp","dev","A","193"}'' as bp_dev_a_0193,--昇圧方法選択
pm.device_set_info#>>''{"bp","dev","A","195"}'' as bp_dev_a_0195,--血圧測定方法選択
pm.device_set_info#>>''{"bp","dev","A","239"}'' as bp_dev_a_0239,--高速測定選択
pm.device_set_info#>>''{"bp","dev","A","194"}'' as bp_dev_a_0194,--血圧連続測定動作選択
pm.device_set_info#>>''{"bp","dev","A","235"}'' as bp_dev_a_0235,--警報連動測定開始時間
pm.device_set_info#>>''{"bp","dev","A","236"}'' as bp_dev_a_0236,--治療条件連動測定時間
pm.device_set_info#>>''{"bp","dev","A","237"}'' as bp_dev_a_0237,--静脈圧警報発生時の血圧測定
pm.device_set_info#>>''{"bp","dev","A","238"}'' as bp_dev_a_0238,--血流量または除水速度変更時の血圧測定
pm.device_set_info#>>''{"bv","dev","A","267"}'' as bv_dev_a_0267,--BV計使用選択
pm.device_set_info#>>''{"bv","dev","A","260"}'' as bv_dev_a_0260,--⊿BV低下警報点1
pm.device_set_info#>>''{"bv","dev","A","261"}'' as bv_dev_a_0261,--⊿BV低下警報点2
pm.device_set_info#>>''{"bv","dev","A","262"}'' as bv_dev_a_0262,--⊿BV変化率警報点
pm.device_set_info#>>''{"bv","dev","A","277"}'' as bv_dev_a_0277,--⊿BV除水低下速度
pm.device_set_info#>>''{"bv","dev","A","278"}'' as bv_dev_a_0278,--⊿BV除水低下遅延時間
pm.device_set_info#>>''{"bv","dev","A","258"}'' as bv_dev_a_0258,--アクセス再循環測定使用選択
pm.device_set_info#>>''{"bv","dev","A","259"}'' as bv_dev_a_0259,--アクセス再循環自動測定1
pm.device_set_info#>>''{"bv","dev","A","263"}'' as bv_dev_a_0263,--アクセス再循環自動測定2
pm.device_set_info#>>''{"bv","dev","A","264"}'' as bv_dev_a_0264,--アクセス再循環自動測定3
pm.device_set_info#>>''{"bv","dev","A","265"}'' as bv_dev_a_0265,--アクセス再循環自動測定4
pm.device_set_info#>>''{"bv","dev","A","266"}'' as bv_dev_a_0266,--アクセス再循環自動測定5
pm.device_set_info#>>''{"bv","dev","A","281"}'' as bv_dev_a_0281,--アクセス再循環再循環率報知
pm.device_set_info#>>''{"cpro","dev","A","252"}'' as cpro_dev_a_0252,--Ｂ液濃度プログラム自動設定警報幅上限
pm.device_set_info#>>''{"cpro","dev","A","253"}'' as cpro_dev_a_0253,--Ｂ液濃度プログラム自動設定警報幅下限
pm.device_set_info#>>''{"cpro","dev","A","250"}'' as cpro_dev_a_0250,--透析液濃度プログラム自動設定警報幅上限
pm.device_set_info#>>''{"cpro","dev","A","251"}'' as cpro_dev_a_0251,--透析液濃度プログラム自動設定警報幅下限
pm.device_set_info#>>''{"dfas","dev","A","339"}'' as dfas_dev_a_0339,--脱血方法選択
pm.device_set_info#>>''{"dfas","dev","A","333"}'' as dfas_dev_a_0333,--脱血速度
pm.device_set_info#>>''{"dfas","dev","A","331"}'' as dfas_dev_a_0331,--同時脱血_脱血量
pm.device_set_info#>>''{"dfas","dev","A","334"}'' as dfas_dev_a_0334,--片側脱血(除水なし)_脱血量
pm.device_set_info#>>''{"dfas","dev","A","338"}'' as dfas_dev_a_0338,--片側脱血（除水あり）_脱血量
pm.device_set_info#>>''{"dfas","dev","A","332"}'' as dfas_dev_a_0332,--片側脱血への切替え透析液圧
pm.device_set_info#>>''{"dfas","dev","A","373"}'' as dfas_dev_a_0373,--静脈側返血速度
pm.device_set_info#>>''{"dfas","dev","A","374"}'' as dfas_dev_a_0374,--静脈側最大返血量
pm.device_set_info#>>''{"dfas","dev","A","377"}'' as dfas_dev_a_0377,--静脈側返血_血液判別器使用選択
pm.device_set_info#>>''{"dfas","dev","A","270"}'' as dfas_dev_a_0270,--動脈側返血使用選択
pm.device_set_info#>>''{"dfas","dev","A","376"}'' as dfas_dev_a_0376,--動脈側最大返血量
pm.device_set_info#>>''{"dfas","dev","A","378"}'' as dfas_dev_a_0378,--動脈側返血_血液判別器使用選択
pm.device_set_info#>>''{"dfas","dev","A","335"}'' as dfas_dev_a_0335,--治療開始時_血液ポンプ速度
pm.device_set_info#>>''{"dfas","dev","B","36"}'' as dfas_dev_b_0036,--治療開始時_血流量使用有無
pm.device_set_info#>>''{"dfas","pat","B","1"}'' as dfas_pat_b_0001,--IPラインプライミング使用選択
pm.device_set_info#>>''{"dfas","pat","B","5"}'' as dfas_pat_b_0005,--中空糸_プライミング時のBP速度
pm.device_set_info#>>''{"dfas","pat","B","7"}'' as dfas_pat_b_0007,--中空糸_送液最大時間
pm.device_set_info#>>''{"dfas","pat","B","8"}'' as dfas_pat_b_0008,--中空糸_回路内洗浄送液量
pm.device_set_info#>>''{"dfas","pat","B","9"}'' as dfas_pat_b_0009,--中空糸_気泡抜き動作実行回数
pm.device_set_info#>>''{"dfas","pat","B","10"}'' as dfas_pat_b_0010,--中空糸_気泡抜き圧力上限
pm.device_set_info#>>''{"dfas","pat","B","59"}'' as dfas_pat_b_0059,--積層_プライミング時のBP速度
pm.device_set_info#>>''{"dfas","pat","B","54"}'' as dfas_pat_b_0054,--積層_送液最大時間
pm.device_set_info#>>''{"dfas","pat","B","55"}'' as dfas_pat_b_0055,--積層_回路内洗浄送液量
pm.device_set_info#>>''{"dfas","pat","B","56"}'' as dfas_pat_b_0056,--積層_気泡抜き動作実行回数
pm.device_set_info#>>''{"dfas","pat","B","57"}'' as dfas_pat_b_0057,--積層_気泡抜き圧力上限
pm.device_set_info#>>''{"dfas","pat","B","58"}'' as dfas_pat_b_0058,--積層_除水ポンプ速度
pm.device_set_info#>>''{"ecum","dev","A","16"}'' as ecum_dev_a_0016,--ECUM選択
pm.device_set_info#>>''{"ecum","dev","A","17"}'' as ecum_dev_a_0017,--ECUM量
pm.device_set_info#>>''{"ecum","dev","A","18"}'' as ecum_dev_a_0018,--ECUM時間
pm.device_set_info#>>''{"ecum","dev","A","19"}'' as ecum_dev_a_0019,--ECUM時間カウント選択
pm.device_set_info#>>''{"ope","dev","A","179"}'' as ope_dev_a_0179,--血流量設定最大値
pm.device_set_info#>>''{"ope","dev","A","181"}'' as ope_dev_a_0181,--除水速度制限
pm.device_set_info#>>''{"ope","dev","A","38"}'' as ope_dev_a_0038,--動脈側気泡検出器
pm.device_set_info#>>''{"ope","dev","A","21"}'' as ope_dev_a_0021,--除水計算時間
pm.device_set_info#>>''{"ope","dev","A","22"}'' as ope_dev_a_0022,--除水計算優先項目
pm.device_set_info#>>''{"ope","dev","A","39"}'' as ope_dev_a_0039,--除水開始遅延時間
pm.device_set_info#>>''{"ope","dev","A","182"}'' as ope_dev_a_0182,--透析液温度操作範囲上限
pm.device_set_info#>>''{"ope","dev","A","183"}'' as ope_dev_a_0183,--透析液温度操作範囲下限
pm.device_set_info#>>''{"ope","dev","A","268"}'' as ope_dev_a_0268,--透析液流量　設定方法
pm.device_set_info#>>''{"ope","dev","A","269"}'' as ope_dev_a_0269,--透析液流量　比率設定
pm.device_set_info#>>''{"ope","dev","A","24"}'' as ope_dev_a_0024,--シングルニードル切替圧上限
pm.device_set_info#>>''{"ope","dev","A","25"}'' as ope_dev_a_0025,--シングルニードル切替圧下限
pm.device_set_info#>>''{"ope","dev","A","241"}'' as ope_dev_a_0241,--TMPゼロ補正
pm.device_set_info#>>''{"ope","dev","A","168"}'' as ope_dev_a_0168,--HD補正警報上限値
pm.device_set_info#>>''{"ope","dev","A","169"}'' as ope_dev_a_0169,--HD補正警報下限値
pm.device_set_info#>>''{"ope","dev","A","171"}'' as ope_dev_a_0171,--ECUM補正警報上限値
pm.device_set_info#>>''{"ope","dev","A","172"}'' as ope_dev_a_0172,--ECUM補正警報下限値
pm.device_set_info#>>''{"ope","dev","A","174"}'' as ope_dev_a_0174,--HDF補正警報上限値
pm.device_set_info#>>''{"ope","dev","A","175"}'' as ope_dev_a_0175,--HDF補正警報下限値
pm.device_set_info#>>''{"ope","dev","A","177"}'' as ope_dev_a_0177,--HF補正警報上限値
pm.device_set_info#>>''{"ope","dev","A","178"}'' as ope_dev_a_0178,--HF補正警報下限値
pm.device_set_info#>>''{"ope","dev","A","391"}'' as ope_dev_a_0391,--OHDF補正警報上限値
pm.device_set_info#>>''{"ope","dev","A","392"}'' as ope_dev_a_0392,--OHDF補正警報下限値
pm.device_set_info#>>''{"ope","dev","A","394"}'' as ope_dev_a_0394,--OHF補正警報上限値
pm.device_set_info#>>''{"ope","dev","A","395"}'' as ope_dev_a_0395,--OHF補正警報下限値
pm.device_set_info#>>''{"ope","dev","A","383"}'' as ope_dev_a_0383,--補液量制限
pm.device_set_info#>>''{"ope","dev","A","389"}'' as ope_dev_a_0389,--補液計算優先項目
pm.device_set_info#>>''{"ope","dev","A","379"}'' as ope_dev_a_0379,--補液比率（前補液）
pm.device_set_info#>>''{"ope","dev","A","398"}'' as ope_dev_a_0398,--補液開始遅延時間
pm.device_set_info#>>''{"ope","dev","A","369"}'' as ope_dev_a_0369,--DP=Qd+Qs(補液速度加算)
pm.device_set_info#>>''{"ope","dev","A","90"}'' as ope_dev_a_0090,--濾過率（前補液）
pm.device_set_info#>>''{"ope","dev","A","91"}'' as ope_dev_a_0091,--ヘマトクリット（Ht）
pm.device_set_info#>>''{"ope","dev","A","92"}'' as ope_dev_a_0092,--総タンパク（TP）
pm.device_set_info#>>''{"ope","dev","A","336"}'' as ope_dev_a_0336,--緊急補液速度
pm.device_set_info#>>''{"ope","dev","A","337"}'' as ope_dev_a_0337,--緊急補液量
pm.device_set_info#>>''{"ope","dev","A","185"}'' as ope_dev_a_0185,--HDF速度操作範囲上限前補液
pm.device_set_info#>>''{"ope","dev","A","186"}'' as ope_dev_a_0186,--HF速度操作範囲上限前補液
pm.device_set_info#>>''{"ope","dev","A","396"}'' as ope_dev_a_0396,--OHDF速度操作範囲上限前補液
pm.device_set_info#>>''{"ope","dev","A","397"}'' as ope_dev_a_0397,--OHF速度操作範囲上限前補液
pm.device_set_info#>>''{"ope","dev","A","384"}'' as ope_dev_a_0384,--AFBF補液比率使用選択
pm.device_set_info#>>''{"ope","dev","A","385"}'' as ope_dev_a_0385,--AFBF補液比率
pm.device_set_info#>>''{"ope","dev","A","386"}'' as ope_dev_a_0386,--AFBF速度操作範囲上限
pm.device_set_info#>>''{"ope","dev","A","387"}'' as ope_dev_a_0387,--AFBF速度操作範囲下限
pm.device_set_info#>>''{"ope","dev","A","472"}'' as ope_dev_a_0472,--TMP閾値　速度低下,
pm.device_set_info#>>''{"ope","dev","A","473"}'' as ope_dev_a_0473,--TMP閾値　速度復帰,
pm.device_set_info#>>''{"ope","dev","A","474"}'' as ope_dev_a_0474,--速度変化率　速度低下,
pm.device_set_info#>>''{"ope","dev","A","475"}'' as ope_dev_a_0475,--速度変化率　速度復帰
pm.device_set_info#>>''{"ope","dev","B","37"}'' as ope_dev_b_0037,--HD+補液補正警報上限値
pm.device_set_info#>>''{"ope","dev","B","38"}'' as ope_dev_b_0038,--HD+補液補正警報下限値
pm.device_set_info#>>''{"ope","dev","B","39"}'' as ope_dev_b_0039,--補液比率（後補液）
pm.device_set_info#>>''{"ope","dev","B","40"}'' as ope_dev_b_0040,--濾過率（後補液）
pm.device_set_info#>>''{"ope","dev","B","30"}'' as ope_dev_b_0030,--HD+補液速度操作範囲上限前補液
pm.device_set_info#>>''{"ope","dev","B","31"}'' as ope_dev_b_0031,--HDF速度操作範囲上限後補液
pm.device_set_info#>>''{"ope","dev","B","32"}'' as ope_dev_b_0032,--HF速度操作範囲上限後補液
pm.device_set_info#>>''{"ope","dev","B","33"}'' as ope_dev_b_0033,--HD+補液速度操作範囲上限後補液
pm.device_set_info#>>''{"ope","dev","B","34"}'' as ope_dev_b_0034,--OHDF速度操作範囲上限後補液
pm.device_set_info#>>''{"ope","dev","B","35"}'' as ope_dev_b_0035,--OHF速度操作範囲上限後補液
pm.device_set_info#>>''{"ope","dev","C","91"}'' as ope_dev_c_0091,--ヘマトクリット（Ht）
pm.device_set_info#>>''{"ope","dev","C","92"}'' as ope_dev_c_0092,--総タンパク（TP）
pm.device_set_info#>>''{"pri","dev","A","370"}'' as pri_dev_a_0370,--自動回収_使用液量
pm.device_set_info#>>''{"pri","dev","A","371"}'' as pri_dev_a_0371,--自動回収_流速
pm.device_set_info#>>''{"pri","dev","A","372"}'' as pri_dev_a_0372,--自動回収_血液判別器による終了選択
pm.device_set_info#>>''{"pri","pat","A","219"}'' as pri_pat_a_0219,--プライミング補助動脈充填液量
pm.device_set_info#>>''{"pri","pat","A","220"}'' as pri_pat_a_0220,--プライミング補助動脈充填流速
pm.device_set_info#>>''{"pri","pat","A","225"}'' as pri_pat_a_0225,--プライミング補助動脈充填後継続の有無
pm.device_set_info#>>''{"pri","pat","A","221"}'' as pri_pat_a_0221,--プライミング補助静脈充填液量
pm.device_set_info#>>''{"pri","pat","A","222"}'' as pri_pat_a_0222,--プライミング補助静脈充填流速
pm.device_set_info#>>''{"pri","pat","A","226"}'' as pri_pat_a_0226,--プライミング補助静脈充填後継続の有無
pm.device_set_info#>>''{"pri","pat","A","223"}'' as pri_pat_a_0223,--プライミング補助気泡抜き液量
pm.device_set_info#>>''{"pri","pat","A","224"}'' as pri_pat_a_0224,--プライミング補助気泡抜き流速
pm.device_set_info#>>''{"pri","pat","A","227"}'' as pri_pat_a_0227,--プライミング補助気泡抜き間欠動作選択
pm.device_set_info#>>''{"pri","pat","A","228"}'' as pri_pat_a_0228,--プライミング補助液交換量
pm.device_set_info#>>''{"pri","pat","A","229"}'' as pri_pat_a_0229,--プライミング補助間欠動作動作時間
pm.device_set_info#>>''{"pri","pat","A","230"}'' as pri_pat_a_0230,--プライミング補助間欠動作停止時間
pm.device_set_info#>>''{"pri","pat","A","232"}'' as pri_pat_a_0232,--自動プライミング落差時間
pm.device_set_info#>>''{"pri","pat","A","238"}'' as pri_pat_a_0238,--自動プライミング総量
pm.device_set_info#>>''{"pri","pat","A","231"}'' as pri_pat_a_0231,--自動プライミング開始時間
pm.device_set_info#>>''{"pri","pat","A","233"}'' as pri_pat_a_0233,--自動プライミング送液液量
pm.device_set_info#>>''{"pri","pat","A","234"}'' as pri_pat_a_0234,--自動プライミング送液流速1回目
pm.device_set_info#>>''{"pri","pat","A","235"}'' as pri_pat_a_0235,--自動プライミング送液流速2回目以降
pm.device_set_info#>>''{"pri","pat","A","236"}'' as pri_pat_a_0236,--自動プライミング循環流速
pm.device_set_info#>>''{"pri","pat","A","237"}'' as pri_pat_a_0237,--自動プライミング循環時間
pm.device_set_info#>>''{"pri","pat","B","51"}'' as pri_pat_b_0051,--オンラインプライミング_ダイアライザ気泡抜き時間_後補液
pm.device_set_info#>>''{"pri","pat","B","32"}'' as pri_pat_b_0032,--オンラインプライミング_動脈チャンバ液面作成時間_前補液
pm.device_set_info#>>''{"pri","pat","B","52"}'' as pri_pat_b_0052,--オンラインプライミング_動脈チャンバ液面作成時間_後補液
pm.device_set_info#>>''{"pri","pat","B","33"}'' as pri_pat_b_0033,--オンラインプライミング_循環洗浄時間_前補液
pm.device_set_info#>>''{"pri","pat","B","53"}'' as pri_pat_b_0053,--オンラインプライミング_循環洗浄時間_後補液
pm.device_set_info#>>''{"war","dev","A","240"}'' as war_dev_a_0240,--TMP監視モード
pm.device_set_info#>>''{"war","dev","A","100"}'' as war_dev_a_0100,--HD/ECUM静脈圧自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","101"}'' as war_dev_a_0101,--HD/ECUM静脈圧自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","102"}'' as war_dev_a_0102,--HD/ECUM静脈圧自動設定警報限界上限
pm.device_set_info#>>''{"war","dev","A","103"}'' as war_dev_a_0103,--HD/ECUM静脈圧自動設定警報限界下限
pm.device_set_info#>>''{"war","dev","A","104"}'' as war_dev_a_0104,--HD/ECUM静脈圧固定警報上限
pm.device_set_info#>>''{"war","dev","A","105"}'' as war_dev_a_0105,--HD/ECUM静脈圧固定警報下限
pm.device_set_info#>>''{"war","dev","A","152"}'' as war_dev_a_0152,--HD/ECUMダイアライザ入口圧自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","153"}'' as war_dev_a_0153,--HD/ECUMダイアライザ入口圧自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","154"}'' as war_dev_a_0154,--HD/ECUMダイアライザ入口圧自動設定警報限界上限
pm.device_set_info#>>''{"war","dev","A","155"}'' as war_dev_a_0155,--HD/ECUMダイアライザ入口圧自動設定警報限界下限
pm.device_set_info#>>''{"war","dev","A","156"}'' as war_dev_a_0156,--HD/ECUMダイアライザ入口圧固定警報上限
pm.device_set_info#>>''{"war","dev","A","157"}'' as war_dev_a_0157,--HD/ECUMダイアライザ入口圧固定警報下限
pm.device_set_info#>>''{"war","dev","A","112"}'' as war_dev_a_0112,--HD/ECUM液圧自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","113"}'' as war_dev_a_0113,--HD/ECUM液圧自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","114"}'' as war_dev_a_0114,--HD/ECUM液圧自動設定警報限界上限
pm.device_set_info#>>''{"war","dev","A","115"}'' as war_dev_a_0115,--HD/ECUM液圧自動設定警報限界下限
pm.device_set_info#>>''{"war","dev","A","116"}'' as war_dev_a_0116,--HD/ECUM液圧固定警報上限
pm.device_set_info#>>''{"war","dev","A","117"}'' as war_dev_a_0117,--HD/ECUM液圧固定警報下限
pm.device_set_info#>>''{"war","dev","A","128"}'' as war_dev_a_0128,--HD/ECUMTMP自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","129"}'' as war_dev_a_0129,--HD/ECUMTMP自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","130"}'' as war_dev_a_0130,--HD/ECUMTMP自動設定警報限界上限
pm.device_set_info#>>''{"war","dev","A","131"}'' as war_dev_a_0131,--HD/ECUMTMP自動設定警報限界下限
pm.device_set_info#>>''{"war","dev","A","132"}'' as war_dev_a_0132,--HD/ECUMTMP固定警報上限
pm.device_set_info#>>''{"war","dev","A","133"}'' as war_dev_a_0133,--HD/ECUMTMP固定警報下限
pm.device_set_info#>>''{"war","dev","A","126"}'' as war_dev_a_0126,--HD/ECUMTMP自動追従警報幅上限
pm.device_set_info#>>''{"war","dev","A","127"}'' as war_dev_a_0127,--HD/ECUMTMP自動追従警報幅下限
pm.device_set_info#>>''{"war","dev","A","146"}'' as war_dev_a_0146,--HD/ECUMダイアライザ差圧自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","147"}'' as war_dev_a_0147,--HD/ECUMダイアライザ差圧自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","148"}'' as war_dev_a_0148,--HD/ECUMダイアライザ差圧固定警報上限
pm.device_set_info#>>''{"war","dev","A","149"}'' as war_dev_a_0149,--HD/ECUMダイアライザ差圧固定警報下限
pm.device_set_info#>>''{"war","dev","A","106"}'' as war_dev_a_0106,--HDF/HF静脈圧自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","107"}'' as war_dev_a_0107,--HDF/HF静脈圧自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","158"}'' as war_dev_a_0158,--HDF/HFダイアライザ入口圧自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","159"}'' as war_dev_a_0159,--HDF/HFダイアライザ入口圧自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","118"}'' as war_dev_a_0118,--HDF/HF液圧自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","119"}'' as war_dev_a_0119,--HDF/HF液圧自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","136"}'' as war_dev_a_0136,--HDF/HFTMP自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","137"}'' as war_dev_a_0137,--HDF/HFTMP自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","134"}'' as war_dev_a_0134,--HDF/HFTMP自動追従警報幅上限
pm.device_set_info#>>''{"war","dev","A","135"}'' as war_dev_a_0135,--HDF/HFTMP自動追従警報幅下限
pm.device_set_info#>>''{"war","dev","A","150"}'' as war_dev_a_0150,--HDF/HFダイアライザ差圧自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","151"}'' as war_dev_a_0151,--HDF/HFダイアライザ差圧自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","110"}'' as war_dev_a_0110,--SN静脈圧固定警報上限
pm.device_set_info#>>''{"war","dev","A","111"}'' as war_dev_a_0111,--SN静脈圧固定警報下限
pm.device_set_info#>>''{"war","dev","A","162"}'' as war_dev_a_0162,--SNダイアライザ入口圧固定警報上限
pm.device_set_info#>>''{"war","dev","A","163"}'' as war_dev_a_0163,--SNダイアライザ入口圧固定警報下限
pm.device_set_info#>>''{"war","dev","A","120"}'' as war_dev_a_0120,--SN液圧自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","121"}'' as war_dev_a_0121,--SN液圧自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","122"}'' as war_dev_a_0122,--SN液圧自動設定警報限界上限
pm.device_set_info#>>''{"war","dev","A","123"}'' as war_dev_a_0123,--SN液圧自動設定警報限界下限
pm.device_set_info#>>''{"war","dev","A","124"}'' as war_dev_a_0124,--SN液圧固定警報上限
pm.device_set_info#>>''{"war","dev","A","125"}'' as war_dev_a_0125,--SN液圧固定警報下限
pm.device_set_info#>>''{"war","dev","A","140"}'' as war_dev_a_0140,--SNTMP自動設定警報幅上限
pm.device_set_info#>>''{"war","dev","A","141"}'' as war_dev_a_0141,--SNTMP自動設定警報幅下限
pm.device_set_info#>>''{"war","dev","A","142"}'' as war_dev_a_0142,--SNTMP自動設定警報限界上限
pm.device_set_info#>>''{"war","dev","A","143"}'' as war_dev_a_0143,--SNTMP自動設定警報限界下限
pm.device_set_info#>>''{"war","dev","A","144"}'' as war_dev_a_0144,--SNTMP固定警報上限
pm.device_set_info#>>''{"war","dev","A","145"}'' as war_dev_a_0145,--SNTMP固定警報下限
pm.device_set_info#>>''{"war","dev","A","138"}'' as war_dev_a_0138,--SNTMP自動追従警報幅上限
pm.device_set_info#>>''{"war","dev","A","139"}'' as war_dev_a_0139,--SNTMP自動追従警報幅下限
pm.device_set_info#>>''{"war","dev","A","108"}'' as war_dev_a_0108,--準備回収静脈圧固定警報上限
pm.device_set_info#>>''{"war","dev","A","109"}'' as war_dev_a_0109,--準備回収静脈圧固定警報下限
pm.device_set_info#>>''{"war","dev","A","160"}'' as war_dev_a_0160,--準備回収ダイアライザ入口圧固定警報上限
pm.device_set_info#>>''{"war","dev","A","161"}'' as war_dev_a_0161,--準備回収ダイアライザ入口圧固定警報下限
pm.device_set_info#>>''{"war","dev","A","254"}'' as war_dev_a_0254,--Na濃度自動警報幅上限値
pm.device_set_info#>>''{"war","dev","A","255"}'' as war_dev_a_0255,--Na濃度自動警報幅下限値
pm.device_set_info#>>''{"war","dev","A","256"}'' as war_dev_a_0256,--Na濃度固定警報幅上限値
pm.device_set_info#>>''{"war","dev","A","257"}'' as war_dev_a_0257,--Na濃度固定警報幅下限値
pm.device_set_info#>>''{"war","dev","A","242"}'' as war_dev_a_0242,--静脈圧自動設定警報監視有無
pm.device_set_info#>>''{"war","dev","A","243"}'' as war_dev_a_0243,--ダイアライザー血液入口圧自動設定警報監視有無
pm.device_set_info#>>''{"war","dev","A","244"}'' as war_dev_a_0244,--透析液圧自動設定警報監視有無
pm.device_set_info#>>''{"war","dev","A","245"}'' as war_dev_a_0245,--ＴＭＰ自動設定警報監視有無
pm.device_set_info#>>''{"war","dev","A","246"}'' as war_dev_a_0246,--差圧自動設定警報監視有無
pm.device_set_info#>>''{"war","dev","A","247"}'' as war_dev_a_0247,--Ｎａ濃度自動設定警報監視有無
pm.device_set_info#>>''{"lap","dev","A","468"}'' as lap_dev_a_0468,--VA確認報知基準値(静的静脈圧)
pm.device_set_info#>>''{"lap","dev","A","469"}'' as lap_dev_a_0469,--VA確認報知基準値(アクセス内圧力比率)
pm.device_set_info#>>''{"lap","dev","A","470"}'' as lap_dev_a_0470,--静的静脈圧記録 自動実施選択
pm.device_set_info#>>''{"lap","dev","A","471"}'' as lap_dev_a_0471,--血圧測定 自動実施選択
om.ind_device_set_info#>>''{"ihdf","dev","A","201"}'' as ihdf_dev_a_0201,--I-HDF_補液速度
om.ind_device_set_info#>>''{"ihdf","dev","A","203"}'' as ihdf_dev_a_0203,--I-HDF_補液開始時間
om.ind_device_set_info#>>''{"ihdf","dev","A","200"}'' as ihdf_dev_a_0200,--I-HDF_補液量設定
om.ind_device_set_info#>>''{"ihdf","dev","A","204"}'' as ihdf_dev_a_0204,--I-HDF_除水再開時間
om.ind_device_set_info#>>''{"ihdf","dev","A","202"}'' as ihdf_dev_a_0202,--I-HDF_補液周期
om.ind_device_set_info#>>''{"ihdf","dev","A","205"}'' as ihdf_dev_a_0205,--I-HDF_総補液量上限
om.ind_device_set_info#>>''{"ihdf","dev","A","432"}'' as ihdf_dev_a_0432,--I-HDFプログラム使用選択
om.ind_device_set_info#>>''{"ihdf","dev","A","433"}'' as ihdf_dev_a_0433,--予定補液回数
om.ind_device_set_info#>>''{"ihdf","dev","A","434"}'' as ihdf_dev_a_0434,--補液バランス制限
om.ind_device_set_info#>>''{"ihdf","dev","A","435"}'' as ihdf_dev_a_0435,--補液量01
om.ind_device_set_info#>>''{"ihdf","dev","A","436"}'' as ihdf_dev_a_0436,--補液量02
om.ind_device_set_info#>>''{"ihdf","dev","A","437"}'' as ihdf_dev_a_0437,--補液量03
om.ind_device_set_info#>>''{"ihdf","dev","A","438"}'' as ihdf_dev_a_0438,--補液量04
om.ind_device_set_info#>>''{"ihdf","dev","A","439"}'' as ihdf_dev_a_0439,--補液量05
om.ind_device_set_info#>>''{"ihdf","dev","A","440"}'' as ihdf_dev_a_0440,--補液量06
om.ind_device_set_info#>>''{"ihdf","dev","A","441"}'' as ihdf_dev_a_0441,--補液量07
om.ind_device_set_info#>>''{"ihdf","dev","A","442"}'' as ihdf_dev_a_0442,--補液量08
om.ind_device_set_info#>>''{"ihdf","dev","A","443"}'' as ihdf_dev_a_0443,--補液量09
om.ind_device_set_info#>>''{"ihdf","dev","A","444"}'' as ihdf_dev_a_0444,--補液量10
om.ind_device_set_info#>>''{"ihdf","dev","A","445"}'' as ihdf_dev_a_0445,--補液量11
om.ind_device_set_info#>>''{"ihdf","dev","A","446"}'' as ihdf_dev_a_0446,--補液量12
om.ind_device_set_info#>>''{"ihdf","dev","A","447"}'' as ihdf_dev_a_0447,--補液量13
om.ind_device_set_info#>>''{"ihdf","dev","A","448"}'' as ihdf_dev_a_0448,--補液量14
om.ind_device_set_info#>>''{"ihdf","dev","A","449"}'' as ihdf_dev_a_0449,--補液量15
om.ind_device_set_info#>>''{"ihdf","dev","A","450"}'' as ihdf_dev_a_0450,--補液量16
om.ind_device_set_info#>>''{"ihdf","dev","A","451"}'' as ihdf_dev_a_0451,--回収量01
om.ind_device_set_info#>>''{"ihdf","dev","A","452"}'' as ihdf_dev_a_0452,--回収量02
om.ind_device_set_info#>>''{"ihdf","dev","A","453"}'' as ihdf_dev_a_0453,--回収量03
om.ind_device_set_info#>>''{"ihdf","dev","A","454"}'' as ihdf_dev_a_0454,--回収量04
om.ind_device_set_info#>>''{"ihdf","dev","A","455"}'' as ihdf_dev_a_0455,--回収量05
om.ind_device_set_info#>>''{"ihdf","dev","A","456"}'' as ihdf_dev_a_0456,--回収量06
om.ind_device_set_info#>>''{"ihdf","dev","A","457"}'' as ihdf_dev_a_0457,--回収量07
om.ind_device_set_info#>>''{"ihdf","dev","A","458"}'' as ihdf_dev_a_0458,--回収量08
om.ind_device_set_info#>>''{"ihdf","dev","A","459"}'' as ihdf_dev_a_0459,--回収量09
om.ind_device_set_info#>>''{"ihdf","dev","A","460"}'' as ihdf_dev_a_0460,--回収量10
om.ind_device_set_info#>>''{"ihdf","dev","A","461"}'' as ihdf_dev_a_0461,--回収量11
om.ind_device_set_info#>>''{"ihdf","dev","A","462"}'' as ihdf_dev_a_0462,--回収量12
om.ind_device_set_info#>>''{"ihdf","dev","A","463"}'' as ihdf_dev_a_0463,--回収量13
om.ind_device_set_info#>>''{"ihdf","dev","A","464"}'' as ihdf_dev_a_0464,--回収量14
om.ind_device_set_info#>>''{"ihdf","dev","A","465"}'' as ihdf_dev_a_0465,--回収量15
om.ind_device_set_info#>>''{"ihdf","dev","A","466"}'' as ihdf_dev_a_0466,--回収量16
om.ind_device_set_info#>>''{"qbqd","dev","A","430"}'' as qbqd_dev_a_0430,--QBプログラム電源
om.ind_device_set_info#>>''{"qbqd","dev","A","429"}'' as qbqd_dev_a_0429,--QB、QDプログラム最大ステップ数
om.ind_device_set_info#>>''{"qbqd","dev","A","400"}'' as qbqd_dev_a_0400,--QBプログラム血流量1
om.ind_device_set_info#>>''{"qbqd","dev","A","401"}'' as qbqd_dev_a_0401,--QBプログラム血流量2
om.ind_device_set_info#>>''{"qbqd","dev","A","402"}'' as qbqd_dev_a_0402,--QBプログラム血流量3
om.ind_device_set_info#>>''{"qbqd","dev","A","403"}'' as qbqd_dev_a_0403,--QBプログラム血流量4
om.ind_device_set_info#>>''{"qbqd","dev","A","404"}'' as qbqd_dev_a_0404,--QBプログラム血流量5
om.ind_device_set_info#>>''{"qbqd","dev","A","405"}'' as qbqd_dev_a_0405,--QBプログラム血流量6
om.ind_device_set_info#>>''{"qbqd","dev","A","406"}'' as qbqd_dev_a_0406,--QBプログラム血流量7
om.ind_device_set_info#>>''{"qbqd","dev","A","407"}'' as qbqd_dev_a_0407,--QBプログラム血流量8
om.ind_device_set_info#>>''{"qbqd","dev","A","408"}'' as qbqd_dev_a_0408,--QBプログラム血流量9
om.ind_device_set_info#>>''{"qbqd","dev","A","409"}'' as qbqd_dev_a_0409,--QBプログラム血流量10
om.ind_device_set_info#>>''{"qbqd","dev","A","431"}'' as qbqd_dev_a_0431,--QDプログラム電源
om.ind_device_set_info#>>''{"qbqd","dev","A","410"}'' as qbqd_dev_a_0410,--QDプログラム透析液流量1
om.ind_device_set_info#>>''{"qbqd","dev","A","411"}'' as qbqd_dev_a_0411,--QDプログラム透析液流量2
om.ind_device_set_info#>>''{"qbqd","dev","A","412"}'' as qbqd_dev_a_0412,--QDプログラム透析液流量3
om.ind_device_set_info#>>''{"qbqd","dev","A","413"}'' as qbqd_dev_a_0413,--QDプログラム透析液流量4
om.ind_device_set_info#>>''{"qbqd","dev","A","414"}'' as qbqd_dev_a_0414,--QDプログラム透析液流量5
om.ind_device_set_info#>>''{"qbqd","dev","A","415"}'' as qbqd_dev_a_0415,--QDプログラム透析液流量6
om.ind_device_set_info#>>''{"qbqd","dev","A","416"}'' as qbqd_dev_a_0416,--QDプログラム透析液流量7
om.ind_device_set_info#>>''{"qbqd","dev","A","417"}'' as qbqd_dev_a_0417,--QDプログラム透析液流量8
om.ind_device_set_info#>>''{"qbqd","dev","A","418"}'' as qbqd_dev_a_0418,--QDプログラム透析液流量9
om.ind_device_set_info#>>''{"qbqd","dev","A","419"}'' as qbqd_dev_a_0419,--QDプログラム透析液流量10
om.ind_device_set_info#>>''{"qbqd","dev","A","420"}'' as qbqd_dev_a_0420,--QB、QDプログラム切替時間1
om.ind_device_set_info#>>''{"qbqd","dev","A","421"}'' as qbqd_dev_a_0421,--QB、QDプログラム切替時間2
om.ind_device_set_info#>>''{"qbqd","dev","A","422"}'' as qbqd_dev_a_0422,--QB、QDプログラム切替時間3
om.ind_device_set_info#>>''{"qbqd","dev","A","423"}'' as qbqd_dev_a_0423,--QB、QDプログラム切替時間4
om.ind_device_set_info#>>''{"qbqd","dev","A","424"}'' as qbqd_dev_a_0424,--QB、QDプログラム切替時間5
om.ind_device_set_info#>>''{"qbqd","dev","A","425"}'' as qbqd_dev_a_0425,--QB、QDプログラム切替時間6
om.ind_device_set_info#>>''{"qbqd","dev","A","426"}'' as qbqd_dev_a_0426,--QB、QDプログラム切替時間7
om.ind_device_set_info#>>''{"qbqd","dev","A","427"}'' as qbqd_dev_a_0427,--QB、QDプログラム切替時間8
om.ind_device_set_info#>>''{"qbqd","dev","A","428"}'' as qbqd_dev_a_0428,--QB、QDプログラム切替時間9
om.ind_device_set_info#>>''{"ufr","dev","A","290"}'' as ufr_dev_a_0290,--ＵＦＲプログラム電源ＳＷ
om.ind_device_set_info#>>''{"ufr","dev","A","311"}'' as ufr_dev_a_0311,--ＵＦＲプログラム最終位置
om.ind_device_set_info#>>''{"ufr","dev","A","312"}'' as ufr_dev_a_0312,--ＵＦＲプログラムコース
om.ind_device_set_info#>>''{"ufr","dev","A","291"}'' as ufr_dev_a_0291,--治療モード１
om.ind_device_set_info#>>''{"ufr","dev","A","292"}'' as ufr_dev_a_0292,--治療モード２
om.ind_device_set_info#>>''{"ufr","dev","A","293"}'' as ufr_dev_a_0293,--治療モード３
om.ind_device_set_info#>>''{"ufr","dev","A","294"}'' as ufr_dev_a_0294,--治療モード４
om.ind_device_set_info#>>''{"ufr","dev","A","295"}'' as ufr_dev_a_0295,--治療モード５
om.ind_device_set_info#>>''{"ufr","dev","A","296"}'' as ufr_dev_a_0296,--治療モード６
om.ind_device_set_info#>>''{"ufr","dev","A","297"}'' as ufr_dev_a_0297,--治療モード７
om.ind_device_set_info#>>''{"ufr","dev","A","298"}'' as ufr_dev_a_0298,--治療モード８
om.ind_device_set_info#>>''{"ufr","dev","A","299"}'' as ufr_dev_a_0299,--治療モード９
om.ind_device_set_info#>>''{"ufr","dev","A","300"}'' as ufr_dev_a_0300,--治療モード１０
om.ind_device_set_info#>>''{"ufr","dev","A","301"}'' as ufr_dev_a_0301,--ＵＦＲプログラム指数１
om.ind_device_set_info#>>''{"ufr","dev","A","302"}'' as ufr_dev_a_0302,--ＵＦＲプログラム指数２
om.ind_device_set_info#>>''{"ufr","dev","A","303"}'' as ufr_dev_a_0303,--ＵＦＲプログラム指数３
om.ind_device_set_info#>>''{"ufr","dev","A","304"}'' as ufr_dev_a_0304,--ＵＦＲプログラム指数４
om.ind_device_set_info#>>''{"ufr","dev","A","305"}'' as ufr_dev_a_0305,--ＵＦＲプログラム指数５
om.ind_device_set_info#>>''{"ufr","dev","A","306"}'' as ufr_dev_a_0306,--ＵＦＲプログラム指数６
om.ind_device_set_info#>>''{"ufr","dev","A","307"}'' as ufr_dev_a_0307,--ＵＦＲプログラム指数７
om.ind_device_set_info#>>''{"ufr","dev","A","308"}'' as ufr_dev_a_0308,--ＵＦＲプログラム指数８
om.ind_device_set_info#>>''{"ufr","dev","A","309"}'' as ufr_dev_a_0309,--ＵＦＲプログラム指数９
om.ind_device_set_info#>>''{"ufr","dev","A","310"}'' as ufr_dev_a_0310,--ＵＦＲプログラム指数１０
om.ind_device_set_info#>>''{"ufr","dev","A","313"}'' as ufr_dev_a_0313,--ＵＦＲプログラム開始数値
om.ind_device_set_info#>>''{"ufr","dev","A","314"}'' as ufr_dev_a_0314,--ＵＦＲプログラム終了数値
om.ind_device_set_info#>>''{"ufr","dev","B","0"}'' as ufr_dev_b_0000,--UFRプログラム工程1の指数
om.ind_device_set_info#>>''{"ufr","dev","B","1"}'' as ufr_dev_b_0001,--UFRプログラム工程2の指数
om.ind_device_set_info#>>''{"ufr","dev","B","2"}'' as ufr_dev_b_0002,--UFRプログラム工程3の指数
om.ind_device_set_info#>>''{"ufr","dev","B","3"}'' as ufr_dev_b_0003,--UFRプログラム工程4の指数
om.ind_device_set_info#>>''{"ufr","dev","B","4"}'' as ufr_dev_b_0004,--UFRプログラム工程5の指数
om.ind_device_set_info#>>''{"ufr","dev","B","5"}'' as ufr_dev_b_0005,--UFRプログラム工程6の指数
om.ind_device_set_info#>>''{"ufr","dev","B","6"}'' as ufr_dev_b_0006,--UFRプログラム工程7の指数
om.ind_device_set_info#>>''{"ufr","dev","B","7"}'' as ufr_dev_b_0007,--UFRプログラム工程8の指数
om.ind_device_set_info#>>''{"ufr","dev","B","8"}'' as ufr_dev_b_0008,--UFRプログラム工程9の指数
om.ind_device_set_info#>>''{"ufr","dev","B","9"}'' as ufr_dev_b_0009,--UFRプログラム工程10の指数
om.ind_device_set_info#>>''{"na","dev","A","315"}'' as na_dev_a_0315,--Na注入プログラム電源ＳＷ
om.ind_device_set_info#>>''{"na","dev","A","326"}'' as na_dev_a_0326,--Na注入プログラム切替時間
om.ind_device_set_info#>>''{"na","dev","A","328"}'' as na_dev_a_0328,--Na注入プログラムコース
om.ind_device_set_info#>>''{"na","dev","A","327"}'' as na_dev_a_0327,--Na注入プログラム　ＵＦＲプロとの連動選択
om.ind_device_set_info#>>''{"na","dev","A","316"}'' as na_dev_a_0316,--Na注入プログラム設定１
om.ind_device_set_info#>>''{"na","dev","A","317"}'' as na_dev_a_0317,--Na注入プログラム設定２
om.ind_device_set_info#>>''{"na","dev","A","318"}'' as na_dev_a_0318,--Na注入プログラム設定３
om.ind_device_set_info#>>''{"na","dev","A","319"}'' as na_dev_a_0319,--Na注入プログラム設定４
om.ind_device_set_info#>>''{"na","dev","A","320"}'' as na_dev_a_0320,--Na注入プログラム設定５
om.ind_device_set_info#>>''{"na","dev","A","321"}'' as na_dev_a_0321,--Na注入プログラム設定６
om.ind_device_set_info#>>''{"na","dev","A","322"}'' as na_dev_a_0322,--Na注入プログラム設定７
om.ind_device_set_info#>>''{"na","dev","A","323"}'' as na_dev_a_0323,--Na注入プログラム設定８
om.ind_device_set_info#>>''{"na","dev","A","324"}'' as na_dev_a_0324,--Na注入プログラム設定９
om.ind_device_set_info#>>''{"na","dev","A","325"}'' as na_dev_a_0325,--Na注入プログラム設定１０
om.ind_device_set_info#>>''{"na","dev","A","329"}'' as na_dev_a_0329,--Na注入プログラム開始数値
om.ind_device_set_info#>>''{"na","dev","A","330"}'' as na_dev_a_0330,--Na注入プログラム終了数値
om.ind_device_set_info#>>''{"na","dev","A","184"}'' as na_dev_a_0184,--Na注入濃度操作範囲上限
om.ind_device_set_info#>>''{"bvufc","dev","A","196"}'' as bvufc_dev_a_0196,--BV-UFC使用選択
om.ind_device_set_info#>>''{"bvufc","dev","A","197"}'' as bvufc_dev_a_0197,--UFC期間除水速度上限
om.ind_device_set_info#>>''{"bvufc","dev","A","198"}'' as bvufc_dev_a_0198,--UFC期間除水速度下限
om.ind_device_set_info#>>''{"bvufc","dev","A","199"}'' as bvufc_dev_a_0199,--開始期間 時間
om.ind_device_set_info#>>''{"bvufc","dev","A","206"}'' as bvufc_dev_a_0206,--開始期間 除水速度倍率
om.ind_device_set_info#>>''{"bvufc","dev","A","207"}'' as bvufc_dev_a_0207,--固定倍率除水期間 時間
om.ind_device_set_info#>>''{"bvufc","dev","A","208"}'' as bvufc_dev_a_0208,--固定倍率除水期間 除水速度倍率
om.ind_device_set_info#>>''{"bvufc","dev","A","209"}'' as bvufc_dev_a_0209,--固定倍率除水終了条件　最高血圧
om.ind_device_set_info#>>''{"bvufc","dev","A","210"}'' as bvufc_dev_a_0210,--固定倍率除水終了条件　脈拍
om.ind_device_set_info#>>''{"bvufc","dev","A","248"}'' as bvufc_dev_a_0248,--固定倍率除水終了条件　ΔBV
om.ind_device_set_info#>>''{"bvufc","dev","A","249"}'' as bvufc_dev_a_0249,--終了前期間 時間
om.ind_device_set_info#>>''{"bvufc","dev","A","271"}'' as bvufc_dev_a_0271,--開始時ΔBV基準値 
om.ind_device_set_info#>>''{"bvufc","dev","A","272"}'' as bvufc_dev_a_0272,--ΔBV基準線　指数1
om.ind_device_set_info#>>''{"bvufc","dev","A","273"}'' as bvufc_dev_a_0273,--ΔBV基準線　指数2
om.ind_device_set_info#>>''{"bvufc","dev","A","274"}'' as bvufc_dev_a_0274,--ΔBV基準線　指数3
om.ind_device_set_info#>>''{"bvufc","dev","A","275"}'' as bvufc_dev_a_0275,--終了時ΔBV基準値
om.ind_device_set_info#>>''{"dia","dev","A","282"}'' as dia_dev_a_0282,--透析量プログラム使用選択
om.ind_device_set_info#>>''{"dia","dev","A","288"}'' as dia_dev_a_0288,--目標Kt/V
om.ind_device_set_info#>>''{"dia","dev","A","ord_no"}'' as dia_dev_a_ord_no,--検査日オーダ番号
om.ind_device_set_info#>>''{"dc","dev","A","340"}'' as dc_dev_a_0340,--透析液濃度プログラム使用選択
om.ind_device_set_info#>>''{"dc","dev","A","368"}'' as dc_dev_a_0368,--濃度プログラム　ＵＦＲプロとの連動選択
om.ind_device_set_info#>>''{"dc","dev","A","367"}'' as dc_dev_a_0367,--濃度プログラム切替時間
om.ind_device_set_info#>>''{"dc","dev","A","361"}'' as dc_dev_a_0361,--透析液濃度プログラムステップ切替無し　コース
om.ind_device_set_info#>>''{"dc","dev","A","341"}'' as dc_dev_a_0341,--透析液濃度プログラム設定１
om.ind_device_set_info#>>''{"dc","dev","A","342"}'' as dc_dev_a_0342,--透析液濃度プログラム設定２
om.ind_device_set_info#>>''{"dc","dev","A","343"}'' as dc_dev_a_0343,--透析液濃度プログラム設定３
om.ind_device_set_info#>>''{"dc","dev","A","344"}'' as dc_dev_a_0344,--透析液濃度プログラム設定４
om.ind_device_set_info#>>''{"dc","dev","A","345"}'' as dc_dev_a_0345,--透析液濃度プログラム設定５
om.ind_device_set_info#>>''{"dc","dev","A","346"}'' as dc_dev_a_0346,--透析液濃度プログラム設定６
om.ind_device_set_info#>>''{"dc","dev","A","347"}'' as dc_dev_a_0347,--透析液濃度プログラム設定７
om.ind_device_set_info#>>''{"dc","dev","A","348"}'' as dc_dev_a_0348,--透析液濃度プログラム設定８
om.ind_device_set_info#>>''{"dc","dev","A","349"}'' as dc_dev_a_0349,--透析液濃度プログラム設定９
om.ind_device_set_info#>>''{"dc","dev","A","350"}'' as dc_dev_a_0350,--透析液濃度プログラム設定１０
om.ind_device_set_info#>>''{"dc","dev","A","362"}'' as dc_dev_a_0362,--透析液濃度プログラム開始数値
om.ind_device_set_info#>>''{"dc","dev","A","363"}'' as dc_dev_a_0363,--透析液濃度プログラム終了数値
om.ind_device_set_info#>>''{"dc","dev","A","364"}'' as dc_dev_a_0364,--Ｂ液濃度プログラムステップ切替無し　コース
om.ind_device_set_info#>>''{"dc","dev","A","351"}'' as dc_dev_a_0351,--Ｂ液濃度プログラム設定１
om.ind_device_set_info#>>''{"dc","dev","A","352"}'' as dc_dev_a_0352,--Ｂ液濃度プログラム設定２
om.ind_device_set_info#>>''{"dc","dev","A","353"}'' as dc_dev_a_0353,--Ｂ液濃度プログラム設定３
om.ind_device_set_info#>>''{"dc","dev","A","354"}'' as dc_dev_a_0354,--Ｂ液濃度プログラム設定４
om.ind_device_set_info#>>''{"dc","dev","A","355"}'' as dc_dev_a_0355,--Ｂ液濃度プログラム設定５
om.ind_device_set_info#>>''{"dc","dev","A","356"}'' as dc_dev_a_0356,--Ｂ液濃度プログラム設定６
om.ind_device_set_info#>>''{"dc","dev","A","357"}'' as dc_dev_a_0357,--Ｂ液濃度プログラム設定７
om.ind_device_set_info#>>''{"dc","dev","A","358"}'' as dc_dev_a_0358,--Ｂ液濃度プログラム設定８
om.ind_device_set_info#>>''{"dc","dev","A","359"}'' as dc_dev_a_0359,--Ｂ液濃度プログラム設定９
om.ind_device_set_info#>>''{"dc","dev","A","360"}'' as dc_dev_a_0360,--Ｂ液濃度プログラム設定１０
om.ind_device_set_info#>>''{"dc","dev","A","365"}'' as dc_dev_a_0365,--Ｂ液濃度プログラム開始数値
om.ind_device_set_info#>>''{"dc","dev","A","366"}'' as dc_dev_a_0366,--Ｂ液濃度プログラム終了数値
om.ind_device_set_info#>>''{"dc","dev","B","20"}'' as dc_dev_b_0020,--A液濃度プログラム工程1のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","21"}'' as dc_dev_b_0021,--A液濃度プログラム工程2のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","22"}'' as dc_dev_b_0022,--A液濃度プログラム工程3のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","23"}'' as dc_dev_b_0023,--A液濃度プログラム工程4のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","24"}'' as dc_dev_b_0024,--A液濃度プログラム工程5のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","25"}'' as dc_dev_b_0025,--A液濃度プログラム工程6のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","26"}'' as dc_dev_b_0026,--A液濃度プログラム工程7のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","27"}'' as dc_dev_b_0027,--A液濃度プログラム工程8のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","28"}'' as dc_dev_b_0028,--A液濃度プログラム工程9のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","29"}'' as dc_dev_b_0029,--A液濃度プログラム工程10のA液濃度
om.ind_device_set_info#>>''{"dc","dev","B","10"}'' as dc_dev_b_0010,--B液濃度プログラム工程1のB液濃度
om.ind_device_set_info#>>''{"dc","dev","B","11"}'' as dc_dev_b_0011,--B液濃度プログラム工程2のB液濃度
om.ind_device_set_info#>>''{"dc","dev","B","12"}'' as dc_dev_b_0012,--B液濃度プログラム工程3のB液濃度
om.ind_device_set_info#>>''{"dc","dev","B","13"}'' as dc_dev_b_0013,--B液濃度プログラム工程4のB液濃度
om.ind_device_set_info#>>''{"dc","dev","B","14"}'' as dc_dev_b_0014,--B液濃度プログラム工程5のB液濃度
om.ind_device_set_info#>>''{"dc","dev","B","15"}'' as dc_dev_b_0015,--B液濃度プログラム工程6のB液濃度
om.ind_device_set_info#>>''{"dc","dev","B","16"}'' as dc_dev_b_0016,--B液濃度プログラム工程7のB液濃度
om.ind_device_set_info#>>''{"dc","dev","B","17"}'' as dc_dev_b_0017,--B液濃度プログラム工程8のB液濃度
om.ind_device_set_info#>>''{"dc","dev","B","18"}'' as dc_dev_b_0018,--B液濃度プログラム工程9のB液濃度
om.ind_device_set_info#>>''{"dc","dev","B","19"}'' as dc_dev_b_0019,--B液濃度プログラム工程10のB液濃度
pm.host_notification_info#>>''{"blood_flow","judge"}'' as blood_flow_judge, --ホスト監視血流量監視フラグ
pm.host_notification_info#>>''{"blood_flow","upper"}'' as blood_flow_upper, --ホスト監視血流量上限
pm.host_notification_info#>>''{"blood_flow","lower"}'' as blood_flow_lower, --ホスト監視血流量下限
pm.host_notification_info#>>''{"ip_speed","judge"}'' as ip_speed_judge, --ホスト監視IP速度監視フラグ
pm.host_notification_info#>>''{"ip_speed","upper"}'' as ip_speed_upper, --ホスト監視IP速度上限
pm.host_notification_info#>>''{"ip_speed","lower"}'' as ip_speed_lower, --ホスト監視IP速度下限
pm.host_notification_info#>>''{"ufr","judge"}'' as ufr_judge, --ホスト監視除水速度監視フラグ
pm.host_notification_info#>>''{"ufr","upper"}'' as ufr_upper, --ホスト監視除水速度上限
pm.host_notification_info#>>''{"ufr","lower"}'' as ufr_lower, --ホスト監視除水速度下限
pm.host_notification_info#>>''{"bp_max","judge"}'' as bp_max_judge, --ホスト監視最高血圧監視フラグ
pm.host_notification_info#>>''{"bp_max","upper"}'' as bp_max_upper, --ホスト監視最高血圧上限
pm.host_notification_info#>>''{"bp_max","lower"}'' as bp_max_lower, --ホスト監視最高血圧下限
pm.host_notification_info#>>''{"bp_min","judge"}'' as bp_min_judge, --ホスト監視最低血圧監視フラグ
pm.host_notification_info#>>''{"bp_min","upper"}'' as bp_min_upper, --ホスト監視最低血圧上限
pm.host_notification_info#>>''{"bp_min","lower"}'' as bp_min_lower, --ホスト監視最低血圧下限
pm.host_notification_info#>>''{"bp_ave","judge"}'' as bp_ave_judge, --ホスト監視平均血圧監視フラグ
pm.host_notification_info#>>''{"bp_ave","upper"}'' as bp_ave_upper, --ホスト監視平均血圧上限
pm.host_notification_info#>>''{"bp_ave","lower"}'' as bp_ave_lower, --ホスト監視平均血圧下限
pm.host_notification_info#>>''{"pulse","judge"}'' as pulse_judge, --ホスト監視脈拍監視フラグ
pm.host_notification_info#>>''{"pulse","upper"}'' as pulse_upper, --ホスト監視脈拍上限
pm.host_notification_info#>>''{"pulse","lower"}'' as pulse_lower, --ホスト監視脈拍下限
pm.host_notification_info#>>''{"vp","judge"}'' as vp_judge, --ホスト監視静脈圧監視フラグ
pm.host_notification_info#>>''{"vp","upper"}'' as vp_upper, --ホスト監視静脈圧上限
pm.host_notification_info#>>''{"vp","lower"}'' as vp_lower, --ホスト監視静脈圧下限
pm.host_notification_info#>>''{"ap","judge"}'' as ap_judge, --ホスト監視動脈圧監視フラグ
pm.host_notification_info#>>''{"ap","upper"}'' as ap_upper, --ホスト監視動脈圧上限
pm.host_notification_info#>>''{"ap","lower"}'' as ap_lower, --ホスト監視動脈圧下限
pm.host_notification_info#>>''{"na_conc","judge"}'' as na_conc_judge, --ホスト監視Na濃度監視フラグ
pm.host_notification_info#>>''{"na_conc","upper"}'' as na_conc_upper, --ホスト監視Na濃度上限
pm.host_notification_info#>>''{"na_conc","lower"}'' as na_conc_lower, --ホスト監視Na濃度下限
pm.host_notification_info#>>''{"dialys_temp","judge"}'' as dialys_temp_judge, --ホスト監視透析液温度監視フラグ
pm.host_notification_info#>>''{"dialys_temp","upper"}'' as dialys_temp_upper, --ホスト監視透析液温度上限
pm.host_notification_info#>>''{"dialys_temp","lower"}'' as dialys_temp_lower, --ホスト監視透析液温度下限
pm.host_notification_info#>>''{"care_i","judge"}'' as care_i_judge, --ホスト監視血圧未測定時報知監視フラグ
pm.host_notification_info#>>''{"care_i","interval"}'' as care_i_interval --ホスト監視ケア報知

from pat_main pm left outer join 
(select pat_id,ind_device_set_info from ord_main where facility_cd = @facilityCd and is_del=''0'' and pat_id=@patId and treat_date>to_char(now(), ''YYYYMMDD'') order by treat_date asc  LIMIT 1 OFFSET 0) om ON pm.pat_id=om.pat_id
where pm.pat_id=@patId and pm.facility_cd = @facilityCd' where sql_cd=15;


update ntss.sys_data_set set "sql"='   select
    rst_treatment_name,
    rst_kur_name,
    rst_bed_name,
    rst_dw,
    case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mst.in_hosp_a_startdate)) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mst.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
    then  mst.in_hospital_cd_a1 else mst.in_hospital_cd_b1 end as rst_trea_in_hospital_cd_1,
    case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mst.in_hosp_a_startdate)) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mst.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
    then  mst.in_hospital_cd_a2 else mst.in_hospital_cd_b2 end as rst_trea_in_hospital_cd_2,
    case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mst.in_hosp_a_startdate)) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mst.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
    then  mst.in_hospital_cd_a3 else mst.in_hospital_cd_b3 end as rst_trea_in_hospital_cd_3,
    case when  abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mst.in_hosp_a_startdate)) ::text,''days'',''''),''99999'')) < abs(to_number(replace((date_trunc(''day'',now()) - date_trunc(''day'',mst.in_hosp_b_startdate)) ::text,''days'',''''),''99999''))
    then  mst.in_hospital_cd_a4 else mst.in_hospital_cd_b4 end as rst_trea_in_hospital_cd_4,
    msk.in_hospital_cd_1 as rst_kur_in_hospital_cd_1,
    msb.in_hospital_cd_1 as rst_bed_in_hospital_cd_1,
    msb.in_hospital_cd_2 as rst_bed_in_hospital_cd_2
  from
    ord_main ord
    left join mst_treatment mst on ( ord.rst_treatment_cd = mst.treatment_cd  and mst.is_del = ''0'' and mst.is_disp = ''1'' and mst.facility_cd = @facilityCd ) 
    left join mst_kur  msk on ( ord.rst_kur_cd = msk.kur_cd and msk.is_del = ''0'' and msk.facility_cd = @facilityCd )
    left join mst_bed  msb on ( ord.rst_bed_cd = msb.bed_cd and msb.is_disp = ''1'' and msb.is_del = ''0'' and msb.facility_cd = @facilityCd )
  where
    ord.pat_id = @patId
  and ord.facility_cd = @facilityCd  
  and ord.is_del = ''0''
  and ord.rst_dialysis_state <> ''0''
  order by ord.rst_start_date desc ;' where sql_cd=7;
  
  update ntss.sys_data_set set "sql"='with ord_tbl as (
  select
    facility_cd,
    pat_id,
    rst_bed_cd,
    to_timestamp(treat_date, ''yyyymmdd'') + ''1 days - 1 milliseconds'' as treat_date_end
  from ord_main
  where ord_no = @ordNo
  and facility_cd = @facilityCd 
  and is_del = ''0''
), bed_group_tbl AS (
  select
    facility_cd,
    room_bed_group_name as bed_group_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 1
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_name
), room_tbl AS (
  select
    facility_cd,
    room_bed_group_name as room_name
  from
    mst_room_bed_group
  where
    mst_room_bed_group.bed_list @> (''['' || (select rst_bed_cd from ord_tbl) || '']'')::jsonb
  and
    mst_room_bed_group.group_class = 2
  and mst_room_bed_group.is_del = ''0''
  and mst_room_bed_group.is_disp = ''1''
  group by
    facility_cd, room_bed_group_name
), pat_physical_tbl AS (
-- 指定患者、基準日以前のDWがある身体情報を取得
  select
    work_tbl.*
  from
    (
    select
      pat_id,
      info->>''exam_date'' as exam_date,
      info->>''dw'' as dw,
      info->>''pre_scale_upper'' as pre_scale_upper,
      info->>''pre_scale_lower'' as pre_scale_lower
    from
      (select * from pat_unique where is_del = ''0'') as pat_unique
      cross join lateral
        json_array_elements (pat_unique.physical_info :: json) info
    where
      pat_unique.pat_id = (select pat_id from ord_tbl)
    ) work_tbl
  where
    exam_date::timestamp <= (select treat_date_end from ord_tbl)
  and
    dw is not null
  order by
    exam_date desc
  limit 1
), pat_wheel_chair_tbl AS (
-- 指定患者の車いす情報を取得
  select
    pat_id,
    wheel_chair_name,
    wheel_chair_weight
  from
    mst_wheel_chair,
    (
      select
        mss.facility_cd, ms.*, row_number() over() as index
      from
        mst_selector mss
      cross join lateral jsonb_to_recordset(mss.order_settings->''items'') as ms
      (
        code bigint,
        name text
      )
      where
        facility_cd = (select facility_cd from ord_tbl)
      and
        master_physical_name = ''mst_wheel_chair''
    ) ms
  where
    mst_wheel_chair.wheel_chair_cd = ms.code
  and
    pat_id = (select pat_id from ord_tbl)
  and
    is_disp = ''1''
  and
    is_del = ''0''
  and
    is_personal = ''1''
  limit 1
)
select
  to_date(ord.treat_date, ''yyyymmdd'') as treat_date,
  ord.rst_kur_cd as kur_cd,
  
  ord.rst_treatment_cd as treatment_cd,
  to_char(ord.rst_start_date, ''HH24:MI'') as treat_start_time,
  
  to_char(ord.rst_end_date, ''HH24:MI'') as treat_end_time,
  
  ord.rst_bed_cd as bed_cd,

  ord.rst_cond_info->''1''->>''value'' as treatment_time,
  --ord.rst_cond_info->''2''->>''value_name_1'' as va,
  ord.rst_cond_info->''4''->>''value'' as water_removal_amount_limit,
  ord.rst_cond_info->''12''->>''value'' as single_needle,
  ord.rst_cond_info->''14''->>''value'' as blood_flow,
  ord.rst_cond_info->''16''->>''value'' as dialysate_flow_rate,
  ord.rst_cond_info->''17''->>''value'' as dialysate_amount,
  ord.rst_cond_info->''18''->>''value'' as dialysate_temperature,
  ord.rst_cond_info->''20''->>''value'' as fluid_replacement_amount,
  ord.rst_cond_info->''21''->>''value'' as fluid_replacement_timing,
  ord.rst_cond_info->''22''->>''value'' as fluid_replacement_use_count,
  ord.rst_cond_info->''23''->>''value'' as fluid_replacement_temperature,
  ord.rst_cond_info->''24''->>''value'' as fluid_replacement_speed,
  ord.rst_cond_info->''26''->>''value'' as anti_coagulant_one_shot_amount,
  ord.rst_cond_info->''27''->>''value'' as anti_coagulant_sustained_speed,
  ord.rst_cond_info->''27''->>''unit'' as anti_coagulant_sustained_speed_unit,
  ord.rst_cond_info->''28''->>''value'' as anti_coagulant_sustained_amount,
  ord.rst_cond_info->''29''->>''value'' as ip,
  ord.rst_cond_info->''30''->>''value'' as ip_start,
  ord.rst_cond_info->''31''->>''value'' as ip_one_shot_amount,
  ord.rst_cond_info->''32''->>''value'' as ip_speed,
  ord.rst_cond_info->''33''->>''value'' as ip_speed_max,
  ord.rst_cond_info->''34''->>''value'' as auto_one_shot,
  ord.rst_cond_info->''35''->>''value'' as ip_auto_off,
  ord.rst_cond_info->''36''->>''value'' as ip_auto_off_time,
  ord.rst_cond_info->''37''->>''value'' as ip_monitor_auto_off,
  ord.rst_cond_info->''38''->>''value'' as ip_monitor_auto_off_time,

  to_number(ord.rst_cond_info->''26''->>''value'', ''999999.999'')
    + to_number(ord.rst_cond_info->''28''->>''value'', ''999999.999'')
    as anti_coagulant_total_amount,

  case
    when ord.rst_cond_info->''31''->>''value'' is not null then ''ml/h''
    else null
  end as ip_one_shot_amount_unit,
  case
    when ord.rst_cond_info->''32''->>''value'' is not null then ''ml/h''
    else null
  end as ip_speed_unit,
  case
    when ord.rst_cond_info->''33''->>''value'' is not null then ''ml''
    else null
  end as ip_speed_max_unit,

  ord.rst_tare_info->>''name_1'' as tare_name1,
  ord.rst_tare_info->>''name_2'' as tare_name2,
  ord.rst_tare_info->>''name_3'' as tare_name3,
  ord.rst_tare_info->>''name_4'' as tare_name4,
  ord.rst_tare_info->>''name_5'' as tare_name5,
  ord.rst_tare_info->>''weight_1'' as tare_weight1,
  ord.rst_tare_info->>''weight_2'' as tare_weight2,
  ord.rst_tare_info->>''weight_3'' as tare_weight3,
  ord.rst_tare_info->>''weight_4'' as tare_weight4,
  ord.rst_tare_info->>''weight_5'' as tare_weight5,
  to_number(ord.rst_tare_info->>''weight_1'', ''999999'')
    + to_number(ord.rst_tare_info->>''weight_2'', ''999999'')
    + to_number(ord.rst_tare_info->>''weight_3'', ''999999'')
    + to_number(ord.rst_tare_info->>''weight_4'', ''999999'')
    + to_number(ord.rst_tare_info->>''weight_5'', ''999999'')
    as tare_weight_total,

  ord.rst_off_water_info->>''name_1'' as off_water_name1,
  ord.rst_off_water_info->>''name_2'' as off_water_name2,
  ord.rst_off_water_info->>''name_3'' as off_water_name3,
  ord.rst_off_water_info->>''name_4'' as off_water_name4,
  ord.rst_off_water_info->>''name_5'' as off_water_name5,
  ord.rst_off_water_info->>''weight_1'' as off_water_weight1,
  ord.rst_off_water_info->>''weight_2'' as off_water_weight2,
  ord.rst_off_water_info->>''weight_3'' as off_water_weight3,
  ord.rst_off_water_info->>''weight_4'' as off_water_weight4,
  ord.rst_off_water_info->>''weight_5'' as off_water_weight5,
  to_number(ord.rst_off_water_info->>''weight_1'', ''999999'')
    + to_number(ord.rst_off_water_info->>''weight_2'', ''999999'')
    + to_number(ord.rst_off_water_info->>''weight_3'', ''999999'')
    + to_number(ord.rst_off_water_info->>''weight_4'', ''999999'')
    + to_number(ord.rst_off_water_info->>''weight_5'', ''999999'')
    as off_water_weight_total,

  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then ''1''
    else ''0''
  end as target_weight_mode,
  case
    when ord.rst_cond_info->''3''->>''value'' = ''-1'' then pat_physical_tbl.dw
    else ord.rst_cond_info->''3''->>''value''
  end as target_weight,
  
  --pat_physical_tbl.dw, -- 指示
  
  pat_physical_tbl.pre_scale_upper,
  pat_physical_tbl.pre_scale_lower,

  pat_wheel_chair_tbl.wheel_chair_name,
  pat_wheel_chair_tbl.wheel_chair_weight,

  --kur_tbl.kur_name as kur_name, -- 指示
  
  mst_va.va_name as va_name,
  mst_va.in_hospital_cd_1 as va_in_hospital_cd_1,
  mst_va.in_hospital_cd_2  as va_in_hospital_cd_2,  
  mst_va.va_direct as va_direct,
  
  --treatment_tbl.treatment_name, --指示
  
  mst_treatment.device_mode,
  mst_bed.*,
  mst_machine.*,
  
  -- room_bed_group_tbl.room_bed_group_name_list, -- 指示
  bed_group_tbl.bed_group_name, -- 実績
  room_tbl.room_name, -- 実績

  mst_dialyzer.model_number as dialyzer_name,
  mst_dialyzer.in_hospital_cd_1 as rst_dialyzer_in_hospital_cd_1,
  mst_dialyzer.in_hospital_cd_2 as rst_dialyzer_in_hospital_cd_2,
  mst_dialyzer.in_hospital_cd_3 as rst_dialyzer_in_hospital_cd_3,
  mst_dialyzer.in_hospital_cd_4 as rst_dialyzer_in_hospital_cd_4,
  mst_dialyzer.*,

  adsorption_column_tbl.equipment_name as adsorption_column_name,
  adsorption_column_tbl.in_hospital_cd_1 as rst_adsorption_in_hospital_cd_1,
  adsorption_column_tbl.in_hospital_cd_2 as rst_adsorption_in_hospital_cd_2,
  adsorption_column_tbl.in_hospital_cd_3 as rst_adsorption_in_hospital_cd_3,
  adsorption_column_tbl.in_hospital_cd_4 as rst_adsorption_in_hospital_cd_4, 
  
  
  primary_film_tbl.equipment_name as primary_film_name,
  primary_film_tbl.in_hospital_cd_1 as rst_primary_film_in_hospital_cd_1,
  primary_film_tbl.in_hospital_cd_2 as rst_primary_film_in_hospital_cd_2,
  primary_film_tbl.in_hospital_cd_3 as rst_primary_film_in_hospital_cd_3,
  primary_film_tbl.in_hospital_cd_4 as rst_primary_film_in_hospital_cd_4,
  
  secondary_film_tbl.equipment_name as secondary_film_name,
  secondary_film_tbl.in_hospital_cd_1 as rst_secondary_film_in_hospital_cd_1,
  secondary_film_tbl.in_hospital_cd_2 as rst_secondary_film_in_hospital_cd_2,
  secondary_film_tbl.in_hospital_cd_3 as rst_secondary_film_in_hospital_cd_3,
  secondary_film_tbl.in_hospital_cd_4 as rst_secondary_film_in_hospital_cd_4,

  puncture_needle_a_tbl.equipment_name as puncture_needle_a_name,
  puncture_needle_a_tbl.in_hospital_cd_1 as rst_pn_a_in_hospital_cd_1,
  puncture_needle_a_tbl.in_hospital_cd_2 as rst_pn_a_in_hospital_cd_2,
  puncture_needle_a_tbl.in_hospital_cd_3 as rst_pn_a_in_hospital_cd_3,  
  puncture_needle_a_tbl.in_hospital_cd_4 as rst_pn_a_in_hospital_cd_4,    
  
  puncture_needle_v_tbl.equipment_name as puncture_needle_v_name,
  puncture_needle_v_tbl.in_hospital_cd_1 as rst_pn_v_in_hospital_cd_1,
  puncture_needle_v_tbl.in_hospital_cd_2 as rst_pn_v_in_hospital_cd_2,
  puncture_needle_v_tbl.in_hospital_cd_3 as rst_pn_v_in_hospital_cd_3,  
  puncture_needle_v_tbl.in_hospital_cd_4 as rst_pn_v_in_hospital_cd_4, 
  
  puncture_needle_sn_tbl.equipment_name as puncture_needle_s_name,
  puncture_needle_sn_tbl.in_hospital_cd_1 as rst_pn_s_in_hospital_cd_1,
  puncture_needle_sn_tbl.in_hospital_cd_2 as rst_pn_s_in_hospital_cd_2,
  puncture_needle_sn_tbl.in_hospital_cd_3 as rst_pn_s_in_hospital_cd_3,  
  puncture_needle_sn_tbl.in_hospital_cd_4 as rst_pn_s_in_hospital_cd_4, 
  
  blood_circuit_tbl.equipment_name as blood_circuit_name,
  blood_circuit_tbl.in_hospital_cd_1 as rst_bc_in_hospital_cd_1,
  blood_circuit_tbl.in_hospital_cd_2 as rst_bc_in_hospital_cd_2,
  blood_circuit_tbl.in_hospital_cd_3 as rst_bc_in_hospital_cd_3,  
  blood_circuit_tbl.in_hospital_cd_4 as rst_bc_in_hospital_cd_4, 

  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.medicine_mix_name
    else med_dialysate_tbl.medicine_name
  end as dialysate_name,
  
  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_1
    else med_dialysate_tbl.in_hospital_cd_1
  end as rst_dialysate_in_hospital_cd_1,
  
  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_2
    else med_dialysate_tbl.in_hospital_cd_2
  end as rst_dialysate_in_hospital_cd_2,
  
  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.in_hospital_cd_3
    else med_dialysate_tbl.in_hospital_cd_3
  end as rst_dialysate_in_hospital_cd_3,
  
  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then ''''
    else med_dialysate_tbl.in_hospital_cd_4
  end as rst_dialysate_in_hospital_cd_4,
    
  
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.medicine_mix_name
    else med_fluid_replacement_tbl.medicine_name
  end as fluid_replacement_name,
  
   case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_1
    else med_fluid_replacement_tbl.in_hospital_cd_1
  end as rst_fluid_in_hospital_cd_1,
  
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_2
    else med_fluid_replacement_tbl.in_hospital_cd_2
  end as rst_fluid_in_hospital_cd_2,
  
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.in_hospital_cd_3
    else med_fluid_replacement_tbl.in_hospital_cd_3
  end as rst_fluid_in_hospital_cd_3,
  
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then ''''
    else med_fluid_replacement_tbl.in_hospital_cd_4
  end as rst_fluid_in_hospital_cd_4,
  
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.medicine_mix_name
    else med_anti_coagulant_tbl.medicine_name
  end as anti_coagulant_name,
  
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_1
    else med_anti_coagulant_tbl.in_hospital_cd_1
  end as rst_anti_in_hospital_cd_1,
  
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_2
    else med_anti_coagulant_tbl.in_hospital_cd_2
  end as rst_anti_in_hospital_cd_2,
  
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.in_hospital_cd_3
    else med_anti_coagulant_tbl.in_hospital_cd_3
  end as rst_anti_in_hospital_cd_3,
  
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then ''''
    else med_anti_coagulant_tbl.in_hospital_cd_4
  end as rst_anti_in_hospital_cd_4,
    
  
  case
    when ord.rst_cond_info->''15''->>''medicine_type'' = ''2'' then mix_dialysate_tbl.unit
    else med_dialysate_tbl.unit
  end as dialysate_amount_unit,
  case
    when ord.rst_cond_info->''19''->>''medicine_type'' = ''2'' then mix_fluid_replacement_tbl.unit
    else med_fluid_replacement_tbl.unit
  end as fluid_replacement_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_unit,
  case
    when ord.rst_cond_info->''25''->>''medicine_type'' = ''2'' then mix_anti_coagulant_tbl.unit
    else med_anti_coagulant_tbl.unit
  end as anti_coagulant_speed_unit
  
  -- 実績
  ,rst_dialysis_cnt
  ,rst_in_out_class
  ,rst_ward_name
  ,mst_ward_tbl.in_hospital_cd_1 as  rst_ward_in_hospital_cd_1
  ,rst_course_name
  ,mst_course_tbl.in_hospital_cd_1 as  rst_course_in_hospital_cd_1
  ,rst_accept_date
  ,rst_return_home_date
  ,rst_purification_cnt
  ,trim(coalesce(rst_charge_user_info->>''user_id_1'', '''') , '' '') as rst_charge_user_id_1
  ,trim(coalesce(rst_charge_user_info->>''user_id_2'', '''') , '' '') as rst_charge_user_id_2
  ,trim(coalesce(rst_charge_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_charge_user_info->>''user_first_name_1'', ''''), '' '') as rst_charge_user_name1
  ,trim(coalesce(rst_charge_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_charge_user_info->>''user_first_name_2'', ''''), '' '') as rst_charge_user_name2
  ,(rst_charge_user_info->>''date_1'')::timestamp as rst_charge_date1
  ,(rst_charge_user_info->>''date_2'')::timestamp as rst_charge_date2
  ,trim(coalesce(rst_puncture_user_info->>''user_id_1'', '''') , '' '') as rst_puncture_user_id_1
  ,trim(coalesce(rst_puncture_user_info->>''user_id_2'', '''') , '' '') as rst_puncture_user_id_2
  ,trim(coalesce(rst_puncture_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_puncture_user_info->>''user_first_name_1'', ''''), '' '') as rst_puncture_user_name1
  ,trim(coalesce(rst_puncture_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_puncture_user_info->>''user_first_name_2'', ''''), '' '') as rst_puncture_user_name2
  ,(rst_puncture_user_info->>''date_1'')::timestamp as rst_puncture_date1
  ,(rst_puncture_user_info->>''date_2'')::timestamp as rst_puncture_date2
  ,trim(coalesce(rst_return_user_info->>''user_id_1'', '''') , '' '') as rst_return_user_id_1
  ,trim(coalesce(rst_return_user_info->>''user_id_2'', '''') , '' '') as rst_return_user_id_2
  ,trim(coalesce(rst_return_user_info->>''user_last_name_1'', '''') || '' '' || coalesce(rst_return_user_info->>''user_first_name_1'', ''''), '' '') as rst_return_user_name1
  ,trim(coalesce(rst_return_user_info->>''user_last_name_2'', '''') || '' '' || coalesce(rst_return_user_info->>''user_first_name_2'', ''''), '' '') as rst_return_user_name2
  ,(rst_return_user_info->>''date_1'')::timestamp as rst_return_date1
  ,(rst_return_user_info->>''date_2'')::timestamp as rst_return_date2
  ,pull_leave_amount
from
  ord_main as ord

  left join pat_physical_tbl on ord.pat_id = pat_physical_tbl.pat_id
  left join pat_wheel_chair_tbl on ord.pat_id = pat_wheel_chair_tbl.pat_id 

--   left join kur_tbl on ord.rst_kur_cd = kur_tbl.kur_cd
  
  --left join va_tbl on ord.ind_va_cd = va_tbl.va_cd -- 指示
  left join mst_va on cast(rst_cond_info->''2''->>''value'' as integer) = mst_va.va_cd  and mst_va.is_del = ''0'' and mst_va.is_disp = ''1'' and mst_va.facility_cd = @facilityCd  -- 実績
  
  left join mst_treatment on ord.rst_treatment_cd = mst_treatment.treatment_cd and mst_treatment.is_del = ''0'' and mst_treatment.is_disp = ''1'' and mst_treatment.facility_cd = @facilityCd 
  left join mst_bed on ord.rst_bed_cd = mst_bed.bed_cd and mst_bed.is_del = ''0'' and mst_bed.is_disp = ''1'' and mst_bed.facility_cd = @facilityCd
  left join mst_machine on mst_bed.machine_no = mst_machine.machine_no and mst_machine.is_del = ''0'' and mst_machine.is_disp = ''1'' and mst_machine.facility_cd = @facilityCd
  
  --left join room_bed_group_tbl on bed_tbl.facility_cd = room_bed_group_tbl.facility_cd -- 指示
  left join bed_group_tbl on mst_bed.facility_cd = bed_group_tbl.facility_cd -- 実績
  left join room_tbl on mst_bed.facility_cd = room_tbl.facility_cd -- 実績

  left join mst_dialyzer on ord.rst_cond_info->''5''->>''value'' = mst_dialyzer.dialyzer_cd::text and mst_dialyzer.is_del = ''0'' and mst_dialyzer.is_disp = ''1'' and mst_dialyzer.facility_cd = @facilityCd

  left join mst_equipment as adsorption_column_tbl on ord.rst_cond_info->''6''->>''value'' = adsorption_column_tbl.equipment_cd::text and adsorption_column_tbl.is_del = ''0'' and adsorption_column_tbl.is_disp = ''1'' and adsorption_column_tbl.facility_cd = @facilityCd 
  left join mst_equipment as primary_film_tbl on ord.rst_cond_info->''7''->>''value'' = primary_film_tbl.equipment_cd::text and primary_film_tbl.is_del = ''0'' and primary_film_tbl.is_disp = ''1'' and adsorption_column_tbl.facility_cd = @facilityCd 
  left join mst_equipment as secondary_film_tbl on ord.rst_cond_info->''8''->>''value'' = secondary_film_tbl.equipment_cd::text and secondary_film_tbl.is_del = ''0'' and secondary_film_tbl.is_disp = ''1'' and adsorption_column_tbl.facility_cd = @facilityCd 

  left join mst_equipment as puncture_needle_a_tbl on ord.rst_cond_info->''9''->>''value'' = puncture_needle_a_tbl.equipment_cd::text and puncture_needle_a_tbl.is_del = ''0'' and puncture_needle_a_tbl.is_disp = ''1'' and puncture_needle_a_tbl.facility_cd = @facilityCd 
  left join mst_equipment as puncture_needle_v_tbl on ord.rst_cond_info->''10''->>''value'' = puncture_needle_v_tbl.equipment_cd::text and puncture_needle_v_tbl.is_del = ''0'' and puncture_needle_v_tbl.is_disp = ''1'' and puncture_needle_v_tbl.facility_cd = @facilityCd 
  left join mst_equipment as puncture_needle_sn_tbl on ord.rst_cond_info->''11''->>''value'' = puncture_needle_sn_tbl.equipment_cd::text and puncture_needle_sn_tbl.is_del = ''0'' and puncture_needle_sn_tbl.is_disp = ''1'' and puncture_needle_sn_tbl.facility_cd = @facilityCd 
  left join mst_equipment as blood_circuit_tbl on ord.rst_cond_info->''13''->>''value'' = blood_circuit_tbl.equipment_cd::text and blood_circuit_tbl.is_del = ''0'' and blood_circuit_tbl.is_disp = ''1'' and blood_circuit_tbl.facility_cd = @facilityCd 

  left join mst_medicine as med_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = med_dialysate_tbl.medicine_cd::text and med_dialysate_tbl.is_del = ''0'' and med_dialysate_tbl.is_disp = ''1''  and med_dialysate_tbl.facility_cd = @facilityCd 
  left join mst_medicine as med_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = med_fluid_replacement_tbl.medicine_cd::text and med_fluid_replacement_tbl.is_del = ''0'' and med_fluid_replacement_tbl.is_disp = ''1''  and med_fluid_replacement_tbl.facility_cd = @facilityCd 
  left join mst_medicine as med_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = med_anti_coagulant_tbl.medicine_cd::text and med_anti_coagulant_tbl.is_del = ''0'' and med_anti_coagulant_tbl.is_disp = ''1''  and med_anti_coagulant_tbl.facility_cd = @facilityCd 

  left join mst_medicine_mix as mix_dialysate_tbl on ord.rst_cond_info->''15''->>''value'' = mix_dialysate_tbl.medicine_mix_cd::text and mix_dialysate_tbl.is_del = ''0'' and mix_dialysate_tbl.is_disp = ''1''  and mix_dialysate_tbl.facility_cd = @facilityCd 
  left join mst_medicine_mix as mix_fluid_replacement_tbl on ord.rst_cond_info->''19''->>''value'' = mix_fluid_replacement_tbl.medicine_mix_cd::text and mix_fluid_replacement_tbl.is_del = ''0'' and mix_fluid_replacement_tbl.is_disp = ''1''  and mix_fluid_replacement_tbl.facility_cd = @facilityCd 
  left join mst_medicine_mix as mix_anti_coagulant_tbl on ord.rst_cond_info->''25''->>''value'' = mix_anti_coagulant_tbl.medicine_mix_cd::text and mix_anti_coagulant_tbl.is_del = ''0'' and mix_anti_coagulant_tbl.is_disp = ''1''  and mix_anti_coagulant_tbl.facility_cd = @facilityCd 
  left join mst_ward as mst_ward_tbl on (ord.rst_ward_cd = mst_ward_tbl.ward_cd and mst_ward_tbl.is_disp =''1'' and mst_ward_tbl.is_del =''0''   and mst_ward_tbl.facility_cd = @facilityCd )
  left join mst_course as mst_course_tbl on (ord.rst_course_cd = mst_course_tbl.course_cd and mst_course_tbl.is_disp =''1'' and mst_course_tbl.is_del =''0''   and mst_ward_tbl.facility_cd = @facilityCd )
where
  ord.ord_no = @ordNo
  and ord.facility_cd = @facilityCd  
 and ord.is_del = ''0''
;' where sql_cd=95;

update ntss.sys_data_set set "sql"='WITH current_ord AS (
    SELECT pat_id, treat_date, rst_start_date
    FROM ord_main
    WHERE ord_no = @ordNo
    and facility_cd = @facilityCd  
    and is_del = ''0''
    and rst_dialysis_state <>''0''
)
select
  ord.rst_weight_info ->> ''ctr'' as last_ctr
  , ord.rst_weight_info ->> ''ctr_weight'' as last_ctr_weight
  , ord.rst_weight_info ->> ''weight_before'' as last_weight_before
  , ord.rst_weight_info ->> ''weight_after'' as last_weight_after
  , ord.rst_weight_info ->> ''ctr_measure_date'' as last_ctr_measure_date
  , ord.rst_weight_info ->> ''weight_decreased'' as last_weight_decreased
  , ord.rst_weight_info ->> ''weight_after_date'' as last_weight_after_date
  , ord.rst_weight_info ->> ''weight_before_date'' as last_weight_before_date
  , (ord.rst_puncture_user_info ->> ''user_last_name_1'') || (ord.rst_puncture_user_info ->> ''user_first_name_1'') as last_puncture_user_name
from
  ord_main as ord INNER JOIN current_ord ON ord.pat_id = current_ord.pat_id 
where
  ord.is_del=''0''
   and  and ord.facility_cd = @facilityCd  
   and ord.rst_dialysis_state <>''0''
   and ord.treat_date <= current_ord.treat_date
   and (((current_ord.rst_start_date is not null) AND (ord.rst_start_date <= current_ord.rst_start_date))
        OR
        ((current_ord.rst_start_date is null) AND (ord.rst_start_date is not null) AND (ord.treat_date <= current_ord.treat_date)))
order by ord.treat_date DESC LIMIT 1 OFFSET 0' where sql_cd=12;

update ntss.sys_data_set set "sql"='select
  *
from
  ord_main
where
  ord_no = @ordNo
and facility_cd = @facilityCd 
and is_del = ''0''
and rst_dialysis_state <>''0''' where sql_cd=2;

update ntss.sys_data_set set "sql"='with tmp as
(
select 
  to_number(rst_weight_info->>''weight_before'', ''999.99'') as weight_before
  ,(rst_weight_info->>''weight_before_date'')::timestamp as weight_before_date

  ,to_number(rst_weight_info->>''weight_after'', ''999.99'') as weight_after
  ,(rst_weight_info->>''weight_after_date'')::timestamp as weight_after_date

  ,to_number(rst_weight_info->>''ctr'', ''999.99'') as ctr
  ,(rst_weight_info->>''ctr_measure_date'')::timestamp as ctr_measure_date
  ,to_number(rst_weight_info->>''ctr_weight'', ''999.99'') as ctr_weight

  ,to_number(rst_weight_info->>''kt_v_measure'', ''999.99'') as kt_v_measure
  ,to_number(rst_weight_info->>''urr'', ''999.9'') as urr
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and bio_moni_ctl_no::text = rst_weight_info->>''re_loop_rate_main'' and is_del = ''0'')->>''38'', ''999.99'') as re_loop_rate
  
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''90'', ''999'') as before_bp_high
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''91'', ''999'') as before_bp_low
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''92'', ''999'') as before_bp_ave
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'')->>''93'', ''999'') as before_pulse
  ,(select occur_date from mni_monitor where ord_no = @ordNo and data_type = 5 and is_del = ''0'') as before_vital_measure_date
  
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''90'', ''999'') as after_bp_high
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''91'', ''999'') as after_bp_low
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''92'', ''999'') as after_bp_ave
  ,to_number((select monitor_data from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'')->>''93'', ''999'') as after_pulse
  ,(select occur_date from mni_monitor where ord_no = @ordNo and data_type = 6 and is_del = ''0'') as after_vital_measure_date
from
  ord_main
where
  ord_no = @ordNo and is_del = ''0''
  and facility_cd = @facilityCd 
 and rst_dialysis_state <>''0''
)

select
  *
  ,before_bp_high::text || ''/'' || before_bp_low::text || ''/'' || before_bp_ave || ''('' || before_pulse::text || '')'' as before_bp_summary
  ,after_bp_high::text || ''/'' || after_bp_low::text || ''/'' || after_bp_ave || ''('' || after_pulse::text || '')'' as after_bp_summary
from
  tmp
;' where sql_cd=3;

update ntss.sys_data_set set "sql"='with ord_key_tbl as (
  select
    facility_cd
  from
    ord_main
  where
    ord_no = @ordNo and facility_cd = @facilityCd and is_del = ''0'' and rst_dialysis_state <> ''0''


), dialyzer_tbl as (
  select
    *
  from
    mst_dialyzer
  where
    mst_dialyzer.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_dialyzer.is_disp = ''1''
  and
    mst_dialyzer.is_del = ''0''

), equipment_tbl as (
  select
    *
  from
    mst_equipment
  where
    mst_equipment.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment.is_disp = ''1''
  and
    mst_equipment.is_del = ''0''

), equipment_class_tbl as (
  select
    *
  from
    mst_equipment_class
  where
    mst_equipment_class.facility_cd = (select facility_cd from ord_key_tbl)
  and
    mst_equipment_class.is_disp = ''1''
  and
    mst_equipment_class.is_del = ''0''

), ord_tbl as (
  select
    facility_cd,
    to_date(treat_date, ''yyyymmdd'') as treat_date,

    info->>''class_cd'' as class_cd,
    info->>''class_type'' as class_type,
    info->>''equip_type'' as equip_type,
    info->>''cd'' as cd,
    info->>''amount'' as amount,

    info->>''ind_user_id'' as ind_user_id,
    info->>''ind_user_last_name'' as ind_user_last_name,
    info->>''ind_user_first_name'' as ind_user_first_name,
    info->>''upd_user_id'' as upd_user_id,
    info->>''upd_user_last_name'' as upd_user_last_name,
    info->>''upd_user_first_name'' as upd_user_first_name,
    info->>''input_class'' as input_class,
    info->>''is_editable'' as is_editable,
    info->>''cop_order_no'' as cop_order_no

    -- 実績
    ,info->>''needle_type'' as needle_type
  from
    ord_main
      cross join lateral
        json_array_elements (ord_main.rst_equip_info :: json) info
  where
    ord_no = @ordNo and facility_cd = @facilityCd and is_del = ''0'' and rst_dialysis_state <> ''0''

)


select
  ord.*,
  case
    when equip_type = ''1'' then dia.model_number
    else eqp.equipment_name
  end as equip_name,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_1
    else eqp.in_hospital_cd_1
  end as rst_equip_in_hospital_cd_1,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_2
    else eqp.in_hospital_cd_2
  end as rst_equip_in_hospital_cd_2,
  
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_3
    else eqp.in_hospital_cd_3
  end as rst_equip_in_hospital_cd_3,
  
  case
    when equip_type = ''1'' then dia.in_hospital_cd_4
    else eqp.in_hospital_cd_4
  end as rst_equip_in_hospital_cd_4,
  
  
  case
    when equip_type = ''1'' then null
    else eqp.unit
  end as equip_unit,
  eqp_cls.class_name as equip_class_name,
  eqp_cls.class_type as equip_class_type

from
  ord_tbl as ord

  left join dialyzer_tbl as dia on ord.cd = dia.dialyzer_cd::text
  left join equipment_tbl as eqp on ord.cd = eqp.equipment_cd::text
  left join equipment_class_tbl eqp_cls on eqp.class_cd = eqp_cls.class_cd
  
order by class_cd, cd
;' where sql_cd=97;







