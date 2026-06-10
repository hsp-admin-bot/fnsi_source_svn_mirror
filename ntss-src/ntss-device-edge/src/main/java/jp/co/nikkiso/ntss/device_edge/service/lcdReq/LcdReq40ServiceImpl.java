package jp.co.nikkiso.ntss.device_edge.service.lcdReq;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import com.fasterxml.jackson.core.JsonProcessingException;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.DailyReportInfoDTO;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.DailyReportResponse;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.LcdResponseStruct;
import jp.co.nikkiso.ntss.device_edge.util.Utilities;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfo;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfoService;
import jp.co.nikkiso.ntss.device_edge.util.EquipmentInfo.EquipmentInfo;
import jp.co.nikkiso.ntss.device_edge.util.EquipmentInfo.EquipmentInfoService;
import jp.co.nikkiso.ntss.device_edge.util.MedicineInfo.MedicineInfo;
import jp.co.nikkiso.ntss.device_edge.util.MedicineInfo.MedicineInfoService;
import jp.co.nikkiso.ntss.device_edge.util.VitalInfo.VitalInfo;
import jp.co.nikkiso.ntss.device_edge.util.WeightInfo.WeightInfo;
import jp.co.nikkiso.ntss.device_edge.service.Utility.MedicineAndEquipmentUtilService;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 仮想端末情報サービス
 */
@Service
public class LcdReq40ServiceImpl implements LcdReq40Service {

  /**
   * 仮想端末情報（透析日報）サービス
   */
  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  MstComsvSettingDao mstComsvSettingDao;
  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  @Autowired
  MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  MstDialyzerDao mstDialyzerDao;
  @Autowired
  CondInfoService condInfoService;
  @Autowired
  EquipmentInfoService equipmentInfoService;
  @Autowired
  MedicineInfoService medicineInfoService;
  @Autowired
  MniMonitorDao mniMonitorDao;
  // #11451 2025.01.20 add 透析日報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 start
  @Autowired
  MedicineAndEquipmentUtilService medicineAndEquipmentUtilService;
  // #11451 2025.01.20 add 透析日報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 end

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
  @Autowired
  LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end

  @Override
  public DailyReportResponse selectByNo(Long ordNo, Integer deviceEdgeNo) {
    // 透析日報DTOのインスタンス生成
    DailyReportInfoDTO dto = new DailyReportInfoDTO();

    // 指定したオーダー番号の治療情報を取得
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);

    /**************************
     *  ord_mainから直接取得できるもの
     **************************/
    // DTOにセット
    // 透析開始時刻
    dto.setTreatSartDate(ordMain.getRstStartDate());
    // 透析終了時刻
    dto.setTreatEndDate(ordMain.getRstEndDate());
    // 透析時間
    dto.setTreatTime(ordMain.getRstRunningTime());
    // 透析回数
    dto.setDialysisCnt(ordMain.getRstDialysisCnt());
    // 実績血液循環量
    dto.setRstBvCirculate(ordMain.getRstBloodCirculateTotal());
    // 治療法名
    dto.setTreatName(ordMain.getRstTreatmentName());
    // DW
    dto.setDw(ordMain.getRstDw());
    // 入外区分
    dto.setInOut(ordMain.getRstInOutClass());
    // クール名
    dto.setKurName(ordMain.getRstKurName());
    // ベッド名
    dto.setBedName(ordMain.getRstBedName());
    // 病棟名
    dto.setWardName(ordMain.getRstWardName());

    /***********
     *  血液型
     ***********/
    // 患者個人情報を取得
    Long patId = ordMain.getPatId();
    if (!Objects.isNull(patId)) {
      PatPersonalMain patPersonal = patPersonalMainDao.selectById(patId);
      /// DTOに血液型コードをセット
      dto.setBloodTypeAbo(patPersonal.getPat_blood_type_abo());
      dto.setBloodTypeRh(patPersonal.getPat_blood_type_rh());
    }

    /***********
     * 穿刺者
     ***********/
    // 穿刺者のコードを取得
    Long puncUserId = Utilities.getUserIdFromJsonString(ordMain.getRstPunctureUserInfo());
    // 穿刺者のユーザー個人情報を取得
    String puncUserName = mstPersonalUserDao.selectUserNameById(puncUserId);
    // DTOにセット
    dto.setPunctureName(puncUserId, puncUserName);

    /***********
     * 回収者
     ***********/
    // 回収者のコードを取得
    Long returnUserId = Utilities.getUserIdFromJsonString(ordMain.getRstReturnUserInfo());
    // 回収者のユーザー個人情報を取得
    String returnUserName = mstPersonalUserDao.selectUserNameById(returnUserId);
    // DTOにセット
    dto.setReturnName(returnUserId, returnUserName);

    /***********
     * 治療条件
     ***********/
    // 治療条件項目(実績)の値を取得する
    CondInfo condInfo = condInfoService.createCondInfo(ordMain.getRstCondInfo());
    // DTOにセット
    dto.setConds(condInfo);

    /****************
     * ダイアライザ膜面積
     ****************/
    Double dialyzerArea;
    if (condInfo.getDialyzer() != null) {
      // 治療条件からダイアライザコードを取得
      int dialyzerCd = Integer.parseInt(condInfo.getDialyzer().getValue());
      // マスタ情報を取得
      MstDialyzer mstDialyzer = mstDialyzerDao.selectByDialyzerCd(SelectOptions.get(), dialyzerCd);
      // ダイアライザ膜面積を取得
      dialyzerArea = mstDialyzer.getArea();
    } else {
      dialyzerArea = null;
    }
    // DTOにセット
    dto.setDialyzerArea(dialyzerArea);

    /***********
     * バイタル
     ***********/
    // バイタル情報の値を取得する
    //VitalInfo vitalInfo = new VitalInfo(ordMain.getRstVitalInfo());
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//    VitalInfo vitalInfo = new VitalInfo("{}");
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end

    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
    VitalInfo vitalInfo = null;
    try {
      vitalInfo = new VitalInfo("{}");
    } catch (JsonProcessingException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
    String bpMax;
    String bpMin;
    String bpAve;
    String pulse;
    List<MniMonitor> mniMonitor = mniMonitorDao.selectByOrdNoVital(ordNo);
    try {
      for (int lop = 0; lop < mniMonitor.size(); lop++) {
        MniMonitor mon = mniMonitor.get(lop);
        // JSON文字列を展開
        ObjectMapper mapper = new ObjectMapper();
        // 親ノード
        JsonNode jsonNode = mapper.readTree(mon.getMonitorData());
        // 各値のノード
        bpMax = jsonNode.get("90").asText();	// 最高血圧
        bpMin = jsonNode.get("91").asText();	// 最低血圧
        bpAve = jsonNode.get("92").asText();	// 平均血圧
        pulse = jsonNode.get("93").asText();	// 脈拍
        if ( mon.getDataType() == 5 ) {
          // 前血圧
      	  vitalInfo.setBpMaxBefore(bpMax);
      	  vitalInfo.setBpMinBefore(bpMin);
      	  vitalInfo.setBpAveBefore(bpAve);
      	  vitalInfo.setPulseBefore(pulse);
        }
        else {
          // 後血圧
          vitalInfo.setBpMaxAfter(bpMax);
          vitalInfo.setBpMinAfter(bpMin);
          vitalInfo.setBpAveAfter(bpAve);
          vitalInfo.setPulseAfter(pulse);
        }
        dto.setVitals(vitalInfo);
      }
    } catch (Exception e) {
      // 例外が発生した場合
      vitalInfo = null;
    }
    // DTOにセット
    dto.setVitals(vitalInfo);

    /***********
     * 体重情報
     ***********/
    // 体重情報の値を取得する
    WeightInfo weightInfo = new WeightInfo(ordMain.getRstWeightInfo());
    // DTOにセット
    dto.setWeights(weightInfo);

    /***********
     *  前回後体重
     ***********/
    // 検索基準日を取得(透析日報は条件送信後であるが、運転開始されているとは限らないため、条件送信日時を用いる)
    Timestamp baseDate = ordMain.getRstCondSendDate();
    // 前回の体重情報のJSON文字列を取得(特殊浄化を除きたいため第4引数を0とする)
    String lastWeightInfoStr = ordMainDao.selectLastRstWeight(patId, ordNo, baseDate, 0);
    // 前回後体重の体重情報
    WeightInfo lastWeightInfo = new WeightInfo(lastWeightInfoStr);
    // DTOにセット
    dto.setLastWeightAfter(lastWeightInfo);

    /***********
     * 消耗品情報
     ***********/
    // 消耗品情報(実績)の値を取得する
    // #11451 2025.01.20 mod 透析日報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 start
//    List<EquipmentInfo> equipmentInfoList = equipmentInfoService.createEquipmentInfoList(ordMain.getRstEquipInfo());

    String sortedRstEquipInfo = medicineAndEquipmentUtilService.getSortedEquipInfo(ordMain.getFacilityCd(), ordMain.getRstEquipInfo());
    List<EquipmentInfo> equipmentInfoList = equipmentInfoService.createEquipmentInfoList(sortedRstEquipInfo);
    // #11451 2024.01.20 mod 透析日報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 end
    // DTOにセット
    dto.setEquips(equipmentInfoList);

    /***********
     * 薬剤情報
     ***********/
    // 薬剤情報(実績)の値を取得する
    // #11451 2025.01.20 mod 透析日報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 start
//    List<MedicineInfo> medicineInfoList = medicineInfoService.createMedicineInfoList(ordMain.getRstMediInfo());

    String sortedRstMediInfo = medicineAndEquipmentUtilService.getSortedMedicineInfo(ordMain.getFacilityCd(), ordMain.getRstMediInfo());
    List<MedicineInfo> medicineInfoList = medicineInfoService.createMedicineInfoList(sortedRstMediInfo);
    // #11451 2024.01.20 mod 透析日報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 end
    // DTOにセット
    dto.setMedis(medicineInfoList);

    /***********
     * 除水補正値合計
     ***********/
    // 実績の除水補正情報を与える
    dto.setUfrAmendTotal(ordMain.getRstOffWaterInfo());

    /***********
     * 算出値
     ***********/
    // セット済みの値を用いた算出値項目をセットする
    // 対象：抗凝固剤合計注入量、前体重ーDW、前体重ー前回後体重、前回後体重ー前体重、前体重ー後体重、後体重ー前体重
    dto.setAllCalculationValue();

    /** レスポンス生成 **/

    // 通信サーバ設定の透析日報設定情報を取得
    String facilityCd = ordMain.getFacilityCd();
    MstComsvSetting comsvSetting = mstComsvSettingDao.selectByCd(facilityCd, deviceEdgeNo);
    String lcdReport = comsvSetting.getLcdReport();

    List<LcdResponseStruct> reportList = new ArrayList<LcdResponseStruct>();
    for (int initlop = 0; initlop < 8; initlop++) {
      reportList.add(null);
    }

    // 取得した透析日報表示設定の表示順をもとに項目コード一覧を取得する
    int[] dispOrderArray = dto.getDispOrderList(lcdReport);

    for (int lop = 0; lop < dispOrderArray.length; lop++) {
      int itemCd = dispOrderArray[lop];
      LcdResponseStruct item = dto.getReportItemByCd(itemCd);
      reportList.set(lop, item);
    }

    DailyReportResponse response = new DailyReportResponse();
    response.setReport1(reportList.get(0));
    response.setReport2(reportList.get(1));
    response.setReport3(reportList.get(2));
    response.setReport4(reportList.get(3));
    response.setReport5(reportList.get(4));
    response.setReport6(reportList.get(5));
    response.setReport7(reportList.get(6));
    response.setReport8(reportList.get(7));

    return response;
  }
}
