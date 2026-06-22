--薬剤(削除済を含む)
  select
    /*%expand "A" */*
  from
    mst_medicine A   --テーブル名
      --add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi start
      left join (select mss.facility_cd,
                        ms.*,
                        row_number() over () as index
                 from mst_selector mss
                        cross join lateral jsonb_to_recordset(mss.order_settings -> 'items') as ms
                   (code bigint, name text)
                 where
                   /*%if params.facilityCd != null */
                     facility_cd = /* params.facilityCd*/'0'
                   and
                   /*%end */
                     master_physical_name = 'mst_medicine') ms
                on A.facility_cd = ms.facility_cd and A.medicine_cd = ms.code
      --add #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi end
      where
            /*%if params.facilityCd != null */
                A.facility_cd = /* params.facilityCd*/'0'
            /*%end */
      order by
--del #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi start
--     A.medicine_cd
--del #9589 禁忌・アレルギーマスタ詳細の重複登録と選択状態 20231030 zhaoqi end
ms.index
;
