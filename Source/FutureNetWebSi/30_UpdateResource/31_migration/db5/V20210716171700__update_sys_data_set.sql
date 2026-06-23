UPDATE sys_data_set SET sql = '   select
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
    left join mst_treatment mst on ( ord.rst_treatment_cd = mst.treatment_cd  and mst.is_del = ''0'' and mst.is_disp = ''1'' ) 
    left join mst_kur  msk on ( ord.rst_kur_cd = msk.kur_cd and msk.is_del = ''0''  )
    left join mst_bed  msb on ( ord.rst_bed_cd = msb.bed_cd and msb.is_disp = ''1'' and msb.is_del = ''0'' )
  where
    ord.pat_id = @patId  and ord.ord_no = @ordNo
  and ord.is_del = ''0''
  and ord.rst_dialysis_state <> ''0''
  order by ord.rst_start_date desc ;', can_repeat = '0' WHERE sql_cd = 7;
