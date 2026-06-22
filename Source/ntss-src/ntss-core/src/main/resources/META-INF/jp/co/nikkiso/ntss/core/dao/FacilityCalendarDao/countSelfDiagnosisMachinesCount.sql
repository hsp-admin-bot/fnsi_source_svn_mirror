 SELECT COUNT(*) AS sum_count                                                   -- 診断対象の合計
   FROM mst_machine machine                                                     -- 装置マスタテーブル
  INNER JOIN mst_machine_type mst                                               -- 型式マスタテーブル
     ON machine.machine_type_cd = mst.machine_type_cd                           -- 型式コード
    AND mst.model BETWEEN '004' AND '005'                                       -- 機種
  WHERE machine.facility_cd = /*facilityCd*/NULL                                -- 施設コード
    AND machine.is_disp = '1'                                                   -- 表示フラグ
    AND machine.is_del = '0'                                                    -- 削除フラグ
