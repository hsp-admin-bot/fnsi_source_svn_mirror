package jp.co.nikkiso.ntss.admin_web.response.rad;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.PatTreatmentPattern;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadPatternData;
import lombok.AllArgsConstructor;

/**
 *　患者放射線検査結果のResponse.
 */
@AllArgsConstructor
public class RadRequestResponse {

  /**
   * 患者放射線検査結果のリスト.
   */
  public List<PatRadMainData> patRadMains;

  /**
   * 患者放射線検査日付のリスト.
   */
  public List<String> radDateList;

  /**
   * 患者放射線検査日時のリスト.
   */
  public List<String> radDateTimeList;

  /**
   * 患者毎の透析予定日のリスト.
   */
  public List<String> ordMainTreatDateList;

  /**
   * 患者、検査セットごとの前回検査日リスト.
   */
  public List<String> lastRadDateList;

  /**
   * 患者毎の透析予定日のリスト.
   */
  public List<PatRadPatternData> patRadPatternList;

  /**
   * 患者、検査セットごとの検査パターンリスト.
   */
  public List<Map<String, Integer>> radPatternColumnList;

  /**
   * 患者、検査セットごとの検査パターンリスト（患者個別用）.
   */
  public List<Map<String, String>> radPatternDetailColumnList;

  /**
   * 身体情報
   */
  public List<PatUnique> patUniqueList;

  /**
   * 患者毎の治療パターンリスト.
   */
  public List<PatTreatmentPattern> patTreatmentPatternList;

  /**
   * 空の情報を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public RadRequestResponse() {
    this.patRadMains = Collections.emptyList();
    this.radDateList = Collections.emptyList();
    this.radDateTimeList = Collections.emptyList();
    this.ordMainTreatDateList = Collections.emptyList();
    this.lastRadDateList = Collections.emptyList();
    this.patRadPatternList = Collections.emptyList();
    this.radPatternColumnList = Collections.emptyList();
    this.radPatternDetailColumnList = Collections.emptyList();
    this.patUniqueList = Collections.emptyList();
    this.patTreatmentPatternList = Collections.emptyList();
  }

}
