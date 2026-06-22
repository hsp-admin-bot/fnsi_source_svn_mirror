package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;

import lombok.Data;

/**
 * ord_schedule検索条件
 */
@Data
public class OrdScheduleSimpleConditions {
  // 治療日
  private String treatDate;
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
  private List<Long> rstDialysisState;
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
  // クールコードのリスト
  private List<Long> kurCdList;
  // ベッドグループコード
  private String bedGroupCd;
  // ベッドコードのリスト
  private List<Long> bedCdList;
  // 治療曜日のリスト
  private List<Integer> treatDayOfWeekList;
}
