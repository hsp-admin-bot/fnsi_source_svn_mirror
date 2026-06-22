SELECT
		/*%expand "A" */*
FROM
		mst_mainte_category_hst A
WHERE

		/*%if cusMainteCategoryResults != null && cusMainteCategoryResults.size() != 0*/
        /*%for  cusMainteCategoryResult : cusMainteCategoryResults*/
						(
							mainte_category_cd = /* cusMainteCategoryResult.mainteCategoryCd*/0
							AND
							edition_no = /* cusMainteCategoryResult.editionNo*/0
						)
            /*%if cusMainteCategoryResult_has_next */
                  /*# "or" */
            /*%end*/
        /*%end*/
    /*%else*/
      mainte_category_cd = 0
    /*%end*/
