package jp.co.nikkiso.ntss.admin_web.request.weight;

import java.math.BigDecimal;

import lombok.Data;

@Data
public class SendConditionRequest {

  /**
   * 治療番号
   */
  private Long ordNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 体重計番号
   */
  private Integer weightNo;
  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;
  /**
   * 患者ID
   */
  private Long patId;
  /**
   * クール
   */
  private Long kurCd;
  /**
   * クール名
   */
  private String kurName;
  /**
   * ベッド
   */
  private Long bedCd;
  /**
   * ベッド名
   */
  private String bedName;
  /**
   * 風袋
   */
  private String tare;
  /**
   * 風袋登録フラグ
   */
  private Short tareFlg;
  /**
   * 除水
   */
  private String offWater;
  /**
   * 除水登録フラグ
   */
  private Short offWaterFlg;
  /**
   * 測定値
   */
  private BigDecimal scaleValue;
  /**
   * 体重値
   */
  private BigDecimal weightValue;
  /**
   * 目標除水量
   */
  private BigDecimal targetOffWater;
  /**
   * 目標体重
   */
  private BigDecimal targetWeight;
  /**
   * スタッフID
   */
  private Long userId;
  /**
   * 体重計コード
   */
  private Long weightCd;
  /**
   * 体重計名称
   */
  private String weightName;
  /**
   * 体重測定区分
   */
  private Short scaleClass;
  /**
   * 体重測定モード
   */
  private Short scaleMode;
  /**
   * 測定日時
   */
  private String measureDate;

  /**
   * 目標除水量
   */
  private BigDecimal limitOffWater;
  /**
   * 車いすコード
   */
  private Long wheelChairCd;
  /**
   * 車いす名称
   */
  private String wheelChairName;
  /**
   * 車いす重量
   */
  private BigDecimal wheelChairWeight;
  /**
   * 治療コード
   */
  private Integer treatmentCd;
  /**
   * 治療名
   */
  private String treatmentName;
  /**
   * 装置モード
   */
  private Integer deviceMode;
  /**
   * 更新対象記録コード
   */
  private Long weightScaleNo;
  /**
   * 印刷有無
   */
  private String isPrint;
  /**
   * 印刷内容
   */
  private String printContent;
  /**
   * DW
   */
  private String dw;
  // add FNSI-分類不一致判断の追加 徐 start
  private Boolean chkIndCondInfoFlg;

  private Boolean mstDelFlg;

  private Boolean mstOverdueFlg;
  // add FNSI-分類不一致判断の追加 徐 end

  // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 start
  private Long scaleBedBedCd;
  // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 end
}
