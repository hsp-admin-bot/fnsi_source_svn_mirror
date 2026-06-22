package jp.co.nikkiso.ntss.core.entity;

import java.math.BigDecimal;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 体重計状態のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_weight_state")
@Getter
@Setter
public class MntWeightState extends BaseEntity {

  /**
   * 体重計管理コード
   */
  @Id
  private Long weightCd;

  /**
   * 接続状態.
   */
  private String isConnect;

  /**
   * 測定値
   */
  private BigDecimal scaleValue;

  /**
   * バーコードリーダー読み取り値
   */
  private String barcodeValue;

  /**
   * カード読み取り値
   */
  private String cardReadValue;

  /**
   * カード書き込み内容
   */
  private String cardWriteValue;

  /**
   * カード書き込み結果
   */
  private int writeResult;
  // add FNSI-田中衡機の追加 徐 start
  /**
   * 田中衡機の測定重量
   */
  private String scaleValueList;
  // add FNSI-田中衡機の追加 徐 end

  /**
   * 施設コード.
   */
  private String facilityCd;
}
