import PeriodicInspectionStore from "@/stores/periodic-inspection/PeriodicInspectionStore";
/*add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 start*/
import MotionRecordStore from "@/stores/periodic-inspection/MotionRecordDoneStore";
/*add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 end*/
export const PERIODIC_INSPECTION = {
  /*add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 start*/
  "motion-record-done": MotionRecordStore,
  /*add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 end*/
  "periodic-inspection": PeriodicInspectionStore
};
