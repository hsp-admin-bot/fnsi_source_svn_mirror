package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import java.math.BigDecimal;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ScaleBedAllState {

  /**
   * システムで管理する一意なオーダ番号
   */
  private Long ordNo;

  /**
   * システムで管理する一意な患者ID
   */
  private Long patId;

  /**
   * 同名フラグ
   */
  private String isSame;

  /**
   * ベッドコード
   */
  private Long bedCd;

  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 測定値　(実績)
   */
  private BigDecimal ScaleValue;

  /**
   * 接続状態
   */
  private String isConnect;

  /**
   * 送信状態
   */
  private Integer sendStatus;

  /**
   * 体重計コード
   */
  private Long weightCd;
  /**
   * 体重計番号
   */
  private Integer weightNo;

  /**
   * 実績：治療状況
   */
  private String rstDialysisState;

  /**
   * 次患者クールCD.
   */
  private Long kurCd;

  /**
   * 体重測定履歴番号(実績)
   */
  private Long weightScaleNo;
  /**
   * 体重測定履歴番号(スケールベッドステータス)
   */
  private Long ssWeightScaleNo;

  /**
   * 測定状況
   */
  private Integer weightScaleStatus;

  /**
   * 工程状態
   */
  private String processState;

  /**
   * 通信種別
   */
  private Integer comType;

  /**
   * 通信フォーマット
   */
  private String comFormatCd;

  /**
   * ベッドの並び順
   */
  private Long bedOrderIndex;

  /**
   * 個人所有車番号
   */
  private Long wheelChairCd;

  /**
   * 測定モード
   */
  private Long scaleMode;

  /**
   * 車いすモード
   */
  private String isWheelChair;

  /**
   * ベッド名
   */
  private String bedName;

  /**
   * 風袋情報
   */
  private String indTareInfo;
  /**
   * 実績風袋情報
   */
  private String rstTareInfo;

  /**
   * 前体重印刷設定
   */
  private Long isDefaultPrintBefore;

  /**
   * 後体重印刷設定
   */
  private Long isDefaultPrintAfter;

  /**
   * 実績：体重情報
   */
  private Integer scaleClass;

  /**
   * 実績：体重情報
   */
  private String rstWeightInfo;
  /**
   * 実績：前体重値
   */
  private BigDecimal weightBefore;

}
