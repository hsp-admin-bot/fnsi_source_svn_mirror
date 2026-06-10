UPDATE mst_device_set_info_default
SET device_set_info = (
    jsonb_set(
            jsonb_set(
                    jsonb_set(
                            jsonb_set(
                                    jsonb_set(
                                            jsonb_set(
                                                    jsonb_set(device_set_info, '{pat,ope,dev,A,"90"}', '50', TRUE),
                                                    '{pat,ope,dev,A,"91"}', '33', TRUE),
                                            '{pat,ope,dev,A,"92"}', '6.5', TRUE),
                                    '{pat,ope,dev,B,"40"}', '40', TRUE),
                            '{pat,ope,dev,"C"}', '{}', TRUE),
                    '{pat,ope,dev,C,"91"}', '"-"', TRUE),
            '{pat,ope,dev,C,"92"}', '"-"', TRUE))
WHERE facility_cd = /* facilityCd */null
-- add #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang start
AND NOT COALESCE(jsonb_exists((device_set_info #> '{pat,ope,dev,A}'), '90'), FALSE);
-- add #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang end
