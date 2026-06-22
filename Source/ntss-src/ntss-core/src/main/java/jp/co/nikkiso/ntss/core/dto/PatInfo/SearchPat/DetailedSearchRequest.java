package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;
import lombok.Data;

/**
 * 詳細検索リクエスト
 */
@Data
public class DetailedSearchRequest {
  private PatPersonalMainDetailedConditions pat_personal_main;
  private PatMainDetailedConditions pat_main;
  private PatUniqueDetailedConditions pat_unique;
  private OrdScheduleDetailedConditions ord_schedule;
  private OrdMainDetailedConditions ord_main;
  private List<String> facilityCdList;
  private PatGroupSearchRequest patGroupSearch;
  //add NO338 患者イベントで検索　劉全航 start
  private PatEventDetailedConditions patEvent;
  //add NO338 患者イベントで検索　劉全航 start
  // add 患者檢索　張岩 start
  private PatInsuranceConditions pat_insurance;
  private PatExamPatternConditions pat_exam_pattern;
  //add 患者檢索　張岩 end
  //add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 start
  private PatRadPatternDetailedConditions pat_rad_pattern;
  //add No338患者詳細検索の追加項目 一般撮影検査予定検索 劉全航 end
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 start
  // 簡易検索 患者グループ
  private PatGroupSearchRequest simpleSearchPatGroupSearch;
  // add 11315 【たくしん会】患者検索の患者リストのソートが正しく動作しない 関 end

}
