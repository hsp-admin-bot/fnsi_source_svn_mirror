
INSERT INTO mst_mainte_layout_group_hst (
  mainte_layout_group_cd,
  edition_no,
  facility_cd,
  group_name,
  layout_list,
  is_disp,
  is_del,
  up_date,
  reg_date)
VALUES 
    /*%for  mstMainteLayoutGroupHst : mstMainteLayoutGroupHsts*/
      (
        /* mstMainteLayoutGroupHst.mainteLayoutGroupCd*/0,
        /* mstMainteLayoutGroupHst.editionNo*/0,
        /* mstMainteLayoutGroupHst.facilityCd*/'000000',
        /* mstMainteLayoutGroupHst.groupName*/1,
        /* mstMainteLayoutGroupHst.layoutList*/null,
        /* mstMainteLayoutGroupHst.isDisp*/1,
        /* mstMainteLayoutGroupHst.isDel*/0,
        current_timestamp,
        current_timestamp)
        /*%if mstMainteLayoutGroupHst_has_next */
                /*# "," */
        /*%end*/

     /*%end*/
