package jp.co.nikkiso.ntss.admin_web.service.master.checklist;

import java.sql.Timestamp;
import java.util.Date;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.StringUtils;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.custom.MstEquipmentClassForChecklist;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class MstChecklistServiceImpl implements MstChecklistService {

  @Autowired
  MstChecklistDao mstChecklistDao;
  @Autowired
  private MstEquipmentClassDao mstEquipmentClassDao;
  @Autowired
  private OrdChecklistDao ordChecklistDao;
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 start
  @Autowired
  private OrdMainDao ordMainDao;
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 end

  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  //DB更新ログ出力ロジック wp end
  // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
  @Autowired
  private LogService logService;

  private final static String KEY_EDIT_LIST = "editList";
  private final static String KEY_LIST_CD = "list_cd";
  private final static String KEY_ITEM_NUMBER = "item_number";
  private final static String KEY_LIST_NAME = "list_name";
  private final static String NO_CHECKED = "0";
  private final static Long NULL_LONG = null;
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 start
  private final static String KEY_ORD_CHECKLIST_CHANGE_FLG = "ord_checklist_change_flg";
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 end
  // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
  @Override
  public List<MstChecklist> mstChecklistSelectByFacility(String facilityCd){
    return mstChecklistDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
  }

  @Override
  public List<MstEquipmentClassForChecklist> getMstEquipClassList(String facilityCd) {
    return mstEquipmentClassDao.selectAllChecklist(SelectOptions.get(), facilityCd);
  }

  @Override
  @Transactional
  public int mstChecklistInsert(MstChecklist param) {
    return mstChecklistDao.insert(param);
  }

// mod #8344 【デグレ】チェックリストマスタの保存までが長い dou start
//  /**
//   * チェックリストマスタ更新
//   */
//  @Override
//  @Transactional
//  public int mstChecklistUpdate(MstChecklist param) {
//
//
//    //DB更新ログ出力ロジック wp start
//
//    String mmsTbN = "mst_checklist";
//
//    // SQL検索条件
//    StringBuffer wheres = new StringBuffer("");
//    wheres.append(" WHERE\n");
//    wheres.append(" checklist_cd = '" + param.getChecklistCd() + "'" +"\n");
//    //add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
//    wheres.append(" AND\n");
//    wheres.append(" facility_cd = '" + param.getFacilityCd() + "'" +"\n");
//    //add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
//    // logCommon設定
//    // logCommon設定
//    // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
//    // DataUpdateLogCommonNew logCommon = getLogCommon(mstChecklistDao, mmsTbN, wheres, getEventLogMessage());
//    DataUpdateLogCommonNew logCommon = getLogCommon(mstChecklistDao, mmsTbN, wheres, getEventLogMessage(), null);
//    // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
//    // ログ出力カラム情報及び更新前データ情報取得
//    boolean setResult = logCommon.setInfo();
//    //DB更新ログ出力ロジック wp end
//
//    int res = 0;
//    // 更新前の情報削除フラグセット
//    res += mstChecklistDao.updateByChecklistCd(param.getChecklistCd());
//
//    //DB更新ログ出力ロジック wp start
//    // 更新後データ取得、差分あれば、log出力
//    if (setResult && res > 0) {
//      logCommon.updateLog();
//    }
//    //DB更新ログ出力ロジック wp end
//
//    // 新しく設定を登録
//    param.setChecklistCd(null);
//    res += mstChecklistDao.insert(param);
//
//    // DB更新ログ出力ロジック wangzuo Start
//    String tableNameOrd = "ord_checklist";
//    // SQL検索条件
//    StringBuffer wheresOrd = new StringBuffer("");
//    wheresOrd.append(" WHERE\n");
//    wheresOrd.append(" rst_class = 0\n");
//    wheresOrd.append(" AND\n");
//    wheresOrd.append(" is_del = '0'\n");
//    wheresOrd.append(" AND\n");
//    wheresOrd.append(" is_disp = '1'\n");
//    //add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
//    wheresOrd.append(" AND\n");
//    wheresOrd.append(" facility_cd = '" + param.getFacilityCd() + "'" +"\n");
//    //add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
//    // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
//    String limit = " limit 100";
//    // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
//    // logCommon設定
//    // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
//    // DataUpdateLogCommonNew logCommonOrd = getLogCommon(ordChecklistDao, tableNameOrd, wheresOrd, getEventLogMessage());
//    DataUpdateLogCommonNew logCommonOrd = getLogCommon(ordChecklistDao, tableNameOrd, wheresOrd, getEventLogMessage(), limit);
//    // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
//    // ログ出力カラム情報及び更新前データ情報取得
//    //mod 8344【デグレ】チェックリストマスタの保存までが長い zhao start
////    boolean setResultOrd = logCommonOrd.setInfo();
//    boolean setResultOrd = logCommonOrd.setInfoLimit();
//    //mod 8344【デグレ】チェックリストマスタの保存までが長い zhao end
//    // DB更新ログ出力ロジック wangzuo End
//
//    // 条件送信前のチェックリスト実績削除
//    //mod 8344【デグレ】チェックリストマスタの保存までが長い zhao start
////    int updateCountOrd = ordChecklistDao.updateDeleteByRstClass();
//    int updateCountOrd = ordChecklistDao.updateDeleteByRstClassByFacilityCd(param.getFacilityCd());
//    //mod 8344【デグレ】チェックリストマスタの保存までが長い zhao end
//    // DB更新ログ出力ロジック wangzuo Start
//    // 更新後データ取得、差分あれば、log出力
//    if (setResultOrd && updateCountOrd > 0) {
//      logCommonOrd.updateLog();
//    }
//    // DB更新ログ出力ロジック wangzuo End
//
//    return res;
//  }

  /**
   * チェックリストマスタ更新
   */
  @Override
  @Transactional
  public int mstChecklistUpdate(Map<String, Object> params) {

    int res = 0;
    try {
      ObjectMapper mapper = new ObjectMapper();
      MstChecklist param = mapper.convertValue(params.get("mstChecklist"), new TypeReference<MstChecklist>() {});
      String mmsTbN = "mst_checklist";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" checklist_cd = '" + param.getChecklistCd() + "'" + "\n");
      wheres.append(" AND\n");
      wheres.append(" facility_cd = '" + param.getFacilityCd() + "'" + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(mstChecklistDao, mmsTbN, wheres, getEventLogMessage(), null);
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // 更新前の情報削除フラグセット
      res += mstChecklistDao.updateByChecklistCd(param.getChecklistCd());
      // 更新後データ取得、差分あれば、log出力
      if (setResult && res > 0) {
        logCommon.updateLog();
      }
      // 新しく設定を登録
      param.setChecklistCd(null);
      res += mstChecklistDao.insert(param);

      // チェック済み項目のチェックリストマスタ変更
      // 未チェックに変更し新しい項目で表示。
      // 対象データは「チェックリスト実績(ord_checklist)」からを物理削除
      List<Map> editList = (List<Map>) params.get(KEY_EDIT_LIST);
      // del #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen start
      // List<Long> checklistCtlNoList = new ArrayList<>();
      // del #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen end
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 start
      List<Long> ordNoList = ordMainDao.selectOrdNoByRstDialysisState0(param.getFacilityCd());
      editList.stream().forEach(x -> {
        if ("1".equals(x.get(KEY_ORD_CHECKLIST_CHANGE_FLG).toString())) {
          String listCd = x.get(KEY_LIST_CD).toString();
          String itemNumber = x.get(KEY_ITEM_NUMBER).toString();
//         List<OrdChecklist> ordChecklists = ordChecklistDao.selectIsChecked(param.getFacilityCd(), listCd, itemNumber);
//         if (ordChecklists.size() > 0) {
//           ordChecklists = ordChecklists.stream().map(y -> {
//             OrdChecklist.OrdChecklistRegCheckInfo rstChecklistInfo = y.getRstChecklistInfo();
//             rstChecklistInfo.setName(x.get(KEY_LIST_NAME).toString());
//             y.setRstChecklistInfo(rstChecklistInfo);
//             // del #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen start
//             // checklistCtlNoList.add(y.getChecklistCtlNo());
//             // del #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen end
//             y.setChecklistCtlNo(NULL_LONG);
//             y.setIsCheck(NO_CHECKED);
//             y.setUpDate(this.getTimeNow());
//             return y;
//           }).collect(Collectors.toList());
//           /* upd by ztc 2023-05-19 [8605] 一括挿入データの修正ioストリームの超長異常問題が発生しました  --start */
// //          ordChecklistDao.insertByList(ordChecklists);
//           this.insertBatch(ordChecklists);
          /* upd by ztc 2023-05-19 [8605] 一括挿入データの修正ioストリームの超長異常問題が発生しました  --end */
          // del #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen start
          ordChecklistDao.deleteByCheckListCtlNoList(param.getFacilityCd(), listCd, itemNumber, ordNoList);
          // del #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen end
          // }
        }
      });
      List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), param.getFacilityCd(), "0");
      MstChecklist nowMstChecklist = mstChecklist.get(0);
      ordMainDao.updateChecklistCdByOrdNos(ordNoList, nowMstChecklist.getChecklistCd().toString(), param.getFacilityCd());
      //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない。 関 end
      // del #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen start
      // if (checklistCtlNoList.size() > 0) {
      //   ordChecklistDao.deleteByCheckListCtlNoList(checklistCtlNoList);
      // }
      // del #9539 チェックリストマスタの設定を変更して保存しても保存できない dengshen end
    } catch (Exception e) {
      // エラーメッセージをログ出力
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      throw new NotExistException(e.getMessage());
    }
    return res;
  }
  // mod #8344 【デグレ】チェックリストマスタの保存までが長い dou end

  /* add by ztc 2023-05-19 [8605] 一括挿入データの修正ioストリームの超長異常問題が発生しました  --start */
  public void insertBatch(List<OrdChecklist> targeSaveList) {
    int loopCount = targeSaveList.size() / AdminWebConstant.SystemUseSetting.BATCH_INSERT_MAX_LIMIT_NUM_ORD_CHECK_LIST;
    for (int i = 0; i <= loopCount; i++) {
      List<OrdChecklist> saveList;
      if (i == loopCount) {
        saveList = targeSaveList.subList(i * AdminWebConstant.SystemUseSetting.BATCH_INSERT_MAX_LIMIT_NUM_ORD_CHECK_LIST
                , targeSaveList.size());
      } else {
        saveList = targeSaveList.subList(i * AdminWebConstant.SystemUseSetting.BATCH_INSERT_MAX_LIMIT_NUM_ORD_CHECK_LIST
                , (i + 1) * AdminWebConstant.SystemUseSetting.BATCH_INSERT_MAX_LIMIT_NUM_ORD_CHECK_LIST);
      }
      ordChecklistDao.insertByList(saveList);
    }
  }
  /* add by ztc 2023-05-19 [8605] 一括挿入データの修正ioストリームの超長異常問題が発生しました  --end */

  /**
   * 現在の日を取得する
   *
   * @return 日付
   */
  public Timestamp getTimeNow() {
    Date now = new Date();
    return new Timestamp(now.getTime());
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return   eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
  // private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage, String limit) {
  // mod #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
    logCommon.setCommonEventLogMessage(eventLogMessage);
    if (StringUtils.isNotBlank(limit)) {
      logCommon.setLimit(limit);
    }
    // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End
}
