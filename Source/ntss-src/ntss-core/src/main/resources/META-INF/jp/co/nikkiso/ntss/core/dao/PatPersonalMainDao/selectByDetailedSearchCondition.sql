select
  pat_id
from
  pat_personal_main
where
  is_del = '0'

--- 施設コードリスト未指定の場合は検索は実行されないので配列長チェックしていない
  and facility_cd in /* facilityCdList */(null)

--- 院内ID(部分一致)
/*%if !conditions.hospPatId.isEmpty() */
  and hosp_pat_id like /* @infix(conditions.hospPatId) */null
/*%end*/

--- 名前・カナ(部分一致)
/*%if !conditions.patName.isEmpty() */
  and (
    personal_info_decrypt(pat_last_name) || personal_info_decrypt(pat_first_name) like /* @infix(conditions.patName) */null
    or
    coalesce(personal_info_decrypt(pat_last_name_kana), '') || coalesce(personal_info_decrypt(pat_first_name_kana), '') like /* @infix(conditions.patName) */null
    or
    coalesce(personal_info_decrypt(pat_last_name_alpha), '') || coalesce(personal_info_decrypt(pat_first_name_alpha), '') like /* @infix(conditions.patName) */null
  )
/*%end*/

--- カナ頭文字(行)
/*%if conditions.nameInitialList.size() > 0 */
  and (
  /*%for nameInitial : conditions.nameInitialList */
    --- 指定カナ行を正規表現で検索(例: 「ア」なら正規表現 ^[ア-オ].*)
    personal_info_decrypt(pat_last_name_kana) ~ (/* "^[" + nameInitial + "].*" */null)
    /*%if nameInitial_has_next */
    or
    /*%end */
  /*%end */
    )
/*%end */

--- 性別
/*%if conditions.patSex.size() > 0 */
  and pat_sex in /* conditions.patSex */(null)
/*%end*/

--- 年齢下限
/*%if conditions.ageLower != null */
  and date_part('year', age(current_date, to_date(pat_birthday, 'YYYYMMDD'))) >= /* conditions.ageLower */null
/*%end*/

--- 年齢上限
/*%if conditions.ageUpper != null */
  and date_part('year', age(current_date, to_date(pat_birthday, 'YYYYMMDD'))) <= /* conditions.ageUpper */null
/*%end*/

--- 血液型ABO
/*%if conditions.bloodTypeAboList.size() > 0 */
  and pat_blood_type_abo in /* conditions.bloodTypeAboList */(null)
/*%end*/

--- 血液型Rh
/*%if conditions.bloodTypeRhList.size() > 0 */
  and pat_blood_type_rh in /* conditions.bloodTypeRhList */(null)
/*%end*/

--- 血液型亜型
/*%if conditions.bloodTypeSerovarList.size() > 0 */
  and pat_blood_type_serovar in /* conditions.bloodTypeSerovarList */(null)
/*%end*/

--- 入外区分
/*%if conditions.inOutClassList.size() > 0 */
  and in_out_class in /* conditions.inOutClassList */(null)
/*%end*/
--- 連絡先氏名
/*%if !conditions.lastName.isEmpty() || !conditions.firstName.isEmpty() || !conditions.lastNameKana.isEmpty() || !conditions.firstNameKana.isEmpty() */
  AND pat_id IN (
	SELECT
		r.pat_id
	FROM
		(
		SELECT
			pat_id,
			personal_info_decrypt (  o ->> 'last_name' )  AS last_name,
			personal_info_decrypt (  o ->> 'first_name' )  AS first_name,
			personal_info_decrypt (  o ->> 'last_name_kana'  ) AS last_name_kana,
			personal_info_decrypt (  o ->> 'first_name_kana'  ) AS first_name_kana
		FROM
			pat_personal_main AS T,
			jsonb_array_elements ( other_contact_info ) AS o
		) AS r
	WHERE 1=1
	    /*%if !conditions.lastName.isEmpty() */
		AND r.last_name LIKE /* @infix(conditions.lastName) */null
		/*%end*/
		/*%if !conditions.firstName.isEmpty() */
		AND r.first_name LIKE /* @infix(conditions.firstName) */null
		/*%end*/
		/*%if !conditions.lastNameKana.isEmpty() */
		AND r.last_name_kana LIKE /* @infix(conditions.lastNameKana) */null
		/*%end*/
		/*%if !conditions.firstNameKana.isEmpty() */
		AND r.first_name_kana LIKE /* @infix(conditions.firstNameKana) */null
		/*%end*/
	)
/*%end*/
--- 続柄
/*%if conditions.relationCd != null || !conditions.relationName.isEmpty() */
  AND pat_id IN (
	SELECT
		r.pat_id
	FROM
		(
		SELECT
			pat_id,
			(  o ->> 'relation_cd' )::INTEGER AS relation_cd,
			personal_info_decrypt (  o ->> 'relation_name' )  AS relation_name
		FROM
			pat_personal_main AS T,
			jsonb_array_elements ( other_contact_info ) AS o
		) AS r
	WHERE 1=1
	    /*%if conditions.relationCd != null */
		AND r.relation_cd = /* conditions.relationCd */null
		/*%end*/
		/*%if !conditions.relationName.isEmpty() */
		AND r.relation_name LIKE /* @infix(conditions.relationName) */null
		/*%end*/
	)
/*%end*/
--- 連絡先(業者)会社名
/*%if !conditions.companyName.isEmpty() */
  AND pat_id IN (
	SELECT
		r.pat_id
	FROM
		(
		SELECT
			pat_id,
			personal_info_decrypt (  o ->> 'company_name' )  AS company_name
		FROM
			pat_personal_main AS T,
			jsonb_array_elements ( vendor_contact_info ) AS o
		) AS r
	WHERE
		r.company_name LIKE /* @infix(conditions.companyName) */null
	)
/*%end*/
--- 連絡先(業者)会社名
/*%if !conditions.workerLastName.isEmpty() ||  !conditions.workerFirstName.isEmpty() */
  AND pat_id IN (
	SELECT
		r.pat_id
	FROM
		(
		SELECT
			pat_id,
			personal_info_decrypt (  o ->> 'worker_last_name' )  AS worker_last_name,
			personal_info_decrypt (  o ->> 'worker_first_name' )  AS worker_first_name
		FROM
			pat_personal_main AS T,
			jsonb_array_elements ( vendor_contact_info ) AS o
		) AS r
	WHERE 1=1
	    /*%if !conditions.workerLastName.isEmpty() */
		AND r.worker_last_name LIKE /* @infix(conditions.workerLastName) */null
		/*%end*/
		--- mod 6230 連絡先(業者)の検索結果が間違っている 吉 start
		--- /*%if !conditions.relationName.isEmpty() */
		/*%if !conditions.workerFirstName.isEmpty() */
		--- mod 6230 連絡先(業者)の検索結果が間違っている 吉 end
		AND r.worker_first_name LIKE /* @infix(conditions.workerFirstName) */null
		/*%end*/
	)
/*%end*/

---add 透析困難情報 劉全航
/*%if !conditions.isDialDiff.isEmpty() */
  and pat_id in
  (select foo.pat_id
    from
    (
        select distinct
        jsonb_array_elements(ppm.dial_diff_com_info)::jsonb->>'is_dial_diff' as is_dial_diff,
        ppm.pat_id
        from
        ntss.pat_personal_main as ppm
        where ppm.dial_diff_com_info is not null
    ) as foo
  where foo.is_dial_diff = /* conditions.isDialDiff */null)
/*%end*/

---add 重症度 劉全航
/*%if conditions.severityCd != null */
  and severity_cd = /* conditions.severityCd */null
/*%end*/
---add 搬送区分 劉全航
/*%if conditions.transportCd != null */
  and transport_cd = /* conditions.transportCd */null
/*%end*/
