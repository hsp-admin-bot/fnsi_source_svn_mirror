package jp.co.nikkiso.ntss.admin_web.service.checkList;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

public class IndApproveContentDto {

  @Data
  public class Item {
    /**
     * data 項目
     */
    @Data
    public class ItemData {
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

      /**
       * コンストラクタ
       */
      public ItemData() {
        this.value = new ValueData();
        this.updater = "";
        this.instructor = "";
        this.isDisable = null;
      }
    }
    /**
     * サブカテゴリ項目
     */
    @Data
    public class subCategoryItemData {
      /**
       * アイテム番号
       */
      private Integer itemNo;
      /**
       * 項目名
       */
      private String itemName;
      /**
       * データ
       */
      private ItemData data;
      /**
       * コンストラクタ
       */
      public subCategoryItemData() {
        this.itemNo = 0;
        this.itemName = "";
        this.data = new ItemData();
      }
    }

    /**
     * "data"キー 治療方法で使用
     */
    private ItemData data;

    /**
     * カテゴリ名
     */
    private String component;

    /**
     * サブカテゴリ番号
     */
    private Integer subCategoryNo;
    /**
     * サブカテゴリ名称
     */
    private String subCategoryName;

    /**
     * サブカテゴリアイテム
     */
    private List<subCategoryItemData> subCategoryItem;
    /**
     * コンストラクタ
     */
    public Item() {
      this.data = new ItemData();
      this.component = "";
      this.subCategoryNo = 0;
      this.subCategoryName = "";
      this.subCategoryItem = new ArrayList<>();
    }

    //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
    @Data
    public class ValueData {
      private String prefix = "";
      private String dispVal = "";
      private String unit = "";
    }
    //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
  }

  /**
   * 実際の設定値
   */
  private List<Item> value;

  /**
   * コンストラクタ
   */
  public IndApproveContentDto() {
    this.value = new ArrayList<>();
  }

  /**
   * セッター
   * @param value 値
   */
  public void setValue(List<Item> value) {
    this.value = value;
  }
  /**
   * 項目追加
   * @param value 値
   */
  public void addValue(Item value) {
    this.value.add(value);
  }

  /**
   * ゲッター
   * @return 値
   */
  public List<Item> getValue() {
    return this.value;
  }

  /**
   * JSON文字列化して取得
   * @return
   * @throws JsonProcessingException 文字列化失敗
   */
  public String getStringValue() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this.value);
  }
}
