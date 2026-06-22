package jp.co.nikkiso.ntss.admin_web.response.checkList.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * チェックリスト設定のJSON格納クラス.
 */
@Data
public class ChecklistSettingsDto {

  /**
   * リストコード.
   */
  @JsonProperty("list_cd")
  private Short listCd;
  /**
   * リスト名
   */
  @JsonProperty("list_name")
  private String listName;
  /**
   * 透析工程コード
   */
  @JsonProperty("dialysis_prog_cd")
  private Integer dialysisProgCd;

  /**
   * 透析工程名
   */
  @JsonProperty("dialysis_prog_name")
  private String dialysisProgName;
  /**
   * 使用可否
   */
  @JsonProperty("is_use")
  private String isUse;
  /**
   * 機能リスト
   */
  @JsonProperty("funclist")
  private String funclist;
}
