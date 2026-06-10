UPDATE shr_pat_info
SET
    /*%if shrPatInfo.fromFacilityCd != null */
    from_facility_cd = /* shrPatInfo.fromFacilityCd */'999999',
    /*%end*/

    /*%if shrPatInfo.fromPatId != null */
    from_pat_id = /* shrPatInfo.fromPatId */null,
    /*%end*/

    /*%if shrPatInfo.toFacilityCd != null */
    to_facility_cd = /* shrPatInfo.toFacilityCd */null,
    /*%end*/

    /*%if shrPatInfo.toPatId != null */
    to_pat_id = /* shrPatInfo.toPatId */null,
    /*%end*/

    /*%if shrPatInfo.shareDirection != null */
    share_direction = /* shrPatInfo.shareDirection */null,
    /*%end*/

    /*%if shrPatInfo.isFromConsent != null */
    is_from_consent = /* shrPatInfo.isFromConsent */'0',
    /*%end*/

    /*%if shrPatInfo.fromUserId != null */
    from_user_id = /* shrPatInfo.fromUserId */null,
    /*%end*/

    /*%if shrPatInfo.isToConsent != null */
    is_to_consent = /* shrPatInfo.isToConsent */null,
    /*%end*/

    /*%if shrPatInfo.toUserId != null */
    to_user_id = /* shrPatInfo.toUserId */null,
    /*%end*/

    /*%if shrPatInfo.isPatConsent != null */
    is_pat_consent = /* shrPatInfo.isPatConsent */null,
    /*%end*/

    /*%if shrPatInfo.shrAttachment != null */
    shr_attachment = /* shrPatInfo.shrAttachment */'[]',
    /*%end*/

    /*%if shrPatInfo.isDisp != null */
    is_disp = /* shrPatInfo.isDisp */'1',
    /*%end*/

    /*%if shrPatInfo.isDel != null */
    is_del = /* shrPatInfo.isDel */'0',
    /*%end*/

    /*%if shrPatInfo.fromUpdUserId != null */
    from_upd_user_id = /* shrPatInfo.fromUpdUserId */null,
     /*%end*/

    /*%if shrPatInfo.fromUpDate != null && true */
    from_up_date = /* shrPatInfo.fromUpDate */null,
    /*%end*/

    /*%if shrPatInfo.toUpDate != null && true */
    to_up_date  = /* shrPatInfo.toUpDate */null,
    /*%end*/


    /*%if shrPatInfo.toUpdUserId != null */
    to_upd_user_id = /* shrPatInfo.toUpdUserId */null,
    /*%end*/

    reg_date = CURRENT_TIMESTAMP(3)
WHERE shr_pat_info_id = /* shrPatInfo.shrPatInfoId */0
AND is_del = '0'
