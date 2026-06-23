UPDATE "ntss"."mst_coop_facility" 
SET
    if_edge_setting = jsonb_set( 
        if_edge_setting
        , '{response_telegram}'
        , ( 
            SELECT
                jsonb_agg( 
                    CASE 
                        WHEN (item ->> 'socket-type') = 'csi' 
                            THEN jsonb_set( 
                            item
                            , '{response_success}'
                            , jsonb_set( 
                                item -> 'response_success'
                                , '{header_length}'
                                , '23' ::jsonb
                            ) || '{"header": [
                        {"name": "DataLength", "value": "000000", "length": 6},
                        {"name": "ErrorCode", "value": "$TYPENAME", "length": 2},
                        {"name": "DllErrorCodeLen", "value": "000000000000000", "length": 15},
                        {"name": "IsUseCoopOrdNo", "value": "", "length": 0}
                    ]}'
                             ::jsonb
                        ) 
                        ELSE item 
                        END
                ) 
            FROM
                jsonb_array_elements(if_edge_setting -> 'response_telegram') AS item
        )
    ) 
    , up_date = CURRENT_TIMESTAMP 
WHERE
    "ctl_no" BETWEEN - 1000 AND 0;
