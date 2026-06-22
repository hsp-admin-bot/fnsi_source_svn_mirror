-- 本人連絡先情報、連絡先情報、業者連絡先情報の暗号化
UPDATE
	pat_personal_main
SET
	pat_contact_info = personal_info_encrypt_jsonb(pat_contact_info),
	other_contact_info = personal_info_encrypt_jsonb(other_contact_info),
	vendor_contact_info = personal_info_encrypt_jsonb(vendor_contact_info)
;