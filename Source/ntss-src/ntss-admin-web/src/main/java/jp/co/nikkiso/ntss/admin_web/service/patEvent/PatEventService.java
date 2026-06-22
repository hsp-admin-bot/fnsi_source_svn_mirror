package jp.co.nikkiso.ntss.admin_web.service.patEvent;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.ShrPatInfo;
import org.apache.commons.lang3.tuple.Pair;

import jp.co.nikkiso.ntss.admin_web.request.patEvent.PatEventRequest;
import jp.co.nikkiso.ntss.admin_web.response.patEvent.PatEventMasterResponse;
import jp.co.nikkiso.ntss.core.entity.MstPatEventCategory;
import jp.co.nikkiso.ntss.core.entity.MstPatEventDataTemplate;
import jp.co.nikkiso.ntss.core.entity.MstPatEventSubCategory;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatEventShare;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.SysFacility;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatEventRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventCoopInfo;
import org.springframework.web.multipart.MultipartFile;

import java.sql.Timestamp;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public interface PatEventService {

  /**
   * sysDataSetの項目を取得
   * @param mode 0: リスト項目 1: テキスト項目
   * @return
   */
  List<SysDataSet> getSysDataSet(Integer mode);

  List<OrdMainPatEventRecCombo> selectPatEventRecCombo(String facilityCd, Long patId, Timestamp dialysisDateFrom,
                                                       Timestamp dialysisDateTo, Integer mode);

  List<PatEventShare> selectByPatIdNewestShare(Long pat_id, Timestamp event_start_date_from, Timestamp event_start_date_to, String facilityCd, Long... patEventCdList);
  List<PatEvent> selectByCd(Long pat_event_cd);

  // add FNSI-観察記録を追加 楊 start
  /**
   * 患者経過総合ビューア取得用、観察記録データ取得
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 観察記録のResponse
   */
  List<PatEvent> FindPatEventByDateCd(long pat_id, String dialysis_date_from, String dialysis_date_to);
  // add FNSI-観察記録を追加 楊 end

  // add FNSI-患者イベント（仮）を追加 李 start
  /**
   * 患者経過総合ビューア取得用、患者イベント（仮）データ取得
   * @param pat_id 患者ID
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  List<PatEvent> FindPatientByDateCd(long pat_id, String dialysis_date_from, String dialysis_date_to, String facilityCd);
  // add FNSI-患者イベント（仮）を追加 李 end

  // add 426 姜 start
  // mod FNSI-FutreNetWeb+SI課題管理No.4710 李 start
  // void updateDateByCd(String patEventCd, int dataNumber);
  void updateDateByCd(ArrayList<String> patEventCd, int dataNumber);
  // mod FNSI-FutreNetWeb+SI課題管理No.4710 李 end


  void deleteDateByCd(String patEventCd);
  // add 426 姜 end
  List<PatEvent> selectByOrdNo(Long ord_no,String facilityCd);
  // update by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
  List<PatEvent> create(PatEventRequest request) throws ParseException;
  // update by YangYongzhuang  2023-02-03 [CodeOptimization]  End /
  PatEvent update(PatEvent patEvent, Boolean isNotification);
  /*add FNSI-改修内容転入転出の患者情報連動 任 start*/
  PatEvent updateLetterInfo(PatEvent patEvent);
  /*add FNSI-改修内容転入転出の患者情報連動 任 end*/

  PatEvent updateResultParams(PatEvent patEvent);

  void delete(Long pat_event_cd);

  PatEvent updateBbsCtlNo(PatEvent patEvent);

  PatEventMasterResponse findPatEventMaster(String facilityCd);

  List<MstPatEventDataTemplate> selectPatEventTemplate(String facilityCd);

  List<MstPatEventSubCategory> selectPatEventSubCategory(String facilityCd);

  List<MstPatEventCategory> selectPatEventCategory(String facilityCd);

  OrdMainPatEventRecCombo selectOrdMain(Long ordNo, Long patId);

  /**
   * ファイルダウンロード
   * @throws Exception
   */
  String downloadEventFileAttachment(String filepath, String facilityCd) throws Exception;

  /**
   * ファイルアップロード
   * @throws Exception
   */
  void uploadEventFileAttachment(MultipartFile file, String patEvent) throws Exception;

  /**
   * ファイル削除
   * @throws Exception
   */
  void deleteEventFileAttachment(List<Map<String, String>> fileInfo, Long pat_id, String facilityCd) throws Exception;

  /**
   * イメージファイルダウンロード
   * @throws Exception
   */
  String downloadEventImageAttachment(String filepath, Timestamp upDate, String facilityCd) throws Exception;

  /**
   * イメージファイルアップロード
   * @throws Exception
   */
  void uploadEventImageAttachment(MultipartFile file, String patEvent) throws Exception;

  /**
   * イメージファイル削除
   * @throws Exception
   */
  void deleteEventImageAttachment(List<Map<String, String>> fileInfo, Long pat_id, String facilityCd) throws Exception;

  /**
   * テキストスタンプ用文字列一覧取得
   * @param facilityCd 施設コード
   * @return
   */
  List<String> fetchStampTextCollection(String facilityCd);
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 start*/
  Integer findPublicFlag(Long userId);
  /*add FNSI-改修内容患者イベント患者情報共有より改修 任 end*/
  /*add FNSI-改修内容538 連携イベントの登録適正化 任 start*/
  String getPatEventTreatDate(Long ordNo);
  /*add FNSI-改修内容538 連携イベントの登録適正化 任 end*/

  // add FNSI-連携イベント作成・中止ツールを追加 ウ start
  /**
   * 連携イベント作成・中止ツールデータ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  List<PatEventCoopInfo> searchPatInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to,String strkbn);
  // add FNSI-連携イベント作成・中止ツールを追加 ウ end
  /*add FNSI-改修内容患者イベント外结No.7 任 start*/
  List<SysFacility> getFacilityNameByCd();
  /*add FNSI-改修内容患者イベント外结No.7 任 end*/

 // add 20210819 #61411： FNSI-追加検査オーダ作成 鄭 start
  /**
   * 連携イベント作成・中止ツールデータ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  // mod 9989 種別単位の検索条件が正しくない donghao start
  //List<PatEventCoopInfo> searchPatExamInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to);
  List<PatEventCoopInfo> searchPatExamInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to,boolean phyFlg);
  // add 20210819 #61411：FNSI-追加検査オーダ作成 鄭 end
  // mod 9989 種別単位の検索条件が正しくない donghao end
  // add 20210830 #61411： FNSI-追加放射線検査オーダ 鄭 start
  /**
   * 連携イベント作成・中止ツールデータ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  List<PatEventCoopInfo> searchPatRadInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to);
  // add 20210830 #61411：FNSI-追加放射線検査オーダ 鄭 end


  // add 20210830 #61411： FNSI-追加処方情報連携 鄭 start
  /**
   * 連携イベント作成・中止ツールデータ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  List<PatEventCoopInfo> searchOrdPrescriptionInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to);
  // add 20210830 #61411：FNSI-追加処方情報連携 鄭 end


  // add 20210830 #61411： FNSI-追加中止 鄭 start
  /**
   * 連携イベント作成・中止ツールデータ取得
   * @param facility_cd 施設コード
   * @param dialysis_date_from 表示開始日(YYYYMMDD)
   * @param dialysis_date_to 表示終了日(YYYYMMDD)
   * @return 患者イベント（仮）のResponse
   */
  List<PatEventCoopInfo> searchStopPatInfo(String facility_cd, String dialysis_date_from, String dialysis_date_to,String strSyubetu);
  // add 20210830 #61411：FNSI-追加中止 鄭 end
// add 20210830 #61411： FNSI-追加种别 鄭 start
  List<String> getFacilityCdInfo();
  // add 20210830 #61411：FNSI-追加种别 鄭 end
  /**
   * 観察記録を取得する
   * @param pat_event_cd 患者イベントコード
   * @return 患者イベントのうちサブカテゴリの利用種別が観察記録のもの
   */
  List<PatEvent> selectObserveRecordByCd(Long pat_event_cd);

  /**
   * 紹介状を取得する
   * @param pat_event_cd 患者イベントコード
   * @return 患者イベントのうちサブカテゴリの利用種別が紹介状のもの
   */
  List<PatEvent> selectPatIntroLetterByCd(Long pat_event_cd);
  /**
   * 患者経過総合ビューア取得用、患者イベント（仮）データ取得
   * @param pat_id 患者ID
   * @param dateFrom 表示開始日(YYYYMMDD)
   * @param dateTo 表示終了日(YYYYMMDD)
   * @return 紹介状
   */
   /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
    // List<PatEvent> selectByLetterDate(long pat_id, String dateFrom, String dateTo, String facilityCd);
    List<PatEvent> selectByLetterDate(long pat_id, String dateFrom, String dateTo, String facilityCd, Integer patShareMode);
    /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  start
  /**
   * イベント削除
   */
  void deleteEventAndBbs(String facilityCd, Long patId, String eventStartDate);
  List<PatEvent> selectByPatIdAndEventStartDate(String facilityCd, Long patId, String eventStartDate);
  int updateNoticeDate(Long patEventCd, int dataNumber);
  void updateEventAndBbsDate(Long patEventCd, int dataNumber);
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  end

  /**
   * 観察記録リストの件数取得
   * @param pat_id
   * @param startDate
   * @param endDate
   * @param categoryDataList
   * @param regStaffCd
   * @param upStaffCd
   * @param patShareMode 自施設：1　他施設：0
   * @param otherFacilityCd 他施設コード
   * @return 観察記録リストの件数
   */
  // mod #12462 患者情報共有 zhao start
  //int countObsRecByCondition(Long pat_id, String startDate, String endDate, List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd);
  int countObsRecByCondition(Long pat_id, String startDate, String endDate, List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd,
                             String patShareMode, String otherFacilityCd);
  // mod #12462 患者情報共有 zhao end
  /**
   * 観察記録リスト取得 offset指定あり
   * @param pat_id
   * @param startDate
   * @param endDate
   * @param categoryDataList
   * @param regStaffCd
   * @param upStaffCd
   * @param offset ※追加読込で使用
   * @param patShareMode 自施設：1　他施設：0
   * @param otherFacilityCd 他施設コード
   * @return 観察記録リスト MAX100件取得
   */
  // mod #12462 患者情報共有 zhao start
  //List<PatEventShare> getObsRecByCondition(Long pat_id, String startDate, String endDate, List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd, Integer offset);
  List<PatEventShare> getObsRecByCondition(Long pat_id, String startDate, String endDate, List<Pair<Long, Long>> categoryDataList, String regStaffCd, String upStaffCd, Integer offset,
                                           String patShareMode, String otherFacilityCd);
  // mod #12462 患者情報共有 zhao end
  // add 10409 曜日パターン変更の患者イベント修正 関  start
  boolean searchLinkage(String facility_cd, String dialysis_date_from, String dialysis_date_to,Long pat_id);
  // add 10409 曜日パターン変更の患者イベント修正 関  end

  // add #11717【因島】曜日パターン変更の動作が遅い fang start
  List<PatEvent> selectByOrdNos(String facilityCd, Long patId, List<Long> ordNos);
  // add #11717【因島】曜日パターン変更の動作が遅い fang end
  // add #12462 患者情報共有 zhao start
  List<ShrPatInfo> getShrPatInfoForPatId(Long patId, String facilityCd);
  OrdMain selectByOrdNo(Long ordNo);
  /**
   * 患者イベント情報を取得する
   * @param pat_id
   * @param event_start_date_from
   * @param event_start_date_to
   * @param facilityCd
   * @param patShareMode 自施設：1　他施設：0
   * @param otherFacilityCd 他施設コード
   * @param patEventCdList
   * @return 患者イベント情報
   */
  List<PatEventShare> selectByPatIdNewestShareForShare(Long pat_id, Timestamp event_start_date_from, Timestamp event_start_date_to, String facilityCd,
                                               String patShareMode,
                                               String otherFacilityCd,
                                               Long... patEventCdList);
  // add #12462 患者情報共有 zhao end
}
