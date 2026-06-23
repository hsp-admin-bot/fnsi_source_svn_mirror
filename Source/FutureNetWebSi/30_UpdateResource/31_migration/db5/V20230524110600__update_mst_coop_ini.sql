UPDATE mst_coop_ini
SET coop_ini_info = jsonb_insert(coop_ini_info, '{-1}',
                                 '
                                   {
                                     "key0": "SSI",
                                     "key1": "PAT_SCOPE",
                                     "key2": "ind_dial",
                                     "value": "0",
                                     "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
                                     "default_v": "0",
                                     "is_effect": "1"
                                   }
                                 '::jsonb)
WHERE
        facility_cd = 'S_hosp';
UPDATE mst_coop_ini
SET coop_ini_info = jsonb_insert(coop_ini_info, '{-1}',
                                 '
                                   {
                                     "key0": "SSI",
                                     "key1": "PAT_SCOPE",
                                     "key2": "rst_dial",
                                     "value": "0",
                                     "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
                                     "default_v": "0",
                                     "is_effect": "1"
                                   }
                                 '::jsonb)
WHERE
        facility_cd = 'S_hosp';
UPDATE mst_coop_ini
SET coop_ini_info = jsonb_insert(coop_ini_info, '{-1}',
                                 '
                                   {
                                     "key0": "SSI",
                                     "key1": "PAT_SCOPE",
                                     "key2": "rep_dial",
                                     "value": "0",
                                     "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
                                     "default_v": "0",
                                     "is_effect": "1"
                                   }
                                 '::jsonb)
WHERE
        facility_cd = 'S_hosp';
UPDATE mst_coop_ini
SET coop_ini_info = jsonb_insert(coop_ini_info, '{-1}',
                                 '
                                   {
                                     "key0": "SSI",
                                     "key1": "PAT_SCOPE",
                                     "key2": "karte_ord",
                                     "value": "0",
                                     "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
                                     "default_v": "0",
                                     "is_effect": "1"
                                   }
                                 '::jsonb)
WHERE
        facility_cd = 'S_hosp';
UPDATE mst_coop_ini
SET coop_ini_info = jsonb_insert(coop_ini_info, '{-1}',
                                 '
                                   {
                                           "key0": "CSI",
                                           "key1": "PAT_SCOPE",
                                           "key2": "profile",
                                           "value": "0",
                                           "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
                                           "default_v": "0",
                                           "is_effect": "1"
                                       }
                                 '::jsonb)
WHERE
        facility_cd = 'C_hosp';
UPDATE mst_coop_ini
SET coop_ini_info = jsonb_insert(coop_ini_info, '{-1}',
                                 '
                                   {
                                           "key0": "CSI",
                                           "key1": "PAT_SCOPE",
                                           "key2": "ind_dial",
                                           "value": "0",
                                           "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
                                           "default_v": "0",
                                           "is_effect": "1"
                                       }
                                 '::jsonb)
WHERE
        facility_cd = 'C_hosp';
UPDATE mst_coop_ini
SET coop_ini_info = jsonb_insert(coop_ini_info, '{-1}',
                                 '
                                   {
                                           "key0": "CSI",
                                           "key1": "PAT_SCOPE",
                                           "key2": "rst_dial",
                                           "value": "0",
                                           "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
                                           "default_v": "0",
                                           "is_effect": "1"
                                       }
                                 '::jsonb)
WHERE
        facility_cd = 'C_hosp';
UPDATE mst_coop_ini
SET coop_ini_info = jsonb_insert(coop_ini_info, '{-1}',
                                 '
                                   {
                                           "key0": "CSI",
                                           "key1": "PAT_SCOPE",
                                           "key2": "rep_dial",
                                           "value": "0",
                                           "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
                                           "default_v": "0",
                                           "is_effect": "1"
                                       }
                                 '::jsonb)
WHERE
        facility_cd = 'C_hosp';
UPDATE mst_coop_ini
SET coop_ini_info = jsonb_insert(coop_ini_info, '{-1}',
                                 '
                                   {
                                           "key0": "CSI",
                                           "key1": "PAT_SCOPE",
                                           "key2": "exam_ord",
                                           "value": "0",
                                           "comment": "0:登録済患者（初期値）1:プロファイル連携済患者のみ　2:特殊（富士通・NEC)",
                                           "default_v": "0",
                                           "is_effect": "1"
                                       }
                                 '::jsonb)
WHERE
        facility_cd = 'C_hosp';