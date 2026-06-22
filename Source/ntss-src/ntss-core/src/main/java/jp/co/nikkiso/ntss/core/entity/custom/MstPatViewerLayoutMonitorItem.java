package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Data;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 患者経過総合ビューアレイアウトマスタのバイタル・モニタに表示する選択肢のエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE )
@Data
public class MstPatViewerLayoutMonitorItem {

  /**
   * テーブル種別
   *  1 : sys_monitor_item から取得したデータ
   *  2 : mst_add_monitor から取得したデータ
   */
  private Integer tableType;

  /**
   * 項目コード
   */
  private String moniDataNo;

  /**
   * バイタル・モニタ区分
   *  1 : バイタル
   *  2 : モニタ
   */
  private String vitalMonitorClass;

  /**
   * バイタル・モニタ項目名称
   */
  private String vitalMonitorItemName;

  /**
   * モニタデータ種別
   */
  private String moniDataType;

  /**
   * 項目コード（ソート用）
   * ※DADや特殊浄化等の場合、頭に英文字を取り除いた数値です.
   */
  private Long moniDataNoSort;

  /**
   * 特殊浄化装置種別
   *  1 : シグマ
   * 　2 : KM8900
   * 　3 : iQ
   * 　4 : KM9000
   */
  private Integer purificationType;

  /***
   * 最大値
   */
  private Integer upper;

  /***
   * 最小値
   */
  private Integer lower;

  /**
   * 表示フラグ
   */
  private String isDisp;
}
