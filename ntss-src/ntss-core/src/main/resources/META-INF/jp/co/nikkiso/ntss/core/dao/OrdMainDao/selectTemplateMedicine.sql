SELECT mst.medicine_cd                                  -- 薬剤コード
     , cls.class_name                                   -- 分類名称
  FROM mst_medicine mst                                 -- 薬剤マスタ
 INNER JOIN mst_medicine_class cls                      -- 薬剤分類マスタ
    ON cls.class_cd    = mst.class_cd                   -- 薬剤分類コード
   AND cls.is_del      = '0'                            -- 削除フラグ
   AND cls.is_disp     = '1'                            -- 表示フラグ
 WHERE mst.is_del      = '0'                            -- 削除フラグ
   AND mst.is_disp     = '1'                            -- 表示フラグ
   AND mst.facility_cd = /*facilityCd*/NULL             -- 施設コード
