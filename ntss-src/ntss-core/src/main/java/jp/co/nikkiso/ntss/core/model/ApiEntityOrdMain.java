package jp.co.nikkiso.ntss.core.model;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

public class ApiEntityOrdMain {
  @Getter
  @Setter
  public static class ValiOrdMaterialSave {
    // 処理タイプ(1:予定作成、2:予定コーピ)
    private Integer species;
    // 治療方法セットコード
    private String treatment_set_cd;
    // 施設コード
    private String facility_cd;
    // 患者ID
    private String pat_id;
    // データ基準日(復数可能)
    private List<String> supplies_base_date;
    // データ基準日
    private String base_date;
    // データ基準番号
    private String supplies_base_no;
    // データ元基準番号
    private String original_base_no;
    // 削除されたOrdNoList
    private List<Long> ord_no_list;
    // データ発生元区分
    private String supplies_source_class;
    // 物品区分
    private String supplies_class;
    // 物品コード
    private String supplies_cd;
    // 調整薬剤コード
    private String medicine_mix_cd;
    // 分類コード
    private String class_cd;
    // 指示・実績区分
    private String ind_rst_class;
    // 指示・実績値
    private String ind_rst_value;
    // レセ値
    private String receipt_value;
    // 確定フラグ
    private String is_confirm;

    // 物品区分List
    private List<String> supplies_class_list;
    // 物品代码List
    private List<String> supplies_cd_list;
    // 指示・実績区分 search contion
    private List<String> indRstClassList;
  }
}