-- mnt_machine_state のデータ変更
UPDATE mnt_machine_state SET use_time = '{"1": 101, "2": 102, "3": 103, "4": 104, "5": 105, "6": 106, "7": 107, "8": 108, "9": 109, "10": 110, "11": 111, "12": 112, "13": 113, "14": 114, "15": 115}' 
WHERE facility_cd = '009999' AND (machine_type_cd = '026' OR machine_type_cd = '011')  AND machine_serial = '00999901'
;