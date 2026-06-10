select
  /*%expand*/*
from
 ord_main
where
/*%if 1 == mode*/
-- updateOrdMainRstUserInfo updateTreatmentRecordForVersionInfo updateTreatmentRecordForRoundsInfo updateTmpReportInfo
-- updateTreatmentRecordForConfirm updateWeightScaleNo updateWeightInfo updateWeightBefore updateWeightAfter
-- updateTareAndOffWater updateScheduleAssignment updateRstTareOffWaterInfo updateRstTareAndOffWater updateRstTare
-- updateRstOffWater updateRstDialysisCnt updateReturnHomeDateAndState updatePatId updateOrdMainMediInfo
-- updateOrdMainEquipInfo updateMediInfo updateManualAddInfoById updateIndTreatVa updateIndTareOffWaterInfo
-- updateIndStartTareAndOffWater updateIndRstDw updateDeviceSetInfo updateDeleteByOrdNo updateCommentInfo
-- updateCheckAfterWeight updateCancelSendCondition updateBeforeWeight updateAdditionInfoById moveDataToIndDate
-- immediateCommitTare immediateCommitOffWater deleteCommentInfo updateOrdMainStatus updateOrdMain updateTreatStaffAdd
-- updateTreatmentAdd updateStartDate updateSendDate updateRstWeight updateRstMonitor updateReturnUser updatePunctureUser
-- updatePullLeaveAmount updateOxygenAdd updateMediInfo updateEndDate updateComplaintAdd updateChargeUser
 ord_no = /*ordNo*/'1'

/*%elseif 2 == mode */
-- updateDeleteByPatId
 pat_id = /*patId*/0

/*%elseif 3 == mode */
-- updateTreatMethod updateTreatmentMethod updateRstTreatmentMethod updateRstOrdMainInfo updateOrdMainScheduleInfo
-- updateOrdMainInfo updateIndCondInfoWithTreatCondSetting deleteByOrdNo
 ord_no in /*ordNoList*/()

/*%elseif 4 == mode */
-- updateByIndKurCd
ord_no in (
  select
    ord_no
  from
    ord_main
  where
    facility_cd = /*facilityCd*/null
  and
    ind_kur_cd in /*kurList*/(null)
)

/*%elseif 5 == mode */
-- updateIndCondInfoWithTreatMethodNonReplenish
ord_no IN
	(
		SELECT
			ord_no
		FROM
      ord_main A
		LEFT JOIN
      mst_treatment B
		ON
      A.ind_treatment_cd = B.treatment_cd
		WHERE
      A.ord_no IN /*ordNoList*/() AND
			B.device_mode IN (0,1)
	)
/*%elseif 6 == mode */
-- updateIndCondInfoWithTreatMethodReplenish
ord_no IN
	(
		SELECT
			ord_no
		FROM
      ord_main A
		LEFT JOIN
      mst_treatment B
		ON
      A.ind_treatment_cd = B.treatment_cd
		WHERE
      A.ord_no IN /*ordNoList*/() AND
			B.device_mode IN
      /*%if isOnline*/
      (2,3,5,6,9,-1)
      /*%else*/
			(4,7,8,10)
      /*%end*/
	)

/*%elseif 7 == mode */
-- updateIsConfirm
  ord_no = /*ordNo*/0
AND
  is_confirm = /*updateTargetIsConfirm*/'1'

/*%elseif 8 == mode */
-- updateRstDeviceSetInfo
  /*%if null != ordNo*/
    ord_no = /*ordNo*/0
  /*%else*/
    pat_id = /*patId*/0
  AND
    facility_cd = /*facilityCd*/'000000'
    /*%if null != startDate*/
  AND
    treat_date >= /*startDate*/'20180401'
    /*%end*/
    /*%if null != endDate*/
  AND
    treat_date <= /*endDate*/'20180431'
    /*%end*/
    /*%if 0 != week.size()*/
  AND
    treat_week in /*week*/(0)
    /*%end*/
    /*%if 0 != treatMethod.size()*/
  AND
    ind_treatment_cd in /*treatMethod*/()
    /*%end*/
    /*%if 0 != kurList.size()*/
  AND
    ind_kur_cd in /*kurList*/(0)
    /*%end*/
  /*%end*/

/*%elseif 9 == mode */
-- updateOrdMainData
  ord_no = /*ordNo*/0
  and
  facility_cd = /*facilityCd*/''
  and
  treat_date = /*condTreatDate*/''

/*%elseif 10 == mode */
-- updateTreatmentRecordForWeight updateTreatmentRecordForResultMerge updateTreatmentRecordForResult
-- updateTreatmentRecordForEquipInfo updateTreatmentRecordForCondition updateTreatmentRecordForAddition
-- updateTreatmentRecordForMediInfo updateTreatmentRecordComplaint 8
  ord_no = /*ordNo*/1
and
  is_del = '0'

/*%elseif 11 == mode */
-- updateDeviceInfo
  /*%if null != ordNo*/
    ord_no = /*ordNo*/0
  /*%else*/
    pat_id = /*patId*/0
  and
    facility_cd = /*facilityCd*/'000001'
    --startDateがnullなら処理を行わないとしているが後で変更必要!!!!!!!!!
    /*%if null != startDate*/
  and
    treat_date >= /*startDate*/'20180220'
    /*%end*/
    /*%if null != endDate*/
  and
    treat_date <= /*endDate*/'20191231'
    /*%end*/
    /*%if 0 != week.size()*/
  and
    treat_week in /* week */(1,2,3)
    /*%end*/
    /*%if 0 != treatMethod.size()*/
  and
    ind_treatment_cd in /*treatMethod*/(1,2,3)
    /*%end*/
    /*%if 0 != kurList.size()*/
  and
    ind_kur_cd in /*kurList*/(1,2,3)
    /*%end*/
  /*%end*/

/*%elseif 12 == mode */
-- updateFutureIndTareAndOffWater
    pat_id = /*patId*/0
  AND
    treat_date >= /*treatDate*/'00000000'
  AND
    treat_week = /*treatWeek*/0

/*%elseif 13 == mode */
-- delete
  /*%if null != ordNo */
    ord_no = /*ordNo*/'1'
  /*%else*/
    pat_id = /*patId*/'000000000001'
  and
    treat_date >= /*dialysisDateFrom*/'20180220'
  and
    treat_date <= /*dialysisDateTo*/'20180226'
  and
    is_del = '0'
    /*%if 0 < treatmentCdList.size() */
      and
        ind_treatment_cd in /*treatmentCdList*/(0)
    /*%end*/
    /*%if 0 < kurList.size() */
      and
        ind_kur_cd in /*kurList*/(0)
    /*%end*/
  /*%end*/

/*%end */
;
