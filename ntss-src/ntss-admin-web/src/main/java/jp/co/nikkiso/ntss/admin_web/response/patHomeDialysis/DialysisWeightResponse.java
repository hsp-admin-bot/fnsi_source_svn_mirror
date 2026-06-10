package jp.co.nikkiso.ntss.admin_web.response.patHomeDialysis;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

/**
 *　在宅透析患者向けのResponse.
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
//add 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start
@Setter
//add 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 end
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class DialysisWeightResponse {
  
  /**
   * オーダ番号
   */
  private Long ordNo;

  /**
   * 実績：治療状況
   */
  private String rstDialysisState;

  /**
   * 実績:体重情報
   */
  private String rstWeightInfo;
  //add 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 start
  /**
   * OrdMain フラグ
   */
  private Long rstOrdMainFlag;

  public DialysisWeightResponse(Long ordNo, String rstDialysisState, String rstWeightInfo){
    this.ordNo = ordNo;
    this.rstDialysisState = rstDialysisState;
    this.rstWeightInfo = rstWeightInfo;
  }
  //add 7311 新規に作った治療予定の存在しない施設でクールマスタを保存するとフリーズ 関俊楠 end
}
