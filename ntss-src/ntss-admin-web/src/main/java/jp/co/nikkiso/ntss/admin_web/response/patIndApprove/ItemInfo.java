package jp.co.nikkiso.ntss.admin_web.response.patIndApprove;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
public class ItemInfo {

  private Item ItemInfo;

  @Data
  public static class Item {
    /**
     * 項目名
     */
    private String itemName;

    /**
     * アイテム番号
     */
    private Integer itemNo;

    /**
     * クールコード
     */
    private Integer itemCd;

    /**
     * type
     */
    private Integer itemType;

    /**
     * "data"キー 治療方法で使用
     */
    private ItemData data;
  }

  /**
   * data 項目
   */
  @Data
  public static class ItemData {
    /**
     * 値
     */
    private ValueData value = new ValueData();
    /**
     * 更新者
     */
    private String updater = "";
    /**
     * 指示者
     */
    private String instructor = "";

    @JsonInclude(JsonInclude.Include.NON_NULL)
    private Boolean isDisable;
  }

  @Data
  public static class ValueData {

    /**
     * 接頭語
     */
    private String prefix = "";

    /**
     * name
     */
    private String dispVal = "";

    /**
     * unit
     */
    private String unit = "";
  }
}
