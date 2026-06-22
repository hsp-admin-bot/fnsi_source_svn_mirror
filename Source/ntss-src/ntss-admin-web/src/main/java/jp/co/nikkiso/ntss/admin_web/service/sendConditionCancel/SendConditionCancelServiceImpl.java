package jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.WebApiProperties;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.OrdMainConst.DialysisState;
import jp.co.nikkiso.ntss.admin_web.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.OrdMainService;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.web.rest.OrdMainResource;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.rstDialysisState;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatIndApproveDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatIndApprove;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForWeightInd;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.HttpServerErrorException;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end


@Component
@Slf4j
public class SendConditionCancelServiceImpl implements SendConditionCancelService {
  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  @Autowired
  private WebApiProperties myPropaties;

  @Autowired
  MstMachineDao mstMachineDao;

  @Autowired
  MntMachineStateDao mntMachineStateDao;

  @Autowired
  PatMainDao patMainDao;

  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  MntMotionRecordDao mntMotionRecordDao;

  @Autowired
  MniMonitorDao mniMonitorDao;

  @Autowired
  OrdMainService ordMainService;

  //add FNSI改修401対応 房 start
  @Autowired
  OrdChecklistDao ordChecklistDao;
  //add FNSI改修401対応 房 end
  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;
  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private TriggerUtil triggerUtil;


  // Add #10196 Update materilaSave record when ordMain updated.
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;

  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
  @Autowired
  private PatIndApproveDao patIndApproveDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse doCancel(String facilityCd, Long bedCd, Long baseOrdNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    // 条件から装置情報を取得
    List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, bedCd);
    if (machines.size() == 0) {
      res.isSuccess = false;
      res.errorMessage = "対象装置なし";
      res.exMessage = "装置の特定に失敗";
      return res;
    }
    MstMachine machine = machines.get(0);
    ComsvMntMachineState machineState = mntMachineStateDao.selectMachineKey(facilityCd,
        machine.getMachineTypeCd(), machine.getMachineSerial());
    // 条件送信済みオーダー番号
    Long ordNo = machineState.getOrdNo();

    return doCancel(machine, ordNo, baseOrdNo);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse doCancel(String facilityCd, Long bedCd) {
    return doCancel(facilityCd, bedCd, null);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse doCancel(MstMachine machine, Long targetOrdNo, Long baseOrdNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    if (targetOrdNo == null) {
      // 条件送信済みデータなし
      res.isSuccess = true;
      return res;
    } else if (targetOrdNo.equals(baseOrdNo)) {
      // 条件送信済みデータが非キャンセル対象
      res.isSuccess = true;
      return res;
    }
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(targetOrdNo);
    if (ord == null || DialysisState.BEFORE_SEND.equals(ord.getRstDialysisState())) {
      // 条件送信済みデータなし
      res.isSuccess = true;
      // return res;
    } else if (!(DialysisState.AFTER_SEND.equals(ord.getRstDialysisState()) || DialysisState.CHECKED_SEND.equals(ord.getRstDialysisState()))) {
      // 条件送信済みまたは条件送信確認済み でない＝治療中以降の状態
      res.isSuccess = false;
      res.exMessage = "治療開始済みなので条件キャンセルできません";
      res.errorMessage = "治療開始済み";
      return res;
    }

    try {
      // 自前処理
      res = DoCancelDBAction(targetOrdNo, machine);
      if (res.isSuccess == false) {
        return res;
      }
      res.isSuccess = true;
    } catch (Exception ex) {
      res.isSuccess = false;
      res.exMessage = "条件送信キャンセル失敗\n" + ex.getMessage();
      res.errorMessage = "条件送信キャンセル失敗";
    }

    // bug 5628 修正 chen start
    boolean mntMachineflag = false;
    List<MntMachineState> mntMachineStates = mntMachineStateDao.selectByOrdNo(ord.getFacilityCd(), baseOrdNo);
    if (mntMachineStates != null && mntMachineStates.size() > 0) {
      if (mntMachineStates.get(0).getProcessState() != null && mntMachineStates.get(0).getProcessState().equals("99")) {
        mntMachineflag = true;
      }
    }
    if (mntMachineflag) {
      return res;
    }
    // bug 5628 修正 chen end
    // 外部API呼び出し
    res = DoCancelCallWebApi(machine);
    if (res.isSuccess == false) {
      return res;
    }
    return res;
  }

  // bug 5628 修正 chen start
  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse doCancel(MstMachine machine, Long targetOrdNo, Long baseOrdNo, Long mntMachineOrdNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    if (targetOrdNo == null) {
      // 条件送信済みデータなし
      res.isSuccess = true;
      return res;
    } else if (targetOrdNo.equals(baseOrdNo)) {
      // 条件送信済みデータが非キャンセル対象
      res.isSuccess = true;
      return res;
    }
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(targetOrdNo);
    if (ord == null || DialysisState.BEFORE_SEND.equals(ord.getRstDialysisState())) {
      // 条件送信済みデータなし
      res.isSuccess = true;
      // return res;
    } else if (!(DialysisState.AFTER_SEND.equals(ord.getRstDialysisState()) || DialysisState.CHECKED_SEND.equals(ord.getRstDialysisState()))) {
      // 条件送信済みまたは条件送信確認済み でない＝治療中以降の状態
      res.isSuccess = false;
      res.exMessage = "治療開始済みなので条件キャンセルできません";
      res.errorMessage = "治療開始済み";
      return res;
    }

    try {
      // 自前処理
      res = DoCancelDBAction(targetOrdNo, machine);
      if (res.isSuccess == false) {
        return res;
      }
      res.isSuccess = true;
    } catch (Exception ex) {
      res.isSuccess = false;
      res.exMessage = "条件送信キャンセル失敗\n" + ex.getMessage();
      res.errorMessage = "条件送信キャンセル失敗";
    }

    boolean mntMachineflag = false;
    List<MntMachineState> mntMachineStates = mntMachineStateDao.selectByOrdNo(ord.getFacilityCd(), mntMachineOrdNo);
    if (mntMachineStates != null && mntMachineStates.size() > 0) {
      if (mntMachineStates.get(0).getProcessState() != null && mntMachineStates.get(0).getProcessState().equals("99")) {
        mntMachineflag = true;
      }
    }
    if (mntMachineflag) {
      return res;
    }
    // 外部API呼び出し
    res = DoCancelCallWebApi(machine);
    if (res.isSuccess == false) {
      return res;
    }
    return res;
  }
  // bug 5628 修正 chen end

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse doCancel(MstMachine machine, Long targetOrdNo) {
    return doCancel(machine, targetOrdNo, null);
  }

  public SendConditionCancelResponse DoCancelCallWebApi(MstMachine machine) {
    return resetMachineStateNextPat(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial());
  }

  @Transactional
  public SendConditionCancelResponse DoCancelDBAction(Long ordNo, MstMachine machine) {
    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      // 1 pat_mainの更新
      Long patId = ordMainDao.selectPatIdByOrdNo(ordNo);
      if (patId != null) {
        res = resetPatMain(patId, ordNo);
        if (res.isSuccess == false) {
          return res;
        }
      }

      // 2 ord_mainの更新
      //    条件送信開始日時を削除＋ステータスを条件送信前に書き換える
      //    それ以外の実績は残す
      //    ind_dwも消す
      res = resetOrdMain(ordNo);
      if (res.isSuccess == false) {
        return res;
      }

      // 3 mnt_motion_recordの装置記録のorder_noを削除
      res = resetMotionRecord(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
      if (res.isSuccess == false) {
        return res;
      }

      // 4 mni_monitorのorder_noを削除
      //    血圧・体温・血糖値などはorder_no振替後にも引き継ぐ
      res = resetMniMonitor(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
      if (res.isSuccess == false) {
        return res;
      }
      // 5 チェックリストのデータを削除
      res = resetCheckList(ordNo);
      if (res.isSuccess == false) {
        return res;
      }
    	// 6 mnt_machine_stateのorder_noを削除(現患者削除)
      res = resetMachineState(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
      if (res.isSuccess == false) {
        return res;
      }
      // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
      // 7 pat_ind_approveの更新
      List <Long> ordNos = new ArrayList();
      ordNos.add(ordNo);
      res = this.resetPatIndApprove(ordNos);
      if (res.isSuccess == false) {
        return res;
      }
      // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetPatMain(Long patId, Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      if (patMainAcceptanceStatusInfoService.update(patId, ordNo, rstDialysisState.BEFORE_SEND_CONDITIOM, null, null) > 0) {
        res.isSuccess = true;

      } else {
        res.isSuccess = false;
        res.errorMessage = "患者治療状況初期化失敗";
      }
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "患者治療状況初期化失敗\n" + e.getMessage();
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetOrdMain(Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {

      // add FNSI-改修内容追加OrdMain履歴 付 start
      getHistory(ordNo);
      // mangoDb-updateCancelSendCondition-insertSuccess
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
      //add #10412 次患者更新関連全体見直し対応 朴 start
      if(oldOrdMain == null){
        res.isSuccess = true;
        return res;
      }
      //add #10412 次患者更新関連全体見直し対応 朴 end
      /* add by chamaojia 2024-01-22 [10196] When the data is restored to [rst_dialys_state='0'] --start */
      OrdMain updateOrdMain = new OrdMain();
      updateOrdMain.setOrdNo(ordNo);

      String[] mediAndEquipDeleteKeys = {"class_cd", "class_name",
              "class_type", "name", "short_name", "unit"};
      // 指示：投与薬剤情報
      if (oldOrdMain.getIndMediInfo() != null && !"[]".equals(oldOrdMain.getIndMediInfo())) {
        JSONArray indMediInfoArray = new JSONArray(oldOrdMain.getIndMediInfo());
        for (int i = 0; i < indMediInfoArray.length(); i++) {
          JSONObject indMediInfo = indMediInfoArray.getJSONObject(i);
          for (String deleteKey : mediAndEquipDeleteKeys) {
            indMediInfo.remove(deleteKey);
          }
          indMediInfo.remove("timing_name");
          indMediInfo.remove("procedure_name");
        }
        updateOrdMain.setIndMediInfo(indMediInfoArray.toString());
      } else {
        updateOrdMain.setIndMediInfo(null);
      }

      // 指示：医療材料情報
      if (oldOrdMain.getIndEquipInfo() != null && !"[]".equals(oldOrdMain.getIndEquipInfo())) {
        JSONArray indEquipInfoArray = new JSONArray(oldOrdMain.getIndEquipInfo());
        for (int i = 0; i < indEquipInfoArray.length(); i++) {
          JSONObject indEquipInfo = indEquipInfoArray.getJSONObject(i);
          for (String deleteKey : mediAndEquipDeleteKeys) {
            indEquipInfo.remove(deleteKey);
          }
        }
        updateOrdMain.setIndEquipInfo(indEquipInfoArray.toString());
      } else {
        updateOrdMain.setIndEquipInfo(null);
      }

      // 指示：治療条件情報
      if (oldOrdMain.getIndCondInfo() != null) {
        JSONObject indCondInfo = new JSONObject(oldOrdMain.getIndCondInfo());
//        indCondInfo.remove(TreatmentItemsDef.T_I_DW.getItemCode());
        for (String indCondKey : indCondInfo.keySet()) {
          JSONObject item = (JSONObject)indCondInfo.get(indCondKey);
          item.remove("unit");
          item.remove("value_name_1");
          // "5:ダイアライザ" exist 'value_name_2'
          if ("5".equals(indCondKey)) {
            item.remove("value_name_2");
          }
        }
        updateOrdMain.setIndCondInfo(indCondInfo.toString());
      }
      /* add by chamaojia 2024-01-22 [10196] When the data is restored to [rst_dialys_state='0'] --end */

      int updateCount = ordMainDao.updateCancelSendCondition(updateOrdMain, new Timestamp(System.currentTimeMillis()));
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));
      // 10196 update materialSave record
      // mod #12250 ord_material_saveの処理を2回重複実行している zkm start
//      ordMaterialSaveService.cancelSendCondition(ordNo);
      ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquipTreatment(Collections.singletonList(ordNo));
      // mod #12250 ord_material_saveの処理を2回重複実行している zkm end

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      if (updateCount >= 0) {

        res.isSuccess = true;

      } else {
        res.isSuccess = false;
        res.errorMessage = "治療状況初期化失敗";
      }
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "治療状況初期化失敗\n" + e.getMessage();
    }
    return res;
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo){
    selectHistoryUtils.insertMangoDbHistory(1, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetMachineStateNextPat(String facilityCd, String machineTypeCd,
      String machineSerial) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      String baseApiPath = myPropaties.getWebApi().getSetNextPat();

      res = callWebApi(facilityCd, machineTypeCd, machineSerial, baseApiPath);
    } catch (Exception e) {
      res.isSuccess = false;
      res.exMessage = "次患者更新失敗\n" + e.getMessage();
      res.errorMessage = "次患者更新失敗";
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse currentPatClear(String facilityCd, String machineTypeCd,
      String machineSerial) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();

    // add ログ改善対応 劉 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    // add ログ改善対応 劉 end
    try {
      String baseApiPath = myPropaties.getWebApi().getCurrentPatClear();

      res = callWebApi(facilityCd, machineTypeCd, machineSerial, baseApiPath);
      if (!res.isSuccess) {
        res.exMessage = "現患者クリア失敗\n" + res.exMessage;
        res.errorMessage = "現患者クリア失敗";
        // add ログ改善対応 劉 start
        eventLogMessage.setLogMessage("現患者クリア失敗 method:[ callWebApi ]");
        // add ログ改善対応 劉 end
      }
    } catch (Exception e) {
      res.isSuccess = false;
      res.ex = e;
      res.exMessage = "現患者クリア失敗\n" + e.getMessage();
      res.errorMessage = "現患者クリア失敗";
      // add ログ改善対応 劉 start
      eventLogMessage.setLogMessage("現患者クリア失敗 method:[ catch ]");
      // add ログ改善対応 劉 end
    }
    // add ログ改善対応 劉 start
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // add ログ改善対応 劉 end
    return res;
  }

  @AllArgsConstructor
  @SuppressWarnings("unused")
  private class webApiPayload {
    public String facility_cd;
    public String machine_type_cd;
    public String machine_serial;
  }

  /**
   * WebApi側のREST APIを呼び出す処理
   * @param facilityCd 施設コード
   * @param machineTypeCd 装置種別
   * @param machineSerial 装置シリアル
   * @param baseApiPath 呼び出しAPIの非共通部
   * @return
   * @throws URISyntaxException
   * @throws IOException
   */
  private SendConditionCancelResponse callWebApi(String facilityCd, String machineTypeCd,
      String machineSerial, String baseApiPath) throws URISyntaxException, IOException {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    // 送信URI
    String baseUri = myPropaties.getWebApi().getUrl();
    String api;
    if (baseUri.endsWith("/")) {
      // baseUriが / で終わる場合、/が連続しないようにする
      if (baseApiPath.startsWith("/")) {
        api = baseUri + baseApiPath.substring(1);
      } else {
        api = baseUri + baseApiPath;
      }
    } else {
      // baseUriが / で終わらない場合、/が抜けないようにする
      if (baseApiPath.startsWith("/")) {
        api = baseUri + baseApiPath;
      } else {
        api = baseUri + "/" + baseApiPath;
      }
    }
    URI uri = new URI(api);
    RestTemplate restTemplate = new RestTemplate();

    // body作成
    webApiPayload json = new webApiPayload(facilityCd, machineTypeCd, machineSerial);

    // リクエスト作成
    RequestEntity<webApiPayload> requestEntity = RequestEntity
        .post(uri)
        .contentType(MediaType.APPLICATION_JSON)
        .header(myPropaties.getWebApi().getHeaderName(), myPropaties.getWebApi().getHeaderValue())
        .body(json);

    try {
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // API呼び出し
      ResponseEntity<Object> response = restTemplate.exchange(requestEntity, Object.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.service.sendConditionCancel.SendConditionCancelServiceImpl");
      map.put("methodName", "callWebApi");
      map.put("method", requestEntity.getMethod());
      map.put("url", uri.getPath());
      map.put("headers", requestEntity.getHeaders());
      map.put("requestParameter", requestEntity.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      if (response.getStatusCode() == HttpStatus.OK) {
        res.isSuccess = true;
      } else {
        // APIエラー
        res.isSuccess = false;
        if (response.hasBody() && response.getBody() != null) {
          res = getApiErrorMessage(res, response.getBody(), HttpStatus.OK);
        }
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        res.exMessage = baseApiPath + "\n" + res.exMessage;
      }
    } catch(HttpServerErrorException e) {
      // API呼び出しエラー 5xx
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(baseApiPath + "API呼び出しエラー = " + e.getStatusCode());
      logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_SEND_CONDITION,SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = "内部エラー";
      res.exMessage = "API呼び出しエラー = " + e.getStatusCode();
      res = getApiErrorMessage(res, e.getResponseBodyAsString(), HttpStatus.OK);
    } catch(HttpClientErrorException e) {
      // API呼び出しエラー 4xx
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(baseApiPath + "API呼び出しエラー = " + e.getStatusCode());
      logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_SEND_CONDITION,SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = "内部エラー";
      res.exMessage = "API呼び出しエラー = " + e.getStatusCode();
      res = getApiErrorMessage(res, e.getResponseBodyAsString(), HttpStatus.OK);
    } catch(Exception e) {
      // API呼び出しエラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(baseApiPath + "API呼び出しエラー = " + e.getMessage());
      logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_SEND_CONDITION,SERVICE_NAME.REMS, null);
      res.isSuccess = false;
      res.errorMessage = "内部エラー";
      res.exMessage = "エラー要因特定失敗 = " + e.getMessage();
    }
    return res;
  }
  /**
   * YED製APIからエラーメッセージを取得
   * @param res
   * @return
   */
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
  private SendConditionCancelResponse getApiErrorMessage(SendConditionCancelResponse res, Object responseBody, HttpStatus httpStatus) {
    if (responseBody != null ) {
      try {
        JsonNode node = mapper.valueToTree(responseBody);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        res.errorMessage = node.get("retMsg").asText("");
        if (Objects.equals(res.errorMessage, "null")) {
          res.exMessage = "API内部エラー";
          res.errorMessage = "内部エラー";
        }
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("外部API返り値エラー:" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_SEND_CONDITION,SERVICE_NAME.REMS, null);
        res.exMessage = "外部API返り値エラー:" + e.getMessage();
        res.errorMessage = "処理エラー";
      }
      if (httpStatus != null && httpStatus != HttpStatus.OK) {
        res.exMessage += "(HTTP " + httpStatus + ")";
      }
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetMotionRecord(String facilityCd, String machineTypeCd, String machineSerial,
      Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {

      //DB更新ログ出力ロジック wp start

      String tableName = "mnt_motion_record";

      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" facility_cd = '" + facilityCd + "'" +"\n");
      wheres.append(" AND\n");
      wheres.append(" machine_type_cd = '" + machineTypeCd + "'" +"\n");
      wheres.append(" AND\n");
      wheres.append(" trim(machine_serial) = trim('" + machineSerial  + "')" +"\n");
      wheres.append(" AND\n");
      wheres.append(" ord_no = " + ordNo  + "\n");
      // logCommon設定
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      //DB更新ログ出力ロジック wp end
      /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
      int ret = 0;
      if(setResult){
        ret = mntMotionRecordDao.updateClearOrdNo(facilityCd, machineTypeCd, machineSerial, ordNo,
                new Timestamp(System.currentTimeMillis()));
      }
      /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */
      //DB更新ログ出力ロジック wp start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && ret > 0) {
        logCommon.updateLog();
      }
      //DB更新ログ出力ロジック wp end 20210128
      res.isSuccess = true;

    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "装置記録情報削除失敗\n" + e.getMessage();
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetMniMonitor(String facilityCd, String machineTypeCd, String machineSerial,
      Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "mni_monitor";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" ord_no = " + ordNo + "\n");
      wheres.append(" AND\n");
      wheres.append(" data_type = 1" + "\n");

      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End
      /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
      int updateCount = 0;
      if(setResult){
        updateCount = mniMonitorDao.updateClearOrdNo(ordNo, new Timestamp(System.currentTimeMillis()));
      }
      /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      res.isSuccess = true;

    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "モニタデータ情報削除失敗\n" + e.getMessage();
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetCheckList(Long ordNo) {
    SendConditionCancelResponse res = new SendConditionCancelResponse();
    //del 9324 既存のコード論理エラーのため削除 gjn start
    try {
//      // DB更新ログ出力ロジック wangzuo Start
//      String tableName = "ord_checklist";
//      // SQL検索条件
//      StringBuffer wheres = new StringBuffer("");
//      wheres.append(" WHERE\n");
//      wheres.append(" ord_no = " + ordNo + "\n");
//      wheres.append(" AND\n");
//      wheres.append(" is_del = '0'\n");
//      wheres.append(" AND\n");
//      wheres.append(" is_disp = '1'\n");
//      // logCommon設定
//      DataUpdateLogCommonNew logCommon = getLogCommon(ordChecklistDao, tableName, wheres, getEventLogMessage());
//      // ログ出力カラム情報及び更新前データ情報取得
//      boolean setResult = logCommon.setInfo();
//      // DB更新ログ出力ロジック wangzuo End
//      /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
//      int updateCount = 0;
//      if(setResult){
//        updateCount = ordChecklistDao.updateClearOrdNo(ordNo, new Timestamp(System.currentTimeMillis()));
//      }
//      /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */
//      // DB更新ログ出力ロジック wangzuo Start
//      // 更新後データ取得、差分あれば、log出力
//      if (setResult && updateCount > 0) {
//        logCommon.updateLog();
//      }
//      // DB更新ログ出力ロジック wangzuo End
      //del 9324 既存のコード論理エラーのため削除 gjn end

      //add 9324 条件送信キャンセル処理ord_checklist共通メソッドの実行 gjn start
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);
      //治療記録の削除按照条件送信キャンセル処理逻辑
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.CONDITION_DO_CANCEL, ordNoList);
      //add 9324 条件送信キャンセル処理ord_checklist共通メソッドの実行 gjn end
      res.isSuccess = true;
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "条件送信キャンセル処理ord_checklist共通メソッドの実行失敗\n" + e.getMessage();
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetMachineState(String facilityCd, String machineTypeCd, String machineSerial, Long ordNo) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "mnt_machine_state";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" facility_cd = '" + facilityCd + "'\n");
      wheres.append(" AND\n");
      wheres.append(" machine_type_cd = '" + machineTypeCd + "'\n");
      wheres.append(" AND\n");
      wheres.append(" trim(machine_serial) = '" + machineSerial + "'\n");
      wheres.append(" AND\n");
      wheres.append(" ord_no = " + ordNo + "\n");

      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End
      /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --start */
      int updateCount = 0;
      if(setResult){
        updateCount = mntMachineStateDao.updateClearOrdNo(facilityCd, machineTypeCd, machineSerial, ordNo,
                new Timestamp(System.currentTimeMillis()));
        // ＃10889 2024.09.13 add オフラインフラグ初期化 TDC片口 start
        if (updateCount > 0) {
          // 現患者が一致して条件送信キャンセルで初期化されたmnt_machine_stateがある場合、is_offlineを初期化する
          mntMachineStateDao.updateIsOfflineInitialize(facilityCd, machineTypeCd, machineSerial);
        }
        // ＃10847 2024.09.13 add オフラインフラグ初期化 TDC片口 end
      }
      /* modify by shiyw 2023-03-25 [#8101] 患者経過総合応答速度の最適化です --end */
      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      res.isSuccess = true;

    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "装置状態削除失敗\n" + e.getMessage();
    }
    return res;
  }
  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
  @Override
  public SendConditionCancelResponse resetPatIndApprove(List<Long> ordNos) {
    SendConditionCancelResponse res = new SendConditionCancelResponse();
    res.isSuccess = true;

    try {
      List<PatIndApprove> patIndApproves = patIndApproveDao.selectPatIndApproveByOrdNos(ordNos);

      if (patIndApproves.isEmpty()) {
        return res;
      }
      List<PatIndApprove> updatedPatIndApproves = new ArrayList<>();

      for (PatIndApprove patIndApprove : patIndApproves) {
        try {
          String checkContent = patIndApprove.getCheck_content();
          String approveContent = patIndApprove.getApprove_content();

          if (isValidContent(checkContent)) {
            patIndApprove.setCheck_content(processJsonData(checkContent));
          }
          if (isValidContent(approveContent)) {
            patIndApprove.setApprove_content(processJsonData(approveContent));
          }

          patIndApprove.setContent_for_map(null);

          updatedPatIndApproves.add(patIndApprove);
        } catch (Exception e) {
          res.isSuccess = false;
          res.errorMessage += "注文番号 " + patIndApprove.getOrd_no() + " の処理に失敗しました: " + e.getMessage() + "\n";
          log.error("注文番号 {} の指示受け承認情報リセット失敗", patIndApprove.getOrd_no(), e);
        }
      }
      if (!updatedPatIndApproves.isEmpty()) {
        try {
          patIndApproveDao.updateContentAndMapBatch(updatedPatIndApproves);
        } catch (Exception e) {
          res.isSuccess = false;
          res.errorMessage += "バッチ更新に失敗しました: " + e.getMessage() + "\n";
          log.error("バッチ更新に失敗しました", e);
        }
      }
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "指示受け承認情報リセット失敗: " + e.getMessage();
      log.error("指示受け承認情報リセット中にエラーが発生しました", e);
    }

    return res;
  }
  private boolean isValidContent(String content) {
    return StringUtils.hasText(content) && !"{}".equals(content);
  }
  public String processJsonData(String josnData) {
    JSONArray jsonArray = new JSONArray(josnData);

    for (int i = 0; i < jsonArray.length(); i++) {
      JSONObject item = jsonArray.getJSONObject(i);
      int subCategoryNo = item.getInt("subCategoryNo");

      switch (subCategoryNo) {
        case 2: {
          JSONObject itemInfo = item.optJSONObject("itemInfo");
          boolean hasItemCd = itemInfo != null &&  (itemInfo.has("itemCd") && !"null".equals(itemInfo.get("itemCd").toString()));
          setNullForValues(item, true, !hasItemCd);
          break;
        }
        case 3: {
          JSONArray subCategoryItemArray = item.optJSONArray("subCategoryItem");
          if (subCategoryItemArray != null) {
            for (int j = 0; j < subCategoryItemArray.length(); j++) {
              JSONObject subItem = subCategoryItemArray.getJSONObject(j);
              JSONObject itemInfo = subItem.optJSONObject("itemInfo");
              int itemNo = (itemInfo != null) ? itemInfo.optInt("itemNo", -1) : -1;

              if (itemNo == 1 || itemNo == 3) {
                boolean hasItemCd = itemInfo != null && (itemInfo.has("itemCd") && !"null".equals(itemInfo.get("itemCd")));
                setNullForValues(subItem, true, !hasItemCd);
              }
            }
          }
          break;
        }
        case 4:
        case 5:
        case 6: {
          JSONArray subCategoryItemArray = item.optJSONArray("subCategoryItem");
          if (subCategoryItemArray != null) {
            for (int j = 0; j < subCategoryItemArray.length(); j++) {
              JSONObject subItem = subCategoryItemArray.getJSONObject(j);
              JSONObject itemInfo = subItem.optJSONObject("itemInfo");
              int itemNo = (itemInfo != null) ? itemInfo.optInt("itemNo", -1) : -1;

              if (subCategoryNo == 4) {
                // subCategoryNo=4のみを扱う特殊なケース
                if (Arrays.asList(2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 19, 25).contains(itemNo)) {
                  boolean hasItemCd = itemInfo != null && (itemInfo.has("itemCd") && !"null".equals(itemInfo.get("itemCd").toString()));
                  setNullForValues(subItem, true, !hasItemCd);
                } else {
                  setNullForValues(subItem, false, false);
                }
              } else {
                // subCategoryNo=5、6を処理し、dispValを修正しない
                setNullForValues(subItem, false, false);
              }
            }
          }
          break;
        }
        default:
          break;
      }
    }
    return jsonArray.toString();
  }
  private void setNullForValues(JSONObject item, boolean updateDispVal, boolean updateDispValNot) {
    JSONObject itemInfo = item.getJSONObject("itemInfo");
    JSONObject data = itemInfo.getJSONObject("data");
    JSONObject value = data.getJSONObject("value");

    value.put("unit", JSONObject.NULL);
    value.put("prefix", JSONObject.NULL);

    if (updateDispVal) {
      value.put("dispVal", updateDispValNot ? "未登録" : JSONObject.NULL);
    }
  }
  // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

  //add FNSI改修401対応 房 start
  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse doCancel(MstMachine machine, Long targetOrdNo, Long baseOrdNo, String flag) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    //mod FNSI-redmine6215 fang start
//    if (targetOrdNo == null) {
//      // 条件送信済みデータなし
//      res.isSuccess = true;
//      return res;
//    } else if (targetOrdNo.equals(baseOrdNo)) {
//      // 条件送信済みデータが非キャンセル対象
//      res.isSuccess = true;
//      return res;
//    }
    if (flag == null || !flag.equals("1")) {
      if (targetOrdNo != null && targetOrdNo.equals(baseOrdNo)) {
        // 条件送信済みデータが非キャンセル対象
        res.isSuccess = true;
        return res;
      }
    }
    //mod FNSI-redmine6215 fang end
    //add FNSI-redmine6215 fang start
    boolean mntMachineStateFlg = true;
    if (flag != null && "1".equals(flag)) {
      if (targetOrdNo == null || !targetOrdNo.equals(baseOrdNo)) {
        targetOrdNo = baseOrdNo;
        mntMachineStateFlg = false;
      }
    }
    //add FNSI-redmine6215 fang end
    OrdMainForWeightInd ord = ordMainDao.selectForWeightIndByOrdNo(targetOrdNo);
    if (ord == null || DialysisState.BEFORE_SEND.equals(ord.getRstDialysisState())) {
      // 条件送信済みデータなし
      res.isSuccess = true;
      // return res;
    } else if (!(DialysisState.AFTER_SEND.equals(ord.getRstDialysisState()) || DialysisState.CHECKED_SEND.equals(ord.getRstDialysisState()))) {
      // 条件送信済みまたは条件送信確認済み でない＝治療中以降の状態
      res.isSuccess = false;
      res.exMessage = "治療開始済みなので条件キャンセルできません";
      res.errorMessage = "治療開始済み";
      return res;
    }

    try {
      // 自前処理
      res = DoCancelDBAction(targetOrdNo, machine, flag, mntMachineStateFlg);
      if (res.isSuccess == false) {
        return res;
      }
      res.isSuccess = true;
    } catch (Exception ex) {
      res.isSuccess = false;
      res.exMessage = "条件送信キャンセル失敗\n" + ex.getMessage();
      res.errorMessage = "条件送信キャンセル失敗";
    }

    if (!mntMachineStateFlg) {
      res.isSuccess = false;
      res.exMessage = "sendSkip";
      res.errorMessage = "sendSkip";
      return res;
    }

    // bug 5628 修正 chen start
    boolean mntMachineflag = false;
    List<MntMachineState> mntMachineStates = mntMachineStateDao.selectByOrdNo(ord.getFacilityCd(), baseOrdNo);
    if (mntMachineStates != null && mntMachineStates.size() > 0) {
      if (mntMachineStates.get(0).getProcessState() != null && mntMachineStates.get(0).getProcessState().equals("99")) {
        mntMachineflag = true;
      }
    }
    if (mntMachineflag) {
      return res;
    }
    // bug 5628 修正 chen end
    // 外部API呼び出し
    res = DoCancelCallWebApi(machine);
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse doCancel(String facilityCd, Long bedCd, Long baseOrdNo, String flag) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    // 条件から装置情報を取得
    List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, bedCd);
    if (machines.size() == 0) {
      res.isSuccess = false;
      res.errorMessage = "対象装置なし";
      res.exMessage = "装置の特定に失敗";
      return res;
    }
    MstMachine machine = machines.get(0);
    ComsvMntMachineState machineState = mntMachineStateDao.selectMachineKey(facilityCd,
      machine.getMachineTypeCd(), machine.getMachineSerial());
    // 条件送信済みオーダー番号
    Long ordNo = machineState.getOrdNo();

    return doCancel(machine, ordNo, baseOrdNo, flag);

  }
  //del #10412 次患者更新関連全体見直し対応 朴 start
//  // add #10132 時間外加算処理不正 dengshen start
//  /**
//   * 条件送信キャンセル（キャンセル対象が対象オーダー番号と一致する場合はキャンセルしない）
//   * @param facilityCd 施設コード
//   * @param bedCd 対象ベッドコード
//   * @param baseOrdNo キャンセルしないオーダー番号
//   * @param flag 改修フラグ
//   * @return
//   */
//  @Override
//  public SendConditionCancelResponse cancelSendMessage(String facilityCd, Long bedCd, Long baseOrdNo, String flag) {
//
//    SendConditionCancelResponse res = new SendConditionCancelResponse();
//    // 条件から装置情報を取得
//    List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, bedCd);
//    if (machines.size() == 0) {
//      res.isSuccess = false;
//      res.errorMessage = "対象装置なし";
//      res.exMessage = "装置の特定に失敗";
//      return res;
//    }
//    MstMachine machine = machines.get(0);
//    ComsvMntMachineState machineState = mntMachineStateDao.selectMachineKey(facilityCd,
//      machine.getMachineTypeCd(), machine.getMachineSerial());
//    // 条件送信済みオーダー番号
//    Long ordNo = machineState.getOrdNo();
//
//    res = doCancel(machine, ordNo, baseOrdNo, flag);
//
//    ordMainDao.updateAdditionInfoById(ordNo, "[]");
//
//    return res;
//
//  }
//  // add #10132 時間外加算処理不正 dengshen end
  //del #10412 次患者更新関連全体見直し対応 朴 end

  @Transactional
  public SendConditionCancelResponse DoCancelDBAction(Long ordNo, MstMachine machine, String flag) {
    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      // 1 pat_mainの更新
      Long patId = ordMainDao.selectPatIdByOrdNo(ordNo);
      if (patId != null) {
        res = resetPatMain(patId, ordNo);
        if (res.isSuccess == false) {
          return res;
        }
      }

      // 2 ord_mainの更新
      //    条件送信開始日時を削除＋ステータスを条件送信前に書き換える
      //    それ以外の実績は残す
      //    ind_dwも消す
      res = resetOrdMain(ordNo);
      if (res.isSuccess == false) {
        return res;
      }

      // 3 mnt_motion_recordの装置記録のorder_noを削除
      res = resetMotionRecord(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
      if (res.isSuccess == false) {
        return res;
      }

      // 4 mni_monitorのorder_noを削除
      //    血圧・体温・血糖値などはorder_no振替後にも引き継ぐ
      res = resetMniMonitor(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
      if (res.isSuccess == false) {
        return res;
      }
      // 5 チェックリストのデータを削除
      res = resetCheckList(ordNo, machine.getFacilityCd(), flag);
      if (res.isSuccess == false) {
        return res;
      }
      // 6 mnt_machine_stateのorder_noを削除(現患者削除)
      res = resetMachineState(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
      if (res.isSuccess == false) {
        return res;
      }
    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse resetCheckList(Long ordNo, String facilityCd, String flag) {

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      //del 9324 既存のコード論理エラーのため削除 gjn start
//      if ("1".equals(flag)) {
//        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
//        if (DialysisState.AFTER_SEND.equals(ordMain.getRstDialysisState())
//          || DialysisState.CHECKED_SEND.equals(ordMain.getRstDialysisState())) {
//          List<OrdChecklist> ordChecklists = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);
//          ordChecklists.stream().forEach(element->{
//            if ("1".equals(element.getIsCheck())) {
//              element.setRstClass((short) 0);
//              // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
//              LogEventUtils.setOperatorId(element);
//              // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
//              ordChecklistDao.update(element);
//            } else {
//              ordChecklistDao.deleteByOrdNo(ordNo, facilityCd);
//            }
//          });
//        }
//      } else if ("2".equals(flag)) {
//        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
//        if (DialysisState.AFTER_SEND.equals(ordMain.getRstDialysisState())
//          || DialysisState.CHECKED_SEND.equals(ordMain.getRstDialysisState())) {
//          ordChecklistDao.deleteByOrdNo(ordNo, facilityCd);
//        }
//      }
      //del 9324 既存のコード論理エラーのため削除 gjn end

      //add 9324 条件送信キャンセル処理ord_checklist共通メソッドの実行 gjn start
      List<Long> ordNoList = new ArrayList<>();
      ordNoList.add(ordNo);
      //治療記録の削除按照条件送信キャンセル処理逻辑
      ordMainService.updateOrdChecklistByActionBeCurrent(OrdMainResource.OrdMainActionForChecklist.CONDITION_DO_CANCEL, ordNoList);
      //add 9324 条件送信キャンセル処理ord_checklist共通メソッドの実行 gjn end

      res.isSuccess = true;
    } catch (Exception e) {
      res.isSuccess = false;
      res.errorMessage = "条件送信キャンセル処理ord_checklist共通メソッドの実行失敗\n" + e.getMessage();
    }
    return res;
  }
  //add FNSI改修401対応 房 start

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
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
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

  //add FNSI-redmine6215 fang start
  @Transactional
  public SendConditionCancelResponse DoCancelDBAction(Long ordNo, MstMachine machine, String flag, boolean mntMachineStateFlg) {
    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      // 1 pat_mainの更新
      Long patId = ordMainDao.selectPatIdByOrdNo(ordNo);
      if (patId != null) {
        res = resetPatMain(patId, ordNo);
        if (res.isSuccess == false) {
          return res;
        }
      }

      // 2 ord_mainの更新
      //    条件送信開始日時を削除＋ステータスを条件送信前に書き換える
      //    それ以外の実績は残す
      //    ind_dwも消す
      res = resetOrdMain(ordNo);
      if (res.isSuccess == false) {
        return res;
      }

      //del 9513警報報知一覧で患者名空欄が表示されない。 zhao start
/*      res = resetMotionRecord(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
      if (res.isSuccess == false) {
        return res;
      }*/
      //del 9513警報報知一覧で患者名空欄が表示されない。 zhao end

      // 4 mni_monitorのorder_noを削除
      //    血圧・体温・血糖値などはorder_no振替後にも引き継ぐ
      res = resetMniMonitor(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
      if (res.isSuccess == false) {
        return res;
      }
      // 5 チェックリストのデータを削除
      res = resetCheckList(ordNo, machine.getFacilityCd(), flag);
      if (res.isSuccess == false) {
        return res;
      }
      //mod FNSI-redmine6215 fang start
      // 6 mnt_machine_stateのorder_noを削除(現患者削除)
      if (mntMachineStateFlg) {
        res = resetMachineState(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial(), ordNo);
        if (res.isSuccess == false) {
          return res;
        }
      }
      //mod FNSI-redmine6215 fang end
    } catch (Exception ex) {
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
    return res;
  }
  //add FNSI-redmine6215 fang end

  //add #10412 次患者更新関連全体見直し対応 朴 start
  @Transactional
  public SendConditionCancelResponse DoCancelDBAction2(String facilityCd, String machineTypeCd, String machineSerial, OrdMain targetOrdMain) {
    // Log定義
    EventLogMessage eventLogMessage = new EventLogMessage();
    final String className = new Object() {}.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {}.getClass().getEnclosingMethod().getName();
    // 開始ログ
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

    Long patId = targetOrdMain.getPatId();
    Long ordNo = targetOrdMain.getOrdNo();

    SendConditionCancelResponse res = new SendConditionCancelResponse();
    try {
      // 1 pat_mainの更新
      if (patId != null) {

        //mod #10880  患者削除の処理不正 start
//        res = this.resetPatMain(patId, ordNo);
//        if (res.isSuccess == false) {
//          return res;
//        }
        PatMain pat = patMainDao.selectById(patId);
        if(pat != null){
          res = this.resetPatMain(patId, ordNo);
          if (res.isSuccess == false) {
            return res;
          }
        }
        //mod #10880  患者削除の処理不正 end

      } else {
        // ログ
        eventLogMessage.setLogMessage(className + "." + methodName + "pat_mainの更新をskip patId = null");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      }

      // 2 ord_mainの更新
      //    条件送信開始日時を削除＋ステータスを条件送信前に書き換える
      //    それ以外の実績は残す
      //    ind_dwも消す
      if(!Objects.equals(targetOrdMain.getRstDialysisState(), "0")){
        res = this.resetOrdMain(ordNo);
        if (res.isSuccess == false) {
          return res;
        }
      } else{
        // ログ
        eventLogMessage.setLogMessage(className + "." + methodName + "ord_mainの更新をskip 変更前bed処理");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      }

      //mod #11418 条件送信キャンセル時に、mnt_motion_recordの同一ord_noをnull更新していない zrx start
      // 3 mnt_motion_recordの装置記録のorder_noを削除
      res = resetMotionRecord(facilityCd, machineTypeCd, machineSerial, ordNo);
      if (res.isSuccess == false) {
        return res;
      }
      //mod #11418 条件送信キャンセル時に、mnt_motion_recordの同一ord_noをnull更新していない zrx end

      // 4 mni_monitorのorder_noを削除
      //    血圧・体温・血糖値などはorder_no振替後にも引き継ぐ
      res = this.resetMniMonitor(facilityCd, machineTypeCd, machineSerial, ordNo);
      if (res.isSuccess == false) {
        return res;
      }
      // 5 チェックリストのデータを削除
      res = this.resetCheckList(ordNo);
      if (res.isSuccess == false) {
        return res;
      }
      // 6 mnt_machine_stateのorder_noを削除(現患者削除)
      res = this.resetMachineState(facilityCd, machineTypeCd, machineSerial, ordNo);
      if (res.isSuccess == false) {
        return res;
      }
      // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 start
      // 7 pat_ind_approveの更新
      List <Long> ordNos = new ArrayList();
      ordNos.add(ordNo);
      res = this.resetPatIndApprove(ordNos);
      if (res.isSuccess == false) {
        return res;
      }
      // add #10739 コンバート施設で指示受け(治療単位)が表示されない 関 end

    } catch (Exception ex) {
      // ログ
      eventLogMessage.setLogMessage(className + "." + methodName + "ロールバックエラー" + ex.getMessage());
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      // ロールバック実行
      throw new RuntimeException(ex.getMessage());
    }
    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse doCancel2(String facilityCd, Long bedCd, Long targetOrdNo) {
    // Log定義
    EventLogMessage eventLogMessage = new EventLogMessage();
    final String className = new Object() {}.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {}.getClass().getEnclosingMethod().getName();

    SendConditionCancelResponse res = new SendConditionCancelResponse();

    // 条件から装置情報を取得
    List<MstMachine> machines = mstMachineDao.selectByBedCd(facilityCd, bedCd);
    if (machines.size() == 0) {
      res.isSuccess = false;
      res.errorMessage = "対象装置なし";
      res.exMessage = "装置の特定に失敗";
      return res;
    }
    MstMachine machine = machines.get(0);
    ComsvMntMachineState machineState = mntMachineStateDao.selectMachineKey(facilityCd,
      machine.getMachineTypeCd(), machine.getMachineSerial());

    if(targetOrdNo > 0){
      if(!Objects.equals(machineState.getOrdNo(), targetOrdNo)){
        eventLogMessage.setLogMessage(className + "." + methodName + " 注意：条件送信キャンセル対象targetOrdNoとの指定BedCdのmachineState.getOrdNo()が不一致です");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);
      }
    }

    // 条件送信済みオーダー
    OrdMain targetOrdMain = ordMainDao.selectByOrdNo(machineState.getOrdNo());
    return this.doCancel2(facilityCd, machine.getMachineTypeCd(), machine.getMachineSerial(), targetOrdMain);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public SendConditionCancelResponse doCancel2(String facilityCd, String machineTypeCd, String machineSerial, OrdMain targetOrdMain) {
    // Log定義
    EventLogMessage eventLogMessage = new EventLogMessage();
    final String className = new Object() {}.getClass().getEnclosingClass().getName();
    final String methodName = new Object() {}.getClass().getEnclosingMethod().getName();
    // 開始ログ
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理開始");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

    // 主処理
    SendConditionCancelResponse res = new SendConditionCancelResponse();
    if (targetOrdMain == null) {
      // ログ
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了 条件送信済みデータなし targetOrdNo == null");
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      // 条件送信済みデータなし
      res.isSuccess = true;
      return res;
    }

    try {
      // 自前処理
      res = this.DoCancelDBAction2(facilityCd, machineTypeCd, machineSerial, targetOrdMain);
      if (res.isSuccess == false) {
        // ログ
        eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了 自前処理失敗 res.isSuccess == false");
        logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

        return res;
      }
      res.isSuccess = true;
    } catch (Exception ex) {
      // ログ
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理継続 自前処理Exception検知 " + ex.getMessage());
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      res.isSuccess = false;
      res.exMessage = "条件送信キャンセル失敗\n" + ex.getMessage();
      res.errorMessage = "条件送信キャンセル失敗";
    }

    // 外部API呼び出し
    res = resetMachineStateNextPat(facilityCd, machineTypeCd, machineSerial);
    if (res.isSuccess == false) {
      // ログ
      eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了 外部API呼び出し失敗 res.isSuccess == false");
      logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

      return res;
    }

    // 開始ログ
    eventLogMessage.setLogMessage(className + "." + methodName + " 処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, "", SERVICE_NAME.FNSI, null);

    return res;
  }
  //add #10412 次患者更新関連全体見直し対応 朴 end

}
