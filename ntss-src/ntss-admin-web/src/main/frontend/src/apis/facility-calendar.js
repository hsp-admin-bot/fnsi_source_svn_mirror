import { ApiHelper } from "@/apis/AxiosHelper";

export function sendRequestGetPatEventCateMst() {
  return ApiHelper.get('/master_maintenance/mst_pat_event_category/data');
}

export function sendRequestGetPatSubEventCateMst() {
  return ApiHelper.get('/master_maintenance/mst_pat_event_sub_category/data');
}