
package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;

import lombok.Data;

/**
 * pat_main検索条件
 */
@Data
public class PatMainDetailedConditions {
  // 血糖検査有無フラグのリスト
  private String isBloodSugerExam;
  // 感染症有無フラグのリスト
  private String isInfect;
  // インプラント有無フラグのリスト
  private String isImplant;
  // 糖尿病患者扱いフラグのリスト
  private String isDiabetes;
  // スタッフコード(主治医)
  private Long staffCdDoctor;
  // スタッフコード(担当)
  private Long staffCdCharge;
  // スタッフコード(穿刺)
  private Long staffCdPucture;
  // 禁忌コード
  private Integer tabooCd;
  // 禁忌内容
  private String tabooContent;
  // アレルギーコード
  private Integer allergyCd;
  // アレルギー内容
  private String allergyContent;
  // 診療情報.透析導入日(下限)
  private String dialysisStartDateLower;
  // 診療情報.透析導入日(上限)
  private String dialysisStartDateUpper;
  // 検索条件として画面から入力した在院状態のリスト
  private List<String> inOutStateList;
  // 確定在院状態のリスト(DB検索用)
  private List<String> inOutCurrentStateList;
  // 予定在院状態のリスト(DB検索用)
  private List<String> inOutPlanStateList;
  // 診療科
  private Long mainCourseCd;
  private String courseName;
  // 透析実施科
  private Long dialysisCourseCd;
  private String dialCourseName;
  // 病棟
  private Long wardCd;
  private String wardName;
  // 自施設通信透析回数(下限)
  private Integer dialysisCountLower;
  // 自施設通信透析回数(上限)
  private Integer dialysisCountUpper;
  // 自施設通信特殊浄化回数(下限)
  private Integer purificationCountLower;
  // 自施設通信特殊浄化回数(上限)
  private Integer purificationCountUpper;
  //add 車いす利用 劉全航 start
  private String isWheelChair;
  //add 車いす利用 劉全航 end
  //add NO338 患者情報加算 劉全航 start
  private String additionCd;

  private boolean additionSearchCondition;
  //add NO338 患者情報加算 劉全航 end
  //mod 患者詳細検索bug修正 start
  private boolean conditionIsEmpty;
  //mod 患者詳細検索bug修正 end
}

