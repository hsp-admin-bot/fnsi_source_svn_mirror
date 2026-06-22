SELECT motion_rec.event_reg_date,
		s2.bed_name,
		s.pat_id,
		motion_rec.machine_record_message,
		motion_rec.machine_record_cd,
        -- add FNSI-警報・報知追加 付 start
		motion_rec.machine_type_cd,
		motion_rec.machine_serial,
		-- add FNSI-警報・報知追加 付 end
		motion_rec.ord_no
FROM ntss.mnt_motion_record motion_rec
LEFT JOIN ntss.ord_main s
  ON motion_rec.ord_no = s.ord_no
LEFT JOIN ntss.mst_machine s1
  ON  motion_rec.facility_cd = s1.facility_cd
       and motion_rec.machine_type_cd = s1.machine_type_cd
       and motion_rec.machine_serial = s1.machine_serial
LEFT join ntss.mst_bed s2
  ON s2.facility_cd=s1.facility_cd
  and s2.machine_no = s1.machine_no
WHERE motion_rec.data_type = '1'
  AND
  -- mod FNSI-bse confirm as error 付 start
   --((motion_rec.machine_record_cd  >= '4000' AND motion_rec.machine_record_cd <= '5FFF')
  --OR
   --(motion_rec.machine_record_cd  >= '8000' AND motion_rec.machine_record_cd <= '9FFF'))
    motion_rec.machine_record_cd BETWEEN '0000' AND 'FFFF'
   -- mod FNSI-bse confirm as error 付 end
  AND
    motion_rec.facility_cd = /*facilityCd*/'000000'
  AND
    motion_rec.event_reg_date BETWEEN /*occurDateStart*/'2018/01/01 00:00:00' AND /*occurDateEnd*/'2018/01/01 23:59:59'
ORDER BY
  motion_rec.event_reg_date DESC

;
