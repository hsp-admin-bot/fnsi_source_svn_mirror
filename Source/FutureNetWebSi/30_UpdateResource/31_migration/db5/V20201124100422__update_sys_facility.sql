ALTER TABLE ntss.sys_facility DROP CONSTRAINT unq_sys_facility_01;

update ntss.sys_facility set medical_institution_cd = repeat( chr(int4(random()*26)+65),10) where medical_institution_cd is null;
ALTER TABLE ntss.sys_facility ADD CONSTRAINT unq_sys_facility_01 PRIMARY KEY (medical_institution_cd);