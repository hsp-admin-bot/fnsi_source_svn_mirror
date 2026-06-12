SELECT
		/*%expand "A" */*
FROM
		mst_mainte_layout_hst A
WHERE
		facility_cd = /* facilityCd*/'000000'
	AND
		/*%if devMenteMains != null && devMenteMains.size() != 0*/
			/*%for devMenteMain : devMenteMains*/
				(
					mainte_layout_cd = /* devMenteMain.menteLayoutCd*/0
					AND
					edition_no = /* devMenteMain.mainteLayoutEdition*/0
				)
				/*%if devMenteMain_has_next */
					/*# "or" */
				/*%end*/
			/*%end*/
		/*%else*/
			mainte_layout_cd = 0
		/*%end*/
