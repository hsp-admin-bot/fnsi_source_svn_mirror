package jp.co.nikkiso.ntss.admin_web.service.scaleBed;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.CheckSendableConditionResult;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.CheckingParameter;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.ScaleBedListViewDTO;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto.ScaleBedWeightAndBedKey;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MntScaleBedStateDao;
import jp.co.nikkiso.ntss.core.dao.MstWeightDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.PropertyNamingStrategies;
import tools.jackson.databind.annotation.JsonNaming;
import info.sunjune.solve.calculation.calculator.NumberCalculator;
import io.micrometer.core.instrument.util.StringUtils;
import jp.co.nikkiso.ntss.admin_web.request.weight.PatExamPrintRequest;
import jp.co.nikkiso.ntss.admin_web.request.weight.SendConditionRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.scaleBed.constant.CheckingParameterCode;
import jp.co.nikkiso.ntss.admin_web.service.weight.WeightService;
import jp.co.nikkiso.ntss.admin_web.service.weight.state.ScaleBedStateService;
import jp.co.nikkiso.ntss.admin_web.web.rest.WeightResource;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dto.mstWeight.ScaleBedSettingBedCd;
import jp.co.nikkiso.ntss.core.entity.MstWeight;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainWeightPrint;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPrint;
import jp.co.nikkiso.ntss.core.entity.custom.ScaleBedAllState;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.ObjectUtils;
import org.springframework.lang.Nullable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;


@Service
public class ScaleBedServiceImpl implements ScaleBedService{

  @Autowired
  private LogService logService;

  @Autowired
  private ScaleBedStateService  scaleBedStateService;

  @Autowired
  private WeightService weightService;

  @Autowired
  private CheckScaleService checkScaleService;

  @Autowired
  private MntScaleBedStateDao mntScaleBedStateDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private MstWeightDao mstWeightDao;

  @Autowired
  private MntMachineStateDao machineStateDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private OrdWeightScaleDao ordWeightScaleDao;

  @Autowired
  private FacilitySettingService facilitySettingService;

  @Autowired
  private WeightResource weightResource;

  @Autowired
  private ObjectMapper objectMapper;

  @Override
  public List<ScaleBedListViewDTO> getScaleBedList(String facilityCd ) {

    // フォーマットを指定（yyyyMMdd）
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    // 1. 本日の日付を取得
    LocalDate today = LocalDate.now();
    String treatDate = today.format(formatter);
    // 2. 昨日の日付を取得（minusDays(1)を使用）
    LocalDate yesterday = today.minusDays(1);
    String treatLocalDateFirst = yesterday.format(formatter);

    String  endState;
    // 施設設定マスタから 患者切替タイミングを取得
    String facilitySetting = facilitySettingService.getFacilitySettingValue(facilityCd,  CoreConstant.FacilitySettingNo.SCALE_BED_PAT_CHANGE_TIMING);
    if(Objects.equals(facilitySetting, "1")){
      endState = "4";
    }
    else {
      endState = "5";
    }

    // スケールベッドの一覧取得
    List<ScaleBedListViewDTO> returnValue = new ArrayList<>();
    // スケールベッド状態テーブルと関連する情報の収集(前体重)
    List<ScaleBedAllState> stateList = mntScaleBedStateDao.selectScaleBedAllStateByFacility(facilityCd);
    // 対象患者IDのリスト
    List<Long> patIdList = stateList.stream().map(ScaleBedAllState::getPatId).filter(Objects::nonNull).distinct().toList();
    // 対象患者個人情報
    List<PatPersonalMain> patPersonalMains = patPersonalMainDao.selectByIdList(patIdList);
    // スケールベッド状態テーブルと関連する情報の収集(後体重)
    List<ScaleBedAllState> stateListRst = mntScaleBedStateDao.selectScaleBedAllRstStateByFacility(facilityCd,treatLocalDateFirst,endState);
    // 対象患者IDのリスト
    List<Long> patIdListRst = stateListRst.stream().map(ScaleBedAllState::getPatId).filter(Objects::nonNull).distinct().toList();
    // 対象患者個人情報
    List<PatPersonalMain> patPersonalMainsRst = patPersonalMainDao.selectByIdList(patIdListRst);

    // 対象患者個人情報の統合
    patPersonalMains.addAll(patPersonalMainsRst);

    // stateListRst に存在する bedCd を作る
    Set<Long> rstBedCdSet = stateListRst.stream()
        .map(ScaleBedAllState::getBedCd)
        .filter(Objects::nonNull)
        .collect(java.util.stream.Collectors.toSet());

    // stateList から、RstDialysisState が無いstateListRst と重複するものを削除
    stateList.removeIf(s -> s.getRstDialysisState() == null  &&
    rstBedCdSet.contains(s.getBedCd()));

    // スケージュールベッド一覧情報の統合
    stateList.addAll(stateListRst);

    // 応答データ作成
    for(ScaleBedAllState scaleBedAllState : stateList){
      int inOutClass = 0;
      String patName = "";
      String hospPatId = "";
      String patFirstNameKana ="";
      String patLastNameKana ="";

      //測定値がNULの場合は、データをクリアする。
      //実績ステータスがNULLの場合データをクリアする。
      if(scaleBedAllState.getScaleValue() == null || scaleBedAllState.getRstDialysisState() == null){
        scaleBedAllState.setSendStatus(null);
      }

      // PadIdがある場合の処理
      if (scaleBedAllState.getPatId() != null) {
        PatPersonalMain patPersonalMain = patPersonalMains.stream()
          .filter(p -> Objects.equals(p.getPat_id(), scaleBedAllState.getPatId()))
          .findFirst()
          .orElse(null);

        if (patPersonalMain != null) {
          inOutClass = patPersonalMain.getIn_out_class();
          hospPatId =patPersonalMain.getHosp_pat_id();
          String patLastName = patPersonalMain.getPat_last_name() == null ? "" : patPersonalMain.getPat_last_name();
          String patFirstName =  patPersonalMain.getPat_first_name() == null ? "" : patPersonalMain.getPat_first_name();
          patName = patLastName + patFirstName;
          patFirstNameKana = patPersonalMain.getPat_first_name_kana() == null ? "" : patPersonalMain.getPat_first_name_kana();
          patLastNameKana =  patPersonalMain.getPat_last_name_kana() == null ? "" : patPersonalMain.getPat_last_name_kana();
        }
      }

      //前体重の場合で、後体重実績を取得した場合で、透析中以外では、測定実績をNULLセットする。
      if(scaleBedAllState.getWeightScaleStatus() != null && scaleBedAllState.getScaleClass() != null
        && (!Objects.equals(scaleBedAllState.getRstDialysisState(), "3"))){

        if ((scaleBedAllState.getWeightScaleStatus() == 1) && (scaleBedAllState.getScaleClass() == 1)) {
          scaleBedAllState.setScaleValue(null);
        }
        //後体重の場合で、前体重実績を取得した場合は、測定実績をNULLセットする。
        if ((scaleBedAllState.getWeightScaleStatus() > 3) && (scaleBedAllState.getScaleClass() == 0)) {
          scaleBedAllState.setScaleValue(null);
        }
      }
      /*
      //後体重で、患者切替後のデータを取得した場合は、NULLをセットする。
      if(scaleBedAllState.getWeightScaleStatus() != null && scaleBedAllState.getScaleClass() != null){
        if (scaleBedAllState.getWeightScaleStatus() > endState)  {
          scaleBedAllState.setScaleValue(null);
          scaleBedAllState.setWeightScaleStatus(null);
          scaleBedAllState.setWeightScaleNo(null);
          scaleBedAllState.setComType(null);
          scaleBedAllState.setRstDialysisState(null);
          scaleBedAllState.setIsSame(null);
          scaleBedAllState.setKurCd(null);
          scaleBedAllState.setSendStatus(null);
        }
      }
      */

      // 予定がない場合は過去測定値を無視する。
      if (scaleBedAllState.getOrdNo() == null) {
        scaleBedAllState.setScaleValue(null);
        scaleBedAllState.setWeightScaleStatus(null);
        scaleBedAllState.setWeightScaleNo(null);
        scaleBedAllState.setComType(null);
        scaleBedAllState.setRstDialysisState(null);
        scaleBedAllState.setIsSame(null);
        scaleBedAllState.setKurCd(null);
        scaleBedAllState.setSendStatus(null);
      }

      //透析中の場合
      if(Objects.equals(scaleBedAllState.getRstDialysisState(), "3")) {
        //測定値
        JsonNode weightInfo;
        var weightStr = scaleBedAllState.getRstWeightInfo();
        var rstWeightInfo = parseNode(weightStr);
        if (rstWeightInfo == null) {
          scaleBedAllState.setScaleValue(null);
          scaleBedAllState.setWeightBefore(null);
        } else {
          weightInfo = rstWeightInfo.has("weight_measure_before") ? rstWeightInfo.get("weight_measure_before") : null;
          if (weightInfo == null) {
            scaleBedAllState.setScaleValue(null);
          } else {
            BigDecimal measure = safeNewBigDecimal(weightInfo.toString());
            scaleBedAllState.setScaleValue(measure);
          }
          weightInfo = rstWeightInfo.has("weight_before") ? rstWeightInfo.get("weight_before") : null;
          if (weightInfo == null) {
            scaleBedAllState.setWeightBefore(null);
          } else {
            BigDecimal measure = safeNewBigDecimal(weightInfo.toString());
            scaleBedAllState.setWeightBefore(measure);
          }
        }
      }

      //測定モードが体重（独歩）以外の場合、測定値、車いす、測定モードを０とする。
      if(scaleBedAllState.getScaleMode() != null && scaleBedAllState.getScaleMode() != 0){
        //測定モードを体重にする。
        scaleBedAllState.setScaleMode(0L);
        //測定値に０をセットする。
        scaleBedAllState.setScaleValue(BigDecimal.valueOf(0));
        //車いす重量に０をセットする。
        scaleBedAllState.setWheelChairCd(0L);
      }
      ScaleBedListViewDTO scaleBedListViewDTO = new ScaleBedListViewDTO(
        scaleBedAllState, inOutClass, hospPatId, patName, patFirstNameKana, patLastNameKana
      );
      returnValue.add(scaleBedListViewDTO);
    }
    return returnValue;
  }

  @Override
  public List<ScaleBedWeightAndBedKey> getScaleBedWeightAndBedKeyList(String facilityCd) {

    // 有効なスケールベッド設定の紐づくベッドコードの一覧を取得
    List<ScaleBedSettingBedCd> bedCdList = this.mstWeightDao.selectScaleBedSettingBedCdList(facilityCd);
    List<MstWeight> mstWeights = this.mstWeightDao.selectByFacility(facilityCd);
    List<ScaleBedWeightAndBedKey> scaleBedWeightAndBedKeyList = new ArrayList<>();

    for(ScaleBedSettingBedCd bedCdItem : bedCdList){
      MstWeight matchedMstWeight = mstWeights.stream()
        .filter(mw -> Objects.equals(mw.getWeightCd(), bedCdItem.getWeightCd()))
        .findFirst()
        .orElse(null);
      if(matchedMstWeight != null){
        ScaleBedWeightAndBedKey scaleBedWeightAndBedKey = new ScaleBedWeightAndBedKey();
        scaleBedWeightAndBedKey.setBedCd(bedCdItem.getItemBedCd());
        scaleBedWeightAndBedKey.setWeightCd(matchedMstWeight.getWeightCd());
        scaleBedWeightAndBedKey.setWeightNo(matchedMstWeight.getWeightNo());
        scaleBedWeightAndBedKeyList.add(scaleBedWeightAndBedKey);
      }
    }
    return scaleBedWeightAndBedKeyList;
  }

  @Transactional
  @Override
  public CheckSendableConditionResult checkSendableCondition(Long bedCd, Long weightCd, Long ordNo, BigDecimal measureValue, NtssUser user) {

    var result = new CheckSendableConditionResult();
    var eventLogMessage = new EventLogMessage();
    var scaleBedState = mntScaleBedStateDao.selectByBedCd(bedCd);
    var machineStateArray = machineStateDao.selectByBedCd(bedCd);
    var mstWeight = mstWeightDao.selectByWeightCd(weightCd);

    if  (scaleBedState == null || machineStateArray == null || machineStateArray.isEmpty() ||  mstWeight == null) {
      result.setSuccess(Boolean.FALSE);
      return result;
    }

    var machineState = machineStateArray.get(0);

    eventLogMessage.setFacilityCd(scaleBedState.getFacilityCd());

    if (mstWeight.getIsDefaultPrintBefore().equals("1")) {
      // 条件送信が成功しなかった場合に備え、戻り値に[患者未登録でのレシート印刷に必要なもの]をセット(※成功時は後から正しいものがセットされる)
      var ppTmp = new CheckingParameter.PrintParameter();
      ppTmp.setFacilityName(weightService.findFacilityName(user.getFacilityCd()));
      var cpForNoPatPrint = new CheckingParameter();
      cpForNoPatPrint.setPrintParameter(ppTmp);
      cpForNoPatPrint.setMeasureValue(measureValue);

      var scrForNoPatPrint = new SendConditionRequest();
      scrForNoPatPrint.setIsPrint("1");
      scrForNoPatPrint.setScaleClass((short) 2); // 重量測定
      scrForNoPatPrint.setWeightScaleNo(scaleBedState.getBeforeWeightScaleNo());
      scrForNoPatPrint.setPrintContent(buildPrintContent(cpForNoPatPrint, mstWeight, scrForNoPatPrint, user));

      result.setSendConditionRequest(scrForNoPatPrint);
    }

    // 本日の日付を取得
    Timestamp measureDate = Timestamp.valueOf(LocalDateTime.now());

    // ord_main から治療情報取得
    if (ordNo == null) {
      // 条件送信対象無し
      eventLogMessage.setLogMessage("送信対象ord_no無し");
      logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
      result.setSuccess(Boolean.FALSE);
      result.setMessage("送信対象ord_no無し");
      // エラー
      scaleBedStateService.updateSendStatusError(bedCd, true, scaleBedState.getBeforeWeightScaleNo());
      return result;
    }
    var ordParameters = weightService.buildOrderResponse(ordNo);
    var ordMain = ordMainDao.selectByOrdNo(ordNo);

    // MEMO: ord_main.rst_dialysis_stateがすでに後体重測定待ち状態だったりすると md_cd が間違ってるってことなのでエラー
    if(Integer.parseInt(ordMain.getRstDialysisState()) > 1) {
      // 前体重測受信したが、透析中以降の透析状態だった場合
      eventLogMessage.setLogMessage("前後体重不一致");
      logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
      result.setSuccess(Boolean.FALSE);
      result.setMessage("前後体重不一致");
      // エラー
      scaleBedStateService.updateSendStatusError(bedCd, true, scaleBedState.getBeforeWeightScaleNo());
      return result;
    }

    // 治療予定の薬剤・医療材料が適切か、マスタで削除フラグが立っているか、期限切れかどうかチェック
    if (!checkIndCondMedicineAndEquip(bedCd, ordMain, user.getFacilityCd())) {
      // 薬剤・医療材料が要確認
      eventLogMessage.setLogMessage("薬剤・医療材料の使用に確認が必要");
      logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
      result.setSuccess(Boolean.FALSE);
      result.setMessage("薬剤・医療材料の使用に確認が必要");
      // 警告
      scaleBedStateService.updateSendStatusWarning(bedCd, true, scaleBedState.getBeforeWeightScaleNo());
      return result;
    }

    var checkScaleParam = checkScaleService.buildCheckingParameter(
      measureValue,
      measureDate,
      ordNo,
      CheckScaleService.ScaleMode.BEFORE,
      user.getFacilityCd(),
      bedCd);

    // 測定値チェック
    switch (checkScaleService.checkScaleAsNumber(checkScaleParam, mstWeight, CheckScaleService.ScaleMode.BEFORE, user.getFacilityCd())) {
      case 1:
        // 警告
      {
        eventLogMessage.setLogMessage("測定値チェックが警告");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        result.setSuccess(Boolean.FALSE);
        result.setMessage("測定値チェックが警告");
        // 警告
        scaleBedStateService.updateSendStatusWarning(bedCd, true, scaleBedState.getBeforeWeightScaleNo());
        return result;
      }
      case 2:
        // エラー
      {
        eventLogMessage.setLogMessage("測定値チェックがエラー");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        result.setSuccess(Boolean.FALSE);
        result.setMessage("測定値チェックがエラー");
        // 警告
        scaleBedStateService.updateSendStatusError(bedCd, true, scaleBedState.getBeforeWeightScaleNo());
        return result;
      }
    }

    Long weightScaleNo = scaleBedState.getBeforeWeightScaleNo();
    var ordWeightScale = weightScaleNo != null ? ordWeightScaleDao.selectByCd(weightScaleNo) : null;

    if (ordWeightScale != null && (ordWeightScale.getWeightScaleStatus() == 1 || ordWeightScale.getWeightScaleStatus() == 3 || ordWeightScale.getWeightScaleStatus() == 4 )){
      // 関連する測定履歴が条件送信済み
      weightScaleNo = null;
    }

    // 条件送信パラメータ作成
    var sendConditionRequest = new SendConditionRequest();
    sendConditionRequest.setScaleBedBedCd(bedCd);
    sendConditionRequest.setWeightScaleNo(weightScaleNo);
    sendConditionRequest.setOrdNo(ordNo);
    sendConditionRequest.setFacilityCd(scaleBedState.getFacilityCd());
    sendConditionRequest.setWeightNo(mstWeight.getWeightNo());
    sendConditionRequest.setPatId(machineState.getNextPatid());
    sendConditionRequest.setKurCd(machineState.getNextKurCd());
    sendConditionRequest.setBedCd(bedCd);
    sendConditionRequest.setWeightCd(mstWeight.getWeightCd());
    sendConditionRequest.setTare(ordParameters.ord.getIndTareInfo());
    sendConditionRequest.setTareFlg((short)0);
    sendConditionRequest.setOffWater(ordParameters.ord.getIndOffWaterInfo());
    sendConditionRequest.setOffWaterFlg((short)0);
    sendConditionRequest.setScaleValue(checkScaleParam.getMeasureValue());
    sendConditionRequest.setUserId(user.getUserId());
    sendConditionRequest.setWeightName(mstWeight.getWeightName());
    sendConditionRequest.setTreatmentCd(ordParameters.ord.getIndTreatmentCd());
    sendConditionRequest.setDeviceMode(ordParameters.ord.getIndDeviceMode());
    sendConditionRequest.setScaleClass((short)0); // 前体重:0
    sendConditionRequest.setScaleMode((short)0); // 車いすなしの体重のみ:0
    sendConditionRequest.setIsPrint(mstWeight.getIsDefaultPrintBefore());
    sendConditionRequest.setMstDelFlg(true);
    sendConditionRequest.setChkIndCondInfoFlg(true);
    sendConditionRequest.setMstOverdueFlg(true);

    // クール名セット
    sendConditionRequest.setKurName(ordParameters.ord.getIndKurName());
    // ベッド名セット
    sendConditionRequest.setBedName(ordParameters.ord.getIndBedName());
    // 治療名セット
    sendConditionRequest.setTreatmentName(ordParameters.ord.getIndTreatmentName());
    // 測定日時セット
    sendConditionRequest.setMeasureDate(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(measureDate.toInstant().atZone(java.time.ZoneId.systemDefault())));

    // DWセット
    sendConditionRequest.setDw(checkScaleParam.getByCode(CheckingParameterCode.DW));

    // 目標体重セット
    sendConditionRequest.setTargetWeight(checkScaleParam.getTargetWeight());

    // 前体重 = 測定値-風袋合計値
    sendConditionRequest.setWeightValue(checkScaleParam.getBeforeWeight());

    // 目標除水量セット
    sendConditionRequest.setTargetOffWater(checkScaleParam.getTargetOffWater());
    // 除水制限セット
    sendConditionRequest.setLimitOffWater(checkScaleParam.getLimitOffWater());

    // 集まったデータを使って 印刷データjson を作成
    String printContent = buildPrintContent(checkScaleParam, mstWeight, sendConditionRequest, user);
    sendConditionRequest.setPrintContent(printContent);

    result.setSuccess(Boolean.TRUE);
    result.setSendConditionRequest(sendConditionRequest);
    return result;
  }


  @Transactional
  @Override
  public CheckSendableConditionResult checkSendableAfterWeight(Long bedCd, Long weightCd, Long ordNo, BigDecimal measureValue, NtssUser user) {

    var result = new CheckSendableConditionResult();
    var eventLogMessage = new EventLogMessage();

    var scaleBedState = mntScaleBedStateDao.selectByBedCd(bedCd);
    var machineStateArray = machineStateDao.selectByBedCd(bedCd);
    var mstWeight = mstWeightDao.selectByWeightCd(weightCd);

    if  (scaleBedState == null || machineStateArray == null || machineStateArray.isEmpty() ||  mstWeight == null) {
      result.setSuccess(Boolean.FALSE);
      return result;
    }
    eventLogMessage.setFacilityCd(scaleBedState.getFacilityCd());

    // 本日の日付を取得
    Timestamp measureDate = Timestamp.valueOf(LocalDateTime.now());

    if (mstWeight.getIsDefaultPrintAfter().equals("1")) {
      // 条件送信が成功しなかった場合に備え、戻り値に[患者未登録でのレシート印刷に必要なもの]をセット(※成功時は後から正しいものがセットされる)
      var ppTmp = new CheckingParameter.PrintParameter();
      ppTmp.setFacilityName(weightService.findFacilityName(user.getFacilityCd()));
      var cpForNoPatPrint = new CheckingParameter();
      cpForNoPatPrint.setPrintParameter(ppTmp);
      cpForNoPatPrint.setMeasureValue(measureValue);

      var scrForNoPatPrint = new SendConditionRequest();
      scrForNoPatPrint.setIsPrint("1");
      scrForNoPatPrint.setScaleClass((short) 2); // 重量測定
      scrForNoPatPrint.setWeightScaleNo(scaleBedState.getAfterWeightScaleNo());
      scrForNoPatPrint.setPrintContent(buildPrintContent(cpForNoPatPrint, mstWeight, scrForNoPatPrint, user));

      result.setSendConditionRequest(scrForNoPatPrint);
    }

    // ord_main から治療情報取得
    if (ordNo == null) {
      // 条件送信対象無し
      eventLogMessage.setLogMessage("送信対象ord_no無し");
      logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
      result.setSuccess(Boolean.FALSE);
      result.setMessage("送信対象ord_no無し");
      // エラー
      scaleBedStateService.updateSendStatusError(bedCd, false, scaleBedState.getAfterWeightScaleNo());
      return result;
    }
    var ordParameters = weightService.buildOrderResponse(ordNo);
    var ordMain = ordMainDao.selectByOrdNo(ordNo);

    // ord_main.rst_dialysis_stateが前体重測定待ち状態だったりすると md_cd が間違ってるってことなのでエラー
    if(Integer.parseInt(ordMain.getRstDialysisState()) < 4) {
      // 後体重測受信したが、排液前の状態だった場合
      eventLogMessage.setLogMessage("前後体重不一致");
      logService.log(LogLevel.INFO, eventLogMessage,"", LoggingConstant.SERVICE_NAME.FNSI, null);
      result.setSuccess(Boolean.FALSE);
      result.setMessage("前後体重不一致");
      // エラー
      scaleBedStateService.updateSendStatusError(bedCd, false, scaleBedState.getAfterWeightScaleNo());
      return result;
    }

    // 測定値チェック
    var checkScaleParam = checkScaleService.buildCheckingParameter(
      measureValue,
      measureDate,
      ordNo,
      CheckScaleService.ScaleMode.AFTER,
      user.getFacilityCd(),
      bedCd
      );

    switch (checkScaleService.checkScaleAsNumber(checkScaleParam, mstWeight, CheckScaleService.ScaleMode.AFTER, user.getFacilityCd())) {
      case 1:
        // 警告
      {
        eventLogMessage.setLogMessage("測定値チェックが警告");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        result.setSuccess(Boolean.FALSE);
        result.setMessage("測定値チェックが警告");
        // 警告
        scaleBedStateService.updateSendStatusWarning(bedCd, false, scaleBedState.getAfterWeightScaleNo());
        return result;
      }
      case 2:
        // エラー
      {
        eventLogMessage.setLogMessage("測定値チェックがエラー");
        logService.log(LogLevel.INFO, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        result.setSuccess(Boolean.FALSE);
        result.setMessage("測定値チェックがエラー");
        // 警告
        scaleBedStateService.updateSendStatusError(bedCd, false, scaleBedState.getAfterWeightScaleNo());
        return result;
      }
    }

    Long weightScaleNo = scaleBedState.getAfterWeightScaleNo();
    var ordWeightScale = weightScaleNo != null ? ordWeightScaleDao.selectByCd(weightScaleNo) : null;

    if (ordWeightScale != null && (ordWeightScale.getWeightScaleStatus() == 1 || ordWeightScale.getWeightScaleStatus() == 3 || ordWeightScale.getWeightScaleStatus() == 4 )){
      // 関連する測定履歴が送信済み
      weightScaleNo = null;
    }

    // 条件送信パラメータ作成
    var sendConditionRequest = new SendConditionRequest();
    sendConditionRequest.setScaleBedBedCd(bedCd);
    sendConditionRequest.setWeightScaleNo(weightScaleNo);
    sendConditionRequest.setOrdNo(ordNo);
    sendConditionRequest.setFacilityCd(scaleBedState.getFacilityCd());
    sendConditionRequest.setWeightNo(mstWeight.getWeightNo());
    sendConditionRequest.setPatId(ordMain.getPatId());
    sendConditionRequest.setKurCd(Long.valueOf(ordMain.getRstKurCd()));
    sendConditionRequest.setKurName(ordMain.getRstKurName());
    sendConditionRequest.setBedCd(bedCd);
    sendConditionRequest.setBedName(ordMain.getRstBedName());
    sendConditionRequest.setWeightCd(mstWeight.getWeightCd());
    sendConditionRequest.setScaleValue(checkScaleParam.getMeasureValue());
    sendConditionRequest.setUserId(user.getUserId());
    sendConditionRequest.setWeightName(mstWeight.getWeightName());
    sendConditionRequest.setTreatmentCd(ordMain.getRstTreatmentCd());
    sendConditionRequest.setTreatmentName(ordMain.getRstTreatmentName());
    sendConditionRequest.setDeviceMode(ordMain.getIndDeviceMode());
    sendConditionRequest.setScaleClass((short)1); // 後体重:1
    sendConditionRequest.setScaleMode((short)0); // 車いすなしの体重のみ:0
    sendConditionRequest.setIsPrint(mstWeight.getIsDefaultPrintAfter());
    // 測定日時セット
    sendConditionRequest.setMeasureDate(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss.SSSXXX").format(measureDate.toInstant().atZone(java.time.ZoneId.systemDefault())));
    // 後体重セット
    sendConditionRequest.setWeightValue(checkScaleParam.getAfterWeight());

    sendConditionRequest.setTare(checkScaleParam.getTareJsonStr());
    sendConditionRequest.setTareFlg((short)0);
    sendConditionRequest.setOffWater(checkScaleParam.getOffWaterJsonStr());
    sendConditionRequest.setOffWaterFlg((short)0);

    // TODO: 以下は本当に必要か？？？

    // 目標除水量セット
    sendConditionRequest.setTargetOffWater(checkScaleParam.getTargetOffWater());
    // 目標体重セット
    sendConditionRequest.setTargetWeight(checkScaleParam.getTargetWeight());
    // 除水制限セット
    sendConditionRequest.setLimitOffWater(checkScaleParam.getLimitOffWater());
    // DWセット
    sendConditionRequest.setDw(checkScaleParam.getByCode(CheckingParameterCode.DW));

    // 集まったデータを使って 印刷データjson を作成
    String printContent = buildPrintContent(checkScaleParam, mstWeight, sendConditionRequest, user);
    sendConditionRequest.setPrintContent(printContent);

    result.setSuccess(Boolean.TRUE);
    result.setSendConditionRequest(sendConditionRequest);
    return result;
  }

  private boolean checkIndCondMedicineAndEquip(Long bedCd, OrdMain ordMain, String facilityCd) {
    // 治療予定の薬剤・医療材料がマスタで削除フラグが立っているか、期限切れかどうかチェック
    // 施設設定で、薬剤のNG判断が変わる。　設定により、YES・NOで送信が実施できるもの（黄色判定
    // できないものがある（赤判定
    // 治療予定の薬剤、医療材料について
    // 指示がない場合そのままTrueで返す。
    // NULLの場合のもしくは、[]だけの処理

    String medicalInfo = ordMain.getIndMediInfo();
    if (ObjectUtils.isEmpty(medicalInfo) || "[]".equals(medicalInfo)) {
      return true;
    }

    // 分類不一致発生時条件送信設定
    String CHK_IND_COND_INFO = "3009";
    // マスタ削除発生時条件送信設定
    String CHK_MSG_DEL = "3018";
    // マスタ期限切れ発生時条件送信設定
    String CHK_MSG_OVERDUE = "3019";
    var settingCdList = new String[]{CHK_IND_COND_INFO, CHK_MSG_DEL, CHK_MSG_OVERDUE};

    // 施設設定を取得
    var facilitySetting = facilitySettingService.getFacilitySettingValueMap(facilityCd, Arrays.stream(settingCdList).toList());
    String facilityValueIndCondCheck = facilitySetting.get(CHK_IND_COND_INFO);
    String facilityValueMstDeleted = facilitySetting.get(CHK_MSG_DEL);
    String facilityValueMstOverDue = facilitySetting.get(CHK_MSG_OVERDUE);
    // 治療条件に不適切な分類の薬剤、医療材料が指定されてる場合はfalseを返す
    // マスタで削除フラグが立っている場合はfalseを返す
    // 有効期限が過ぎている場合はfalseを返す
    var resCheck = weightService.getChkIndCondInfoData(ordMain.getOrdNo(), 0L, false, false, false);

    if (!resCheck.mstDelFlgMsgList.isEmpty()) {
      // マスタ削除の場合
      if (Objects.equals(facilityValueIndCondCheck, "0")){
        // 0の場合送信不可　赤
        scaleBedStateService.updateSendStatusError(bedCd, true, ordMain.getWeightScaleNo());
      } else {
        // 送信可能　黄色
        scaleBedStateService.updateSendStatusWarning(bedCd, true, ordMain.getWeightScaleNo());
      }
      return false;
    }
    if (!resCheck.mstOverdueMsgList.isEmpty()) {
      // マスタ期限切れ
      if (Objects.equals(facilityValueMstDeleted, "0")){
        // 0の場合送信不可　赤
        scaleBedStateService.updateSendStatusError(bedCd, true, ordMain.getWeightScaleNo());
      } else {
        // 送信可能　黄色
        scaleBedStateService.updateSendStatusWarning(bedCd, true, ordMain.getWeightScaleNo());
      }
      return false;
    }
    if (!resCheck.msgList.isEmpty()){
      // 治療条件不一致
      if (Objects.equals(facilityValueMstOverDue, "0")){
        // 0の場合送信不可　赤
        scaleBedStateService.updateSendStatusError(bedCd, true, ordMain.getWeightScaleNo());
      } else {
        // 送信可能　黄色
        scaleBedStateService.updateSendStatusWarning(bedCd, true, ordMain.getWeightScaleNo());
      }
      return false;
    }
    return true;
  }

  /**
   * 印刷内容jsonを作る
   */
  private String buildPrintContent(CheckingParameter cp, MstWeight mw, SendConditionRequest scr, NtssUser ntssUser) {
    var printedTs = Timestamp.valueOf(LocalDateTime.now());

    if (scr.getIsPrint().equals("0")) {
      return "";
    }

    var mapper = new ObjectMapper();
    PrintConfig pConfListAll;
    try {
      pConfListAll = mapper.readValue(mw.getPrintSetting(), PrintConfig.class);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("ERROR 印刷内容生成時の印刷項目設定jsonのパースに失敗 : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return "";
    }

    var pConfListUse = switch (scr.getScaleClass()) {
      case 0 -> // 前体重 →　前体重印字設定を使用
        pConfListAll.before;
      case 1 -> // 後体重 →　後体重印字設定を使用
        pConfListAll.after;
      case 2 -> // 重量測定 → 患者未登録印字設定を使用
        pConfListAll.noPat;
      case 4 -> // スケジュールなし患者 → スケジュールなし印字設定を使用
        pConfListAll.noSchedule;
      default -> null;
    };

    if (pConfListUse == null) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("ERROR 体重測定区分が不正のため印刷項目設定が不定");
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return "";
    }

    Objects.requireNonNull(pConfListUse).sort(Comparator.comparing(x -> x.dispOrder));
    var retJsonBaseMap = new LinkedHashMap<String, Object>();


    //// 検査データの取得処理
    List<PatExamMainWeightPrint> examDataForPrintList = new ArrayList<>();
    if (scr.getPatId() != null) {
      var pepReq = new PatExamPrintRequest();
      var pepItemCdList = new ArrayList<PatExamPrint>();

      // 印刷項目設定を舐めて検査結果のものがあるかをチェック
      for (var pConf : pConfListUse) {
        // 印刷項目設定の「1つの印刷項目」のアイテムソース区分が「1:検査結果から」かつ「アイテムコード指定あり」
        if (pConf.itemSource == 1 && pConf.itemCd != null) {
          var addPep = new PatExamPrint();
          addPep.setItem_cd(pConf.itemCd.toString());
          addPep.setExam_class(pConf.examClass != null ? pConf.examClass : "1");
          pepItemCdList.add(addPep);
        }
      }

      if (!pepItemCdList.isEmpty()) {
        // 印刷項目に1個でも検査データがあれば検査データを取得
        pepReq.setPatId(scr.getPatId());
        pepReq.setBaseDate(printedTs.toLocalDateTime().format(DateTimeFormatter.ofPattern("yyyyMMdd")));
        pepReq.setItemCdList(pepItemCdList);
        var feifpRes = weightResource.fetchExamInfoForPrinter(pepReq, ntssUser);
        // 成功時にはresのbodyに List<PatExamMainWeightPrint> がセットされるので型チェックしてセット
        if (feifpRes.getBody() instanceof List<?> tmpList) {
          if (!tmpList.isEmpty() && tmpList.get(0) instanceof PatExamMainWeightPrint) {
            @SuppressWarnings("unchecked")
            List<PatExamMainWeightPrint> safeCastedList = (List<PatExamMainWeightPrint>) tmpList;
            examDataForPrintList = safeCastedList;
          }
        }
      }
    }


    //// 実際に印刷項目のデータを生成
    for (var pConf : pConfListUse) {
      var row = new LinkedHashMap<>(Map.of(
        "class", 0, // [0]はテキスト
        "value", "",
        "font_size", pConf.fontSize
      ));
      var before_word = pConf.beforeWord == null || pConf.beforeWord.equals("null") ? "" : pConf.beforeWord;
      var after_word = pConf.afterWord == null || pConf.afterWord.equals("null") ? "" : pConf.afterWord;

      if (pConf.itemSource == 1) { // アイテムソース区分が「1:検査結果から」
        var mainContent = "未検査";
        var dateStr = "";

        var found
          = examDataForPrintList.stream()
          .filter(x -> Objects.equals(x.getItemCd(), pConf.itemCd.toString()))
          .findFirst();
        if (found.isPresent()) {
          mainContent = found.get().getResult();
          String jsToJavaFormatStr = pConf.dataFormat.replace("YYYY", "yyyy").replace("DD", "dd");
          DateTimeFormatter formatter = DateTimeFormatter.ofPattern(jsToJavaFormatStr);
          dateStr = found.get().getResultExamDate().toLocalDateTime().format(formatter);
        }

        if (pConf.datePosition == 0) {
          row.put("value", String.format("%s %s%s%s", dateStr, before_word, mainContent, after_word));
        } else {
          row.put("value", String.format("%s%s%s %s", before_word, mainContent, after_word, dateStr));
        }
      } else if (pConf.itemSource == 2) { // アイテムソース区分が「2:チェック項目から」
        // データ定義文字列群を(例."[dw]") を 実データ文字列(例."54.32") に置換
        var replacedCalcStr  = pConf.calculate;
        for (var code : CheckingParameterCode.ALL_CODE) {
          replacedCalcStr = replacedCalcStr.replace(code, cp.getByCode(code) == null ? "0" : cp.getByCode(code));
        }

        switch (pConf.dataType) {
          case 0: // 計算(※データ定義文字列をデータで置換した後、それを計算式文字列として扱って計算した結果を出力)
            // 全角SP・半角SP・タブ・改行などの「セパレータ系文字」を排除
            var cleanedCalcStr = replacedCalcStr.replaceAll("[\\s\\p{Z}]+", "");
            // 外部ライブラリで計算式文字列を計算
            var calculator = new NumberCalculator();
            try {
              var calcResult = new BigDecimal(calculator.calculation(cleanedCalcStr).toString());
              row.put("value", buildNumberPrintData(calcResult, pConf, "<計算失敗>"));
            } catch (Exception ignored) {
              row.put("value", before_word + "計算失敗" + after_word);
            }
            break;
          case 1: // 日付(※データ定義文字列をデータで置換した文字列を出力)
            row.put("value", before_word + (replacedCalcStr == null ? "" : replacedCalcStr) + after_word);
            break;
          default: // それ以外(※データ定義文字列をデータで置換した文字列を出力だが、前表示文字列や後表示文字列は付与しない)
            row.put("value", replacedCalcStr == null ? "" : replacedCalcStr);
            break;
        }
      } else if (pConf.itemSource == 0) { // アイテムソース区分が「0:マスタ項目から」
        var mainContent = "";
        switch (pConf.itemCd) {
          case 0: // (空行)
            row.put("value", "");
            break;
          case 1: // 現在日時
            var jsToJavaFormatStr = pConf.dataFormat.replace("YYYY", "yyyy").replace("DD", "dd");
            var formatter = DateTimeFormatter.ofPattern(jsToJavaFormatStr);
            row.put("value", before_word + printedTs.toLocalDateTime().format(formatter) + after_word);
            break;
          case 2: // ベッド名
            mainContent = cp.getPrintParameter().getBedName();
            // #11146 2026.06.08 mod データがない場合は全角スペース４文字を出力する TDC米沢 start
            mainContent = (StringUtils.isNotEmpty(mainContent) ? mainContent: "　　　　");
            // #11146 2026.06.08 mod データがない場合は全角スペース４文字を出力する TDC米沢 end
            row.put("value", before_word + (mainContent == null ? "" : mainContent) + after_word);
            break;
          case 3: // 患者ID(院内)
            mainContent = cp.getPrintParameter().getHospPatId();
            // #11146 2026.06.08 mod データがない場合は全角スペース４文字を出力する TDC米沢 start
            mainContent = (StringUtils.isNotEmpty(mainContent) ? mainContent: "　　　　");
            // #11146 2026.06.08 mod データがない場合は全角スペース４文字を出力する TDC米沢 end
            row.put("value", before_word + (mainContent == null ? "" : mainContent) + after_word);
            break;
          case 4: // 患者名
            mainContent = cp.getPrintParameter().getPatName();
            // #11146 2026.06.08 mod データがない場合は全角スペース４文字を出力する TDC米沢 start
            mainContent = (StringUtils.isNotEmpty(mainContent) ? mainContent: "　　　　");
            // #11146 2026.06.08 mod データがない場合は全角スペース４文字を出力する TDC米沢 end
            row.put("value", before_word + mainContent + after_word);
            break;
          case 5: // 透析時間
            if (cp.getPrintParameter().getDialysisTime() != null) {
              var dialysisTime = new BigDecimal(cp.getPrintParameter().getDialysisTime()).intValue();
              mainContent = String.format("%02d:%02d", dialysisTime / 60, dialysisTime % 60);
            } else {
              mainContent = "不明";
            }
            row.put("value", before_word + mainContent + after_word);
            break;
          case 6: // DW
            row.put("value", buildNumberPrintData(cp.getDw(), pConf, "未測定"));
            break;
          case 7: // 目標体重
            row.put("value", buildNumberPrintData(cp.getTargetWeight(), pConf, "未設定"));
            break;
          case 8: // 測定値
            row.put("value", buildNumberPrintData(cp.getMeasureValue(), pConf, "未測定"));
            break;
          case 9: // 前体重
            row.put("value", buildNumberPrintData(cp.getBeforeWeight(), pConf, "未測定"));
            break;
          case 10: // 後体重
            row.put("value", buildNumberPrintData(cp.getAfterWeight(), pConf, "未測定"));
            break;
          case 11: // 前回後体重
            row.put("value", buildNumberPrintData(cp.getLastAfterWeight(), pConf, "未測定"));
            break;
          case 12: // 前体重 / DW
            if (cp.getBeforeWeight() == null) {
              row.put("value", before_word + "未測定" + after_word);
            } else if (cp.getDw() == null) {
              row.put("value", before_word + "未設定" + after_word);
            } else {
              row.put("value", buildNumberPrintData(cp.getBeforeWeight().divide(cp.getDw(), 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
            }
            break;
          case 13: // 後体重 / DW
            if (cp.getAfterWeight() == null) {
              row.put("value", before_word + "未測定" + after_word);
            } else if (cp.getDw() == null) {
              row.put("value", before_word + "未設定" + after_word);
            } else {
              row.put("value", buildNumberPrintData(cp.getAfterWeight().divide(cp.getDw(), 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
            }
            break;
          case 14: // 体重増減(前体重 - 前回後体重)
            if (cp.getBeforeWeight() == null) {
              row.put("value", before_word + "未測定" + after_word);
            } else if (cp.getLastAfterWeight() == null) {
              row.put("value", before_word + "未設定" + after_word);
            } else {
              row.put("value", buildNumberPrintData(cp.getBeforeWeight().subtract(cp.getLastAfterWeight()), pConf, "<計算失敗>"));
            }
            break;
          case 15: // 体重前後差(前体重 - 後体重)
            if (cp.getBeforeWeight() == null) {
              row.put("value", before_word + "未測定" + after_word);
            } else if (cp.getAfterWeight() == null) {
              row.put("value", before_word + "未設定" + after_word);
            } else {
              row.put("value", buildNumberPrintData(cp.getBeforeWeight().subtract(cp.getAfterWeight()), pConf, "<計算失敗>"));
            }
            break;
          case 16: // 除水目標値
            row.put("value", buildNumberPrintData(cp.getTargetOffWater(), pConf, ""));
            break;
          case 17: // 除水制限値
            row.put("value", buildNumberPrintData(cp.getLimitOffWater(), pConf, ""));
            break;
          case 18: // 引き残し
            if (scr.getScaleClass() == 0 || scr.getScaleClass() == 4) { // 前体重 or スケジュールなし患者
              // 前体重 - 目標体重 - 除水制限 + 除水補正値(計算でマイナスになったら[0])
              if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getTargetWeight() == null || cp.getLimitOffWater() == null || cp.getOffWater() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                var tmp = cp.getBeforeWeight().subtract(cp.getTargetWeight()).subtract(cp.getLimitOffWater()).add(cp.getOffWater());
                if (tmp.compareTo(BigDecimal.ZERO) < 0) {
                  tmp = new BigDecimal(0);
                }
                row.put("value", buildNumberPrintData(tmp, pConf, "<計算失敗>"));
              }
            } else if (scr.getScaleClass() == 1) { // 後体重
              // 後体重 - 目標体重
              if (cp.getAfterWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getTargetWeight() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                row.put("value", buildNumberPrintData(cp.getAfterWeight().subtract(cp.getTargetWeight()), pConf, "<計算失敗>"));
              }
            } else {
              row.put("value", before_word + "未設定" + after_word);
            }
            break;
          case 19: // 風袋
            row.put("value", buildNumberPrintData(cp.getTare(), pConf, ""));
            break;
          case 20: // 除水補正値
            row.put("value", buildNumberPrintData(cp.getOffWater(), pConf, ""));
            break;
          case 21: // DWからの差
            if (scr.getScaleClass() != 0 && scr.getScaleClass() != 1 && scr.getScaleClass() != 4) {
              row.put("value", before_word + "未設定" + after_word);
            } else if (scr.getScaleClass() == 0 || scr.getScaleClass() == 4) { // 前体重 or スケジュールなし患者
              // 前体重 - DW
              if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getDw() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                row.put("value", buildNumberPrintData(cp.getBeforeWeight().subtract(cp.getDw()), pConf, "<計算失敗>"));
              }
            } else if (scr.getScaleClass() == 1) { // 後体重
              // 後体重 - DW
              if (cp.getAfterWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getDw() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                row.put("value", buildNumberPrintData(cp.getAfterWeight().subtract(cp.getDw()), pConf, "<計算失敗>"));
              }
            }
            break;
          case 22: // DWからの割合
            if (scr.getScaleClass() != 0 && scr.getScaleClass() != 1 && scr.getScaleClass() != 4) {
              row.put("value", before_word + "未設定" + after_word);
            } else if (scr.getScaleClass() == 0 || scr.getScaleClass() == 4) { // 前体重 or スケジュールなし患者
              // 前体重 / (DW / 100)
              if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getDw() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                var dwDiv100 = cp.getDw().divide(BigDecimal.valueOf(100), 11, RoundingMode.HALF_UP);
                row.put("value", buildNumberPrintData(cp.getBeforeWeight().divide(dwDiv100, 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
              }
            } else if (scr.getScaleClass() == 1) { // 後体重
              // 後体重 / (DW / 100)
              if (cp.getAfterWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getDw() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                var dwDiv100 = cp.getDw().divide(BigDecimal.valueOf(100), 11, RoundingMode.HALF_UP);
                row.put("value", buildNumberPrintData(cp.getAfterWeight().divide(dwDiv100, 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
              }
            }
            break;
          case 23: // 目標体重からの差
            if (scr.getScaleClass() != 0 && scr.getScaleClass() != 1 && scr.getScaleClass() != 4) {
              row.put("value", before_word + "未設定" + after_word);
            } else if (scr.getScaleClass() == 0 || scr.getScaleClass() == 4) { // 前体重 or スケジュールなし患者
              // 前体重 - 目標体重
              if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getTargetWeight() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                row.put("value", buildNumberPrintData(cp.getBeforeWeight().subtract(cp.getTargetWeight()), pConf, "<計算失敗>"));
              }
            } else if (scr.getScaleClass() == 1) { // 後体重
              // 後体重 - 目標体重
              if (cp.getAfterWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getTargetWeight() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                row.put("value", buildNumberPrintData(cp.getAfterWeight().subtract(cp.getTargetWeight()), pConf, "<計算失敗>"));
              }
            }
            break;
          case 24: // 目標体重からの割合
            if (scr.getScaleClass() != 0 && scr.getScaleClass() != 1 && scr.getScaleClass() != 4) {
              row.put("value", before_word + "未設定" + after_word);
            } else if (scr.getScaleClass() == 0 || scr.getScaleClass() == 4) { // 前体重 or スケジュールなし患者
              // 前体重 / (目標体重 / 100)
              if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getTargetWeight() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                var twDiv100 = cp.getTargetWeight().divide(BigDecimal.valueOf(100), 11, RoundingMode.HALF_UP);
                row.put("value", buildNumberPrintData(cp.getBeforeWeight().divide(twDiv100, 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
              }
            } else if (scr.getScaleClass() == 1) { // 後体重
              // 後体重 / (目標体重 / 100)
              if (cp.getAfterWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getTargetWeight() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                var twDiv100 = cp.getTargetWeight().divide(BigDecimal.valueOf(100), 11, RoundingMode.HALF_UP);
                row.put("value", buildNumberPrintData(cp.getAfterWeight().divide(twDiv100, 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
              }
            }
            break;
          case 25: // 前回からの差
            if (scr.getScaleClass() != 0 && scr.getScaleClass() != 1 && scr.getScaleClass() != 4) {
              row.put("value", before_word + "未設定" + after_word);
            } else if (scr.getScaleClass() == 0 || scr.getScaleClass() == 4) { // 前体重 or スケジュールなし患者
              // 前体重 - 前回後体重
              if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getLastAfterWeight() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                row.put("value", buildNumberPrintData(cp.getBeforeWeight().subtract(cp.getLastAfterWeight()), pConf, "<計算失敗>"));
              }
            } else if (scr.getScaleClass() == 1) { // 後体重
              // 後体重 - 前体重
              if (cp.getAfterWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                row.put("value", buildNumberPrintData(cp.getAfterWeight().subtract(cp.getBeforeWeight()), pConf, "<計算失敗>"));
              }
            }
            break;
          case 26: // 前回からの割合
            if (scr.getScaleClass() != 0 && scr.getScaleClass() != 1 && scr.getScaleClass() != 4) {
              row.put("value", before_word + "未設定" + after_word);
            } else if (scr.getScaleClass() == 0 || scr.getScaleClass() == 4) { // 前体重 or スケジュールなし患者
              // 前体重 / (前回後体重 / 100)
              if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getLastAfterWeight() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                var lwDiv100 = cp.getLastAfterWeight().divide(BigDecimal.valueOf(100), 11, RoundingMode.HALF_UP);
                row.put("value", buildNumberPrintData(cp.getBeforeWeight().divide(lwDiv100, 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
              }
            } else if (scr.getScaleClass() == 1) { // 後体重
              // 後体重 / (前体重 / 100)
              if (cp.getAfterWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未設定" + after_word);
              } else {
                var bwDiv100 = cp.getBeforeWeight().divide(BigDecimal.valueOf(100), 11, RoundingMode.HALF_UP);
                row.put("value", buildNumberPrintData(cp.getAfterWeight().divide(bwDiv100, 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
              }
            }
            break;
          case 27: // BMI
            if (scr.getScaleClass() != 0 && scr.getScaleClass() != 1 && scr.getScaleClass() != 4) {
              row.put("value", before_word + "未設定" + after_word);
            } else if (scr.getScaleClass() == 0 || scr.getScaleClass() == 4) { // 前体重 or スケジュールなし患者
              // 前体重 / (身長(m) × 身長(m))
              if (cp.getBeforeWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getPatHeight() == null) {
                row.put("value", before_word + "身長未設定" + after_word);
              } else {
                var heightByMeter = cp.getPatHeight().divide(BigDecimal.valueOf(100), 11, RoundingMode.HALF_UP);
                var squaredHeightByMeter = heightByMeter.multiply(heightByMeter);
                row.put("value", buildNumberPrintData(cp.getBeforeWeight().divide(squaredHeightByMeter, 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
              }
            } else if (scr.getScaleClass() == 1) { // 後体重
              // 後体重 / (身長(m) × 身長(m))
              if (cp.getAfterWeight() == null) {
                row.put("value", before_word + "未測定" + after_word);
              } else if (cp.getPatHeight() == null) {
                row.put("value", before_word + "身長未設定" + after_word);
              } else {
                var heightByMeter = cp.getPatHeight().divide(BigDecimal.valueOf(100), 11, RoundingMode.HALF_UP);
                var squaredHeightByMeter = heightByMeter.multiply(heightByMeter);
                row.put("value", buildNumberPrintData(cp.getAfterWeight().divide(squaredHeightByMeter, 11, RoundingMode.HALF_UP), pConf, "<計算失敗>"));
              }
            }
            break;
          case 28: // フリーテキスト
            row.put("value", before_word);
            break;
          case 29: // 罫線 ※設定文字列を繰り返し連結し「頭から30文字」を使用
            row.put("class", 1);
            StringBuilder sb = new StringBuilder();
            while (sb.length() < 30) {
              sb.append(before_word);
            }
            row.put("value", sb.substring(0, 30));
            break;
          case 30: // NW-7
            row.put("class", 2);
            mainContent = cp.getPrintParameter().getHospPatId();
            row.put("value", mainContent == null ? "" : mainContent);
            break;
          case 31: // JAN13
            row.put("class", 3);
            mainContent = cp.getPrintParameter().getHospPatId();
            row.put("value", mainContent == null ? "" : mainContent);
            break;
          case 32: // 次回予定日
            try {
              var jsToJavaFormatStr2 = pConf.dataFormat.replace("YYYY", "yyyy").replace("DD", "dd");
              var formatter2 = DateTimeFormatter.ofPattern(jsToJavaFormatStr2);
              row.put("value", before_word + cp.getPrintParameter().getNextSchedule().toLocalDateTime().format(formatter2) + after_word);
            } catch (Exception ignored) {
              row.put("value", before_word + "未設定" + after_word);
            }
            break;
          case 33: // 施設名称
            mainContent = cp.getPrintParameter().getFacilityName();
            row.put("value", before_word + (mainContent == null ? "" : mainContent) + after_word);
            break;
          case 34: // 用紙カット
            row.put("class", 4);
            row.put("value", "");
            break;
        }
      } else {
        continue;
      }


      // 準備した1行分の印刷内容を row_1, row_2 として格納していく
      retJsonBaseMap.put("row_" + (retJsonBaseMap.size() + 1), row);
    }

    // {"row_1":{"class":0,"value":"2026/03/06 12:34:56","font_size":0},"row_2":{"class":0,"value":"DW: 54.00kg","font_size":2},"row_size":2}
    // のようなフォーマットでjson文字列を生成して返す
    retJsonBaseMap.put("row_size", retJsonBaseMap.size()); // row_1, row_2 など は上記でセット済なので最後に行数をセット
    try {
      return mapper.writeValueAsString(retJsonBaseMap);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("ERROR 印刷内容jsonの生成に失敗 : " + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return "";
    }
  }

  /**
   * @param value 各種型の数値 や 数値の文字列(小数点OK) や BigDecimal や null
   */
  private BigDecimal safeNewBigDecimal(Object value) {
    BigDecimal bdRet;

    if (value == null) {
      bdRet = null;
    } else if (value instanceof BigDecimal) {
      bdRet = (BigDecimal) value;
    } else {
      try {
        bdRet = new BigDecimal(String.valueOf(value));
      } catch (Exception e) {
        bdRet = null;
      }
    }

    return bdRet;
  }

  /**
   * @param value 各種型の数値 や 数値の文字列(小数点OK) や BigDecimal や null
   */
  private String buildNumberPrintData(Object value, PrintConfig.PrintConfigItem pConf, String whenNullStr) {
    String beforeWord = (pConf.beforeWord == null || "null".equals(pConf.beforeWord)) ? "" : pConf.beforeWord;
    String afterWord = (pConf.afterWord == null || "null".equals(pConf.afterWord)) ? "" : pConf.afterWord;

    if (value == null) {
      return beforeWord + whenNullStr + afterWord;
    }

    BigDecimal bdVal;
    if (value instanceof BigDecimal) {
      bdVal = (BigDecimal) value;
    } else {
      try {
        bdVal = new BigDecimal(String.valueOf(value));
      } catch (Exception e) {
        return beforeWord + "<計算失敗>" + afterWord;
      }
    }

    // フォーマットの解析("5.2"->intPartLimit=5,digit=2、"4."->intPartLimit=4,digit=0、"3"->intPartLimit=3,digit=0)
    int intPartLimit;
    int digit;
    try {
      String[] fmt = pConf.dataFormat.split("\\.");
      intPartLimit = Integer.parseInt(fmt[0]);
      digit = (fmt.length > 1) ? Integer.parseInt(fmt[1]) : 0;
    } catch (Exception e) {
      return beforeWord + "<計算失敗>" + afterWord;
    }

    // 四捨五入して小数点以下の桁数を固定した状態の文字列を準備([123.45/digitが1]->"123.5"、[123.4/digitが2]->"123.40"、[234.5/digitが0]->"235")
    var baseNumStr = bdVal.setScale(digit, RoundingMode.HALF_UP).toPlainString();

    // 整数部分のスペース埋め[123.45/intPartLimitが5]->"  123.5")
    String spFilledNum;
    String[] parts = baseNumStr.split("\\.");
    String intPart = parts[0];
    String decimalPart = (parts.length > 1) ? parts[1] : "";

    if (intPart.length() < intPartLimit) {
      // String.formatで右詰めスペース埋めを実現(%5s のような形になる、5 は intPartLimit）
      String formattedIntPart = String.format("%" + intPartLimit + "s", intPart);

      if (digit > 0) {
        spFilledNum = formattedIntPart + "." + decimalPart;
      } else {
        spFilledNum = formattedIntPart;
      }
    } else {
      spFilledNum = baseNumStr;
    }

    return beforeWord + spFilledNum + afterWord;
  }

  private @Nullable JsonNode parseNode(String jsonString) {
    if (jsonString == null || jsonString.isEmpty()) {
      return null;
    }
    try {
      return objectMapper.readTree(jsonString);
    } catch (Exception e) {
      return null;
    }
  }

  @JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
  @JsonIgnoreProperties(ignoreUnknown = true)
  public static class PrintConfig {
    public List<PrintConfigItem> after;
    public List<PrintConfigItem> before;
    public List<PrintConfigItem> noSchedule;
    public List<PrintConfigItem> noPat;

    @JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class PrintConfigItem {
      public Integer ctlNo;
      public Integer dispOrder;
      public Integer itemSource;
      public Integer itemCd;
      public String examClass;
      public Integer fontSize;
      public Integer dataType;
      public String dataFormat;
      public Integer datePosition;
      public String beforeWord;
      public String afterWord;
      public String calculate;
    }
  }
}
