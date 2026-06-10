
INSERT INTO mst_mainte_layout_hst (
  mainte_layout_cd,
  edition_no,
  facility_cd,
  layout_class,
  layout_name,
  type_info,
  detail_info_1,
  detail_info_2,
  is_disp,
  is_del,
  up_date,
  reg_date)
VALUES 
    /*%for  mstMainteLayoutHst : mstMainteLayoutHsts*/
      (
        /* mstMainteLayoutHst.mainteLayoutCd*/0,
        /* mstMainteLayoutHst.editionNo*/0,
        /* mstMainteLayoutHst.facilityCd*/'000000',
        /* mstMainteLayoutHst.layoutClass*/1,
        /* mstMainteLayoutHst.layoutName*/null,
        /* mstMainteLayoutHst.typeInfo*/null,
        /* mstMainteLayoutHst.detailInfo1*/null,
        /* mstMainteLayoutHst.detailInfo2*/null,
        /* mstMainteLayoutHst.isDisp*/1,
        /* mstMainteLayoutHst.isDel*/0,
        current_timestamp,
        current_timestamp)
        /*%if mstMainteLayoutHst_has_next */
                /*# "," */
        /*%end*/

     /*%end*/
