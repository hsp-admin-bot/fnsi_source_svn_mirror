select
  pat_id
from
  pat_main
where
  is_del = '0'

/*%if patIdList.size() > 0 */
  and pat_id in /* patIdList */(null)
/*%end */

--- 施設コード絞り込み(速度改善)
  and facility_cd in /* facilityCdList */(null)

--- 血糖検査有無
/*%if !conditions.isBloodSugerExam.isEmpty() */
  and is_blood_suger_exam = /* conditions.isBloodSugerExam */null
/*%end*/

--- 確定在院状態
/*%if conditions.inOutCurrentStateList != null && !conditions.inOutCurrentStateList.isEmpty() */
-- add 11315【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
    /*%if unknownFlag */
    AND (in_out_current_state in /* conditions.inOutCurrentStateList */(null) OR in_out_current_state IS NULL)
    /*%else */
    AND in_out_current_state IN /* conditions.inOutCurrentStateList */(null)
    /*%end */
-- add 11315【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
/*%end */

--- 予定在院状態
/*%if conditions.inOutPlanStateList != null && !conditions.inOutPlanStateList.isEmpty() */
  /*%if conditions.inOutCurrentStateList != null && !conditions.inOutCurrentStateList.isEmpty() */
    or in_out_plan_state in /* conditions.inOutPlanStateList */(null)
  /*%else */
    and in_out_plan_state in /* conditions.inOutPlanStateList */(null)
  /*%end */
/*%end */



--- 感染症有無
/*%if !conditions.isInfect.isEmpty() */
  and is_infect = /* conditions.isInfect */null
/*%end*/

--- インプラント有無
/*%if !conditions.isImplant.isEmpty() */
  and is_implant = /* conditions.isImplant */null
/*%end*/

--- 糖尿病患者扱い
/*%if !conditions.isDiabetes.isEmpty() */
  and is_diabetes = /* conditions.isDiabetes */null
/*%end*/

--- 担当スタッフ情報(主治医)
/*%if conditions.staffCdDoctor != null */
  and json_array_contains_value_with_class(charge_staff_info, 'staff_cd', (/* conditions.staffCdDoctor */null)::text, 'is_main', '1', false)
/*%end*/

--- 担当スタッフ情報(担当)
/*%if conditions.staffCdCharge != null */
  and json_array_contains_value_with_class(charge_staff_info, 'staff_cd', (/* conditions.staffCdCharge */null)::text, 'is_charge', '1', false)
/*%end*/

--- 担当スタッフ情報(穿刺)
/*%if conditions.staffCdPucture != null */
  and json_array_contains_value_with_class(charge_staff_info, 'staff_cd', (/* conditions.staffCdPucture */null)::text, 'is_puncture', '1', false)
/*%end*/

--- 禁忌
/*%if conditions.tabooCd != null */
  --- マスタが指定されている場合はコード検索
  and json_array_contains_value_with_class(taboo_allergy_info, 'taboo_allergy_cd', (/* conditions.tabooCd */null)::text, 'taboo_allergy_class', '1', false)
/*%elseif !conditions.tabooContent.isEmpty() */
  --- 手入力されている場合は内容検索
  and json_array_contains_value_with_class(taboo_allergy_info, 'content', /* conditions.tabooContent */null, 'taboo_allergy_class', '1', true)
/*%end*/

--- アレルギー
/*%if conditions.allergyCd != null */
  --- マスタが指定されている場合はコード検索
  and json_array_contains_value_with_class(taboo_allergy_info, 'taboo_allergy_cd', (/* conditions.allergyCd */null)::text, 'taboo_allergy_class', '2', false)
/*%elseif !conditions.allergyContent.isEmpty() */
  --- 手入力されている場合は内容検索
  and json_array_contains_value_with_class(taboo_allergy_info, 'content', /* conditions.allergyContent */null, 'taboo_allergy_class', '2', true)
/*%end*/

--- 透析導入日(下限)
/*%if !conditions.dialysisStartDateLower.isEmpty() */
  and (medical_care_info ->> 'dialysis_start_date') >= /* conditions.dialysisStartDateLower */null
/*%end */

--- 透析導入日(上限)
/*%if !conditions.dialysisStartDateUpper.isEmpty() */
  and (medical_care_info ->> 'dialysis_start_date') <= /* conditions.dialysisStartDateUpper */null
/*%end */

--- 診療科
and pat_id in(	SELECT
		pm.pat_id
	FROM
		pat_main pm
        -- mod FutreNetWeb+SI課題管理No5763 趙 start
		-- LEFT JOIN mst_course mc ON ( pm.medical_care_info ->> 'main_course_cd' ) :: INTEGER = mc.course_cd
		LEFT JOIN mst_course mc ON ( pm.medical_care_info ->> 'main_course_cd' ) ::text = mc.course_cd::text
		-- mod FutreNetWeb+SI課題管理No5763 趙 end
	WHERE 1=1
	-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 start
--     /*%if !conditions.courseName.isEmpty() */
    /*%if null != conditions.courseName && !conditions.courseName.isEmpty() */
    -- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 end
        and mc.course_name = /* conditions.courseName */null
    /*%end*/
    /*%if conditions.mainCourseCd != null */
        and mc.course_cd =  /* conditions.mainCourseCd */null
    /*%end*/
    -- add FutreNetWeb+SI課題管理No5763 趙 start
    and pm.facility_cd in /* facilityCdList */(null)
    -- add FutreNetWeb+SI課題管理No5763 趙 end
	)
--- 透析実施科
and pat_id in(	SELECT
		pm.pat_id
	FROM
		pat_main pm
		-- mod FutreNetWeb+SI課題管理No5763 趙 start
		-- LEFT JOIN mst_course mc ON ( pm.medical_care_info ->> 'dialysis_course_cd' ) :: INTEGER = mc.course_cd
		LEFT JOIN mst_course mc ON ( pm.medical_care_info ->> 'dialysis_course_cd' ) ::text = mc.course_cd::text
		-- mod FutreNetWeb+SI課題管理No5763 趙 end
	WHERE 1=1
	-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 start
--     /*%if !conditions.dialCourseName.isEmpty() */
    /*%if null != conditions.dialCourseName && !conditions.dialCourseName.isEmpty() */
    -- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 end
        and mc.course_name = /* conditions.dialCourseName */null
    /*%end*/
    /*%if conditions.dialysisCourseCd != null */
        and mc.course_cd =  /* conditions.dialysisCourseCd */null
    /*%end*/
    -- add FutreNetWeb+SI課題管理No5763 趙 start
    and pm.facility_cd in /* facilityCdList */(null)
    -- add FutreNetWeb+SI課題管理No5763 趙 end
	)
--- 病棟
and pat_id in(	SELECT
		pm.pat_id
	FROM
		pat_main pm
		-- mod FutreNetWeb+SI課題管理No5763 趙 start
		-- LEFT JOIN mst_ward mw ON ( pm.medical_care_info ->> 'ward_cd' ) :: INTEGER = mw.ward_cd
		LEFT JOIN mst_ward mw ON ( pm.medical_care_info ->> 'ward_cd' ) ::text = mw.ward_cd::text
		-- mod FutreNetWeb+SI課題管理No5763 趙 end
	WHERE 1=1
	-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 start
--     /*%if !conditions.wardName.isEmpty() */
    /*%if null != conditions.wardName && !conditions.wardName.isEmpty() */
    -- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 start
        and mw.ward_name = /* conditions.wardName */null
    /*%end*/
    /*%if conditions.wardCd != null */
        and mw.ward_cd =  /* conditions.wardCd */null
    /*%end*/
    -- add FutreNetWeb+SI課題管理No5763 趙 start
    and pm.facility_cd in /* facilityCdList */(null)
    -- add FutreNetWeb+SI課題管理No5763 趙 end
	)
--- 自施設通信透析回数　
/*%if conditions.dialysisCountLower != null */
  and (medical_care_info ->> 'dialysis_count')::INTEGER >=  /* conditions.dialysisCountLower */null
/*%end*/
/*%if conditions.dialysisCountUpper != null */
  and (medical_care_info ->> 'dialysis_count')::INTEGER <=  /* conditions.dialysisCountUpper */null
/*%end*/
--- 自施設通信特殊浄化回数
/*%if conditions.purificationCountLower != null */
  and (medical_care_info ->> 'purification_count')::INTEGER >=  /* conditions.purificationCountLower */null
/*%end*/
/*%if conditions.purificationCountUpper != null */
  and (medical_care_info ->> 'purification_count')::INTEGER <=  /* conditions.purificationCountUpper */null
/*%end*/
---add 車いす利用 劉全航
/*%if !conditions.isWheelChair.isEmpty() && conditions.isWheelChair == "1"*/
and (pat_id in(
SELECT
	pat_id
	FROM
		mst_wheel_chair
	WHERE
	 is_del = '0'
	and is_disp = '1'
	and facility_cd in /* facilityCdList */(null)
	and is_personal = '1'
	) or is_wheel_chair = '1')
/*%elseif  !conditions.isWheelChair.isEmpty() && conditions.isWheelChair == "0"*/
and is_wheel_chair = /* conditions.isWheelChair */null
and pat_id not in(
SELECT
	pat_id
	FROM
		mst_wheel_chair
	WHERE
	 is_del = '0'
	and is_disp = '1'
	and facility_cd in /* facilityCdList */(null)
	and is_personal = '1'
	)
/*%end*/
---add 加算 劉全航
/*%if conditions.additionCd !=null && conditions.additionSearchCondition == true */
    and pat_id in (
        select foo.pat_id
        from (
                 select pat_id,jsonb_array_elements(addition_info)::jsonb->>'cd' as addition_cd,
                        -- add  FNSI 加算で検索を行った際、すべての患者がリストに表示される 6237修正 関 start
                        jsonb_array_elements(addition_info)::jsonb->>'is_enable' as is_enable
                        -- add  FNSI 加算で検索を行った際、すべての患者がリストに表示される 6237修正 関 end
                 from pat_main
                 where is_del='0'
                 -- add FutreNetWeb+SI課題管理No5763 趙 start
                 and facility_cd in /* facilityCdList */(null)
                 -- add FutreNetWeb+SI課題管理No5763 趙 end
             )as foo
        where foo.addition_cd = /* conditions.additionCd */null
        -- add  FNSI 加算で検索を行った際、すべての患者がリストに表示される 6237修正 関 start
        and  is_enable = '1'
        -- add  FNSI 加算で検索を行った際、すべての患者がリストに表示される 6237修正 関 end
    )
/*%end*/
/*%if conditions.additionCd !=null && conditions.additionSearchCondition == false */
    and pat_id in (
        select foo.pat_id
        from (
                 select pat_id,jsonb_array_elements(addition_info)::jsonb->>'cd' as addition_cd,
                 -- add  FNSI 加算で検索を行った際、すべての患者がリストに表示される 6237修正 関 start
                 jsonb_array_elements(addition_info)::jsonb->>'is_enable' as is_enable
                 -- add  FNSI 加算で検索を行った際、すべての患者がリストに表示される 6237修正 関 end
                 from pat_main
                 where is_del='0'
                 -- add FutreNetWeb+SI課題管理No5763 趙 start
                 and facility_cd in /* facilityCdList */(null)
                 -- add FutreNetWeb+SI課題管理No5763 趙 end
             )as foo
        where foo.addition_cd = /* conditions.additionCd */null
        -- add  FNSI 加算で検索を行った際、すべての患者がリストに表示される 6237修正 関 start
        and  is_enable = '0'
        -- add  FNSI 加算で検索を行った際、すべての患者がリストに表示される 6237修正 関 end
    )
/*%end*/
