-- データ型変更

ALTER TABLE mst_machine_type
 ALTER COLUMN treat_mode TYPE character varying(11);

-- コメント追加
COMMENT ON COLUMN "mst_machine_type"."treat_mode" IS E'装置モード';


-- 装置モードの11桁目の更新
-- ABP-01とTR-2020のみON、それ以外はOFF

UPDATE mst_machine_type
SET treat_mode = 
 CASE 
   WHEN char_length(treat_mode) = 10 THEN
     CASE 
       WHEN machine_type IN('ABP-01','TR-2020') THEN treat_mode || '1' 
       ELSE treat_mode || '0'
     END
   ELSE treat_mode
 END
