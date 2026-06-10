update
    mst_device_set_info_default
set device_set_info = device_set_info #- '{pat,ope,dev,A,"90"}' #- '{pat,ope,dev,A,"91"}' #- '{pat,ope,dev,A,"92"}'
                          #- '{pat,ope,dev,B,"40"}' #-'{pat,ope,dev,C,"91"}' #-'{pat,ope,dev,C,"92"}',
    up_date         = CURRENT_TIMESTAMP
where facility_cd = /* facilityCd */null
;