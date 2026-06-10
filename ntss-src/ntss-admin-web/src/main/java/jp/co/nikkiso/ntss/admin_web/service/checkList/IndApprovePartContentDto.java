package jp.co.nikkiso.ntss.admin_web.service.checkList;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;

import java.util.ArrayList;
import java.util.List;

public class IndApprovePartContentDto {

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
      private String value = "";
      /**
       * 更新者
       */
      private String updater = "";
      /**
       * 指示者
       */
      private String instructor = "";

      /**
       * コンストラクタ
       */
      public ItemData() {
        this.value = "";
        this.updater = "";
        this.instructor = "";
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
  }

  /**
   * 実際の設定値
   */
  private List<Item> value;

  /**
   * コンストラクタ
   */
  public IndApprovePartContentDto() {
    this.value = new ArrayList<>();
  }

  /**
   * セッター
   *
   * @param value 値
   */
  public void setValue(List<Item> value) {
    this.value = value;
  }

  /**
   * 項目追加
   *
   * @param value 値
   */
  public void addValue(Item value) {
    this.value.add(value);
  }

  /**
   * ゲッター
   *
   * @return 値
   */
  public List<Item> getValue() {
    return this.value;
  }

  /**
   * JSON文字列化して取得
   *
   * @return
   * @throws JsonProcessingException 文字列化失敗
   */
  public String getStringValue() throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    return mapper.writeValueAsString(this.value);
  }
}
