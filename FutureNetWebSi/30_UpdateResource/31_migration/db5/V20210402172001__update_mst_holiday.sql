CREATE UNIQUE INDEX mst_holiday_pkey_03 ON ntss.mst_holiday USING btree (holiday_y, facility_cd, "class") WHERE ((is_disp)::text = '1'::text);
DROP INDEX ntss.mst_holiday_pkey_02;