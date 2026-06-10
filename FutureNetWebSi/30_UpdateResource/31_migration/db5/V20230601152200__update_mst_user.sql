UPDATE mst_user 
SET
    user_settings = CASE 
        WHEN jsonb_exists( 
            user_settings -> 'default_setting'
            , 'schedule-list'
        ) 
            THEN jsonb_set( 
            user_settings
            , '{default_setting,schedule-list}'
            , ( 
                user_settings -> 'default_setting' -> 'schedule-list'
            ) - 'selectedBedIndexList' || jsonb_build_object('bedGroupCd', 0)
        ) 
        ELSE user_settings 
        END
    , up_date = CURRENT_TIMESTAMP; 

UPDATE mst_user 
SET
    user_settings = CASE 
        WHEN jsonb_exists( 
            user_settings -> 'default_setting'
            , 'status-list'
        ) 
            THEN jsonb_set( 
            user_settings
            , '{default_setting,status-list}'
            , ( 
                user_settings -> 'default_setting' -> 'status-list'
            ) - 'bedGroupIndex' || jsonb_build_object('bedGroupCd', 0)
        ) 
        ELSE user_settings 
        END
    , up_date = CURRENT_TIMESTAMP; 

UPDATE mst_user 
SET
    user_settings = CASE 
        WHEN jsonb_exists( 
            user_settings -> 'default_setting'
            , 'status-map'
        ) 
            THEN jsonb_set( 
            user_settings
            , '{default_setting,status-map}'
            , ( 
                user_settings -> 'default_setting' -> 'status-map'
            ) - 'bedGroupIndex' || jsonb_build_object('bedGroupCd', 0)
        ) 
        ELSE user_settings 
        END
    , up_date = CURRENT_TIMESTAMP; 

UPDATE mst_user 
SET
    user_settings = CASE 
        WHEN jsonb_exists( 
            user_settings -> 'default_setting'
            , 'check-list'
        ) 
            THEN jsonb_set( 
            user_settings
            , '{default_setting,check-list}'
            , ( 
                user_settings -> 'default_setting' -> 'check-list'
            ) - 'bedGroupIndex' || jsonb_build_object('bedGroupCd', - 1)
        ) 
        ELSE user_settings 
        END
    , up_date = CURRENT_TIMESTAMP;
