
INSERT INTO mst_mainte_category_hst (
  mainte_category_cd,
  edition_no,
  facility_cd,
  category_name,
  is_disp,
  is_del,
  up_date,
  reg_date)
VALUES 
    /*%for  mstMainteCategoryHst : mstMainteCategoryHsts*/
      (
        /* mstMainteCategoryHst.mainteCategoryCd*/0,
        /* mstMainteCategoryHst.editionNo*/0,
        /* mstMainteCategoryHst.facilityCd*/'000000',
        /* mstMainteCategoryHst.categoryName*/null,
        /* mstMainteCategoryHst.isDisp*/1,
        /* mstMainteCategoryHst.isDel*/0,
        current_timestamp,
        current_timestamp)
        /*%if mstMainteCategoryHst_has_next */
                /*# "," */
        /*%end*/

     /*%end*/
