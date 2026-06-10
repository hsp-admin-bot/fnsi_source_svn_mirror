package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 治療状況レイアウトビュー用のクラス
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TreatmentStatusLayoutViewItems implements Cloneable{
  /**
   * 表示順
   */
  @JsonProperty("order_no")
  private Integer orderNo;
  /**
   * 表示列名
   */
  @JsonProperty("title")
  private String title;
  /**
   * 表示幅(em)
   */
  @JsonProperty("width")
  private Integer width;
  /**
   * データ種類
   */
  @JsonProperty("data_class")
  private Integer dataClass;
  /**
   * データの取得先テーブル名称
   */
  @JsonProperty("table_name")
  private String tableName;
  /**
   * データの取得先列名
   */
  @JsonProperty("column_name")
  private String columnName;
  /**
   * データの取得先キー名称
   */
  @JsonProperty("key_name")
  private String keyName;

  /**
   * 変換区分('0':変換不要/1:変換必要)
   */
  @JsonProperty("conv_type")
  private String convType;
  /**
   * データのバイタル・モニタ区分('1':バイタル/'2':モニタ)
   */
  @JsonProperty("vital_monitor_class")
  private String vitalMonitorClass;
  /**
   * データ区分(空：指定なし/0：文字列/1：実数/2：整数/3：時分)
   */
  @JsonProperty("data_type")
  private String dataType;


  /**
   * クローンメソッド
   */
  @Override
  public TreatmentStatusLayoutViewItems clone() {
    TreatmentStatusLayoutViewItems ret = null;
    try {
      ret = (TreatmentStatusLayoutViewItems)super.clone();
    } catch ( Exception ex ) {
    }
    return ret;
  }
}