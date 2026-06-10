/**
 * 参照型コンボストア
 */
import {sendRequestGetComboList, sendRequestGetComboListByFacilityCd} from "@/apis/reference-combo";

export default {
  strict: true,
  namespaced: true,
  state: {},
  actions: {
    // -----------------------------------------
    // クールのコンボデータ取得
    // -----------------------------------------
    getKurComboList() {
      return sendRequestGetComboList("mst_kur", "kur_name", "kur_cd");
    },
    // -----------------------------------------
    // ベッドのコンボデータ取得
    // -----------------------------------------
    getBedComboList() {
      return sendRequestGetComboList("mst_bed", "bed_name", "bed_cd");
    },
    // -----------------------------------------
    // 病棟のコンボデータ取得
    // -----------------------------------------
    getWardComboList() {
      return sendRequestGetComboList("mst_ward", "ward_name", "ward_cd");
    },
    // -----------------------------------------
    // 診療科のコンボデータ取得
    // -----------------------------------------
    getCourseComboList() {
      return sendRequestGetComboList("mst_course", "course_name", "course_cd");
    },
    // -----------------------------------------
    // 送信先グループのコンボデータ取得
    // -----------------------------------------
    getDestinationGroupComboList() {
      return sendRequestGetComboList(
        "mst_destination_group",
        "destination_group_name",
        "destination_group_cd"
      );
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    getDestinationGroupComboListByFacilityCd(tmp, facilityCd) {
      return sendRequestGetComboListByFacilityCd(
        "mst_destination_group",
        "destination_group_name",
        "destination_group_cd",
        facilityCd
      );
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s end
    // -----------------------------------------
    // 手技のコンボデータ取得
    // -----------------------------------------
    getProcedureComboList() {
      return sendRequestGetComboList(
        "mst_procedure",
        // テーブル設計書の誤りか
        "pricedure_name",
        "procedure_cd"
      );
    },
    getProcedureComboListByFacilityCd(tmp, facilityCd) {
      return sendRequestGetComboListByFacilityCd(
        "mst_procedure",
        // テーブル設計書の誤りか
        "pricedure_name",
        "procedure_cd",
        facilityCd
      );
    },
    // -----------------------------------------
    // 時間帯のコンボデータ取得
    // -----------------------------------------
    getMedicateTimingComboList() {
      return sendRequestGetComboList(
        "mst_medicate_timing",
        "medicate_timing_name",
        "medicate_timing_cd"
      );
    },
    // -----------------------------------------
    // 薬剤のコンボデータ取得
    // -----------------------------------------
    getMedicineComboList() {
      return sendRequestGetComboList(
        "mst_medicine",
        "medicine_name",
        "medicine_cd"
      );
    },
    // -----------------------------------------
    // 治療方法のコンボデータ取得
    // -----------------------------------------
    getTreatmentMethodComboList() {
      return sendRequestGetComboList(
        "mst_treatment",
        "treatment_name",
        "treatment_cd"
      );
    }
  }
};
