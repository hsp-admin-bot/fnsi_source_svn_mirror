        select distinct
               pem.pat_id
          from ord_prescription as pem
    /*%if ""!= issueStatusFlag && issueStatusFlag == "1" */
    inner join ord_main om
            on om.pat_id = pem.pat_id
           and om.facility_cd = /* facilityCd */''
           and om.treat_date between /* issueFromDate */'' and /* issueToDate */''
           and om.rst_dialysis_state >= '0'
           and om.is_del = '0'
    /*%end */
    /*%if ""!= issueStatusFlag && issueStatusFlag == "2" */
    inner join ord_main om
            on om.pat_id = pem.pat_id
           and om.facility_cd = /* facilityCd */''
           and om.treat_date between /* issueFromDate */'' and /* issueToDate */''
           and om.rst_dialysis_state > '0'
           and om.is_del = '0'
    /*%end */
         where pem.pat_id in /* patIds */(null)
           and pem.facility_cd = /* facilityCd */''
           and pem.is_del = '0'
    /*%if ""!= issueStatusFlag && issueStatusFlag == "1" */
           and pem.issue_state >= '0'
    /*%end */
    /*%if ""!= issueStatusFlag && issueStatusFlag == "2" */
           and pem.issue_state > '0'
    /*%end */
    /*%if issueFromDate != null*/
           and pem.issue_date between /* issueFromDate */'' and /* issueToDate */''
    /*%end*/
--     add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
    and pem.prescription_type IN /* prescriptionClassList */(null)
--     add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
