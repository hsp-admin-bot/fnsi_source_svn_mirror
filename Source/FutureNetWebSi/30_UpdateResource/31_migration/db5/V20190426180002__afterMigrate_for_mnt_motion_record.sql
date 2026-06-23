---------------------------------------------------
-- 対処ボタン不具合対応　NKK青田　2019/04/26
---------------------------------------------------
UPDATE mnt_motion_record SET is_correction = 0 WHERE data_type = '2' AND is_correction is null;
