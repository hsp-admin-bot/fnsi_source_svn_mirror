package jp.co.nikkiso.ntss.admin_web.response.statusList;

import org.seasar.doma.Id;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import jp.co.nikkiso.ntss.core.entity.MstTreatmentStatusDispItem;
import lombok.Getter;
import lombok.Setter;
import org.springframework.util.StringUtils;

/**
 * 治療状況レイアウト選択項目のResponse.
 */
@Getter
@Setter
public class DispItemListResponse extends FlagAndMessageBaseResponse {

  /**
   * レイアウト表示項目管理番号
   */
  @Id
  private Integer itemCd;
  /**
   * データ取得種別['0'：変換不要/'1'：変換必要]
   */
  private String dataClass;
  /**
   * 装置種別['0':透析装置/'1':DAB/'2':DAD/'3':DRO]
   */
  private String machineClass;
  /**
   * 項目名
   */
  private String itemName;
  /**
   * 参照先テーブル名
   */
  private String tableName;
  /**
   * 参照先フィールド名
   */
  private String fieldName;
  /**
   * 参照先JSONキー名
   */
  private String jsonKeyName;
  /**
   * バイタル・モニタ区分['1':バイタル/'2':モニタ]
   */
  private String vitalMonitorClass;
  /**
   * データ種類[空：指定なし/0：文字列/1：実数/2：整数/3：時分]
   */
  private String dataType;

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public DispItemListResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * コンストラクタ.
   * @param dispItem 表示項目情報
   */
  public DispItemListResponse(MstTreatmentStatusDispItem dispItem) {
    this.setItem(dispItem);
  }

  private void setItem(MstTreatmentStatusDispItem dispItem) {
    this.itemCd = dispItem.getItemCd();
    this.dataClass = dispItem.getDataClass();
    this.machineClass = dispItem.getMachineClass();
    this.itemName = dispItem.getItemName();
    this.tableName = dispItem.getTableName();
    this.fieldName = dispItem.getFieldName();
    this.jsonKeyName = dispItem.getJsonKeyName();
    this.vitalMonitorClass = "2";
    this.dataType = "";
  }

  /**
   * コンストラクタ
   * @param itemCd
   * @param dataClass
   * @param machineClass
   * @param itemName
   * @param tableName
   * @param fieldName
   * @param jsonKeyName
   * @param vitalMonitorClass
   * @param dataType
   */
  public DispItemListResponse(
      Integer itemCd,
      String dataClass,
      String machineClass,
      String itemName,
      String tableName,
      String fieldName,
      String jsonKeyName,
      String vitalMonitorClass,
      String dataType
      ) {
    this.itemCd = itemCd;
    this.dataClass = dataClass;
    this.machineClass = machineClass;
    this.itemName = itemName;
    this.tableName = tableName;
    this.fieldName = fieldName;
    this.jsonKeyName = jsonKeyName;
    this.vitalMonitorClass = vitalMonitorClass;
    this.dataType = dataType;
  }

  // #9312 Add by Z.T. 治療状況リスト，マップの表示が不正 Start
  /**
   * コンストラクタ
   *
   * @param dataClass
   * @param machineClass
   * @param itemName
   * @param tableName
   * @param fieldName
   * @param jsonKeyName
   * @param vitalMonitorClass
   * @param dataType
   */
  public DispItemListResponse(
    String dataClass,
    String machineClass,
    String itemName,
    String tableName,
    String fieldName,
    String jsonKeyName,
    String vitalMonitorClass,
    String dataType
  ) {
    this.dataClass = dataClass;
    this.machineClass = machineClass;
    this.itemName = itemName;
    this.tableName = tableName;
    this.fieldName = fieldName;
    this.jsonKeyName = jsonKeyName;
    this.vitalMonitorClass = vitalMonitorClass;
    this.dataType = dataType;

    if (StringUtils.hasText(jsonKeyName)) {
      StringBuilder nameChar = new StringBuilder();
      for (int i = 0; i < jsonKeyName.length(); i++) {
        nameChar.append((int) jsonKeyName.charAt(i));
      }
      this.itemCd = -10000 - Integer.parseInt(nameChar.toString());
    }
  }
  // ADD #9312 治療状況リスト，マップの表示が不正 End
}
