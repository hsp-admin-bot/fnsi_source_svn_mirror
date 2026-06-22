select
  pat_id,
  ord_no
from
  ord_main
where
  is_del = '0'
  /*%if patIdList.size() > 0 */
  and pat_id in /* patIdList */(null)
 /*%end */
--- 施設コード絞り込み(速度改善)
  and facility_cd in /* facilityCdList */(null)

--- 透析条件(マスタリスト選択形式)
/*%if conditions.dialysisConditionSelectionList != null && conditions.dialysisConditionSelectionList.size() > 0 */
  and
  --- 指定条件数分回す
  /*%for selection : conditions.dialysisConditionSelectionList */
    ind_cond_info_value(ind_cond_info, /* selection.conditionId */null)::int in /* selection.cdList */(null)
    /*%if selection_has_next */
	  and
    /*%end */
  /*%end */
/*%end */

--- 透析条件(値指定形式)
/*%if conditions.dialysisConditionRangeValueList != null && conditions.dialysisConditionRangeValueList.size() > 0 */
  --- 指定条件数分回す
  /*%for range : conditions.dialysisConditionRangeValueList */
  /*%if range.conditionId != "39" && range.conditionId != "3"*/
  and (
    /*%if range.comparisonType == 1*/
    --- 比較方式が「一致」の場合
    ind_cond_info_value(ind_cond_info, /* range.conditionId */null)::decimal = /* range.value1 */null
    /*%else */
    --- 比較方式が「範囲」の場合
      /*%if range.value1 != null */
      --- 左辺が指定されている場合
        /*%if range.inequalitySign1 == 1 */
        --- 不等号が「<」の場合
    ind_cond_info_value(ind_cond_info, /* range.conditionId */null)::decimal > /* range.value1 */null
        /*%else */
        --- 不等号が「≦」の場合
    ind_cond_info_value(ind_cond_info, /* range.conditionId */null)::decimal >= /* range.value1 */null
        /*%end*/
      /*%end*/
      /*%if range.value2 != null */
      --- 右辺が指定されている場合
        /*%if range.value1 != null */
        --- 左辺が指定されている場合
    and
        /*%end*/
        /*%if range.inequalitySign2 == 1 */
        --- 不等号が「<」の場合
    ind_cond_info_value(ind_cond_info, /* range.conditionId */null)::decimal < /* range.value2 */null
        /*%else */
        --- 不等号が「≦」の場合
    ind_cond_info_value(ind_cond_info, /* range.conditionId */null)::decimal <= /* range.value2 */null
        /*%end*/
      /*%end*/
    /*%end*/
    )
    /*%end */
  /*%end */
/*%end */

--- 透析条件(ラジオボタン形式)
/*%if conditions.dialysisConditionRadioValueList != null && conditions.dialysisConditionRadioValueList.size() > 0 */
  and (
  --- 指定条件数分回す
  /*%for radio : conditions.dialysisConditionRadioValueList */
    ind_cond_info_value(ind_cond_info, /* radio.conditionId */null)::int = /* radio.value */null
    /*%if radio_has_next */
    and
    /*%end */
  /*%end */
  )
/*%end */

--- 透析条件(時間形式)
/*%if conditions.dialysisConditionTimeValueList != null && conditions.dialysisConditionTimeValueList.size() > 0 */
  and (
  --- 指定条件数分回す
  /*%for time : conditions.dialysisConditionTimeValueList */
    /*%if time.lowerMinutes != null */
    --- 下限値が指定されている場合
    ind_cond_info_value(ind_cond_info, /* time.conditionId */null)::int >= /* time.lowerMinutes */null
    /*%end*/
    /*%if time.upperMinutes != null */
    --- 上限値が指定されている場合
      /*%if time.lowerMinutes != null */
      --- 下限値が指定されている場合
    and
      /*%end*/
    ind_cond_info_value(ind_cond_info, /* time.conditionId */null)::int <= /* time.upperMinutes */null
    /*%end*/
    /*%if time_has_next */
    and
    /*%end */
  /*%end */
  )
/*%end */

--- 投薬指示
/*%if conditions.medicationList != null && conditions.medicationList.size() > 0 */
  and (
  --- 指定薬剤分類分回す
  /*%for medicineCdList : conditions.medicationList */
    -- mod 患者検索外結No8対応 趙 start
    -- json_array_contains_array_value(ind_medi_info, 'cd', /* "{" + medicineCdList.toString().substring(1, medicineCdList.toString().length() -1) + "}" */null::int[])
    json_array_contains_array_value(ind_medi_info, 'cd', /* medicineCdList.toString().substring(1, medicineCdList.toString().length() -1) */null::int[])
    -- mod 患者検索外結No8対応 趙 end
    /*%if medicineCdList_has_next */
    and
    /*%end */
  /*%end */
  )
/*%end */

--- 医材指示
/*%if conditions.equipmentList != null && conditions.equipmentList.size() > 0 */
  and (
  --- 指定医材分類分回す
  /*%for equipmentCdList : conditions.equipmentList */
    -- mod 患者検索外結No8対応 趙 start
    -- json_array_contains_array_value(ind_equip_info, 'cd', /* "{" + equipmentCdList.toString().substring(1, equipmentCdList.toString().length() -1) + "}" */null::int[])
    json_array_contains_array_value(ind_equip_info, 'cd', /* equipmentCdList.toString().substring(1, equipmentCdList.toString().length() -1) */null::int[])
    -- mod 患者検索外結No8対応 趙 end
    /*%if equipmentCdList_has_next */
    and
    /*%end */
  /*%end */
  )
/*%end */

--- 指示コメント
/*%if conditions.indCommentList != null && conditions.indCommentList.size() > 1 */
  and (
  /*%for indComment : conditions.indCommentList */
    /*%if indComment_index != 0 */
	    json_array_contains_value(ind_ind_comment_info, 'content', /* indComment */null, /* conditions.indCommentList.get(0) */null)
	    /*%if indComment_has_next */
	    and
	    /*%end */
    /*%end */
  /*%end */
  )
/*%end */
--- ダイアライザ
/*%if conditions.dialyzerCdList != null && conditions.dialyzerCdList.size() > 0*/
  and (
    (ind_cond_info ->'5' ->> 'value')::int in /*conditions.dialyzerCdList*/(null) or
    (/*%for dialyzerCd : conditions.dialyzerCdList */
    COALESCE(jsonb_array_length(ind_equip_info), 0) > 0
    AND json_array_contains_value_with_class(ind_equip_info, 'cd', (/* dialyzerCd */null)::text, 'equip_type', '1', false)
    /*%if dialyzerCd_has_next */
    or
    /*%end */
  /*%end */)
  )
/*%end */
--- 治療方法
/*%if conditions.treatmentCdList != null && conditions.treatmentCdList.size() > 0 */
  and (
    ind_treatment_cd in /*conditions.treatmentCdList*/(null)
  )
/*%end */

--- 透析予定期間開始
/*%if conditions.dialysisStartDate != null && !conditions.dialysisStartDate.isEmpty() */
  and  treat_date >= /*conditions.dialysisStartDate*/null
/*%end */
--- 透析予定期間結束
/*%if conditions.dialysisEndDate != null && !conditions.dialysisEndDate.isEmpty() */
  and  treat_date <= /*conditions.dialysisEndDate*/null
/*%end */
-- add  FNSI 患者詳細検索＞治療予定で検索を行った際、過去の治療予定も検索対象となっている 6232修正 関 start
/*%if conditions.dialysisStartDate != null && conditions.dialysisEndDate != null &&
 conditions.dialysisStartDate.isEmpty() && conditions.dialysisEndDate.isEmpty() &&
 null != conditions.simpleSearchTreatDate && conditions.simpleSearchTreatDate.isEmpty()*/
  and  treat_date >= to_char(CURRENT_DATE, 'YYYYMMDD')
/*%end */
/*%if null != conditions.simpleSearchTreatDate && !conditions.simpleSearchTreatDate.isEmpty() */
  and treat_date = /* conditions.simpleSearchTreatDate */null
/*%end*/
-- add  FNSI 患者詳細検索＞治療予定で検索を行った際、過去の治療予定も検索対象となっている 6232修正 関 end
-- add 患者の詳細検索で500エラー 7044  関 start
  and pat_id is not null
-- add 患者の詳細検索で500エラー 7044  関 end
/*%if ""!= rstDialysisStateFlag && rstDialysisStateFlag == "1" */
  and rst_dialysis_state > '0'
/*%end */
/*%if ""!= rstDialysisStateFlag && rstDialysisStateFlag == "2" */
  and rst_dialysis_state >= '0'
/*%end */
