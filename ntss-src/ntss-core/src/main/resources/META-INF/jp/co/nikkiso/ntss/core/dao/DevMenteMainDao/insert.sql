insert into mnt_mainte_main (
        mainte_no,
        facility_cd,
        mainte_class,
        machine_no,
        rec_no,
        mainte_date,
        mainte_layout_group_cd,
        mainte_layout_group_edition,
        mainte_layout_cd,
        mainte_layout_edition,
        mainte_category_cd,
        checker_id_1,
        checker_id_2,
        mainte_ans_1,
        mainte_comment_1,
        detail,
        is_disp,
        is_del,
        up_date,
        reg_date)
    values(
        /* devMenteMain.devMenteNo */0,
        /* devMenteMain.facilityCd */'0',
        /* devMenteMain.menteClass*/'0',
        /* devMenteMain.machineNo*/0,
        /* devMenteMain.recNo*/0,
        /* devMenteMain.menteDate*/'2010-01-01',
        /* devMenteMain.menteLayoutGroupCd*/0,
        /* devMenteMain.mainteLayoutGroupEdition*/0,
        /* devMenteMain.menteLayoutCd*/0,
        /* devMenteMain.mainteLayoutEdition*/0,
        /* devMenteMain.mainteCategoryCd*/0,
        /* devMenteMain.checkerId1*/0,
        /* devMenteMain.checkerId2*/0,
        /* devMenteMain.menteAns1*/'0',
        /* devMenteMain.menteComment1*/null,
        /* devMenteMain.detail*/'[]',
        /* devMenteMain.isDisp*/'1',
        /* devMenteMain.isDel*/'0',
        /* devMenteMain.upDate*/null,
         /* devMenteMain.regDate*/null
         )
;
  select
        /*%expand "A" */*
  from
          mnt_mainte_main A
  where
          mainte_no = /* devMenteMain.devMenteNo */'0';
