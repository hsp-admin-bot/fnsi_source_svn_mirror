DELETE FROM ntss.pat_unique WHERE pat_id in (select pat_id from ntss.pat_main where facility_cd = 'F_h700');
DELETE FROM ntss.pat_main WHERE facility_cd = 'F_h700';