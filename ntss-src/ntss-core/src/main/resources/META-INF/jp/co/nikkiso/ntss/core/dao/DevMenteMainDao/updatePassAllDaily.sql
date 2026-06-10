UPDATE
		mnt_mainte_main
SET
		mainte_ans_1 = '1',
		checker_id_1 = /* checkerId */'0',
		detail = /* detail*/null,
		up_date = /* update*/'2010-01-01'

WHERE
    /*%if devMenteMains != null && devMenteMains.size() != 0*/
        /*%for  devMenteMain : devMenteMains*/
            mainte_no = /* devMenteMain.devMenteNo*/'0'
            /*%if devMenteMain_has_next */
                  /*# "or" */
            /*%end*/
        /*%end*/
    /*%else*/
      mainte_no = 0
    /*%end*/
