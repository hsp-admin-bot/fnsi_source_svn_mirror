package jp.co.nikkiso.ntss.admin_web.service.deviceEdgeManage;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.AmazonS3Exception;
import com.amazonaws.services.s3.model.ListObjectsV2Request;
import com.amazonaws.services.s3.model.ListObjectsV2Result;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.config.AwsConfiguration;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.WebSocketTopic.DeviceEdgeManage;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeManage.DeviceEdgeManageResponse;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeManage.ResponseS3Bucket;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.PayloadBuilder;
import jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeManageDao;
import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.dao.MstDeviceEdgeDao;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.entity.custom.DeviceEdgeStateWithManage;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;
import java.util.StringJoiner;

@Service
public class DeviceEdgeManageServiceImpl implements DeviceEdgeManageService {

  @Autowired
  MntDeviceEdgeManageDao mntDeviceEdgeManageDao;
  @Autowired
  MntDeviceEdgeStateDao mntDeviceEdgeStateDao;
  @Autowired
  MstDeviceEdgeDao mstDeviceEdgeDao;
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  private final short statusOrder = 0;
  private final short statusError = -2;

  @Autowired
  private WebSocketNotifyService webSocketNotifyService;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;
  /**
   * Amazon S3.
   */
  @Autowired
  private AwsConfiguration awsS3;
  private AmazonS3 s3() {
    return awsS3.s3();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<DeviceEdgeStateWithManage> getDeviceEdgeState() {
    List<DeviceEdgeStateWithManage> stateList = mntDeviceEdgeStateDao.selectStateWithManage(null, null);

    return stateList;
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgeStateWithManage getDeviceEdgeState(String facilityCd, int deviceEdgeNo) {
    List<DeviceEdgeStateWithManage> stateList = mntDeviceEdgeStateDao.selectStateWithManage(facilityCd, deviceEdgeNo);
    if (stateList.size() > 0) {
      return stateList.get(0);
    }
    return null;
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public MntDeviceEdgeManage selectByManageNo(Long manageNo) {
    return mntDeviceEdgeManageDao.selectByManageNo(manageNo);
  }

  /**
   * {@inheritDoc}
   */
  @Transactional
  @Override
  public Long insertNewRecordManageNo(MntDeviceEdgeManage param) {
    if (mntDeviceEdgeManageDao.insertNewRecordManageNo(param) > 0) {
      return param.getManageNo();
    }
    return null;
  }

  /**
   * {@inheritDoc}
   */
  @Transactional
  @Override
  public Long updateManageOrderInfo(Long manageNo, short responseStatus, String topic, String payload) {
    MntDeviceEdgeManage param = mntDeviceEdgeManageDao.selectByManageNo(manageNo);
    param.setResponseStatus(responseStatus);
    MntDeviceEdgeManage.ManageInfo info = param.getManageInfo();
    info.setMessage("");
    info.setPayload(topic + "\t" + payload);
    param.setManageInfo(info);

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

    if (mntDeviceEdgeManageDao.update(param) > 0) {
      return param.getManageNo();
    }
    return null;
  }

  /**
   * {@inheritDoc}
   */
  @Transactional
  @Override
  public Long updateManageError(Long manageNo, short responseStatus, String errorMessage) {
    MntDeviceEdgeManage param = mntDeviceEdgeManageDao.selectByManageNo(manageNo);
    param.setResponseStatus(responseStatus);
    MntDeviceEdgeManage.ManageInfo info = param.getManageInfo();
    info.setMessage(errorMessage);
    param.setManageInfo(info);
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end

    if (mntDeviceEdgeManageDao.update(param) > 0) {
      return param.getManageNo();
    }
    return null;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public String getTopicString(Short category) {
    String ret = null;
    switch (category) {
    case DeviceEdgeManage.OrderClass.UPDATE:
      ret = DeviceEdgeManage.UPDATE;
      break;
    case DeviceEdgeManage.OrderClass.RESTORE:
      ret = DeviceEdgeManage.RESTORE;
      break;
    case DeviceEdgeManage.OrderClass.LOG_GATHER:
      ret = DeviceEdgeManage.LOG_GATHER;
      break;
    case DeviceEdgeManage.OrderClass.DEVICE_REBOOT:
      ret = DeviceEdgeManage.DEVICE_REBOOT;
      break;
    case DeviceEdgeManage.OrderClass.CONF_UPDATE:
      ret = DeviceEdgeManage.CONF_UPDATE;
      break;
    case DeviceEdgeManage.OrderClass.CONF_GATHER:
      ret = DeviceEdgeManage.CONF_GATHER;
      break;
    case DeviceEdgeManage.OrderClass.APP_STOP:
      ret = DeviceEdgeManage.APP_STOP;
      break;
    case DeviceEdgeManage.OrderClass.APP_START:
      ret = DeviceEdgeManage.APP_START;
      break;
    case DeviceEdgeManage.OrderClass.APP_REBOOT:
      ret = DeviceEdgeManage.APP_REBOOT;
      break;
    case DeviceEdgeManage.OrderClass.PLAN_CANCEL:
      ret = DeviceEdgeManage.PLAN_CANCEL;
      break;

    default:
      break;
    }
    return ret;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public ResponseS3Bucket findLogInfo(String facilityCd, int deviceEdgeNo, String dateStr) {
    //add #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 start
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
    //add #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 end
    String logFilepath = "";
    // DEログファイルパス取得
    List<SysSystemDefine> data = sysSystemDefineDao.selectByCtlNo(CoreConstant.SysSystemDefine.DEVICEEDGE_LOG_OUTPUT_PATH);
    if (data.size() > 0) {
      String strJson = data.get(0).getValue();
      JSONObject objJson = new JSONObject(strJson);
      logFilepath = objJson.getString("path").replaceAll("\\{0\\}", facilityCd);

      //add #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 start
      Date date = new Date();
      String todayYMD = sdf.format(date);
      if (dateStr.equals(todayYMD)) {
        logFilepath = logFilepath.replaceAll("\\{1\\}", "today");
      } else {
        logFilepath = logFilepath.replaceAll("\\{1\\}", dateStr);
      }
      //add #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 end
    }

    // レスポンスを用意
    ResponseS3Bucket res = new ResponseS3Bucket();
    res.setExists(false);
    res.setBucket(logFilepath);

    // ファイル名を構築
    String serial = "";
    for (MstDeviceEdge edge : mstDeviceEdgeDao.selectByFacilityCd(facilityCd)) {
      if (edge.getDeviceEdgeNo() != null && edge.getDeviceEdgeNo().intValue() == deviceEdgeNo) {
        serial = edge.getSerialNo();
        break;
      }
    }
    // mod #10756 拡張しを小文字に統一すること。 dengshen start
    // StringJoiner sj = new StringJoiner("_", "", ".ZIP");
    StringJoiner sj = new StringJoiner("_", "", ".zip");
    // mod #10756 拡張しを小文字に統一すること。 dengshen end
    //mod #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 start
    sj.add(facilityCd).add("DE").add(String.format("%s", serial)).add(String.format("%02d", deviceEdgeNo)).add(dateStr);
    //mod #9696 アプリケーションログのパスとファイル名の修正。 zhaoqi 20240403 end
    String fileName = sj.toString();
    res.setFileName(fileName);

    // ファイルを検索
    try {
      String fileLocation = logFilepath + "/" + res.getFileName();
      Path pathFile = Paths.get(fileLocation);
      boolean exists = Files.exists(pathFile);
      res.setExists(exists);
      if (!exists) {
        res.setMessage("ダウンロードするファイルがありません。");
      }
    } catch (Exception ex) {
      res.setMessage(ex.getMessage());
    }

    return res;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public ResponseS3Bucket findConfS3Info(String s3Bucket, String facilityCd, int deviceEdgeNo) {
    String localStore = null;
    String status = null;
    s3Bucket = s3Bucket.replace("s3://", "");
    try {
      SysSystemDefine data = sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      ObjectMapper objectMapper = new ObjectMapper();
      HashMap<String, String> onPremise = objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
      localStore = onPremise.get("path");
      status = onPremise.get("status");
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[findConfS3Info]ダウンロード対象ファイル確認: システム設定の取得に失敗[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    if (status.equals("on")) {
      return findConfS3InfoOnPremise(s3Bucket, deviceEdgeNo, localStore);
    }
    // レスポンスを用意
    ResponseS3Bucket res = new ResponseS3Bucket();
    res.setExists(false);

    // s3のバケットパスを構築
    StringJoiner sjBucket = new StringJoiner("/");
    String bucket = sjBucket.add(s3Bucket).add(String.valueOf(deviceEdgeNo)).toString();
    res.setBucket(bucket);

    // s3のパス部のみを構築
    String[] pathArray = s3Bucket.split("/");
    String s3BucketName = pathArray[0];
    String prefix = s3Bucket.substring(pathArray[0].length() + 1);
    prefix += "/" + String.valueOf(deviceEdgeNo);
    String path = prefix + "/";

    // S3を検索
    try {
      final ListObjectsV2Request req = new ListObjectsV2Request().withBucketName(s3BucketName).withPrefix(prefix);
      ListObjectsV2Result result;
      Date lastModified = null;
      do {
        result = s3().listObjectsV2(req);

        res.setExists(res.isExists() || result.getObjectSummaries().size() > 0);
        for (S3ObjectSummary objectSummary : result.getObjectSummaries()) {
          if (lastModified == null || lastModified.before(objectSummary.getLastModified())) {
            lastModified = objectSummary.getLastModified();
            res.setFileName(objectSummary.getKey());
          }
        }
        req.setContinuationToken(result.getNextContinuationToken());
      } while (result.isTruncated() == true);

      if (res.isExists()) {

        removeOtherFileS3(s3BucketName, path, res.getFileName());

        res.setModifiedDate(lastModified);
        res.setMessage("");
        res.setFileName(res.getFileName().substring(path.length()));
      } else {
        res.setMessage("ダウンロードするファイルがありません。");
      }
    } catch (AmazonS3Exception ex) {
      res.setMessage("ダウンロードするファイルがありません。");
    }

    return res;
  }

  /**
   * 指定のファイル以外をs3の同フォルダから削除
   * @param s3Bucket
   * @param path
   * @param fileName
   */
  private void removeOtherFileS3(String s3Bucket, String path, String fileName) {

    // S3を検索
    try {
      final ListObjectsV2Request req = new ListObjectsV2Request().withBucketName(s3Bucket).withPrefix(path);
      ListObjectsV2Result result;
      do {
        result = s3().listObjectsV2(req);
        for (S3ObjectSummary objectSummary : result.getObjectSummaries()) {
          if (!Objects.equals(objectSummary.getKey(), fileName)) {
            s3().deleteObject(s3Bucket, objectSummary.getKey());
          }
        }
        req.setContinuationToken(result.getNextContinuationToken());
      } while (result.isTruncated() == true);
    } catch (AmazonS3Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[removeOtherFileS3]古いファイル削除に失敗[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[removeOtherFileS3]古いファイル削除で想定外のエラー[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }

  private ResponseS3Bucket findConfS3InfoOnPremise(String s3Bucket, int deviceEdgeNo, String localStore) {
    // レスポンスを用意
    ResponseS3Bucket res = new ResponseS3Bucket();
    res.setExists(false);

    // s3のバケットパスを構築
    StringJoiner sjBucket = new StringJoiner("/");
    String bucket = sjBucket.add(s3Bucket).add(String.valueOf(deviceEdgeNo)).toString();
    res.setBucket(bucket);

    // s3のパス部のみを構築
    StringJoiner sjPath = new StringJoiner("/");
    String path = sjPath.add(String.valueOf(deviceEdgeNo)).toString();

    try {
      File folder = new File(localStore + "/" + s3Bucket + "/" + path);
      File[] listOfFiles = folder.listFiles();
      Date lastModified = null;
      for (int i = 0; i < listOfFiles.length; i++) {
        res.setExists(res.isExists() || listOfFiles.length > 0);
        if (listOfFiles[i].isFile()) {
          Date fileModifiedDate = new Date(listOfFiles[i].lastModified());
          if (lastModified == null || lastModified.before(fileModifiedDate)) {
            lastModified = fileModifiedDate;
            res.setFileName(listOfFiles[i].getName());
          }
        }
      }
      if (res.isExists()) {
        res.setModifiedDate(lastModified);
        res.setMessage("");
        removeOtherFileOnpremise(localStore, s3Bucket, path, res.getFileName());
      } else {
        res.setMessage("ダウンロードするファイルがありません。");
      }
    } catch (Exception e) {
      res.setMessage("ダウンロードするファイルがありません。");
    }
    return res;
  }
  /**
   * 指定のファイル以外を同フォルダから削除
   * @param s3Bucket
   * @param path
   * @param fileName
   */
  private void removeOtherFileOnpremise(String localStore, String s3Bucket, String path, String fileName) {

    try {
      File folder = new File(localStore + "/" + s3Bucket + "/" + path);
      File[] listOfFiles = folder.listFiles();
      for (int i = 0; i < listOfFiles.length; i++) {
        if (listOfFiles[i].isFile()) {
          if (!Objects.equals(listOfFiles[i].getName(), fileName)) {
            listOfFiles[i].delete();
          }
        }
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[removeOtherFileOnpremise]古いファイル削除に失敗[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public ResponseS3Bucket findConfS3UpTarget(String s3Bucket, int deviceEdgeNo) {

    // レスポンスを用意
    ResponseS3Bucket res = new ResponseS3Bucket();
    res.setExists(false);

    // s3のバケットパスを構築
    StringJoiner sjBucket = new StringJoiner("/");
    String bucket = sjBucket.add(s3Bucket).add(String.valueOf(deviceEdgeNo)).toString();
    res.setBucket(bucket);

    res.setExists(true);
    return res;
  }

  /* add by SongJiHao  2023-02-01 [Transaction,Remote]  start */
  /**
   * 指示
   * @return
   */
  @Transactional
  public DeviceEdgeManageResponse sendOrderToEdge(
    NtssUser ntssUser,
    String targetFacilityCd,
    Integer deviceEdgeNo,
    MntDeviceEdgeManage param,
    MntDeviceEdgeManage.ManageInfo manageInfo,
    Short appType) {
    return sendOrderToEdge(ntssUser, targetFacilityCd, deviceEdgeNo, param, manageInfo, appType, null);
  }

  /**
   * 指示
   * @return
   */
  @Transactional
  public DeviceEdgeManageResponse sendOrderToEdge(
    NtssUser ntssUser,
    String targetFacilityCd,
    Integer deviceEdgeNo,
    MntDeviceEdgeManage param,
    MntDeviceEdgeManage.ManageInfo manageInfo,
    Short appType,
    String planDate) {

    DeviceEdgeManageResponse res = new DeviceEdgeManageResponse();
    try {
      if (param.getOrderClass() == null || param.getOrderClass().shortValue() < 0
        || param.getOrderClass().shortValue() > CoreConstant.DeviceEdgeManageConstant.OrderClass.MAX_CODE_VALUE) {
        res.isSuccess = false;
        res.errorMessage = "指示情報不正:命令種別異常";
        return res;
      }
      param.setUserId(ntssUser.getUserId());
      param.setResponseStatus(statusOrder);
      param.setManageInfo(manageInfo);
      Long manageNo = insertNewRecordManageNo(param);

      param.setManageNo(manageNo);
      res.manageParam = param;
      // ペイロード部作成
      String payload = "";
      switch (param.getOrderClass().shortValue()) {
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.APP_REBOOT:
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.APP_START:
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.APP_STOP:
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.DEVICE_REBOOT:
          payload = PayloadBuilder.BuildServiceControlPayload(param.getManageNo());

          break;
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.LOG_GATHER:
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.CONF_GATHER:
          payload = PayloadBuilder.BuildGatherPayload(param.getManageNo());

          break;
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.RESTORE:
          payload = PayloadBuilder.BuildAppRestorePayload(param.getManageNo());
          break;
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.UPDATE:
          payload = PayloadBuilder.BuildAppUpdatePayload(param.getManageNo(), appType,
            manageInfo.getDownloadBucket(), manageInfo.getDownloadFile(), planDate);
          break;
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.CONF_UPDATE:
          payload = PayloadBuilder.BuildConfUpdatePayload(param.getManageNo(), manageInfo.getDownloadBucket(),
            manageInfo.getDownloadFile());
          break;
        case CoreConstant.DeviceEdgeManageConstant.OrderClass.PLAN_CANCEL:
          payload = PayloadBuilder.BuildPlanCancelPayload(param.getManageNo());
          break;

        default:
          res.isSuccess = false;
          res.errorMessage = "指示情報不正:命令種別異常";
          return res;
      }

      String topic = PayloadBuilder.BuildTopic(
        getTopicString(param.getOrderClass()), targetFacilityCd,
        deviceEdgeNo);

      updateManageOrderInfo(manageNo, statusOrder, topic, payload);

      WebSocketNotifyService.SendTarget targetAppClass = WebSocketNotifyService.SendTarget.updater;

      if (param.getOrderTargetClass().shortValue() == (short) 0) {
        targetAppClass = WebSocketNotifyService.SendTarget.main;
      } else if (param.getOrderTargetClass().shortValue() == (short) 1) {
        targetAppClass = WebSocketNotifyService.SendTarget.updater;
      }

      if (webSocketNotifyService.sendMsg(targetAppClass, targetFacilityCd, deviceEdgeNo, topic, payload)) {
        res.isSuccess = true;
        return res;
      } else {
        res.isSuccess = false;
        res.errorMessage = "デバイスエッジ指示失敗";
        updateManageError(manageNo, statusError, res.errorMessage);
        return res;
      }
    } catch (Exception ex) {
      res.isSuccess = false;
      res.errorMessage = ex.getMessage();
      return res;
    }

  }
  /* add by SongJiHao  2023-02-01 [Transaction,Remote]  end */

}
