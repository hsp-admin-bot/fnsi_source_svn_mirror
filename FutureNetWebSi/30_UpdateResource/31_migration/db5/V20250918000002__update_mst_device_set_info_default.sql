-- #11124 酸素飽和度対応
-- ΔSO2低下報知点(476)追加
UPDATE ntss.mst_device_set_info_default SET device_set_info = jsonb_set(device_set_info, '{pat,bv,dev,A,476}', '0');
