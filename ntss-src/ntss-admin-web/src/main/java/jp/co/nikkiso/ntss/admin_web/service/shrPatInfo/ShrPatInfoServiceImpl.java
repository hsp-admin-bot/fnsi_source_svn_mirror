package jp.co.nikkiso.ntss.admin_web.service.shrPatInfo;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.DeleteObjectRequest;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.config.AwsConfiguration;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.ShrPatInfoDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatInsuranceConditionsSharing;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatientFacilityInfo;
import jp.co.nikkiso.ntss.core.entity.PatientInfoSharingDetails;
import jp.co.nikkiso.ntss.core.entity.PatientShareCount;
import jp.co.nikkiso.ntss.core.entity.ShrPatInfo;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatientInfoSharing;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import javax.xml.bind.DatatypeConverter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Component
@Slf4j
public class ShrPatInfoServiceImpl implements ShrPatInfoService {

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private ShrPatInfoDao shrPatInfoDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private MstFacilityDao mstFacilityDao;

  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;


  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

  /**
   * S3バケット名
   */
  @Value("${ntss.shr-pat-info.s3-bucket}")
  private String s3Bucket;
  /**
   * S3オブジェクト取得
   *
   * @return s3 S3オブジェクト
   */
  @Autowired
  private AwsConfiguration awsS3;

  private AmazonS3 s3() {
    return awsS3.s3();
  }


  @Override
  public List<PatientInfoSharing> patientInformationSharing(PatInsuranceConditionsSharing conditions, String facilityCd) {

    // 施設コード設定
    conditions.setFacilityCd(facilityCd);

    // 当院に紐づく患者＋施設情報取得
    List<PatientFacilityInfo> allHospitalPatientFacilityInfos = shrPatInfoDao.getAllHospitalPatientIds(conditions);

    List<Long> allHospitalPatientIds=new ArrayList<>();
    allHospitalPatientIds.add(conditions.getCurrentSelectedPatId());
    // 当院患者ID一覧取得
    allHospitalPatientIds = allHospitalPatientFacilityInfos.stream()
      .map(PatientFacilityInfo::getPatientId)
      .filter(Objects::nonNull)
      .distinct()
      .toList();

    // 他施設患者の共有情報
    List<PatientInfoSharing> otherPatientInfoSharings = new ArrayList<>();

    // 施設指定検索かつ当院患者が存在しない場合
    if ((!StringUtils.isEmpty(conditions.getFromFacilityCd()) || !StringUtils.isEmpty(conditions.getToFacilityCd())) && allHospitalPatientIds.isEmpty()) {
      return List.of();
    }

    if (!allHospitalPatientIds.isEmpty()) {
      // 他施設患者の共有情報取得
      conditions.setFacilityCd(null);
      conditions.setPatIdList(allHospitalPatientIds);
      otherPatientInfoSharings = patPersonalMainDao.selectPatientInformationSharing(conditions);

      // 条件復元
      conditions.setFacilityCd(facilityCd);
      conditions.setPatIdList(null);
    }

    // 除外患者ID設定
    PatInsuranceConditionsSharing tempConditions = new PatInsuranceConditionsSharing();
    tempConditions.setFacilityCd(facilityCd);

    List<PatientFacilityInfo> currentFacilityPatients = shrPatInfoDao.getAllHospitalPatientIds(tempConditions);

    Set<Long> existsPatientIds = allHospitalPatientFacilityInfos.stream().map(PatientFacilityInfo::getPatientId).filter(Objects::nonNull).collect(Collectors.toSet());

    List<Long> excludePatientIds = currentFacilityPatients.stream().map(PatientFacilityInfo::getPatientId).filter(Objects::nonNull).filter(id -> !existsPatientIds.contains(id)).distinct().toList();

    conditions.setExcludePatIdList(excludePatientIds);


    // 共有先件数
    Map<Long, Integer> shareFromCountMap = convertToIntMap(shrPatInfoDao.selectShareFromCounts(facilityCd));

    // 共有元件数
    Map<Long, Integer> shareToCountMap = convertToIntMap(shrPatInfoDao.selectShareToCounts(facilityCd));

    // 未完了件数
    Map<Long, Integer> pendingCountMap = convertToIntMap(shrPatInfoDao.selectPendingCounts(facilityCd, allHospitalPatientIds));

    // 禁止数量件数
    Map<Long, Integer> prohibitedCountMap = convertToIntMap(shrPatInfoDao.selectProhibitedCounts(facilityCd, allHospitalPatientIds));

    // 同姓同名判定用患者情報取得
    Map<Long, PatMain> patMainMap =
      patMainDao.selectByFacilityCd(facilityCd)
        .stream()
        .collect(Collectors.toMap(
          PatMain::getPat_id,
          p -> p
        ));

    // 患者共有情報取得
    List<PatientInfoSharing> patientInfoSharings =new ArrayList<>();

    if (StringUtils.isEmpty(conditions.getFromFacilityCd()) && StringUtils.isEmpty(conditions.getToFacilityCd())){
      patientInfoSharings = patPersonalMainDao.selectPatientInformationSharing(conditions);
    }

    patientInfoSharings.addAll(otherPatientInfoSharings);

    // 患者情報整形
    for (PatientInfoSharing info : patientInfoSharings) {
      Long patId = info.getPatId();

      // 同姓同名フラグ設定
      PatMain patMain = patMainMap.get(patId);
      if (patMain != null) {
        info.setIs_same(patMain.getIs_same());
      }

      // 他施設の患者の場合、院内患者IDを非表示
      if (!facilityCd.equals(info.getFacilityCd())) {
        info.setHosp_pat_id(null);
      }

      // 統計情報設定
      info.setShareFromCount(shareToCountMap.getOrDefault(patId, 0));
      info.setShareToCount(shareFromCountMap.getOrDefault(patId, 0));
      info.setPendingCount(pendingCountMap.getOrDefault(patId, 0));
      info.setProhibitedCount(prohibitedCountMap.getOrDefault(patId, 0));

      // 生年月日フォーマット
      info.setPat_birthday(formatBirthday(info.getPat_birthday()));
    }
    Set<Long> seenPatientIds = new HashSet<>();

    Long currentPatId = conditions.getCurrentSelectedPatId();

    return patientInfoSharings.stream()
      .filter(Objects::nonNull)
      .filter(p -> seenPatientIds.add(p.getPatId()))
      .filter(p -> {
        if (Objects.equals(p.getPatId(), currentPatId)) {
          return true;
        }
        return (!conditions.getPendingFlg() || p.getPendingCount() > 0)
          && (!conditions.getShareFromFlg() || p.getShareFromCount() > 0)
          && (!conditions.getShareToFlg() || p.getShareToCount() > 0)
          && (!conditions.getProhibitedFlg() || p.getProhibitedCount() > 0);
      })
      .sorted(
        Comparator.comparingInt(PatientInfoSharing::getPendingCount).reversed()
          .thenComparing(p -> p.getHosp_pat_id() == null)
      )
      .toList();
  }

  @Override
  public PatientInfoSharingDetails sharingDetails(Long patId, String facilityCd) {
    // 戻り値オブジェクト生成
    PatientInfoSharingDetails patientInfoSharingDetails = new PatientInfoSharingDetails();

    // 送信した共有データ（自施設 → 他施設）
    List<ShrPatInfo> facilityToList = shrPatInfoDao.selectShrPatInfoSource(patId, facilityCd);

    // 受信した共有データ（他施設 → 自施設）
    List<ShrPatInfo> facilityFromList = shrPatInfoDao.selectShrPatInfoReceive(patId, facilityCd);

    // 全施設マスタ取得（施設名設定用）
    List<MstFacility> mstFacilities = mstFacilityDao.selectAll();

    // 関連する患者ID一覧を抽出（重複除外）
    List<Long> patIdList = Stream.concat(facilityToList.stream(), facilityFromList.stream()).flatMap(info -> Stream.of(info.getFromPatId(), info.getToPatId())).filter(Objects::nonNull).distinct().toList();

    // 関連するユーザID一覧を抽出（重複除外）
    List<Long> userIdList = Stream.concat(facilityToList.stream(), facilityFromList.stream()).flatMap(info -> Stream.of(info.getFromUserId(), info.getToUserId())).filter(Objects::nonNull).distinct().toList();

    // ユーザ情報取得
    List<MstPersonalUser> mstPersonalUsers = mstPersonalUserDao.selectByIdList(userIdList);

    // ユーザID → ユーザ名 のMap作成
    Map<Long, String> mstPersonalUsersMap = mstPersonalUsers.stream().collect(Collectors.toMap(MstPersonalUser::getUserId, user -> user.getUserLastName() + user.getUserFirstName()));

    // 患者個人情報取得
    List<PatPersonalMain> patPersonalMains = patPersonalMainDao.selectByIdList(patIdList);

    // 患者ID → 院内患者ID のMap作成
    Map<Long, String> patPersonalMainsMap = patPersonalMains.stream().collect(Collectors.toMap(PatPersonalMain::getPat_id, PatPersonalMain::getHosp_pat_id));

    // 施設コード → 施設名 のMap作成
    Map<String, String> facilityNameMap = mstFacilities.stream().collect(Collectors.toMap(MstFacility::getFacilityCd, MstFacility::getFacilityName));

    // 受信データの画面表示用情報設定
    for (ShrPatInfo matShrPatInfo : facilityFromList) {

      // 自施設が受信側の場合、送信者ユーザ名を設定
      if (facilityCd.equals(matShrPatInfo.getToFacilityCd())) {
        matShrPatInfo.setUserName(mstPersonalUsersMap.get(matShrPatInfo.getFromUserId()));
      }

      // 院内患者ID設定
      matShrPatInfo.setHosp_pat_id(patPersonalMainsMap.get(matShrPatInfo.getQueryPatientId(facilityCd)));

      // 施設名設定
      matShrPatInfo.setFacilityName(facilityNameMap.get(matShrPatInfo.getQueryfacilityCd(facilityCd)));
      matShrPatInfo.setDeletionFlag(matShrPatInfo.getDisplayDeletionFlag(facilityCd));

      // 共有状態初期化
      initSharedState(matShrPatInfo);
    }

    // 送信データの画面表示用情報設定
    for (ShrPatInfo matShrPatInfo : facilityToList) {

      // 自施設が送信側の場合、受信者ユーザ名を設定
      if (facilityCd.equals(matShrPatInfo.getFromFacilityCd())) {
        matShrPatInfo.setUserName(mstPersonalUsersMap.get(matShrPatInfo.getToUserId()));
      }

      // 院内患者ID設定
      matShrPatInfo.setHosp_pat_id(patPersonalMainsMap.get(matShrPatInfo.getQueryPatientId(facilityCd)));

      // 施設名設定
      matShrPatInfo.setFacilityName(facilityNameMap.get(matShrPatInfo.getQueryfacilityCd(facilityCd)));
      matShrPatInfo.setDeletionFlag(matShrPatInfo.getDisplayDeletionFlag(facilityCd));
      // 共有状態初期化
      initSharedState(matShrPatInfo);
    }

    // 戻り値にセット
    patientInfoSharingDetails.setFacilityToList(facilityToList);
    patientInfoSharingDetails.setFacilityFromList(facilityFromList);

    return patientInfoSharingDetails;
  }

  @Transactional
  public List<Map<String, Object>> uploadShrFileAttachment(MultipartFile[] files, String facilityCd, long shrPatInfoId) throws Exception {

    String localStore = null;
    String status = null;

    try {
      Map<String, String> map = getLocalStoreAndStatus();
      localStore = map.get("localStore");
      status = map.get("status");
    } catch (Exception e) {
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
      throw e;
    }

    String s3BucketInFcd = String.format(s3Bucket, facilityCd);

    List<Map<String, Object>> resultList = new ArrayList<>();
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
    String modifiedTime = LocalDateTime.now().format(formatter);

    for (MultipartFile file : files) {
      if (file == null) {
        continue;
      }

      String fileName = file.getOriginalFilename();
      String path = shrPatInfoId + "/file/" + fileName;

      if ("on".equals(status)) {
        String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
        Path filePath = Paths.get(fileLocation);
        byte[] bytes = file.getBytes();

        if (!Files.exists(filePath)) {
          Files.createDirectories(filePath.getParent());
          File newFile = new File(filePath.toString());
          newFile.createNewFile();
        }

        Files.write(filePath, bytes);

      } else {
        try (InputStream inputStream = file.getInputStream()) {

          s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, path));

          ObjectMetadata metadata = new ObjectMetadata();
          metadata.setContentLength(file.getSize());

          s3().putObject(new PutObjectRequest(s3BucketInFcd, path, inputStream, metadata));

        } catch (Exception e) {
          throw e;
        }
      }

      Map<String, Object> fileInfo = new HashMap<>();
      fileInfo.put("file_name", fileName);
      fileInfo.put("file_path", path);
      fileInfo.put("file_modified_time", modifiedTime);

      resultList.add(fileInfo);
    }

    return resultList;
  }


  @Override
  @Transactional
  public void uploadShrFileAttachment(MultipartFile file, String params) throws Exception {
    String localStore = null;
    String status = null;
    try {
      Map<String, String> map = getLocalStoreAndStatus();
      localStore = map.get("localStore");
      status = map.get("status");
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      throw e;
    }
    String[] event = params.split("&");
    String facility_cd = event[0];
    long pat_id = Long.parseLong(event[1]);
    long pat_shr_cd = Long.parseLong(event[2]);
    String path = pat_id + "/" + pat_shr_cd + "/file/" + file.getOriginalFilename();
    String s3BucketInFcd = String.format(s3Bucket, facility_cd);
    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
      Path filePath = Paths.get(fileLocation);
      byte[] bytes = file.getBytes();
      if (!Files.exists(filePath)) {

        Files.createDirectories(filePath.getParent());
        File newFile = new File(filePath.toString());
        newFile.createNewFile();
      }
      Files.write(filePath, bytes);
    } else {
      try (InputStream inputStream = file.getInputStream()) {

        s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, path));
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        // S3アップロード
        s3().putObject(new PutObjectRequest(s3BucketInFcd, path, file.getInputStream(), metadata));
        // DB更新
        //        patEventDao.updateOnlyResultParams(pat_event_cd, result_params);
      } catch (Exception e) {
        throw e;
      }
    }
  }

  @Override
  public String downloadShrFileAttachment(String filepath, String facilityCd) throws Exception {
    String localStore = null;
    String status = null;
    String s3BucketInFcd = String.format(s3Bucket, facilityCd);
    try {
      Map<String, String> map = getLocalStoreAndStatus();
      localStore = map.get("localStore");
      status = map.get("status");
    } catch (Exception e) {
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
      throw e;
    }

    if (status.equals("on")) {
      String fileLocation = localStore + "/" + s3BucketInFcd + "/" + filepath;
      Path path = Paths.get(fileLocation);
      byte[] content = null;
      content = Files.readAllBytes(path);
      // 16進数文字列に変換
      String hexString = DatatypeConverter.printHexBinary(content);
      return hexString;
    } else {
      S3Object object = s3().getObject(new GetObjectRequest(s3BucketInFcd, filepath));

      // レスポンス用データ生成
      try (InputStream is = object.getObjectContent(); ByteArrayOutputStream os = new ByteArrayOutputStream();) {
        byte[] buffer = new byte[1024];
        while (true) {
          int len = is.read(buffer);
          if (len < 0) {
            break;
          }
          os.write(buffer, 0, len);
        }
        byte[] content = os.toByteArray();
        // 16進数文字列に変換
        String hexString = DatatypeConverter.printHexBinary(content);
        return hexString;
      } catch (Exception e) {
        throw e;
      }
    }
  }

  @Override
  public void saveShrPatInfo(ShrPatInfo shrPatInfo, NtssUser ntssUser, MultipartFile[] files) throws Exception {

    // ログインユーザの施設コード取得
    String facilityCd = ntssUser.getFacilityCd();

    // 対応施設情報取得（※現在は未使用だが業務上必要な場合あり）
    Map<String, List<String>> stringListMap = getCorrespondingFacilities(facilityCd);

    // 送信側か受信側かを判定し、各種情報を設定
    if (facilityCd.equals(shrPatInfo.getFromFacilityCd())) {

      // 自施設が送信側の場合
      shrPatInfo.setFromUpDate(getTimeNow());
      shrPatInfo.setShareDirection("1");   // 送信
      shrPatInfo.setFromUpdUserId(ntssUser.getUserId());

    } else {

      // 自施設が受信側の場合
      shrPatInfo.setToUpDate(getTimeNow());
      shrPatInfo.setShareDirection("2");   // 受信
      shrPatInfo.setToUpdUserId(ntssUser.getUserId());
    }

    // 共通初期値設定
    shrPatInfo.setRegDate(getTimeNow());  // 登録日時
    shrPatInfo.setIsDisp("1");            // 表示フラグ（表示）
    shrPatInfo.setIsDel("0");             // 削除フラグ（未削除）
    shrPatInfo.setShrAttachment(null);    // 添付ファイル初期化

    // DBへ登録
    shrPatInfoDao.insert(shrPatInfo);

    // 自動採番されたID取得
    Long id = shrPatInfo.getShrPatInfoId();

    // 添付ファイルが存在する場合の処理
    if (files != null) {

      // ファイルアップロード処理
      List<Map<String, Object>> shrFileAttachment = uploadShrFileAttachment(files, facilityCd, shrPatInfo.getShrPatInfoId());

      // 添付情報をJSONへ変換
      ObjectMapper objectMapper = new ObjectMapper();
      String jsonStr = objectMapper.writeValueAsString(shrFileAttachment);

      // 添付情報をDBへ更新
      shrPatInfoDao.updateAttachment(jsonStr, id);
    }
  }

  @Override
  public void updateShrPatInfo(ShrPatInfo shrPatInfo,
                               NtssUser ntssUser,
                               MultipartFile[] files) throws Exception {

    // ログインユーザの施設コード取得
    String facilityCd = ntssUser.getFacilityCd();

    ObjectMapper objectMapper = new ObjectMapper();

    // ===== 既存添付情報取得 =====
    List<Map<String, Object>> attachments;
    String jsonStr = shrPatInfo.getShrAttachment();

    // 添付情報が空の場合は空Listを生成
    if (jsonStr == null || jsonStr.isBlank()) {
      attachments = new ArrayList<>();
    } else {
      // JSON文字列をList<Map>へ変換
      attachments = objectMapper.readValue(
        jsonStr,
        new TypeReference<List<Map<String, Object>>>() {}
      );
    }

    // ===== ファイル更新処理 =====
    if (files != null && files.length > 0) {

      // ファイル名をキーにしたMap作成（重複時は先勝ち）
      Map<String, MultipartFile> fileMap =
        Arrays.stream(files)
          .filter(f -> f != null)
          .collect(Collectors.toMap(
            MultipartFile::getOriginalFilename,
            f -> f,
            (f1, f2) -> f1
          ));

      // ① file_path が null の既存データに対応するファイルをアップロード
      List<MultipartFile> filesToUpload = new ArrayList<>();

      for (Map<String, Object> attachment : attachments) {
        if (attachment.get("file_path") == null) {
          String fileName = (String) attachment.get("file_name");
          MultipartFile matchFile = fileMap.get(fileName);
          if (matchFile != null) {
            filesToUpload.add(matchFile);
          }
        }
      }

      // アップロード実行
      if (!filesToUpload.isEmpty()) {

        List<Map<String, Object>> uploadedFiles =
          uploadShrFileAttachment(
            filesToUpload.toArray(new MultipartFile[0]),
            facilityCd,
            shrPatInfo.getShrPatInfoId()
          );

        // JSON内の file_path / file_modified_time を更新
        for (Map<String, Object> uploaded : uploadedFiles) {
          String fileName = (String) uploaded.get("file_name");

          attachments.stream()
            .filter(att ->
              fileName.equals(att.get("file_name"))
                && att.get("file_path") == null
            )
            .forEach(att -> {
              att.put("file_path", uploaded.get("file_path"));
              att.put("file_modified_time",
                uploaded.get("file_modified_time"));
            });
        }
      }

      // ② JSONに存在しない新規ファイルを抽出
      List<MultipartFile> newFiles =
        Arrays.stream(files)
          .filter(f -> f != null
            && !f.isEmpty()
            && attachments.stream().noneMatch(att ->
            f.getOriginalFilename()
              .equals(att.get("file_name"))
          ))
          .collect(Collectors.toList());

      // 新規ファイルアップロード
      if (!newFiles.isEmpty()) {

        List<Map<String, Object>> uploadedNewFiles =
          uploadShrFileAttachment(
            newFiles.toArray(new MultipartFile[0]),
            facilityCd,
            shrPatInfo.getShrPatInfoId()
          );

        // 添付一覧へ追加
        attachments.addAll(uploadedNewFiles);
      }
    }

    // 更新後の添付情報をJSONへ再変換
    shrPatInfo.setShrAttachment(
      objectMapper.writeValueAsString(attachments)
    );

    // ===== 更新者情報設定 =====
    if (facilityCd.equals(shrPatInfo.getFromFacilityCd())) {

      // 自施設が送信側の場合
      shrPatInfo.setFromUpdUserId(ntssUser.getUserId());
      shrPatInfo.setFromUpDate(getTimeNow());

    } else {

      // 自施設が受信側の場合
      shrPatInfo.setToUpdUserId(ntssUser.getUserId());
      shrPatInfo.setToUpDate(getTimeNow());
    }

    // DB更新
    shrPatInfoDao.update(shrPatInfo);
  }

  @Override
  public List<PatientInfoSharing> patientDetailsDown(String facilityCd)
    throws JsonProcessingException {
    List<String> facilityCdList =new ArrayList<>();
    facilityCdList.add(facilityCd);
    FacilitySettingInfo settingValue
      = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, CoreConstant.FacilitySettingNo.SIMPLE_SEARCH_CONDITIONS);
    int conditionalSearchPatient = Integer.parseInt(settingValue.getValue());

    List<PatMain> patMainList = new ArrayList<PatMain>();
    patMainList = patMainDao.selectByCdListAndSetting(facilityCdList, conditionalSearchPatient);
    // ===== 検索条件設定 =====
    PatInsuranceConditionsSharing conditions =
      new PatInsuranceConditionsSharing();
    conditions.setFacilityCd(facilityCd);
    conditions.setStartBirthDate("");
    conditions.setEndBirthDate("");

    // 患者共有情報取得
    List<PatientInfoSharing> patientInfoSharings =
      patPersonalMainDao.selectPatientInformationSharing(conditions);

    ObjectMapper mapper = new ObjectMapper();

    // ===== 同姓同名判定用患者情報取得 =====
    Map<Long, PatMain> patMainMap =
      patMainDao.selectByFacilityCd(facilityCd)
        .stream()
        .collect(Collectors.toMap(
          PatMain::getPat_id,
          p -> p
        ));

    // ===== 画面表示用データ加工 =====
    for (PatientInfoSharing patientInfoSharing : patientInfoSharings) {

      // 生年月日退避（元データ保持用）
      patientInfoSharing.setBirthday(
        patientInfoSharing.getPat_birthday()
      );

      // 生年月日フォーマット変換
      patientInfoSharing.setPat_birthday(
        formatBirthday(patientInfoSharing.getPat_birthday())
      );

      // 同姓同名フラグ設定
      PatMain patMain =
        patMainMap.get(patientInfoSharing.getPatId());
      if (patMain != null) {
        patientInfoSharing.setIs_same(
          patMain.getIs_same()
        );
      }

      // ===== 連絡先JSON解析 =====
      String json = patientInfoSharing.getPat_contact_info();
      if (json != null && !json.isEmpty()) {

        Map<String, Object> map =
          mapper.readValue(json, Map.class);

        // 住所取得
        String address = (String) map.get("address");
        patientInfoSharing.setAddress(address);
      }
    }

    Set<Long> patIdSet = patMainList.stream()
      .map(PatMain::getPat_id)
      .collect(Collectors.toSet());

    List<PatientInfoSharing> result = patientInfoSharings.stream()
      .filter(p -> patIdSet.contains(p.getPatId()))
      .collect(Collectors.toList());

    return result;
  }

  @Override
  public Map<String, Object> facilityCdDown(String facilityCd) {

    Map<String, Object> mapList=new HashMap<>();
    // 施設名取得
    List<MstFacility> mstFacilityList = mstFacilityDao.selectAll();
    List<Map<String, String>> facilityList = mstFacilityList.stream().map(facility -> Map.of("facilityCd", facility.getFacilityCd(), "facilityName", facility.getFacilityName())).toList();
    mapList.put("facility",facilityList);
    // 施設名取得
    List<MstFacility> mstFacilities = mstFacilityDao.selectFacilityByFunctionCd(facilityCd);
    List<Map<String, String>> filterFacility = mstFacilities.stream().map(facility -> Map.of("facilityCd", facility.getFacilityCd(), "facilityName", facility.getFacilityName())).collect(Collectors.toList());
    mapList.put("filterFacility",filterFacility);
    return mapList;
  }

  @Override
  public void deleteShrPatInfo(Long shrPatInfoId) {
    shrPatInfoDao.deleteShrPatInfo(shrPatInfoId);
  }

  @Override
  public Map<String, List<String>> correspondingFacilities(String facilityCd) throws JsonProcessingException {
    return getCorrespondingFacilities(facilityCd);
  }

  @Override
  @Transactional
  public void deleteEventFileAttachment(List<Map<String, String>> fileInfoList, long patId, String facilityCd) throws Exception {
    String localStore = null;
    String status = null;
    String s3BucketInFcd = null;
    try {
      s3BucketInFcd = String.format(s3Bucket, facilityCd);
      Map<String, String> map = getLocalStoreAndStatus();
      localStore = map.get("localStore");
      status = map.get("status");
    } catch (Exception e) {
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
      throw e;
    }
    for (Map<String, String> fileInfo : fileInfoList) {
      String path = fileInfo.get("file_path");
      if (status.equals("on")) {
        String fileLocation = localStore + "/" + s3BucketInFcd + "/" + path;
        Path pathFile = Paths.get(fileLocation);
        pathFile.toFile().delete();
      } else {
        if (!path.isEmpty()) {
          // S3ファイル削除
          s3().deleteObject(new DeleteObjectRequest(s3BucketInFcd, path));
        }
      }
    }
  }

  // add #12462 患者情報共有->患者経過総合ビューア fang start
  /**
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return ShrPatInfo 共有情報
   */
  @Override
  public List<ShrPatInfo> selectShrPatInfoByPatId(Long patId, String facilityCd) {
    return shrPatInfoDao.selectShrPatInfoByPatId(patId, facilityCd);
  }
  // add #12462 患者情報共有->患者経過総合ビューア fang end

  /**
   * PatientShareCount のリストを、<患者ID, 件数> の Map に変換する。
   *
   * @param counts PatientShareCount のリスト
   * @return キー：patientId（Long）、値：count（Integer）の Map。
   * counts が null の場合は空の Map を返す。
   */
  private Map<Long, Integer> convertToIntMap(List<PatientShareCount> counts) {

    // counts が null の場合は空の Map を返却する
    if (counts == null) {
      return new HashMap<>();
    }

    // Stream を使用して List から Map へ変換する
    return counts.stream().collect(Collectors.toMap(
      // キー：PatientShareCount#getPatientId
      PatientShareCount::getPatientId,
      // 値：PatientShareCount#getCount
      PatientShareCount::getCount));
  }

  /**
   * 生年月日フォーマット変換
   *
   * @param birthdayStr
   * @return
   */
  public String formatBirthday(String birthdayStr) {
    if (birthdayStr == null || birthdayStr.length() != 8) {
      return birthdayStr;
    }
    try {
      // 解析日
      DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
      LocalDate birthday = LocalDate.parse(birthdayStr, inputFormatter);

      // 出力の書式設定
      DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("yyyy/MM/dd");
      String formattedDate = birthday.format(outputFormatter);

      // 年齢の計算
      LocalDate today = LocalDate.now();
      int age = Period.between(birthday, today).getYears();

      return formattedDate + "(" + age + "歳)";
    } catch (DateTimeParseException e) {
      return birthdayStr;
    }
  }

  /**
   * 状態を計算する
   */
  private void initSharedState(ShrPatInfo info) {
    String sharedState;
    if ("9".equals(info.getIsFromConsent()) || "9".equals(info.getIsToConsent()) || "9".equals(info.getIsPatConsent())) {
      sharedState = "9";
    } else if ("1".equals(info.getIsFromConsent()) && "1".equals(info.getIsToConsent()) && "1".equals(info.getIsPatConsent())) {
      sharedState = "1";
    } else {
      sharedState = "0";
    }
    info.setSharedState(sharedState);
  }

  /**
   * オンプレミス設定の取得
   *
   * @return
   * @throws Exception
   */
  private Map<String, String> getLocalStoreAndStatus() throws Exception {
    String localStore = null;
    String status = null;
    SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
    ObjectMapper objectMapper = new ObjectMapper();
    HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>() {
    });
    localStore = onPremise.get("path");
    status = onPremise.get("status");
    Map<String, String> mapResult = new HashMap<>();
    mapResult.put("localStore", localStore);
    mapResult.put("status", status);
    return mapResult;
  }

  /**
   * 現在の日を取得する
   *
   * @return 日付
   */
  public Timestamp getTimeNow() {
    Date now = new Date();
    return new Timestamp(now.getTime());
  }

  /**
   * 指定した施設コードに対応する施設情報を取得する
   *
   * @param facilityCd 施設コード
   * @return "fromCorresponding" と "toCorresponding" を含む Map
   * @throws JsonProcessingException JSON 解析例外
   */
  private Map<String, List<String>> getCorrespondingFacilities(String facilityCd) throws JsonProcessingException {
    ObjectMapper mapper = new ObjectMapper();
    Map<String, List<String>> map = new HashMap<>();

    // 自施設に対応する附属施設を取得
    String affiliatedFacilities = mstFacilitySettingDao.getAffiliatedFacilities(facilityCd, CoreConstant.FacilitySettingNo.AFFILIATED_FACILITIES);

    List<String> fromList;
    if (affiliatedFacilities == null || affiliatedFacilities.isEmpty() || "null".equals(affiliatedFacilities)) {
      fromList = new ArrayList<>();
    } else {
      fromList = mapper.readValue(affiliatedFacilities, new TypeReference<List<String>>() {});
    }

    // 自施設に対応する施設を取得
    String jsonValue = "[\"" + facilityCd + "\"]";
    List<String> toList = mstFacilitySettingDao.getFacilityToMe(jsonValue, CoreConstant.FacilitySettingNo.AFFILIATED_FACILITIES);

    map.put("fromCorresponding", fromList);
    map.put("toCorresponding", toList);

    return map;
  }
}
