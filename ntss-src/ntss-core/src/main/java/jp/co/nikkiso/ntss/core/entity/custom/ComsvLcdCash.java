package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバ用仮想端末キャッシュデータクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvLcdCash {

  /**
   * 仮想端末情報(酸素吸入)
   */
  private String lcdCashReq32;

  /**
   * 仮想端末情報(体重トレンド)
   */
  private String lcdCashReq38;

  /**
   * 仮想端末情報(透析日報)
   */
  private String lcdCashReq40;

  /**
   * 仮想端末情報(投与薬剤)
   */
  private String lcdCashReq41;

  /**
   * 仮想端末情報(抗凝固剤)
   */
  private String lcdCashReq42;

  /**
   * 仮想端末情報（禁忌）
   */
  private String lcdCashReq44;

  /**
   * 仮想端末情報（メモ）
   */
  private String lcdCashReq45;

  /**
   * 仮想端末情報(検査グラフ)
   */
  private String lcdCashReq46;

  /**
   * 仮想端末情報(穿刺／回収／担当)
   */
  private String lcdCashReq51;

  /**
   * 仮想端末情報(指示／特記)
   */
  private String lcdCashReq52;

  /**
   * 仮想端末情報(CTRトレンド)
   */
  private String lcdCashReq53;

  /**
   * 仮想端末情報(チェックリスト1)
   */
  private String lcdCashReq54No1;

  /**
   * 仮想端末情報(チェックリスト2)
   */
  private String lcdCashReq54No2;

  /**
   * 仮想端末情報(チェックリスト3)
   */
  private String lcdCashReq54No3;

  /**
   * 仮想端末情報(チェックリスト4)
   */
  private String lcdCashReq54No4;

  /**
   * 仮想端末情報(チェックリスト5)
   */
  private String lcdCashReq54No5;

  /**
   * 仮想端末情報(チェックリスト6)
   */
  private String lcdCashReq54No6;

  /**
   * 仮想端末情報(チェックリスト7)
   */
  private String lcdCashReq54No7;

  /**
   * 仮想端末情報(チェックリスト8)
   */
  private String lcdCashReq54No8;

  /**
   * 仮想端末情報(予備)
   */
  private String lcdCashWork;

}