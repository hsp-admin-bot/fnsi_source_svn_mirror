SELECT
  /*%expand "A" */*
FROM
  mst_mainte_detail_hst A
  -- add FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 start
-- del FNSI-改修内容 点検項目入力の表示順を修正する 陳 start
--  ,(
--    SELECT
--      ms.code,
--      row_number() over()  as index
--    FROM
--      mst_selector mss
--    CROSS JOIN lateral jsonb_to_recordset(mss.order_settings->'items') as ms
--      (
--        code bigint,
--        name text
--      )
--    WHERE
--    		facility_cd = /*facilityCd*/'00000'
--	AND
--		master_physical_name = 'mst_mainte_detail' --テーブル名
--  ) ms
-- del FNSI-改修内容 点検項目入力の表示順を修正する 陳 end
  -- add FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 end
WHERE

  /*%if cusMenteDetailResults != null && cusMenteDetailResults.size() != 0*/
    /*%for  cusMenteDetailResult : cusMenteDetailResults*/
      (
        mainte_detail_cd = /* cusMenteDetailResult.detail_cd*/0
-- mod FNSI-改修内容 点検項目入力の表示順を修正する 陳 start
--        AND edition_no = /* cusMenteDetailResult.edition*/0
        AND edition_no = /* cusMenteDetailResult.detail_edi*/0
-- mod FNSI-改修内容 点検項目入力の表示順を修正する 陳 end
        -- add FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 start
-- del FNSI-改修内容 点検項目入力の表示順を修正する 陳 start
--        AND mainte_detail_cd = ms.code
-- del FNSI-改修内容 点検項目入力の表示順を修正する 陳 end
        -- add FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 end
      )
      /*%if cusMenteDetailResult_has_next */
        /*# "or" */
      /*%end*/
    /*%end*/
  /*%else*/
    mainte_detail_cd = 0
  /*%end*/
-- mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 start
-- ORDER BY mainte_category_cd
-- del FNSI-改修内容 点検項目入力の表示順を修正する 陳 start
--ORDER BY ms.index
-- del FNSI-改修内容 点検項目入力の表示順を修正する 陳 end
-- mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 end
