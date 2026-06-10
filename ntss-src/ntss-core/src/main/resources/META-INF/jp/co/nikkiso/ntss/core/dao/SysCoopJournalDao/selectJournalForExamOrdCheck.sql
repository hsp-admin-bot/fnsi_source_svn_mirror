select facility_cd
     , ctl_no
     , coop_cd
     , TRIM(coop_cd_index) AS coop_cd_index
     , crud
     , direction
     , ana_result
     , base_date
     , out_reg_date
     , out_ana_date
     , coop_result
     , in_reg_date
     , in_ana_date
     , ord_no
     , coop_ord_no
     , pat_id
     , hosp_pat_id
     , TRIM(dump_path)     AS dump_path
     , dump
     , is_editable
     , reg_date
     , up_date
     , is_del
     , user_id
     , temp_content
     , accept_no
     , ope_cd
     , key0
     , coop_version
from sys_coop_journal
where coop_cd = 'ind_dial'
  and base_date = /*baseDate*/''
  and pat_id = /*patId*/''
  and ana_result = '9'
  --mod 11037 透析予定のクール変更時、同日の検査依頼の連携イベントがスキップになる場合がある 20240904 zhaoqi start
  and coop_result in ('9','8','1','0')
  --mod 11037 透析予定のクール変更時、同日の検査依頼の連携イベントがスキップになる場合がある 20240904 zhaoqi end
limit 1;
