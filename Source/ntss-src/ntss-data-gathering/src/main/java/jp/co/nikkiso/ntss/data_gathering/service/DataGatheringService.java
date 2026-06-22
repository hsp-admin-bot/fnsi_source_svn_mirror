package jp.co.nikkiso.ntss.data_gathering.service;

import java.net.URI;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.data_gathering.entity.MntGatheringManage;
import jp.co.nikkiso.ntss.data_gathering.entity.MntMotionRecord;
import jp.co.nikkiso.ntss.data_gathering.entity.MstMachine;
import jp.co.nikkiso.ntss.data_gathering.service.util.NtssComIOService;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntClientConnectDao;
import jp.co.nikkiso.ntss.core.entity.MntClientConnect;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

/**
 * データ収集APIのServiceクラス
 */
@Service
public class DataGatheringService {

  @Autowired
  private MntClientConnectDao mntClientConnectDao;

  @Autowired
  private MntGatheringManageService gatheringManageSv;

  @Autowired
  private MstMachineService mstMachineSv;

  @Autowired
  private MntMotionRecordService motionRecordService;

  @Autowired
  private LogService logService;

  /**
   * 個別トランザクション用
   */
  @Autowired
  private PlatformTransactionManager ptm;

  @Autowired
  private Environment environment;

  @Autowired
  private NtssComIOService ntssComIOService;

  /**
   * 装置記録メッセージ(データ収集依頼失敗時)
   */
  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */        
  // private String machineRecordMessageRequestError = "【依頼失敗】装置データファイル収集";
  private static final String MACHINE_RECORD_MESSAGE_REQUEST_ERROR = "【依頼失敗】装置データファイル収集";
  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * 受信データ(全情報)
   *
   */
  public enum ContentData {
    GATHERING_MANAGE_NO, DEVICE_EDGE_NO, DEVICE_EDGE_STATUS, MACHINE_INFO, RECEPT_DATA_CNT, // 項目数
  }

  /**
   * データ収集（デバイスエッジ）ステータス
   *
   */
  public enum GatheringStatus {
    /*** 一部異常(-2) */
    PART_ERROR(-2),
    /*** 異常(-1) */
    ERROR(-1),
    /*** 依頼中(0) */
    DURING_REQUEST(0),
    /*** 処理中(1) */
    PROCESSING(1),
    /*** 転送完了(2) */
    TRANSFER_COMPLETION(2);
    /*** 項目数 */

    private final int value;

    private GatheringStatus(int value) {
      this.value = value;
    }

    public int Ordinal() {
      return this.value;
    }

    public String OrdinalString() {
      return String.valueOf(this.value);
    }
  }

  /**
   * Topic、Payload格納用クラス
   *
   */
  public static class PublishInfo {
    public String Topic;
    public String Payload;
    public int CommandResult = 999;
    public boolean Result = false;
  }

  /**
   * Json文字列変換用関数の引数に渡すリスト用クラス
   *
   */
  private static class GatheringInfo {
    public int deviceEdgeNo;
    public String machineNo;
  }

  /**
   * Json文字列作成用クラス(DB登録用)
   *
   */
  private static class GatheringInfoMachine {
    public String machine_no;
    public String machine_err_cd;
  }

  /**
   * Json文字列作成用クラス(DB登録用)
   *
   */
  private static class GatheringInfoEdge {
    public int device_edge_no;
    public int device_edge_status;
    public List<GatheringInfoMachine> machine_info;
  }

  /**
   * topicの共通部分
   */
  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */  
  // private String _topicBase = "NTSS/GATHERING";
  private static final String TOPIC_BASE = "NTSS/GATHERING";
  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */  

  /**
   * 受け取った情報の格納用クラス
   */
  public static class GatheringTarget {
    /**
     * 施設コード
     */
    String facilityCd;

    /**
     * 装置情報(文字列の値は、[デバイスエッジ番号] + '_' + [型式コード] + '_' + [通信フォーマット] + '_' + [製造番号])
     */
    List<String> machineNo;

    /**
     * 全装置かどうかのフラグ(true:全装置)
     */
    boolean isAll = false;

    /**
     * 再送対象のデータ収集管理番号
     */
    Long retryManageNo;

    /**
     * 再送時の装置が、「失敗した装置のみ」or「成功含め全ての装置」のどちらかのフラグ(true:成功含め全て(マスタではなく再送対象元の装置に限る)、false:失敗のみ)
     */
    boolean isRetryAll;

    /**
     * 操作情報(0：自動収集、1：手動収集、2：失敗時の再要求)
     */
    Integer opeInfo;

    /**
     * 利用者ID
     */
    String userId;

    /**
     * 施設コードGetter
     */
    public String getFacilityCd() {
      return this.facilityCd;
    }

    /**
     * 施設コードSetter
     */
    public void setFacilityCd(String facilityCd) {
      this.facilityCd = facilityCd;
    }

    /**
     * 装置情報Getter(文字列の値は、[デバイスエッジ番号] + '_' + [型式コード] + '_' + [通信フォーマット] + '_' +
     * [製造番号])
     */
    public List<String> getMachineNo() {
      return this.machineNo;
    }

    /**
     * 装置情報Setter(文字列の値は、[デバイスエッジ番号] + '_' + [型式コード] + '_' + [通信フォーマット] + '_' +
     * [製造番号])
     */
    public void setMachineNo(List<String> machineNo) {
      this.machineNo = machineNo;
    }

    /**
     * 全装置かどうかのフラグGetter(true:全装置)
     */
    public boolean getIsAll() {
      return this.isAll;
    }

    /**
     * 全装置かどうかのフラグSetter(true:全装置)
     */
    public void setIsAllCd(boolean isAll) {
      this.isAll = isAll;
    }

    /**
     * 再送対象のデータ収集管理番号Getter
     */
    public Long getRetryManageNo() {
      return this.retryManageNo;
    }

    /**
     * 再送対象のデータ収集管理番号Setter
     */
    public void setRetryManageNo(Long retryManageNo) {
      this.retryManageNo = retryManageNo;
    }

    /**
     * 再送対象の装置が、成功を含めた装置かどうかのフラグGetter(true:成功含め全て(マスタではなく再送対象元の装置に限る)、false:失敗のみ)
     */
    public boolean getIsRetryAll() {
      return this.isRetryAll;
    }

    /**
     * 再送対象の装置が、成功を含めた装置かどうかのフラグSetter(true:成功含め全て(マスタではなく再送対象元の装置に限る)、false:失敗のみ)
     */
    public void setIsRetryAll(boolean isRetryAll) {
      this.isRetryAll = isRetryAll;
    }

    /**
     * 操作情報Getter
     */
    public Integer getOpeInfo() {
      return this.opeInfo;
    }

    /**
     * 操作情報Setter
     */
    public void setOpeInfo(Integer opeInfo) {
      this.opeInfo = opeInfo;
    }

    /**
     * 利用者ID Getter
     */
    public String getUserId() {
      return this.userId;
    }

    /**
     * 利用者ID Setter
     */
    public void setUserId(String userId) {
      this.userId = userId;
    }
  }

  /**
   * 受け取った各情報のバイト数チェック用定義
   *
   */
  public class CheckRequestByteNum {
    /* 以下、データ収集情報(content)用 */

    /**
     * 施設コードのバイト数
     */
    public static final int FacilityCdByteNum = 6;

    /**
     * デバイスエッジ番号のバイト数
     */
    public static final int DeviceEdgeNoByteNum = 2;

    /**
     * 型式コードのバイト数
     */
    public static final int MachineTypeCdByteNum = 3;

    /**
     * 通信フォーマットのバイト数
     */
    public static final int ComFormatCdByteNum = 1;

    /**
     * 製造番号のバイト数
     */
    public static final int MachineSerialByteNum = 8;

    /**
     * 利用者IDのバイト数
     */
    public static final int UserIdByteNum = 12;

    /**
     * バイト数合計
     */
    public static final int TotalNum = (FacilityCdByteNum + DeviceEdgeNoByteNum + MachineTypeCdByteNum
        + ComFormatCdByteNum + MachineSerialByteNum + UserIdByteNum);


    /* 以下、アップロードファイル名情報(filename)用 */
    /**
     * ファイル数のバイト数
     */
    public static final int FileNumByteNum = 3;
  }

  /**
   * ファイルアップロードの結果格納クラス.
   */
  private static class UploadFileResult {
    public boolean Result = false;
    public String Filename = "";
  }

  /**
   * データ収集メイン処理
   *
   * @param target
   * @param type
   * @param targetData
   * @return
   */
  public PublishInfo Gathering(GatheringTarget targetData) {

	 EventLogMessage eventLogMessage = new EventLogMessage();

    // 登録・更新日時
    Timestamp nowDate = new Timestamp(System.currentTimeMillis());

    // 個別トランザクション用
    DefaultTransactionDefinition dfd = new DefaultTransactionDefinition();
    TransactionStatus ts;

    // 戻り値用のTopic、Payload格納用クラス
    PublishInfo publishInfo = new PublishInfo();

    // 収集情報が無い場合はここで終了
    if (null == targetData) {

	  eventLogMessage.setLogMessage("データ収集API：引数[targetData]がnull");
	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return publishInfo;
    }

    // Payload格納用
    String payload = "";

    // 操作情報の取得
    Integer procOpeInfo = targetData.getOpeInfo();

    // 収集対象情報の取得
    String targetFacilityCd = targetData.getFacilityCd();

    // 利用者ID
    Long userId = null;
    String _userId = targetData.getUserId();
    if (false == StringUtils.isEmpty(_userId) && true == isNumber(_userId.trim())) {
      userId = Long.parseLong(_userId.trim());
    }

    // 対象装置情報格納用リスト
    List<GatheringInfo> targetMachineInfo = new ArrayList<>();

    // データ収集管理番号のMAX＋1取得
    MntGatheringManage maxManageNo = this.gatheringManageSv.findMaxNo();
    if (null == maxManageNo) {
      eventLogMessage.setLogMessage("データ収集API：データ収集管理テーブルからデータ収集管理番号(新規発行)の取得に失敗");
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      eventLogMessage.setUserId(targetData.getUserId());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return publishInfo;
    }

    eventLogMessage.setLogMessage("データ収集API：新規発行したデータ収集管理番号[" + maxManageNo.getGatheringManageNo() + "]");
    eventLogMessage.setFacilityCd(targetData.getFacilityCd());
    eventLogMessage.setUserId(targetData.getUserId());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // 再依頼時の親となるデータ収集管理番号
    Long parentManageNo = null;

    // Payloadの先頭は管理番号
    payload = maxManageNo.getGatheringManageNo() + "_";

    // 操作情報により分岐

    switch (procOpeInfo) {
      case 0:
        // 新規要求(自動)
        eventLogMessage.setLogMessage("データ収集API：新規要求(自動)処理開始");
        eventLogMessage.setFacilityCd(targetData.getFacilityCd());
        eventLogMessage.setUserId(targetData.getUserId());
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

        // 装置マスタ情報取得
        List<MstMachine> lstMachine = this.mstMachineSv.findById(null, null, targetFacilityCd, -1);
        if (null == lstMachine) {
          eventLogMessage.setLogMessage("データ収集API：装置マスタの取得に失敗　施設コード[" + targetFacilityCd + "]");
          eventLogMessage.setFacilityCd(targetData.getFacilityCd());
          eventLogMessage.setUserId(targetData.getUserId());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return publishInfo;
        }
        if (0 == lstMachine.size()) {
          // ログ
          eventLogMessage.setLogMessage("データ収集API：装置マスタの取得件数0件　施設コード[" + targetFacilityCd + "]");
          eventLogMessage.setFacilityCd(targetData.getFacilityCd());
          eventLogMessage.setUserId(targetData.getUserId());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          // 装置マスタの取得件数が0件の場合、データ収集管理テーブルへその旨を登録する

          // トランザクション開始
          ts = ptm.getTransaction(dfd);

          // Insert処理
          boolean retInsert = InsertMntGatheringManage(ts, maxManageNo.getGatheringManageNo(), targetFacilityCd, 9, null,
              procOpeInfo, parentManageNo, userId, nowDate, nowDate);
          if (false == retInsert) {
            // ロールバック
            ptm.rollback(ts);
          } else {
            // コミット
            ptm.commit(ts);
          }

          // 戻り値としてはtrueを返す
          publishInfo.Result = true;
          return publishInfo;
        }

        // 収集対象情報の設定
        for (int i = 0; i < lstMachine.size(); i++) {
          MstMachine machine = lstMachine.get(i);

          GatheringInfo info = new GatheringInfo();

          // デバイスエッジ番号
          info.deviceEdgeNo = machine.getDeviceEdgeNo();

          // 装置情報([型式コード][通信フォーマット][製造番号] ※製造番号は8桁になるまで右側に半角スペース)
          // info.machineNo = machine.getMachineTypeCd() + machine.getComFormatCd() +
          // String.format("%-8s", machine.getMachineSerial());

          try {
            // 型式コード
            String typeCd = StringPadding(machine.getMachineTypeCd(), 3);
            // 通信フォーマット
            String comFormatCd = StringPadding(machine.getComFormatCd(), 1);
            // 製造番号
            String serial = StringPadding(machine.getMachineSerial(), 8);

            // 装置情報([型式コード][通信フォーマット][製造番号])
            info.machineNo = typeCd + comFormatCd + serial;
          } catch (Exception e) {
            eventLogMessage.setLogMessage("データ収集API：装置情報のbyte精査処理で異常　" + "型式コード[" + machine.getMachineTypeCd() + "]、" + "通信フォーマット["
                    + machine.getComFormatCd() + "]、" + "製造番号[" + machine.getMachineSerial() + "]、" + "施設コード["
                    + targetFacilityCd + "]");
            eventLogMessage.setFacilityCd(targetData.getFacilityCd());
            eventLogMessage.setUserId(targetData.getUserId());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            return publishInfo;
          }

          // リストに格納
          targetMachineInfo.add(info);
        }

        // ※対象は全装置なのでPayloadはそのまま([管理番号] + '_')

        break;

      case 1:
        // 新規要求(手動)
        eventLogMessage.setLogMessage("データ収集API：新規要求(手動)処理開始");
        eventLogMessage.setFacilityCd(targetData.getFacilityCd());
        eventLogMessage.setUserId(targetData.getUserId());
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

        // 収集対象情報の設定
        boolean targetIsAll = targetData.getIsAll();
        for (int i = 0; i < targetData.getMachineNo().size(); i++) {
          GatheringInfo info = new GatheringInfo();

          // 装置情報を区切り文字('_')で分割
          String[] machineInfo = targetData.getMachineNo().get(i).split("_");

          // デバイスエッジ番号
          info.deviceEdgeNo = Integer.parseInt(machineInfo[0]);

          // // 装置情報([型式コード][通信フォーマット][製造番号] ※製造番号は8桁になるまで右側に半角スペース)
          // info.machineNo = machineInfo[1] + machineInfo[2] + String.format("%-8s",
          // machineInfo[3]);

          try {
            // 型式コード
            String typeCd = machineInfo[1];
            // 通信フォーマット
            String comFormatCd = StringPadding(machineInfo[2], 1);
            // 製造番号
            String serial = StringPadding(machineInfo[3], 8);

            // 装置情報([型式コード][通信フォーマット][製造番号])
            info.machineNo = typeCd + comFormatCd + serial;
          } catch (Exception e) {
            eventLogMessage.setLogMessage( "データ収集API：装置情報のbyte精査処理で異常　" + "型式コード[" + machineInfo[1] + "]、" + "通信フォーマット[" + machineInfo[2] + "]、"
                    + "製造番号[" + machineInfo[3] + "]、" + "施設コード[" + targetFacilityCd + "]");
            eventLogMessage.setFacilityCd(targetData.getFacilityCd());
            eventLogMessage.setUserId(targetData.getUserId());
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            return publishInfo;
          }

          // リストに格納
          targetMachineInfo.add(info);
        }

        if (false == targetIsAll) {
          // 全装置ではない場合、装置情報分でPayloadの作成
          for (int i = 0; i < targetMachineInfo.size(); i++) {
            // 各装置の情報をPayloadに追加
            payload += targetMachineInfo.get(i).machineNo;
          }
        }

        break;

      case 2:
        // 再送要求
        eventLogMessage.setLogMessage("データ収集API：再要求処理開始");
        eventLogMessage.setFacilityCd(targetData.getFacilityCd());
        eventLogMessage.setUserId(targetData.getUserId());
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

        // 再送対象となるデータ収集管理番号の取得
        parentManageNo = targetData.getRetryManageNo();
        if (null == parentManageNo) {
          eventLogMessage.setLogMessage("データ収集API：再送対象となるデータ収集管理番号がnull");
          eventLogMessage.setFacilityCd(targetData.getFacilityCd());
          eventLogMessage.setUserId(targetData.getUserId());
          logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return publishInfo;
        }

        // データ収集管理情報の取得
        List<MntGatheringManage> retryData = this.gatheringManageSv.findById(parentManageNo);
        if (null == retryData) {
          eventLogMessage.setLogMessage("データ収集API：再送対象となるデータ収集管理番号に紐付くデータ収集管理の取得に失敗　データ収集管理番号[" + parentManageNo + "]");
          eventLogMessage.setFacilityCd(targetData.getFacilityCd());
          eventLogMessage.setUserId(targetData.getUserId());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return publishInfo;
        }

        // 取得結果が0件
        if (0 == retryData.size()) {
          eventLogMessage.setLogMessage( "データ収集API：再送対象となるデータ収集管理番号に紐付くデータ収集管理情報が存在しない　データ収集管理番号[" + parentManageNo + "]");
          eventLogMessage.setFacilityCd(targetData.getFacilityCd());
          eventLogMessage.setUserId(targetData.getUserId());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return publishInfo;
        }

        // 取得情報から施設コードを取得
        targetFacilityCd = retryData.get(0).getFacilityCd();

        // 取得情報から「データ収集情報(gathering_info)」に登録するデータに抽出
        String json = retryData.get(0).getGatheringInfo();
        if (true == StringUtils.isEmpty(json)) {

          eventLogMessage.setLogMessage("データ収集API：取得した再送対象レコードのデータ収集情報(gathering_info)が空の為、再送不可　データ収集管理番号[" + parentManageNo + "]");
          eventLogMessage.setFacilityCd(targetData.getFacilityCd());
          eventLogMessage.setUserId(targetData.getUserId());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return publishInfo;
        }

        // Json文字列をデータ収集情報クラスへ変換
        ObjectMapper mapper = new ObjectMapper();
        List<GatheringInfoEdge> jsonList;
        try {
          jsonList = Arrays.asList(mapper.readValue(json, GatheringInfoEdge[].class));
        } catch (Exception e) {

          eventLogMessage.setLogMessage("データ収集API：REST APIへ渡す情報(データ収集情報(gathering_info))の変換処理に失敗　データ収集管理番号[" + parentManageNo + "]");
          eventLogMessage.setFacilityCd(targetData.getFacilityCd());
          eventLogMessage.setUserId(targetData.getUserId());
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return publishInfo;
        }

        // データ収集情報から再送対象装置に絞込み
        for (int i = 0; i < jsonList.size(); i++) {
          GatheringInfoEdge edge = jsonList.get(i);

          // 登録用データ格納用変数
          GatheringInfo info = new GatheringInfo();

          for (int j = 0; j < edge.machine_info.size(); j++) {
            GatheringInfoMachine machine = edge.machine_info.get(j);
            if (false == targetData.getIsRetryAll() && true == "00".equals(machine.machine_err_cd)) {
              // エラーではない装置に対しては再送要求をしない
              // ※後で成功含めた再送要求処理も実装予定
              continue;
            }

            // デバイスエッジ番号
            info.deviceEdgeNo = edge.device_edge_no;

            // 装置情報([型式コード][通信フォーマット][製造番号]
            info.machineNo = machine.machine_no;

            // リストに格納
            targetMachineInfo.add(info);

            // Payloadも合わせて作成
            payload += machine.machine_no;
          }
        }

        break;

      default:
        // その他

        // エラー扱い
        return publishInfo;
    }

    // Topic、Payloadを戻り値用に格納
    publishInfo.Topic = this.TOPIC_BASE + "/" + targetFacilityCd;
    publishInfo.Payload = payload;

    // トランザクション開始
    ts = ptm.getTransaction(dfd);

    // Insert処理
    boolean retInsert = InsertMntGatheringManage(ts, maxManageNo.getGatheringManageNo(), targetFacilityCd, 0,
        this.MakeJson(targetMachineInfo), procOpeInfo, parentManageNo, userId, nowDate, nowDate);
    if (false == retInsert) {
      // ロールバック
      ptm.rollback(ts);
      return publishInfo;
    }

    // #8470 2023.03.24 mod 通知先をmnt_client_connectから取得した最初のIPアドレスとする TDC米沢 start
    //publishInfo.Result = ntssComIOService.SendToMessage(this.GetProperty("commApi.uri"), targetFacilityCd, null,
    //    publishInfo.Topic, publishInfo.Payload);
    String targetURL = this.GetProperty("commApi.uri");

    // mnt_client_connect から対象の施設のデバイスエッジが接続されている ntss-clietn-comm サーバーのIPアドレスを取得
    List<MntClientConnect> mntClientConnectList = this.mntClientConnectDao.selectByServerType(targetFacilityCd, 0);
    if (0 < mntClientConnectList.size())
      // URLの「localhost」を先頭のIPアドレスで書き換え
      targetURL = targetURL.replace("localhost", mntClientConnectList.get(0).getIpAddress());

    // DE通知API呼び出し
    publishInfo.Result = ntssComIOService.SendToMessage(targetURL, targetFacilityCd, null,
        publishInfo.Topic, publishInfo.Payload);
    // #8470 2023.03.24 mod 通知先をmnt_client_connectから取得した最初のIPアドレスとする TDC米沢 end
    if (false == publishInfo.Result) {
      // ログ

      eventLogMessage.setLogMessage("データ収集API：DE通知API呼び出しに失敗　データ収集管理番号[" + maxManageNo.getGatheringManageNo() + "]");
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      eventLogMessage.setUserId(targetData.getUserId());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);

      // DE通知API呼び出しエラー時、データ収集管理テーブルへその旨を登録する

      // 一旦ロールバックし、エラーとして登録し直す
      ptm.rollback(ts);

      // トランザクション開始
      ts = ptm.getTransaction(dfd);

      // データ収集管理Insert処理
      retInsert = InsertMntGatheringManage(ts, maxManageNo.getGatheringManageNo(), targetFacilityCd, -9,
          this.MakeJson(targetMachineInfo), procOpeInfo, parentManageNo, userId, nowDate, nowDate);
      if (false == retInsert) {
        // ロールバック
        ptm.rollback(ts);
        return publishInfo;
      }

      for (int i = 0; i < targetMachineInfo.size(); i++) {
        // デバイスエッジ番号
        int deviceEdgeNo = targetMachineInfo.get(i).deviceEdgeNo;

        // 装置情報([型式][通信フォーマット][製造番号])
        String machineNo = targetMachineInfo.get(i).machineNo;

        int sIndex = 0;

        // 型式コード
        String typeCd = machineNo.substring(sIndex, CheckRequestByteNum.MachineTypeCdByteNum);
        sIndex += CheckRequestByteNum.MachineTypeCdByteNum;
        // 通信フォーマット
        String comFormatCd = machineNo.substring(sIndex, sIndex + CheckRequestByteNum.ComFormatCdByteNum);
        sIndex += CheckRequestByteNum.ComFormatCdByteNum;
        // 製造番号
        String serial = machineNo.substring(sIndex, sIndex + CheckRequestByteNum.MachineSerialByteNum);

        // 装置動作記録テーブルInsert処理
        retInsert = InsertMntMotionRecord(ts, nowDate, targetFacilityCd, deviceEdgeNo, typeCd, serial, comFormatCd, 6,
            maxManageNo.getGatheringManageNo(), this.MACHINE_RECORD_MESSAGE_REQUEST_ERROR, null, null, userId, nowDate,
            nowDate);
        if (false == retInsert) {
          // ロールバック
          ptm.rollback(ts);
          return publishInfo;
        }
      }

      // コミット
      ptm.commit(ts);

      return publishInfo;
    }

    // コミット
    ptm.commit(ts);
    eventLogMessage.setLogMessage("データ収集API：Insert成功(コミット)　データ収集管理番号[" + maxManageNo.getGatheringManageNo() + "]");
    eventLogMessage.setFacilityCd(targetData.getFacilityCd());
    eventLogMessage.setUserId(targetData.getUserId());
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // 処理成功
    publishInfo.Result = true;

    return publishInfo;
  }

  /**
   * データ収集受信処理
   *
   * @param strContent
   * @param strFilepath
   * @param strFilename
   * @return true：正常、false：異常
   */
  public boolean GatheringResponse(String strContent, String strFilepath, String strFilename) {
    // 受信データ(content)を分解([データ収集管理番号]_[デバイスエッジ番号]_[デバイスエッジステータス]_{[型式コード][通信フォーマット][製造番号][装置エラーコード]})
    String[] listContentData = strContent.split("_");

    // 受信データ(filename)を分解([型式コード][通信フォーマット][製造番号][ファイル数][ファイル名][LF]・・・(ファイル数分))
    String[] listFilenameData = {};
    if (false == StringUtils.isEmpty(strFilename)) {
      listFilenameData = strFilename.split("\n");
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    // 受信データパラメータチェック（「データ収集管理番号」「デバイスエッジ番号」「デバイスエッジステータス」は必須）
    if ((ContentData.RECEPT_DATA_CNT.ordinal() - 1) > listContentData.length) {

      eventLogMessage.setLogMessage("データ収集API：受信データ(項目数)が異常　受信データ[" + strContent + "]、項目数[" + listContentData.length + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    // データ収集管理番号取得
    String strGatheringManageNo = listContentData[ContentData.GATHERING_MANAGE_NO.ordinal()];
    if (false == isNumber(strGatheringManageNo)) {

      eventLogMessage.setLogMessage("データ収集API：受信データ(データ収集管理番号)が異常　受信データ[" + strContent + "]、データ収集管理番号[" + strGatheringManageNo + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }
    int iGatheringManageNo = Integer.parseInt(strGatheringManageNo);

    // デバイスエッジ番号取得
    String strDeviceEdgeNo = listContentData[ContentData.DEVICE_EDGE_NO.ordinal()];
    if (false == isNumber(strDeviceEdgeNo)) {

      eventLogMessage.setLogMessage("データ収集API：受信データ(デバイスエッジ番号)が異常　受信データ[" + strContent + "]、デバイスエッジ番号[" + strDeviceEdgeNo + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }
    int iDeviceEdgeNo = Integer.parseInt(strDeviceEdgeNo);

    // デバイスエッジステータス取得
    String strDeviceEdgeStatus = listContentData[ContentData.DEVICE_EDGE_STATUS.ordinal()];
    if (false == isNumber(strDeviceEdgeStatus)) {

      eventLogMessage.setLogMessage("データ収集API：受信データ(デバイスエッジステータス)が異常　受信データ[" + strContent + "]、デバイスエッジステータス[" + strDeviceEdgeStatus + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }
    int iDeviceEdgeStatus = Integer.parseInt(strDeviceEdgeStatus);

    // 装置情報取得
    ArrayList<GatheringInfoMachine> listMachineInfo = new ArrayList<GatheringInfoMachine>();
    if ((ContentData.RECEPT_DATA_CNT.ordinal()) <= listContentData.length) {
      int iMachineInfoSize = 14;
      int iMachineNoSize = 12;
      String strMachineInfo = listContentData[ContentData.MACHINE_INFO.ordinal()];

      // 装置情報を分解
      while ("".compareTo(strMachineInfo) != 0) {
        // 1装置分(14バイト)のデータを抽出
        GatheringInfoMachine listTmp = new GatheringInfoMachine();
        if (iMachineInfoSize < strMachineInfo.length()) {
          String strTmp = strMachineInfo.substring(0, iMachineInfoSize);
          listTmp.machine_no = strTmp.substring(0, iMachineNoSize);
          listTmp.machine_err_cd = strTmp.substring(iMachineNoSize);
          listMachineInfo.add(listTmp);

          // 残りの装置情報を格納
          strMachineInfo = strMachineInfo.substring(iMachineInfoSize);
        } else if (iMachineInfoSize == strMachineInfo.length()) {
          // 最後の1装置分(14バイト)
          listTmp.machine_no = strMachineInfo.substring(0, iMachineNoSize);
          listTmp.machine_err_cd = strMachineInfo.substring(iMachineNoSize);
          listMachineInfo.add(listTmp);
          strMachineInfo = "";
        } else {
          // 異常データ

          eventLogMessage.setLogMessage( "データ収集API：受信データ(装置情報)が異常　受信データ[" + strContent + "]、装置情報[" + strMachineInfo + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return false;
        }
      }
    }

    // データ収集管理情報取得
    List<MntGatheringManage> listGatheringManage = this.gatheringManageSv.findById(iGatheringManageNo);
    if (null == listGatheringManage) {

      eventLogMessage.setLogMessage("データ収集API：データ収集管理の取得に失敗　データ収集管理番号[" + iGatheringManageNo + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }
    if (1 != listGatheringManage.size()) {

      eventLogMessage.setLogMessage( "データ収集API：データ収集管理の取得件数が異常　データ収集管理番号[" + iGatheringManageNo + "]、取得件数[" + listGatheringManage.size() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    // 利用者ID
    Long userId = listGatheringManage.get(0).getUserId();

    // Json文字列をデータ収集情報クラスへ変換
    ObjectMapper mapper = new ObjectMapper();
    String json = listGatheringManage.get(0).getGatheringInfo();
    GatheringInfoEdge[] arrayJson;
    List<GatheringInfoEdge> listJson;
    try {
      arrayJson = mapper.readValue(json, GatheringInfoEdge[].class);
      listJson = Arrays.asList(arrayJson);
    } catch (Exception e) {

      eventLogMessage.setLogMessage("データ収集API：データ収集情報(gathering_info)のJson形式への変換処理に失敗　データ収集管理番号[" + iGatheringManageNo + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    // 対象デバイスエッジ情報を抽出
    List<GatheringInfoEdge> listTargetGatheringManage = listJson.stream()
        .filter(ele -> ele.device_edge_no == iDeviceEdgeNo).collect(Collectors.toList());
    if (1 != listTargetGatheringManage.size()) {

      eventLogMessage.setLogMessage("データ収集API：対象デバイスエッジ情報の取得件数が異常　データ収集管理番号[" + iGatheringManageNo
              + "]、デバイスエッジ番号[" + iDeviceEdgeNo + "]、取得件数[" + listTargetGatheringManage.size() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    // 対象デバイスエッジ情報に受信データを書き込み
    listTargetGatheringManage.get(0).device_edge_status = iDeviceEdgeStatus;
    for (int i = 0; i < listMachineInfo.size(); i++) {
      // 対象デバイスエッジ情報内の対象装置情報を抽出
      String strMachineNo = listMachineInfo.get(i).machine_no;
      List<GatheringInfoMachine> listGatheringInfoMachine = listTargetGatheringManage.get(0).machine_info.stream()
          .filter(ele -> true == ele.machine_no.equals(strMachineNo)).collect(Collectors.toList());
      if (1 != listGatheringInfoMachine.size()) {
        if (0 == listGatheringInfoMachine.size()) {

          eventLogMessage.setLogMessage("データ収集API：データ収集管理.データ収集情報内に受信した装置情報が存在しない　データ収集管理番号["
                  + iGatheringManageNo + "]、装置情報[" + strMachineNo + "]");
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI,null);

          // データ収集情報内に受信した装置情報が存在しない場合、データ収集情報として追加する
          GatheringInfoMachine addMachineInfo = new GatheringInfoMachine();
          addMachineInfo.machine_no = listMachineInfo.get(i).machine_no;
          addMachineInfo.machine_err_cd = listMachineInfo.get(i).machine_err_cd;
          listTargetGatheringManage.get(0).machine_info.add(addMachineInfo);
        } else {

          eventLogMessage.setLogMessage("データ収集API：データ収集管理.データ収集情報内に受信した装置情報が複数存在する　データ収集管理番号["
                  + iGatheringManageNo + "]、装置情報[" + strMachineNo + "]、件数[" + listGatheringInfoMachine.size() + "]");
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        }
      } else {
        // 対象装置情報に受信データを書き込み
        listGatheringInfoMachine.get(0).machine_err_cd = listMachineInfo.get(i).machine_err_cd;
      }
    }

    // データ収集ステータス更新確認
    GatheringStatus status = GatheringStatus.PROCESSING;

    // 受信データのデバイスエッジステータスが「処理中」でなければ処理実施
    if (false == GatheringStatus.PROCESSING.OrdinalString().equals(strDeviceEdgeStatus)) {
      int iErrorCnt = 0;
      int iPartErrorCnt = 0;
      int iProcessingCnt = 0;
      for (int i = 0; i < listJson.size(); i++) {
        if (GatheringStatus.ERROR.Ordinal() == listJson.get(i).device_edge_status) {
          // デバイスエッジステータスが「異常」の場合、エラー件数をカウント
          iErrorCnt++;
        } else if (GatheringStatus.PART_ERROR.Ordinal() == listJson.get(i).device_edge_status) {
          // デバイスエッジステータスが「一部異常」の場合、一部エラー件数をカウント
          iPartErrorCnt++;
        } else if (GatheringStatus.PROCESSING.Ordinal() == listJson.get(i).device_edge_status) {
          // デバイスエッジステータスが「処理中」の場合、処理中件数カウント
          iProcessingCnt++;
        }
      }

      if (iErrorCnt == listJson.size()) {
        // 全デバイスエッジが「異常あり」の場合、ステータスは「異常」
        status = GatheringStatus.ERROR;
      } else if ((0 != iErrorCnt) || (0 != iPartErrorCnt)) {
        // 全デバイスエッジうち「一部に異常あり」、ステータスは「一部異常」
        status = GatheringStatus.PART_ERROR;
      } else if (0 != iProcessingCnt) {
        // 全デバイスエッジで「異常なし」かつ「処理中あり」の場合、ステータスは「処理中」
        status = GatheringStatus.PROCESSING;
      } else {
        // 全デバイスエッジで「異常なし」かつ「処理中なし」の場合、ステータスは「転送完了」
        status = GatheringStatus.TRANSFER_COMPLETION;
      }
    }

    // DB登録用データ作成(データ収集管理テーブル)
    MntGatheringManage updateDataGatheringManage = new MntGatheringManage();

    // 更新日時
    Timestamp upDate = new Timestamp(System.currentTimeMillis());

    // データ収集管理番号
    updateDataGatheringManage.setGatheringManageNo(iGatheringManageNo);
    // データ収集ステータス
    updateDataGatheringManage.setGatheringStatus(status.Ordinal());
    // 利用者ID
    updateDataGatheringManage.setUserId(userId);

    // データ収集情報をJson文字列形式へ変換
    mapper = new ObjectMapper();
    json = null;
    try {
      json = mapper.writeValueAsString(listJson);
    } catch (Exception e) {

      eventLogMessage.setLogMessage("データ収集API：データ収集情報(gathering_info)登録用にJson形式への変換処理に失敗　データ収集管理番号["
              + strGatheringManageNo + "]　" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }
    updateDataGatheringManage.setGatheringInfo(json);

    // 更新日時
    updateDataGatheringManage.setUpDate(upDate);

    // Update情報をログ出力

    eventLogMessage.setLogMessage("データ収集API：Update情報　" + updateDataGatheringManage.toString());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // DB登録用データ作成(装置動作記録テーブル(mnt_motion_record))
    List<MntMotionRecord> listUpdateDataMotionRecord = new ArrayList<>();
    if (GatheringStatus.DURING_REQUEST != status && GatheringStatus.PROCESSING != status) {
      // 施設コード
      String facilityCd = listGatheringManage.get(0).getFacilityCd();
      // データ収集管理番号
      Long gatheringManageNo = listGatheringManage.get(0).getGatheringManageNo();

      // 対象装置のFTP収集(is_ftp)が「0：FTP収集しない」 の場合、mnt_motion_recordへレコードは登録しない
      // 装置マスタ情報取得
      List<MstMachine> lstMachine = this.mstMachineSv.findById(null, null, facilityCd, -1);
      if (null == lstMachine) {

        eventLogMessage.setLogMessage("データ収集API：装置マスタの取得に失敗　施設コード[" + facilityCd + "]");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
      }

      // アップロードファイル格納先
      // ・引数[strFilepath]に値が設定されている場合はその値を登録
      // ・引数[strFilepath]に値が設定されていない場合は「S3バケット名+施設コード」を登録
      String uploadPath = strFilepath;
      if (true == StringUtils.isEmpty(uploadPath)) {
        uploadPath = this.GetProperty("upload.s3Bucket") + "/" + facilityCd;
      }

      for (int i = 0; i < listJson.size(); i++) {
        // デバイスエッジ番号
        int deviceEdgeNo = listJson.get(i).device_edge_no;
        // データ種別(6：データ収集記録 固定)
        int dataType = 6;

        // データ収集情報分(装置分)ループ
        for (int j = 0; j < listJson.get(i).machine_info.size(); j++) {
          // データ収集情報分解用
          int sIndex = 0;

          // データ収集情報を分解して各情報を取得
          // [型式コード][通信フォーマット][製造番号]
          String machineNo = listJson.get(i).machine_info.get(j).machine_no;
          String machineTypeCd = machineNo.substring(sIndex, sIndex + CheckRequestByteNum.MachineTypeCdByteNum);
          sIndex = sIndex + CheckRequestByteNum.MachineTypeCdByteNum;
          String comFormatCd = machineNo.substring(sIndex, sIndex + CheckRequestByteNum.ComFormatCdByteNum);
          sIndex = sIndex + CheckRequestByteNum.ComFormatCdByteNum;
          String machineSerial = machineNo.substring(sIndex, sIndex + CheckRequestByteNum.MachineSerialByteNum);

          // 対象装置のFTP収集(is_ftp)が「1：FTP収集する」かどうかを確認
          // 「1：FTP収集する」ではない場合、mnt_motion_recordへは登録しない
          long cnt = lstMachine.stream().filter(ele -> ele.getMachineTypeCd().trim().equals(machineTypeCd.trim())
              && ele.getMachineSerial().trim().equals(machineSerial.trim()) && "1".equals(ele.getIsFtp())).count();
          if (0 == cnt) {
            // 「1：FTP収集する」の装置ではない為、次へ

            eventLogMessage.setLogMessage("データ収集API：対象装置のFTP収集(is_ftp)が「1：FTP収集する」ではない為、装置動作記録テーブル(mnt_motion_record)へ登録しない　" + "施設コード["
                    + facilityCd + "]、" + "型式コード[" + machineTypeCd + "]、" + "製造番号[" + machineSerial + "]");
            eventLogMessage.setMachineTypeCd(machineTypeCd);
            eventLogMessage.setFacilityCd(facilityCd);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            continue;
          }

          // アップロードファイルの分割確認、結合、S3へ再アップロード処理
          UploadFileResult ret = ProcJoinFile(listFilenameData, machineNo, uploadPath);

          // 装置エラーコードより装置記録メッセージ
          // ※上記『アップロードファイルの分割確認、復元、S3へ再アップロード処理』で失敗した場合は【転送失敗】('05')とする
          String errCd = (false == ret.Result) ? "05" : listJson.get(i).machine_info.get(j).machine_err_cd;
          String machineRecordMessage = GetMachineRecordMessage(errCd);

          // // 装置エラーコードより装置記録メッセージ
          // String errCd = listJson.get(i).machine_info.get(j).machine_err_cd;
          // String machineRecordMessage = GetMachineRecordMessage(errCd);

          // 装置動作記録番号をシーケンスから取得
          // この戻り値を他情報の格納用として使用
          MntMotionRecord updateItem = this.motionRecordService.findMaxNo();

          // イベント発生日時
          updateItem.setEventRegDate(upDate);
          // 緊急発報ステータス(なし)
          // 施設コード
          updateItem.setFacilityCd(facilityCd);
          // デバイスエッジ番号
          updateItem.setDeviceEdgeNo(deviceEdgeNo);
          // 型式コード
          updateItem.setMachineTypeCd(machineTypeCd);
          // 製造番号
          updateItem.setMachineSerial(machineSerial);
          // 通信フォーマット
          updateItem.setComFormatCd(comFormatCd);
          // データ種別
          updateItem.setDataType(dataType);
          // 自己診断種別(なし)
          // データ収集管理番号
          updateItem.setGatheringManageNo(gatheringManageNo);
          // メール送信日時(なし)
          // メール本文(なし)
          // 装置記録コード(なし)
          // 装置記録メッセージ
          updateItem.setMachineRecordMessage(machineRecordMessage);
          // 内容
          String contentsJson = null;
          if (true == ret.Result && false == StringUtils.isEmpty(ret.Filename)) {
            contentsJson = "{\"filename\":\"" + ret.Filename + "\", \"path\":\"" + uploadPath + "\"}";
          }
          updateItem.setContents(contentsJson);
          // 装置記録補助データ(なし)
          // メールアドレス(なし)
          // 宛先名称(なし)
          // 備考(なし)
          // 対処
          updateItem.setIsCorrection(null);
          // 対処者
          updateItem.setUserId(userId);
          // 登録日時
          updateItem.setRegDate(upDate);
          // 更新日時
          updateItem.setUpDate(upDate);

          // リストに格納
          listUpdateDataMotionRecord.add(updateItem);
        }
      }
    }

    // DB登録用データをDBへ登録
    // 個別トランザクション用
    DefaultTransactionDefinition dfd = new DefaultTransactionDefinition();
    TransactionStatus ts = ptm.getTransaction(dfd);
    try {
      // データ収集管理テーブル(Update)
      int ret = this.gatheringManageSv.update(updateDataGatheringManage);
      if (ret < 1) {
        // ロールバック
        ptm.rollback(ts);

        eventLogMessage.setLogMessage("データ収集API：データ収集管理へのUpdateに失敗　データ収集管理番号[" + iGatheringManageNo + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
      }
    } catch (Exception e) {
      // ロールバック
      ptm.rollback(ts);
      eventLogMessage.setLogMessage("データ収集API：データ収集管理へのUpdateで例外発生　データ収集管理番号[" + iGatheringManageNo + "]　" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    for (int i = 0; i < listUpdateDataMotionRecord.size(); i++) {
      try {
        // 装置動作記録テーブル(Insert)
        int ret = this.motionRecordService.insert(listUpdateDataMotionRecord.get(i));
        if (ret < 1) {
          // ロールバック
          ptm.rollback(ts);

          eventLogMessage.setLogMessage("データ収集API：装置動作記録へのInsertに失敗　装置動作記録番号[" + listUpdateDataMotionRecord.get(i).getMotionRecordNo() + "]");
      	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);

          return false;
        }
      } catch (Exception e) {
        // ロールバック
        ptm.rollback(ts);

        eventLogMessage.setLogMessage( "データ収集API：装置動作記録へのInsertで例外発生　装置動作記録番号[" + listUpdateDataMotionRecord.get(i) + "]　" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return false;
      }
    }

    // コミット
    ptm.commit(ts);

    eventLogMessage.setLogMessage("データ収集API：データ収集管理Update成功(コミット)　データ収集管理番号[" + iGatheringManageNo + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    if (0 < listUpdateDataMotionRecord.size()) {
      eventLogMessage.setLogMessage("データ収集API：装置動作記録Insert成功(コミット)　データ収集管理番号[" + iGatheringManageNo + "]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }

    return true;
  }

  /**
   * データ収集管理Insert処理
   *
   * @param ts
   * @param gatheringManageNo
   * @param facilityCd
   * @param gatheringStatus
   * @param gatheringInfo
   * @param opeInfo
   * @param parentManageNo
   * @param userId
   * @param regDate
   * @param upDate
   * @return
   */
  private boolean InsertMntGatheringManage(TransactionStatus ts, Long gatheringManageNo, String facilityCd,
      Integer gatheringStatus, String gatheringInfo, Integer opeInfo, Long parentManageNo, Long userId,
      Timestamp regDate, Timestamp upDate) {
    // Insert用データ作成
    MntGatheringManage insertData = new MntGatheringManage();
    insertData.setGatheringManageNo(gatheringManageNo);
    insertData.setGatheringStatus(gatheringStatus);
    insertData.setFacilityCd(facilityCd);
    insertData.setGatheringInfo(gatheringInfo);
    insertData.setOpeInfo(opeInfo);
    insertData.setParentManageNo(parentManageNo);
    insertData.setUserId(userId);
    insertData.setRegDate(regDate);
    insertData.setUpDate(upDate);

    EventLogMessage eventLogMessage = new EventLogMessage();
    // Insert情報をログ出力
    eventLogMessage.setLogMessage("データ収集API：Insert情報　" + insertData.toString());
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setUserId(String.valueOf(userId));
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // データ収集管理テーブルInsert
    int ret = this.gatheringManageSv.insert(insertData);
    if (ret < 1) {
      // エラー
      eventLogMessage.setLogMessage("データ収集API：データ収集管理へのInsertに失敗　データ収集管理番号[" + gatheringManageNo + "]");
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setUserId(String.valueOf(userId));
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    return true;
  }

  /**
   * 装置動作記録テーブルInsert処理
   *
   * @param ts
   * @param eventRegDate
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineTypeCd
   * @param machineSerial
   * @param comFormatCd
   * @param dataType
   * @param gatheringManageNo
   * @param machineRecordMessage
   * @param contents
   * @param isCorrection
   * @param userId
   * @param regDate
   * @param upDate
   * @return
   */
  private boolean InsertMntMotionRecord(TransactionStatus ts, Timestamp eventRegDate, String facilityCd,
      Integer deviceEdgeNo, String machineTypeCd, String machineSerial, String comFormatCd, Integer dataType,
      Long gatheringManageNo, String machineRecordMessage, String contents, String isCorrection, Long userId,
      Timestamp regDate, Timestamp upDate) {

    // 装置動作記録番号をシーケンスから取得
    // この戻り値を他情報の格納用として使用
    MntMotionRecord updateItem = this.motionRecordService.findMaxNo();

    // イベント発生日時
    updateItem.setEventRegDate(eventRegDate);
    // 緊急発報ステータス(なし)
    // 施設コード
    updateItem.setFacilityCd(facilityCd);
    // デバイスエッジ番号
    updateItem.setDeviceEdgeNo(deviceEdgeNo);
    // 型式コード
    updateItem.setMachineTypeCd(machineTypeCd);
    // 製造番号
    updateItem.setMachineSerial(machineSerial);
    // 通信フォーマット
    updateItem.setComFormatCd(comFormatCd);
    // データ種別
    updateItem.setDataType(dataType);
    // 自己診断種別(なし)
    // データ収集管理番号
    updateItem.setGatheringManageNo(gatheringManageNo);
    // メール送信日時(なし)
    // メール本文(なし)
    // 装置記録コード(なし)
    // 装置記録メッセージ
    updateItem.setMachineRecordMessage(machineRecordMessage);
    // 内容
    updateItem.setContents(contents);
    // 装置記録補助データ(なし)
    // メールアドレス(なし)
    // 宛先名称(なし)
    // 備考(なし)
    // 対処
    updateItem.setIsCorrection(isCorrection);
    // 対処者
    updateItem.setUserId(userId);
    // 登録日時
    updateItem.setRegDate(regDate);
    // 更新日時
    updateItem.setUpDate(upDate);

    EventLogMessage eventLogMessage = new EventLogMessage();
    // 装置動作記録テーブル(Insert)
    int ret = this.motionRecordService.insert(updateItem);
    if (ret < 1) {
      // エラー

      eventLogMessage.setLogMessage("データ収集API：装置動作記録へのInsertに失敗　装置動作記録番号[" + updateItem.getMotionRecordNo() + "]");
      eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
      eventLogMessage.setMachineTypeCd(machineTypeCd);
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setUserId(String.valueOf(userId));
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    return true;
  }

  /**
   * アップロードファイルの分割確認、復元、S3へ再アップロード処理
   *
   * @param listFilenameData
   * @param machineNo
   * @param uploadPath
   * @return
   */
  private UploadFileResult ProcJoinFile(String[] listFilenameData, String machineNo, String uploadPath) {
    UploadFileResult ret = new UploadFileResult();

    // 対象ファイル情報を抽出([型式コード][通信フォーマット][製造番号][ファイル数][ファイル名])
    String fileInfo = null;
    for (int i = 0; i < listFilenameData.length; i++) {
      if (true == listFilenameData[i].contains(machineNo)) {
        fileInfo = listFilenameData[i];
        break;
      }
    }
    if (true == StringUtils.isEmpty(fileInfo)) {
      // ファイル情報内に存在しない場合は処理終了(ここは正常終了とする)
      ret.Result = true;
      return ret;
    }

    // [ファイル数][ファイル名]部分を抽出
    int sIndex = CheckRequestByteNum.MachineTypeCdByteNum + CheckRequestByteNum.ComFormatCdByteNum
        + CheckRequestByteNum.MachineSerialByteNum;
    fileInfo = fileInfo.substring(sIndex);
    EventLogMessage eventLogMessage = new EventLogMessage();
    // ファイル結合APIを呼び出し
    try {
      UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromUriString(this.GetProperty("fileJoin.uri"))
          .queryParam("filePath", Base64.getEncoder().encodeToString(uploadPath.getBytes()))
          .queryParam("fileName", Base64.getEncoder().encodeToString(fileInfo.getBytes()));
      RestTemplate rt = new RestTemplate();

      // リクエスト作成
      RequestEntity<Map<String, String>> request = RequestEntity.post(new URI(uriBuilder.toUriString()))
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").body(null);


      try {
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        // リクエスト処理
        ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
        // log start
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.data_gathering.service.DataGatheringService");
        map.put("methodName", "ProcJoinFile");
        map.put("method", request.getMethod());
        map.put("url", request.getUrl());
        map.put("headers", request.getHeaders().toSingleValueMap());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
       // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        if (false == HttpStatus.OK.equals(response.getStatusCode())) {
          // エラー(500(INTERNAL_SERVER_ERROR)などの場合は例外となりcathchへ飛ぶが、念のためここでもチェックする)

          eventLogMessage.setLogMessage("データ収集API：ファイル結合APIでエラー発生 filePath[" + uploadPath + "]、fileInfo[" + fileInfo + "]");
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          return ret;
        }
      } catch (Exception ex) {
        // エラー

        eventLogMessage.setLogMessage("データ収集API：ファイル結合APIでエラー発生 filePath[" + uploadPath + "]、fileInfo[" + fileInfo + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        return ret;
      }
    } catch (Exception e) {
      // 例外
      eventLogMessage.setLogMessage("データ収集API：ファイル結合API呼び出し時に例外発生[" + e.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return ret;
    }

    // // ファイル数取得
    // String fileNum = fileInfo.substring(0, CheckRequestByteNum.FileNumByteNum);
    // ファイル名取得
    String filename = fileInfo.substring(CheckRequestByteNum.FileNumByteNum);

    // ファイル名を戻り値に格納
    ret.Filename = filename;

    ret.Result = true;
    return ret;
  }

  /**
   * 装置エラーコードから装置記録メッセージ取得(FTP関連のみ)
   *
   * @param code
   * @return
   */
  private String GetMachineRecordMessage(String code) {
    // エラーコードの1桁目(FTP関連)を取得
    int length = code.length();
    String ftpErrCode = code.substring(length - 1, length);

    // メッセージ格納用
    String msg;
    switch (ftpErrCode) {
      case "0":
        // 成功
        msg = "【成功】装置データファイル収集";
        break;

      case "1":
        // 対象ファイルなし
        msg = "【対象ファイルなし】装置データファイル収集";
        break;

      case "2":
        // 取得失敗
        msg = "【取得失敗】装置データファイル収集";
        break;

      case "3":
        // 圧縮失敗
        msg = "【圧縮失敗】装置データファイル収集";
        break;

      case "4":
        // 接続失敗
        msg = "【FTP接続失敗】装置データファイル収集";
        break;

      case "5":
        // 転送失敗
        msg = "【転送失敗】装置データファイル収集";
        break;

      default:
        // 不明
        msg = "【例外】装置データファイル収集";
        break;
    }

    return msg;
  }

  /**
   * 数値変換確認
   *
   * @param val
   * @return
   */
  private static boolean isNumber(String val) {
    try {
      Long.parseLong(val);
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  /**
   * Json文字列作成
   *
   * @param lstMstDeviceEdge
   * @param lstMstMachine
   * @return
   */
  private String MakeJson(List<GatheringInfo> targetMachineInfo) {
    // Json文字列に変換する為にデータを格納するクラス
    List<GatheringInfoEdge> result = new ArrayList<>();

    // 引数の装置情報分ループしJson文字列に変換する前のデータを作成（念の為、引数をコピーして別変数で処理する）
    List<GatheringInfo> targetMachineInfoCopy = new ArrayList<>(targetMachineInfo);
    for (int i = 0; i < targetMachineInfoCopy.size();) {
      GatheringInfo info = targetMachineInfoCopy.get(i);

      // 指定デバイスエッジ番号で抽出
      List<GatheringInfo> seachData = targetMachineInfoCopy.stream()
          .filter(ele -> ele.deviceEdgeNo == info.deviceEdgeNo).collect(Collectors.toList());

      // Json文字列作成(デバイスエッジ部分)
      GatheringInfoEdge edgeInfo = new GatheringInfoEdge();
      edgeInfo.device_edge_no = info.deviceEdgeNo;
      edgeInfo.device_edge_status = 0;
      edgeInfo.machine_info = new ArrayList<>();

      for (int j = 0; j < seachData.size(); j++) {
        // Json文字列(装置部分)格納用クラス
        GatheringInfoMachine machineInfo = new GatheringInfoMachine();
        machineInfo.machine_no = seachData.get(j).machineNo;
        machineInfo.machine_err_cd = "00";

        // Json文字列(デバイスエッジ部分)の装置情報部分に格納
        edgeInfo.machine_info.add(machineInfo);
      }

      // 大元のリストに格納
      result.add(edgeInfo);

      // 抽出した情報を大元のリストから削除
      targetMachineInfoCopy.removeAll(seachData);
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    // Json文字列形式へ変換
    ObjectMapper mapper = new ObjectMapper();
    String json = null;
    try {
      json = mapper.writeValueAsString(result);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("データ収集API：データ収集情報(gathering_info)登録用にJson形式への変換処理に失敗");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    }

    return json;
  }

  /**
   * 指定文字列のPadding処理 ・指定文字列のbyte数が指定byte数より少ない場合：50byte以降を切り捨て
   * ・指定文字列のbyte数が指定byte数より多い場合：50byte以降になるまで右側に半角スペース埋め
   *
   * @param target
   * @param byteNum
   * @return
   * @throws Exception
   */
  private static String StringPadding(String target, int byteNum) throws Exception {
    // 戻り値用変数
    String resultMsg = "";

    if (false == StringUtils.isEmpty(target)) {
      // 対象文字列を1文字ずつ分割しbyte数チェックをしながら結合
      String[] arrayMsg = target.split("");

      for (int i = 0; i < arrayMsg.length; i++) {
        if (byteNum < (resultMsg + arrayMsg[i]).getBytes("SJIS").length) {
          // 対象文字列が指定byte数を超える場合は終了
          break;
        }

        // 1文字を結合
        resultMsg += arrayMsg[i];
      }
    }

    // 指定byte数になるまで右側に半角スペースを付与
    // ※String.format("%-" + byteNum + "s", resultMsg)で実施すると指定バイト数分の文字列数となるのでNG
    for (int i = byteNum; resultMsg.getBytes("SJIS").length < i;) {
      resultMsg += " ";
    }

    return resultMsg;
  }

  /**
   * 要求API呼び出し時の受信情報のバイト数チェック
   *
   * @param deviceInfo
   * @return
   */
  public boolean CheckRequestByte(String requestData) {
	EventLogMessage eventLogMessage = new EventLogMessage();
    // 受信情報が各項目のバイト数を足した値で割り切れない場合はデータ不正
    if (0 != requestData.length() % CheckRequestByteNum.TotalNum) {
      eventLogMessage.setLogMessage("データ収集API：要求API呼び出し時の受信情報のバイト数が不正　装置情報[" + requestData + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return false;
    }

    return true;
  }

  /**
   * 設定ファイルから指定の情報を読込み
   *
   * @param property
   * @return
   */
  public String GetProperty(String property) {
    // 設定ファイルから指定の取得
    return this.environment.getProperty(property);
  }
}
