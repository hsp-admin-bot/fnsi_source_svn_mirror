package jp.co.nikkiso.ntss.admin_web.service.prescription;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.web.service.MaterialsSharingPatientInformation.MaterialsSharingPatientInfomationService;
import jp.co.nikkiso.ntss.core.dao.MedicineSelectionDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstTakeMedicineDao;
import jp.co.nikkiso.ntss.core.dao.OrdPersonalPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatInsuranceDao;
import jp.co.nikkiso.ntss.core.dao.PatNameIdentificationDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.MedicineSelection;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstTakeMedicine;
import jp.co.nikkiso.ntss.core.entity.OrdPersonalPrescription;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;
import jp.co.nikkiso.ntss.core.entity.PatNameIdentification;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysGenericMedicineSelection;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuranceName;
import jp.co.nikkiso.ntss.core.service.ordMaterialSaveService.OrdMaterialSaveService;
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.google.common.collect.Lists;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.PatInsuranceClass;
import jp.co.nikkiso.ntss.admin_web.request.prescription.MedicineSelectionRequest;
import jp.co.nikkiso.ntss.admin_web.request.prescription.OrdPrescriptionDTO;
import jp.co.nikkiso.ntss.admin_web.request.prescription.OrdPrescriptionRequest;
import jp.co.nikkiso.ntss.admin_web.request.prescription.PrescriptionListRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.custom.PrescriptionCount;
import jp.co.nikkiso.ntss.core.entity.custom.PrescriptionList;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

@Service
public class PrescriptionServiceImpl implements PrescriptionService {

  private static final String OFF = "0";

  private static final String ON = "1";

  @Autowired
  MedicineSelectionDao medicineSelectionDao;

  @Autowired
  OrdPrescriptionDao ordPrescriptionDao;

  @Autowired
  MstTakeMedicineDao mstTakeMedicineDao;

  @Autowired
  OrdPersonalPrescriptionDao ordPersonalPrescriptionDao;

  @Autowired
  PatInsuranceDao patInsuranceDao;

  @Autowired
  MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  PatPersonalMainDao patPersonalMainDao;
  //add no.396 処方箋アイテムの保存 張岩 start
  @Autowired
  OrdMaterialSaveService ordMaterialSaveService;
  // add no.396  処方箋アイテムの保存 張岩 end

  // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
  @Autowired
  MstFacilityDao mstFacilityDao;
  // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private LogService logService;

  @Autowired
  private PatNameIdentificationDao patNameIdentificationDao;

  @Autowired
  private MaterialsSharingPatientInfomationService materialsSharingPatientInfomationService;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;


  @Override
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 start
  public List<MedicineSelection> searchMedicineSelection(MedicineSelectionRequest request, String facilityCd) {
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 end
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss.SSS");
    EventLogMessage elm = new EventLogMessage();
    elm.setLogMessage("searchMedicineSelection begin:" + sdf.format(new Date()));
    logService.log(LogLevel.INFO, elm, null, null, null);
    List<MedicineSelection> matchMedicationPrescription = new ArrayList<>();
    List<MedicineSelection> resultList = new ArrayList<>();
    List<MedicineSelection> medicineSelectionList =  new ArrayList<>();
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 start
    medicineSelectionList = medicineSelectionDao.selectByFacilityCdJoinMstSelector(facilityCd, request.getPatId());
    // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 end
    List<SysGenericMedicineSelection> sysGenericMedicineSelectionList =  new ArrayList<>();
    sysGenericMedicineSelectionList = medicineSelectionDao.searchSysGenericMedicine(request.getPatId());
    for(MedicineSelection ms : medicineSelectionList){
      if(ms.getStandardMedicineCd() != null && ms.getStandardMedicineCd().length() >= 9){
        String mCodePrefix = ms.getStandardMedicineCd().substring(0, 9);
        for (SysGenericMedicineSelection sgms : sysGenericMedicineSelectionList) {
          if (sgms.getSearchCodeList() != null && sgms.getSearchCodeList().contains(mCodePrefix)) {
            ms.setMedicineType(Integer.valueOf(sgms.getMedicineType()));
            ms.setGenericCd(sgms.getGenericCd());
            ms.setGenericName(sgms.getGenericName());
            ms.setSearchCodeList(sgms.getSearchCodeList());
            ms.setGenUnitFirst(sgms.getUnitFirst());
            ms.setGenUnitSecond(sgms.getUnitSecond());
            ms.setGenericTabooType(sgms.getGenericTabooType());
          }
        }
      }
      matchMedicationPrescription.add(ms);
    }
    List<SysGenericMedicineSelection> unMatchMedicationPrescriptionList = sysGenericMedicineSelectionList.stream()
            .filter(g -> matchMedicationPrescription.stream().noneMatch(t -> Objects.equals(t.getGenericCd(), g.getGenericCd())))
            .collect(Collectors.toList());
    List<MedicineSelection> unMatchGenericMedication = unMatchMedicationPrescriptionList.stream()
            .map(sgms -> {
              MedicineSelection medicineSelection = new MedicineSelection();
              medicineSelection.setMedicineType(Integer.valueOf(sgms.getMedicineType()));
              medicineSelection.setGenericCd(sgms.getGenericCd());
              medicineSelection.setGenericName(sgms.getGenericName());
              medicineSelection.setSearchCodeList(sgms.getSearchCodeList());
              medicineSelection.setGenUnitFirst(sgms.getUnitFirst());
              medicineSelection.setGenUnitSecond(sgms.getUnitSecond());
              medicineSelection.setGenericTabooType(sgms.getGenericTabooType());
              return medicineSelection;
            })
            .collect(Collectors.toList());
    matchMedicationPrescription.addAll(unMatchGenericMedication);
    elm.setLogMessage("searchMedicineSelection end:" + sdf.format(new Date()));
    logService.log(LogLevel.INFO, elm, null, null, null);
    resultList = matchMedicationPrescription.stream()
            .filter(mmp -> (StringUtils.isEmpty(request.getClassCd()) || Objects.equals(request.getClassCd(), mmp.getClassCd()))
                    && (StringUtils.isEmpty(request.getMedicineName()) || (mmp.getMedicineName() != null && mmp.getMedicineName().contains(request.getMedicineName())))
                    && (StringUtils.isEmpty(request.getGenericName()) || (mmp.getGenericName() != null && mmp.getGenericName().contains(request.getGenericName()))))
            .collect(Collectors.toList());
    return resultList;
  }

  @Override
  public List<OrdPrescription> searchOrdPrescription(OrdPrescriptionRequest request) {
    String issueDateFrom = request.getIssueDateFrom();
    String issueDateTo = request.getIssueDateTo();
    List<Long> ordPrescriptionNoArrayList = new ArrayList<Long>();
    Long ordPrescriptionNo = request.getOrdPrescriptionNo();
    if (ordPrescriptionNo != null) {
      ordPrescriptionNoArrayList.add(ordPrescriptionNo);
    }
    Long[] ordPrescriptionNoList = new Long[ordPrescriptionNoArrayList.size()];
    ordPrescriptionNoArrayList.toArray(ordPrescriptionNoList);

    List<OrdPrescription> ordPrescriptions = ordPrescriptionDao.searchPrescriptionHistory(
      request.getPatId(), request.getFacilityCd(), issueDateFrom,
      issueDateTo, request.getPrescriptionType(), request.getIssueState(), null,
      ordPrescriptionNoList);

    if ("0".equals(request.getPatientShareMode())) {
      List<PatNameIdentification> srcPatIds = patNameIdentificationDao.getListPatIdSrcFromPatTo(request.getPatId());
      for (PatNameIdentification srcPatId : srcPatIds) {
        List<OrdPrescription> list = ordPrescriptionDao.searchPrescriptionHistory(
          srcPatId.getPatIdSrc(), srcPatId.getFacilityCdSrc(), issueDateFrom,
          issueDateTo, request.getPrescriptionType(), request.getIssueState(), null,
          ordPrescriptionNoList);
        if (list != null && !list.isEmpty()) {
          ordPrescriptions.addAll(list);
        }
      }
    }
    return ordPrescriptions;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstTakeMedicine> getTakeMedicine(String listClass, String facilityCd) {
    return mstTakeMedicineDao.selectByListClass(listClass, facilityCd);
  }

  @Transactional
  @Override
  public OrdPrescriptionDTO save(OrdPrescriptionDTO input) {
//    mod IES_6935【EOL対応内部】【处方】 関 start
    // Timestamp currentDate = Timestamp.valueOf(LocalDateTime.now());
    Timestamp currentDate = Timestamp.valueOf(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS")));
//    mod IES_6935【EOL対応内部】【处方】 関 end
    OrdPrescription ordPrescription = input.getOrdPrescription();

    // 更新処理
    if (ordPrescription.getOrdPrescriptionNo() != null && !ordPrescription.getOrdPrescriptionNo().equals(Long.valueOf(0))) {
      ordPrescription.setUpDate(currentDate);

      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(ordPrescription,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      int count = ordPrescriptionDao.update(ordPrescription);

      //add no.396 処方箋アイテムの保存 張岩 start
      // ordMaterialSaveService.saveOrdMaterialSave(ordPrescription);
      //add no.396 処方箋アイテムの保存 張岩 end
      // 処方情報計算材料保持
      ordMaterialSaveService.savePrescriptionOrdMaterialSave(List.of(ordPrescription));

      if (count <= 0) {
        throw new NtssException("Failed to update: " + ordPrescription);
      }
      OrdPersonalPrescription ordPersonalPrescription = buildOrdPersonalPrescription(
        ordPrescription.getOrdPrescriptionNo(), input.getOrdPersonalPrescription());
      ordPersonalPrescription.setUpDate(currentDate);


      OrdPersonalPrescription ordPersonalPrescriptionOrigin = ordPersonalPrescriptionDao.selectByOrdPrescriptionNo(ordPrescription.getOrdPrescriptionNo());
      if(ordPersonalPrescription.getInsuranceCd() == ordPersonalPrescriptionOrigin.getInsuranceCd() &&
        ordPersonalPrescription.getInsuranceName() == ordPersonalPrescriptionOrigin.getInsuranceName()){
        ordPersonalPrescription.setInsuNameShort(ordPersonalPrescriptionOrigin.getInsuNameShort());
        ordPersonalPrescription.setInsuInfo(ordPersonalPrescriptionOrigin.getInsuInfo());
        ordPersonalPrescription.setInsuPubInfo(ordPersonalPrescriptionOrigin.getInsuPubInfo());
        ordPersonalPrescription.setInsuSetInfo(ordPersonalPrescriptionOrigin.getInsuSetInfo());
        ordPersonalPrescription.setInsuSelfInfo(ordPersonalPrescriptionOrigin.getInsuSelfInfo());
        ordPersonalPrescription.setMemo1(ordPersonalPrescriptionOrigin.getMemo1());
        ordPersonalPrescription.setMemo2(ordPersonalPrescriptionOrigin.getMemo2());
      }else{
        if(!StringUtils.isEmpty(ordPersonalPrescription.getInsuranceCd())){
          PatInsurance patInsurance = patInsuranceDao.selectByIdNoDecrypt(ordPersonalPrescription.getInsuranceCd());
          ordPersonalPrescription.setInsuNameShort(patInsurance == null ? null : patInsurance.getInsu_name_short());
          ordPersonalPrescription.setInsuInfo(patInsurance == null ? null : patInsurance.getInsu_info());
          ordPersonalPrescription.setInsuPubInfo(patInsurance == null ? null : patInsurance.getInsu_pub_info());
          ordPersonalPrescription.setInsuSetInfo(patInsurance == null ? null : getInsuSetInfo(patInsurance));
          ordPersonalPrescription.setInsuSelfInfo(patInsurance == null ? null : patInsurance.getInsu_self_info());
          ordPersonalPrescription.setMemo1(patInsurance == null ? null : patInsurance.getMemo1());
          ordPersonalPrescription.setMemo2(patInsurance == null ? null : patInsurance.getMemo2());

          if(patInsurance != null){
            // 保険情報
            if (patInsurance.getInsu_class().equals(0)) {
              ordPersonalPrescription.setInsuPubInfo(null);
              ordPersonalPrescription.setInsuSetInfo(null);
              ordPersonalPrescription.setInsuSelfInfo(null);
              // 公費情報
            }else if(patInsurance.getInsu_class().equals(1)) {
              ordPersonalPrescription.setInsuInfo(null);
              ordPersonalPrescription.setInsuSetInfo(null);
              ordPersonalPrescription.setInsuSelfInfo(null);
              // セット情報
            }else if(patInsurance.getInsu_class().equals(2)) {
              ordPersonalPrescription.setInsuInfo(null);
              ordPersonalPrescription.setInsuSelfInfo(null);
              ordPersonalPrescription.setInsuPubInfo(null);
              // 自費情報
            }else if (patInsurance.getInsu_class().equals(3)) {
              ordPersonalPrescription.setInsuInfo(null);
              ordPersonalPrescription.setInsuSetInfo(null);
              ordPersonalPrescription.setInsuPubInfo(null);
            }
          }else{
            ordPersonalPrescription.setInsuranceCd(null);
          }
        }else{
          ordPersonalPrescription.setInsuNameShort(null);
          ordPersonalPrescription.setInsuInfo(null);
          ordPersonalPrescription.setInsuPubInfo(null);
          ordPersonalPrescription.setInsuSetInfo(null);
          ordPersonalPrescription.setInsuSelfInfo(null);
          ordPersonalPrescription.setMemo1(null);
          ordPersonalPrescription.setMemo2(null);
        }
      }

      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(ordPersonalPrescription,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
      count = ordPersonalPrescriptionDao.update(ordPersonalPrescription);

      if (count <= 0) {
        throw new NtssException("Failed to update : " + ordPersonalPrescription);
      }
      input.setOrdPrescription(ordPrescription);

      ordPersonalPrescription = ordPersonalPrescriptionDao
        .selectByOrdPrescriptionNo(ordPrescription.getOrdPrescriptionNo());
      input.setOrdPersonalPrescription(ordPersonalPrescription);
    } else {
      // 新規登録
      ordPrescription.setUpDate(currentDate);
      ordPrescription.setRegDate(currentDate);
      int count = ordPrescriptionDao.insert(ordPrescription);
      if (count <= 0) {
        throw new NtssException("Failed to insert: " + ordPrescription);
      }

      List<OrdPrescription> ordPrescriptions = ordPrescriptionDao.searchPrescriptionHistory(
        ordPrescription.getPatId(), ordPrescription.getFacilityCd(), null, null, null, null, currentDate);
      if (ordPrescriptions == null || ordPrescriptions.isEmpty()) {
        throw new NtssException(
          String.format(
            "Not found ord prescription with patId %d and facilityCd %s with regDate "
              + currentDate.toString(),
            ordPrescription.getPatId(), ordPrescription.getFacilityCd()));
      } else if (ordPrescriptions.size() > 1) {
        throw new NtssException(
          String.format(
            "Duplicated ord prescription with patId %d and facilityCd %s with regDate "
              + currentDate.toString(),
            ordPrescription.getPatId(), ordPrescription.getFacilityCd()));
      }

      ordPrescription = ordPrescriptions.get(0);
      //add no.396 処方箋アイテムの保存 張岩 start
      // ordMaterialSaveService.saveOrdMaterialSave(ordPrescription);
      //add no.396 処方箋アイテムの保存 張岩 end
      // 処方情報計算材料保持
      ordMaterialSaveService.savePrescriptionOrdMaterialSave(List.of(ordPrescription));

      OrdPersonalPrescription ordPersonalPrescription = input.getOrdPersonalPrescription();

      ordPersonalPrescription = buildOrdPersonalPrescription(ordPrescription.getOrdPrescriptionNo(),
        ordPersonalPrescription);
      ordPersonalPrescription.setUpDate(currentDate);
      ordPersonalPrescription.setRegDate(currentDate);

      if(!StringUtils.isEmpty(ordPersonalPrescription.getInsuranceCd())){
        PatInsurance patInsurance = patInsuranceDao.selectByIdNoDecrypt(ordPersonalPrescription.getInsuranceCd());
        ordPersonalPrescription.setInsuNameShort(patInsurance == null ? null : patInsurance.getInsu_name_short());
        ordPersonalPrescription.setInsuInfo(patInsurance == null ? null : patInsurance.getInsu_info());
        ordPersonalPrescription.setInsuPubInfo(patInsurance == null ? null : patInsurance.getInsu_pub_info());
        ordPersonalPrescription.setInsuSetInfo(patInsurance == null ? null : getInsuSetInfo(patInsurance));
        ordPersonalPrescription.setInsuSelfInfo(patInsurance == null ? null : patInsurance.getInsu_self_info());
        ordPersonalPrescription.setMemo1(patInsurance == null ? null : patInsurance.getMemo1());
        ordPersonalPrescription.setMemo2(patInsurance == null ? null : patInsurance.getMemo2());

        if(patInsurance != null){
          // 保険情報
          if (patInsurance.getInsu_class().equals(0)) {
            ordPersonalPrescription.setInsuPubInfo(null);
            ordPersonalPrescription.setInsuSetInfo(null);
            ordPersonalPrescription.setInsuSelfInfo(null);
            // 公費情報
          }else if(patInsurance.getInsu_class().equals(1)) {
            ordPersonalPrescription.setInsuInfo(null);
            ordPersonalPrescription.setInsuSetInfo(null);
            ordPersonalPrescription.setInsuSelfInfo(null);
            // セット情報
          }else if(patInsurance.getInsu_class().equals(2)) {
            ordPersonalPrescription.setInsuInfo(null);
            ordPersonalPrescription.setInsuSelfInfo(null);
            ordPersonalPrescription.setInsuPubInfo(null);
            // 自費情報
          }else if (patInsurance.getInsu_class().equals(3)) {
            ordPersonalPrescription.setInsuInfo(null);
            ordPersonalPrescription.setInsuSetInfo(null);
            ordPersonalPrescription.setInsuPubInfo(null);
          }
        }else{
          ordPersonalPrescription.setInsuranceCd(null);
        }
      }else{
        ordPersonalPrescription.setInsuNameShort(null);
        ordPersonalPrescription.setInsuInfo(null);
        ordPersonalPrescription.setInsuPubInfo(null);
        ordPersonalPrescription.setInsuSetInfo(null);
        ordPersonalPrescription.setInsuSelfInfo(null);
        ordPersonalPrescription.setMemo1(null);
        ordPersonalPrescription.setMemo2(null);
      }

      count = ordPersonalPrescriptionDao.insert(ordPersonalPrescription);
      if (count <= 0) {
        throw new NtssException("Failed to insert: " + ordPersonalPrescription);
      }
      input.setOrdPrescription(ordPrescription);

      ordPersonalPrescription = ordPersonalPrescriptionDao
        .selectByOrdPrescriptionNo(ordPrescription.getOrdPrescriptionNo());
      input.setOrdPersonalPrescription(ordPersonalPrescription);
    }
    return input;
  }

  @Override
  public OrdPrescription selectOrdPrescriptionDetails(Long ordPrescriptionNo) {
    return ordPrescriptionDao.selectByOrdPrescriptionNo(ordPrescriptionNo);
  }

  @Override
  public OrdPersonalPrescription selectOrdPersonalPrescriptionDetails(Long ordPrescriptionNo) {
    return ordPersonalPrescriptionDao.selectByOrdPrescriptionNo(ordPrescriptionNo);
  }

  @Override
  @Transactional
  public List<OrdPrescription> delete(Long ordPrescriptionNo) {

    // DB更新ログ出力ロジック wangzuo Start
    String tableNamePre = "ord_prescription";
    // SQL検索条件
    StringBuffer wheresPre = new StringBuffer("");
    wheresPre.append(" WHERE\n");
    wheresPre.append(" ord_prescription_no = " + ordPrescriptionNo + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommonPre = getLogCommon(tableNamePre, wheresPre, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultPre = logCommonPre.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    // mod #10553 処方連携 piao start
    int updatedRows = 0;
    List<OrdPrescription> ordRps = ordPrescriptionDao.deleteAndRerutning(ordPrescriptionNo, Timestamp.valueOf(LocalDateTime.now()));
    if(ordRps !=null){
      updatedRows = ordRps.size();
    }
    // mod #10553 処方連携 piao end

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResultPre && updatedRows > 0) {
      logCommonPre.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    //add no.396 処方薬の削除 張岩 start
    ordMaterialSaveService.deleteOrdMaterialSave(ordPrescriptionNo);
    //add no.396 処方薬の削除 張岩 end
    if (updatedRows < 0) {
      throw new NtssException(String.format("Failed to delete %d in OrdPrescription table.", ordPrescriptionNo));
    }

    // DB更新ログ出力ロジック wangzuo Start
    String tableNamePer = "ord_personal_prescription";
    // SQL検索条件
    StringBuffer wheresPer = new StringBuffer("");
    wheresPer.append(" WHERE\n");
    wheresPer.append(" ord_prescription_no = " + ordPrescriptionNo + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommonPer = getLogCommon(tableNamePer, wheresPer, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultPer = logCommonPer.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    updatedRows = ordPersonalPrescriptionDao.delete(ordPrescriptionNo, Timestamp.valueOf(LocalDateTime.now()));

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResultPer && updatedRows > 0) {
      logCommonPer.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    if (updatedRows < 0) {
      throw new NtssException(
        String.format("Failed to delete %d in OrdPersonalPrescription table.", ordPrescriptionNo));
    }
    // mod #10553 処方連携 piao start
    return ordRps;
    // mod #10553 処方連携 piao end
  }

  private OrdPersonalPrescription buildOrdPersonalPrescription(Long ordPrescriptionNo,
                                                               OrdPersonalPrescription ordPersonalPrescription) {
    Long insuranceCd = ordPersonalPrescription.getInsuranceCd();
    PatInsurance patInsurance = patInsuranceDao.selectById(insuranceCd);
    // mod 7271 処方がコンバートされない 関 start
    // if (insuranceCd != null && patInsurance != null) {
    //  ordPersonalPrescription.setInsuPubNo(getPubNo(patInsurance, "insu_pub_no"));
    //  ordPersonalPrescription.setInsuPubPatNo(getPubNo(patInsurance, "insu_pub_pat_no"));
    //  ordPersonalPrescription.setInsuNo(getInsuNo(patInsurance, "insu_no"));
    //  ordPersonalPrescription.setInsuPatMark(getInsuNo(patInsurance, "insu_pat_mark"));
    //  ordPersonalPrescription.setInsuPatNo(getInsuNo(patInsurance, "insu_pat_no"));
    //
    //  String isInsured = getIsInsured(patInsurance);
    //  String isDependent = getIsDependent(patInsurance);
    //  ordPersonalPrescription.setIsInsured(getIsInsured(patInsurance));
    //  ordPersonalPrescription.setIsDependent(isDependent);
    //  ordPersonalPrescription.setInsuKbn(getInsuKbn(isInsured, isDependent));
    //  } else {
    //    ordPersonalPrescription.setInsuPubNo(null);
    //    ordPersonalPrescription.setInsuPubPatNo(null);
    //    ordPersonalPrescription.setInsuNo(null);
    //    ordPersonalPrescription.setInsuPatMark(null);
    //    ordPersonalPrescription.setInsuPatNo(null);
    //    ordPersonalPrescription.setIsInsured(null);
    //    ordPersonalPrescription.setIsDependent(null);
    //    ordPersonalPrescription.setInsuKbn(null);
    //  }
    if (insuranceCd != null && patInsurance != null) {
      JSONObject insuSetInfoJson  = new JSONObject(patInsurance.getInsu_set_info());
      if (insuSetInfoJson.has("insu_cd") && !insuSetInfoJson.get("insu_cd").equals(JSONObject.NULL)) {
        ordPersonalPrescription.setInsuPubNo(getPubNo(patInsurance, "insu_pub_no"));
        ordPersonalPrescription.setInsuPubPatNo(getPubNo(patInsurance, "insu_pub_pat_no"));
        ordPersonalPrescription.setInsuNo(getInsuNo(patInsurance, "insu_no"));
        ordPersonalPrescription.setInsuPatMark(getInsuNo(patInsurance, "insu_pat_mark"));
        ordPersonalPrescription.setInsuPatNo(getInsuNo(patInsurance, "insu_pat_no"));

        String isInsured = getIsInsured(patInsurance);
        String isDependent = getIsDependent(patInsurance);
        ordPersonalPrescription.setIsInsured(getIsInsured(patInsurance));
        ordPersonalPrescription.setIsDependent(isDependent);
        ordPersonalPrescription.setInsuKbn(getInsuKbn(isInsured, isDependent));
      } else {
        ordPersonalPrescription.setInsuPubNo(null);
        ordPersonalPrescription.setInsuPubPatNo(null);
        ordPersonalPrescription.setInsuNo(null);
        ordPersonalPrescription.setInsuPatMark(null);
        ordPersonalPrescription.setInsuPatNo(null);
        ordPersonalPrescription.setIsInsured(null);
        ordPersonalPrescription.setIsDependent(null);
        ordPersonalPrescription.setInsuKbn(null);
      }
    } else {
      ordPersonalPrescription.setInsuPubNo(null);
      ordPersonalPrescription.setInsuPubPatNo(null);
      ordPersonalPrescription.setInsuNo(null);
      ordPersonalPrescription.setInsuPatMark(null);
      ordPersonalPrescription.setInsuPatNo(null);
      ordPersonalPrescription.setIsInsured(null);
      ordPersonalPrescription.setIsDependent(null);
      ordPersonalPrescription.setInsuKbn(null);
    }
    // mod 7271 処方がコンバートされない 関  end
    ordPersonalPrescription.setOrdPrescriptionNo(ordPrescriptionNo);
    String insuDrName = getInsuDrName(ordPersonalPrescription.getInsuDrId());
    ordPersonalPrescription.setInsuDrName(insuDrName);
    ordPersonalPrescription.setInsuDrSign(insuDrName);
    ordPersonalPrescription.setRemarks(getRemarks(ordPersonalPrescription.getIsElderly(),
      ordPersonalPrescription.getIsElderly7(), ordPersonalPrescription.getIsChild()));
    if (ON.equalsIgnoreCase(ordPersonalPrescription.getIsAnesthesia())) {
      ordPersonalPrescription.setRemarksAnesthesia(
        getRemarksAnesthesia(ordPersonalPrescription.getInsuDrId(), ordPersonalPrescription.getPatId()));
    }
    return ordPersonalPrescription;
  }

  private String getRemarksAnesthesia(Long insuDrId, Long patId) {
    String remarksAnesthesia = "";
    if (insuDrId != null) {
      MstPersonalUser user = mstPersonalUserDao.selectById(insuDrId);
      if (user == null) {
        return null;
      }
      String anesthesiologistLicenseNo = user.getAnesthesiologistLicenseNo();

      PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
      if (patPersonalMain == null) {
        return null;
      }

      String address = getStringValue(patPersonalMain.getPat_contact_info(), "address");
      remarksAnesthesia = anesthesiologistLicenseNo == null ? ""
        : anesthesiologistLicenseNo + System.lineSeparator() + address == null ? "" : address;
    }
    return remarksAnesthesia;
  }

  private String getRemarks(String isElderly, String isElderly7, String isChild) {
    String remarks = "";
    if (ON.equalsIgnoreCase(isElderly)) {
      remarks += "高一";
    }
    if (ON.equalsIgnoreCase(isElderly7)) {
      remarks += remarks.isEmpty() ? "高７" : ",高７";
    }
    /* modify by chamaojia 2023-06-29 [9008] 判定パラメータ使用エラー修正  isElderly7 -> isChild  --start */
    if (ON.equalsIgnoreCase(isChild)) {
      remarks += remarks.isEmpty() ? "６歳未満" : ",６歳未満";
    }
    /* modify by chamaojia 2023-06-29 [9008] 判定パラメータ使用エラー修正  isElderly7 -> isChild  --end */
    return remarks;
  }

  private String getInsuDrName(Long insuDrId) {
    if (insuDrId != null) {
      MstPersonalUser user = mstPersonalUserDao.selectById(insuDrId);
      if (user == null) {
        return null;
      }
      return user.getUserLastName() + " " + user.getUserFirstName();
    }
    return null;
  }

  private String getInsuKbn(String isInsured, String isDependent) {
    if (isInsured.equalsIgnoreCase(OFF) && isDependent.equalsIgnoreCase(OFF)) {
      return "被保険者　・　被扶養者";
    } else if (isInsured.equalsIgnoreCase(ON) && isDependent.equalsIgnoreCase(OFF)) {
      return "被保険者";
    } else if (isInsured.equalsIgnoreCase(OFF) && isDependent.equalsIgnoreCase(ON)) {
      return "被扶養者";
    } else if (isInsured.equalsIgnoreCase(ON) && isDependent.equalsIgnoreCase(ON)) {
      return "被保険者　・　被扶養者";
    }
    return null;
  }

  private String getPubNo(PatInsurance patInsurance, String key) {
    Integer insClass = patInsurance.getInsu_class();
    if (PatInsuranceClass.PUBLIC_EXPENDITURE_CLASS.equals(insClass)) {
      return getStringValue(patInsurance.getInsu_pub_info(), key);
    } else if (PatInsuranceClass.SET_CLASS.equals(insClass)) {
      String insuSetInfo = patInsurance.getInsu_set_info();
      String insu_pub1_cd = getStringValue(insuSetInfo, "insu_pub1_cd");
      String insu_pub2_cd = getStringValue(insuSetInfo, "insu_pub2_cd");
      String insu_pub3_cd = getStringValue(insuSetInfo, "insu_pub3_cd");
      String insu_pub4_cd = getStringValue(insuSetInfo, "insu_pub4_cd");

      List<String> strings = Lists.newArrayList(insu_pub1_cd, insu_pub2_cd, insu_pub3_cd, insu_pub4_cd);

      Optional<String> firstNonNull = strings.stream().filter(p -> p != null).findFirst();
      if (firstNonNull.isPresent()) {
        Long insuranceCd = Long.valueOf(firstNonNull.get());

        PatInsurance subPatInsurance = patInsuranceDao.selectById(insuranceCd);
        if (subPatInsurance == null) {
          return null;
        }
        return getStringValue(subPatInsurance.getInsu_pub_info(), key);
      }
    }
    return null;
  }

  private String getInsuNo(PatInsurance patInsurance, String key) {
    Integer insClass = patInsurance.getInsu_class();
    if (PatInsuranceClass.INSURANCE_CLASS.equals(insClass)) {
      return getStringValue(patInsurance.getInsu_info(), key);
    } else if (PatInsuranceClass.SET_CLASS.equals(insClass)) {
      JSONObject json = new JSONObject(patInsurance.getInsu_set_info());
      String insu_cd = json.getString("insu_cd");
      if (insu_cd != null) {
        Long insuranceCd = Long.valueOf(insu_cd);
        PatInsurance subPatInsurance = patInsuranceDao.selectById(insuranceCd);
        if (subPatInsurance == null) {
          return null;
        }
        return getStringValue(subPatInsurance.getInsu_info(), key);
      }
    }
    return null;
  }

  private String getIsInsured(PatInsurance patInsurance) {
    Integer insClass = patInsurance.getInsu_class();
    if (PatInsuranceClass.INSURANCE_CLASS.equals(insClass)) {
      String value = getStringValue(patInsurance.getInsu_info(), "insu_kbn");
      if (value == null) {
        return OFF;
      }
      if (OFF.equalsIgnoreCase(value)) {
        return ON;
      } else if (ON.equalsIgnoreCase(value)) {
        return OFF;
      }
    } else if (PatInsuranceClass.PUBLIC_EXPENDITURE_CLASS.equals(insClass)) {
      return ON;
    } else if (PatInsuranceClass.SET_CLASS.equals(insClass)) {
      String insuSetInfo = patInsurance.getInsu_set_info();
      String insu_pub1_cd = getStringValue(insuSetInfo, "insu_pub1_cd");
      String insu_pub2_cd = getStringValue(insuSetInfo, "insu_pub2_cd");
      String insu_pub3_cd = getStringValue(insuSetInfo, "insu_pub3_cd");
      String insu_pub4_cd = getStringValue(insuSetInfo, "insu_pub4_cd");

      List<String> strings = Lists.newArrayList(insu_pub1_cd, insu_pub2_cd, insu_pub3_cd, insu_pub4_cd);

      Optional<String> firstNonNull = strings.stream().filter(p -> p != null).findFirst();
      if (firstNonNull.isPresent()) {
        return ON;
      } else {
        Long insuranceCd = Long.valueOf(getStringValue(insuSetInfo, "insu_cd"));
        PatInsurance subPatInsurance = patInsuranceDao.selectById(insuranceCd);
        if (subPatInsurance == null) {
          return null;
        }
        String insuKbn = getStringValue(subPatInsurance.getInsu_info(), "insu_kbn");

        if (insuKbn.equalsIgnoreCase(OFF)) {
          return ON;
        } else if (insuKbn.equalsIgnoreCase(ON)) {
          return OFF;
        }
      }
    } else if (PatInsuranceClass.OWN_EXPENSE_CLASS.equals(insClass)) {
      return OFF;
    }
    return OFF;
  }

  private String getIsDependent(PatInsurance patInsurance) {
    Integer insClass = patInsurance.getInsu_class();
    String value = getStringValue(patInsurance.getInsu_info(), "insu_kbn");
    if (value == null) {
      return OFF;
    }

    if (PatInsuranceClass.INSURANCE_CLASS.equals(insClass)) {
      if (OFF.equalsIgnoreCase(value)) {
        return OFF;
      } else if (ON.equalsIgnoreCase(value)) {
        return ON;
      }
    } else if (PatInsuranceClass.PUBLIC_EXPENDITURE_CLASS.equals(insClass)) {
      return OFF;
    } else if (PatInsuranceClass.SET_CLASS.equals(insClass)) {
      if (OFF.equalsIgnoreCase(value)) {
        return OFF;
      } else if (ON.equalsIgnoreCase(value)) {
        return ON;
      }
    } else if (PatInsuranceClass.OWN_EXPENSE_CLASS.equals(insClass)) {
      return OFF;
    }
    return OFF;
  }

  private String getStringValue(String json, String key) {
    JSONObject jsonObject = new JSONObject(json);
    if (!jsonObject.optString(key).isEmpty()) {
      return jsonObject.getString(key);
    }
    return null;
  }

  // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
  @Override
  public String getFacilityNameByCd(String facilityCd) {
    return mstFacilityDao.getFacilityNameByCd(facilityCd);
  }

  @Override
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 start
  public List<PrescriptionList> getPrescriptionList(List<Long> patIdList, String issueDate,
      List<String> prescriptionTypeList, Integer patientShareMode, String facilityCd) {
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260507 end
    List<PrescriptionList> resultList = ordPrescriptionDao.getPrescriptionList(patIdList, issueDate, prescriptionTypeList, facilityCd);
    if (patientShareMode != null && patientShareMode == 0) {
      for (Long patId : patIdList) {
        List<PatNameIdentification> srcPatIds = materialsSharingPatientInfomationService.getListPatIdSrcFromPatTo(patId);
        if (srcPatIds != null && !srcPatIds.isEmpty()) {
          List<Long> srcPatIdList = new ArrayList<>();
          for (PatNameIdentification patIdSrc : srcPatIds) {
            srcPatIdList.add(patIdSrc.getPatIdSrc());
          }
          List<PrescriptionList> srcResultList =
            ordPrescriptionDao.getPrescriptionList(srcPatIdList, issueDate, prescriptionTypeList, null);
          if (srcResultList != null && !srcResultList.isEmpty()) {
            srcResultList.forEach(item -> item.setPatId(patId));
            resultList.addAll(srcResultList);
          }
        }
      }
      if (!resultList.isEmpty()) {
        resultList = this.filterPrescription(resultList, facilityCd);
      }
    }
    return resultList;
  }

  public List<PrescriptionList> filterPrescription(List<PrescriptionList> resultList, String facilityCd) {
    LocalDate today = LocalDate.now();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd");

    Map<Long, List<PrescriptionList>> groupMap =
      resultList.stream().collect(Collectors.groupingBy(PrescriptionList::getPatId));

    List<PrescriptionList> finalResult = new ArrayList<>();

    for (List<PrescriptionList> group : groupMap.values()) {
      PrescriptionList source = group.stream()
        .filter(item -> facilityCd.equals(item.getFacilityCd()))
        .filter(this::hasAnyValue)
        .findFirst()
        .orElse(group.stream().filter(this::hasAnyValue).findFirst().orElse(null));

      if (source != null) {
        String indKurName = source.getIndKurName();
        String indBedName = source.getIndBedName();
        String indTreatmentName = source.getIndTreatmentName();
        String issueState2 = source.getIssueState2();

        for (PrescriptionList item : group) {
          item.setIndKurName(indKurName);
          item.setIndBedName(indBedName);
          item.setIndTreatmentName(indTreatmentName);
          item.setIssueState2(issueState2);
        }
      }

      List<PrescriptionList> futureList = new ArrayList<>();
      List<PrescriptionList> pastList = new ArrayList<>();
      List<PrescriptionList> nullList = new ArrayList<>();

      for (PrescriptionList item : group) {
        if (item.getIssueDate() == null) {
          nullList.add(item);
          continue;
        }
        LocalDate itemIssueDate = parseDate(item.getIssueDate(), formatter);
        if (itemIssueDate.isAfter(today)) {
          futureList.add(item);
        } else if (itemIssueDate.isBefore(today)) {
          pastList.add(item);
        }
      }

      Comparator<PrescriptionList> futureComparator =
        Comparator.comparing((PrescriptionList item) -> parseDate(item.getIssueDate(), formatter))
          .thenComparing(item -> !isSameFacility(item, facilityCd));

      Comparator<PrescriptionList> pastComparator =
        Comparator.comparing((PrescriptionList item) -> parseDate(item.getIssueDate(), formatter),
            Comparator.reverseOrder())
          .thenComparing(item -> !isSameFacility(item, facilityCd));

      futureList.sort(futureComparator);
      pastList.sort(pastComparator);

      PrescriptionList nearestFuture = futureList.isEmpty() ? null : futureList.get(0);
      futureList.clear();
      if (nearestFuture != null) {
        futureList.add(nearestFuture);
      }

      List<PrescriptionList> tempList = new ArrayList<>();
      boolean hasValidData = !futureList.isEmpty() || !pastList.isEmpty();

      if (hasValidData) {
        if (!futureList.isEmpty()) {
          tempList.add(futureList.get(0));
        }
        tempList.addAll(pastList.stream().limit(3).collect(Collectors.toList()));
      } else {
        tempList.addAll(nullList);
      }

      boolean hasFuture = !futureList.isEmpty();
      int totalLimit = hasFuture ? 4 : 3;
      int remainSize = totalLimit;

      for (PrescriptionList item : tempList) {
        if (remainSize <= 0) {
          break;
        }
        if (item != null) {
          finalResult.add(item);
          remainSize--;
        }
      }
    }

    return finalResult;
  }

  private boolean hasAnyValue(PrescriptionList item) {
    return item.getIndKurName() != null
      || item.getIndBedName() != null
      || item.getIndTreatmentName() != null
      || item.getIssueState2() != null;
  }

  private LocalDate parseDate(String date, DateTimeFormatter formatter) {
    return LocalDate.parse(date, formatter);
  }

  private boolean isSameFacility(PrescriptionList item, String facilityCd) {
    return facilityCd.equals(item.getFacilityCd());
  }
  // add FNSI-改修内容イベント一覧の日付直下に、施設名を表示する dou end

  // 対象処方件数取得
  public int getPatPrescriptionCount(List<Long> patIdList, String issueDate, String facilityCd) {
    return ordPrescriptionDao.getPatPrescriptionCount(patIdList, issueDate, facilityCd);
  }

  // 処方オーダー番号リスト取得
  @Override
  public List<PrescriptionList> getOrdPrescriptionNoList(List<Long> patIdList, String issueDate, String facilityCd) {
    return ordPrescriptionDao.getOrdPrescriptionNoList(patIdList, issueDate, facilityCd);
  }

  // 交付状態更新
  @Transactional
  // mod #10553 処方連携 piao start
  public List<OrdPrescription> updateIssueState(PrescriptionListRequest bodyData) {
  // mod #10553 処方連携 piao end
    List<Long> ordPrescriptionNoList = bodyData.getOrdPrescriptionNoList();
    String insuDrId = bodyData.getInsuDrId();
    String selectedPreDoctor = bodyData.getSelectedPreDoctor();
    String facilityCd = bodyData.getFacilityCd();

    // mod #10553 処方連携 piao start
    int count = 0;
    List<OrdPrescription> ordRps = ordPrescriptionDao.updateIssueStateAndRerutning(ordPrescriptionNoList, Timestamp.valueOf(LocalDateTime.now()), facilityCd);
    if(ordRps !=null){
      count = ordRps.size();
    }
    // mod #10553 処方連携 piao end

    if (count <= 0) {
      throw new NtssException(String.format("Failed to update %d in OrdPrescription table.", ordPrescriptionNoList));
    }
    // #10425 処方計算材料保持情報更新 Start
    else {
      this.ordMaterialSaveService.updatePrescriptionIssueState(ordPrescriptionNoList, facilityCd);
    }
    // #10425 処方計算材料保持情報更新 End

    // 保険医をセット
    // 処方の保険医に関しては空欄での保存を認めている
    Long insuDrIdLong = null;
    String insuDrName = null;
    if (StringUtils.hasLength(insuDrId)) {
      insuDrIdLong = Long.valueOf(insuDrId);
      insuDrName = getInsuDrName(insuDrIdLong);
    }
    ordPersonalPrescriptionDao.updatePrescriptionInsuDr(ordPrescriptionNoList, insuDrIdLong, insuDrName, Timestamp.valueOf(LocalDateTime.now()), selectedPreDoctor, facilityCd);
    // add #10553 処方連携 piao start
    return ordRps;
    // add #10553 処方連携 piao end
  }

  /**
   * 一括処方オーダー処理
   *
   * @return List<OrdPrescriptionDTO>
   */
  public List<OrdPrescription> copyPrescription(PrescriptionListRequest bodyData) {

    List<Long> ordPrescriptionNoList = bodyData.getOrdPrescriptionNoList();
    String insuDrId = bodyData.getInsuDrId();
    String issueState = bodyData.getIssueState();
    String issueDate = bodyData.getIssueDate();
    String selectedPreDoctor = bodyData.getSelectedPreDoctor();

//    String regIssueDate = issueDate.replace("/", "");
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyyMMdd");
    LocalDate ldIssueDate = LocalDate.parse(issueDate, dtf);

    // add #10553 処方連携 piao start
    List<OrdPrescription> ordRps = new ArrayList<>();
    // add #10553 処方連携 piao end

    for(Long ordPrescriptionNo : ordPrescriptionNoList) {
      // 処方情報(ord_prescription)の取得
      OrdPrescription targetOrdPrescription = selectOrdPrescriptionDetails(ordPrescriptionNo);
      // 処方情報(ord_personal_prescription)の取得
      OrdPersonalPrescription targetOrdPersonalPrescription = selectOrdPersonalPrescriptionDetails(
          ordPrescriptionNo);

      OrdPrescription ordPrescription = new OrdPrescription();
      BeanUtils.copyProperties(targetOrdPrescription, ordPrescription);
      ordPrescription.setOrdPrescriptionNo(null);
      ordPrescription.setIssueDate(issueDate);
      ordPrescription.setIssueState(issueState);

      if (!StringUtils.isEmpty(targetOrdPrescription.getIssueDate())
          && !StringUtils.isEmpty(targetOrdPrescription.getExpirationDate())) {
        // コピー元処方の交付日と使用期限の差分日数を取得
        LocalDate fromDate = LocalDate.parse(targetOrdPrescription.getIssueDate().replace("/", ""), dtf);
        LocalDate toDate = LocalDate.parse(targetOrdPrescription.getExpirationDate().replace("/", ""), dtf);
        long diffDays = ChronoUnit.DAYS.between(fromDate, toDate);
        // 新規登録する交付日に差分日数を加えたものを新規の使用期限とする
        LocalDate newExpirationDate = ldIssueDate.plusDays(diffDays);
        ordPrescription.setExpirationDate(newExpirationDate.format(dtf));
      }

      OrdPersonalPrescription ordPersonalPrescription = new OrdPersonalPrescription();
      BeanUtils.copyProperties(targetOrdPersonalPrescription, ordPersonalPrescription);
      ordPersonalPrescription.setOrdPrescriptionNo(null);

      // 保険医をセット
      // 複製する処方の保険医を継承するチェックON
      if ("2".equals(selectedPreDoctor)) {
        // 処方の保険医に関しては空欄での保存を認めている
        Long insuDrIdLong = null;
        String insuDrName = null;
        if (StringUtils.hasLength(insuDrId)) {
          insuDrIdLong = Long.valueOf(insuDrId);
          insuDrName = getInsuDrName(insuDrIdLong);
        }
        ordPersonalPrescription.setInsuDrId(insuDrIdLong);
        ordPersonalPrescription.setInsuDrName(insuDrName);
        ordPersonalPrescription.setInsuDrSign(insuDrName);
      }
      // add #11406 処方の「コピーして新規登録」を行うと保険情報がNULLになることがある 房 start
      PatInsuranceName tempPatInsuranceName = null;
      List<PatInsuranceName> patInsuranceNames
        = patInsuranceDao.getListPatInsuranceNameByIdAndCd(ordPersonalPrescription.getPatId()
        ,ordPersonalPrescription.getFacilityCd()
        ,PatInsuranceClass.OWN_EXPENSE_CLASS);
      if(patInsuranceNames != null && !patInsuranceNames.isEmpty()) {
        Optional<PatInsuranceName> optional = patInsuranceNames.stream()
          .filter(el -> el != null && "1".equals(el.getIsSelected())).findFirst();
        if(optional.isPresent()) {
          // 主保険がある場合
          tempPatInsuranceName = optional.get();
        }
        if(tempPatInsuranceName == null) {
          // 上記以外
          tempPatInsuranceName = patInsuranceNames.get(0);
        }
      }
      if(tempPatInsuranceName != null) {
        ordPersonalPrescription.setInsuranceCd(tempPatInsuranceName.getInsuranceCd());
        ordPersonalPrescription.setInsuranceName(tempPatInsuranceName.getInsuName());
      } else {
        ordPersonalPrescription.setInsuranceCd(null);
        ordPersonalPrescription.setInsuranceName(null);
      }
      // add #11406 処方の「コピーして新規登録」を行うと保険情報がNULLになることがある 房 end
      OrdPrescriptionDTO input = new OrdPrescriptionDTO();
      input.setOrdPrescription(ordPrescription);
      input.setOrdPersonalPrescription(ordPersonalPrescription);

      // mod #10553 処方連携 piao start
      OrdPrescriptionDTO ordPrescriptionDTO = save(input);
      if(ordPrescriptionDTO !=null && ordPrescriptionDTO.getOrdPrescription() != null){
        ordRps.add(ordPrescriptionDTO.getOrdPrescription());
      }
      // mod #10553 処方連携 piao end
    }
    // add #10553 処方連携 piao start
    return ordRps;
    // add #10553 処方連携 piao end
  }

  // DB更新ログ出力ロジック wangzuo Start

  /**
   * ログ情報設定
   *
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
    return eventLogMessage;
  }

  /**
   * セット情報取得
   *
   * @return eventLogMessage
   */
  private String getInsuSetInfo(PatInsurance insuInfo){

    if(insuInfo.getInsu_set_info().isEmpty()){
      return null;
    }

    // セット情報
    JSONObject insuSetInfoJson = new JSONObject(insuInfo.getInsu_set_info());
    // 保険区分変更以外のmongoDB挿入
    JSONArray insuSetInfo = new JSONArray();
    // 保険名
    if (insuSetInfoJson.has("insu_cd") && insuSetInfoJson.get("insu_cd") != null && !insuSetInfoJson.get("insu_cd").toString().isEmpty() && !"null".equals(insuSetInfoJson.get("insu_cd").toString())) {
      PatInsurance insuInfo1 = patInsuranceDao.selectByIdNoDecrypt(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_cd"))));
      if (insuInfo1 != null) {
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString(): null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuInfoJson = new JSONObject(insuInfo1.getInsu_info());
          insuInfoJson.put("insu_cd",insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuInfoJson.put("insu_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuInfoJson.put("insu_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);

          insuSetInfo.put(insuInfoJson);
        }
      }
    }
    // 保険情報.公費1
    if (insuSetInfoJson.has("insu_pub1_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub1_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub1_cd").toString())) {
      PatInsurance insuInfo1 = patInsuranceDao.selectByIdNoDecrypt(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub1_cd").toString())));
      if (insuInfo1 != null) {
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name") .toString() : null;
          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;

          insuPubInfoJson.put("insu_pub1_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null")? insuPubPatNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub1_passbook_no",insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          insuPubInfoJson.remove("passbook_no");
          insuPubInfoJson.remove("insu_pub_name");
          insuPubInfoJson.remove("insu_pub_no");
          insuPubInfoJson.remove("insu_pub_pat_no");

          insuSetInfo.put(insuPubInfoJson);
        }
      }
    }
    // 保険情報.公費2
    if (!StringUtils.isEmpty(insuSetInfoJson.get("insu_pub2_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub2_cd").toString())) {
      PatInsurance insuInfo1 = patInsuranceDao.selectByIdNoDecrypt(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub2_cd").toString())));
      if (insuInfo1 != null) {
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;

          insuPubInfoJson.put("insu_pub2_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub2_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          insuPubInfoJson.remove("passbook_no");
          insuPubInfoJson.remove("insu_pub_name");
          insuPubInfoJson.remove("insu_pub_no");
          insuPubInfoJson.remove("insu_pub_pat_no");

          insuSetInfo.put(insuPubInfoJson);
        }
      }
    }
    // 保険情報.公費3
    if (insuSetInfoJson.has("insu_pub3_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub3_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub3_cd").toString())) {
      PatInsurance insuInfo1 = patInsuranceDao.selectByIdNoDecrypt(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub3_cd").toString())));
      if (insuInfo1 != null) {
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null")  ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;

          insuPubInfoJson.put("insu_pub3_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub3_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          insuPubInfoJson.remove("passbook_no");
          insuPubInfoJson.remove("insu_pub_name");
          insuPubInfoJson.remove("insu_pub_no");
          insuPubInfoJson.remove("insu_pub_pat_no");

          insuSetInfo.put(insuPubInfoJson);
        }
      }
    }
    // 保険情報.公費4
    if (insuSetInfoJson.has("insu_pub4_cd") && !StringUtils.isEmpty(insuSetInfoJson.get("insu_pub4_cd").toString()) && !"null".equals(insuSetInfoJson.get("insu_pub4_cd").toString())) {
      PatInsurance insuInfo1 = patInsuranceDao.selectByIdNoDecrypt(Long.parseLong(String.valueOf(insuSetInfoJson.get("insu_pub4_cd").toString())));
      if (insuInfo1 != null) {
        String insuCode = insuInfo1.getInsurance_cd() != null ? insuInfo1.getInsurance_cd().toString() : null;
        String insuInfoName = insuInfo1.getInsu_name() != null ? insuInfo1.getInsu_name() : null;
        String insuClass = insuInfo1.getInsu_class() != null ? insuInfo1.getInsu_class().toString() : null;
        String insuNameShort = insuInfo1.getInsu_name_short() != null ? insuInfo1.getInsu_name_short() : null;

        if(insuInfo.getInsu_class().equals(2)) {
          JSONObject insuPubInfoJson = new JSONObject(insuInfo1.getInsu_pub_info());
          String insuPub1Name = insuPubInfoJson.has("insu_pub_name") && insuPubInfoJson.get("insu_pub_name") != null && !insuPubInfoJson.get("insu_pub_name").equals("null") ? insuPubInfoJson.get("insu_pub_name").toString() : null;
          String insuPubNo = insuPubInfoJson.has("insu_pub_no") && insuPubInfoJson.get("insu_pub_no") != null && !insuPubInfoJson.get("insu_pub_no").equals("null") ? insuPubInfoJson.get("insu_pub_no").toString() : null;
          String insuPubPatNo = insuPubInfoJson.has("insu_pub_pat_no") && insuPubInfoJson.get("insu_pub_pat_no") != null && !insuPubInfoJson.get("insu_pub_pat_no").equals("null") ? insuPubInfoJson.get("insu_pub_pat_no").toString() : null;

          insuPubInfoJson.put("insu_pub4_cd", insuCode != null && !insuCode.equals("null") ? insuCode : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_info_name", insuInfoName != null && !insuInfoName.equals("null") ? insuInfoName : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_info_name_short", insuNameShort != null && !insuNameShort.equals("null") ? insuNameShort : JSONObject.NULL);
          insuPubInfoJson.put("insu_class", insuClass != null && !insuClass.equals("null") ? insuClass : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_name", insuPub1Name != null && !insuPub1Name.equals("null") ? insuPub1Name : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_no", insuPubNo != null && !insuPubNo.equals("null") ? insuPubNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_pat_no",insuPubPatNo != null && !insuPubPatNo.equals("null") ? insuPubPatNo : JSONObject.NULL);
          insuPubInfoJson.put("insu_pub4_passbook_no", insuPubInfoJson.has("passbook_no") && insuPubInfoJson.get("passbook_no") != null && !insuPubInfoJson.get("passbook_no").equals("null")? insuPubInfoJson.get("passbook_no") : JSONObject.NULL);
          insuPubInfoJson.remove("passbook_no");
          insuPubInfoJson.remove("insu_pub_name");
          insuPubInfoJson.remove("insu_pub_no");
          insuPubInfoJson.remove("insu_pub_pat_no");

          insuSetInfo.put(insuPubInfoJson);
        }
      }
    }
    return insuSetInfo.toString();
  }

  /**
   * ログ出力共通クラス設定、取得
   *
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

  // add FNSI-処方を追加 姜 start
@Override
// mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy start
//public List<PrescriptionCount> getPrescriptionCount(String patId, String facilityCd) {
/* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
// public List<PrescriptionCount> getPrescriptionCount(String patId, String facilityCd,String startDate,String endDate) {
public List<PrescriptionCount> getPrescriptionCount(String patId, String facilityCd,String startDate,String endDate, Integer patShareMode) {

//  return ordPrescriptionDao.getPrescriptionCount(patId,facilityCd);
  return ordPrescriptionDao.getPrescriptionCount(patId,facilityCd,startDate,endDate, patShareMode);
// mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy end
}
/* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
// add FNSI-処方を追加 姜 end
}
