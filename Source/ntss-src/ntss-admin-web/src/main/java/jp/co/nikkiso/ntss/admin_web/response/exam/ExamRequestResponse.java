package jp.co.nikkiso.ntss.admin_web.response.exam;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPatternData;

import lombok.AllArgsConstructor;

/**
 *　患者検査結果のResponse.
 */
@AllArgsConstructor
public class ExamRequestResponse {
  
  /**
   * 患者検査結果のリスト.
   */
  public List<PatExamMainData> patExamMains;
  
  /**
   * 患者検査日付のリスト.
   */
  public List<String> examDateList;
  
  /**
   * 患者毎の透析予定日のリスト.
   */
  public List<String> ordMainTreatDateList;

  /**
   * 患者毎の透析予定日のリスト.
   */
  public List<PatExamPatternData> patExamPatternList;

  /**
   * 患者、検査セットごとの検査パターンリスト.
   */
  public List<Map<String, Integer>> examPatternColumnList;

  /**
   * 患者毎の治療パターンリスト.
   */
  public List<PatTreatmentPattern> patTreatmentPatternList;

  /**
   * 空の情報を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public ExamRequestResponse() {
    this.patExamMains = Collections.emptyList();
    this.examDateList = Collections.emptyList();
    this.ordMainTreatDateList = Collections.emptyList();
    this.patExamPatternList = Collections.emptyList();
    this.examPatternColumnList = Collections.emptyList();
    this.patTreatmentPatternList = Collections.emptyList();
  }

}
