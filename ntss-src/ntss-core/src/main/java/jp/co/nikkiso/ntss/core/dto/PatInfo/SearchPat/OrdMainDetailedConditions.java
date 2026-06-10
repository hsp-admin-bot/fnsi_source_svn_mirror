package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.math.BigDecimal;
import java.util.List;

import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * ord_main検索条件
 */
@Data
public class OrdMainDetailedConditions {
  List<DiaysisConditionListSelect> dialysisConditionSelectionList;
  List<DiaysisConditionRangeValue> dialysisConditionRangeValueList;
  List<DiaysisConditionRadio> dialysisConditionRadioValueList;
  List<DiaysisConditionTime> dialysisConditionTimeValueList;
  // 投薬指示の薬剤コードリスト
  List<List<Integer>> medicationList;
  // 医材指示の医材コードリスト
  List<List<Integer>> equipmentList;
  List<String> indCommentList;
  // ダイアライザコードリスト
  List<Integer> dialyzerCdList;
  // 治療方法コードリスト
  List<Integer> treatmentCdList;
  //add no338 透析予定期間 張岩 start
  private String dialysisStartDate;
  private String dialysisEndDate;
  // add no338 透析予定期間 張岩 end

  // add 患者検索外結No7対応 趙 start
  public String getConditionId(int index){
    return dialysisConditionRangeValueList.get(index).getConditionId();
  }
  public BigDecimal getValue1(int index){
    return dialysisConditionRangeValueList.get(index).getValue1();
  }
  public BigDecimal getValue2(int index){
    return dialysisConditionRangeValueList.get(index).getValue2();
  }
  public Integer getComparisonType(int index){
    return dialysisConditionRangeValueList.get(index).getComparisonType();
  }
  public Integer getInequalitySign1(int index){
    return dialysisConditionRangeValueList.get(index).getInequalitySign1();
  }
  public Integer getInequalitySign2(int index){
    return dialysisConditionRangeValueList.get(index).getInequalitySign2();
  }
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  // 簡易検索 実績予定区分
  private List<Long> simpleSearchRstDialysisState;
  // 簡易検索 治療日
  private String simpleSearchTreatDate;
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
  // add 患者検索外結No7対応 趙 end
}

@Data
class DialysisCondition {
  String conditionId;
}

@Data
@EqualsAndHashCode(callSuper=true)
class DiaysisConditionListSelect extends DialysisCondition {
  List<Integer> cdList;
}

@Data
@EqualsAndHashCode(callSuper=true)
class DiaysisConditionRangeValue extends DialysisCondition {
  BigDecimal value1;
  BigDecimal value2;
  Integer comparisonType;
  Integer inequalitySign1;
  Integer inequalitySign2;
}

@Data
@EqualsAndHashCode(callSuper=true)
class DiaysisConditionRadio extends DialysisCondition {
  Integer value;
}

@Data
@EqualsAndHashCode(callSuper=true)
class DiaysisConditionTime extends DialysisCondition {
  Integer lowerMinutes;
  Integer upperMinutes;
}
