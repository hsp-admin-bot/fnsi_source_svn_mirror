package jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.request.sharePatient.DstPatientRequest;
import jp.co.nikkiso.ntss.admin_web.request.sharePatient.SrcPatientRequest;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.custom.PatPersonalMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatientInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PublicPatientInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ReceivedPatientInfo;

public interface MaterialsSharingPatientInfomationService {

    /**
     * 共有されている患者情報を選択します
     * @param patPersonalMainDataLst 患者検索一覧
     * @return 開示した患者一覧
     */
    List<PatientInfo> selectPatInfoPulic(List<PatPersonalMainData> patPersonalMainDataLst);
    /**
     * 受け取った患者のリストを取得する
     * @param loginFacilityCd ログイン施設CD
     * @param patPersonalMainDataLst 患者検索一覧
     * @return 受理患者一覧
     */
    List<PatientInfo> getPatientListReceive(String loginFacilityCd, List<PatPersonalMainData> patPersonalMainDataLst);

	/**
	 * 患者情報共有詳細画面(受理)施設を取得する.
	 * @param request
	 * @return 受け取った事業所のリスト
	 */
	List<ReceivedPatientInfo> getSrcFacilities(SrcPatientRequest request);

	/**
	 * 患者情報共有詳細画面(受理)変更を更新.
	 * @param request
	 * @return
	 * @throws Exception
	 */
	List<ReceivedPatientInfo> updateSrcFacilities(SrcPatientRequest request) throws Exception;

	/**
	 * 患者情報共有詳細画面(開示)変更を更新.
	 * @param request
	 * @return
	 */
	List<PublicPatientInfo> updateDstFacilities(DstPatientRequest request);

	/**
	 * 患者情報共有詳細画面(開示)施設を取得する
	 * @param request
	 * @return 与えられた基本リスト
	 */
	List<PublicPatientInfo> getDstFacilities(DstPatientRequest request);

	/**
	 * Pat_id_dstから患者IDを取得
	 * @param pat_id_dst
	 * @return
	 */
	List<PatNameIdentification> getListPatIdSrcFromPatDst(Long pat_id_dst);
	/**
	 * Pat_id_dst一覧から患者IDを取得
	 * @param pat_id_dst
	 * @return
	 */
	List<Long> getListPatIdSrcFromListPatDst(List<Long> pat_id_dst);


    /**
     * 患者情報共有受理側通知
     * @param patId 登録患者の内部患者ID
     * @param publicPatientInfos 通知先の施設コード
     */
    void registerPushNotification(Long patId, List<PublicPatientInfo> publicPatientInfos);

    /**
     * 承認済み施設コードを取得
     * @param pat_id_src
     * @return
     */
    List<String> getListFacilityCdDstApproved(Long pat_id_src);

  //add #12462 Pat_id_dstから患者IDを取得 患者情報共有 zrx start
  List<PatNameIdentification> getListPatIdSrcFromPatTo(Long pat_id_dst) ;

  List<OrdMain> findOrdMainByDateCdSharingInfo(String facility_cd, Long pat_id, String dialysis_date_from,
                                               String dialysis_date_to, List<Integer> weeksArry);
  //add #12462 Pat_id_dstから患者IDを取得 患者情報共有 zrx end
}
