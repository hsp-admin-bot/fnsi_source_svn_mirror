package jp.co.nikkiso.ntss.admin_web.response.checkList.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * 機能リストのJSON格納クラス.
 */
@Data
public class FunclistDto {

  /**
   * 項目番号.
   */
  @JsonProperty("item_number")
  private Short itemNumber;
  /**
   * 機能種別
   */
  @JsonProperty("func_class")
  private Integer funcClass;
  /**
   * リスト名
   */
  @JsonProperty("list_name")
  private String listName;

  /**
   * 分類コード
   */
  @JsonProperty("class_cd")
  private Integer classCd;
}
