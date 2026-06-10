--add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
select insurance_cd,
       pat_id,
       facility_cd,
       ctl_no,
       fn_pat_id,
       insu_class,
       insu_name,
       insu_name_short,
       start_date,
       end_date,
       check_date,
       insu_info,
       insu_pub_info,
       insu_set_info,
       insu_self_info,
       is_selected,
       is_disp,
       is_del,
       coop_code,
       is_coop,
       reg_date,
       up_date,
       old_up_date,
       memo1,
       memo2,
       fn_ctl_no
from pat_insurance
where pat_id in (select pat_id
                 from pat_insurance
                 where facility_cd = /* facilityCd */null
                   and personal_info_decrypt(insu_info ->> 'insu_no') in /* insuranceCdList */(null))
  and facility_cd = /* facilityCd */null
  and is_del = '0';
--add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
