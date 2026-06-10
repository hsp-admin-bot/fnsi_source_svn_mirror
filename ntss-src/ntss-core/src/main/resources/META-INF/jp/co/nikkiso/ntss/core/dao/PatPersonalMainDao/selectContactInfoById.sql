select facility_cd AS facility_cd,
       personal_info_decrypt_jsonb(other_contact_info) AS other_contact_info,
       personal_info_decrypt_jsonb(vendor_contact_info) AS vendor_contact_info
from pat_personal_main
where pat_id = /* pat_id */1
;
