package jp.co.nikkiso.ntss.api.service.conditionSend;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.DBAppWebAPIDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

/**
 * 条件送信3011系のService実装クラス.
 */
@Service
public class ConditionSendResultUtilServiceImpl implements ConditionSendResultUtilService {

  /**
   * 条件送信画面系Dao.
   */
  @Autowired
  private DBAppWebAPIDao dBAppWebAPIDao;

  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private OrdMainDao ordMainDao;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // DB更新ログ出力ロジック wangzuo End

  /**
   * 各名称取得用
   * @param ordNo オーダー番号
   * @return 名称
   * @throws Exception
   */
  public Map<String,Object> getNamesFromDbs(Long ordNo) {
    return dBAppWebAPIDao.selectNameDataFromVariousTbl(ordNo);
  }

  /**
   * ord_main情報の取得
   */
  public OrdMain getOrdMainInfo(Long ord_no) {
    return ordMainDao.selectByOrdNo(ord_no);
  }

  /**
   * pat_main情報の取得
   * @param pat_id  患者ID
   * @return 患者情報
   */
  public PatMain getPatMainInfo(Long pat_id) {

    PatMain ret = null ;

    List<Long> list = new ArrayList<Long>() ;
    list.add(pat_id) ;

    List<PatMain> patMainList = patMainDao.selectByIdList(list) ;

    if(patMainList != null && patMainList.size() == 1)
    {
      ret = patMainList.get(0) ;
    }

    return  ret ;
  }

  /**
   * pat_unque情報の取得
   * @param pat_id  患者ID
   * @return 患者情報
   */
  public PatUnique getPatUniqueInfo(Long pat_id) {

    PatUnique ret = null ;

    List<Long> list = new ArrayList<Long>() ;
    list.add(pat_id) ;

    List<PatUnique> patUniqueList = patUniqueDao.selectByIdList(list) ;

    if(patUniqueList != null && patUniqueList.size() == 1)
    {
      ret = patUniqueList.get(0) ;
    }

    return  ret ;
  }

  /**
   * mnt_machine_state情報の取得
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   */
  public List<MntMachineState> getMntMachineStateInfo(
        String facilityCd,
        String machineTypeCd,
        String machineSerial
      )
  {
    //レコードを取得するために4番目のパラメータをnullに指定する(仕様)
    return mntMachineStateDao.selectByProcessState(
              facilityCd,
              machineTypeCd,
              machineSerial,
              null
          );
  }

  /**
   * オフラインかどうかの確認
   * @param ord_no  オーダー番号
   * @return true:オフライン
   */
  public boolean checkOfflineOrNot(Long ord_no) {
    return dBAppWebAPIDao.checkOfflineOrNot(ord_no) ;
  }

  /**
   * 治療方法が特殊浄化かどうかの確認
   * @param ord_no  オーダー番号
   * @return true:治療方法が特殊浄化
   */
  public boolean checkDeviceModeIsPureOrNot(Long ord_no)
  {
    return dBAppWebAPIDao.checkDeviceModeIsPureOrNot(ord_no) ;
  }

  /**
   * 指定した患者の治療状況の確認
   *  実績:治療状況が、治療中以上かどうかの確認
   * @param ord_no  オーダ番号
   * @param facility_cd  施設コード
   * @return true:治療中以上
   */
  public boolean checkPatStatusNotUnderOperation(Long ord_no,String facility_cd)
  {
    return dBAppWebAPIDao.checkPatStatusNotUnderOperation(ord_no, facility_cd);
  }

  /**
   * 病棟名、診療科名の取得
   * @param facility_cd 施設コード
   * @param ward_cd     病棟コード
   * @param course_cd   診療科コード
   * @return 名称
   *    key                 value
   *    ----------------+-------------
   *    ward_name           病棟名
   *    course_name         診療科名
   */
  public Map<String,Object> getWardAndCourseName(
        String facility_cd,
        Integer ward_cd,
        Integer course_cd
      ) {
    return dBAppWebAPIDao.selectWardAndCourseName(facility_cd, ward_cd, course_cd) ;
  }

  /**
   * ord_mainの更新処理
   * @param ordMain  ord_mainエンティティクラス
   */
  public int updateOrdMain(OrdMain ordMain) {
    return dBAppWebAPIDao.updateOrdMain(ordMain);
  }

  /**
   * mnt_machine_stateの更新処理
   * @param mntMachineState  mnt_machine_stateエンティティクラス
   * @return 更新件数
   */
  public int updateMntMachineState(MntMachineState mntMachineState) {
    return dBAppWebAPIDao.updateMntMachineState(mntMachineState);
  }

  /**
   * 治療終了予定時刻の更新
   *    mnt_machine_state:end_plan_date
   *       ←
   *        mnt_machine_state:start_plan_date
   *        +
   *        ord_main-指示/治療時間(分)
   * @param ord_no  オーダー番号
   * @param facility_cd 施設コード
   * @param machine_type_cd 型式コード
   * @param machine_serial  製造番号
   * @return    更新件数
   */
  public int updateEndPlanDateOnMntMachineState(
      Long ord_no,
      String facility_cd,
      String machine_type_cd,
      String machine_serial
  ) {
    int ret = 0 ;

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "mnt_machine_state";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" facility_cd = '" + facility_cd + "'\n");
    wheres.append(" AND\n");
    wheres.append(" machine_type_cd = '" + machine_type_cd + "'\n");
    wheres.append(" AND\n");
    wheres.append(" machine_serial = '" + machine_serial + "'\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    ret = dBAppWebAPIDao.updateEndPlanDateOnMntMachineState(ord_no, facility_cd, machine_type_cd, machine_serial) ;

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && ret > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    return ret ;
  }

  /*
   *    薬剤情報の取得
   * @param facility_cd     施設コード
   * @param medicine_type   薬剤区分
   * @param cd              薬剤(or 調整薬剤)コード
   */
  public Map<String,Object> getMedicineInfo(
                             String facilityCd,
                             Integer medicine_type,
                             Integer cd
  ) {
    return dBAppWebAPIDao.selectMedicineInfo(
            facilityCd,
            medicine_type,
            cd
          );
  }


  /*
   *    投与タイミング名の取得
   * @param facility_cd     施設コード
   * @param timing_cd       投与タイミングコード
   */
  public String getTimingName(
        String facility_cd,
        Integer timing_cd
      )
  {
   return dBAppWebAPIDao.selectTimingName(facility_cd, timing_cd) ;
  }

  /*
   *    手技名の取得
   * @param facility_cd     施設コード
   * @param name_cd         手技コード
   */
  public String getProcedureName(
        String facility_cd,
        Integer procedure_cd
      )
  {
    return dBAppWebAPIDao.selectProcedureName(facility_cd, procedure_cd) ;
  }

  /*
   *    医療材料情報の取得
   * @param facility_cd     施設コード
   * @param cd              医療材料コード
   */
  public Map<String,Object> getEquipmentInfo(
         String facility_cd,
         Integer cd
      ) {
    return dBAppWebAPIDao.selectEquipmentInfo(facility_cd, cd) ;
  }
  /*
   *    ダイアライザー情報(名称)の取得
   * @param facility_cd     施設コード
   * @param cd              ダイアライザコード
   * @return   key            value
   *            model_number    型番
   *            maker           メーカー名
   */
  public Map<String,Object> getDialyzerNames(
         String facility_cd,
         Integer cd
      ) {
    return dBAppWebAPIDao.selectDialyzerNames(facility_cd, cd) ;
  }
  /*
   *    医療材料情報(名称)の取得
   * @param facility_cd     施設コード
   * @param cdList          医療材料コード(リスト)
   * @return mapリスト
   *           key            value
   *            equipment_cd    医療材料コード
   *            equipment_name  医療材料名
   */
  public List<Map<String,Object>> getNameListWithCase(
         String target,
         String facility_cd,
         List<Integer> cdList
      )
  {
    return dBAppWebAPIDao.selectNameListWithCase(target,facility_cd, cdList);
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_WEB_API + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return   eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End
}
