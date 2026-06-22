UPDATE pat_main
SET device_set_info = (
    jsonb_set(
            jsonb_set(
                    jsonb_set(
                            jsonb_set(
                                    jsonb_set(
                                            jsonb_set(
                                                    jsonb_set(device_set_info, '{ope,dev,A,"90"}', '50', TRUE),
                                                    '{ope,dev,A,"91"}', '33', TRUE),
                                            '{ope,dev,A,"92"}', '6.5', TRUE),
                                    '{ope,dev,B,"40"}', '40', TRUE),
                            '{ope,dev,"C"}', '{}', TRUE),
                    '{ope,dev,C,"91"}', '"-"', TRUE),
            '{ope,dev,C,"92"}', '"-"', TRUE))
WHERE facility_cd = /* facilityCd */null
  -- add #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang start
  AND is_del <> '1'
  AND NOT COALESCE(jsonb_exists((device_set_info #> '{ope,dev,A}'), '90'), FALSE);
  -- add #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang end
