UPDATE mst_machine_record 
SET
    machine_record_message = '再循環率測定再循環率[{0}%]血液流量[{1,3}mL/min]' ,
    up_date = now()
where
    machine_record_cd = '0106';
