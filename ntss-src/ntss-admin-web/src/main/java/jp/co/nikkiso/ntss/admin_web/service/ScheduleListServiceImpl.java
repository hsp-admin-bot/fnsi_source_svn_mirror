package jp.co.nikkiso.ntss.admin_web.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataRequest;
import jp.co.nikkiso.ntss.admin_web.request.scheduleList.UpdateScheduleListDataRequestList;
import jp.co.nikkiso.ntss.admin_web.response.OtherScheduleListResponse;
import jp.co.nikkiso.ntss.admin_web.response.exam.ExamRequestResponse;
import jp.co.nikkiso.ntss.admin_web.response.rad.RadRequestResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.exam.ExamRequestService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.rad.RadRequestService;
import jp.co.nikkiso.ntss.admin_web.service.utils.MasterCacheHandler;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.DevMenteMainDao;
import jp.co.nikkiso.ntss.core.dao.MntWaterSurveyDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainHstDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainHstDao;
import jp.co.nikkiso.ntss.core.dao.ScheduleListDao;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMainHst;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMainHst;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadMainData;
import jp.co.nikkiso.ntss.core.entity.custom.SchedulePlanData;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import org.apache.commons.collections.CollectionUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestBody;

import javax.annotation.Resource;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


/**
 * スケジュール表のService実装クラス.
 */
@Service
public class ScheduleListServiceImpl implements ScheduleListService {

  /**
   * スケジュール表Dao.
   */
  @Autowired
  private ScheduleListDao scheduleListDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private PatIndApproveDao patIndApproveDao;
  @Autowired
  private PatExamMainDao patExamMainDao;
  @Autowired
  private PatRadMainDao patRadMainDao;
  @Autowired
  private PatEventDao patEventDao;
  @Autowired
  private DevMenteMainDao devMenteMainDao;
  @Autowired
  private MntWaterSurveyDao mntWaterSurveyDao;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  // FNSI-add 対応401 孫灝 20201203 start
  @Resource
  private OrdChecklistDao ordChecklistDao;
  // FNSI-add 対応401 孫灝 20201203 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private OrdMainService ordMainService;

  /* add by yuqinlong  2023-02-02 [CodeOptimization] start  */
  @Autowired
  FacilitySettingService facilitySettingService;
  /* add by yuqinlong  2023-02-02 [CodeOptimization] end  */

  /* add by yuqinlong  2023-02-02 [CodeOptimization] start  */
  @Autowired
  LogService logService;
  /* add by yuqinlong  2023-02-02 [CodeOptimization] end  */

  /* add by yuqinlong  2023-02-02 [CodeOptimization] start  */
  @Autowired
  OrdMainService OrdMainService;

  @Autowired
  IndHistoryMakeService indHistoryMakeService;

  @Autowired
  RadRequestService radRequestService;

  @Autowired
  private JournalService journalService;

  @Autowired
  ExamRequestService examRequestService;
  /* add by yuqinlong  2023-02-02 [CodeOptimization] end  */
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  @Autowired
  PatRadMainHstDao patRadMainHstDao;

  @Autowired
  PatExamMainHstDao patExamMainHstDao;
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
  @Autowired
  OrdMainResource ordMainResource;
  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end


  /**
   * ベッド一覧取得用
   * @param facilityCd 施設コード
   * @param treatDateList   治療日
   * @return ベッド一覧情報
   * @throws Exception
   */
  public List<Map<String,Object>> getBedListMain(
          String facilityCd,
          List<String> treatDateList
      ){
    // #10061 Mod by zhou.tao start
//    return scheduleListDao.selectBedListMain(facilityCd, treatDateList);
    if (CollectionUtils.isNotEmpty(treatDateList)) {
      return scheduleListDao.selectBedListMain(facilityCd
        , treatDateList.get(0)
        , treatDateList.get(treatDateList.size() - 1));
    } else {
      return new ArrayList<>();
    }

    // #10061 add by zhou.tao end
  }
  /**
   * ベッド未登録一覧取得用
   * @param facilityCd 施設コード
   * @param treatDateList   治療日
   * @return ベッド未登録一覧情報
   * @throws Exception
   */
  public List<Map<String,Object>> getBedListNotYet(
          String facilityCd,
          List<String> treatDateList
      ){
    // #10061 Mod by zhou.tao start
//    return scheduleListDao.selectBedListNotYet(facilityCd, treatDateList);
    if (CollectionUtils.isNotEmpty(treatDateList)) {
      return scheduleListDao.selectBedListNotYet(facilityCd
        , treatDateList.get(0)
        , treatDateList.get(treatDateList.size() - 1));
    } else {
      return new ArrayList<>();
    }
    // #10061 add by zhou.tao end
  }
  /**
   * クール未登録一覧取得用
   * @param facilityCd 施設コード
   * @param treatDateList   治療日
   * @return クール未登録一覧情報
   * @throws Exception
   */
  public List<Map<String,Object>> getBedListKurNotYet(
          String facilityCd,
          List<String> treatDateList
      ){
    // #10061 mod by zhou.tao start
    if (CollectionUtils.isNotEmpty(treatDateList)) {
      return scheduleListDao.selectBedListKurNotYet(facilityCd
        , treatDateList.get(0)
        , treatDateList.get(treatDateList.size() - 1));
    } else {
      return new ArrayList<>();
    }
    // #10061 add by zhou.tao end
  }
  /**
   * 患者情報取得用(チェック用情報)
   * @param ordNo オーダー番号
   * @return 患者情報(不一致、治療時間、同姓同名、予定有無チェック用) ※TODO:予定有無の追加
   * @throws Exception
   */
  public List<Map<String,Object>> selectPatInfoForCheck(
          Long ordNo
      ){
    return scheduleListDao.selectPatInfoForCheck(ordNo);
  }

  //  add by ShiHongda 2023-02-08 [optimize] --start /
  /**
   * 患者情報取得用(チェック用情報)
   * @param ordNoList オーダー番号List
   * @return 患者情報(不一致、治療時間、同姓同名、予定有無チェック用) ※TODO:予定有無の追加
   * @throws Exception
   */
  public List<Map<String,Object>> selectPatInfoForListCheck(
    List<Long> ordNoList
  ){
    return scheduleListDao.selectPatInfoForListCheck(ordNoList);
  }
  //  add by ShiHongda 2023-02-08 [optimize] --end /

  /**
   * 患者情報一覧取得用
   * @param List<String> facilityCdList 施設コードリスト
   * @param List<Long> patIdList   患者IDリスト
   * @return クール未登録一覧情報
   * @throws Exception
   */
  public List<PatPersonalMain>  getPatInfoList(
          List<String> facilityCdList,
          List<Long> patIdList
      ){
    return patPersonalMainDao.selectByIdListFacilityCd(patIdList, facilityCdList.get(0));
  }

  /**
   * add 10061 by kangjie
   * @param facilityCdList
   * @param patIdList
   * @return
   */
  @Override
  public List<PatPersonalMain> getPatPersonalMainDtoList(List<String> facilityCdList, List<Long> patIdList) {
    return patPersonalMainDao.getPatPersonalMainDtoList(patIdList,facilityCdList.get(0));
  }

  /**
   * クール名一覧取得用
   * @param String facilityCd 施設コード
   * @return クール名一覧
   * @throws Exception
   */
  public List<MstKur>  getKurNameList(
          String facilityCd
      ){
    return scheduleListDao.selectKurNameList(facilityCd);
  }
  /**
   * ベッド数最大値取得用
   * @param String facilityCd 施設コード
   * @return ベッド数
   * @throws Exception
   */
  public List<Map<String,Object>>  getBedMaxCount(
          String facilityCd
      ) {
    return scheduleListDao.selectBedMaxCount(facilityCd);
  }
  /**
   * ベッドグループ情報取得用
   * @param String facilityCd 施設コード
   * @return ベッドグループ情報一覧
   * @throws Exception
   */
  public List<MstRoomBedGroup>  getRoomBedGroupList(
          String facilityCd
      )
  {
    return scheduleListDao.selectRoomBedList(facilityCd);
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public OtherScheduleListResponse getOtherScheduleListByPeriod(
          String startDate,
          String endDate,
          String facilityCd
      )
  {
    // 各テーブルからデータを取得
    List<PatExamMainData> examList = patExamMainDao.selectScheduleListByPeriod(facilityCd, startDate, endDate);
    List<PatRadMainData> radList = patRadMainDao.selectScheduleListByPeriod(facilityCd, startDate, endDate);
    List<PatEvent> eventList = patEventDao.selectScheduleListByPeriod(facilityCd, startDate, endDate);
    List<SchedulePlanData> mainteList = devMenteMainDao.selectScheduleListByPeriod(facilityCd, startDate, endDate);
    List<SchedulePlanData> waterSurveyList = mntWaterSurveyDao.selectScheduleListByPeriod(facilityCd, startDate, endDate);

    // 開始日(startDate)、終了日(endDate)
    LocalDate lStartDate = LocalDate.parse(startDate, DateTimeFormatter.ofPattern("yyyy/MM/dd"));
    LocalDate lEndDate = LocalDate.parse(endDate, DateTimeFormatter.ofPattern("yyyy/MM/dd"));
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyyMMdd");

    // レスポンス用<日付：患者IDのリスト>(重複する可能性がある為、HashSetを使って、重複しないようにする)
    HashMap<String, Set<Long>> resExamList = new HashMap<String, Set<Long>>();
    HashMap<String, Set<Long>> resRadList = new HashMap<String, Set<Long>>();
    HashMap<String, Set<Long>> resEventList = new HashMap<String, Set<Long>>();
    // レスポンス用<日付：ベッドコードのリスト>(重複する可能性がある為、HashSetを使って、重複しないようにする)
    HashMap<String, Set<Long>> resMainteList = new HashMap<String, Set<Long>>();
    HashMap<String, Set<Long>> resWaterSurveyList = new HashMap<String, Set<Long>>();

    // 初期化(検索日付の範囲でで空のリストを作成しておく)
    while (lStartDate.isBefore(lEndDate) || lStartDate.isEqual(lEndDate)) {
      String strDay = dtf.format(lStartDate);
      Set<Long> examSet = new HashSet<Long>();
      Set<Long> radSet = new HashSet<Long>();
      Set<Long> eventSet = new HashSet<Long>();
      Set<Long> mainteSet = new HashSet<Long>();
      Set<Long> waterSurveySet = new HashSet<Long>();
      resExamList.put(strDay, examSet);
      resRadList.put(strDay, radSet);
      resEventList.put(strDay, eventSet);
      resMainteList.put(strDay, mainteSet);
      resWaterSurveyList.put(strDay, waterSurveySet);
      lStartDate = lStartDate.plusDays(1);
    }

    // 検査依頼
    for (PatExamMainData examObj : examList) {
      if (resExamList.containsKey(examObj.getStrExamDate())) {
        resExamList.get(examObj.getStrExamDate()).add(examObj.getPatId());
      }
    }
    // 放射線検査依頼
    for (PatRadMainData radObj : radList) {
      if (resRadList.containsKey(radObj.getStrRadDate())) {
        resRadList.get(radObj.getStrRadDate()).add(radObj.getPatId());
      }
    }
    // 患者イベント
    for (PatEvent eventObj : eventList) {
      // 患者イベントの日付範囲でリストを作成する
      LocalDate eventStart = LocalDate.parse(eventObj.getEventStartDate().replace("-", "/"), DateTimeFormatter.ofPattern("yyyy/MM/dd"));
      LocalDate eventEnd = LocalDate.parse(eventObj.getEventEndDate().replace("-", "/"), DateTimeFormatter.ofPattern("yyyy/MM/dd"));
      while (eventStart.isBefore(eventEnd) || eventStart.isEqual(eventEnd)) {
        if (resEventList.containsKey(dtf.format(eventStart))) {
          resEventList.get(dtf.format(eventStart)).add(eventObj.getPatId());
        }
        eventStart = eventStart.plusDays(1);
      }
    }
    // 定期点検
    for (SchedulePlanData mainteObj : mainteList) {
      if (resMainteList.containsKey(mainteObj.getStrDate())) {
        resMainteList.get(mainteObj.getStrDate()).add(mainteObj.getBedCd());
      }
    }
    // 水質管理
    for (SchedulePlanData waterSurveyObj : waterSurveyList) {
      if (resWaterSurveyList.containsKey(waterSurveyObj.getStrDate())) {
        resWaterSurveyList.get(waterSurveyObj.getStrDate()).add(waterSurveyObj.getBedCd());
      }
    }
    // 取得データを応答
    return new OtherScheduleListResponse(resExamList, resRadList, resEventList, resMainteList, resWaterSurveyList);
  }
  /**
   * 同一患者同一治療日同一クール同一治療方法のチェック
   * @param List<Long> ordNoList オーダー番号リスト
   * @return Boolean true:存在した false:存在しなかった
   * @throws Exception
   */
  public Boolean checkSamePatDayKurMode(
          Long ordNo,
          String treatDate,
          Long kurCd
      )
  {
    return scheduleListDao.checkSamePatDayKurMode(ordNo,treatDate,kurCd);
  }
  /**
   * ベッド患者情報の存在チェック
   * @param Long ordNoList オーダー番号
   * @param String treatDate 治療日
   * @param Long kurCd クールコード
   * @param Long bedCd ベッドコード
   * @return Boolean true:存在した false:存在しなかった
   * @throws Exception
   */
  // mod #11493 スケジュール表　更新不正 関 start
  public Boolean  checkPatExistance(
          Long ordNo,
          String treatDate,
          Long kurCd,
          Long bedCd,
          String dialysisState,
          String isDummy
      )
  {
    return scheduleListDao.checkPatExistance(ordNo, treatDate, kurCd, bedCd, dialysisState, isDummy);
  }
  // mod #11493 スケジュール表　更新不正 関 end
  /**
   * スケジュール表の更新処理(単体)
   * @param Long ordNo              条件:オーダー番号
   * @param String condTreatDate    条件:治療日
   * @param String facilityCd       条件:施設コード
   * @param String newTreatDate     更新対象:治療日
   * @param Long kurCd              更新対象:クールコード
   * @param Long bedCd              更新対象:ベッドコード
   * @return 更新数
   * @throws Exception
   */
  public int  updateScheduleListData(
      Long ordNo,               //条件:オーダー番号
      String condTreatDate,     //条件:治療日
      String facilityCd,        //条件:施設コード
      String newTreatDate,      //更新対象:治療日
      Long kurCd,               //更新対象:クールコード
      Long bedCd                //更新対象:ベッドコード
      ) {
    return   scheduleListDao.updateScheduleListData(
        ordNo,
        condTreatDate,
        facilityCd,
        newTreatDate,
        kurCd,
        bedCd
      );
  }
  /**
   * ord_mainの更新処理(単体)
   * @param Long ordNo              条件:オーダー番号
   * @param String condTreatDate    条件:治療日
   * @param String facilityCd       条件:施設コード
   * @param String newTreatDate     更新対象:治療日
   * @param Long kurCd              更新対象:クールコード
   * @param Long bedCd              更新対象:ベッドコード
   * @return 更新数
   * @throws Exception
   */
  public int  updateOrdMainData(
      Long ordNo,               //条件:オーダー番号
      String condTreatDate,     //条件:治療日
      String facilityCd,        //条件:施設コード
      String newTreatDate,      //更新対象:治療日
      Long kurCd,               //更新対象:クールコード
      Long bedCd,                //更新対象:ベッドコード
      Long indUserId,           //更新対象:指示者ID
      Long updUserId            //更新対象:更新者ID
      ) {

    // add FNSI-改修内容追加OrdMain履歴 付 start
    selectHistoryUtils.insertMangoDbHistory(9, ordNo, null, new ArrayList<>(), new ArrayList<>(), facilityCd, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), condTreatDate, null, null,
      new ArrayList<>(), null, null);
    // mangoDb-updateOrdMainData-insertSuccess
    // add FNSI-改修内容追加OrdMain履歴 付 end
    //mod 10860 ind_schedule_user_infoのデータ不正 zhao start
//    return   scheduleListDao.updateOrdMainData(
//        ordNo,
//        condTreatDate,
//        facilityCd,
//        newTreatDate,
//        kurCd,
//        bedCd,
//        indUserId,
//        updUserId
//      );
    MstPersonalUser indUser = MasterCacheHandler.get().getMstPersonalUser(indUserId);
    MstPersonalUser updUser = MasterCacheHandler.get().getMstPersonalUser(updUserId);
    return   scheduleListDao.updateOrdMainData(
      ordNo,
      condTreatDate,
      facilityCd,
      newTreatDate,
      kurCd,
      bedCd,
      indUserId,
      updUserId,
      updUser.getUserFirstName(),
      updUser.getUserLastName(),
      indUser.getUserFirstName(),
      indUser.getUserLastName()
    );
    //mod 10860 ind_schedule_user_infoのデータ不正 zhao end
  }

  /**
   * {@inheritDoc}
   * @throws Exception
   */
  @Override
  public int changedIndData(Long ordNo, String condTreatDate, String newTreatDate) throws Exception {

    if (Objects.equals(condTreatDate, newTreatDate)) {
      // 同一日内でのスケジュール移動(クール・ベッド移動)
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_ind_approve";
      // SQL検索条件
      String inStr = getInStr("ord.ord_no IN ", ordNoList);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append("ord_no IN (" + "\n");
      wheres.append("SELECT ord.ord_no" + "\n");
      wheres.append("FROM ord_main as ord" + "\n");
      wheres.append("JOIN mst_facility_setting as setting" + "\n");
      wheres.append("ON ord.facility_cd = setting.facility_cd" + "\n");
      wheres.append("WHERE" + "\n");
      wheres.append(inStr + "\n");
      wheres.append("AND setting.facility_setting_no = '1022'" + "\n");
      wheres.append("AND value = '1')" + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patIndApproveDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int patUpdateCount = ordMainService.updateContentChangeListByBedControlWithNotification(ordNoList, new PatIndApprove());

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && patUpdateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      return patUpdateCount;
    } else {
      // 日付を跨いだスケジュール移動(指示変更フラグを立てる)
      PatIndApprove patIndApprove = new PatIndApprove();
      patIndApprove.setOrd_no(ordNo);

      return ordMainService.updateContentChangeSingleWithNotification(ordNo, patIndApprove);
    }
  }

  /**
   * FNSI-add 対応401 孫灝 20201203
   * @param ordNo
   * @return
   */
  /* add by yuqinlong  2023-02-02 [Transaction]  */
  @Transactional
  @Override
  public int deleteOrdCheckListByOrdNo(long ordNo, String facilityCd) {
    //del 9324 ord_checklist共通之外的dao方法删除 gjn start
//    return ordChecklistDao.deleteByOrdNo(ordNo, facilityCd);
    //del 9324 ord_checklist共通之外的dao方法删除 gjn end
    return 0;
  }

  /**
   * FNSI-add 1006 No.426 --Sanjingye Sun 20201217
   * selecting db find event start Date and event end Date
   * @param facilityCd
   * @param patId
   * @param eventStartDate
   * @return
   */
  @Override
  public List<PatEvent> selectPatEventPeriod(String facilityCd, String patId, String eventStartDate) {
    return patEventDao.selectEventPeriod(facilityCd, patId, eventStartDate);
  }
  // add 9273 start
  /**
   * @param facilityCd
   * @param patId
   * @param eventStartDate
   * @param ordNo
   * @return
   */
  @Override
  public List<PatEvent> selectPatEventByOrdNoWithOutStartDate(String facilityCd, String patId, String eventStartDate, Long ordNo) {
    return patEventDao.selectPatEventByOrdNoWithOutStartDate(facilityCd, patId, eventStartDate, ordNo);
  }
  /**
   * @param facilityCd
   * @param patId
   * @param eventStartDate
   * @param eventEndDate
   * @return
   */
  @Override
  public List<PatEvent> selectPatEventByOrdNoAndDate(String facilityCd, String patId, String eventStartDate, String eventEndDate, List<Long> ordNoList) {
    return patEventDao.selectPatEventByOrdNoAndDate(facilityCd, patId, eventStartDate, eventEndDate, ordNoList);
  }
  // add 9273 end

  /**
   * FNSI-add 1006 No.426 -- Sanjingye Sun 20201217
   * update event_start_date and event_end_date of pat_event
   * @param patEvent
   * @return
   */
  @Override
  public int updatePatEventPeriod(PatEvent patEvent) {
    return patEventDao.updateSelected(patEvent);
  }

  /**
   * add FNSI 1006 No.426 -- Sanjingye Sun 20201224
   * delete pat event according to facilityCd,patId and beforeDate by update 'isDel' field to 1
   * @param patEvent
   * @return
   */
  @Override
  public int updatePatEventIsDel(PatEvent patEvent) {
    return patEventDao.updateSelected(patEvent);
  }


  // DB更新ログ出力ロジック wangzuo Start

  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   *
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  public <T> String getInStr(String fieldInfo, List<T> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (T obj : inList) {
      inStr.append(obj);
      inStr.append(" ,");
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }
  // DB更新ログ出力ロジック wangzuo End

  @Override
  public Map<String, Object> getBedAndKurInfoFromDB(String facilityCd) {
    Map<String, Object> retMap = new HashMap<String, Object>();

    //ベッド情報の取得
    List<Map<String, Object>> retBedList = getBedMaxCount(facilityCd);

    //クール情報の取得
    List<MstKur> retKurList = getKurNameList(facilityCd);

    //ベッドグループ情報の取得
    List<MstRoomBedGroup> retRoomBedGroupList = getRoomBedGroupList(facilityCd);

    // FNSI-add 現行改善対応425 孫灝 20201117 start
    // 施設設定マスタから 透析予定日変更時検査予定変更機能 の設定値を取得 1007
    String resExamChangeSetting = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE);

    // 検査依頼変更締切り有無 1015
    String examChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_CHANGE_ON_OFF_WITH_ORDER);

    // 検査依頼変更締切り日数 1011
    String examScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_DAY);

    // 検査依頼変更締切り時間 1012
    String examScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_TIME);

    // 1007
    retMap.put("setting1007", resExamChangeSetting);
    // 1015
    retMap.put("examChangeOnOffWithOrder", examChangeOnOffWithOrder);
    // 1011
    retMap.put("examScheduleChangeLimitDay", examScheduleChangeLimitDay);
    // 1012
    retMap.put("examScheduleChangeLimitTime", examScheduleChangeLimitTime);

    // 1008
    String radChangeSetting = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE);
    // 一般撮影検査依頼変更締切り有無 1016
    String radChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.RAD_CHANGE_ON_OFF_WITH_ORDER);
    // 放射線検査依頼変更締切り日数 1013
    String radScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_DAY);
    // 放射線検査依頼変更締切り時間 1014
    String radScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_TIME);

    retMap.put("setting1008", radChangeSetting);
    // 1016
    retMap.put("radChangeOnOffWithOrder", radChangeOnOffWithOrder);
    // 1013
    retMap.put("radScheduleChangeLimitDay", radScheduleChangeLimitDay);
    // 1014
    retMap.put("radScheduleChangeLimitTime", radScheduleChangeLimitTime);
    // FNSI-add 現行改善対応425 孫灝 20201117 end

    // add FNSI 1006 No.426 施設設定に患者イベントの治療スケジュール連動設定code取得 start --- 孙灏 20201215
    String patEventChangeSetting = facilitySettingService.getFacilitySettingValue(
      facilityCd,
      CoreConstant.FacilitySettingNo.PAT_EVENT_CHANGE
    );
    retMap.put("setting3005", patEventChangeSetting);
    // add FNSI 1006 No.426 施設設定に患者イベントの治療スケジュール連動設定code取得 end --- 孙灏 20201215

    //戻り値の組み立て
    retMap.put("bed", retBedList);
    retMap.put("kur", retKurList);
    retMap.put("roombedgroup", retRoomBedGroupList);

    return retMap;
  }

  /* add by yuqinlong  2023-02-02 [CodeOptimization] start  */
  @Override
  public ResponseEntity<List<String>> getScheduleListDataFromDB_DAO(String treatDate, String facilityCd) {
    //処理時間計測開始
    long start = System.currentTimeMillis();

    HttpStatus status = HttpStatus.OK;

    //パラメータ
    dbgPrint("treatDate:" + treatDate);
    treatDate = treatDate.replaceAll("/", "");
    dbgPrint("replaced treatDate:" + treatDate);
    dbgPrint("facilityCd:" + facilityCd);

    List<String> treatDateList = new ArrayList<>();
    treatDateList.add(treatDate);
    //メイン部分のベッド一覧取得
    List<Map<String, Object>> retList = getBedListMain(
      facilityCd,
      treatDateList
    );

    //取得内容確認 ここから   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    dbgPrint(treatDate + ":retList.size():" + retList.size());
//
//      for(int i= 0 ; i < 2 ; i++)
//        for(int i= 0 ; i < retList.size() ; i++)
//      {
//        Map<String,Object> map = (Map<String,Object>)retList.get(i) ;
//
//
//        for (String key : map.keySet()) {
//          dbgPrint(key + " => " + map.get(key));
//        }
//      }
    //取得内容確認 ここまで  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

    //未登録ベッド一覧取得
    List<Map<String, Object>> retListNotYet = getBedListNotYet(
      facilityCd,
      treatDateList
    );

    //取得内容確認 ここから   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    dbgPrint(treatDate + ":retListNotYet.size():" + retListNotYet.size());
//
//        for(int i= 0 ; i < retListNotYet.size() ; i++)
//        {
//          Map<String,Object> map = (Map<String,Object>)retListNotYet.get(i) ;
//
//          for (String key : map.keySet()) {
//            dbgPrint(key + " => " + map.get(key));
//          }
//        }
    //取得内容確認 ここまで  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
    //クール未登録一覧取得
    List<Map<String, Object>> retListKurNotYet = getBedListKurNotYet(
      facilityCd,
      treatDateList
    );

    //取得内容確認 ここから   ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
    dbgPrint(treatDate + ":retListKurNotYet.size():" + retListKurNotYet.size());

    for (int i = 0; i < retListKurNotYet.size(); i++) {
      Map<String, Object> map = (Map<String, Object>) retListKurNotYet.get(i);

      for (String key : map.keySet()) {
        dbgPrint(key + " => " + map.get(key));
      }
    }
    //取得内容確認 ここまで  ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

    //----------------------------------------------------------
    //患者情報の取得
    //患者IDの収集
    // 患者ID一覧格納用
    List<Long> patIdList = new ArrayList<Long>();
    // 施設コード一覧(一つだけ)格納用
    List<String> facilityCdList = new ArrayList<String>();
    facilityCdList.add(facilityCd);

    //ベッド一覧のリスト
    Object[] obj = {
      retList,             //ベッド一覧
      retListNotYet,       //未登録ベッド一覧
      retListKurNotYet     //クール未登録一覧
    };

    //患者ID収集
    List<Map<String, Object>> tmpList = null;
    for (int j = 0; j < obj.length; j++) {
      tmpList = (List<Map<String, Object>>) obj[j];
      for (int i = 0; i < tmpList.size(); i++) {
        if (null != tmpList.get(i).get("pat_id")) {
          long patId = (long) tmpList.get(i).get("pat_id");
          if (!patIdList.contains(patId)) {
            patIdList.add(patId);
          }
        }
      }
    }
    dbgPrint("patIdList.size():" + patIdList.size());


    List<PatPersonalMain> patInfoList = null;
    //パラメータのリストが0件より大きい場合のみ、DB検索する
    if (0 != patIdList.size()) {
      //患者情報の取得
      patInfoList = getPatInfoList(
        facilityCdList,
        patIdList
      );
    }

    //------------------------------------------------------------------------
    //データの加工

    //DBから取得した値をJson化
    // メイン部
    JSONArray jArry = new JSONArray(retList);
    // ベッド未登録
    JSONArray jArryNotYet = new JSONArray(retListNotYet);
    // クール未登録
    JSONArray jArryKurNotYet = new JSONArray(retListKurNotYet);

    //クールでデータを分ける

    Map<String, Object> jObj = null;

    long preKur = -1;
    String preKurName = "";

    int arrayIndex = 1;

    JSONArray tmpArray = null;

    JSONArray retArray = new JSONArray();
    JSONArray retArrayNotYet = new JSONArray();
    int retIndex = 0;
    String[] kurNames = new String[10];
    String[] kurNamesNotYet = new String[10];

    //クールごとの振り分け(ベッドメイン部分)
    try {
      for (int i = 0; i < retList.size(); i++) {
        //-------------------------------------------
        //名前・入外区分の追加 ここから
        JSONObject tmpJObj = (JSONObject) jArry.get(i);
        addNameAndInout(tmpJObj, patInfoList);
        //名前・入外区分の追加 ここまで
        //------------------------------------------

        jObj = retList.get(i);

        if (!jObj.get("kur_cd").equals(preKur)) {
          dbgPrint("クールが" + preKur + "から" + jObj.get("kur_cd") + "に切り替わった");
          dbgPrint("クールが" + preKurName + "から" + jObj.get("kur_name") + "に切り替わった");

          if (tmpArray != null) {
            //格納
            kurNames[retIndex] = preKurName;
            retArray.put(retIndex, tmpArray);
            ++retIndex;      //インデックスの増加タイミングがわかりやすいように分けて記述
          }

          preKur = (long) jObj.get("kur_cd");
          preKurName = (String) jObj.get("kur_name");

          tmpArray = new JSONArray();
          arrayIndex = 1;      //番号0要素はvue側では使わないので番号1から格納
        }

        tmpArray.put(arrayIndex++, jArry.get(i));

//      dbgPrint("Map Ver "+jObj.get("no") + " name:" + jObj.get("patlastname") + " " + jObj.get("patfirstname"));
      }
      kurNames[retIndex] = preKurName;
      retArray.put(retIndex++, tmpArray);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    dbgPrint("retArray.length():" + retArray.length());

    JSONArray retBuildArray = new JSONArray();
    JSONObject buildJson = null;

    //クールごとの振り分け(ベッド未登録部分)
    try {
      arrayIndex = 1;
      jObj = null;
      preKurName = "";
      tmpArray = null;
      preKur = -1;
      retIndex = 0;

      dbgPrint("retListNotYet.size():" + retListNotYet.size());
      for (int i = 0; i < retListNotYet.size(); i++) {
        //-------------------------------------------
        //名前・入外区分の追加 ここから
        JSONObject tmpJObj = (JSONObject) jArryNotYet.get(i);
        addNameAndInout(tmpJObj, patInfoList);
        //名前・入外区分の追加 ここまで
        //------------------------------------------

        jObj = retListNotYet.get(i);

        if (Integer.parseInt(jObj.get("kur_cd").toString()) != preKur) {
          dbgPrint("クールが" + preKur + "から" + jObj.get("kur_cd") + "に切り替わった");
          dbgPrint("クールが" + preKurName + "から" + jObj.get("kur_name") + "に切り替わった");

          if (tmpArray != null) {
            //格納
            dbgPrint("retIndex:" + retIndex);
            kurNamesNotYet[retIndex] = preKurName;
            retArrayNotYet.put(retIndex, tmpArray);
            ++retIndex;      //インデックスの増加タイミングがわかりやすいように分けて記述
          }
          dbgPrint("jObj.get(\"kur_cd\"):" + jObj.get("kur_cd"));
          preKur = Integer.parseInt(jObj.get("kur_cd").toString());
          preKurName = (String) jObj.get("kur_name");

          tmpArray = new JSONArray();
          arrayIndex = 1;      //番号0要素はvue側では使わないので番号1から格納
        }

        tmpArray.put(arrayIndex++, jArryNotYet.get(i));

//      dbgPrint("Map Ver "+jObj.get("no") + " name:" + jObj.get("patlastname") + " " + jObj.get("patfirstname"));
      }
      kurNamesNotYet[retIndex] = preKurName;
      retArrayNotYet.put(retIndex++, tmpArray);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    //クール未登録部分 ※1日内でクールをまたいで乙型に配置

    try {
      JSONArray bedNotYetJson = null;
//      JSONArray kurNotYetJson = null ;

      for (int i = 0; i < retArray.length(); i++) {
        buildJson = new JSONObject();
        buildJson.put("kur", kurNames[i]);
        buildJson.put("beddata", retArray.get(i));

        //クールが一致するものを探してputする
        bedNotYetJson = new JSONArray();
        for (int j = 0; j < retArrayNotYet.length(); j++) {
          if (kurNamesNotYet[j].equals(kurNames[i])) {
            bedNotYetJson = retArrayNotYet.getJSONArray(j);

            //とりあえずクール未登録に値をセット(実験的コード)
//            kurNotYetJson = retArrayNotYet.getJSONArray(j) ;
            break;
          }
        }
        buildJson.put("bedNotYet", bedNotYetJson);
        retBuildArray.put(i, buildJson);
      }
      //クール未登録の設定(とりあえず入れてみる)

//      kurNotYetJson = new JSONArray() ;
      buildJson = new JSONObject();
      buildJson.put("kur", "kurNotYet");
      //0要素はnullなので、要素をひとつずつずらす
      for (int index = jArryKurNotYet.length(); index > 0; index--) {
        //-------------------------------------------
        //名前・入外区分の追加 ここから
        JSONObject tmpJObj = (JSONObject) jArryKurNotYet.get(index - 1);
        addNameAndInout(tmpJObj, patInfoList);
        //名前・入外区分の追加 ここまで
        //------------------------------------------
        jArryKurNotYet.put(index, tmpJObj);
      }
      //0要素にnullをセット
      jArryKurNotYet.put(0, "");
      buildJson.put("beddata", jArryKurNotYet);
      retBuildArray.put(retArray.length(), buildJson);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }

    //返却
    List<String> listRet = new ArrayList<>();

    try {

      listRet.add(retBuildArray.toString());

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
    }


    //処理時間計測終了
    long end = System.currentTimeMillis();
    dbgPrint("getScheduleListDataFromDB_DAO 処理時間:" + (end - start) + "ms");

    return new ResponseEntity<>(listRet, status);
  }

  private boolean addNameAndInout(
    JSONObject targetJson,
    List<PatPersonalMain> patInfoList
  ) {
    boolean ret = true;
    PatPersonalMain tmpPPM = null;
//    JSONObject tmpJObj = (JSONObject)jArry.get(i) ;

    //初期設定
    targetJson.put("patLastName", "");    //名前(姓)
    targetJson.put("patFirstName", "");   //名前(名)
    targetJson.put("inOutClass", "");     //入外区分
    targetJson.put("hospPatId", "");     //院内表示用の患者ID

    if (null != patInfoList) {//patInfoListが有効だった場合、検索
      if (targetJson.has("pat_id") && null != targetJson.get("pat_id")) {
        dbgPrint("■pat_id:" + targetJson.get("pat_id"));
        //該当情報を探す
        for (int j = 0; j < patInfoList.size(); j++) {
          if (patInfoList.get(j).getPat_id().equals(targetJson.get("pat_id"))) {
            //見つかった
            tmpPPM = patInfoList.get(j);
            break;
          }
        }

        //患者IDが一致する情報が見つかった場合、名前(姓)、名前名)、入外区分、院内表示用の患者IDをセットします
        if (null != tmpPPM) {
          targetJson.put("patLastName", tmpPPM.getPat_last_name());
          targetJson.put("patFirstName", tmpPPM.getPat_first_name());
          //入外区分のnull対策
          Integer inOutClass = tmpPPM.getIn_out_class();
          if (null == inOutClass) {
            //入外区分がnullの場合、外来として扱う
            inOutClass = 0;
          }
          targetJson.put("inOutClass", inOutClass);
          targetJson.put("hospPatId", tmpPPM.getHosp_pat_id());
        }
      }
    }

    return ret;
  }

  /**
   * デバッグ出力
   *
   * @param msg
   */
  private void dbgPrint(String msg) {
  }

  /* add by yuqinlong  2023-02-02 [CodeOptimization] start  */
  @Transactional
  @Override
  public ResponseEntity<List<String>> updateScheduleListData(UpdateScheduleListDataRequest request) {
    HttpStatus status = HttpStatus.OK;
    List<String> listRet = new ArrayList<>();

    //パラメータ
    Long ordNo = request.getOrdNo();
    String patId = request.getPatId();
    String condTreatDate = request.getCondTreatDate();
    String facilityCd = request.getFacilityCd();
    String newTreatDate = request.getNewTreatDate();
    Long kurCd = request.getKurCd();
    Long bedCd = request.getBedCd();
    Long indUserId = request.getIndUserId();
    Long updUserId = request.getUpdUserId();
    //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
    String isSamePatId = request.getIsSamePatId();
    //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

    dbgPrint("ordNo:" + ordNo);
    dbgPrint("condTreatDate:" + condTreatDate);
    dbgPrint("facilityCd:" + facilityCd);
    dbgPrint("newTreatDate:" + newTreatDate);
    dbgPrint("kurCd:" + kurCd);
    dbgPrint("bedCd:" + bedCd);

    // 旧ord_mainデータ取得
    OrdMain ordMain = OrdMainService.selectByOrdNo(ordNo);

    //データを更新

    int retCount = 0;

    try {
      retCount = updateScheduleListData(
        ordNo,
        condTreatDate,
        facilityCd,
        newTreatDate,
        kurCd,
        bedCd
      );
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      throw new RuntimeException(e.getMessage());   //rollback
//      return new ResponseEntity<>(listRet, status);
    }

    dbgPrint("retCount:" + retCount);

    if (retCount != 1) {
      String retMsg = "ord_scheduleに更新対象のレコードが見つかりませんでした。ord_no:" + ordNo + " treat_date:" + condTreatDate + " facility_cd:" + facilityCd;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(retMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      throw new RuntimeException(retMsg);   //rollback
//      return new ResponseEntity<>(listRet, status);
    }

    try {
      retCount = updateOrdMainData(
        ordNo,
        condTreatDate,
        facilityCd,
        newTreatDate,
        kurCd,
        bedCd,
        indUserId,
        updUserId
      );
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;

      throw new RuntimeException(e.getMessage());   //rollback
//      return new ResponseEntity<>(listRet, status);
    }

    dbgPrint("retCount:" + retCount);

    if (retCount != 1) {
      String retMsg = "ord_mainに更新対象のレコードが見つかりませんでした。ord_no:" + ordNo + " treat_date:" + condTreatDate + " facility_cd:" + facilityCd;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(retMsg);
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      throw new RuntimeException(retMsg);   //rollback
//      return new ResponseEntity<>(listRet, status);
    }

    // 指示変更ありフラグの更新
    try {
      changedIndData(ordNo, condTreatDate, newTreatDate);
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      throw new RuntimeException(e.getMessage());   //rollback
    }

    // 検査依頼結果の移動及び削除処理
    // FNSI-add 現行改善対応425 徐 start
//    String resExamChangeSetting = facilitySettingService.getFacilitySettingValue(
//      facilityCd,
//      FacilitySettingNo.EXAM_SCHEDULE_CHANGE
//    );
    SimpleDateFormat ymd = new SimpleDateFormat("yyyyMMdd");
    SimpleDateFormat hm = new SimpleDateFormat("HHmm");
    String resExamChangeSetting = "";
    // 施設設定マスタから 透析予定日変更時検査予定変更機能 の設定値を取得
    resExamChangeSetting = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE);
    // 検査依頼変更締切り有無 1015
    String examChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_CHANGE_ON_OFF_WITH_ORDER);
    // 検査依頼変更締切り日数 1011
    String examScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_DAY);
    // 検査依頼変更締切り時間 1012
    String examScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.EXAM_SCHEDULE_CHANGE_LIMIT_TIME);
    // 検査結果
    boolean examStatus = false;
    // 検査依頼日付加算
    String newExamDateAdd = "";
    // 時間
    String newTime = "";
    // 検査依頼強制選択型
    boolean examForcedSelection = false;

    Calendar rightNow = Calendar.getInstance();
    rightNow.add(Calendar.DAY_OF_YEAR, Integer.valueOf(examScheduleChangeLimitDay));
    Date dt = rightNow.getTime();
    newExamDateAdd = ymd.format(dt);
    newTime = hm.format(new Date());
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
    //List<PatExamMain> patListRet = examRequestService.FindPatExamMainByDateCd(Integer.valueOf(patId), condTreatDate, condTreatDate);
    List<PatExamMain> patListRet = examRequestService.FindPatExamMainByIsOrder(Integer.valueOf(patId), condTreatDate, condTreatDate);
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
    if (patListRet.size() <= 0) {
      examStatus = true;
    }
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
    if (patListRet != null && patListRet.size() > 0) {
      for (int i = 0; i < patListRet.size(); i++) {
        PatExamMain items = patListRet.get(i);
        if ("1".equals(items.getExamStatus())) {
          examStatus = true;
          break;
        }
      }
    }
    if (!"4".equals(resExamChangeSetting)) {
      if ("1".equals(examChangeOnOffWithOrder)) {
        if (Integer.valueOf(condTreatDate) < Integer.valueOf(newExamDateAdd)) {
          examForcedSelection = true;
        } else if (Integer.valueOf(condTreatDate) == Integer.valueOf(newExamDateAdd)) {
          if (Integer.valueOf(examScheduleChangeLimitTime.replace(":", "")) <= Integer.valueOf(newTime)) {
            examForcedSelection = true;
          } else {
            if (examStatus) {
              examForcedSelection = true;
            }
          }
        } else {
          if (examStatus) {
            examForcedSelection = true;
          }
        }
      } else {
        if (examStatus) {
          examForcedSelection = true;
        }
      }
    } else {
      examForcedSelection = true;
    }
    if (examForcedSelection) {
      // add #9273 施設設定マスタのNo105の設定どおり動かない。 dou start
      if (examStatus) {
        // 検体検査への処理は行わない
        resExamChangeSetting = "3";
      } else {
        resExamChangeSetting = String.valueOf(request.getFacilitySetting1007SelectedVal());
      }
      // add #9273 施設設定マスタのNo105の設定どおり動かない。 dou end
    }

    String resRadChangeSetting = "";
    // 施設設定マスタから 透析予定日変更時放射線検査予定変更機能 の設定値を取得
    //    String resRadChangeSetting = facilitySettingService.getFacilitySettingValue(
//      facilityCd,
//      FacilitySettingNo.RAD_SCHEDULE_CHANGE
//    );
    resRadChangeSetting = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE);
    // 一般撮影検査依頼変更締切り有無 1016
    String radChangeOnOffWithOrder = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.RAD_CHANGE_ON_OFF_WITH_ORDER);
    // 放射線検査依頼変更締切り日数 1013
    String radScheduleChangeLimitDay = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_DAY);
    // 放射線検査依頼変更締切り時間 1014
    String radScheduleChangeLimitTime = facilitySettingService.getFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.RAD_SCHEDULE_CHANGE_LIMIT_TIME);
    // 一般撮影日付加算
    String newRadDateAdd = "";
    // 一般撮影強制選択型
    boolean radForcedSelection = false;
    Calendar rightRadNow = Calendar.getInstance();
    rightRadNow.add(Calendar.DAY_OF_YEAR, Integer.valueOf(radScheduleChangeLimitDay));
    Date radDt = rightRadNow.getTime();
    newRadDateAdd = ymd.format(radDt);

    //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
    boolean radStatus = false;
    List<PatRadMain> patRadListRet = radRequestService.FindPatRadMainByIsOrder(Integer.valueOf(patId), condTreatDate, condTreatDate);
    if (patRadListRet.size() <= 0) {
      radStatus = true;
    }
    //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

    if (!"4".equals(resRadChangeSetting)) {
      if ("1".equals(radChangeOnOffWithOrder)) {
        if (Integer.valueOf(condTreatDate) < Integer.valueOf(newRadDateAdd)) {
          radForcedSelection = true;
        } else if (Integer.valueOf(condTreatDate) == Integer.valueOf(newRadDateAdd)) {
          if (Integer.valueOf(radScheduleChangeLimitTime.replace(":", "")) <= Integer.valueOf(newTime)) {
            radForcedSelection = true;
          }
        }
      }
    } else {
      radForcedSelection = true;
    }
    if (radForcedSelection) {
      // add #9273 施設設定マスタのNo105の設定どおり動かない。 dou start
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
      //if (examStatus) {
      if (radStatus) {
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
        resRadChangeSetting = "3";
      } else {
        resRadChangeSetting = String.valueOf(request.getFacilitySetting1008SelectedVal());
      }
      // add #9273 施設設定マスタのNo105の設定どおり動かない。 dou end
    }

    // FNSI-add 現行改善対応425 徐 end

    // 変更前日付の整形 YYYYMMDD -> YYYY/MM/DD
    String beforeDate = condTreatDate;
    String bf_year = beforeDate.substring(0, 4);
    String bf_month = beforeDate.substring(4, 6);
    String bf_day = beforeDate.substring(6);
    String beforeDateFormatted = bf_year + "/" + bf_month + "/" + bf_day;

    // 変更後日付の整形 YYYYMMDD -> YYYY/MM/DD
    String afterDate = newTreatDate;
    String af_year = afterDate.substring(0, 4);
    String af_month = afterDate.substring(4, 6);
    String af_day = afterDate.substring(6);
    String afterDateFormatted = af_year + "/" + af_month + "/" + af_day;

    Map<String, String> paramsMoveInfo = new HashMap<String, String>();
    paramsMoveInfo.put("patId", patId);
    paramsMoveInfo.put("beforeDate", beforeDateFormatted);
    paramsMoveInfo.put("afterDate", afterDateFormatted);

    Map<String, String> paramsDeleteInfo = new HashMap<String, String>();
    paramsDeleteInfo.put("patId", patId);
    paramsDeleteInfo.put("date", beforeDateFormatted);
    //add FNSI-8247 劉全航 start
    paramsDeleteInfo.put("userId", updUserId.toString());
    //add FNSI-8247 劉全航 end
    List<Long> patIdList = new ArrayList<>();
    patIdList.add(Long.parseLong(patId));
    String startDate = "";
    String endDate = "";
    ExamRequestResponse examRequestResponse = null;
    try {
      //mod #12462 患者は合計 by zrx  start
//      examRequestResponse = examRequestService.createExamRequestResponse(patIdList, startDate, endDate, facilityCd);
      examRequestResponse = examRequestService.createExamRequestResponse(patIdList, startDate, endDate, facilityCd, null);
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());
    }
    RadRequestResponse radRequestResponse = radRequestService.createRadRequestResponse(patIdList, startDate, facilityCd, null);
    //add #12462 患者は合計 by zrx  end

    // 検体検査が1件以上あった場合、日付を変更orキャンセルを行う
    if (examRequestResponse.patExamMains.size() > 0) {
      // 検体検査コードの取得
      Long examMainCd = examRequestResponse.patExamMains.get(examRequestResponse.patExamMains.size() - 1).getExamMainCd();

      // FNSI-mod 現行改善対応425 孫灝 20201117 start
      // 施設設定により処理分岐(検体検査)
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正  zhao start
      //if (Integer.valueOf(condTreatDate)!= Integer.valueOf(newTreatDate)) {
      if ((!Integer.valueOf(condTreatDate).equals(Integer.valueOf(newTreatDate)) && !"2".equals(isSamePatId))||("2".equals(isSamePatId)&&"2".equals(resExamChangeSetting))) {
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正  zhao end
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正  zhao start
        switchResExamChangeSetting(request, patId, facilityCd, updUserId, resExamChangeSetting, beforeDate, afterDate, paramsMoveInfo, paramsDeleteInfo, examRequestResponse, examMainCd,request.getIsSamePatId());
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正  zhao end
      }
      // FNSI-mod 現行改善対応425 孫灝 20201117 end
    }

    // 放射線検査が1件以上あった場合、日付を変更orキャンセルを行う
    if (radRequestResponse.patRadMains.size() > 0) {
      // 放射線検査コードの取得
      Long radResultCd = radRequestResponse.patRadMains.get(radRequestResponse.patRadMains.size() - 1).getRadResultCd();

      // FNSI-mod 現行改善対応425 孫灝 20201203 start
      // 施設設定により処理分岐(放射線検査)
      //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正  zhao start
      //if (Integer.valueOf(condTreatDate)!= Integer.valueOf(newTreatDate)) {
      if (!Integer.valueOf(condTreatDate).equals(Integer.valueOf(newTreatDate)) && !"2".equals(isSamePatId)) {
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正  zhao end
        //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
        switchResRadChangeSetting(request, patId, facilityCd, updUserId, resRadChangeSetting, beforeDate, afterDate, paramsMoveInfo, paramsDeleteInfo, radRequestResponse, radResultCd,request.getIsSamePatId());
        //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
      }
      // FNSI-mod 現行改善対応425 孫灝 20201203 end
    }

    // add FNSI 1006 No.426 患者イベント変更機能 --Sanjingye SgetExistOrderun start

    List<PatEvent> patEventList = selectPatEventPeriod(facilityCd, patId, beforeDate);

    if (patEventList.size() > 0) {

      for (int pat = 0; pat < patEventList.size(); pat++) {
        PatEvent pe = patEventList.get(pat);

        int facilitySetting3005SelectedVal = request.getFacilitySetting3005SelectedVal();
        switch (facilitySetting3005SelectedVal) {
          // 変更された透析予定の日付に患者イベントのイベント開始日を変更
          case 1:
            try {
              // Change pat event period
              Calendar beforeC = Calendar.getInstance();
              // Date before move.
              beforeC.set(Integer.valueOf(bf_year), Integer.valueOf(bf_month) - 1, Integer.valueOf(bf_day));
              Calendar afterC = Calendar.getInstance();
              // Date after move
              afterC.set(Integer.valueOf(af_year), Integer.valueOf(af_month) - 1, Integer.valueOf(af_day));

              // Days of movement
              int moveDays = afterC.get(Calendar.DAY_OF_YEAR) - beforeC.get(Calendar.DAY_OF_YEAR);

              // New eventStartDate and eventEndDate
              SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
              pe.setEventStartDate(sdf.format(afterC.getTime()));

              Date eventEndDate = sdf.parse(pe.getEventEndDate());
              afterC.setTime(eventEndDate);
              afterC.add(Calendar.DAY_OF_YEAR, moveDays);

              pe.setEventEndDate(sdf.format(afterC.getTime()));

              // update db pat_event
              updatePatEventPeriod(pe);
              //9273 start
              patEventDao.updateNoticeDate(pe.getPatEventCd(),moveDays);
              //9273 end

            } catch (Exception e) {
              //エラー
              EventLogMessage eventLogMessage = new EventLogMessage();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
              logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
              throw new RuntimeException(e.getMessage());   //rollback
            }
            break;
          //9273 start
          // 中止
          //case 3:
          case 2:
          //9273 end
            // mod #9273 施設設定マスタのNo105の設定どおり動かない。 start
            if(!condTreatDate.equals(newTreatDate)) {
              try {
                pe.setIsDel("1");
                updatePatEventIsDel(pe);
              } catch (Exception e) {
                //エラー
                EventLogMessage eventLogMessage = new EventLogMessage();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
                eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                if (facilityCd != null) {
                  eventLogMessage.setFacilityCd(facilityCd);
                }
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
                throw new RuntimeException(e.getMessage());   //rollback
              }
              // mod #9273 施設設定マスタのNo105の設定どおり動かない。 end
            }
            break;
          default:
            // 2.移動しない
            break;
        }
      }
    }

    // add FNSI 1006 No.426 患者イベント変更機能 --Sanjingye Sun end

    // 更新後開始時刻データ取得
    String startTime = OrdMainService.getOrdIndTreatStartTime(ordNo);

    // FNSI-add 対応401 孫灝 20201203 start
    // sjy: Delete data from ord_checklist by ord_no where the value of rst_dialysis_state of ord_main is in 0,1,2
    Integer beforBedCd = ordMain.getIndBedCd();
    switch (ordMain.getRstDialysisState()) {
      case "0":
      case "1":
      case "2":
        // FIXME 1006 401 {sendConditionCancelService.doCancel} throws an exception 孫灝
//        sendConditionCancelService.doCancel(facilityCd, beforBedCd.longValue(), null, "2");
        deleteOrdCheckListByOrdNo(ordNo, facilityCd);
        break;

    }
    // FNSI-add 対応401 孫灝 20201203 end

    // 更新後治療情報スケジュール編集情報データの作成
    ApiEntityOrdMain.ValiUpdateIndSchedule updBodyData = new ApiEntityOrdMain.ValiUpdateIndSchedule();
    // ログ出力時現行仕様表示部
    updBodyData.setFacility_cd(facilityCd);
    updBodyData.setPat_id(ordMain.getPatId().toString());
    updBodyData.setInd_start_date(ordMain.getTreatDate());
    updBodyData.setInd_end_date(ordMain.getTreatDate());
    updBodyData.setWeek_pattern(ordMain.getTreatWeek().toString());
    updBodyData.setInd_kur_cd(ordMain.getIndKurCd().toString());
    updBodyData.setInd_treatment_cd(ordMain.getIndTreatmentCd().toString());

    // 更新後データ(更新後開始日は未定)
    updBodyData.setEdit_ind_kur_cd(kurCd.toString());
    updBodyData.setEdit_ind_treat_date(newTreatDate);
    updBodyData.setEdit_ind_bed_cd(bedCd.toString());
    updBodyData.setInd_user_id(indUserId.toString());
    updBodyData.setUpd_user_id(updUserId.toString());
    updBodyData.setIs_deadline("");

    //該当する曜日を取得
    Integer weekNum = ordMain.getTreatWeek().intValue();
    List<Integer> weeksArray = Arrays.asList(weekNum);
    List<OrdMain> ordMainList = Arrays.asList(ordMain);

    //値がnullの場合はnullセット
    if (Objects.isNull(startTime)) {
      updBodyData.setEdit_ind_treat_start_time(null);
    }
    //文字列→時刻表記に変換して取得(nullの場合は"未登録"に変換)
    else {
      // 治療開始時刻 HHmm形式⇒HH:mm形式
      SimpleDateFormat treatTimeFormat = new SimpleDateFormat("HHmm");
      Date treatTimeDate = null;
      try {
        treatTimeDate = treatTimeFormat.parse(startTime);
      } catch (ParseException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      updBodyData.setEdit_ind_treat_start_time(new SimpleDateFormat("HH:mm").format(treatTimeDate));
    }

    // 設定パラメータを作成
    String paramTarget = "クール,治療開始時刻,ベッド,治療日";

    // 指示履歴作成機能呼び出し
    indHistoryMakeService.createScheduleHistory(updBodyData, "2", weeksArray, ordMainList, paramTarget);

    return new ResponseEntity<>(listRet, status);
  }
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  public List<PatRadMain> deletePatRad(String patId,String toDate,String fromDate){
    List<PatRadMain> updatePatRadMainList = new ArrayList<>();
    updatePatRadMainList = radRequestService.FindPatRadMainByIsOrder(Integer.valueOf(patId), fromDate, fromDate);
    PatRadMainHst patRadMainHst = new PatRadMainHst();
    updatePatRadMainList.forEach(item -> {
      patRadMainHst.setRadResultCd(item.getRadResultCd());
      patRadMainHst.setPatId(item.getPatId());
      patRadMainHst.setFacilityCd(item.getFacilityCd());
      patRadMainHst.setFnPatId(item.getFnPatId());
      patRadMainHst.setRegRadDate(item.getRegRadDate());
      patRadMainHst.setRegOrderClass(item.getRegOrderClass());
      patRadMainHst.setRadStatus(item.getRadStatus());
      patRadMainHst.setOrderRadSetInfo(item.getOrderRadSetInfo());
      patRadMainHst.setCopOrderNo1(item.getCopOrderNo1());
      patRadMainHst.setCopOrderNo2(item.getCopOrderNo2());
      patRadMainHst.setIsLock(item.getIsLock());
      patRadMainHst.setIndUserId(item.getIndUserId());
      patRadMainHst.setIsDel(item.getIsDel());
      patRadMainHst.setRegDate(item.getRegDate());
      patRadMainHst.setRegStaff(item.getRegStaff());
      patRadMainHst.setUpDate(item.getUpDate());
      patRadMainHst.setUpStaff(item.getUpStaff());
      patRadMainHstDao.insertOrderRadSetInfo(patRadMainHst);
      patRadMainDao.deleteByRadResultCdAndFacility(item);
    });
    return updatePatRadMainList;
  }
  public List<PatExamMain> deletePatExam(String patId,String toDate,String fromDate){
    List<PatExamMain> updatePatExamMainList = new ArrayList<>();
    updatePatExamMainList = examRequestService.FindPatExamMainByIsOrder(Integer.valueOf(patId), fromDate, fromDate);
    PatExamMainHst patExamMainHst = new PatExamMainHst();
    updatePatExamMainList.forEach(item -> {
      patExamMainHst.setExamMainCd(item.getExamMainCd());
      patExamMainHst.setPatId(item.getPatId());
      patExamMainHst.setFacilityCd(item.getFacilityCd());
      patExamMainHst.setFnPatId(item.getFnPatId());
      patExamMainHst.setRegExamDate(item.getRegExamDate());
      patExamMainHst.setRegOrderClass(item.getRegOrderClass());
      patExamMainHst.setExamStatus(item.getExamStatus());
      patExamMainHst.setOrderComment(item.getOrderComment());
      patExamMainHst.setOrderExamSetInfo(item.getOrderExamSetInfo());
      patExamMainHst.setExamOrderInfo(item.getExamOrderInfo());
      patExamMainHst.setOrderLabelInfo(item.getOrderLabelInfo());
      patExamMainHst.setDataGenClass(item.getDataGenClass());
      patExamMainHst.setResultExamDate(item.getResultExamDate());
      patExamMainHst.setResultComment(item.getResultComment());
      patExamMainHst.setExamResultInfo(item.getExamResultInfo());
      patExamMainHst.setCopOrderNo1(item.getCopOrderNo1());
      patExamMainHst.setCopOrderNo2(item.getCopOrderNo2());
      patExamMainHst.setIsLock(item.getIsLock());
      patExamMainHst.setIndUserId(item.getIndUserId());
      patExamMainHst.setIsDel(item.getIsDel());
      patExamMainHst.setRegDate(item.getRegDate());
      patExamMainHst.setRegStaff(item.getRegStaff());
      patExamMainHst.setUpDate(item.getUpDate());
      patExamMainHst.setUpStaff(item.getUpStaff());
      patExamMainHst.setIsOrder(item.getIsOrder());
      patExamMainHst.setPhyOrdClass(item.getPhyOrdClass());
      patExamMainHstDao.insertOrderExamHstSetInfo(patExamMainHst);
      patExamMainDao.deleteByExamMainCdAndFacility(item);
    });
    return updatePatExamMainList;
  }

  public Map<String,List<PatRadMain>> updatePatRad(String patId,String toDate,String fromDate){
    List<PatRadMain> updatePatRadMainList = new ArrayList<>();
    List<PatRadMain> updatePatRadMainDelList = new ArrayList<>();
    List<PatRadMain> updatePatRadMainInsertList = new ArrayList<>();
    updatePatRadMainList = radRequestService.FindPatRadMainByIsOrder(Integer.valueOf(patId), fromDate, fromDate);
    PatRadMainHst patRadMainHst = new PatRadMainHst();
    updatePatRadMainList.forEach(item -> {
      patRadMainHst.setRadResultCd(item.getRadResultCd());
      patRadMainHst.setPatId(item.getPatId());
      patRadMainHst.setFacilityCd(item.getFacilityCd());
      patRadMainHst.setFnPatId(item.getFnPatId());
      patRadMainHst.setRegRadDate(item.getRegRadDate());
      patRadMainHst.setRegOrderClass(item.getRegOrderClass());
      patRadMainHst.setRadStatus(item.getRadStatus());
      patRadMainHst.setOrderRadSetInfo(item.getOrderRadSetInfo());
      patRadMainHst.setCopOrderNo1(item.getCopOrderNo1());
      patRadMainHst.setCopOrderNo2(item.getCopOrderNo2());
      patRadMainHst.setIsLock(item.getIsLock());
      patRadMainHst.setIndUserId(item.getIndUserId());
      patRadMainHst.setIsDel(item.getIsDel());
      patRadMainHst.setRegDate(item.getRegDate());
      patRadMainHst.setRegStaff(item.getRegStaff());
      patRadMainHst.setUpDate(item.getUpDate());
      patRadMainHst.setUpStaff(item.getUpStaff());
      patRadMainHstDao.insertOrderRadSetInfo(patRadMainHst);
      updatePatRadMainDelList.add(item);
      patRadMainDao.deleteByRadResultCdAndFacility(item);
      String af_year = toDate.substring(0, 4);
      String af_month = toDate.substring(4, 6);
      String af_day = toDate.substring(6,8);
      SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      Timestamp timestamp = null;
      try {
        timestamp = new Timestamp(simpleDateFormat.parse(af_year+"-"+af_month+"-"+af_day + " 00:00:00").getTime());
      } catch (ParseException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      item.setRegRadDate(timestamp);
      item.setUpDate(new Timestamp(System.currentTimeMillis()));
      item.setRadResultCd(null);
      patRadMainDao.insertOrderRadSetInfo(item);
      updatePatRadMainInsertList.add(item);
    });
    Map<String,List<PatRadMain>> delInsertList = new HashMap();
    delInsertList.put("del",updatePatRadMainDelList);
    delInsertList.put("insert",updatePatRadMainInsertList);
    return delInsertList;
  }

  public List<PatExamMain> updatePatExam(String patId,String toDate,String fromDate){
    List<PatExamMain> updatePatExamMainList = new ArrayList<>();
    updatePatExamMainList = examRequestService.FindPatExamMainByIsOrder(Integer.valueOf(patId), fromDate, fromDate);
    PatExamMainHst patExamMainHst = new PatExamMainHst();
    updatePatExamMainList.forEach(item -> {
      patExamMainHst.setExamMainCd(item.getExamMainCd());
      patExamMainHst.setPatId(item.getPatId());
      patExamMainHst.setFacilityCd(item.getFacilityCd());
      patExamMainHst.setFnPatId(item.getFnPatId());
      patExamMainHst.setRegExamDate(item.getRegExamDate());
      patExamMainHst.setRegOrderClass(item.getRegOrderClass());
      patExamMainHst.setExamStatus(item.getExamStatus());
      patExamMainHst.setOrderComment(item.getOrderComment());
      patExamMainHst.setOrderExamSetInfo(item.getOrderExamSetInfo());
      patExamMainHst.setExamOrderInfo(item.getExamOrderInfo());
      patExamMainHst.setOrderLabelInfo(item.getOrderLabelInfo());
      patExamMainHst.setDataGenClass(item.getDataGenClass());
      patExamMainHst.setResultExamDate(item.getResultExamDate());
      patExamMainHst.setResultComment(item.getResultComment());
      patExamMainHst.setExamResultInfo(item.getExamResultInfo());
      patExamMainHst.setCopOrderNo1(item.getCopOrderNo1());
      patExamMainHst.setCopOrderNo2(item.getCopOrderNo2());
      patExamMainHst.setIsLock(item.getIsLock());
      patExamMainHst.setIndUserId(item.getIndUserId());
      patExamMainHst.setIsDel(item.getIsDel());
      patExamMainHst.setRegDate(item.getRegDate());
      patExamMainHst.setRegStaff(item.getRegStaff());
      patExamMainHst.setUpDate(item.getUpDate());
      patExamMainHst.setUpStaff(item.getUpStaff());
      patExamMainHst.setIsOrder(item.getIsOrder());
      patExamMainHst.setPhyOrdClass(item.getPhyOrdClass());
      patExamMainHstDao.insertOrderExamHstSetInfo(patExamMainHst);
      patExamMainDao.deleteByExamMainCdAndFacility(item);
      String af_year = toDate.substring(0, 4);
      String af_month = toDate.substring(4, 6);
      String af_day = toDate.substring(6,8);
      SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      Timestamp timestamp = null;
      try {
        timestamp = new Timestamp(simpleDateFormat.parse(af_year+"-"+af_month+"-"+af_day + " 00:00:00").getTime());
      } catch (ParseException e) {
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      item.setRegExamDate(timestamp);
      item.setUpDate(new Timestamp(System.currentTimeMillis()));
      patExamMainDao.insertOrderExamSetInfo(item);
    });
    return updatePatExamMainList;
  }

  public Map<String,List<PatRadMain>> updatePatRadIsSamePatId(List<PatRadMain> updatePatRadMainList,String toDate) {
    List<PatRadMain> updatePatRadMainDelList = new ArrayList<>();
    List<PatRadMain> updatePatRadMainInsertList = new ArrayList<>();
    PatRadMainHst patRadMainHst = new PatRadMainHst();
    updatePatRadMainList.forEach(item -> {
      patRadMainHst.setRadResultCd(item.getRadResultCd());
      patRadMainHst.setPatId(item.getPatId());
      patRadMainHst.setFacilityCd(item.getFacilityCd());
      patRadMainHst.setFnPatId(item.getFnPatId());
      patRadMainHst.setRegRadDate(item.getRegRadDate());
      patRadMainHst.setRegOrderClass(item.getRegOrderClass());
      patRadMainHst.setRadStatus(item.getRadStatus());
      patRadMainHst.setOrderRadSetInfo(item.getOrderRadSetInfo());
      patRadMainHst.setCopOrderNo1(item.getCopOrderNo1());
      patRadMainHst.setCopOrderNo2(item.getCopOrderNo2());
      patRadMainHst.setIsLock(item.getIsLock());
      patRadMainHst.setIndUserId(item.getIndUserId());
      patRadMainHst.setIsDel(item.getIsDel());
      patRadMainHst.setRegDate(item.getRegDate());
      patRadMainHst.setRegStaff(item.getRegStaff());
      patRadMainHst.setUpDate(item.getUpDate());
      patRadMainHst.setUpStaff(item.getUpStaff());
      patRadMainHstDao.insertOrderRadSetInfo(patRadMainHst);
      updatePatRadMainDelList.add(item);
      patRadMainDao.deleteByRadResultCdAndFacility(item);
      String af_year = toDate.substring(0, 4);
      String af_month = toDate.substring(4, 6);
      String af_day = toDate.substring(6, 8);
      SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      Timestamp timestamp = null;
      try {
        timestamp = new Timestamp(simpleDateFormat.parse(af_year + "-" + af_month + "-" + af_day + " 00:00:00").getTime());
      } catch (ParseException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
      item.setRegRadDate(timestamp);
      item.setUpDate(new Timestamp(System.currentTimeMillis()));
      item.setRadResultCd(null);
      patRadMainDao.insertOrderRadSetInfo(item);
      updatePatRadMainInsertList.add(item);
    });
    Map<String, List<PatRadMain>> delInsertList = new HashMap();
    delInsertList.put("del", updatePatRadMainDelList);
    delInsertList.put("insert", updatePatRadMainInsertList);
    return delInsertList;
  }
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
  // FNSI-mod 現行改善対応425 孫灝 20201203 start
  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  private void switchResRadChangeSetting(@RequestBody UpdateScheduleListDataRequest request, String patId, String facilityCd, Long updUserId, String resRadChangeSetting, String beforeDate, String afterDate, Map<String, String> paramsMoveInfo, Map<String, String> paramsDeleteInfo, RadRequestResponse radRequestResponse, Long radResultCd,String isSamePatId) {
    switch (resRadChangeSetting) {
      case "1":
        // 変更された透析予定の日付に放射線検査の日付を変更
        if("0".equals(isSamePatId)){
          switchResRadChangeSettingCase1(patId, facilityCd, updUserId, beforeDate, afterDate, paramsMoveInfo, radRequestResponse, radResultCd);
        }else if("1".equals(isSamePatId)){
          switchResRadChangeSettingCaseIsSamePatId1(patId, facilityCd, updUserId, beforeDate, afterDate, paramsDeleteInfo, radRequestResponse, radResultCd);
        }
        break;
      case "2":
        // 透析予定日が変更/中止された場合、放射線検査をキャンセル
        if("0".equals(isSamePatId)){
          switchResRadChangeSettingCase2(patId, facilityCd, updUserId, beforeDate, afterDate, paramsDeleteInfo, radRequestResponse, radResultCd);
        }else if("1".equals(isSamePatId)){
          switchResRadChangeSettingCaseIsSamePatId2(patId, facilityCd, updUserId, beforeDate, afterDate, paramsDeleteInfo, radRequestResponse, radResultCd);
        }

        break;
      case "3":
        // 放射線検査への処理は行わない
        break;
      default:
        break;
    }
  }
  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
  // FNSI-mod 現行改善対応425 孫灝 20201203 end
  //mod 10591 予定移動で、X線検査移動中止でのバッグアップデータができていない start zhao
  // FNSI-mod 現行改善対応425 孫灝 20201203 start
//  private void switchResRadChangeSettingCase2(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsDeleteInfo, RadRequestResponse radRequestResponse, Long radResultCd) {
//    try {
//      radRequestService.updateIsDel(paramsDeleteInfo);
//      journalService.callCreateJournal(
//        radRequestResponse.radDateList,
//        beforeDate,
//        afterDate,
//        facilityCd,
//        radResultCd,
//        updUserId,
//        Long.parseLong(patId),
//        // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
//        "022010",
//        "D"
//        // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
//      );
//    } catch (Exception e) {
//      //エラー
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//      throw new RuntimeException(e.getMessage());   //rollback
//    }
//  }
  private void switchResRadChangeSettingCase2(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsDeleteInfo, RadRequestResponse radRequestResponse, Long radResultCd) {
    try {
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
      //radRequestService.updateIsDel(paramsDeleteInfo);
      List<PatRadMain> updatePatRadMainList = deletePatRad(patId,afterDate,beforeDate);
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
      for (PatRadMain patRadMain :updatePatRadMainList) {
        journalService.callCreateJournal(
          radRequestResponse.radDateList,
          beforeDate,
          afterDate,
          facilityCd,
          patRadMain.getRadResultCd(),
          updUserId,
          Long.parseLong(patId),
          // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
          "022010",
          "D"
          // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
        );
      }
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }
  //mod 10591 予定移動で、X線検査移動中止でのバッグアップデータができていない end zhao
  // FNSI-mod 現行改善対応425 孫灝 20201203 end
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  private void switchResRadChangeSettingCaseIsSamePatId2(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsDeleteInfo, RadRequestResponse radRequestResponse, Long radResultCd) {
    try {
      //radRequestService.updateIsDel(paramsDeleteInfo);
      List<PatRadMain> updatePatRadMainListBefore = deletePatRad(patId,afterDate,beforeDate);
      List<PatRadMain> updatePatRadMainListAfter = deletePatRad(patId,beforeDate,afterDate);
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
      for (PatRadMain patRadMain :updatePatRadMainListBefore) {
        journalService.callCreateJournal(
          radRequestResponse.radDateList,
          beforeDate,
          afterDate,
          facilityCd,
          patRadMain.getRadResultCd(),
          updUserId,
          Long.parseLong(patId),
          // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
          "022010",
          "D"
          // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
        );
      }
      for (PatRadMain patRadMain :updatePatRadMainListAfter) {
        journalService.callCreateJournal(
          radRequestResponse.radDateList,
          afterDate,
          beforeDate,
          facilityCd,
          patRadMain.getRadResultCd(),
          updUserId,
          Long.parseLong(patId),
          // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
          "022010",
          "D"
          // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
        );
      }

    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

  // FNSI-mod 現行改善対応425 孫灝 20201203 start
  private void switchResRadChangeSettingCase1(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsMoveInfo, RadRequestResponse radRequestResponse, Long radResultCd) {
    try {
      //mod FNSI-8247 劉全航 start
//      radRequestService.updateRegRadDate(paramsMoveInfo);
//      journalService.callCreateJournal(
//        radRequestResponse.radDateList,
//        beforeDate,
//        afterDate,
//        facilityCd,
//        radResultCd,
//        updUserId,
//        Long.parseLong(patId),
//        // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
//        "022009",
//        "U"
//        // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
//      );
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
      //int i = radRequestService.updateRegRadDate(paramsMoveInfo);
      Map<String,List<PatRadMain>> delInsertList = updatePatRad(patId,afterDate,beforeDate);
      List<PatRadMain> updatePatRadMainDelList = delInsertList.get("del");;
      List<PatRadMain> updatePatRadMainInsertList = delInsertList.get("insert");

      if(updatePatRadMainDelList.size() >= 1){
        //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
        for (PatRadMain patRadMain:updatePatRadMainDelList) {
          journalService.callCreateJournal(
            radRequestResponse.radDateList,
            beforeDate,
            afterDate,
            facilityCd,
            patRadMain.getRadResultCd(),
            updUserId,
            Long.parseLong(patId),
            // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
            "022009",
            "D"
            // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
          );
        }
      }
      if(updatePatRadMainInsertList.size() >= 1){
        for (PatRadMain patRadMain:updatePatRadMainInsertList) {
          journalService.callCreateJournal(
            radRequestResponse.radDateList,
            beforeDate,
            afterDate,
            facilityCd,
            patRadMain.getRadResultCd(),
            updUserId,
            Long.parseLong(patId),
            // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
            "022009",
            "C"
            // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
          );
        }
//        journalService.callCreateJournal(
//          radRequestResponse.radDateList,
//          beforeDate,
//          afterDate,
//          facilityCd,
//          radResultCd,
//          updUserId,
//          Long.parseLong(patId),
//          // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
//          "022009",
//          "C"
//          // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
//        );
      }
      //mod FNSI-8247 劉全航 end
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }
  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  private void switchResRadChangeSettingCaseIsSamePatId1(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsMoveInfo, RadRequestResponse radRequestResponse, Long radResultCd) {
    try {
      //int i = radRequestService.updateRegRadDate(paramsMoveInfo);
      List<PatRadMain>  updatePatRadMainList1 = radRequestService.FindPatRadMainByIsOrder(Integer.valueOf(patId), beforeDate, beforeDate);
      List<PatRadMain>  updatePatRadMainList2= radRequestService.FindPatRadMainByIsOrder(Integer.valueOf(patId), afterDate, afterDate);


      Map<String,List<PatRadMain>> delInsertListAfter = updatePatRadIsSamePatId(updatePatRadMainList1,afterDate);
      Map<String,List<PatRadMain>> delInsertListBefore = updatePatRadIsSamePatId(updatePatRadMainList2,beforeDate);

      List<PatRadMain> updatePatRadMainDelListAfter = delInsertListAfter.get("del");;
      List<PatRadMain> updatePatRadMainInsertListAfter = delInsertListAfter.get("insert");
      if(updatePatRadMainDelListAfter.size() >= 1){
        for (PatRadMain patRadMain:updatePatRadMainDelListAfter) {
          journalService.callCreateJournal(
            radRequestResponse.radDateList,
            beforeDate,
            afterDate,
            facilityCd,
            patRadMain.getRadResultCd(),
            updUserId,
            Long.parseLong(patId),
            "022009",
            "D"
          );
        }
      }
      if(updatePatRadMainInsertListAfter.size() >= 1){
        for (PatRadMain patRadMain:updatePatRadMainInsertListAfter) {
          journalService.callCreateJournal(
            radRequestResponse.radDateList,
            beforeDate,
            afterDate,
            facilityCd,
            patRadMain.getRadResultCd(),
            updUserId,
            Long.parseLong(patId),
            "022009",
            "C"
          );
        }
      }
      List<PatRadMain> updatePatRadMainDelListBefore = delInsertListBefore.get("del");;
      List<PatRadMain> updatePatRadMainInsertListBefore = delInsertListBefore.get("insert");

      if(updatePatRadMainDelListBefore.size() >= 1){
        for (PatRadMain patRadMain:updatePatRadMainDelListBefore) {
          journalService.callCreateJournal(
            radRequestResponse.radDateList,
            afterDate,
            beforeDate,
            facilityCd,
            patRadMain.getRadResultCd(),
            updUserId,
            Long.parseLong(patId),
            "022009",
            "D"
          );
        }
      }
      if(updatePatRadMainInsertListBefore.size() >= 1){
        for (PatRadMain patRadMain:updatePatRadMainInsertListBefore) {
          journalService.callCreateJournal(
            radRequestResponse.radDateList,
            afterDate,
            beforeDate,
            facilityCd,
            patRadMain.getRadResultCd(),
            updUserId,
            Long.parseLong(patId),
            "022009",
            "C"
          );
        }
      }
      //mod FNSI-8247 劉全航 end
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }
  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  // FNSI-mod 現行改善対応425 孫灝 20201203 end

  // FNSI-mod 現行改善対応425 孫灝 20201117 start
  //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start

  // FNSI-mod 現行改善対応425 孫灝 20201117 start
  private void switchResExamChangeSetting(@RequestBody UpdateScheduleListDataRequest request, String patId, String facilityCd, Long updUserId, String resExamChangeSetting, String beforeDate, String afterDate, Map<String, String> paramsMoveInfo, Map<String, String> paramsDeleteInfo, ExamRequestResponse examRequestResponse, Long examMainCd,String isSamePatId) {
    switch (resExamChangeSetting) {
      case "1":
        // 変更された透析予定の日付に検体検査の日付を変更
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
        switchResExamChangeSettingCase1(patId, facilityCd, paramsMoveInfo,isSamePatId);
//        switchResExamChangeSettingCase1(patId, facilityCd, updUserId, beforeDate, afterDate, paramsMoveInfo, examRequestResponse, examMainCd);
        //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end
        break;
      case "2":
        // 透析予定日が変更/中止された場合、検体検査をキャンセル
        //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
        if("0".equals(isSamePatId)){
          switchResExamChangeSettingCase2(patId, facilityCd, updUserId, beforeDate, afterDate, paramsDeleteInfo, examRequestResponse, examMainCd);
        }else if("1".equals(isSamePatId)){
          switchResExamChangeSettingCaseIsSamePatId2(patId, facilityCd, updUserId, beforeDate, afterDate, paramsDeleteInfo, examRequestResponse, examMainCd);
        }
        //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

        break;
      case "3":
        // 検体検査への処理は行わない
        break;
      default:
        break;
    }
  }
  // FNSI-mod 現行改善対応425 孫灝 20201117 end

  private void switchResExamChangeSettingCase2(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsDeleteInfo, ExamRequestResponse examRequestResponse, Long examMainCd) {
    try {
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
      //deletePatExam(patId,afterDate,beforeDate);
      examRequestService.updateIsDel(paramsDeleteInfo);
      //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
      journalService.callCreateJournal(
        examRequestResponse.examDateList,
        beforeDate,
        afterDate,
        facilityCd,
        examMainCd,
        updUserId,
        Long.parseLong(patId),
        // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
        "021010",
        "D"
        // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
      );
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
  private void switchResExamChangeSettingCaseIsSamePatId2(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsDeleteInfo, ExamRequestResponse examRequestResponse, Long examMainCd) {
    try {
      examRequestService.updateIsDel(paramsDeleteInfo);
      //deletePatExam(patId,afterDate,beforeDate);
      //deletePatExam(patId,beforeDate,afterDate);
      journalService.callCreateJournal(
        examRequestResponse.examDateList,
        beforeDate,
        afterDate,
        facilityCd,
        examMainCd,
        updUserId,
        Long.parseLong(patId),
        // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
        "021010",
        "D"
        // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
      );
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }
  //add 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end

  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
//  private void switchResExamChangeSettingCase1(String patId, String facilityCd, Long updUserId, String beforeDate, String afterDate, Map<String, String> paramsMoveInfo, ExamRequestResponse examRequestResponse, Long examMainCd) {
  private void switchResExamChangeSettingCase1(String patId, String facilityCd, Map<String, String> paramsMoveInfo,String isSamePatId) {
  //mod #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end
  //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
//    try {
      //mod FNSI-8247 劉全航 start
//      examRequestService.updateRegExamDate(paramsMoveInfo);
//      journalService.callCreateJournal(
//        examRequestResponse.examDateList,
//        beforeDate,
//        afterDate,
//        facilityCd,
//        examMainCd,
//        updUserId,
//        Long.parseLong(patId),
//        // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
//        "021009",
//        "U"
//        // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
//      );
//      int i = examRequestService.updateRegExamDate(paramsMoveInfo);
//      if(i == 1){
//        journalService.callCreateJournal(
//          examRequestResponse.examDateList,
//          beforeDate,
//          afterDate,
//          facilityCd,
//          examMainCd,
//          updUserId,
//          Long.parseLong(patId),
//          // mod FNSI 1006 No.538 外部連携 start -- Sanjingye Sun 20210104
//          "021009",
//          "U"
//          // mod FNSI 1006 No.538 外部連携 end -- Sanjingye Sun 20210104
//        );
//      }
//      //mod FNSI-8247 劉全航 end
//    } catch (Exception e) {
//      //エラー
//      EventLogMessage eventLogMessage = new EventLogMessage();
//      eventLogMessage.setLogMessage(e.getMessage());
//      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
//      throw new RuntimeException(e.getMessage());   //rollback
//    }
    //del #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end
    //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc start
    Map<String, String> moveDateMapList = new HashMap<>();
    moveDateMapList.put(paramsMoveInfo.get("afterDate"), paramsMoveInfo.get("beforeDate"));
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao start
    if("1".equals(isSamePatId)) {
      moveDateMapList.put(paramsMoveInfo.get("beforeDate"), paramsMoveInfo.get("afterDate"));
    }
    //mod 10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 zhao end
    try {
      // del 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  start
      // ordMainResource.mergePatExamMainListByDate(facilityCd, Long.valueOf(patId), moveDateMapList);
      // del 10618 検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する 関  end
    //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正 20240410 ztc end
    } catch (Exception e) {
      //エラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_SCHEDULE_LIST, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e.getMessage());   //rollback
    }
  }
  /* add by yuqinlong  2023-02-02 [CodeOptimization] end  */

  //add #10601 スケジュール表動作不正 start
  @Override
  public ResponseEntity<List<OrdSchedule>> selectForSearchReservedBed2(UpdateScheduleListDataRequestList request){

    HttpStatus status = HttpStatus.OK;
    List<OrdSchedule> ret = new ArrayList<>();
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("selectForSearchReservedBed2処理開始");

    try {
      List<IndScheduleInfo> beforeIndScheduleInfoList = request.getBeforeIndScheduleInfoList();
      List<IndScheduleInfo> afterIndScheduleInfoList = request.getAfterIndScheduleInfoList();
      if(beforeIndScheduleInfoList == null || beforeIndScheduleInfoList.isEmpty()
          || afterIndScheduleInfoList == null || afterIndScheduleInfoList.isEmpty()){
        status = HttpStatus.INTERNAL_SERVER_ERROR;
        String retMsg = "selectForSearchReservedBed2 before or after data null";
        eventLogMessage.setLogMessage(retMsg);
        logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return new ResponseEntity<>(ret, status);
      }


      if(afterIndScheduleInfoList != null && !afterIndScheduleInfoList.isEmpty()){
        // get Schedule from DB
        List<OrdSchedule> ordScheduleList = scheduleListDao.selectForSearchReservedBed2(afterIndScheduleInfoList);
        if(ordScheduleList != null && !ordScheduleList.isEmpty()){

          List<IndScheduleInfo> beforeHasOrdNoList = beforeIndScheduleInfoList.stream().filter(item -> item.getOrdNo() != null && item.getOrdNo() > 0)
            .collect(Collectors.toList());
          if(beforeHasOrdNoList != null && !beforeHasOrdNoList.isEmpty()){

            Map<String, OrdSchedule> ordScheduleMap = new HashMap<>();
            for (OrdSchedule ordSchedule : ordScheduleList) {
              String key = ordSchedule.getBedCd() + "_" + ordSchedule.getKurCd() + "_" + ordSchedule.getTreatDate();
              ordScheduleMap.put(key, ordSchedule);
            }

            for (IndScheduleInfo indScheduleInfo : beforeHasOrdNoList) {
              if (indScheduleInfo.getIndBedCd() != null && indScheduleInfo.getIndKurCd() != null && StringUtils.hasText(indScheduleInfo.getTreatDate())) {
                String key = indScheduleInfo.getIndBedCd() + "_" + indScheduleInfo.getIndKurCd() + "_" + indScheduleInfo.getTreatDate();
                if (ordScheduleMap.containsKey(key)) {
                  ret.add(ordScheduleMap.get(key));
                }
              }
            }

          }
        }
      }

    }catch (Exception ex) {
      status = HttpStatus.INTERNAL_SERVER_ERROR;
      String retMsg = "selectForSearchReservedBed2処理で例外発生:"+ex.getMessage();
      eventLogMessage.setLogMessage(retMsg);
      logService.log(LogLevel.ERROR, eventLogMessage,"",SERVICE_NAME.FNSI, null);
      return new ResponseEntity<>(ret, status);
    }
    eventLogMessage.setLogMessage("selectForSearchReservedBed2処理終了");
    logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(ret, status);
  }
  //add #10601 スケジュール表動作不正 end
  // add #11493 スケジュール表　更新不正 関 start
  public Boolean checkBatchMovePatExistance(String bodydata, String facilityCd) throws JsonProcessingException {
    Boolean ret = true;
    ObjectMapper objectMapper = new ObjectMapper();
    List<Map<String, Object>> batchMoveList = objectMapper.readValue(bodydata, new TypeReference<List<Map<String, Object>>>() {});
    List<IndScheduleInfo> scheduleList = new ArrayList<>();
    String treatDate = "";
    for (Map<String, Object> data : batchMoveList) {
      Long ordNo = parseLong(data.get("ordNo"));
      Long kurCd = parseLong(data.get("kur_cd"));
      Long bedCd = parseLong(data.get("bed_cd"));
      treatDate = (String) data.get("treatDate");
      String dialysisState = (String) data.get("dialysisState");

      IndScheduleInfo indScheduleInfo = new IndScheduleInfo();
      indScheduleInfo.setOrdNo(ordNo);
      indScheduleInfo.setIndKurCd(kurCd);
      indScheduleInfo.setIndBedCd(bedCd);
      indScheduleInfo.setTreatDate(treatDate);
      indScheduleInfo.setRstDialysisState(dialysisState);

      scheduleList.add(indScheduleInfo);
    }

    if (scheduleListDao.selectBatchMovePatExistanceByIndScheduleList(scheduleList, facilityCd) != scheduleList.size()) {
      return false;
    }

    return ret;
  }
  private static Long parseLong(Object value) {
    return value != null ? Long.parseLong(value.toString()) : null;
  }
  // add #11493 スケジュール表　更新不正 関 end
}
