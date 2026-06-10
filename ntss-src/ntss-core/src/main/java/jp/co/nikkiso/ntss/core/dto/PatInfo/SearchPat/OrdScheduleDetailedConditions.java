package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;

import lombok.Data;

/**
 * ord_schedule検索条件
 */
@Data
public class OrdScheduleDetailedConditions {
  // 治療日(開始日)
  private String treatStartDate;
  // 治療日(終了日)
  private String treatEndDate;
  // クールコードのリスト
  private List<Long> kurCdList;
  // ベッドグループコードのリスト
  private List<Integer> bedGroupCdList;
  // ベッドコードのリスト
  private List<Long> bedCdList;
  // 治療曜日のリスト
  private List<Integer> treatDayOfWeekList;
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  // 簡易検索 治療曜日のリスト
  private List<Integer> simpleSearchTreatDayOfWeekList;
  // 簡易検索 クールコードのリスト
  private List<Long> simpleSearchKurCdList;
  // 簡易検索 ベッドグループコード
  private String simpleSearchBedGroupCd;
  // ベッドコードのリスト
  private List<Long> simpleSearchBedCdList;
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end
}
