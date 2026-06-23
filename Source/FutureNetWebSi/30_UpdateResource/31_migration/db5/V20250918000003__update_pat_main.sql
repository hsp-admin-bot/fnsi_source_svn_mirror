-- #11124 酸素飽和度対応
-- ΔSO2低下報知点(476)追加
UPDATE ntss.pat_main SET device_set_info = jsonb_set(device_set_info, '{bv,dev,A,476}', '0') where is_del = '0';
