ALTER TABLE pat_insurance ADD COLUMN IF NOT EXISTS old_up_date timestamp(3);
ALTER TABLE pat_personal_main ADD COLUMN IF NOT EXISTS old_up_date_personal timestamp(3);
