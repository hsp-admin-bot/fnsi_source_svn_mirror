UPDATE sys_data_set 
SET SQL = 'with pat_other_contact_tbl as (
  select
    to_number(info->>''ctl_no'', ''99999'') as ctl_no,
    to_number(info->>''disp_order'', ''99999'') as disp_order,
    info->>''is_key_person'' as is_key_parson,
    --info->>''pat_id'' as pat_id
    trim(both ''"'' from personal_info_decrypt(info->>''last_name'')) || '' ''
      || trim(both ''"'' from personal_info_decrypt(info->>''first_name'')) as other_name,
    trim(both ''"'' from personal_info_decrypt(info->>''last_name_kana'')) ||'' ''
      || trim(both ''"'' from personal_info_decrypt(info->>''first_name_kana'')) as other_name_kana,
    info->>''relation_cd'' as relation_cd,
    trim(both ''"'' from personal_info_decrypt(info->>''relation_name'')) as relation_name,
    trim(both ''"'' from personal_info_decrypt(info->>''zip_cd'')) as zip_cd,
    trim(both ''"'' from personal_info_decrypt(info->>''address'')) as address,
    trim(both ''"'' from personal_info_decrypt(info->>''tel1'')) as tel1,
    trim(both ''"'' from personal_info_decrypt(info->>''tel2'')) as tel2,
    trim(both ''"'' from personal_info_decrypt(info->>''fax'')) as fax,
    trim(both ''"'' from personal_info_decrypt(info->>''e_mail'')) as e_mail,
    trim(both ''"'' from personal_info_decrypt(info->>''work_name'')) as work_name,
    trim(both ''"'' from personal_info_decrypt(info->>''work_tel'')) as work_tel,
    trim(both ''"'' from personal_info_decrypt(info->>''memo1'')) as memo1,
    trim(both ''"'' from personal_info_decrypt(info->>''memo2'')) as memo2
  from
    pat_personal_main
    cross join lateral
      json_array_elements (pat_personal_main.other_contact_info :: json) info
  where
    pat_id = @patId  and is_del = ''0''
)

select
  *
from
  pat_other_contact_tbl
order by
  disp_order, ctl_no
' 
WHERE
	sql_cd = '40'