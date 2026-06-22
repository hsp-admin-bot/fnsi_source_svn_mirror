/**
 * Vuex - Store 定義（マスタ用Module分割取りまとめ）
 */
import MstComFixedPhraseStore from "@/stores/master/MstComFixedPhraseStore";
import MstCourseStore from "@/stores/master/MstCourseStore";
import MstDialysisDifficultyStore from "@/stores/master/MstDialysisDifficultyStore";
import MstDialyzerStore from "@/stores/master/MstDialyzerStore";
import MstDieStore from "@/stores/master/MstDieStore";
import MstDiseaseStore from "@/stores/master/MstDiseaseStore";
import MstFacilityStore from "@/stores/master/MstFacilityStore";
import MstInfectionStore from "@/stores/master/MstInfectionStore";
import MstInjuryStore from "@/stores/master/MstInjuryStore";
import MstMedicateTimingStore from "@/stores/master/MstMedicateTimingStore";
import MstMedicineStore from "@/stores/master/MstMedicineStore";
import MstProcedureStore from "@/stores/master/MstProcedureStore";
import MstTransportStore from "@/stores/master/MstTransportStore";
import MstTreatmentSetStore from "@/stores/master/MstTreatmentSetStore";
import MstTreatmentStore from "@/stores/master/MstTreatmentStore";
import MstWardStore from "@/stores/master/MstWardStore";

export const MASTER_STORES = {
  "mst-comfixed-phrase": MstComFixedPhraseStore,
  "mst-course": MstCourseStore,
  "mst-dialysis-difficulty": MstDialysisDifficultyStore,
  "mst-dialyzer": MstDialyzerStore,
  "mst-die": MstDieStore,
  "mst-disease": MstDiseaseStore,
  "mst-facility": MstFacilityStore,
  "mst-infection": MstInfectionStore,
  "mst-injury": MstInjuryStore,
  "mst-medicate-timing": MstMedicateTimingStore,
  "mst-medicine": MstMedicineStore,
  "mst-procedure": MstProcedureStore,
  "mst-transport": MstTransportStore,
  "mst-treatment-set": MstTreatmentSetStore,
  "mst-treatment": MstTreatmentStore,
  "mst-ward": MstWardStore
};
