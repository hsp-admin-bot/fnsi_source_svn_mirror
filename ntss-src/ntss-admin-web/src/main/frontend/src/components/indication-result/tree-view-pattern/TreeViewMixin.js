/**
 * 予実リスト表示コンポーネント用のMixin
 */
import { mapActions, mapGetters } from "vuex";
import { confirmAllowDiscardChangesInRequestDetail } from "@/functions/exam-request/ExamRequestFunctions";

export default {
  props: {
    model: {
      required: true
    }
  },
  methods: {
    ...mapActions("treatment-record/common", ["setOrdNo"]),
    ...mapActions("pat-viewer", ["setTreatBaseDate"]),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
    ...mapActions("split-graph", ["setExamRecordDate"]),
    ...mapActions("exam-request/list", {
      setSelectedPatId: "setSelectedPatId",
      examRequestSetTreatBaseDate: "setTreatBaseDate"
    }),
    ...mapActions("rad-request/list", {
      setPhotoSelectedPatId: "setSelectedPatId",
      radRequestSetTreatBaseDate: "setTreatBaseDate"
    }),
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("pat-event/list", {
      setConditionDate: "setConditionDate",
      patEventSetTreatBaseDate: "setTreatBaseDate"
    }),
    ...mapActions("pat-prescription", {preSetTreatBaseDate: "setTreatBaseDate"}),
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
    async onClick(model) {
      // 現在の画面が検査依頼または一般撮影検査依頼で、
      // 依頼の編集状態があり、破棄確認でキャンセルされた場合は中止する
      if (!(await confirmAllowDiscardChangesInRequestDetail())) return;

      // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      // if (model.isResult) {
      //     // オーダ番号を設定し、治療記録画面に遷移
      //     this.setOrdNo(model.ordNo).then(() => {
      //     this.$router.push({ name: "treatment-record", params: { footer: null } });
      //   });
      // } else {
      //     // 治療日を設定し、患者経過総合ビューア画面に遷移
      //     this.setTreatBaseDate(model.treatmentDate).then(() => {
      //     this.$router.push({ name: "pat-viewer", params: { footer: null } });
      //   });
      // }
      if (!model.type && model.isResult) {
        // オーダ番号を設定し、治療記録画面に遷移
        this.setOrdNo(model.ordNo).then(() => {
          this.$router.push({ name: "treatment-record", params: { footer: null }});
        });
      } else if (!model.type && !model.isResult) {
        // 治療日を設定し、患者経過総合ビューア画面に遷移
        this.setTreatBaseDate(model.treatmentDate).then(() => {
          this.$router.push({ name: "pat-viewer", params: { footer: null }});
        });
      } else if (model.type && model.type == 'pat_event') {
        // 患者イベント画面に遷移
        const treatDateList = [model, new Date()];
        this.patEventSetTreatBaseDate(treatDateList).then(() => {
          this.$router.push({ name: "pat-event", params: { condition: model }});
        });
      } else if (model.type && model.type == 'in_schedule') {
        // 検査予定画面へ遷移
        this.setSelectedPatId(this.selectedPatId());
        const treatDateList = [model, new Date()];
        this.examRequestSetTreatBaseDate(treatDateList).then(() => {
          this.$router.push({ name: "exam-request" });
          this.$router.push({ name: "exam-request-detail", params: { condition: model }});
        });
      } else if (model.type && model.type == 'in_result') {
        // 検査結果画面へ遷移
        this.$router.push({ name: "exam-record" });
        this.$router.push({ name: "exam-record-detail", params: { condition: model } });
      } else if (model.type && model.type == 'in_photo') {
        // 一般撮影検査予定へ遷移
        this.setPhotoSelectedPatId(this.selectedPatId());
        const treatDateList = [model, new Date()];
        this.radRequestSetTreatBaseDate(treatDateList).then(() => {
          this.$router.push({ name: "rad-request" });
          this.$router.push({ name: "rad-request-detail", params: { condition: model }});
        });
      } else if (model.type && model.type == 'prescription') {
        // 処方へ遷移
        const treatDateList = [model, new Date()];
        this.preSetTreatBaseDate(treatDateList).then(() => {
          this.$router.push({ name: "prescription" });
          this.$router.push({ name: "pat-prescription", params: { condition: model }});
        });
      }
      // mod FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end

      // 患者選択画面を閉じるため、患者IDを再セット
      this.selectPat(this.selectedPatId());
    }
  }
}
