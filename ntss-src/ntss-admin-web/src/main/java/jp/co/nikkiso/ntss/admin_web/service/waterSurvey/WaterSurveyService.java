package jp.co.nikkiso.ntss.admin_web.service.waterSurvey;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.MntWaterSurvey;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurvey;
/**
 * 水質管理のServiceインターフェース.
 */
public interface WaterSurveyService {
	/**
	 * リストを取得水質管理
	 * @param startDate 開始日
	 * @param endDate 終了日
	 * @param facilityCd 施設コード
	 * @param ListSurveytypeCd リスト調査タイプコード
	 * @param listBedGroupCd リストベッドグループコード
	 * @return
	 */
	List<MntWaterSurvey> filter(String startDate, String endDate, List<Long> ListSurveytypeCd, String bedGroupCd, String facilityCd) throws Exception;

	/**
	 * 調査記録による選択いいえ
	 * @param surveyRecordNo 水質調査記録番号
	 * @throws Exception
	 */
	WaterSurvey selectBySurveyRecordNo(Long surveyRecordNo) throws Exception;
	
	/**
   * 複数の水質管理を節約
   * @param watSurveys 水質管理のリスト
   * @return
   */
	void insertOrUpdateWaterSurveyMulti(List<WaterSurvey> watSurveys);
	
	/**
	   * リスト水調査を削除
	   * @param waterSurveyRequest 水質調査依頼
	   * @param facilityCd 施設コード
	   * @throws Exception 
	*/
	void deleteWaterSurvey(Long surveyRecordNo, String facilityCd) throws Exception;
	
	/**
	   * 調査データを削除
	   * @param surveyRecordNo 水質調査記録番号
	   * @param pointCd 調査箇所コード
	   * @param facilityCd 施設コード
	   * @throws Exception 
	*/
	void deleteSurverDataByPointCd(Long surveyRecordNo, Long pointCd, String facilityCd) throws Exception;
	
	/**
	   * 調査データを削除
	   * @param surveyRecordNo 水質調査記録番号
	   * @param pointCds 調査箇所コード
	   * @param facilityCd 施設コード
	   * @throws Exception 
	*/
	void deleteListSurverData(Long surveyRecordNo, Map<String, String> pointCds, String facilityCd) throws Exception;

	// add FNSI-水質管理_青田の対応 徐 start
	/**
	   * 調査データを結果削除
	   * @param surveyRecordNo 水質調査記録番号
	   * @param pointCd 調査箇所コード
	   * @param facilityCd 施設コード
	   * @throws Exception
	   */
	void removeSurverDataByPointCd(Long surveyRecordNo, Long pointCd, String facilityCd) throws Exception;
	/**
	   * 調査データを結果削除
	   * @param surveyRecordNo 水質調査記録番号
	   * @param pointCds 調査箇所コード
	   * @param facilityCd 施設コード
	   * @throws Exception
	   */
	void removeListSurverData(Long surveyRecordNo, Map<String, String> pointCds, String facilityCd) throws Exception;
	// add FNSI-水質管理_青田の対応 徐 end
}
