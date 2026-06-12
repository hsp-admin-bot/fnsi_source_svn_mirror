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
    getKurComboList(_context, payload = {}) {
      return sendRequestGetComboList("mst_kur", "kur_name", "kur_cd", payload.selectedPatId);
    },
    // -----------------------------------------
    // ベッドのコンボデータ取得
    // -----------------------------------------
    getBedComboList(_context, payload = {}) {
      return sendRequestGetComboList("mst_bed", "bed_name", "bed_cd", payload.selectedPatId);
    },
    // -----------------------------------------
    // 病棟のコンボデータ取得
    // -----------------------------------------
    getWardComboList(_context, payload = {}) {
      return sendRequestGetComboList("mst_ward", "ward_name", "ward_cd", payload.selectedPatId);
    },
    // -----------------------------------------
    // 診療科のコンボデータ取得
    // -----------------------------------------
    getCourseComboList(_context, payload = {}) {
      return sendRequestGetComboList("mst_course", "course_name", "course_cd", payload.selectedPatId);
    },
    // -----------------------------------------
    // 送信先グループのコンボデータ取得
    // -----------------------------------------
    getDestinationGroupComboList(_context, payload = {}) {
      return sendRequestGetComboList(
        "mst_destination_group",
        "destination_group_name",
        "destination_group_cd",
        payload.selectedPatId
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
    getProcedureComboList(_context, payload = {}) {
      return sendRequestGetComboList(
        "mst_procedure",
        // テーブル設計書の誤りか
        "pricedure_name",
        "procedure_cd",
        payload.selectedPatId
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
    getMedicateTimingComboList(_context, payload = {}) {
      return sendRequestGetComboList(
        "mst_medicate_timing",
        "medicate_timing_name",
        "medicate_timing_cd",
        payload.selectedPatId
      );
    },
    // -----------------------------------------
    // 薬剤のコンボデータ取得
    // -----------------------------------------
    getMedicineComboList(_context, payload = {}) {
      return sendRequestGetComboList(
        "mst_medicine",
        "medicine_name",
        "medicine_cd",
        payload.selectedPatId
      );
    },
    // -----------------------------------------
    // 治療方法のコンボデータ取得
    // -----------------------------------------
    getTreatmentMethodComboList(_context, payload = {}) {
      return sendRequestGetComboList(
        "mst_treatment",
        "treatment_name",
        "treatment_cd",
        payload.selectedPatId
      );
    }
  }
};
