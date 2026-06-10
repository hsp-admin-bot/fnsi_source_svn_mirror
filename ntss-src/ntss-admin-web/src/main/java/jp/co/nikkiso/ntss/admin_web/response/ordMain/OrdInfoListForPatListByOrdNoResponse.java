package jp.co.nikkiso.ntss.admin_web.response.ordMain;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@Setter
@Getter
public class OrdInfoListForPatListByOrdNoResponse {
 
  /**
   * 治療日(YYYY/MM/DD)
   */
  @JsonProperty("viewTreatDate")
  private String viewTreatDate;
  
  /**
   * 治療日ソート用
   */
  @JsonProperty("treatDateForSort")
  private String treatDateForSort;


  /**
   * 実績：治療状況
   */
  @JsonProperty("rstDialysisState")
  private String rstDialysisState;
  
  /**
   * 治療ステータス
   */
  @JsonProperty("dialysisState")
  private String dialysisState;
  
  /**
   * 開始時刻(hh:mm)
   */
  @JsonProperty("startTime")
  private String startTime;
  
  /**
   * 開始時刻ソート用
   */
  @JsonProperty("startTimeForSort")
  private String startTimeForSort;
  
  /**
   * 終了予定時刻(hh:mm)
   */
  @JsonProperty("endScheduleTime")
  private String endScheduleTime;
  
  /**
   * 終了予定時刻ソート用
   */
  @JsonProperty("endScheduleTimeForSort")
  private String endScheduleTimeForSort;
  
  /**
   * 終了時刻(hh:mm)
   */
  @JsonProperty("endTime")
  private String endTime;  
  
  /**
   * 終了時刻ソート用
   */
  @JsonProperty("endTimeForSort")
  private String endTimeForSort;  
  
  /**
   * 回診状態
   */
  @JsonProperty("roundState")
  private String roundState;
  
  /**
   * 回診状態ソート用
   */
  @JsonProperty("roundStateForSort")
  private String roundStateForSort;

  /**
   * 回診状態強調表示
   */
  @JsonProperty("roundHighlighting")
  private String roundHighlighting;
  
  /**
   * クール開始時刻
   */
  @JsonProperty("kurStartTime")
  private String kurStartTime;  
  
  /**
   * ベッドマスタ表示順
   */
  @JsonProperty("bedOrderIndex")
  private Long bedOrderIndex;  
}
