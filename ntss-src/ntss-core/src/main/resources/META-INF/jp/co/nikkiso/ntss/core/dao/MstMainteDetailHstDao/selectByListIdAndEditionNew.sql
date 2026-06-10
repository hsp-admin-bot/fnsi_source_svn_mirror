SELECT
  /*%expand "A" */*
FROM
  mst_mainte_detail_hst A
WHERE
    facility_cd = /* facilityCd*/''  AND
  /*%if cusMenteDetailResults != null && cusMenteDetailResults.size() != 0*/
    /*%for  cusMenteDetailResult : cusMenteDetailResults*/
      (
         mainte_detail_cd = /* cusMenteDetailResult.detail_cd*/0
        AND edition_no = /* cusMenteDetailResult.edition*/0

      )
      /*%if cusMenteDetailResult_has_next */
        /*# "or" */
      /*%end*/
    /*%end*/
  /*%else*/
    mainte_detail_cd = 0
  /*%end*/
-- ORDER BY
