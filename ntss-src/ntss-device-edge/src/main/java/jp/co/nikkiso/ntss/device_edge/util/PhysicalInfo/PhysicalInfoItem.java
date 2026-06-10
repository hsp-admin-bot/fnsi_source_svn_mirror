package jp.co.nikkiso.ntss.device_edge.util.PhysicalInfo;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 *  身体情報項目クラス.
 */
@NoArgsConstructor
@Getter
@Setter
public class PhysicalInfoItem {
  /* 管理番号 */
  Integer ctlNo;
  /* 検査日時 */
  String examDate;
  /*検査区分  */
  Integer orderClass;
  /* 身長 */
  String height;
  /* 検査時の体重 */
  // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 start
//  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
//  //String ctrWeight;
//  BigDecimal ctrWeight;
//  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  String ctrWeight;
  // #11175 2024.10.17 mod ctr_weight は文字列で保存されている TDC片口 end
  /* 心横径 */
  String breastDia;
  /* 胸郭横径 */
  String chestDia;
  /* CTR */
  String ctr;
  /* DW */
  String dw;
  /* 目標体重 */
  String targetWeight;
  /* 指示者 */
  String indicatorCd;
  /*  コメント*/
  String memo;
  /* 前体重許容割合（上限） */
  String preScaleUpper;
  /* 前体重許容割合（下限） */
  String preScaleLower;
}
