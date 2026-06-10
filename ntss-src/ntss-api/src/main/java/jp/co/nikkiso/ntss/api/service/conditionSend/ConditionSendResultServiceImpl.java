package jp.co.nikkiso.ntss.api.service.conditionSend;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.additionInfo.AdditionCalculationService;
import jp.co.nikkiso.ntss.api.service.ordChecklistService.OrdCheckListService;
import jp.co.nikkiso.ntss.api.service.utils.ConditionSendResultUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstChecklistDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.OrdChecklistDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.entity.MstChecklist;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForCheckListSchedule;
import jp.co.nikkiso.ntss.core.exception.BusinessException;
import jp.co.nikkiso.ntss.api.service.ordChecklistService.CheckListMakeService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 実績作成系のService実装クラス.
 */
// add 11454 時間外加算自動処理が機能していない zkm start
@Service
public class ConditionSendResultServiceImpl implements ConditionSendResultService {

  @Autowired
  ConditionSendResultUtil conditionSendResultUtil;

  @Autowired
  LogService logService;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  MstKurDao mstKurDao;

  @Autowired
  OrdChecklistDao ordChecklistDao;

  @Autowired
  MstChecklistDao mstChecklistDao;

  @Autowired
  CheckListMakeService checkListMakeService;

  @Autowired
  AdditionCalculationService additionCalculationService;

  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
  @Autowired
  OrdCheckListService ordCheckListService;
  // add #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end

  @Override
  @Transactional
  public void sendCondResultOnly(Long ordNo, Long userId) {
    //戻り値初期化
    HashMap<ConditionSendResultUtil.PARAMKEY,Object> retVal = new HashMap<>();

    if(null == ordNo)
    {
      //必要パラメータが渡されていないので終了
      String fmt = "渡されたパラメータが不正です。ordNo (%s)" ;
      throw new RuntimeException("処理を終了しました。" + ":" + String.format(fmt, ordNo));
    }

    //------------------------------------
    // main処理 3011
    // 条件送信の結果処理を行う(ord_mainのみの処理)
    conditionSendResultUtil.makeSendResult(ordNo, userId, retVal);
    if (retVal.containsKey(ConditionSendResultUtil.PARAMKEY.STATUS) && retVal.containsKey(ConditionSendResultUtil.PARAMKEY.RET_MSG)) {
      if (!HttpStatus.OK.equals(retVal.get(ConditionSendResultUtil.PARAMKEY.STATUS))) {
        throw new RuntimeException(String.valueOf(retVal.get(ConditionSendResultUtil.PARAMKEY.RET_MSG)));
      }
    }
  }

  @Override
  @Transactional
  public void sendCondResultManualOnly(Long ordNo, Long userId) {

    //戻り値初期化
    HashMap<ConditionSendResultUtil.PARAMKEY,Object> retVal = new HashMap<>();

    if(null == ordNo)
    {
      //必要パラメータが渡されていないので終了
      String fmt = "渡されたパラメータが不正です。ordNo (%s)" ;
      throw new RuntimeException("処理を終了しました。" + ":" + String.format(fmt, ordNo));
    }

    //------------------------------------
    // main処理 3011
    // 条件送信の結果処理を行う(ord_mainのみの処理)
    conditionSendResultUtil.makeSendResult(ordNo, userId, retVal);

    if (retVal.containsKey(ConditionSendResultUtil.PARAMKEY.STATUS) && retVal.containsKey(ConditionSendResultUtil.PARAMKEY.RET_MSG)) {
      if (!HttpStatus.OK.equals(retVal.get(ConditionSendResultUtil.PARAMKEY.STATUS))) {

        throw new BusinessException(retVal.get(ConditionSendResultUtil.PARAMKEY.STATUS).toString(),
          String.valueOf(retVal.get(ConditionSendResultUtil.PARAMKEY.RET_MSG)));
      }
    }

    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    String treatDate = ordMain.getTreatDate();
    String indTreatStartTime = ordMain.getIndTreatStartTime();
    if (StringUtils.isEmpty(indTreatStartTime)) {
      Integer indKurCd = ordMain.getIndKurCd();
      MstKur mstKur = mstKurDao.selectByKurCd(indKurCd.toString());
      indTreatStartTime = mstKur.getKurStandardStartTime().substring(0,4);
    }
    LocalDate day = LocalDate.parse(treatDate, DateTimeFormatter.BASIC_ISO_DATE);
    LocalTime time = LocalTime.of(Integer.parseInt(indTreatStartTime.substring(0, 2)), Integer.parseInt(indTreatStartTime.substring(2,indTreatStartTime.length())));
    LocalDateTime dateTime = LocalDateTime.of(day, time);
    ordMain.setRstStartDate(Timestamp.valueOf(dateTime));

    // 利用者ID user
    if (userId != null) {
      ordMain.setLogUserId(userId.toString());
    }

    ordMainDao.update(ordMain);

    // 加算計算する
    AdditionCalculationRequest addCalcRequest = new AdditionCalculationRequest();
    addCalcRequest.setOrdNo(ordMain.getOrdNo());
    addCalcRequest.setFacilityCd(ordMain.getFacilityCd());
    addCalcRequest.setPatId(ordMain.getPatId());
    addCalcRequest.setEventId(5);

    additionCalculationService.calculationAddition(addCalcRequest);

    // 手動実績作成の場合「条件送信前⇒チェックリスト実績を新規作成」「実施状態（0：未実施）」「実績区分（1：条件送信後）」
    // 手動実績作成の場合「条件送信前⇒チェックリスト実績を更新」   「実績区分（0：条件送信前）⇒（1：条件送信後）」
    // 手動実績作成の場合「条件送信前⇒チェックリスト実績を新規作成」「実施状態（9：リスト基準）」
    updateOrdChecklistByActionBeCurrent(ordMain.getOrdNo());
  }

  @Override
  public void mainProcessSendCondResult(String facilityCd, String machineTypeCd, String machineSerial) {
    //戻り値初期化
    HashMap<ConditionSendResultUtil.PARAMKEY,Object> retVal = new HashMap<>();

    if(null == facilityCd || null == machineTypeCd || null == machineSerial)
    {
      //必要パラメータが渡されていないので終了
      String fmt = "渡されたパラメータが不正です。"+ ConditionSendResultUtil.PARAMKEY.FACILITY_CD.get()+"(%s) " + ConditionSendResultUtil.PARAMKEY.MACHINE_TYPE_CD.get()+"(%s) "+ ConditionSendResultUtil.PARAMKEY.MACHINE_SERIAL.get()+"(%s) " ;
      throw new RuntimeException("処理を終了しました。" + ":" + String.format(fmt, facilityCd,machineTypeCd,machineSerial));
    }

    //------------------------------------
    // main処理 3011
    // 条件送信の結果処理を行う
    conditionSendResultUtil.mainProcessSendCondResult(facilityCd, machineTypeCd, machineSerial, retVal);
    if (retVal.containsKey(ConditionSendResultUtil.PARAMKEY.STATUS) && retVal.containsKey(ConditionSendResultUtil.PARAMKEY.RET_MSG)) {
      if (!HttpStatus.OK.equals(retVal.get(ConditionSendResultUtil.PARAMKEY.STATUS))) {
        throw new RuntimeException(String.valueOf(retVal.get(ConditionSendResultUtil.PARAMKEY.RET_MSG)));
      }
    }
  }

  private void updateOrdChecklistByActionBeCurrent(Long insOrdNo) {
    List<OrdMainForCheckListSchedule> ordMainList = ordMainDao.selectByOrdNoListChecklist(List.of(insOrdNo));
    for (OrdMainForCheckListSchedule ordMain : ordMainList) {
      if (ordMain == null) {
        ordChecklistDao.deleteByOrdNo(ordMain.getOrdNo(), ordMain.getFacilityCd());
        return;
      }
      try {
        // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 start
        ordCheckListService.syncOrdChecklistForResult(List.of(ordMain.getOrdNo()));
        // mod #12235【因島】チェックリストの治療条件：抗凝固剤での小数点桁数の扱いが不正 関 end
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
    }
  }

  /**
   * 患者経過総合ビューア用、チェックリスト実績同期処理「条件送信場合」
   *
   * @param ordNo 更新対象番号「治療情報」
   */
  private boolean syncOrdChecklistForResult(Long ordNo) throws IOException {
    // チェックリスト実績対象リスト「登録」「更新」
    // 治療情報を取得
    OrdMainForCheckListSchedule ordMain = ordMainDao.selectByOrdNoChecklist(ordNo);
    // 治療情報がない場合
    if (ordMain == null) {
      return false;
    }

    // 最新のチェックリストマスタを取得
    List<MstChecklist> mstChecklist = mstChecklistDao.selectByFacilityCd(SelectOptions.get(), ordMain.getFacilityCd(), "0");
    MstChecklist nowMstChecklist = mstChecklist.get(0);
    String strSetting = nowMstChecklist.getChecklistSettings();
    ObjectMapper map = new ObjectMapper();
    JsonNode node = map.readTree(strSetting);

    // 登録用チェックリストデータを作成
    List<OrdChecklist> regList = checkListMakeService.getRegisterChecklistRst(ordMain, node, (long) nowMstChecklist.getChecklistCd(), true);
    if (regList != null) {
      // チェックリスト実績情報を取得（治療情報別）
      List<OrdChecklist> ordCheckListJisseki = ordChecklistDao.selectByOrdNo(SelectOptions.get(), ordNo);
      for (int i = 0; i < regList.size(); i++) {
        Boolean regflg = true;
        for (int j = 0; j < ordCheckListJisseki.size(); j++) {
          if (regList.get(i).getFuncClass() == 0) {
            if (Objects.equals(regList.get(i).getRstChecklistInfo().getItemNumber(), ordCheckListJisseki.get(j).getRstChecklistInfo().getItemNumber())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getName(), ordCheckListJisseki.get(j).getRstChecklistInfo().getName())
              &&
              Objects.equals(regList.get(i).getRstClass(), ordCheckListJisseki.get(j).getRstClass())
              &&
              Objects.equals(regList.get(i).getListCd(), ordCheckListJisseki.get(j).getListCd())
              &&
              Objects.equals(regList.get(i).getFuncClass(), ordCheckListJisseki.get(j).getFuncClass())
            ) {
              // 登録しない
              regflg = false;
              break;
            }
          } else {
            if (Objects.equals(regList.get(i).getListCd(), ordCheckListJisseki.get(j).getListCd()) &&
              Objects.equals(regList.get(i).getFuncClass(), ordCheckListJisseki.get(j).getFuncClass()) &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getItemNumber(),
                ordCheckListJisseki.get(j).getRstChecklistInfo().getItemNumber())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getClassCd(),
                ordCheckListJisseki.get(j).getRstChecklistInfo().getClassCd())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getCode(),
                ordCheckListJisseki.get(j).getRstChecklistInfo().getCode())
              &&
              Objects.equals(regList.get(i).getRstClass(), ordCheckListJisseki.get(j).getRstClass())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getMedicineType(), ordCheckListJisseki.get(j).getRstChecklistInfo().getMedicineType())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getMedicineNo(), ordCheckListJisseki.get(j).getRstChecklistInfo().getMedicineNo())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getEquipType(), ordCheckListJisseki.get(j).getRstChecklistInfo().getEquipType())
              &&
              Objects.equals(regList.get(i).getRstChecklistInfo().getAmount(), ordCheckListJisseki.get(j).getRstChecklistInfo().getAmount()))
            {
              // 登録しない
              regflg = false;
              break;
            }
          }
        }
        // 未登録の実績のみ
        if (regflg) {
          // 実績作成
          ordChecklistDao.insert(regList.get(i));
        }
      }
    }
    return true;
  }
}
// add 11454 時間外加算自動処理が機能していない zkm end
