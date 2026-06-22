package jp.co.nikkiso.ntss.admin_web.service.mstTreatment;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.api.service.utils.InvokeResult;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import org.json.JSONObject;

/**
 * 治療方法マスタのServiceインタフェース.
 */
public interface TreatmentService {

  //  add #7327-治療方法マスタ操作時の動作がおかしい 徐博 start
  int getOrdMainByCd(String indTreatmentCd);
  //  add #7327-治療方法マスタ操作時の動作がおかしい 徐博 end

	/**
	 * 更新OrdMain
	 *
	 * @param facilityCd      施設コード
	 * @param treatmentCdList 治療方法コード
	 * @param map             治療方法情報
	 * @param userId          ユーザーID
	 */
	void updateOrdMain(String facilityCd, List<Integer> treatmentCdList, Map<Integer, JSONObject> map, Long userId)
			throws Exception;

	/**
	 * 更新PatTreatmentPattern
	 *
	 * @param facilityCd      施設コード
	 * @param treatmentCdList 治療方法コード
	 * @param map             治療方法情報
	 * @param userId          ユーザーID
	 */
	void updatePatTreatmentPattern(String facilityCd, List<Integer> treatmentCdList, Map<Integer, JSONObject> map,
			Long userId) throws Exception;

  //del #10412 次患者更新関連全体見直し対応 朴 start
//  // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
//  /**
//	 * IndCondInfoの更新
//	 *  @param facilityCd      施設コード
//	 * @param treatmentList   治療方法情報
//   * @param userId          ユーザーID
//   * @return
//   */
//  // mod bug 8099 修正 chen start
//  JournalCreateRequestResponse updateOrdMainForTreatment(String facilityCd, List<Map<String, Object>> treatmentList, Long userId, NtssUser ntssUser) throws Exception;
//  // mod bug 8099 修正 chen end
//
//  // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
  //del #10412 次患者更新関連全体見直し対応 朴 end

  /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */
  void updatetByTreatSetCdSup(Map<String, Long> request);

  void updateTreatmentRecord(String facilityCd, List<Integer> treatmentCdList, Map<Integer, JSONObject> condList, NtssUser ntssUser);

  // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --start /
  List<Integer> getOrdMainByCds(List<Integer> indTreatmentCds);
  // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --end /


  /* add by gaojuncheng  2023-01-31 [CodeOptimization]  end */

  //add 9664 by kangjie 20231212 start
  InvokeResult<Map<String,List>> updateOrdMainForMstTreatment(String facilityCd, Map treatment, Long userId, NtssUser ntssUser);
  // add 9664 by kangjie 20231212 end

	//add 9664 by shiyw 20231212 start
	/**
	 * 次患者更新
	 * @param facilityCd
	 * @param ordMainList
	 */
	void callSetNextPatInfo(String facilityCd, List<OrdMain> ordMainList);
	//add 9664 by shiyw 20231212 end

  //add 9664 by kangjie 20240515 start
  MstTreatment selectByCd(Integer treatmentCd);
  //add 9664 by kangjie 20240515 end
}
