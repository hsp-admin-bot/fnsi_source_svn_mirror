update
  pat_main
set
  acceptance_status_info = acceptance_status_info ||  ('{"class": "' || /*statusClass*/'5' || '"}')::jsonb,
  up_date = /*upDate*/null
where
  pat_id = /*patId*/0
;