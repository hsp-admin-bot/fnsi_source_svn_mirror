select
-- add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
	B.facility_name,
-- add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end
	A.ord_prescription_no,
	A.facility_cd,
	A.pat_id,
	A.prescription_type,
	replace(substring(to_timestamp(A.issue_date, 'YYYYMMDD')::text, 1, 10), '-', '/') as issue_date,
	A.issue_state,
	replace(substring(to_timestamp(A.expiration_date, 'YYYYMMDD')::text, 1, 10), '-', '/') as expiration_date,
	A.prescription_detail,
	A.is_disp,
	A.is_del,
	A.reg_date,
	A.up_date
from
	ord_prescription A
-- add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
left join
    mst_facility B
on  A.facility_cd = B.facility_cd
-- add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end
where
	A.is_disp = '1' and A.is_del = '0'

	and (
		(
			1=1
			/*%if issueDateFrom != null */
			and to_timestamp(A.issue_date, 'YYYYMMDD') >= /* issueDateFrom */'1920/01/01 00:00:00'
			/*%end */
			/*%if issueDateTo != null */
			and to_timestamp(A.issue_date, 'YYYYMMDD') <= /* issueDateTo */'2099/02/20 00:00:00'
			/*%end */
			/*%if prescriptionType != null */
			and A.prescription_type = /* prescriptionType */'0'
			/*%end */
			/*%if issueState != null */
			and A.issue_state = /* issueState */'0'
			/*%end */
		)
		/*%if ordPrescriptionNoList != null */
		or A.ord_prescription_no in /* ordPrescriptionNoList */(null)
		/*%end */
	)
-- mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou start
-- and A.facility_cd = /*facilityCd*/'000000'
/*%if facilityCd != null */
and A.facility_cd = /*facilityCd*/'000000'
/*%end*/
-- mod FNSI-改修内容 他施設の場合、浅黄色背景にする dou end
and A.pat_id = /*patId*/0

/*%if regDate != null */
and A.reg_date = /*regDate*/'2099/02/20 00:00:00'
/*%end*/
ORDER BY A.issue_date
;
