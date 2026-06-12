
/* add by chamaojia 2022-12-06 [5958] データの持続化が必要なデータ,stores/index.jsから移行した --start */
/**
 * データの持続化が必要なコンテンツ
 */
export const persistStorePaths = [
  "account-edit",
  "app",
  "bread-crumb",
  "user",
  "device-edge-operation",
  "operation-viewer.facility",
  "operation-viewer.machine",
  "operation-viewer.motion-record",
  "operation-viewer.motion-record-detail.motionRecord",
  "operation-viewer.motion-record-detail.motionRecordDetail",
  "master-maintenance",
  "observe-record",
  "status-list",
  "check-list",
  "status-map",
  "mst-alarm-notification",
  "mst-destination-group",
  "schedule-assignment",
  "exam-record",
  "treatment-record",
  "mst-complaint",
  "multi-calendar",
  // add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou start
  "multi-pat-list",
  // add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou end
  "report-menu",
  "facility",
  "indication",
  "usage-subscription",
  "application-list",
  "view-log",
  "water-quality-survey",
  "url-link-register",
  "ord-addition",
  "periodic-inspection",
  /*add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 start*/
  "motion-record-done",
  /*add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 end*/
  "daily-check",
  "split-graph",
  "pat-list-layout",
];
/* add by chamaojia 2022-12-06 [5958] データの持続化が必要なデータ,stores/index.jsから移行した  --end */
