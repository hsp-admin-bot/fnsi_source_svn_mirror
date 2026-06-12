package jp.co.nikkiso.ntss.device_edge.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import io.micrometer.core.instrument.util.StringUtils;
import jp.co.nikkiso.ntss.api.service.NameConcat.NameConcatService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ObjectNode;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineStateForMinimumTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfo;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfoService;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class MntMachineStateServiceImpl implements MntMachineStateService {

  @Autowired
  MntMachineStateDao mntMachineStateDao;
  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  CondInfoService condInfoService;
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  @Autowired
  private LogService logService;

  // #11827 2025.05.14 add 姓名結合用サービス構築 TDC米沢 start
  // 姓名結合用サービス構築
  @Autowired
  NameConcatService nameConcatService;
  // #11827 2025.05.14 add 姓名結合要サービス構築 TDC米沢 end

  @Override
  public List<ComsvMntMachineState> selectByFacilityCd(String facilityCd) {
    return mntMachineStateDao.selectByFacilityCd(facilityCd);
  }

  @Override
  @Transactional
  public int updateUseTime(MntMachineState param) {

    return mntMachineStateDao.updateUseTime(param);
  }

  @Override
  @Transactional
  public int updateCondSend(MntMachineState param) {

    return mntMachineStateDao.updateCondSend(param);
  }

  @Override
  @Transactional
  public int updateCondSet(MntMachineState param) {

    return mntMachineStateDao.updateCondSet(param);
  }

  @Override
  @Transactional
  public int updateDialStart(MntMachineState param) {

    return mntMachineStateDao.updateDialStart(param);
  }

  @Override
  @Transactional
  public int updateDialEnd(MntMachineState param) {

    // ＃10889 2024.09.13 add オフラインフラグ初期化 TDC片口 start
    mntMachineStateDao.updateIsOfflineInitialize(param.getFacilityCd(), param.getMachineTypeCd(), param.getMachineSerial());
    // ＃10847 2024.09.13 add オフラインフラグ初期化 TDC片口 end
    return mntMachineStateDao.updateDialEnd(param);
  }

  @Override
  @Transactional
  public int updateUnregisteredPat(MntMachineState param) {

    return mntMachineStateDao.updateUnregisteredPat(param);
  }

  @Override
  public MntMachineState selectByKey(String facilityCd, String machineTypeCd, String machineSerial) {
    return mntMachineStateDao.selectByKey(facilityCd, machineTypeCd, machineSerial);
  }

  @Override
  public List<MntMachineState> selectAllByDeviceEdgeNo(String facilityCd, Integer deviceEdgeNo) {
    return mntMachineStateDao.selectAllByDeviceEdgeNo(facilityCd, deviceEdgeNo);
  }

  @Override
  public ComsvMntMachineState selectMachineKey(String facilityCd, String machineTypeCd, String machineSerial) {

    // #11827 2025.05.16 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
    // 施設設定値取得
    nameConcatService.ReadFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.VIRTUAL_TERMINAL_NAME_CONCAT_SETTING);
    // #11827 2025.05.16 mod 仮想端末姓名結合設定に準拠 TDC米沢 end
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
    try {
    ComsvMntMachineState comsv = mntMachineStateDao.selectMachineKey(facilityCd, machineTypeCd, machineSerial);
    Long patId = comsv.getNextPatid();
    if (!(Objects.equals(patId, null))) {
      // pat_personal_main 患者個人情報取得
      PatPersonalMain patPersonal = patPersonalMainDao.selectById(patId);
      // 患者名
      // #9485 mod 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 start
//      String patLastName = patPersonal.getPat_last_name();
//      String patFirstName = patPersonal.getPat_first_name();
      String patLastName = patPersonal.getPat_last_name() == null?"":patPersonal.getPat_last_name();
      String patFirstName = patPersonal.getPat_first_name() == null?"":patPersonal.getPat_first_name();
      // #9485 mod  患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 end
      //add 通信共通プロトコル（V3/V4）患者IDが異なる --趙-- start
      comsv.setHospPatid(patPersonal.getHosp_pat_id());
      //add 通信共通プロトコル（V3/V4）患者IDが異なる --趙-- end

      // #11827 2025.05.16 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
      // comsv.setNextPatName(patLastName + " " + patFirstName);
      // 姓名結合
      comsv.setNextPatName(nameConcatService.NameConcat(patFirstName, patLastName));
      // #11827 2025.05.16 mod 仮想端末姓名結合設定に準拠 TDC米沢 end
    }

    String setInfo = comsv.getTmpDeviceSetInfo();
    comsv.setDeviceSetPatName(null);
    if (!(Objects.equals(setInfo, null))) {
	  // JSON処理
	  ObjectMapper mapper = new ObjectMapper();
	  try {
	    JsonNode jsonNode_array = mapper.readTree(comsv.getTmpDeviceSetInfo());
        // 設定値書込用患者ID取得
//	    String sDevPatId = jsonNode_array.get("dev").get("0").asText();
//	    if (!(Objects.isNull(sDevPatId))) {
      if (jsonNode_array.hasNonNull("dev")
        && jsonNode_array.get("dev").hasNonNull("0")) {
//	      Long lDevPatId = Long.parseLong(sDevPatId);
        Long lDevPatId = jsonNode_array.get("dev").get("0").asLong();
	      if (!(Objects.isNull(lDevPatId))) {
	        // pat_personal_main 患者個人情報取得
	        PatPersonalMain patPersonal = patPersonalMainDao.selectById(lDevPatId);
	        // 設定値書込用患者名
          // #9485 mod 患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 start
//          String patLastName = patPersonal.getPat_last_name();
//	        String patFirstName = patPersonal.getPat_first_name();
          String patLastName = patPersonal.getPat_last_name() == null ? "" : patPersonal.getPat_last_name();
          String patFirstName = patPersonal.getPat_first_name() == null ? "" : patPersonal.getPat_first_name();
          // #9485 mod  患者名の姓または名に連携からnullが登録された場合に、各画面の患者名表示に「null」と表示してしまう。2024-04-25 卓 end
          // #11827 2025.05.16 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
          // comsv.setDeviceSetPatName(patLastName + " " + patFirstName);
          // 姓名結合
          comsv.setDeviceSetPatName(nameConcatService.NameConcat(patFirstName, patLastName));
          // #11827 2025.05.16 mod 仮想端末姓名結合設定に準拠 TDC米沢 end
	      }
	    }
	  } catch (tools.jackson.core.JacksonException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
	  }
    }

    Long ordNo = comsv.getOrdNo();
    if (ordNo == null) {
      // オーダ番号が未登録なら次回オーダ番号
      ordNo = comsv.getNextOrdNo();
    }
    if (ordNo != null) {
      // オーダ番号から治療情報を取得する
      OrdMain ord = ordMainDao.selectByOrdNo(ordNo);
      // add FNSI-バグ 通信サーバ #7309 高 start
      if (ord != null) {
        // add FNSI-バグ 通信サーバ #7309 高 end
        CondInfo condInfo = null;
        // 治療状態判定
        if (ord.getRstDialysisState() == null ||
          ord.getRstDialysisState().isEmpty() ||
          ord.getRstDialysisState().equals("0")) {
          // 予定
          condInfo = condInfoService.createCondInfo(ord.getIndCondInfo());
        } else {
          // 実績
          condInfo = condInfoService.createCondInfo(ord.getRstCondInfo());
        }
        if (condInfo.getTreatTime() != null) {
          // 透析時間
          String treatTime = condInfo.getTreatTime().getValue();
          comsv.setTreatTime(treatTime);
        }
      }
    }

    // 施設設定から治療時間判定時間を取得
    FacilitySettingInfo info = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, FacilitySettingNo.TREAT_JUDGE_TIME);
    if (info != null) {
      // 治療時間判定時間
      comsv.setTreatJudgeTime(info.getValue());
    }

    return comsv;
    } finally {
      nameConcatService.ClearFacilitySettingValue();
    }
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
  }

  @Override
  @Transactional
  public int updateAlarmList(String facilityCd, String machineTypeCd, String machineSerial, String alarmList) {

    return mntMachineStateDao.updateAlarmList(facilityCd, machineTypeCd, machineSerial, alarmList);
  }

  /**
   * 指定期間内の次患者治療予定日で最小のものを取得する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param startDate 検索開始日付
   * @param endDate 検索終了日付
   * @return
   */
  @Override
  public ComsvMntMachineStateForMinimumTreatDate selectMinimumTreatDate(String facilityCd, Integer deviceEdgeNo, String startDate, String endDate ) {
    return mntMachineStateDao.selectMinimumTreatDate(facilityCd, deviceEdgeNo, startDate, endDate );
  }

  /**
   * 装置ステータス一括更新
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateAllStatus(String facilityCd, String devJson) {
    int rtn = 0;
    int lop;
    List<MntMachineState> mmsList = new ArrayList<MntMachineState>(); // #9111 2023.07.14 add 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎

    // JSON処理
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_array = mapper.readTree(devJson);
      for (lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy().asObject();
        if (objectNode != null) {
          if (jsonNode.get("type") != null && jsonNode.get("serial") != null && jsonNode.get("status") != null) {
       	    MntMachineState state = new MntMachineState();
       	    state.setFacilityCd(facilityCd);
       	    state.setMachineTypeCd(objectNode.get("type").asText());
       	    // #9111 2023.07.14 chg 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎 start
       	    //state.setMachineSerial(objectNode.get("serial").asText());
       	    state.setMachineSerial(objectNode.get("serial").asText().trim()); // trimはSQL文側でやるよりjava側でやるほうが早い
       	    // #9111 2023.07.14 chg 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎 end
       	    state.setMachineStatus(objectNode.get("status").asInt());

       	    // #8732 2023.06.06 add ログ強化 TDC片口 start
       	    EventLogMessage eventLogMessage = new EventLogMessage();
       	    eventLogMessage.setFacilityCd(facilityCd);
       	    eventLogMessage.setLogMessage("装置ステータス更新 machineTypeCd : " + state.getMachineTypeCd() + " machineSerial : " + state.getMachineSerial() + " machineStatus : " + state.getMachineStatus());
       	    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
       	    // #8732 2023.06.06 add ログ強化 TDC片口 end

            // #9111 2023.07.14 chg 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎 start
//          // mod by shiyw 2023-03-09: add trigger logic code  --start
//          MntMachineState mntMachineStateOld = mntMachineStateDao.selectByKey(facilityCd, state.getMachineTypeCd(), state.getMachineSerial());
//          rtn = mntMachineStateDao.updateMachineState(state);
//          if( rtn > 0 && ( MntMachineStateTrigger.PROCESS_STATE_09.equals(state.getProcessState()) || MntMachineStateTrigger.PROCESS_STATE_11.equals(state.getProcessState()) ) ){
//            MntMachineState mntMachineStateNew = mntMachineStateDao.selectByKey(facilityCd, state.getMachineTypeCd(), state.getMachineSerial());
//            mntMachineStateTrigger.triggerUpdate(mntMachineStateOld,mntMachineStateNew);
//          }
//          // mod by shiyw 2023-03-09: add trigger logic code  --start

            mmsList.add(state);
            // #9111 2023.07.14 chg 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎 end
          }
        } else {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("入力値変換失敗:" + lop);
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        }
      }

      // #9111 2023.07.14 add 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎 start
      if (1 <= mmsList.size()) {
        rtn = mntMachineStateDao.updateMachineStateMultiple(mmsList);
      }
      // #9111 2023.07.14 add 複数装置の 装置ステータス の更新を1つのSQL文で実施 TDC山崎 end
    } catch (tools.jackson.core.JacksonException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("装置ステータス一括更新失敗:" + e.getMessage());
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }
    // #8732 2023.06.06 add ログ強化 TDC片口 start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage("装置ステータス一括更新終了." + rtn);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // #8732 2023.06.06 add ログ強化 TDC片口 end

    return rtn;
  }
// add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- start
  @Override
  public int updateTreatmentStatus(MntMachineState param) {

    return mntMachineStateDao.updateTreatmentStatus(param);
  }
  // add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- end

  // add 装置のSTATUS状態更新方法の変更 --趙-- start
  @Override
  public int updateMachineState(MntMachineState param) {
    // mod by shiyw 2023-03-09: add trigger logic code  --start
    //return mntMachineStateDao.updateMachineState(param);

    // #9111 2023.07.14 del 不要処理の削除 TDC山崎 start
//  MntMachineState mntMachineStateOld = mntMachineStateDao.selectByKey(param.getFacilityCd(), param.getMachineTypeCd(), param.getMachineSerial());
    // #9111 2023.07.14 del 不要処理の削除 TDC山崎 end

    int rtn = mntMachineStateDao.updateMachineState(param);

    // #9111 2023.07.14 del 不要処理の削除 TDC山崎 start
//  if( rtn > 0 && ( MntMachineStateTrigger.PROCESS_STATE_09.equals(param.getProcessState()) || MntMachineStateTrigger.PROCESS_STATE_11.equals(param.getProcessState()) ) ){
//    MntMachineState mntMachineStateNew = mntMachineStateDao.selectByKey(param.getFacilityCd(), param.getMachineTypeCd(), param.getMachineSerial());
//    mntMachineStateTrigger.triggerUpdate(mntMachineStateOld,mntMachineStateNew);
//  }
    // #9111 2023.07.14 del 不要処理の削除 TDC山崎 end

    return rtn;
    // mod by shiyw 2023-03-09: add trigger logic code  --end
  }
  // add 装置のSTATUS状態更新方法の変更 --趙-- end

  // add FNSI-画面リロードの修正 徐 start
  @Override
  public MntMachineState selectMachineState(MntMachineState param) {

    return mntMachineStateDao.selectMachineState(param);
  }
  // add FNSI-画面リロードの修正 徐 end

  // add AWSとDEの通信断からの復旧 --趙-- start
  public int updateMachineStateCommFail(MntMachineState param){
    return mntMachineStateDao.updateMachineStateCommFail(param);
  }

  public int updateProcessState(MntMachineState param){
    return mntMachineStateDao.updateProcessState(param);
  }
  // add AWSとDEの通信断からの復旧 --趙-- end

}
