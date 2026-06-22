update ord_weight_scale
set weight_scale_status = 4, -- 条件送信失敗
    message = '通信サーバータイムアウト',
    up_date = now()
where
    facility_cd = /*facilityCd*/null and
/*%if ordNo != null && machineNo != null*/
    (ord_no = /*ordNo*/0 or machine_no = /*machineNo*/0) and
/*%elseif ordNo != null*/
    ord_no = /*ordNo*/0 and
/*%elseif machineNo != null*/
    machine_no = /*machineNo*/0 and
/*%end*/
    weight_scale_status = 1
;