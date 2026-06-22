package jp.co.nikkiso.ntss.device_edge.service;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.StringJoiner;

import jp.co.nikkiso.ntss.api.service.NameConcat.NameConcatService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdMainDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstCompTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstComplaintDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstProcedureDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.MstWardDao;
import jp.co.nikkiso.ntss.core.dao.OperateStatusDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatHhdPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.dao.TmpCommFailureRecoveryDao;
import jp.co.nikkiso.ntss.api.service.ordChecklistService.OrdCheckListService;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import jp.co.nikkiso.ntss.core.entity.MstComplaint;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstProcedure;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatHhdPattern;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.TmpCommFailureRecovery;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvComplaintTreatment;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineStateForMinimumTreatDate;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvNextPatInfo;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvPatRelated;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstTareChild;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainRstWeightInfo;
import jp.co.nikkiso.ntss.core.entity.custom.RecrclRt;
import jp.co.nikkiso.ntss.core.entity.custom.RecrclRtElement;
import jp.co.nikkiso.ntss.core.entity.custom.TareOrOffWaterJson;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import jp.co.nikkiso.ntss.device_edge.service.Utility.MedicineAndEquipmentUtilService;
import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ObjectNode;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq51;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.device_edge.constant.Constant.OrdMainConst;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.ComsvNextPatOrdResponse;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.LcdResponseStruct;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.NextPatMemoDTO;
import jp.co.nikkiso.ntss.device_edge.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.device_edge.service.sendConditionCancel.SendConditionCancelService;
import jp.co.nikkiso.ntss.device_edge.util.Utilities;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfo;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfoItem;
import jp.co.nikkiso.ntss.device_edge.util.CondInfo.CondInfoService;
import jp.co.nikkiso.ntss.device_edge.util.MedicalCareInfo.MedicalCareInfo;
import jp.co.nikkiso.ntss.device_edge.util.MedicalCareInfo.MedicalCareInfoService;
import jp.co.nikkiso.ntss.device_edge.web.rest.util.WebApiCallCommonUtil;
import org.seasar.doma.jdbc.Config;
import org.springframework.util.CollectionUtils;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;


@Service
public class ComsvOrdMainServiceImpl implements ComsvOrdMainService {

  @Autowired
  ComsvOrdMainDao comsvOrdMainDao;
  // #10844 2024.08.06 add 治療状況が治療中(3)の場合、治療終了処理を行う TDC高村 start
  @Autowired
  ComsvOrdMainService comsvOrdMainService;
  // #10844 2024.08.06 add 治療状況が治療中(3)の場合、治療終了処理を行う TDC高村 end
  @Autowired
  OrdMainDao ordMainDao;
  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  @Autowired
  PatMainDao patMainDao;
  @Autowired
  PatUniqueDao patUniqueDao;
  @Autowired
  MstComsvSettingDao mstComsvSettingDao;
  @Autowired
  MstCourseDao mstCourseDao;
  @Autowired
  MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  MstTreatmentDao mstTreatmentDao;
  @Autowired
  MstWardDao mstWardDao;
  @Autowired
  MstEquipmentDao mstEquipmentDao;
  //add #10412 次患者更新関連全体見直し対応 朴 start
  @Autowired
  MstDialyzerDao mstDialyzerDao;
  //add #10412 次患者更新関連全体見直し対応 朴 end
  @Autowired
  MstMedicineDao mstMedicineDao;
  @Autowired
  MstMedicineMixDao mstMedicineMixDao;
  @Autowired
  MstMachineDao mstMachineDao;
  @Autowired
  MntMachineStateService mntMachineStateService;
  //  @Autowired
  //  NextPatMemoDTO dto;
  @Autowired
  CondInfoService condInfoService;
  @Autowired
  MedicalCareInfoService medicalCareInfoService;
  @Autowired
  MstBedDao mstBedDao;
  @Autowired
  MstKurDao mstKurDao;
  @Autowired
  PatHhdPatternDao patHhdPatternDao;
  @Autowired
  MstComplaintDao mstComplaintDao;
  @Autowired
  MstCompTreatmentDao mstCompTreatmentDao;
  @Autowired
  private ComsvPatRelatedService comsvPatRelatedService;
  @Autowired
  private OperateStatusDao operateStatusDao;
  @Autowired
  SendConditionCancelService sendConditionCancelService;

  @Autowired
  private LogService logService;

  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  // add FNSI-バグ 通信サーバ 高 start
  @Autowired
  private ComsvOrdCheckListService comsvOrdCheckListService;
  // add FNSI-バグ 通信サーバ 高 end

  // add AWSとDEの通信断からの復旧 --趙-- start
  @Autowired
  TmpCommFailureRecoveryDao tmpCommFailureRecoveryDao;
  // add AWSとDEの通信断からの復旧 --趙-- end

  //add redmine bug#4741 劉 start
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  //add redmine bug#4741 劉 end

  @Autowired
  private TriggerUtil triggerUtil;

  @Autowired
  private MstProcedureDao mstProcedureDao;

  //add #10196 Ord_Material_Save code implementation 20240130 ztc start
  @Autowired
  private OrdMaterialSaveService ordMaterialSaveService;
  //add #10196 Ord_Material_Save code implementation 20240130 ztc end

  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  @Autowired
  private OrdCheckListService ordCheckListService;
  //  add 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

  // #11339 2024.12.05 add 次患者情報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 start
  @Autowired
  private MedicineAndEquipmentUtilService medicineAndEquipmentUtilService;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // #11339 2024.12.05 add 次患者情報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 end

  // #11827 2025.05.14 add 姓名結合用サービス構築 TDC米沢 start
  // 姓名結合用サービス構築
  @Autowired
  NameConcatService nameConcatService;
  // #11827 2025.05.14 add 姓名結合要サービス構築 TDC米沢 end

  @Override
  public ComsvOrdMain selectByNo(Long ordNo) {
    return comsvOrdMainDao.selectByNo(ordNo);
  }

  @Override
  public int selectTreatmentCount(Long ordNo) {
    return comsvOrdMainDao.selectTreatmentCount(ordNo);
  }

  @Override
  public int selectTreatStaffCount(Long ordNo) {
    return comsvOrdMainDao.selectTreatStaffCount(ordNo);
  }

  @Override
  public ComsvOrdMain selectUnregisteredPat(ComsvOrdMain param) {
    return comsvOrdMainDao.selectUnregisteredPat(param);
  }

  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
  /**
   * 情報取得
   *
   * @param ordNo オーダ番号
   * @return JSON文字列
   */
  @Override
  public String selectWeightInfo(Long ordNo) {
    return ordMainDao.selectWeightInfo(ordNo);
  }
  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end

  //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  /**
   * 通信サーバ用治療情報の愁訴処置情報
   *
   * @param ordNo オーダ番号
   * @return JSON文字列
   */
  @Override
  public ComsvComplaintTreatment selectRecentRstTreatmentInfo(Long ordNo){
    return comsvOrdMainDao.selectRecentRstTreatmentInfo(ordNo);
  }
  //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
  /**
   * 次患者送信有無判定
   * @param facilityCd 施設コード
   * @param comsvSetting 通信サーバー設定
   * @param nextPatientTreatDateTime 次患者治療開始時刻文字列[YYYYMMDDHHMMSS形式]
   * @return false：送信不要/true：送信必要
   */
  private boolean checkNeedToSendPatientInfo(
      String facilityCd,
      MstComsvSetting comsvSetting,
      String nextPatientTreatDateTime) {
    boolean ret = false;

    // 通信サーバー設定有無判定
    if (comsvSetting != null) {
      // 次患者送信モード取得
      Integer mode = comsvSetting.getNextPatMode() == null ? -1 : comsvSetting.getNextPatMode();
      // 次患者検索期間取得
      Integer modeRange = comsvSetting.getNextPatModeRange() == null ? 0 : comsvSetting.getNextPatModeRange();

      // 現在日時
      LocalDateTime now = LocalDateTime.now();
      // 現在時刻を文字列化
      String nowTime = now.format(DateTimeFormatter.ofPattern("HHmmss"));

      // クールリスト情報取得
      List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
      // クールリスト情報をクール開始時刻でソート
      mstKurList.stream().sorted((x, y) -> x.getKurStartTime().compareTo(y.getKurStartTime()));

      // 次クール終了時刻取得
      String nextKurEndTime = "";
      for (int lop = 0; lop < mstKurList.size(); lop++) {
        MstKur info = mstKurList.get(lop);

        // クール開始時刻≦=現在時刻≦=クール終了時刻
        if (0 <= nowTime.compareTo(info.getKurStartTime()) && nowTime.compareTo(info.getKurEndTime()) <= 0) {
          // 現在クールの場合

          // 次クール判定
          if ((lop + 1) < mstKurList.size()) {
            // 次のクールがあればそれが次クール終了時刻
            nextKurEndTime = mstKurList.get(lop + 1).getKurEndTime();
            break;
          } else {
            // 次のクールがなければ翌日の初回クール終了時刻
            nextKurEndTime = mstKurList.get(0).getKurEndTime();
          }
        }
      }

      // 次患者送信モードによる送信範囲日付作成
      LocalDateTime limitDate = now.plusDays(modeRange.longValue());
      String limitTreatDateTime = "";
      switch (mode) {
      case 1: // モード1
        // 当日以降で見つかった直近の治療予定日付＋次クール終了時刻

        // 開始日付
        String startDate = now.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        // 終了日付
        String endDate = limitDate.format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        // 当日を送信範囲とする
        limitDate = now;
        try {
          // 次患者登録されている情報で当日を含めて検索期間分の開始日時にある一番近い日付を取得する
          ComsvMntMachineStateForMinimumTreatDate rec = mntMachineStateService.selectMinimumTreatDate(facilityCd,
              comsvSetting.getDeviceEdgeNo(), startDate, endDate);
          if (rec != null) {
            // 見つかった場合

            // 最小の治療予定日を送信範囲とする
            SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
            Date date = sdf.parse(rec.getMinTreatDate());
            limitDate = LocalDateTime.ofInstant(date.toInstant(), ZoneId.systemDefault());
          }
        } catch (Exception e) {
        }

        break;
      case 2: // モード2
        // 当日+検索期間+次クール終了時刻

        break;
      }
      // 次クール終了時刻が現在時刻より前の場合
      if (0 < nowTime.compareTo(nextKurEndTime)) {
        // 翌日までを送信範囲とする
        limitDate = limitDate.plusDays(1L);
      }
      limitTreatDateTime = limitDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + nextKurEndTime;

      // 次患者の治療開始日付が送信範囲内かどうか
      if (nextPatientTreatDateTime.compareTo(limitTreatDateTime) <= 0) {
        // 送信対象
        ret = true;
      }
    }
    return ret;
  }

  /**
   * 通信サーバ用次患者情報取得
   * @param ordNo オーダー番号
   */
  @Override
  public ComsvNextPatOrdResponse selectNextPatInfo(Long ordNo, int deviceEdgeNo) {
    // DTOインスタンス生成
    NextPatMemoDTO dto = new NextPatMemoDTO();

    // 次患者の治療情報情報取得
    ComsvNextPatInfo nextPatOrd = comsvOrdMainDao.selectNextPatInfo(ordNo);

    if (Objects.isNull(nextPatOrd)) {
      // 次患者情報なし
      return null;
    }
    /// 施設コード
    String facilityCd = nextPatOrd.getFacilityCd();

    // 透析開始時刻
    String treatStartTime = nextPatOrd.getIndTreatStartTime();
    dto.setTreatSartTime(treatStartTime);

    /// 患者ID
    Long patId = nextPatOrd.getPatId();
    dto.setPatId(patId);

    // 指定したデバイスエッジ番号の通信サーバー設定を取得する
    MstComsvSetting comsvSetting = mstComsvSettingDao.selectByCd(facilityCd, deviceEdgeNo);

    // 次患者の治療予定開始日時作成[YYYYMMDDHHMM形式文字列]
    String treatDateTime = nextPatOrd.getTreatDate() + nextPatOrd.getIndTreatStartTime();

    // 次患者情報送信有無を判定
    boolean needToSend = this.checkNeedToSendPatientInfo(facilityCd, comsvSetting, treatDateTime);

    String patLastName = "";
    String patFirstName = "";
    int treatMode = 0;

    // 送信判定
    if (needToSend) {
      // 送信が必要な場合

      // 患者個人情報取得用引数を生成
      List<String> facilityList = new ArrayList<>();
      facilityList.add(facilityCd);
      List<Long> patIdList = new ArrayList<>();
      patIdList.add(patId);

      // pat_main 患者基本情報取得
      PatMain patMain = patMainDao.selectById(patId);

      // pat_personal_main 患者個人情報取得
      PatPersonalMain patPersonal = patPersonalMainDao.selectById(patId);
      // 院内表示用患者ID
      dto.setDispPatId(patPersonal.getHosp_pat_id());
      // 患者名
      patLastName = patPersonal.getPat_last_name() == null ? "" : patPersonal.getPat_last_name();
      patFirstName = patPersonal.getPat_first_name() == null ? "" : patPersonal.getPat_first_name();

      // #11827 2025.05.14 add 仮想端末姓名結合設定に準拠 TDC米沢 start
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
      String patNameKana;
      try {
      // 施設設定値取得
      nameConcatService.ReadFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.VIRTUAL_TERMINAL_NAME_CONCAT_SETTING);
      // 姓名結合
      patLastName = nameConcatService.NameConcat(patFirstName, patLastName);
      patFirstName = "";
      // #11827 2025.05.14 add 仮想端末姓名結合設定に準拠 TDC米沢 end

      /*****************************
       *  患者名カナ(メモ：患者名フリガナ用)
       *****************************/
      String patLastNameKana = patPersonal.getPat_last_name_kana() == null ? "" : patPersonal.getPat_last_name_kana();
      String patFirstNameKana = patPersonal.getPat_first_name_kana() == null ? ""
          : patPersonal.getPat_first_name_kana();
      // #11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
      // // #9147 2024.01.09 chg 次患者整形 姓名の間に全角SP TDC山崎 start
      // //String patNameKana = patLastNameKana + patFirstNameKana;
      // String patNameKana = patLastNameKana + "　" + patFirstNameKana;
      // // #9147 2024.01.09 chg 次患者整形 姓名の間に全角SP TDC山崎 end
      // 姓名かな結合
        patNameKana = nameConcatService.NameConcat(patFirstNameKana, patLastNameKana);
      // #11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 end
      } finally {
        nameConcatService.ClearFacilitySettingValue();
      }
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
      dto.setPatNameKana(patNameKana);

      /*********************
       *  入外区分(メモ：状態用)
       *********************/
      Integer inOut = patPersonal.getIn_out_class();
      dto.setInOut(inOut);

      /***************************
       *  性別・誕生日(メモ：性別・年齢用)
       ***************************/
      int patSex = patPersonal.getPat_sex();
      String patBirthDay = patPersonal.getPat_birthday();
      dto.setPatSexAge(patSex, patBirthDay);

      /***********
       * 身体情報
       ***********/
      List<PatUnique> patUniqueList = patUniqueDao.selectByIdList(patIdList);
      PatUnique patUnique = new PatUnique();
      if (patUniqueList.size() > 0) {
        patUnique = patUniqueList.get(0);
        String physicalInfo = patUnique.getPhysical_info();
        // #9147 2024.06.26 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 start
        //dto.setPhysicals(physicalInfo);
        dto.setPhysicals(physicalInfo, nextPatOrd.getIndDw(), nextPatOrd.getTreatDate());
        // #9147 2024.06.26 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 end
      } else {
        // #9147 2024.06.26 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 start
        //dto.setPhysicals("");
        dto.setPhysicals("", nextPatOrd.getIndDw(), nextPatOrd.getTreatDate());
        // #9147 2024.06.26 chg 次患者整形 指示DW→無ければpat_uniqueの透析日以前の最新DW TDC山崎 end
      }

      // #9290 2023.10.16 mod Nameが存在する場合は新たに取得しない TDC片口 start
      /******************
       *  治療方法 モード・名称
       ******************/
      int treatmentCd = nextPatOrd.getIndTreatmentCd();
      MstTreatment mstTreatment = mstTreatmentDao.selectByCd(treatmentCd);
      treatMode = mstTreatment.getDeviceMode();
//      String treatName = mstTreatment.getTreatmentName() == null ? "" : mstTreatment.getTreatmentName();
      String treatName = nextPatOrd.getIndTreatmentName();
      if (treatName == null) {
        treatName = mstTreatment.getTreatmentName() == null ? "" : mstTreatment.getTreatmentName();
      }
      dto.setTreatMode(treatMode);
      dto.setTreatName(treatName);

      /***********
       *  担当医 姓名
       ***********/
      String chargeStaffInfo = patMain.getCharge_staff_info();
      Long StaffCd = 0L;
      String doctorLastName = "";
      String doctorFirstName = "";
      try {
        StaffCd = dto.getStaffCdOfMainDoctor(chargeStaffInfo);
        MstPersonalUser mstPersonalUser = mstPersonalUserDao.selectById(StaffCd);
        if (mstPersonalUser != null) {
          doctorLastName = mstPersonalUser.getUserLastName() == null ? "" : mstPersonalUser.getUserLastName();
          doctorFirstName = mstPersonalUser.getUserFirstName() == null ? "" : mstPersonalUser.getUserFirstName();
        }
      } catch (IOException e1) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e1));
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
      // #9147 2024.01.10 chg 次患者整形 姓名の間に半角SP TDC山崎 start
      //String doctorName = doctorLastName + doctorFirstName;
      String doctorName = doctorLastName + " " + doctorFirstName;
      // #9147 2024.01.10 chg 次患者整形 姓名の間に半角SP TDC山崎 end
      dto.setDoctorName(doctorName);

      /***********
       *  共通診療情報(病棟・所属科)
       ***********/
      String medicalCareInfo = patMain.getMedical_care_info();
      MedicalCareInfo mediCareInfo = medicalCareInfoService.createMedicalCareInfo(medicalCareInfo);
      /// 名称をマスタから引き当てる
      mediCareInfo.setMainCourseName(medicalCareInfoService.findMainCourseName(mediCareInfo));
      mediCareInfo.setWardName(medicalCareInfoService.findWardName(mediCareInfo));
      /// DTOにセット
      dto.setMediCares(mediCareInfo);

      /************
       *  治療条件
       ************/
      String indCondInfo = nextPatOrd.getIndCondInfo();
      CondInfo condInfo = condInfoService.createCondInfo(indCondInfo);
      /// 名称などをマスタから引き当てる
      //// ダイアライザ
      CondInfoItem dialyzer = condInfo.getDialyzer();
      // dialyzer.setName(condInfoService.findDialyzerName(condInfo));
      if (!StringUtils.hasText(dialyzer.getName())) {
        dialyzer.setName(condInfoService.findDialyzerName(condInfo));
      }
      //add redmine bug#5525 劉 start
      ////吸着カラム
      CondInfoItem adsorbent = condInfo.getAdsorbent();
      //adsorbent.setName(condInfoService.findEquipmentName(adsorbent));
      if (!StringUtils.hasText(adsorbent.getName())) {
        adsorbent.setName(condInfoService.findEquipmentName(adsorbent));
      }
      ////1次膜
      CondInfoItem oneceMembrane = condInfo.getOneceMembrane();
      //oneceMembrane.setName(condInfoService.findEquipmentName(oneceMembrane));
      if (!StringUtils.hasText(oneceMembrane.getName())){
        oneceMembrane.setName(condInfoService.findEquipmentName(oneceMembrane));
      }
      ////2次膜
      CondInfoItem secondaryMembrane = condInfo.getSecondaryMembrane();
      //secondaryMembrane.setName(condInfoService.findEquipmentName(secondaryMembrane));
      if (!StringUtils.hasText(secondaryMembrane.getName())){
        secondaryMembrane.setName(condInfoService.findEquipmentName(secondaryMembrane));
      }
      //add redmine bug#5525 劉 end
      //// VA
      CondInfoItem va = condInfo.getVa();
      //va.setName(condInfoService.findVaName(condInfo));
      if (!StringUtils.hasText(va.getName())){
        va.setName(condInfoService.findVaName(condInfo));
      }
      //// 透析液
      CondInfoItem dialysisFluid = condInfo.getDialysisFluid();
      /*
      HashMap<String, String> dialysisFluidMap = condInfoService.findDialysisFluidName(condInfo);
      dialysisFluid.setName(dialysisFluidMap.get("name"));
      dialysisFluid.setUnit(dialysisFluidMap.get("unit"));
      if ( dialysisFluidMap.containsKey("decimal_point") && Utilities.isNumber(dialysisFluidMap.get("decimal_point"))) {
        dialysisFluid.setDecimalPoint(Integer.parseInt(dialysisFluidMap.get("decimal_point")));
      }
      */
      if (!StringUtils.hasText(dialysisFluid.getName())) {
        HashMap<String, String> dialysisFluidMap = condInfoService.findDialysisFluidName(condInfo);
        dialysisFluid.setName(dialysisFluidMap.get("name"));
        dialysisFluid.setUnit(dialysisFluidMap.get("unit"));
        if (dialysisFluidMap.containsKey("decimal_point") && Utilities.isNumber(dialysisFluidMap.get("decimal_point"))) {
          dialysisFluid.setDecimalPoint(Integer.parseInt(dialysisFluidMap.get("decimal_point")));
        }
      }
      //// 抗凝固剤
      CondInfoItem anticoagulant = condInfo.getAnticoagulant();
      /*
      HashMap<String, String> anticoagulantMap = condInfoService.findAnticoagulantName(condInfo);
      anticoagulant.setName(anticoagulantMap.get("name"));
      anticoagulant.setUnit(anticoagulantMap.get("unit"));
      if ( anticoagulantMap.containsKey("decimal_point") && Utilities.isNumber(anticoagulantMap.get("decimal_point"))) {
        anticoagulant.setDecimalPoint(Integer.parseInt(anticoagulantMap.get("decimal_point")));
      }
       */
      if (!StringUtils.hasText(anticoagulant.getName())) {
        HashMap<String, String> anticoagulantMap = condInfoService.findAnticoagulantName(condInfo);
        anticoagulant.setName(anticoagulantMap.get("name"));
        anticoagulant.setUnit(anticoagulantMap.get("unit"));
        if (anticoagulantMap.containsKey("decimal_point") && Utilities.isNumber(anticoagulantMap.get("decimal_point"))) {
          anticoagulant.setDecimalPoint(Integer.parseInt(anticoagulantMap.get("decimal_point")));
        }
      }

      // #9147 2024.01.25 chg 次患者整形 A針だがSN使用の場合はSNの情報をセット TDC山崎 start
//      //// A針
//      CondInfoItem needleA = condInfo.getNeedleA();
//      /*
//      HashMap<String, String> needleAMap = condInfoService.findNeedleAName(condInfo);
//      needleA.setName(needleAMap.get("name"));
//      needleA.setUnit(needleAMap.get("unit"));
//      */
//      if (!StringUtils.hasText(needleA.getName())) {
//        HashMap<String, String> needleAMap = condInfoService.findNeedleAName(condInfo);
//        needleA.setName(needleAMap.get("name"));
//        needleA.setUnit(needleAMap.get("unit"));
//      }

      //// A針(※SN使用の場合はココにシングルニードルの情報をセット)
      CondInfoItem needleA = condInfo.getNeedleA();

      HashMap<String, String> needleMap;
      if (condInfo.getUseSingleNeedle().getValue().equals("1")) {
        needleMap = condInfoService.findNeedleSnName(condInfo);

        // SN使用なので A針データ格納場所 に シングルニードルの情報 を上書き
        CondInfoItem needleS = condInfo.getNeedleS();
        needleA.setCd(needleS.getCd());
        needleA.setName(needleS.getName());
        needleA.setValue(needleS.getValue());
        needleA.setUnit(needleS.getUnit());
      } else {
        needleMap = condInfoService.findNeedleAName(condInfo);
      }

      if (!StringUtils.hasText(needleA.getName())) {
        needleA.setName(needleMap.get("name"));
        needleA.setUnit(needleMap.get("unit"));
      }
      // #9147 2024.01.25 chg 次患者整形 A針だがSN使用の場合はSNの情報をセット TDC山崎 end

      //// V針
      CondInfoItem needleV = condInfo.getNeedleV();
      /*
      HashMap<String, String> needleVMap = condInfoService.findNeedleVName(condInfo);
      needleV.setName(needleVMap.get("name"));
      needleV.setUnit(needleVMap.get("unit"));
       */
      if (!StringUtils.hasText(needleV.getName())) {
        HashMap<String, String> needleVMap = condInfoService.findNeedleVName(condInfo);
        needleV.setName(needleVMap.get("name"));
        needleV.setUnit(needleVMap.get("unit"));
      }
      // DTOにセット
      dto.setConds(condInfo);

      /***********
       *  医療材料
       ***********/
      String indEquipInfo = nextPatOrd.getIndEquipInfo();
      //mod #10412 次患者更新関連全体見直し対応 朴 start
      if (StringUtils.hasText(indEquipInfo)) {
        // 医療材料情報から医療材料コードのリストを取得
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        List<Integer> equipCdList = null;
        try {
          equipCdList = dto.extractCodeList(indEquipInfo, 0);
        } catch (JacksonException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        // 医療材料コードに対応した情報を医療材料マスタから取得する
//      List<MstEquipment> mstEquipment = mstEquipmentDao.selectByCdList(SelectOptions.get(), equipCdList);
        List<MstEquipment> mstEquipment = CollectionUtils.isEmpty(equipCdList) ?
          new ArrayList<>() :
          mstEquipmentDao.selectByCdList(SelectOptions.get(), equipCdList);

        // 医療材料情報からダイアライザコードのリストを取得
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang satrt
        List<Integer> dialyzerCdList = null;
        try {
          dialyzerCdList = dto.extractCodeList(indEquipInfo, 1);
        } catch (JacksonException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        // 医療材料コードに対応した情報を医療材料マスタから取得する
        List<MstDialyzer> mstDialyzer = CollectionUtils.isEmpty(dialyzerCdList) ?
          new ArrayList<>() :
          mstDialyzerDao.selectAllByCdList(SelectOptions.get(), dialyzerCdList);

        // DTOにセット
        // #11339 2024.12.05 mod 次患者情報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 start
//        dto.setEquips(indEquipInfo, mstEquipment, mstDialyzer);
        String sortedIndEquipInfo = medicineAndEquipmentUtilService.getSortedEquipInfo(facilityCd, indEquipInfo);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        try {
          dto.setEquips(sortedIndEquipInfo, mstEquipment, mstDialyzer);
        } catch (JacksonException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        // #11339 2024.12.05 mod 次患者情報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 end
      }
      //mod #10412 次患者更新関連全体見直し対応 朴 end

      /***********
       *  薬剤
       ***********/
      String indMediInfo = nextPatOrd.getIndMediInfo();
      //mod #10412 次患者更新関連全体見直し対応 朴 start
      if (StringUtils.hasText(indMediInfo)) {
        /// 薬剤情報から薬剤コードのリストを取得
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        List<List<Integer>> mediCdList = null;
        try {
          mediCdList = dto.extractMediCodeList(indMediInfo);
        } catch (JacksonException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        /// 薬剤コードのリストに対応した情報を薬剤マスタから取得する
//      List<MstMedicine> mstMedicine = mstMedicineDao.selectAllByCdList(SelectOptions.get(), mediCdList.get(0));
        List<MstMedicine> mstMedicine = CollectionUtils.isEmpty(mediCdList.get(0)) ?
          new ArrayList<>() :
          mstMedicineDao.selectAllByCdList(SelectOptions.get(), mediCdList.get(0));
        /// 調整薬剤コードのリストに対応した情報を薬剤マスタから取得する
//      List<MstMedicineMix> mstMedicineMix = mstMedicineMixDao.selectByMedicineMixCdList2(mediCdList.get(1));
        List<MstMedicineMix> mstMedicineMix = CollectionUtils.isEmpty(mediCdList.get(1)) ?
          new ArrayList<>() :
          mstMedicineMixDao.selectByMedicineMixCdList2(mediCdList.get(1));
        /// DTOにセット
        // #11339 2024.12.05 mod 次患者情報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 start
//        dto.setMedis(indMediInfo, mstMedicine, mstMedicineMix);
        String sortedIndMediInfo = medicineAndEquipmentUtilService.getSortedMedicineInfo(facilityCd, indMediInfo);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        try {
          dto.setMedis(sortedIndMediInfo, mstMedicine, mstMedicineMix);
        } catch (JacksonException e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        }
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
        // #11339 2024.12.05 mod 次患者情報の投与薬剤、医療材料の並び順を設定合わせてソート TDC片口 end
        // #9290 2023.10.16 mod Nameが存在する場合は新たに取得しない TDC片口 end
      }
      //mod #10412 次患者更新関連全体見直し対応 朴 end
    }

    /***** 戻り値作成処理 ******/

    // メモ設定取得
    String lcdNpat = comsvSetting.getLcdNpat();

    // 取得したメモの表示順をもとにメモ項目を取得する
    List<LcdResponseStruct> memoList = new ArrayList<LcdResponseStruct>();
    // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 start
//    for (int initlop = 0; initlop < 10; initlop++) {
//      memoList.add(null);
//    }
//    try {
//      int[] dispOrderArray = dto.getDispOrderList(lcdNpat);
//      for (int dispOrderLop = 0; dispOrderLop < 10; dispOrderLop++) {
//        int itemCd = dispOrderArray[dispOrderLop];
//        LcdResponseStruct item = dto.getMemoItemByCd(itemCd);
//        memoList.set(dispOrderLop, item);
//      }
//    } catch (IOException e) {
//      e.printStackTrace();
//    }

    // 装置通信・仮想端末マスタの次患者情報2段組表示[ON]ならセットするメモ20件、[OFF]ならセットするメモ10件(＝セットしなかった後半10件はnull)
    int setMemoCount = 10;
    if (comsvSetting.getNextPatSplitarea().equals("1")) {
      setMemoCount = 20;
    }

    try {
      var dispOrderArray = dto.getDispOrderList(lcdNpat, setMemoCount);
        for (int i : dispOrderArray) {
            LcdResponseStruct item = dto.getMemoItemByCd(i); // 未設定=(codeが0)でも「null」ではなく「…"code":0…といった構造」が返ってくる
            memoList.add(item);
        }
    } catch (IOException e) {
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
    }
    // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 end

    // 応答情報作成
    ComsvNextPatOrdResponse response = new ComsvNextPatOrdResponse();
    response.setNeedToSend(needToSend ? 1 : 0);
    response.setPatFirstName(patFirstName);
    response.setPatLastName(patLastName);
    response.setDialysisDate(nextPatOrd.getTreatDate());
    response.setKur(nextPatOrd.getKurName());

    // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 start
//    response.setMemo1(memoList.get(0));
//    response.setMemo2(memoList.get(1));
//    response.setMemo3(memoList.get(2));
//    response.setMemo4(memoList.get(3));
//    response.setMemo5(memoList.get(4));
//    response.setMemo6(memoList.get(5));
//    response.setMemo7(memoList.get(6));
//    response.setMemo8(memoList.get(7));
//    response.setMemo9(memoList.get(8));
//    response.setMemo10(memoList.get(9));

    // メモ1～10
    response.setMemo1(memoList.get(0));
    response.setMemo2(memoList.get(1));
    response.setMemo3(memoList.get(2));
    response.setMemo4(memoList.get(3));
    response.setMemo5(memoList.get(4));
    response.setMemo6(memoList.get(5));
    response.setMemo7(memoList.get(6));
    response.setMemo8(memoList.get(7));
    response.setMemo9(memoList.get(8));
    response.setMemo10(memoList.get(9));

    // 装置通信・仮想端末マスタの次患者情報2段組表示[ON]
    if (comsvSetting.getNextPatSplitarea().equals("1")) {
      // メモ11～20(セットしない場合はjsonで …"memo11":null… となる)
      response.setMemo11(memoList.get(10));
      response.setMemo12(memoList.get(11));
      response.setMemo13(memoList.get(12));
      response.setMemo14(memoList.get(13));
      response.setMemo15(memoList.get(14));
      response.setMemo16(memoList.get(15));
      response.setMemo17(memoList.get(16));
      response.setMemo18(memoList.get(17));
      response.setMemo19(memoList.get(18));
      response.setMemo20(memoList.get(19));
    }
    // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 end

    response.setIsInfect(nextPatOrd.getIsInfect());
    response.setMode(treatMode);

    return response;
  }

  /**
   * 通信サーバ用治療情報の条件送信日時更新
   * @param ord_no
   * @param dial_state
   * @param send_date
   * @return
   */
  @Override
  @Transactional
  public int updateSendDate(ComsvOrdMain param) {
    // #10889 2024.09.05 mod トリガー処理を修正 TDC片口 start
//    return comsvOrdMainDao.updateSendDate(param);
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
    int ret = comsvOrdMainDao.updateSendDate(param);
    if (ret > 0) {
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));
    }
    return ret;
    // #10889 2024.09.05 mod トリガー処理を修正 TDC片口 end
  }

  /**
   * 治療情報（治療開始日時）を更新
   * @param ord_no
   * @param pat_id
   * @param dial_state
   * @param start_date
   * @return
   */
  @Override
  @Transactional
  public int updateStartDate(ComsvOrdMain param) {
    // #10889 2024.09.05 mod トリガー処理を修正 TDC片口 start
//    return comsvOrdMainDao.updateStartDate(param);
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
    int ret = comsvOrdMainDao.updateStartDate(param);
    if (ret > 0) {
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));
    }
    return ret;
    // #10889 2024.09.05 mod トリガー処理を修正 TDC片口 end
  }

  /**
   * 通信サーバ用治療情報の治療終了日時更新
   * @param ord_no
   * @param dial_state
   * @param end_date
   * @return
   */
  @Override
  @Transactional
  public int updateEndDate(ComsvOrdMain param) {
    // #10889 2024.09.05 mod トリガー処理を修正 TDC片口 start
//    return comsvOrdMainDao.updateEndDate(param);
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
    int ret = comsvOrdMainDao.updateEndDate(param);
    if (ret > 0) {
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(param.getOrdNo());
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));
    }
    return ret;
    // #10889 2024.09.05 mod トリガー処理を修正 TDC片口 end
  }
//mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  /**
   * 通信サーバ用治療情報の愁訴処置者更新
   * @param ordNo
   * @param ctlNo
   * @param occurDate
   * @param staffCd
   * @return
   */
  @Override
  @Transactional
  //public int updateCompTreatStaff(Long ordNo, String occurDate, String staffCd) {
  public int updateCompTreatStaff(Long ordNo, int ctlNo, String occurDate, String staffCd) {
    //return treatStaffAdd(ordNo, occurDate, staffCd);
    return complaintTreatStaffAdd(ordNo, ctlNo, occurDate, staffCd);
}
//mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
  /**
   * 通信サーバ用治療情報の酸素吸入更新
   * @param ordNo
   * @param ctlNo
   * @param rowNo
   * @param occurDate
   * @param oxygenStart
   * @param oxygenAmount
   * @return
   */
  @Override
  @Transactional
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  //public int updateOxygen(Long ordNo, String occurDate, String oxygenStart, String oxygenAmount) {
  //mod 複数組の酸素吸入データマッチング問題に対応 劉 start
  //public int updateOxygen(Long ordNo, int ctlNo, int rowNo, String occurDate, String oxygenStart, String oxygenAmount) {
  public int updateOxygen(Long ordNo, int ctlNo, int rowNo, String occurDate, String oxygenStart, String oxygenAmount, String linkStartDate) {
  //mod 複数組の酸素吸入データマッチング問題に対応 劉 end
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    if (occurDate.equals("null") == false) {
      occurDate = '"' + occurDate + '"';
    }
    if (oxygenStart.equals("null") == false) {
      oxygenStart = '"' + oxygenStart + '"';
    }

    // 愁訴処置者情報（酸素吸入）の登録
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    //return comsvOrdMainDao.updateOxygenAdd(ordNo, occurDate, oxygenStart, oxygenAmount);
    //mod 複数組の酸素吸入データマッチング問題に対応 劉 start
    //return comsvOrdMainDao.updateOxygenAdd(ordNo, ctlNo, rowNo, occurDate, oxygenStart, oxygenAmount);
    // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
    MstComplaint virtualMstComp = new MstComplaint();
    comsvOrdMainDao.updateComplaintAdd(ordNo, ctlNo, rowNo, occurDate, virtualMstComp);
    // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end

    return comsvOrdMainDao.updateOxygenAdd(ordNo, ctlNo, rowNo, occurDate, oxygenStart, oxygenAmount, linkStartDate);
    //mod 複数組の酸素吸入データマッチング問題に対応 劉 end
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
  }

  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  /**
   * 通信サーバ用治療情報の酸素吸入処置者更新
   * @param ordNo
   * @param ctlNo
   * @param rowNo
   * @param occurDate
   * @param staffId
   * @return
   */
  @Override
  @Transactional
  public int updateOxygenStaff(Long ordNo, int ctlNo, int rowNo, String occurDate, String staffCd) {
    //return treatStaffAdd(ordNo, occurDate, staffCd);
    return treatStaffAdd(ordNo, ctlNo, rowNo, occurDate, staffCd);
  }
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end

  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  //private int treatStaffAdd(Long ordNo, String occurDate, String staffCd) {
  private int treatStaffAdd(Long ordNo, int ctlNo, int rowNo, String occurDate, String staffCd) {
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
    if (occurDate.equals("null") == false) {
      occurDate = '"' + occurDate + '"';
    }

    // NOTE: ユーザー名称を保存。最終的には暗号化しないといけない気がする
    String userName = null;
    try {
      MstPersonalUser user = mstPersonalUserDao.selectById(Long.valueOf(staffCd));
      userName = "";
      if (!Objects.isNull(user)) {
        userName = "\"" + user.getUserLastName() + " " + user.getUserFirstName() + "\"";
        // #11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
        // 透析番号から施設コードを取得
        String facilityCd = ordMainDao.selectFacilityCdByOrdNo(ordNo);
        if(facilityCd != null) {
          // 施設コードが取得できた場合
          // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
          try {
          // 施設設定値取得
          nameConcatService.ReadFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.VIRTUAL_TERMINAL_NAME_CONCAT_SETTING);
          // 姓名結合
          userName = "\"" + nameConcatService.NameConcat(user.getUserFirstName(), user.getUserLastName()) + "\"";
          } finally {
            nameConcatService.ClearFacilitySettingValue();
          }
          // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
        }
        // #11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("スタッフ名称取得エラー CD:" + staffCd);
      eventLogMessage.setSqlIdentification("(user_id = " + staffCd + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "MstPersonalUserDao/selectById");
    }


    // 愁訴処置者情報の登録
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
    //return comsvOrdMainDao.updateTreatStaffAdd(ordNo, occurDate, staffCd, userName);
    return comsvOrdMainDao.updateTreatStaffAdd(ordNo, ctlNo, rowNo, occurDate, staffCd, userName);
    //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
  }

  private int complaintTreatStaffAdd(Long ordNo, int ctlNo, String occurDate, String staffCd) {
    if (occurDate.equals("null") == false) {
      occurDate = '"' + occurDate + '"';
    }

    // NOTE: ユーザー名称を保存。最終的には暗号化しないといけない気がする
    String userName = null;
    try {
      MstPersonalUser user = mstPersonalUserDao.selectById(Long.valueOf(staffCd));
      userName = "";
      if (!Objects.isNull(user)) {
        userName = "\"" + user.getUserLastName() + " " + user.getUserFirstName() + "\"";
        // #11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
        // 透析番号から施設コードを取得
        String facilityCd = ordMainDao.selectFacilityCdByOrdNo(ordNo);
        if(facilityCd != null) {
          // 施設コードが取得できた場合
          // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
          try {
          // 施設設定値取得
          nameConcatService.ReadFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.VIRTUAL_TERMINAL_NAME_CONCAT_SETTING);
          // 姓名結合
          userName = "\"" + nameConcatService.NameConcat(user.getUserFirstName(), user.getUserLastName()) + "\"";
          } finally {
            nameConcatService.ClearFacilitySettingValue();
          }
          // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
        }
        // #11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("スタッフ名称取得エラー CD:" + staffCd);
      eventLogMessage.setSqlIdentification("(user_id = " + staffCd + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, "MstPersonalUserDao/selectById");
    }


    // 愁訴処置者情報の登録
    return comsvOrdMainDao.updateComplaintTreatStaffAdd(ordNo, ctlNo, occurDate, staffCd, userName);
  }

  /**
   * 通信サーバ用治療情報の穿刺者情報更新
   * @param inpNo
   * @param ordNo
   * @param userId
   * @param userDate
   * @return
   */
  @Override
  @Transactional
  public int updatePunctureUser(int inpNo, Long ordNo, Long userId, String userDate) {

    if (userDate.equals("null") == false) {
      userDate = '"' + userDate + '"';
    }

    LcdReq51 lcdReq51 = ordMainDao.selectRstUserInfoByNo(ordNo);
    String date = lcdReq51.getPunctureDate();
    if (Objects.equals(date, null)) {
      date = userDate;
    } else {
      date = '"' + date + '"';
    }

    MstPersonalUser user;
    String lastName = null;
    String firstName = null;
    // 穿刺者名取得
    if (userId != 0) {
      user = mstPersonalUserDao.selectById(userId);
      lastName = user.getUserLastName();
      if (!Objects.equals(lastName, null)) {
    	  lastName = '"' + lastName + '"';
      }
      firstName = user.getUserFirstName();
      if (!Objects.equals(firstName, null)) {
    	  firstName = '"' + firstName + '"';
      }
    }

    // 穿刺者登録
    return comsvOrdMainDao.updatePunctureUser(inpNo, ordNo, userId, date, userDate, lastName, firstName);
  }

  /**
   * 通信サーバ用治療情報の返血者情報更新
   * @param inpNo
   * @param ordNo
   * @param userId
   * @param userDate
   * @return
   */
  @Override
  @Transactional
  public int updateReturnUser(int inpNo, Long ordNo, Long userId, String userDate) {

    if (userDate.equals("null") == false) {
      userDate = '"' + userDate + '"';
    }

    LcdReq51 lcdReq51 = ordMainDao.selectRstUserInfoByNo(ordNo);
    String date = lcdReq51.getReturnDate();
    if (Objects.equals(date, null)) {
      date = userDate;
    } else {
      date = '"' + date + '"';
    }

    MstPersonalUser user;
    String lastName = null;
    String firstName = null;
    // 穿刺者名取得
    if (userId != 0) {
      user = mstPersonalUserDao.selectById(userId);
      lastName = user.getUserLastName();
      if (!Objects.equals(lastName, null)) {
    	  lastName = '"' + lastName + '"';
      }
      firstName = user.getUserFirstName();
      if (!Objects.equals(firstName, null)) {
    	  firstName = '"' + firstName + '"';
      }
    }

    // 返血者登録
    return comsvOrdMainDao.updateReturnUser(inpNo, ordNo, userId, date, userDate, lastName, firstName);
  }

  /**
   * 通信サーバ用治療情報の担当者情報更新
   * @param inpNo
   * @param ordNo
   * @param userId
   * @param userDate
   * @return
   */
  @Override
  @Transactional
  public int updateChargeUser(int inpNo, Long ordNo, Long userId, String userDate) {

    if (userDate.equals("null") == false) {
      userDate = '"' + userDate + '"';
    }

    MstPersonalUser user;
    String lastName = null;
    String firstName = null;
    // 穿刺者名取得
    if (userId != 0) {
      user = mstPersonalUserDao.selectById(userId);
      lastName = user.getUserLastName();
      if (!Objects.equals(lastName, null)) {
    	  lastName = '"' + lastName + '"';
      }
      firstName = user.getUserFirstName();
      if (!Objects.equals(firstName, null)) {
    	  firstName = '"' + firstName + '"';
      }
    }

    // 担当者登録
    return comsvOrdMainDao.updateChargeUser(inpNo, ordNo, userId, userDate, lastName, firstName);
  }

  /**
   * 治療情報（実績モニタ値）を更新
   * @param ordNo オーダ番号
   * @param rstBloodCirculate 血液循環量
   * @param rstRunningTime 透析運転時間
   * @param rstKtv Kt/V
   * @param addTotal 除水積算値
   * @param addWaterTotal 補液量現在値
   * @param KtvMeasure Kt/V（測定値）
   * @param ufr ＵＲＲ
   * @return
   */
  @Override
  @Transactional
  public int updateRstMonitor(ComsvOrdMain param) {
    return comsvOrdMainDao.updateRstMonitor(param);
  }

  /**
   * 治療情報（目標除水量）を更新
   * @param ordNo オーダ番号
   * @param waterRemovealTarget 目標除水量
   * @return
   */
  @Override
  @Transactional
  public int updateRstWeight(Long ordNo, String waterRemovalTarget) {
    return comsvOrdMainDao.updateRstWeight(ordNo, waterRemovalTarget);
  }

  /**
   * 治療情報（実績プログラム補液引き残し量）を更新
   * @param ordNo オーダ番号
   * @param rstBloodCirculate プログラム補液引き残し量
   * @return
   */
  @Override
  @Transactional
  public int updatePullLeaveAmount(ComsvOrdMain param) {
    return comsvOrdMainDao.updatePullLeaveAmount(param);
  }

  /**
   * 通信サーバ用治療情報の投与薬剤実施更新
   * @param ordNo オーダ番号
   * @param effectDate 投与実施日時
   * @param noJson No配列（json）
   * @return
   */
  @Override
  @Transactional
  public int updateRstMediInfo(Long ordNo, String effectDate, String noJson) {
    int rtn = 0;

    // JSON処理
    List<Integer> noList = new ArrayList<Integer>();
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_array = mapper.readTree(noJson);
      for (int lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy().asObject();

        noList.add(objectNode.get("no").asInt());
      }
    } catch (tools.jackson.core.JacksonException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      return rtn;
    }

    // 投薬の実施状況を取得
    /// まず対象となるオーダー番号のリストを作成
    List<Long> ordNoList = new ArrayList<Long>();
    ordNoList.add(ordNo);
    /// オーダー番号のリストに対応する投薬の実施状況を取得
    List<OrdMain> ordMainList = ordMainDao.selectMediInfoByNoList(ordNoList);
    OrdMain ordMain = ordMainList.get(0);
    // ordNoに対応したmediInfo(JSON文字列)を取得
    String mediInfo = ordMain.getRstMediInfo();
    //add redmine bug#4741 劉 start
    // ordNoに対応したfacilityCdを取得
    String facilityCd = ordMain.getFacilityCd();
    //add redmine bug#4741 劉 end

    // 未実施の投薬を実施にする
    // mediInfo JSON文字列を更新
    //mod redmine bug#4741 劉 start
    //mediInfo = this.updateRstMediToComplete(noList, mediInfo, effectDate);
    // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
    // mediInfo = this.updateRstMediToComplete(noList, mediInfo, effectDate, facilityCd);
    mediInfo = this.updateRstMediToComplete(noList, mediInfo, effectDate, facilityCd, ordNo);
    // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
    //mod redmine bug#4741 劉 end

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

    // ord_mainを更新
    int result = comsvOrdMainDao.updateMediInfo(ordNo, mediInfo);

    //add #10196 Ord_Material_Save code implementation zt start
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm start
//    ordMaterialSaveService.batchProcessingData(
//      Collections.singletonList(
//        ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//          new OrdMaterialSaveDto(
//            ordNo,
//            false,
//            true,
//            false,
//            false,
//            OrdMaterialSaveDto.RST_CLASS
//          )
//        )
//      )
//    );
    ordMaterialSaveService.bulkUpdateByOrdNoInCondMediEquip(Collections.singletonList(ordNo));
    // mod #12250 ord_material_saveの処理を2回重複実行している zkm end
    //add #10196 Ord_Material_Save code implementation zt start

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && result > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    rtn = rtn + result;

    return rtn;
  }

  //mod redmine bug#4741 劉 start
  //private String updateRstMediToComplete(List<Integer> noList, String mediInfo, String effectDate) {
  // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
  // private String updateRstMediToComplete(List<Integer> noList, String mediInfo, String effectDate, String facilityCd) {
  private String updateRstMediToComplete(List<Integer> noList, String mediInfo, String effectDate, String facilityCd, Long ordNo) {
  // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
  //mod redmine bug#4741 劉 end
    // 戻り値格納用StringBuilder
    StringBuilder rtnBuilder = new StringBuilder();
    rtnBuilder.append("[");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(mediInfo)) {
      rtnBuilder.append("]");
      return rtnBuilder.toString();
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    // JSON処理
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_array = mapper.readTree(mediInfo);
      for (int lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy().asObject();

        for (int lop2 = 0; lop2 < noList.size(); lop2++) {
          if (Objects.equals(objectNode.get("no").asInt(), noList.get(lop2))) {
            // 値の変更
            //add redmine bug#5802 劉 start
            //objectNode.put("effect_flg", 1);
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
            //objectNode.put("effect_flg", "1");
            objectNode.put("effect_flg", 1);
            // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
            //add redmine bug#5802 劉 end
            objectNode.put("effect_date", effectDate);

            //add redmine bug#4741 劉 start
            //投薬取得
            Integer mediCd = objectNode.get("cd").asInt();
            MstMedicine mstMedicine = mstMedicineDao.selectByMediCd(mediCd);
            if (null != mstMedicine && "1".equals(mstMedicine.getIsMedicated())) {
              //施設設定取得
              FacilitySettingInfo facilitySettingInfo = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, "3020");
              if (null != facilitySettingInfo && null != facilitySettingInfo.getValue()) {
                //利用者取得
                Long userId = Long.parseLong(facilitySettingInfo.getValue());
                MstPersonalUser userInfo = mstPersonalUserDao.selectById(userId);
                if (null != userInfo) {
                  //実施者の変更
                  objectNode.put("effect_user_id", userId);
                  objectNode.put("effect_user_first_name", userInfo.getUserFirstName());
                  objectNode.put("effect_user_last_name", userInfo.getUserLastName());
                  // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
                  objectNode.put("upd_user_id", userId);
                  objectNode.put("upd_user_first_name", userInfo.getUserFirstName());
                  objectNode.put("upd_user_last_name", userInfo.getUserLastName());
                  ordMainDao.updateUseId(ordNo, userId);
                  // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
                }
              }
            // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
            } else {
              ordMainDao.updateUseId(ordNo, -1L);
            // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
            }
            //add redmine bug#4741 劉 end
            break;
          }
        }
        // objectNodeの文字列化
        rtnBuilder.append(mapper.writeValueAsString(objectNode));
        // 最後以外は区切りのカンマを追加
        if (lop != jsonNode_array.size() - 1) {
          rtnBuilder.append(",");
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

    rtnBuilder.append("]");

    return rtnBuilder.toString();
  }

  /**
   * 通信サーバ用治療情報の投与薬剤実施者更新
   * @param ordNo オーダ番号
   * @param userId 投与実施者コード
   * @param effectDate 投与実施日時
   * @return
   */
  @Override
  @Transactional
  public int updateRstMediInfoUser(Long ordNo, Long userId, String effectDate) {
    int rtn = 0;

    // 投薬の実施状況を取得
    /// まず対象となるオーダー番号のリストを作成
    List<Long> ordNoList = new ArrayList<Long>();
    ordNoList.add(ordNo);
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ordNo + "\n");

    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    boolean setResult = logCommon.setInfo();
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
    /// オーダー番号のリストに対応する投薬の実施状況を取得
    List<OrdMain> ordMainList = ordMainDao.selectMediInfoByNoList(ordNoList);
    OrdMain ordMain = ordMainList.get(0);
    // ordNoに対応したmediInfo(JSON文字列)を取得
    String mediInfo = "";
    mediInfo = ordMain.getRstMediInfo();

    // 未実施の投薬を実施にする
    // mediInfo JSON文字列を更新
    // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
    // mediInfo = this.updateRstMediUserToComplete(mediInfo, userId, effectDate);
    mediInfo = this.updateRstMediUserToComplete(mediInfo, userId, effectDate, ordNo);
    // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end

    // ord_mainを更新
    int result = comsvOrdMainDao.updateMediInfo(ordNo, mediInfo);
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
    if (setResult && result > 0) {
      logCommon.updateLog();
    }
    // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
    rtn = rtn + result;

    return rtn;
  }

  // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
  // private String updateRstMediUserToComplete(String mediInfo, Long userId, String effectDate) {
  private String updateRstMediUserToComplete(String mediInfo, Long userId, String effectDate, Long ordNo) {
  // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
    // 戻り値格納用StringBuilder
    StringBuilder rtnBuilder = new StringBuilder();
    rtnBuilder.append("[");
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --start */
    if(ObjectUtils.isEmpty(mediInfo)) {
      rtnBuilder.append("]");
      return rtnBuilder.toString();
    }
    /* add by shiyw 2024-03-28 #10196 ord_mainのデータ定義の修正:OrdMain.equipInfo/mediInfo/IndCommentInfoがnullの場合を考える --end */
    // JSON処理
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_array = mapper.readTree(mediInfo);
      for (int lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy().asObject();

        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("effect_flg = [" + objectNode.get("effect_flg").asInt() + "] effect_date = ["
                  + objectNode.get("effect_date").asText() + "] effect_date = [" + effectDate + "]");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        if (objectNode.get("effect_flg").asInt() == 1 &&
            objectNode.get("effect_date").asText().equals(effectDate)) {
          // 値の変更
          objectNode.put("effect_user_id", userId);
          // userId に紐づく利用者情報を取得
          if (!Objects.isNull(userId)) {
            MstPersonalUser userInfo = mstPersonalUserDao.selectById(userId);
            if (userInfo != null) {
              objectNode.put("effect_user_first_name", userInfo.getUserFirstName());
              objectNode.put("effect_user_last_name", userInfo.getUserLastName());
              // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
              objectNode.put("upd_user_id", userId);
              objectNode.put("upd_user_first_name", userInfo.getUserFirstName());
              objectNode.put("upd_user_last_name", userInfo.getUserLastName());
              ordMainDao.updateUseId(ordNo, userId);
              // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
            }
          }
        }
        // objectNodeの文字列化
        rtnBuilder.append(mapper.writeValueAsString(objectNode));
        // 最後以外は区切りのカンマを追加
        if (lop != jsonNode_array.size() - 1) {
          rtnBuilder.append(",");
        }
      }
    } catch (tools.jackson.core.JacksonException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    rtnBuilder.append("]");

    return rtnBuilder.toString();
  }

  /**
   * 通信サーバ用治療情報の登録（患者未登録運転開始）
   * @param machine_status
   * @param ComsvOrdMain
   * @return
   */
  @Override
  @Transactional
  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  // public int insertUnregistered(int machine_status, ComsvOrdMain param) {
  public int insertUnregistered(int machine_status, ComsvOrdMain param) throws IOException {
    //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
    // 在宅透析患者情報確認(設定した装置(番号)を使用する患者情報を収集)
    List<PatHhdPattern> lstPatHhdPatern = patHhdPatternDao.selectByMachineNo(param.getFacilityCd(),
        param.getRstMachineNo());
    if (lstPatHhdPatern != null && lstPatHhdPatern.size() > 0) {
      // 在宅患者情報あり
      param.setPatId(lstPatHhdPatern.get(0).getPatId());
      param.setIndCondInfo(lstPatHhdPatern.get(0).getIndCondInfo());
      param.setIndMediInfo(lstPatHhdPatern.get(0).getIndMediInfo());

      // 透析回数
      int dial_count = 0;
      ComsvPatRelated res = comsvPatRelatedService.selectDialCount(lstPatHhdPatern.get(0).getPatId());
      if (res != null) {
        dial_count = res.getDialysisCount();
      }
      param.setRstDialysisCnt(dial_count + 1);
      param.setRstBedCd(lstPatHhdPatern.get(0).getBedCd());
      param.setRstKurCd(0L);
    } else {
      // 在宅患者情報なし
      MstBed bed = findMstBedByMachine(param.getFacilityCd(), param.getRstMachineNo());
      MstKur kur = findMstKurByNowTime(param.getFacilityCd(), param.getStartDate());

      param.setPatId(null);
      param.setRstDialysisCnt(1);
      param.setRstBedCd(0L);
      if (bed != null) {
        param.setRstBedCd(bed.getBedCd());
        param.setRstBedName(bed.getBedName());
      }
      param.setRstKurCd(0L);
      if (kur != null) {
        param.setRstKurCd((long) kur.getKurCd());
        param.setRstKurName(kur.getKurName());
      }
    }

    // 装置番号から装置マスタ情報を取得
    MstMachine machine = null;
    machine = mstMachineDao.selectByMachineNo(param.getRstMachineNo());
    if (machine != null) {
      // 装置治療状態取得
      MntMachineState state = mntMachineStateService.selectByKey(
          machine.getFacilityCd(),
          machine.getMachineTypeCd(),
          machine.getMachineSerial());
      if (state != null) {
        // 現患者判定
        Long ordNo = state.getOrdNo();
        if (ordNo != null) {
          // #10844 2024.08.06 mod 治療状況が治療中(3)の場合、治療終了処理を行う TDC高村 start
          /*
          // ordが状態1,2(治療前)ならば条件送信キャンセル
          ComsvOrdMain ordMain = comsvOrdMainDao.selectByNo(ordNo);
            //8526【デグレ】条件送信済み後に「確認」せず治療を開始し????患者になっても前体重測定済みのまま zhao start
            //if (ordMain != null && Objects.equals(ordMain.getDialState(), OrdMainConst.DialysisState.AFTER_SEND)
            //&& Objects.equals(ordMain.getDialState(), OrdMainConst.DialysisState.CHECKED_SEND)) {
            if (ordMain != null && (Objects.equals(ordMain.getDialState(), OrdMainConst.DialysisState.AFTER_SEND)
            || Objects.equals(ordMain.getDialState(), OrdMainConst.DialysisState.CHECKED_SEND))) {
            //8526【デグレ】条件送信済み後に「確認」せず治療を開始し????患者になっても前体重測定済みのまま zhao end
            // 現患者に対して条件送信キャンセル実施(DB更新のみ)
            SendConditionCancelResponse res = new SendConditionCancelResponse();
            try {
              res = sendConditionCancelService.DoCancelDBAction(ordNo, machine);
            } catch (Exception ex){
              res.isSuccess = false;
              res.errorMessage = ex.getMessage();
              res.ex = ex;
            }
            if (!res.isSuccess) {
              // 条件送信キャンセル失敗
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage("API insertUnregistered() DoCancelDBAction failed. error:" + res.errorMessage);
              eventLogMessage.setMachineTypeCd(machine.getMachineTypeCd());
              eventLogMessage.setPatId(param.getPatId().toString());
              eventLogMessage.setSqlIdentification("ordNo = " + ordNo + ",machine = " + machine);
              eventLogMessage.setFacilityCd(machine.getFacilityCd());
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
            }
          }
          */
          ComsvOrdMain ordMain = comsvOrdMainDao.selectByNo(ordNo);
          if (ordMain != null) {
            if (Objects.equals(ordMain.getDialState(), OrdMainConst.DialysisState.AFTER_SEND)
              || Objects.equals(ordMain.getDialState(), OrdMainConst.DialysisState.CHECKED_SEND)) {
              // 治療状況が治療前(1,2)の場合、条件送信キャンセルを行う(DB更新のみ)
              SendConditionCancelResponse res = new SendConditionCancelResponse();
              try {
                res = sendConditionCancelService.DoCancelDBAction(ordNo, machine);
              } catch (Exception ex){
                res.isSuccess = false;
                res.errorMessage = ex.getMessage();
                res.ex = ex;
              }
              if (!res.isSuccess) {
                // 条件送信キャンセル失敗
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("API insertUnregistered() DoCancelDBAction failed. error:" + res.errorMessage);
                eventLogMessage.setMachineTypeCd(machine.getMachineTypeCd());
                eventLogMessage.setPatId(param.getPatId().toString());
                eventLogMessage.setSqlIdentification("ordNo = " + ordNo + ",machine = " + machine);
                eventLogMessage.setFacilityCd(machine.getFacilityCd());
                logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
              }
            }
            else if (Objects.equals(ordMain.getDialState(), OrdMainConst.DialysisState.DIALYSIS)) {
              // 治療状況が治療中(3)の場合、治療終了処理を行う
              ordMain.setDialState(OrdMainConst.DialysisState.AFTER_DIALYSIS);
              Timestamp nowTime = Timestamp.valueOf(LocalDateTime.now());
              ordMain.setEndDate(nowTime);
              int ret = comsvOrdMainService.updateEndDate(ordMain);
              if (ret <= 0) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("治療終了処理失敗");
                eventLogMessage.setFacilityCd(ordMain.getFacilityCd());
                logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              }
            }
          }
          // #10844 2024.08.06 mod 治療状況が治療中(3)の場合、治療終了処理を行う TDC高村 end
        }
      }
    }

    ObjectMapper mapper = new ObjectMapper();

    // 治療情報の登録（患者未登録運転開始）
    // rst_puncture_user_info
    // rst_return_user_info
    // rst_charge_user_info
    StringJoiner user = new StringJoiner(",");
    user.add("\"user_id_1\": null");
    user.add("\"user_last_name_1\": null");
    user.add("\"user_first_name_1\": null");
    user.add("\"user_id_2\": null");
    user.add("\"user_last_name_2\": null");
    user.add("\"user_first_name_2\": null");
    String user_date = "\"date\": null";
    String user_reg_date = "\"date_1\": null,\"date_2\": null";

    StringJoiner sjRstPunctureUserInfo = new StringJoiner(",", "{", "}");
    sjRstPunctureUserInfo.add(user.toString()).add(user_date).add(user_reg_date);
    param.setRstPunctureUserInfo(sjRstPunctureUserInfo.toString());

    StringJoiner sjReturnUserInfo = new StringJoiner(",", "{", "}");
    sjReturnUserInfo.add(user.toString()).add(user_date).add(user_reg_date);
    param.setRstReturnUserInfo(sjReturnUserInfo.toString());

    StringJoiner sjRstChargeUserInfo = new StringJoiner(",", "{", "}");
    sjRstChargeUserInfo.add(user.toString()).add(user_reg_date);
    param.setRstChargeUserInfo(sjRstChargeUserInfo.toString());

    // rst_weight_info
    OrdMainRstWeightInfo info = new OrdMainRstWeightInfo();
    try {
      param.setRstWeightInfo(mapper.writeValueAsString(info));
    } catch (JacksonException e) {
      // 手打ち
      StringJoiner sjWeight = new StringJoiner(",", "{", "}");
      sjWeight.add("\"weight_measure_before\": null")
          .add("\"weight_before\": null")
          .add("\"weight_before_date\": null")
          .add("\"weight_measure_after\": null")
          .add("\"weight_after\": null")
          .add("\"weight_after_date\": null")
          .add("\"ctr\": null")
          .add("\"ctr_measure_date\": null")
          .add("\"ctr_weight\": null")
          .add("\"water_removal_target\": null")
          .add("\"water_removal_rst\": null")
          .add("\"kt_v_measure\": null")
          .add("\"urr\": null")
          .add("\"weight_decreased\": null")
          .add("\"re_loop_rate_main\": null")
          // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
          .add("\"recrcl_rt\": null")
          .add("\"ihdf_pll\": null")
          .add("\"sttc_vns_prssr\": null")
          .add("\"iap_rt\": null");
          // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end
      ;
      param.setRstWeightInfo(sjWeight.toString());
    }
    // rst_tare_info
    try {
      OrdMainRstTareChild tare = new OrdMainRstTareChild();
      StringBuilder tare_info = new StringBuilder();
      tare_info.append("{\"before\": ");
      tare_info.append(mapper.writeValueAsString(tare));
      tare_info.append(",\"after\": ");
      tare_info.append(mapper.writeValueAsString(tare));
      tare_info.append("}");
      param.setRstTareInfo(tare_info.toString());
    } catch (JacksonException e) {
      // 手打ち
      StringJoiner tare = new StringJoiner(",", "{", "}");
      tare.add("\"name_1\": null, \"weight_1\": null");
      tare.add("\"name_2\": null, \"weight_2\": null");
      tare.add("\"name_3\": null, \"weight_3\": null");
      tare.add("\"name_4\": null, \"weight_4\": null");
      tare.add("\"name_5\": null, \"weight_5\": null");
      tare.add("\"wheel_chair_cd\": null");
      tare.add("\"wheel_chair_name\": null");
      tare.add("\"wheel_chair_weight\": null");
      StringBuilder tare_info = new StringBuilder();
      tare_info.append("{\"before\": ");
      tare_info.append(tare.toString());
      tare_info.append(",\"after\": ");
      tare_info.append(tare.toString());
      tare_info.append("}");
      param.setRstTareInfo(tare_info.toString());
    }
    // rst_off_water_info
    try {
      TareOrOffWaterJson water = new TareOrOffWaterJson();
      param.setRstOffWaterInfo(mapper.writeValueAsString(water));
    } catch (JacksonException e) {
      // 手打ち
      StringJoiner water = new StringJoiner(",", "{", "}");
      water.add("\"name_1\": null, \"weight_1\": null");
      water.add("\"name_2\": null, \"weight_2\": null");
      water.add("\"name_3\": null, \"weight_3\": null");
      water.add("\"name_4\": null, \"weight_4\": null");
      water.add("\"name_5\": null, \"weight_5\": null");
      param.setRstOffWaterInfo(water.toString());
    }

    int ret = comsvOrdMainDao.insertUnregisteredPat(param);
    if (ret > 0) {
      // 登録されたオーダ番号を取得
      ComsvOrdMain ord = null;
      ord = selectUnregisteredPat(param);

      // 装置状態管理の透析開始日時更新（患者未登録運転開始）
      MntMachineState state = new MntMachineState();
      state.setFacilityCd(machine.getFacilityCd());
      state.setMachineTypeCd(machine.getMachineTypeCd());
      state.setMachineSerial(machine.getMachineSerial());
      state.setOrdNo(ord.getOrdNo());
      state.setNextOrdNo(ord.getOrdNo());
      state.setMachineStatus(machine_status);
      state.setStartDate(param.getStartDate());
      // 患者情報を登録(在宅透析の場合はpat_idが登録される、それ以外はnullが登録される)
      //add 患者発生時の次患者情報送信#1437 --趙-- start
      //state.setPatId(param.getPatId());
      //state.setNextPatid(param.getPatId());
      state.setPatId(null);
      state.setNextPatid(null);
      state.setNextKurCd(null);
      state.setStartPlanDate(null);
      state.setEndPlanDate(null);
      state.setWeighBeforeDate(null);
      state.setCondSendDate(null);
      state.setCondSetDate(null);
      state.setEndDate(null);
      state.setWeighAfterDate(null);
      state.setTmpDeviceSetInfo(null);
      //add 患者発生時の次患者情報送信#1437 --趙-- end
      ret = mntMachineStateService.updateUnregisteredPat(state);

      // TODO:暫定処置として？？？？患者のチェックリストの実績展開を行わないようにする
//      // チェックリスト実績展開
//      if (0 < ret) {
//        // 条件送信時のチェックリスト実績作成・更新
//        try {
//          ChecklistUpdateResponse resChk = comsvOrdCheckListService
//              .createOrdChecklistSendCondition(machine.getFacilityCd(), ord.getOrdNo());
//          if (resChk.isSuccess) {
//            log.info("チェックリスト実績作成");
//          } else {
//            log.info("チェックリスト実績作成失敗[" + resChk.errorMessage + "]");
//          }
//        } catch (Exception e) {
//          log.error("チェックリスト実績作成エラー[" + e.getMessage() + "]");
//        }
//      }

      //
      if (ret > 0 && param.getPatId() != null) {
        // 治療時間
        String treatmentTime = null;
        String condInfoText = ord.getRstCondInfo();
        if (null != condInfoText) {
          CondInfo condInfo = condInfoService.createCondInfo(condInfoText);
          CondInfoItem condItem = condInfo.getTreatTime();
          treatmentTime = condItem.getValue();
        }
        // 割り当て対象の患者基本情報(pat_main)更新
        patMainAcceptanceStatusInfoService.update(param.getPatId(), ord.getOrdNo(), ord.getDialState(), param.getStartDate(), treatmentTime);
      }
      // add FNSI-バグ 通信サーバ 高 start
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
      // 条件送信時のチェックリスト実績作成・更新
      //      try {
      //        ChecklistUpdateResponse resChk = comsvOrdCheckListService.createOrdChecklistUnregistered(param.getFacilityCd(), ord.getOrdNo());
      //        if (resChk.isSuccess) {
      //          EventLogMessage eventLogMessage = new EventLogMessage();
      //          eventLogMessage.setLogMessage("チェックリスト実績作成");
      //          eventLogMessage.setSqlIdentification("(facility_cd = " + param.getFacilityCd() + ",or_no = " + ord.getOrdNo());
      //          eventLogMessage.setFacilityCd(param.getFacilityCd());
      //          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"comsvOrdCheckListService/createOrdChecklistUnregistered");
      //        } else {
      //          EventLogMessage eventLogMessage = new EventLogMessage();
      //          eventLogMessage.setLogMessage("チェックリスト実績作成失敗[" + resChk.errorMessage +"]");
      //          eventLogMessage.setSqlIdentification("(facility_cd = " + param.getFacilityCd() + ",or_no = " + ord.getOrdNo());
      //          eventLogMessage.setFacilityCd(param.getFacilityCd());
      //          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,"comsvOrdCheckListService/createOrdChecklistUnregistered");
      //        }
      //      } catch (Exception e) {
      //        EventLogMessage eventLogMessage = new EventLogMessage();
      //        eventLogMessage.setLogMessage("チェックリスト実績作成エラー[" + e.getMessage() + "]");
      //        eventLogMessage.setFacilityCd(param.getFacilityCd());
      //        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      //      }
      // add FNSI-バグ 通信サーバ 高 end
      List<Long> ordnoList = new ArrayList<>();
      ordnoList.add(ord.getOrdNo());
      this.ordCheckListService.syncOrdChecklistForResult(ordnoList);
      //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

      if (ret > 0 && Objects.isNull(param.getPatId())) {
        // ？？？？患者が登録された
        try {
          // 通知用の情報収集
          // 変換用JSONデータを作成
          JSONObject replaceData = new JSONObject();

          // 必要なJSONパラメータを追加
          replaceData.put("FACILITYCD", param.getFacilityCd());
          replaceData.put("BEDNAME", param.getRstBedName());

          webApiCallCommonUtil.registerNotification(NotificationDefinition.UNREGISTERED_PAT, param.getFacilityCd(), replaceData);
        } catch (Exception e) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setFacilityCd(param.getFacilityCd());
          eventLogMessage.setLogMessage("通知失敗:" + e.getMessage());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
      }
    }

    return ret;
  }

  /**
   * 治療開始時刻が収まるクールを検索して返す
   * @param facilityCd
   * @param startTime
   * @return
   */
  private MstKur findMstKurByNowTime(String facilityCd, Timestamp startTime) {
    DateTimeFormatter nowTimeFmt = DateTimeFormatter.ofPattern("HHmmss");
    LocalDateTime ldt = startTime.toLocalDateTime();
    String currentTime = nowTimeFmt.format(ldt);
    try {
      List<MstKur> kurs = mstKurDao.selectByTargetTime(facilityCd, currentTime);
      if (kurs.size() == 1) {
        return kurs.get(0);
      }
    } catch (Exception ex) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    return null;
  }

  /**
   * 装置番号からベッド情報の取得
   * @param facilityCd
   * @param machineNo
   * @return
   */
  MstBed findMstBedByMachine(String facilityCd, Long machineNo) {
    List<MstBed> beds = mstBedDao.selectByMachine(facilityCd, machineNo);
    if (beds.size() > 0) {
      return beds.get(0);
    }
    return null;
  }
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  /**
   * 通信サーバ用治療情報の愁訴処置情報更新
   * @param facilityCd 施設コード
   * @param ordNo オーダ番号
   * @param ctl_no_complaint 愁訴管理番号
   * @param ctl_no_treat 処置管理番号
   * @param occurDate 発生日時
   * @param noJson Cd配列（json）
   * @return
   */
     @Override
    @Transactional
    //public int updateRstCompTreat(String facilityCd, Long ordNo, String occurDate, String cdJson) {
    public int updateRstCompTreat(String facilityCd, Long ordNo,  int ctl_no_complaint ,int ctl_no_treat, String occurDate, String cdJson) {
       //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
      int rtn = 0;
      int lop;
      int comp_cnt = 0;
      int treat_cnt = 0;

    if (occurDate.equals("null") == false) {
      occurDate = '"' + occurDate + '"';
    }

    // JSON処理
    List<Integer> compList = new ArrayList<Integer>();
    List<Integer> treatList = new ArrayList<Integer>();
    ObjectMapper mapper = new ObjectMapper();
    try {
      JsonNode jsonNode_array = mapper.readTree(cdJson);
      for (lop = 0; lop < jsonNode_array.size(); lop++) {
        JsonNode jsonNode = jsonNode_array.get(lop);
        // jsonNodeは読み取り専用のため、ObjectNodeに変換
        ObjectNode objectNode = jsonNode.deepCopy().asObject();
        if (objectNode != null) {
          if (jsonNode.get("comp_cd") != null) {
            compList.add(objectNode.get("comp_cd").asInt());
          } else if (jsonNode.get("treat_cd") != null) {
            treatList.add(objectNode.get("treat_cd").asInt());
          }
        } else {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("入力値変換失敗");
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        }
      }
      // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
      Integer difference = this.balanceLists(compList, treatList);
      if (difference != 0) {
        if (compList.size() > treatList.size()) {
          for (int i = 0; i < difference; i++) {
            treatList.add(-1);
          }
        } else if (compList.size() < treatList.size()){
          for (int i = 0; i < difference; i++) {
            compList.add(-1);
          }
        }
      }
      // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end

      if (compList.size() > 0) {
        // 愁訴入力あり
        List<MstComplaint> mstCompList = mstComplaintDao.selectAllByFacilityCd(facilityCd);
        if (mstCompList != null) {
          for (lop = 0; lop < compList.size(); lop++) {
            for (MstComplaint mstComp : mstCompList) {
              if (Objects.equals(compList.get(lop), mstComp.getComplaintCd())) {
                // ord_mainを更新
                String comp_name = mstComp.getComplaintName();
                if (comp_name != null) {
                  comp_name = '"' + comp_name + '"';
                  mstComp.setComplaintName(comp_name);
                }
                //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
                //rtn = comsvOrdMainDao.updateComplaintAdd(ordNo, occurDate, mstComp);
                rtn = comsvOrdMainDao.updateComplaintAdd(ordNo, ctl_no_complaint, comp_cnt+1, occurDate, mstComp);
                //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
                comp_cnt++;
                break;
                // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
              } else if (Objects.equals(compList.get(lop), -1)){
                MstComplaint virtualMstComp = new MstComplaint();
                rtn = comsvOrdMainDao.updateComplaintAdd(ordNo, ctl_no_complaint, comp_cnt+1, occurDate, virtualMstComp);
                comp_cnt++;
                break;
              }
              // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end
            }
          }
        } else {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("愁訴マスタ取得失敗");
          eventLogMessage.setSqlIdentification("facilityCd = " + facilityCd);
          eventLogMessage.setFacilityCd(facilityCd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mstComplaintDao/selectAllByFacilityCd");
        }
      }

      if (treatList.size() > 0) {
        // 処置入力あり
        List<MstCompTreatment> mstTreatList = mstCompTreatmentDao.selectAllByFacilityCd(facilityCd);
        if (mstTreatList != null) {
          for (lop = 0; lop < treatList.size(); lop++) {
            for (MstCompTreatment mstTreat : mstTreatList) {
              if (Objects.equals(treatList.get(lop), mstTreat.getCompTreatmentCd())) {
                // ord_mainを更新
                String treat_name = mstTreat.getTreatment();
                if (treat_name != null) {
                  treat_name = '"' + treat_name + '"';
                  mstTreat.setTreatment(treat_name);
                }
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
                //String treat_class = mstTreat.getTreatClass();
                Integer treat_class = mstTreat.getTreatClass();
                // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
                if (treat_class != null) {
                  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
                  //mstTreat.setTreatClass('"' + treat_class + '"');
                  mstTreat.setTreatClass(treat_class);
                  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end
                }
                MstMedicine mstMedi = new MstMedicine();
                MstMedicineMix mstMediMix = new MstMedicineMix();
                Integer medi_cd = mstTreat.getTreatMedicineCd();
                // add #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou start
                String procedureName = null;
                // add #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou end
                if (Objects.equals(medi_cd, null) == false) {
                  // 処置区分判定
                  //mod 9844 ljx start
//                  if (Objects.equals(treat_class, "0")) {
                  if (Objects.equals(treat_class, 0)) {
                  //mod 9844 ljx end
                    // 調整薬剤
                    mstMediMix = mstMedicineMixDao.selectByCd(facilityCd, medi_cd);
                    if (mstMediMix != null) {
                      String medi_name = mstMediMix.getMedicineMixName();
                      if (medi_name != null) {
                        medi_name = '"' + medi_name + '"';
                        mstMediMix.setMedicineMixName(medi_name);
                      }
                      String medi_unit = mstMediMix.getUnit();
                      if (medi_unit != null) {
                        medi_unit = '"' + medi_unit + '"';
                        mstMediMix.setUnit(medi_unit);
                      }
                      // add #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou start
                      MstProcedure mstProcedure = mstProcedureDao.selectByProcedureCd(mstTreat.getProcedureCd());
                      if(mstProcedure != null){
                        mstTreat.setProcedureCd(mstProcedure.getProcedureCd());
                        procedureName = '"' + mstProcedure.getPricedureName() + '"';
                      }
                      // add #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou end
                    } else {
                    EventLogMessage eventLogMessage = new EventLogMessage();
                    eventLogMessage.setLogMessage("調整薬剤マスタ[" + medi_cd + "]取得失敗");
                    eventLogMessage.setSqlIdentification("facilityCd:" + facilityCd + ", medi_cd:" + medi_cd);
                    eventLogMessage.setFacilityCd(facilityCd);
                    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mstMedicineMixDao/selectByCd");
                    }
                  }
                  // 処置区分判定
                  //mod 9844 ljx start
//                  if (Objects.equals(treat_class, "1")) {
                  if (Objects.equals(treat_class, 1)) {
                  //mod 9844 ljx end
                    // 薬剤
                    mstMedi = mstMedicineDao.selectByMediCd(medi_cd);
                    if (mstMedi != null) {
                      String medi_name = mstMedi.getMedicineName();
                      if (medi_name != null) {
                        medi_name = '"' + medi_name + '"';
                        mstMedi.setMedicineName(medi_name);
                      }
                      String medi_unit = mstMedi.getUnit();
                      if (medi_unit != null) {
                        medi_unit = '"' + medi_unit + '"';
                        mstMedi.setUnit(medi_unit);
                      }
                      // add #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou start
                      MstProcedure mstProcedure = mstProcedureDao.selectByProcedureCd(mstTreat.getProcedureCd());
                      if(mstProcedure != null){
                        mstTreat.setProcedureCd(mstProcedure.getProcedureCd());
                        procedureName = '"' + mstProcedure.getPricedureName() + '"';
                      }
                      // add #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou end
                    } else {
                    EventLogMessage eventLogMessage = new EventLogMessage();
                    eventLogMessage.setLogMessage("薬剤マスタ[" + medi_cd + "]取得失敗");
                    eventLogMessage.setFacilityCd(facilityCd);
                    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, "mstMedicineDao/selectByMediCd");
                    }
                  }
                }
                // mod #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou start
                  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
                //rtn = comsvOrdMainDao.updateTreatmentAdd(ordNo, occurDate, mstTreat, mstMedi, mstMediMix);
                // rtn = comsvOrdMainDao.updateTreatmentAdd(ordNo, ctl_no_treat, treat_cnt+1, occurDate, mstTreat, mstMedi, mstMediMix);
                rtn = comsvOrdMainDao.updateTreatmentAdd(ordNo, ctl_no_treat, treat_cnt+1, occurDate, procedureName, mstTreat, mstMedi, mstMediMix);
                //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
                // mod #9844 治療中に入力した愁訴処置（処置薬剤）が消える dou end
                treat_cnt++;

                //add #10196 Ord_Material_Save code implementation zt start
                // mod 12250 ord_material_saveの処理を2回重複実行している zkm start
//                ordMaterialSaveService.batchProcessingData(
//                  Collections.singletonList(
//                    ordMaterialSaveService.updateOrdMaterialSaveByDiff(
//                      new OrdMaterialSaveDto(
//                        ordNo,
//                        false,
//                        false,
//                        false,
//                        true,
//                        OrdMaterialSaveDto.RST_CLASS
//                      )
//                    )
//                  )
//                );
                ordMaterialSaveService.bulkUpdateByOrdNoInTreatment(ordNo);
                // mod 12250 ord_material_saveの処理を2回重複実行している zkm end
                //add #10196 Ord_Material_Save code implementation zt start

                break;
                // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
              } else if (Objects.equals(treatList.get(lop), -1)){
                MstCompTreatment virtualMstTreat = new MstCompTreatment();
                MstMedicine virtualMstMedi = new MstMedicine();
                MstMedicineMix virtualMstMediMix = new MstMedicineMix();
                String procedureName = null;

                rtn = comsvOrdMainDao.updateTreatmentAdd(ordNo, ctl_no_treat, treat_cnt+1, occurDate, procedureName, virtualMstTreat, virtualMstMedi, virtualMstMediMix);
                treat_cnt++;
                break;
                // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end
              }
            }
          }
        } else {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("処理マスタ取得失敗");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        }
      }

      if (compList.size() <= 0 && treatList.size() <= 0) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("入力値なし");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      } else if (comp_cnt == 0 && treat_cnt == 0) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("登録なし（マスタ不一致）");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
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

    return rtn;
  }
  // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
  public static int balanceLists(List<Integer> list1, List<Integer> list2) {
    if (list1.size() == list2.size()) {
      return 0;
    }

    List<Integer> smallerList = list1.size() < list2.size() ? list1 : list2;
    List<Integer> largerList = list1.size() >= list2.size() ? list1 : list2;

    int difference = largerList.size() - smallerList.size();

    return difference;
}
  // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end

  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
  /**
   * 情報更新
   *
   * @param ordNo オーダ番号
   * @return
   */
  @Override
  @Transactional
  public int updateWeightInfo(Long ordNo, String weightInfo) {
    OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
    int updateCount = ordMainDao.updateWeightInfo(ordNo, weightInfo);
    if (updateCount > 0) {
      OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
      triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
        Collections.singletonList(newOrdMain));
    }
    return updateCount;
  }
  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_DEVICE_EDGE + "," + LoggingConstant.SERVICE_NAME.REMS);
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

   // add AWSとDEの通信断からの復旧 --趙-- start
  /**
   * 通信サーバ用治療情報の登録（AWSとDEの通信断からの復旧）
   * @param ComsvOrdMain
   * @return
   */
  @Override
  @Transactional
  public int insertUnregisteredCommFail(ComsvOrdMain param) {

    EventLogMessage eventLogMessage = new EventLogMessage();

    MstBed bed = findMstBedByMachine(param.getFacilityCd(), param.getRstMachineNo());
    MstKur kur = findMstKurByNowTime(param.getFacilityCd(), param.getStartDate());
    param.setRstBedCd(0L);
    if (bed != null) {
      param.setRstBedCd(bed.getBedCd());
      param.setRstBedName(bed.getBedName());
    }
    param.setRstKurCd(0L);
    if (kur != null) {
      param.setRstKurCd((long) kur.getKurCd());
      param.setRstKurName(kur.getKurName());
    }

    // 装置番号から装置マスタ情報を取得
    MstMachine machine = null;
    // del 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
    /*
    machine = mstMachineDao.selectByMachineNo(param.getRstMachineNo());
    if (machine != null) {
      // 装置治療状態取得
      TmpCommFailureRecovery state = tmpCommFailureRecoveryDao.selectByKey(
        machine.getFacilityCd(),
        machine.getMachineTypeCd(),
        machine.getMachineSerial());
      if (state != null) {
        // 現患者判定
        Long ordNo = state.getOrdNo();
        if (ordNo != null) {
          // ordが状態1,2(治療前)ならば条件送信キャンセル
          ComsvOrdMain ordMain = comsvOrdMainDao.selectByNo(ordNo);
          if (ordMain != null && Objects.equals(ordMain.getDialState(), OrdMainConst.DialysisState.AFTER_SEND)
            && Objects.equals(ordMain.getDialState(), OrdMainConst.DialysisState.CHECKED_SEND)) {
            // 現患者に対して条件送信キャンセル実施(DB更新のみ)
            SendConditionCancelResponse res = new SendConditionCancelResponse();
            try {
              res = sendConditionCancelService.DoCancelDBActionCommFail(ordNo, machine);
            } catch (Exception ex){
              res.isSuccess = false;
              res.errorMessage = ex.getMessage();
              res.ex = ex;
            }
            if (!res.isSuccess) {
              // 条件送信キャンセル失敗
              eventLogMessage.setLogMessage("API insertUnregisteredCommFail() DoCancelDBActionCommFail failed. error:" + res.errorMessage);
              eventLogMessage.setMachineTypeCd(machine.getMachineTypeCd());
              eventLogMessage.setPatId(param.getPatId().toString());
              eventLogMessage.setSqlIdentification("ordNo = " + ordNo + ",machine = " + machine);
              eventLogMessage.setFacilityCd(machine.getFacilityCd());
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
            }
          }
        }
      }
    }

     */
    // del 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end

    ObjectMapper mapper = new ObjectMapper();
    // 治療情報の登録（患者未登録運転開始）
    // rst_puncture_user_info
    // rst_return_user_info
    // rst_charge_user_info
    StringJoiner user = new StringJoiner(",");
    user.add("\"user_id_1\": null");
    user.add("\"user_last_name_1\": null");
    user.add("\"user_first_name_1\": null");
    user.add("\"user_id_2\": null");
    user.add("\"user_last_name_2\": null");
    user.add("\"user_first_name_2\": null");
    String user_date = "\"date\": null";
    String user_reg_date = "\"date_1\": null,\"date_2\": null";

    StringJoiner sjRstPunctureUserInfo = new StringJoiner(",", "{", "}");
    sjRstPunctureUserInfo.add(user.toString()).add(user_date).add(user_reg_date);
    param.setRstPunctureUserInfo(sjRstPunctureUserInfo.toString());

    StringJoiner sjReturnUserInfo = new StringJoiner(",", "{", "}");
    sjReturnUserInfo.add(user.toString()).add(user_date).add(user_reg_date);
    param.setRstReturnUserInfo(sjReturnUserInfo.toString());

    StringJoiner sjRstChargeUserInfo = new StringJoiner(",", "{", "}");
    sjRstChargeUserInfo.add(user.toString()).add(user_reg_date);
    param.setRstChargeUserInfo(sjRstChargeUserInfo.toString());

    // rst_weight_info
    OrdMainRstWeightInfo info = new OrdMainRstWeightInfo();
    try {
      param.setRstWeightInfo(mapper.writeValueAsString(info));
    } catch (JacksonException e) {
      // 手打ち
      StringJoiner sjWeight = new StringJoiner(",", "{", "}");
      sjWeight.add("\"weight_measure_before\": null")
        .add("\"weight_before\": null")
        .add("\"weight_before_date\": null")
        .add("\"weight_measure_after\": null")
        .add("\"weight_after\": null")
        .add("\"weight_after_date\": null")
        .add("\"ctr\": null")
        .add("\"ctr_measure_date\": null")
        .add("\"ctr_weight\": null")
        .add("\"water_removal_target\": null")
        .add("\"water_removal_rst\": null")
        .add("\"kt_v_measure\": null")
        .add("\"urr\": null")
        .add("\"weight_decreased\": null")
        .add("\"re_loop_rate_main\": null")
        .add("\"recrcl_rt\": null")
        .add("\"ihdf_pll\": null")
        .add("\"sttc_vns_prssr\": null")
        .add("\"iap_rt\": null");
      ;
      param.setRstWeightInfo(sjWeight.toString());
    }
    // rst_tare_info
    try {
      OrdMainRstTareChild tare = new OrdMainRstTareChild();
      StringBuilder tare_info = new StringBuilder();
      tare_info.append("{\"before\": ");
      tare_info.append(mapper.writeValueAsString(tare));
      tare_info.append(",\"after\": ");
      tare_info.append(mapper.writeValueAsString(tare));
      tare_info.append("}");
      param.setRstTareInfo(tare_info.toString());
    } catch (JacksonException e) {
      // 手打ち
      StringJoiner tare = new StringJoiner(",", "{", "}");
      tare.add("\"name_1\": null, \"weight_1\": null");
      tare.add("\"name_2\": null, \"weight_2\": null");
      tare.add("\"name_3\": null, \"weight_3\": null");
      tare.add("\"name_4\": null, \"weight_4\": null");
      tare.add("\"name_5\": null, \"weight_5\": null");
      tare.add("\"wheel_chair_cd\": null");
      tare.add("\"wheel_chair_name\": null");
      tare.add("\"wheel_chair_weight\": null");
      StringBuilder tare_info = new StringBuilder();
      tare_info.append("{\"before\": ");
      tare_info.append(tare.toString());
      tare_info.append(",\"after\": ");
      tare_info.append(tare.toString());
      tare_info.append("}");
      param.setRstTareInfo(tare_info.toString());
    }
    // rst_off_water_info
    try {
      TareOrOffWaterJson water = new TareOrOffWaterJson();
      param.setRstOffWaterInfo(mapper.writeValueAsString(water));
    } catch (JacksonException e) {
      // 手打ち
      StringJoiner water = new StringJoiner(",", "{", "}");
      water.add("\"name_1\": null, \"weight_1\": null");
      water.add("\"name_2\": null, \"weight_2\": null");
      water.add("\"name_3\": null, \"weight_3\": null");
      water.add("\"name_4\": null, \"weight_4\": null");
      water.add("\"name_5\": null, \"weight_5\": null");
      param.setRstOffWaterInfo(water.toString());
    }

    int ret = comsvOrdMainDao.insertUnregisteredPat(param);
    if (ret > 0) {
      // 登録されたオーダ番号を取得
      ComsvOrdMain ord = null;
//      ord = selectUnregisteredPat(param);
      ord = comsvOrdMainDao.selectCommFailPat(param);

      // 装置状態管理の透析開始日時更新（AWSとDEの通信断からの復旧）
      TmpCommFailureRecovery state = new TmpCommFailureRecovery();
      // 装置番号から装置マスタ情報を取得
      //MstMachine machine = null;
      machine = mstMachineDao.selectByMachineNo(param.getRstMachineNo());
      // del 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
      /*
      if (machine != null) {
        state.setFacilityCd(machine.getFacilityCd());
        state.setMachineTypeCd(machine.getMachineTypeCd());
        state.setMachineSerial(machine.getMachineSerial());
      }
       */
      // del 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end

      state = tmpCommFailureRecoveryDao.selectByKey(machine.getFacilityCd(), machine.getMachineTypeCd(), machine.getMachineSerial());

      if(ord != null) {
        if (state != null) {
          state.setOrdNo(ord.getOrdNo());
          state.setNextOrdNo(ord.getOrdNo());
          state.setPatId(param.getPatId());
          state.setNextPatid(param.getPatId());
          state.setStartDate(null);
          state.setEndDate(null);
          ret = tmpCommFailureRecoveryDao.updateTmpCommFailureRecoveryCommFail(state);
        } else {
          state = new TmpCommFailureRecovery();
          state.setFacilityCd(machine.getFacilityCd());
          state.setMachineTypeCd(machine.getMachineTypeCd());
          state.setMachineSerial(machine.getMachineSerial());
          state.setOrdNo(ord.getOrdNo());
          state.setNextOrdNo(ord.getOrdNo());
          state.setPatId(param.getPatId());
          state.setNextPatid(param.getPatId());
          state.setStartDate(null);
          state.setEndDate(null);
          ret = tmpCommFailureRecoveryDao.insert(state);
        }
        // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
        List<Long> ordNoList = new ArrayList<>();
        ordNoList.add(ord.getOrdNo());
        try {
          this.ordCheckListService.syncOrdChecklistForResult(ordNoList);
        }catch (IOException e) {
          eventLogMessage.setLogMessage("???患者のチェックリスト作成に失敗した");
          eventLogMessage.setMachineTypeCd(machine.getMachineTypeCd());
          eventLogMessage.setFacilityCd(machine.getFacilityCd());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          return -1;
        }
        if (ret > 0 && Objects.isNull(param.getPatId())) {
          // ？？？？患者が登録された
          try {
            // 通知用の情報収集
            // 変換用JSONデータを作成
            JSONObject replaceData = new JSONObject();

            // 必要なJSONパラメータを追加
            replaceData.put("FACILITYCD", param.getFacilityCd());
            replaceData.put("BEDNAME", param.getRstBedName());

            webApiCallCommonUtil.registerNotification(NotificationDefinition.UNREGISTERED_PAT, param.getFacilityCd(), replaceData);
          } catch (Exception e) {
            eventLogMessage.setFacilityCd(param.getFacilityCd());
            eventLogMessage.setLogMessage("通知失敗:" + e.getMessage());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        }
        // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end
      } else {
        ret = -1;
        eventLogMessage.setLogMessage("insertUnregisteredCommFail error (ord != null) IsTrue= :" + false);
        eventLogMessage.setMachineTypeCd(machine.getMachineTypeCd());
        eventLogMessage.setFacilityCd(machine.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }
    return ret;
  }
  // add AWSとDEの通信断からの復旧 --趙-- end

  //add 通信サーバ用条件送信キャンセル 劉 start
  /**
   * 通信サーバ用治療情報の登録（AWSとDEの通信断からの復旧）
   * @param facilityCd     施設コード
   * @param machineTypeCd  型式コード
   * @param machineSerial  製造番号
   * @param ordNo          システムで管理する一意なオーダ番号
   * @return
   */
  @Override
  @Transactional
  public int cancelSendCondCommfail(String facilityCd, String machineTypeCd, String machineSerial, Long ordNo) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("cancelSendCondCommfail: " + facilityCd + " " + machineTypeCd + " " + machineSerial + " " + ordNo);
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    //治療情報取得
    ComsvOrdMain comsvOrdMain = comsvOrdMainDao.selectByNo(ordNo);
    if (null == comsvOrdMain) {
      eventLogMessage.setLogMessage("cancelSendCondCommfail実施終了:" + "comsvOrdMain is NULL");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return -1;
    }

    //実績：治療状況検査
    String rstDialysisState = comsvOrdMain.getRstDialysisState();
    if (OrdMainConst.DialysisState.BEFORE_SEND.equals(rstDialysisState)) {
      eventLogMessage.setLogMessage("cancelSendCondCommfail実施終了:" + "before send condition");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return 0;
    }
    if (!OrdMainConst.DialysisState.AFTER_SEND.equals(rstDialysisState) && !OrdMainConst.DialysisState.CHECKED_SEND.equals(rstDialysisState)) {
      eventLogMessage.setLogMessage("cancelSendCondCommfail実施終了:" + "rstDialysisState error");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return -1;
    }

    //装置マスタ取得
    MstMachine mstMachine = mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);
    if (null == mstMachine) {
      eventLogMessage.setLogMessage("cancelSendCondCommfail実施終了:" + "mstMachine is null");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return -1;
    }

    try {
      SendConditionCancelResponse res = sendConditionCancelService.DoCancelDBAction(ordNo, mstMachine);
      if (!res.isSuccess) {
        eventLogMessage.setLogMessage("cancelSendCondCommfail実施終了:" + "Do cancel DB fail");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return -1;
      }
    } catch (Exception e) {
      eventLogMessage.setLogMessage("cancelSendCondCommfail実施終了:" + "Do cancel DB error");
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return -1;
    }

    return 0;
  }
  //add 通信サーバ用条件送信キャンセル 劉 end

  //add 実績：治療状況取得 劉 start
  /**
   * 実績：治療状況取得
   * @param ordNo システムで管理する一意なオーダ番号
   * @return
   */
  @Override
  @Transactional
  public String selectRstDialysisState(Long ordNo) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("selectRstDialysisState: " + ordNo);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    String rstDialysisState = "";
    //治療情報取得
    ComsvOrdMain comsvOrdMain = comsvOrdMainDao.selectByNo(ordNo);
    if (null == comsvOrdMain) {
      eventLogMessage.setLogMessage("selectRstDialysisState実施終了:" + "comsvOrdMain is NULL");
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return rstDialysisState;
    }

    //実績：治療状況取得
    rstDialysisState = comsvOrdMain.getRstDialysisState();
    if (null == rstDialysisState) {
      rstDialysisState = "";
    }

    return rstDialysisState;
  }
  //add 実績：治療状況取得 劉 end

  // ＃10847 2024.07.11 add 再循環率情報作成 TDC米沢 start
  /**
   * 再循環率格納情報を作成する
   * @param base  元の再循環率格納情報
   * @param elem  登録する再循環率測定情報
   * @return      作成された再循環率格納情報
   */
  public RecrclRt makeRecrclRt(RecrclRt base, RecrclRtElement elem)
  {
    // 再循環率格納情報登録
    List<RecrclRtElement> list = new ArrayList<>();

    // 再循環率初期情報作成
    RecrclRtElement newElem = new RecrclRtElement();
    newElem.rate = null;
    newElem.bld_vl = null;
    newElem.comment = "";
    newElem.datetime = null;

    // 5件の初期化情報をリストに格納
    for(int lop = 0; lop <5; lop++) {
      list.add(newElem);
    }

    // 元の再循環率格納情報チェック
    if (base != null && !StringUtils.isEmpty(base)) {
      // 元情報がある場合は再循環率測定情報でリストの情報を差し替え
      if(base.get_1() != null && !StringUtils.isEmpty(base.get_1())) list.set(0, base.get_1());
      if(base.get_2() != null && !StringUtils.isEmpty(base.get_2())) list.set(1, base.get_2());
      if(base.get_3() != null && !StringUtils.isEmpty(base.get_3())) list.set(2, base.get_3());
      if(base.get_4() != null && !StringUtils.isEmpty(base.get_4())) list.set(3, base.get_4());
      if(base.get_5() != null && !StringUtils.isEmpty(base.get_5())) list.set(4, base.get_5());
    }

    // 再循環率測定値ソート用クラス定義
    class RecrclRtElementCompararator implements Comparator<RecrclRtElement> {
      public int compare(RecrclRtElement e1, RecrclRtElement e2) {
        // NULL、空白判定
        if(StringUtils.isEmpty(e1.datetime)) return 1;  // e1が大きい
        if(StringUtils.isEmpty(e2.datetime)) return -1; // e2が大きい
        return e1.datetime.compareTo(e2.datetime);
      }
    }
    RecrclRtElementCompararator comp = new RecrclRtElementCompararator();

    // リストを発生時刻昇順(NULL、空白末尾)でソート
    list.sort(comp);

    // 未測定要素をチェック
    int idx = -1;
    for (int lop = 0; lop < list.size(); lop++) {

      // 再循環率測定値が入っているかどうかをチェック
      RecrclRtElement wkElem = list.get(lop);
      if(StringUtils.isEmpty(wkElem.rate))
      {
        // 値がない

        // 未測定要素検出
        idx = lop;
        break;
      }
    }
    // 処理判定
    if( idx != -1) {
      // 未測定要素がある場合

      // 未測定要素を登録情報で差し替え
      list.set(idx, elem);
    } else {
      // 未測定要素がない場合

      // 一番古い要素を削除
      list.remove(0);
      // 登録情報を追加
      list.add(elem);
    }

    // リストを発生時刻昇順(NULL、空白末尾)でソート
    list.sort(comp);

    // 格納情報作成
    RecrclRt rec = new RecrclRt();
    rec.set_1(list.get(0));
    rec.set_2(list.get(1));
    rec.set_3(list.get(2));
    rec.set_4(list.get(3));
    rec.set_5(list.get(4));
    // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
    // rec.setValid_no(String.valueOf(1 + list.indexOf(elem)));
    rec.setValid_no(1 + list.indexOf(elem));
    // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end

    return rec;
  }
  // ＃10847 2024.07.11 add 再循環率情報作成 TDC米沢 end

  // #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 start
  /** {@inheritDoc} */
  @Override
  public boolean existsOrdNo(Long ordNo) {
    return ordMainDao.selectByOrdNo(ordNo) != null;
  }
  // #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 end

  @Override
  @Transactional
  public int updateOxygenReplace(Long ord_no, int ctlNo, String occur_date, String oxygen_start, String oxygen_amount, String linkStartDate) {

    if (occur_date.equals("null") == false) {
      occur_date = '"' + occur_date + '"';
    }
    if (oxygen_start.equals("null") == false) {
      oxygen_start = '"' + oxygen_start + '"';
    }
    MstComplaint virtualMstComp = new MstComplaint();
    comsvOrdMainDao.updateComplaintDel(ord_no, ctlNo, 1, occur_date, virtualMstComp);
    comsvOrdMainDao.updateTreatStaffDel(ord_no, ctlNo);

    return comsvOrdMainDao.updateOxygenDel(ord_no, ctlNo, 1, occur_date, oxygen_start, oxygen_amount, linkStartDate);
  }
}
