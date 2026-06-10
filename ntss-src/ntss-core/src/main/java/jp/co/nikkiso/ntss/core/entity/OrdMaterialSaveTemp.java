package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

//mod by ztc 2023-02-10 [Optimize no.6118] --start /
@Getter
@Setter
public class OrdMaterialSaveTemp {
  // 処理タイプ(1:予定作成、2:予定コーピ)
  private Integer species;
  // 治療方法セットコード
  private String treatmentSetCd;
  // 施設コード
  private String facilityCd;
  // 患者ID
  private String patId;
  // データ基準日(復数可能)
  private List<String> suppliesBaseDate;
  // データ基準日
  private String baseDate;
  // データ基準番号
  private String suppliesBaseNo;
  // データ元基準番号
  private String originalBaseNo;
  // 削除されたOrdNoList
  private List<Long> ordNoList;
  // データ発生元区分
  //upd  No.8464 治療法変更、従来の治療条件、投与、医療材料削除問題なし修正 start
  private List<String> suppliesSourceClass;
  //upd  No.8464 治療法変更、従来の治療条件、投与、医療材料削除問題なし修正 end
  // 物品区分
  private String suppliesClass;
  // 物品コード
  private String suppliesCd;
  // 調整薬剤コード
  private String medicineMixCd;
  // 分類コード
  private String classCd;
  // 指示・実績区分
  private String indRstClass;
  // 指示・実績値
  private String indRstValue;
  // レセ値
  private String receiptValue;
  // 確定フラグ
  private String isConfirm;

  // 物品区分List
  private List<String> suppliesClassList;
  // 物品代码List
  private List<String> suppliesCdList;
  // 指示・実績区分 search contion
  private List<String> indRstClassList;
}
//mod by ztc 2023-02-10 [Optimize no.6118] --end /
