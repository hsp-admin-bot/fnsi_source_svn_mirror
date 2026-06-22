package jp.co.nikkiso.ntss.admin_web.service;


import jp.co.nikkiso.ntss.admin_web.response.bbsInfo.BbsInfoResponse;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.BbsSearchRequest;
import jp.co.nikkiso.ntss.core.entity.BbsInfo;
import jp.co.nikkiso.ntss.core.entity.BbsInfoCount;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstUserAuthentication;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface BbsInfoService {

  /**
   * 掲示板登録情報取得(施設指定)
   */
  Page<BbsInfo> getBbsInfoByFacilityCd(Pageable pageable, String facility_cd) throws Exception;

  /**
   * 掲示板登録情報取得(掲示板番号指定)
   */
  BbsInfo getBbsInfoByNo(long bbs_ctl_no);

  /**
   * 掲示板登録情報登録
   */
  long createBbs(Map<String, String> payload) throws Exception;

  /**
   * 掲示板登録情報更新
   * @throws Exception
   */
  void updateBbs(long bbs_ctl_no, Map<String, String> payload) throws Exception;

  /**
   * 掲示板登録情報一覧更新
   * @throws Exception
   */
  void updateBbsList(List<Map<String, String>> payload,String curLoginFacilityCd) throws Exception;

  /**
   * 掲示板登録情報削除
   * @throws Exception
   */
  void deleteBbs(long bbs_ctl_no) throws Exception;

  /**
   * 検索
   * @throws Exception
   */
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
// List<BbsInfo> getBbsSearchCondition(String facility_cd, BbsSearchRequest searchConditions) throws Exception;
// delete FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
 List<BbsInfoCount> getBbsSearchCondition(String facility_cd, BbsSearchRequest searchConditions) throws Exception;
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end

 /**
  * イベントカレンダーを検索
  * @throws Exception
  */
 List<BbsInfoResponse> getBbsSearchConditionForCalendar(String facility_cd, BbsSearchRequest searchConditions) throws Exception;
  //  add 6216 施設イベントの表示条件の不正 zhao start
 List<BbsInfoResponse> getBbsSearchConditionForCalendarFacCalLayoutCd(Long facCalLayoutCd,List<BbsInfoResponse> bbsInfo) throws Exception;
  //  add 6216 施設イベントの表示条件の不正 zhao end


 /**
  * 検索患者情報
  * @throws Exception
  */
 List<PatPersonalMain> getPatList(List<Long> patIdList, String facilityCd) throws Exception;

 /**
  * ログイン利用者取得
  * @throws Exception
  */
 MstUserAuthentication getUserAuthentication(String disp_user_id, String facility_cd) throws Exception;

 /**
  * ファイルダウンロード
  * @throws Exception
  */
  String downloadBbsFileAttachment(String filepath, String facility_cd) throws Exception;

 /**
  * ファイルアップロード
  * @throws Exception
  */
  void uploadBbsFileAttachment(MultipartFile file, String bbsInfo) throws Exception;

 /**
  * ファイル削除
  * @throws Exception
  */
  void deleteBbsFileAttachment(List<Map<String, String>> fileInfo, long bbs_ctl_no, String facility_cd) throws Exception;

 /**
  * 添付ファイル情報更新
  * @throws Exception
  */
  void updateBbsFileInfo(long bbs_ctl_no, Map<String, String> payload) throws Exception;
  /*add FNSI-改修内容掲示板外结No.10 任 start*/
  List<MstJob> getJobName(String facilityCd);
  List<PatMain> getIsSame();
  /*add FNSI-改修内容掲示板外结No.10 任 end*/

  // add 入院・同姓同名配布 趙 start
  List<PatMain> getPatIsSame(List<String> facilityCdList);
  // add 入院・同姓同名配布 趙 end
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
  void updateDateByCd(Long bbsCtlNo, int dataNumber);
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  end
}
