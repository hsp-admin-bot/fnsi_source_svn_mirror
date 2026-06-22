/**
 * ジャーナル（患者経過・連携）系 API
 */
import { ApiHelper } from "@/apis/AxiosHelper";

/**
 * ジャーナル登録
 * @param {Record<string, unknown>} params ジャーナル登録用ペイロード
 */
export function createJournal(params) {
  return ApiHelper.post("/patInfo/create", params);
}

/**
 * オーダ連携番号一覧取得
 * @param {{ facilityCd: string; ordNo: string|number; coopCd: string|number }} params
 */
export function getOrdCoopNoList(params) {
  return ApiHelper.get(
    `/journal-web/ordCoopNo/${params.facilityCd}/${params.ordNo}/${params.coopCd}`
  );
}

// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou start
/**
 * ジャーナル一括登録
 * @param {Record<string, unknown>} params ジャーナル一括登録用ペイロード
 */
export function createJournalList(params) {
  return ApiHelper.post("/patInfo/create/list", params);
}
// add 8548 【IES起票】患者経過総合ビューアで、スケジュール編集による【ope_cd】出力間違い；スケジュール表画面で【指定済ベッド→ベッド未登録】による電文出力間違い。zhou end
