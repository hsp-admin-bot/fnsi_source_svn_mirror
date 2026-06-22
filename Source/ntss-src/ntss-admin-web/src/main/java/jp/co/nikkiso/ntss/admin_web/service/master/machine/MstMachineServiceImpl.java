package jp.co.nikkiso.ntss.admin_web.service.master.machine;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine.MstMachineChangeMachineRequest;
import jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine.MstMachineSwitchOfflineRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstDeviceEdgeDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineTypeDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommon;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;


@Service
public class MstMachineServiceImpl implements MstMachineService {

  @Autowired
  MstMachineTypeDao mstMachineTypeDao;

  @Autowired
  MstDeviceEdgeDao mstDeviceEdgeDao;

  @Autowired
  MstMachineDao mstMachineDao;

  @Autowired
  MntMachineStateDao mntMachineStateDao;

  // add FNSI-追加log wp start
  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  private LogService logService;

  @Autowired
  private MntFindMachineService mntFindMachineService;

  /**
   * データ更新ログ共通クラス
   */
  @Autowired
  DataUpdateLogCommon logCommon;

  // add FNSI-追加log wp end
  //9871 addデバイスエッジが並び順の通りに表示しない zhao start
  @Autowired
  MstComsvSettingDao mstComsvSettingDao;
  //9871 addデバイスエッジが並び順の通りに表示しない zhao end

  @Override
  public List<MstMachineType> selectMachineTypeAll() {
    return mstMachineTypeDao.selectAll();
  }

  @Override
  public List<MstDeviceEdge> selectDeviceEdgeByFacilityCd(String facilityCd) {
    return mstDeviceEdgeDao.selectByFacilityCd(facilityCd);
  }

  // add #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm start
  @Override
  public List<MstDeviceEdge> selectAllDeviceEdgeByFacilityCd(String facilityCd) {
    return mstDeviceEdgeDao.selectAllByFacilityCd(facilityCd);
  }
  // add #11015 デバイスエッジマスタで項目を削除した際に関連マスタで表示不正 zkm end

  @Override
  public MstMachine selectMachine(String machineTypeCd, String machineSerial, String facilityCd) {
    return mstMachineDao.selectByCd( machineTypeCd, machineSerial, facilityCd);
  }

  @Override
  @Transactional
  public int deleteMachine(MstMachine mstMachine) {
    return mstMachineDao.delete(mstMachine);
  }
  //9871 addデバイスエッジが並び順の通りに表示しない zhao start
  @Override
  public List<MstDeviceEdge> selectByOrderItem(String facilityCd,List<MstDeviceEdge> res_device_edge){
    List<MstDeviceEdge> res_device_edgeNew = new ArrayList<>();
    List<MstComsvSetting> mstComsvSettingList = mstComsvSettingDao.selectByOrderItem(facilityCd);
    for (MstComsvSetting mstComsvSetting : mstComsvSettingList ){
        MstDeviceEdge res_device_edgeFilter = res_device_edge.stream().filter(e->e.getDeviceEdgeNo().equals(mstComsvSetting.getDeviceEdgeNo())).findFirst().orElse(null);
        if (res_device_edgeFilter != null) {
            res_device_edgeNew.add(res_device_edgeFilter);
        }
    }
    List<MstDeviceEdge> mergedList = new ArrayList<>(res_device_edgeNew);
    mergedList.addAll(res_device_edge.stream().filter(e -> !res_device_edgeNew.contains(e)).collect(Collectors.toList()));
    return mergedList;
  }
  //9871 addデバイスエッジが並び順の通りに表示しない zhao end

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateStateOfflineMachines(String facilityCd, List<Long> codeList) {
    MntMachineState mntParams = new MntMachineState();
    mntParams.setProcessState("07");
    mntParams.setIsPreventiveMainte(0);
    boolean suc = getBeforeData(facilityCd,codeList);
    int retCnt = mntMachineStateDao.updateMachineStateByMachinesNoList(facilityCd, codeList, mntParams);
    if(retCnt > 0 && suc  ){
      List<String> filedList = Arrays.asList("process_state", "is_preventive_mainte", "up_date");
      List<Object> valueList = Arrays.asList(mntParams.getProcessState(),mntParams.getIsPreventiveMainte(),mntParams.getUpDate());
      // データ更新ログ出力
      updateLog("mnt_machine_state", filedList, valueList);
    }
    return retCnt;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateStateOnlineMachines(String facilityCd, List<Long> codeList) {
    MntMachineState mntParams = new MntMachineState();
    mntParams.setProcessState(null);
    mntParams.setIsPreventiveMainte(0);
    boolean suc = getBeforeData(facilityCd,codeList);
    int retCnt = mntMachineStateDao.updateMachineStateByMachinesNoList(facilityCd, codeList, mntParams);
    if(retCnt > 0 && suc  ){
      List<String> filedList = Arrays.asList("process_state", "is_preventive_mainte", "up_date");
      List<Object> valueList = Arrays.asList(mntParams.getProcessState(),mntParams.getIsPreventiveMainte(),mntParams.getUpDate());
      // データ更新ログ出力
      updateLog("mnt_machine_state", filedList, valueList);
    }
    return retCnt;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMachine> selectEntryMachineList(String facilityCd) {
    return mstMachineDao.selectDialysisEntryMachines(facilityCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateProcStateToDefault(String facilityCd, List<Long> codeList) {
    MntMachineState mntParams = new MntMachineState();
    mntParams.setProcessState("07");
    mntParams.setIsPreventiveMainte(0);
    boolean suc = getBeforeData(facilityCd,codeList);
    int retCnt = mntMachineStateDao.updateMachineStateByMachinesNoList(facilityCd, codeList, mntParams);
    if(retCnt > 0 && suc  ){
      List<String> filedList = Arrays.asList("process_state", "is_preventive_mainte", "up_date");
      List<Object> valueList = Arrays.asList(mntParams.getProcessState(),mntParams.getIsPreventiveMainte(),mntParams.getUpDate());
      // データ更新ログ出力
      updateLog("mnt_machine_state", filedList, valueList);
    }
    return retCnt;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public int updateMachineStatusToDefault(String facilityCd, List<Long> codeList) {
    MntMachineState mntParams = new MntMachineState();
    mntParams.setMachineStatus(0);
    mntParams.setIsPreventiveMainte(0);
    boolean suc = getBeforeData(facilityCd,codeList);
    // mod #6822「DABの表示が不正」について、対応する。 dengshen start
    // int retCnt = mntMachineStateDao.updateMachineStateByMachinesNoList(facilityCd, codeList, mntParams);
    int retCnt = mntMachineStateDao.updateMachineStateAndProcessStateByMachinesNoList(facilityCd, codeList, mntParams);
    // mod #6822「DABの表示が不正」について、対応する。 dengshen end
    if(retCnt > 0 && suc  ){
      List<String> filedList = Arrays.asList("process_state", "is_preventive_mainte", "up_date");
      List<Object> valueList = Arrays.asList(mntParams.getProcessState(),mntParams.getIsPreventiveMainte(),mntParams.getUpDate());
      // データ更新ログ出力
      updateLog("mnt_machine_state", filedList, valueList);
    }
    return retCnt;
  }

  //DB更新ログ出力ロジック wp start
  /**
   * データ更新ログ出力
   * @param tableName 更新テーブル名
   * @param filedList 更新項目リスト
   * @param valueList 更新データリスト
   */
  private void updateLog(String tableName, List<String> filedList, List<Object> valueList) {
    Map<String, Object> map = new HashMap<String, Object>();
    for (int i = 0; i < filedList.size(); i++){
      if (valueList.get(i) != null && valueList.get(i) != ""){
        map.put(filedList.get(i), valueList.get(i));
      }
    }
    // 更新テーブル
    logCommon.setTableName(tableName);
    // ログ出力サービス
    logCommon.setLogServiceCore(logServiceCore);
    // 更新コラム
    logCommon.setFieldNameMap(map);
    logCommon.setCommonEventLogMessage(getEventLogMessage());
    // データ更新ログ出力共通を呼出
    logCommon.outputDataAccessLog();
  }

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
   * 更新前のデータを取得
   * @return boolean
   */
  private boolean getBeforeData(String facilityCd , List<Long> codeList) {
    // DAO設定

    if (codeList.size() == 0 || facilityCd.equals("")){
      return  false;
    }
    String sql = getSql(facilityCd,codeList);
    logCommon.setDao(mntMachineStateDao);
    // 変更前データ取得するSQL
    logCommon.setExecuteSQL(sql);
    // 更新前データ取得
    return logCommon.getBeforeUpData();
  }

  /**
   * 検索SQL

   */
  private String getSql(String facilityCd , List<Long> codeList){

    StringBuffer code = new StringBuffer("");
    code.append(" ( ");
    for (Long no : codeList) {
      code.append( no);
      code.append(" ,");
    }
    code.deleteCharAt(code.length() - 1);
    code.append(" ) ");


    StringBuffer sql = new StringBuffer("");
    sql.append("select ");
    sql.append("     * ");
    sql.append("from  mnt_machine_state MNT ");
    sql.append(" inner join ");
    sql.append(" ( ");
    sql.append(" select ");
    sql.append("   facility_cd, ");
    sql.append("   machine_type_cd, ");
    sql.append("   machine_serial ");
    sql.append("  from  mst_machine ");
    //mod 8168 装置状態管理のログ内容について 周安寧　start
    //sql.append("  where facility_cd = " + facilityCd);
    sql.append("  where facility_cd = '" + facilityCd + "'");
    //mod 8168 装置状態管理のログ内容について 周安寧　end
    sql.append("  and machine_no in  " + code.toString() );
    sql.append(" ) MST  on ");
    sql.append("   MNT.facility_cd = MST.facility_cd ");
    sql.append("   and MNT.machine_type_cd = MST.machine_type_cd ");
    sql.append("   and MNT.machine_serial = MST.machine_serial ");


    return String.valueOf(sql);
  }

  //DB更新ログ出力ロジック wp end
  // mod #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstMachine> selectByFacility(String facilityCd){
    return mstMachineDao.selectByFacility(facilityCd);
  }
  // mod #8118 2022/12/06 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou end

  /* add by zhouyingying  2023-02-01 [Transaction] start */
  /**
   *（装置自動登録）通知指示
   * @param procMode
   * @return
   */
  @Override
  @Transactional
  public boolean notificationMstFindMachine(Integer procMode, String facilityCd){
    // 装置検索処理
    // #9626 2023.09.26 mod 通知に成功した場合にtrueを返すようにする TDC米沢 start
    // boolean res = true;
    // if(procMode.equals(1)) {
    //   mntFindMachineService.deleteByFacilityCd(facilityCd);
    // }
    // // 装置検索指示を同一施設のDEに通知
    // List<MstDeviceEdge> res_device_edge = selectDeviceEdgeByFacilityCd(facilityCd);
    // for (MstDeviceEdge mstDeviceEdge : res_device_edge) {
    //   if(mntFindMachineService.deviceSearch(facilityCd,procMode, mstDeviceEdge.getDeviceEdgeNo()) == false)
    //   {
    //     // 通知失敗
    //     res = false;
    //   }
    // }
    boolean res = false;
    if(procMode.equals(1)) {
      // 検索開始時に作業用テーブル内の指定施設コードの情報を削除
      mntFindMachineService.deleteByFacilityCd(facilityCd);
    }
    // 装置検索指示を同一施設のDEに通知
    List<MstDeviceEdge> res_device_edge = selectDeviceEdgeByFacilityCd(facilityCd);
    for (MstDeviceEdge mstDeviceEdge : res_device_edge) {
      if (mntFindMachineService.deviceSearch(facilityCd, procMode, mstDeviceEdge.getDeviceEdgeNo())) {
        // 通知成功
        res = true;
      }
    }
    // #9626 2023.09.26 mod 通知に成功した場合にtrueを返すようにする TDC米沢 end
    return res;
  }
  /* add by zhouyingying  2023-02-01 [Transaction] end */

  /* add by zhouyingying  2023-02-01 [Transaction] start */
  /**
   * 型式や通信フォーマットを切り替えた装置のステータスを初期値状態にする
   * @param request
   */
  @Override
  @Transactional
  public void updateChangeMachine(MstMachineChangeMachineRequest request){
      if (request.getNewOfflineAndCommonCodeList() != null && request.getNewOfflineAndCommonCodeList().size() > 0) {
        // 工程更新対象がない場合は何もしないで返す
        updateProcStateToDefault(request.getFacilityCd(), request.getNewOfflineAndCommonCodeList());
      }
      if (request.getChangeMachineCodeList() != null && request.getChangeMachineCodeList().size() > 0) {
        // 主キー更新対象がない場合は何もしないで返す
        updateMachineStatusToDefault(request.getFacilityCd(), request.getChangeMachineCodeList());
      }
  }
  /* add by zhouyingying  2023-02-01 [Transaction] end */

  /* add by zhouyingying  2023-02-01 [Transaction] start */
  /**
   * オンラインからオフライン装置に切り替えられた装置のステータスを準備状態にする
   * @param request
   */
  @Override
  @Transactional
  public void updateStateOffline(MstMachineSwitchOfflineRequest request){
      if (request.getNewOfflineCodeList() != null && request.getNewOfflineCodeList().size() > 0) {
        // オフライン更新対象がない場合は何もしないで返す
        updateStateOfflineMachines(request.getFacilityCd(), request.getNewOfflineCodeList());
      }
      if (request.getNewOnlineCodeList() != null && request.getNewOnlineCodeList().size() > 0) {
        // オンライン更新対象がない場合は何もしないで返す
        updateStateOnlineMachines(request.getFacilityCd(), request.getNewOnlineCodeList());
      }
  }
  /* add by zhouyingying  2023-02-01 [Transaction] end */

  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
  /**
   * 該当施設からΔSO2を使用する装置件数を取得
   *
   * @param facilityCd 施設コード
   * @return ΔSO2を使用する装置件数
   */
  @Override
  public Long getMachineSo2OptCount(String facilityCd) {
    return mstMachineDao.selectByFacilitySo2Count(facilityCd);
  }
  // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
}
