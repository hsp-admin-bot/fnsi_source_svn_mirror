package jp.co.nikkiso.ntss.core.entity.custom.lcdReq;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 仮想端末情報（投与薬剤）クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class LcdReq41 {

  /**
   * 配列番号（表示順）
   */
  private Integer idx;

  /**
   * 識別番号
   */
  private Integer sno;

  /**
   * 薬剤名
   */
  private String name;

  /**
   * 単位
   */
  private String unit;

  /**
   * 数量
   */
  private String amount;

  /**
   * 投与実施フラグ
   */
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String effectFlg;
  private Integer effectFlg;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

  /**
   * 投与実施日時
   */
  private String effectDate;

  /**
   * 投薬実施フラグ
   */
  private String isMedicated;

  /**
   * 透析工程コード
   */
  private String progressCd;

  /**
   * 治療開始後通知時間
   */
  private Integer alertTime;

  /**
   * 通知フラグ
   */
  private String isAlert;

}
