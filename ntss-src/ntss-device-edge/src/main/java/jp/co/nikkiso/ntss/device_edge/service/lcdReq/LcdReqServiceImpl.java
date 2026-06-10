package jp.co.nikkiso.ntss.device_edge.service.lcdReq;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.util.TimeZone;

import com.fasterxml.jackson.databind.JsonNode;
import com.google.common.base.Strings;
import jp.co.nikkiso.ntss.api.service.NameConcat.NameConcatService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicateTimingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicateTiming;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.Utility.MedicineAndEquipmentUtilService;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq32;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq33;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq36;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq38;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq41;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq42;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq44;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq45;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq46;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq51;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq52;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq53;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.DailyReportResponse;
import jp.co.nikkiso.ntss.device_edge.response.lcdReq.LcdReqExamResponse;
import jp.co.nikkiso.ntss.device_edge.util.DateTimeUtils;
import jp.co.nikkiso.ntss.device_edge.util.PhysicalInfo.PhysicalInfo;
import jp.co.nikkiso.ntss.device_edge.util.PhysicalInfo.PhysicalInfoItem;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 仮想端末情報サービス
 */
@Service
public class LcdReqServiceImpl implements LcdReqService {

  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  PatMainDao patMainDao;
  @Autowired
  PatExamMainDao patExamDao;
  @Autowired
  PatUniqueDao patUniqueDao;
  @Autowired
  MntMotionRecordDao mntMotionRecordDao;
  @Autowired
  MstPersonalUserDao mstPersonalUserDao;
  //add redmine bug#6392 劉 start
  @Autowired
  MstMachineDao mstMachineDao;
  @Autowired
  MstComsvSettingDao mstComsvSettingDao;
  //add redmine bug#6392 劉 end
  // #11339 2024.12.10 mod 投与薬剤の並び順を施設設定に合わせてソート TDC片口 start
//  //add redmine bug#5880 劉 start
//  @Autowired
//  MstFacilitySettingDao mstFacilitySettingDao;
//  //add redmine bug#5880 劉 end
  @Autowired
  MedicineAndEquipmentUtilService medicineAndEquipmentUtilService;
  @Autowired
  MstMedicateTimingDao mstMedicateTimingDao;
  // #11339 2024.12.10 mod 投与薬剤の並び順を施設設定に合わせてソート TDC片口 end

  // #11827 2025.05.14 add 姓名結合用サービス構築 TDC米沢 start
  // 姓名結合用サービス構築
  @Autowired
  NameConcatService nameConcatService;
  // #11827 2025.05.14 add 姓名結合要サービス構築 TDC米沢 end

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
  @Autowired
  LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
  /**
   * 仮想端末情報（酸素吸入）サービス
   */
  @Override
  public List<LcdReq32> lcdReq32SelectByNo(Long ordNo) {
    // #11827 2025.05.14 add 仮想端末姓名結合設定に準拠 TDC米沢 start
    // 透析番号から施設コードを取得
    String facilityCd = ordMainDao.selectFacilityCdByOrdNo(ordNo);
    if(facilityCd != null) {
      // 施設コードが取得できた場合
      // 施設設定取得
      nameConcatService.ReadFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.VIRTUAL_TERMINAL_NAME_CONCAT_SETTING);
    }
    // #11827 2025.05.14 add 仮想端末姓名結合設定に準拠 TDC米沢 start
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
    try {
    List<LcdReq32> lcdReq32 = ordMainDao.selectOxygenByNo(ordNo);
    for (int lop = 0; lop < lcdReq32.size(); lop++) {
      LcdReq32 req = lcdReq32.get(lop);
      if (!(Objects.equals(req.getTreat_staff_cd(), null))) {
        MstPersonalUser user = mstPersonalUserDao.selectById(req.getTreat_staff_cd());
        if (user != null) {
          String user_name = user.getUserName();
          req.setTreat_staff_name(user_name);
          // #11827 2025.05.14 add 仮想端末姓名結合設定に準拠 TDC米沢 start
          if(facilityCd != null) {
            // 姓名結合
            req.setTreat_staff_name(nameConcatService.NameConcat(user.getUserFirstName(), user.getUserLastName()));
          }
          // #11827 2025.05.14 add 仮想端末姓名結合設定に準拠 TDC米沢 start
        }
      }
    }
    return lcdReq32;
  } finally {
      nameConcatService.ClearFacilitySettingValue();
    }
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
  }

  /**
   * 仮想端末情報（ログ）サービス
   */
  @Override
  public List<LcdReq36> lcdReq36SelectMachineRecordMessage(String facilityCd, String machineTypeCd,
      String machineSerial, Timestamp fromDate, Long ordNo, Integer offset) {
    //mod redmine bug#6392 劉 start
    //List<LcdReq36> LcdReq36 = mntMotionRecordDao.selectMachineRecordMessage(facilityCd, machineTypeCd, machineSerial, fromDate, ordNo, offset);
    //仮想端末ログタイプら取得
    boolean isLogTypeOn = false;
    MstMachine mstMachine = mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);
    if (null != mstMachine) {
      isLogTypeOn = mstComsvSettingDao.selectIsLogTypeOnByCd(facilityCd, mstMachine.getDeviceEdgeNo());
    }

    List<LcdReq36> LcdReq36;
    if (isLogTypeOn) {
      //愁訴処置
      LcdReq36 = ordMainDao.selectCompAndTreatMessage(facilityCd, machineTypeCd, machineSerial, fromDate, ordNo, offset);
    } else {
      //ログ
      LcdReq36 = mntMotionRecordDao.selectMachineRecordMessage(facilityCd, machineTypeCd, machineSerial, fromDate, ordNo, offset);
    }
    //mod redmine bug#6392 劉 end
    return LcdReq36;
  }

  /**
   * 仮想端末情報（体重トレンド）サービス
   */
  @Override
  public List<LcdReq38> lcdReq38SelectWeightAll(Long patId) {
    List<LcdReq38> LcdReq38 = ordMainDao.selectWeightTrend(patId);
    return LcdReq38;
  }

  /**
  * 仮想端末情報（透析日報）サービス
  */
  @Autowired
  LcdReq40Service lcdReq40Service;

  @Override
  public DailyReportResponse lcdReq40selectByNo(Long ordNo, Integer deviceEdgeNo) {
    DailyReportResponse lcdReq40 = lcdReq40Service.selectByNo(ordNo, deviceEdgeNo);
    return lcdReq40;
  }

  /**
   * 仮想端末情報（投与薬剤）サービス
   */
  @Override
  public List<LcdReq41> lcdReq41selectByNo(Long ordNo) {
    // #11339 2024.12.10 mod 投与薬剤の並び順を施設設定に合わせてソート TDC片口 start
//    //mod redmine bug#5880 劉 start
//    //List<LcdReq41> lcdReq41 = ordMainDao.selectMediInfoByNo(ordNo);
//    List<LcdReq41> lcdReq41 = new ArrayList<>();
//    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
//    if (null != ordMain) {
//      String orderBy = "";
//      String facilityCd = ordMain.getFacilityCd();
//      //施設設定（投与薬剤表示順）取得
//      FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, "3007");
//      if (null != facilitySettingInfo && null != facilitySettingInfo.getValue()) {
//        orderBy =  formatOrderBy(facilitySettingInfo.getValue());
//      }
//
//      lcdReq41 = ordMainDao.getRstMediInfo(ordNo, facilityCd, orderBy);
//    }
//    //mod redmine bug#5880 劉 end
    List<LcdReq41> lcdReq41 = new ArrayList<>();
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    if (null != ordMain && !Strings.isNullOrEmpty(ordMain.getRstMediInfo())) {
      String sortedRstMediInfo = medicineAndEquipmentUtilService.getSortedMedicineInfo(ordMain.getFacilityCd(), ordMain.getRstMediInfo());
      ObjectMapper mapper = new ObjectMapper();
      JsonNode rstMediInfoJson;
      try {
        rstMediInfoJson = mapper.readTree(sortedRstMediInfo);
      } catch (JsonProcessingException e) {
        throw new RuntimeException(e);
      }

      MedicineAndEquipmentUtilService.MstMedicineAndMix r = medicineAndEquipmentUtilService.getMstMedicineAndMixes(sortedRstMediInfo);
      List<MstMedicine> medicines = r.mstMedicines();
      List<MstMedicineMix> medicineMixes = r.mstMedicineMixes();

      MstMedicateTiming timingParam = new MstMedicateTiming();
      timingParam.setFacilityCd(ordMain.getFacilityCd());
      List<MstMedicateTiming> mstMedicateTimings = mstMedicateTimingDao.selectAll(SelectOptions.get(), timingParam);

      for (int i = 0; i < rstMediInfoJson.size(); i++) {
        JsonNode jsonNode = rstMediInfoJson.get(i);
        LcdReq41 item = new LcdReq41();
        boolean isMix = "2".equals(jsonNode.get("medicine_type").asText());
        Integer cd = jsonNode.get("cd").asInt();

        item.setIdx(i);
        item.setSno(jsonNode.get("no").asInt());
        item.setName(jsonNode.get("name").asText(null));
        item.setUnit(jsonNode.get("unit").asText(null));
        item.setAmount(jsonNode.get("amount").asText(null));
        item.setEffectFlg(jsonNode.get("effect_flg").asInt());
        if (jsonNode.hasNonNull("effect_date")) {
          String effectDateStr = jsonNode.get("effect_date").asText(null);
          if (effectDateStr != null && !"null".equals(effectDateStr)){
            item.setEffectDate(effectDateStr);
          }
        }
        if (isMix) {
          List<MstMedicineMix> targetMedicineMixes = medicineMixes.stream().filter(x -> x.getMedicineMixCd().equals(cd)).toList();
          if (!targetMedicineMixes.isEmpty()) {
            item.setIsMedicated(targetMedicineMixes.get(0).getIsMedicated());
          }
        } else {
          List<MstMedicine> targetMedicines = medicines.stream().filter(x -> x.getMedicineCd().equals(cd)).toList();
          if (!targetMedicines.isEmpty()) {
            item.setIsMedicated(targetMedicines.get(0).getIsMedicated());
          }
        }
        Integer timingCd = jsonNode.get("timing_cd").asInt();
        List<MstMedicateTiming> targetTimings = mstMedicateTimings.stream().filter(t -> t.getMedicateTimingCd().equals(timingCd)).toList();
        if (targetTimings.isEmpty()) {
          item.setAlertTime(-1);
        } else {
          MstMedicateTiming targetTiming = targetTimings.get(0);
          item.setProgressCd(targetTiming.getDialysisProgressCd());
          if ("1".equals(targetTiming.getIsAlert())){
            item.setAlertTime(Integer.valueOf(targetTiming.getAlertTime() == null ? -1 : targetTiming.getAlertTime()));
          } else {
            item.setAlertTime(-1);
          }
          item.setIsAlert(targetTiming.getIsAlert());
        }

        lcdReq41.add(item);
      }
    }
    // #11339 2024.12.10 mod 投与薬剤の並び順を施設設定に合わせてソート TDC片口 end
    return lcdReq41;
  }

  /**
   * 仮想端末情報（抗凝固剤）サービス
   */
  @Override
  public LcdReq42 lcdReq42selectByNo(Long ordNo) {
    LcdReq42 lcdReq42 = ordMainDao.selectCondInfoByNo(ordNo);
    return lcdReq42;
  }

  /**
   * 仮想端末情報（禁忌）サービス
   */
  @Override
  public List<LcdReq44> lcdReq44SelectById(Long patId) {
    List<LcdReq44> lcdReq44 = patMainDao.selectTabooById(patId);
    return lcdReq44;
  }

  /**
   * 仮想端末情報（メモ）サービス
   */
  @Override
  public List<LcdReq45> lcdReq45SelectById(Long patId) {
    List<LcdReq45> LcdReq45 = patMainDao.selectMemoById(patId);
    return LcdReq45;
  }

  /**
   * {@inheritDoc}
   * @throws JsonProcessingException
   */
  @Override
  public List<LcdReqExamResponse> lcdReqExamResult(Long patId) throws JsonProcessingException {
    List<LcdReq46> LcdReq46 = patExamDao.selectPatExamMainByPatIdComSv(patId);
    List<LcdReqExamResponse> resExam = new ArrayList<>();
    ObjectMapper mapper = new ObjectMapper();
    for (LcdReq46 req : LcdReq46) {
      LcdReqExamResponse resItem = new LcdReqExamResponse();
      resItem.setExamMainCd(req.getExamMainCd());
      resItem.setResultExamDate(req.getResultExamDate());
      resItem.setRegOrderClass(resItem.getRegOrderClassFNSi2Machine(req.getRegOrderClass()));

      //mod redmine bug#6768 劉 start
      //List<LcdReq33> LcdReq33 = patExamDao.selectPatExamMainByExamMainCdComSv(req.getExamMainCd());
      List<LcdReq33> LcdReq33 = getExamResultInfo(req.getExamMainCd());
      //mod redmine bug#6768 劉 end
      String json33 = mapper.writeValueAsString(LcdReq33);
      resItem.setExamResultInfo(json33);

      resExam.add(resItem);
    }
    return resExam;
  }

  /**
   * 仮想端末情報（穿刺／回収／担当）サービス
   */
  @Override
  public LcdReq51 lcdReq51SelectByNo(Long ordNo) {
    LcdReq51 lcdReq51 = ordMainDao.selectRstUserInfoByNo(ordNo);

    // 11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
    if(lcdReq51.getFacilityCd() != null) {
      // 施設コードが取得できた場合
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
      try {
      // 施設設定値取得
      nameConcatService.ReadFacilitySettingValue(lcdReq51.getFacilityCd(), CoreConstant.FacilitySettingNo.VIRTUAL_TERMINAL_NAME_CONCAT_SETTING);

      // 穿刺者姓名結合
      if (lcdReq51.getPuserId1() != null) {
        lcdReq51.setPuserName1(nameConcatService.NameConcat(lcdReq51.getPuserFirstName1(), lcdReq51.getPuserLastName1()));
      }
      if (lcdReq51.getPuserId2() != null) {
        lcdReq51.setPuserName2(nameConcatService.NameConcat(lcdReq51.getPuserFirstName2(), lcdReq51.getPuserLastName2()));
      }
      // 返血者姓名結合
      if (lcdReq51.getRuserId1() != null) {
        lcdReq51.setRuserName1(nameConcatService.NameConcat(lcdReq51.getRuserFirstName1(), lcdReq51.getRuserLastName1()));
      }
      if (lcdReq51.getRuserId2() != null) {
        lcdReq51.setRuserName2(nameConcatService.NameConcat(lcdReq51.getRuserFirstName2(), lcdReq51.getRuserLastName2()));
      }
      // 担当者姓名結合
      if (lcdReq51.getCuserId1() != null) {
        lcdReq51.setCuserName1(nameConcatService.NameConcat(lcdReq51.getCuserFirstName1(), lcdReq51.getCuserLastName1()));
      }
      if (lcdReq51.getCuserId2() != null) {
        lcdReq51.setCuserName2(nameConcatService.NameConcat(lcdReq51.getCuserFirstName2(), lcdReq51.getCuserLastName2()));
      }
      } finally {
        nameConcatService.ClearFacilitySettingValue();
      }
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
    }
    // 11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start

    /*
    MstPersonalUser user;
    // 穿刺者名取得
    if (!(Objects.equal(lcdReq51.getPuserId1(), null))) {
      user = mstPersonalUserDao.selectById(lcdReq51.getPuserId1());
      lcdReq51.setPuserName1(user.getUserName());
    }
    if (!(Objects.equal(lcdReq51.getPuserId2(), null))) {
      user = mstPersonalUserDao.selectById(lcdReq51.getPuserId2());
      lcdReq51.setPuserName2(user.getUserName());
    }
    // 返血者名取得
    if (!(Objects.equal(lcdReq51.getRuserId1(), null))) {
      user = mstPersonalUserDao.selectById(lcdReq51.getRuserId1());
      lcdReq51.setRuserName1(user.getUserName());
    }
    if (!(Objects.equal(lcdReq51.getRuserId2(), null))) {
      user = mstPersonalUserDao.selectById(lcdReq51.getRuserId2());
      lcdReq51.setRuserName2(user.getUserName());
    }
    // 担当者名取得
    if (!(Objects.equal(lcdReq51.getCuserId1(), null))) {
      user = mstPersonalUserDao.selectById(lcdReq51.getCuserId1());
      lcdReq51.setCuserName1(user.getUserName());
    }
    if (!(Objects.equal(lcdReq51.getCuserId2(), null))) {
      user = mstPersonalUserDao.selectById(lcdReq51.getCuserId2());
      lcdReq51.setCuserName2(user.getUserName());
    }
    */
    return lcdReq51;
  }

  /**
   * 仮想端末情報（指示／特記）サービス
   */
  @Override
  public List<LcdReq52> lcdReq52SelectByNo(Long ordNo) {
    List<LcdReq52> lcdReq52 = ordMainDao.selectCommentByNo(ordNo);
    return lcdReq52;
  }

  /**
   * 仮想端末情報（CTRトレンド）サービス
   */
  @Override
  public List<LcdReq53> lcdReq53SelectWeightAll(Long patId) {
    PatUnique patUnique = patUniqueDao.selectById(patId);
    List<LcdReq53> lcdReq53 = new ArrayList<>();

    String physicalInfoStr = patUnique.getPhysical_info();
    if (physicalInfoStr != null && physicalInfoStr.length() != 0) {
      // 患者基本情報から身体情報を取得する
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//    PhysicalInfo physicalInfo = new PhysicalInfo(physicalInfoStr, "");
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end

      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      PhysicalInfo physicalInfo = null;
      try {
        physicalInfo = new PhysicalInfo(physicalInfoStr, "");
      } catch (JsonProcessingException e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
      // 全記録格納フィールドを測定日時[ExaminDate]で降順ソート
      List<PhysicalInfoItem> records = physicalInfo.getAllRecords();
      records.sort((a, b) -> {
        String examDateA = a.getExamDate();
        String examDateB = b.getExamDate();
        if (examDateA.length() < 11) {
          examDateA += "T00:00:00.000+09:00";
        }
        if (examDateB.length() < 11) {
          examDateB += "T00:00:00.000+09:00";
        }
        Date A = DateTimeUtils.dateStringToDate_iso8601(examDateA);
        Date B = DateTimeUtils.dateStringToDate_iso8601(examDateB);
        return B.compareTo(A);
      });

      for (PhysicalInfoItem ctrItem : records) {
        LcdReq53 lcdReq53Item = new LcdReq53();
        if (Objects.isNull(ctrItem.getCtr()) || ctrItem.getCtr().isEmpty()
            || Objects.equals(ctrItem.getCtr(), "null")) {
          continue;
        }
        // ctr
        lcdReq53Item.setCtr(ctrItem.getCtr());
        // ctr体重
        lcdReq53Item.setCtrWeight(ctrItem.getCtrWeight());
        // ctr測定日時
        String ctrDate = ctrItem.getExamDate();
        if (ctrDate.length() < 11) {
          ctrDate += "T00:00:00.000+09:00";
        }
        Date d = DateTimeUtils.dateStringToDate_iso8601(ctrDate);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        sdf.setTimeZone(TimeZone.getTimeZone("Asia/Tokyo"));
        lcdReq53Item.setTreatDate(sdf.format(d));
        // 返り値に格納
        lcdReq53.add(lcdReq53Item);
      }
    }
    return lcdReq53;
  }

  //add redmine bug#6768 劉 start
  private List<LcdReq33> getExamResultInfo(Long examMainCd) {
    List<LcdReq33> examResultInfoList = patExamDao.selectPatExamMainByExamMainCdComSv(examMainCd);
    for (int i = 0; i < examResultInfoList.size(); ++i) {
      LcdReq33 examResultInfo = examResultInfoList.get(i);
      if (null != examResultInfo.getDataType() && "1".equals(examResultInfo.getDataType())) {
        //数値型は判断しない
        continue;
      }

      //文字型は文字列の正当性を判断する必要があります
      try {
        Double.parseDouble(examResultInfo.getResult());
      } catch (NumberFormatException e) {
        examResultInfo.setResult("0");
        examResultInfoList.set(i, examResultInfo);
      }
    }
    return examResultInfoList;
  }
  //add redmine bug#6768 劉 end

  //add redmine bug#5880 劉 start
  private String formatOrderBy(String value) {
    StringBuilder orderBy = new StringBuilder();
    String[] list = value.split(",");
    for (String valueTmp : list) {
      int firstIndex = valueTmp.indexOf("\"");
      int lastIndex = valueTmp.lastIndexOf("\"");
      String subStr = valueTmp.substring(firstIndex + 1, lastIndex);
      String orderByTmp = convertOrderBy(subStr);
      if (orderBy.length() > 0) {
        orderBy.append(", ");
      }
      orderBy.append(orderByTmp);
    }
    return orderBy.toString();
  }

  private String convertOrderBy(String cd) {
    String str = "";
    switch (cd) {
      case "1":
        str = "class_cd";
        break;
      case "2":
        str = "medicine_type";
        break;
      case "3":
        str = "index1";
        break;
      case "4":
        str = "timing_cd";
        break;
      case "5":
        str = "procedure_cd";
        break;
      case "6":
        str = "date_interval";
        break;
      default:
        break;
    }

    return str;
  }
  //add redmine bug#5880 劉 end
}
