package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import lombok.Data;

import java.util.List;

/**
 * 患者情報検索条件クラス
 * Doma 用に全ての getter を明示的に追加
 */
@Data
public class PatInsuranceConditionsSharing {

  /**
   * 患者IDリスト（IN句用）
   */
  private List<Long> patIdList;
  private List<Long> excludePatIdList;

  /**
   * 血液型ABO
   */
  private Integer patBloodTypeAbo;

  /**
   * 血液型RH
   */
  private Integer patBloodTypeRh;

  /**
   * 血液型亜型
   */
  private Integer patBloodTypeSerovar;

  /**
   * 性別
   */
  private Integer gender;

  /**
   * 生年月日範囲 - 開始日
   */
  private String startBirthDate;
  private String endBirthDate;

  /**
   * 患者氏名（あいまい検索用）
   */
  private String patName;

  /**
   * 施設コード
   */
  private String facilityCd;
  private List<String> facilityCdList;

  /**
   * 共有元施設コード
   */
  private String fromFacilityCd;

  /**
   * 共有先施設コード
   */
  private String toFacilityCd;

  /**
   * 取得タイプ
   */
  private Integer type;
  private Long currentSelectedPatId;

  private Boolean pendingFlg;
  private Boolean shareFromFlg;
  private Boolean shareToFlg;
  private Boolean prohibitedFlg;

  public Boolean getShareFromFlg() {
    return shareFromFlg;
  }

  public Boolean getShareToFlg() {
    return shareToFlg;
  }

  public Boolean getProhibitedFlg() {
    return prohibitedFlg;
  }
// ============================
  // 以下すべて Doma 用の public getter
  // ============================

  public List<Long> getPatIdList() {
    return patIdList;
  }
  public List<Long> getExcludePatIdList() {
    return excludePatIdList;
  }

  public Integer getPatBloodTypeAbo() {
    return patBloodTypeAbo;
  }

  public Integer getPatBloodTypeRh() {
    return patBloodTypeRh;
  }

  public Integer getPatBloodTypeSerovar() {
    return patBloodTypeSerovar;
  }

  public Integer getGender() {
    return gender;
  }

  public String getStartBirthDate() {
    return startBirthDate;
  }

  public String getEndBirthDate() {
    return endBirthDate;
  }

  public String getPatName() {
    return patName;
  }

  public String getFacilityCd() {
    return facilityCd;
  }

  public List<String> getFacilityCdList() {
    return facilityCdList;
  }

  public String getFromFacilityCd() {
    return fromFacilityCd;
  }

  public String getToFacilityCd() {
    return toFacilityCd;
  }

  public Integer getType() {
    return type;
  }

  public Boolean getPendingFlg() {
    return pendingFlg;
  }

}
