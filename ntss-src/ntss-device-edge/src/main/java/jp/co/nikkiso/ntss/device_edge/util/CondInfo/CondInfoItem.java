package jp.co.nikkiso.ntss.device_edge.util.CondInfo;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 *  治療条件項目クラス.
 */
@NoArgsConstructor
@Getter
@Setter
public class CondInfoItem {

  /** 項目コード */
  private Integer cd;
  /** 名称 */
  private String name;
  /** 設定値 */
  private String value;
  /** 単位 */
  private String unit;
  /** 薬剤区分 */
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String medicineType;
  private Integer medicineType;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  /** 指示者コード */
  private String indUserId;
  /** 指示者名(姓) */
  // TODO:コードから名前を引き当てる処理をServiceに実装する
  //  private String indUserLastName;
  /** 指示者名(名) */
  //  private String indUserFirstName;
  /** 更新者コード */
  private String updUserId;
  /** 更新者名(姓) */
  //  private String updUserLastName;
  /** 更新者名(名) */
  //  private String updUserFirstName;
  /** 登録区分 */
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String inputClass;
  private Integer inputClass;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
  /** 編集可否フラグ */
  private String isEditable;
  /** 連携オーダー番号 */
  private String copOrderNo;

  /** 小数点桁数  */
  private Integer decimalPoint;
}
