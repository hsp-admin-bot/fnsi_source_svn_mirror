update pat_main set
addition_info='[]'
where addition_info is null;

update pat_main set
charge_staff_info='[]'
where charge_staff_info is null;

update pat_main set
pat_group_info='[]'
where pat_group_info is null;

update pat_main set
taboo_allergy_info='[]'
where taboo_allergy_info is null;

update pat_main set
infect_info='[]'
where infect_info is null;

update pat_main set
implant_info='[]'
where implant_info is null;

update pat_main set
acceptance_status_info='[]'
where acceptance_status_info is null;

update pat_unique set
medical_hst_info='[]'
where medical_hst_info is null;

update pat_unique set
in_out_visit_history_info='[]'
where in_out_visit_history_info is null;

update pat_unique set
physical_info='[]'
where physical_info is null;
