import { ApiHelper } from "@/apis/AxiosHelper";

export function createJournal(params) {
  return ApiHelper.post("/patInfo/create", params);
}

export function getOrdCoopNoList(params) {
  return ApiHelper.get(`/journal-web/ordCoopNo/${params.facilityCd}/${params.ordNo}/${params.coopCd}`);
}
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
export function createJournalList(params) {
  return ApiHelper.post("/patInfo/create/list", params);
}
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end