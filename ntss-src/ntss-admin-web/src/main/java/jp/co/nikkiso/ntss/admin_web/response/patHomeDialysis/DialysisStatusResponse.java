package jp.co.nikkiso.ntss.admin_web.response.patHomeDialysis;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 *　在宅透析患者向けのResponse.
 */
@AllArgsConstructor
@NoArgsConstructor
@Getter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
public class DialysisStatusResponse {
  
  /**
   * 実績：治療状況
   */
  private String rstDialysisState;
  
  /**
   * 指示：治療方法名
   */
  private String indTreatmentName;
  
  /**
   * モニタデータ
   */
  private String monitorData;
  
}
