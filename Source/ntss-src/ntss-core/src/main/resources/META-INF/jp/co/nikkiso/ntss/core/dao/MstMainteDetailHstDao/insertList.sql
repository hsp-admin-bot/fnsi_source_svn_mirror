
INSERT INTO mst_mainte_detail_hst (
  mainte_detail_cd,
  edition_no,
  facility_cd,
  mainte_category_cd,
  mainte_content_1,
  mainte_content_2,
  mainte_content_3,
  is_disp,
  is_del,
  up_date,
  reg_date)
VALUES 
    /*%for  mstMainteDetailHst : mstMainteDetailHsts*/
      (
        /* mstMainteDetailHst.mainteDetailCd*/0,
        /* mstMainteDetailHst.editionNo*/0,
        /* mstMainteDetailHst.facilityCd*/'000000',
        /* mstMainteDetailHst.mainteCategoryCd*/1,
        /* mstMainteDetailHst.mainteContent1*/null,
        /* mstMainteDetailHst.mainteContent2*/null,
        /* mstMainteDetailHst.mainteContent3*/null,
        /* mstMainteDetailHst.isDisp*/1,
        /* mstMainteDetailHst.isDel*/0,
        current_timestamp,
        current_timestamp)
        /*%if mstMainteDetailHst_has_next */
                /*# "," */
        /*%end*/

     /*%end*/
