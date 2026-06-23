UPDATE sys_data_set 
SET SQL = 'with pat_vendor_contact_tbl as (
  select
    to_number(info->>''ctl_no'', ''99999'') as ctl_no,
    to_number(info->>''disp_order'', ''99999'') as disp_order,
    trim(both ''"'' from personal_info_decrypt(info->>''company_name'')) as company_name,
    trim(both ''"'' from personal_info_decrypt(info->>''zip_cd'')) as zip_cd,
    trim(both ''"'' from personal_info_decrypt(info->>''address'')) as address,
    trim(both ''"'' from personal_info_decrypt(info->>''company_tel'')) as company_tel,
    trim(both ''"'' from personal_info_decrypt(info->>''fax'')) as company_fax,
    trim(both ''"'' from personal_info_decrypt(info->>''worker_last_name'')) || '' ''
|| trim(both ''"'' from personal_info_decrypt(info->>''worker_first_name'')) as worker_name,
    trim(both ''"'' from personal_info_decrypt(info->>''worker_tel'')) as worker_tel,
    trim(both ''"'' from personal_info_decrypt(info->>''worker_e_mail'')) as worker_e_mail,
    trim(both ''"'' from personal_info_decrypt(info->>''memo1'')) as memo1,
    trim(both ''"'' from personal_info_decrypt(info->>''memo2'')) as memo2
  from
    pat_personal_main
    cross join lateral
      json_array_elements (pat_personal_main.vendor_contact_info :: json) info
  where
    pat_id = @patId  and  is_del = ''0''

)

select
  *
from
  pat_vendor_contact_tbl
order by
  disp_order, ctl_no
' 
WHERE
	sql_cd = '41'
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	