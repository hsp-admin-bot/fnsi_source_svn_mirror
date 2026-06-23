--004：個人用透析装置, 005：透析装置の場合、透析装置と認識で、対応可否フラグ(特殊浄化)がNULLの場合、'1'を更新する
UPDATE mst_machine SET is_support_blood_purify = '1' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_blood_purify IS NULL AND mmt.model IN ('004', '005');
--004：個人用透析装置, 005：透析装置以外場合、透析装置以外と認識で、対応可否フラグ治療方法がNULLの場合、'0'を更新する
UPDATE mst_machine SET is_support_hd = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_hd IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_ecum = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_ecum IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_hdf = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_hdf IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_hf = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_hf IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_hd_ho = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_hd_ho IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_ecum_ho = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_ecum_ho IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_afbf = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_afbf IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_ohdf = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_ohdf IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_ohf = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_ohf IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_i_hdf = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_i_hdf IS NULL AND mmt.model NOT IN ('004', '005');
UPDATE mst_machine SET is_support_blood_purify = '0' FROM mst_machine_type mmt WHERE mst_machine.machine_type_cd = mmt.machine_type_cd AND is_support_blood_purify IS NULL AND mmt.model NOT IN ('004', '005');
