package jp.co.nikkiso.ntss.alive_moni_auto.resource;


import jp.co.nikkiso.ntss.core.utils.Ec2MetadataHelper;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.alive_moni_auto.constant.SysSystemDefineCtlNo;
import jp.co.nikkiso.ntss.alive_moni_auto.entity.MstFacilityCustom;
import jp.co.nikkiso.ntss.alive_moni_auto.service.AliveMoniAutoService;
import jp.co.nikkiso.ntss.alive_moni_auto.service.LogService;
import jp.co.nikkiso.ntss.alive_moni_auto.service.AliveMoniAutoService.ProcInfo;
import jp.co.nikkiso.ntss.alive_moni_auto.service.AliveMoniAutoService.RetTimeout;
import jp.co.nikkiso.ntss.alive_moni_auto.service.MstFacilityCustomService;
import jp.co.nikkiso.ntss.alive_moni_auto.service.SysSystemDefineService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

@RestController
@RequestMapping("/api")
public class AliveMoniAutoResource {
  @Autowired
  AliveMoniAutoService aliveMoniAutoSv;

  @Autowired
  MstFacilityCustomService mstFacilityCustomSv;

  @Autowired
  SysSystemDefineService sysSystemDefineSv;

  @Autowired
  private LogService logService;

  /**
   * 起動確認中の応答待ち時間
   * ・ミリ秒
   * ・この時間を経過しても応答がない場合は異常と判断し処理
   */
  @Value("${scheduler.procTimeout}")
  private int _procTimeout;

  /**
   * 停止処理による起動確認中の応答待ち時間
   * ・ミリ秒
   * ・この時間を経過しても応答がない場合は強制終了
   */
  @Value("${scheduler.stopTimeout}")
  private int _stopTimeout;

  /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  /**
   * 死活監視対象施設
   */
  // private List<MstFacilityCustom> _lstFacility;
  private volatile List<MstFacilityCustom> _lstFacility;

  /**
   * 死活監視実施中の情報格納用
   */
  // private List<ProcInfo> _lstProcInfo;
  private Map<String, ProcInfo> _lstProcInfo;

  /**
   * 開始フラグ
   */
  // private boolean _isStart = true;
  private AtomicBoolean _isStart = new AtomicBoolean(true);

  /**
   * 初期起動時
   */
  // @PostConstruct ← これはSpring起動時に1回だけ実行したい場合に指定(即実行される)
  @Scheduled(initialDelayString = "${scheduler.initialDelay}", fixedDelayString = "${scheduler.fixedDelay}")
  public void main() {
    if (false == this._isStart.get()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視：停止中");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return;
    }

    // PrivateIPの取得
    String ipAddr;
    try {
      // EC2からPrivateIPを取得
      ipAddr = Ec2MetadataHelper.getPrivateIp();
    } catch (Exception e) {
      // EC2からPrivateIPを取得できなかった場合(EC2以外で実行した場合、など)、以下を実行して取得を試みる

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視：PrivateIPアドレスの取得に失敗、別の方法(Java：InetAddressクラス)で取得を試みる　Exception[" + e.getMessage() + "]");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      try {
        // IPアドレスの取得
        ipAddr = InetAddress.getLocalHost().getHostAddress();
      } catch (UnknownHostException ue) {
        // 名前解決ができない
        eventLogMessage.setLogMessage("死活監視：PrivateIPアドレスの取得に失敗　UnknownHostException[" + ue.getMessage() + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return;
      } catch (SecurityException se) {
        // セキュリティ上の規制による例外
        eventLogMessage.setLogMessage("死活監視：PrivateIPアドレスの取得に失敗　SecurityException[" + se.getMessage() + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return;
      } catch (Exception ex) {
        // その他例外

        eventLogMessage.setLogMessage("死活監視：PrivateIPアドレスの取得に失敗　Exception[" + ex.getMessage() + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return;
      }
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("死活監視：取得したPrivateIPアドレス　[" + ipAddr + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);

    // 自身が処理を行うサーバーかどうかの確認を行う
    if (false == this.sysSystemDefineSv.IsProcServer(SysSystemDefineCtlNo.No3, ipAddr)) {
      eventLogMessage.setLogMessage("死活監視：処理実施サーバーではないので、死活監視を行わない　ローカルIPアドレス[" + ipAddr + "]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return;
    }

    eventLogMessage.setLogMessage("死活監視：定期監視開始");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
    // 施設マスタ情報取得
    List<MstFacilityCustom> lstMstFacility = this.mstFacilityCustomSv.findAll();
    if (null == lstMstFacility) {
      eventLogMessage.setLogMessage("死活監視：施設マスタの取得に失敗");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return;
    }

    // 共有フィールドを直接走査せず、スナップショットで整合性を保つ。
    List<MstFacilityCustom> oldFacilitySnapshot = this._lstFacility;
    if (null == oldFacilitySnapshot) {
      // 初期起動時は処理中情報格納用リストを初期化
      this._lstProcInfo = new ConcurrentHashMap<>();
    } else {
      // 施設ごとの処理実施フラグのみキャッシュ
      for (MstFacilityCustom oldFacility : oldFacilitySnapshot) {
        lstMstFacility
          .stream()
          .filter(ele -> ele.getFacilityCd().equals(oldFacility.getFacilityCd()))
          .forEach(ele -> ele.setIsStart(oldFacility.getIsStart()));
      }
    }

    // 死活監視間隔がnullではないレコードの抽出
    // 今回周期で使用する対象施設のスナップショット。
    List<MstFacilityCustom> newFacilitySnapshot = lstMstFacility
        .stream()
        .filter(ele -> null != ele.getAliveMoniInterval())
        .collect(Collectors.toList());
    this._lstFacility = newFacilitySnapshot;

    // 施設分ループ
    for (int i = 0; i < newFacilitySnapshot.size(); i++) {
      this.aliveMoniAutoSv.Schedule(newFacilitySnapshot.get(i), this._lstProcInfo, _procTimeout);
    }
    eventLogMessage.setLogMessage("死活監視：定期監視終了(非同期で収集実施中の可能性あり)");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
  }

  /**
   * 外部から開始
   */
  @PostMapping("/start")
  public void Start() {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("死活監視：[起動]起動処理開始");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (true == this._isStart.get()) {
      return;
    }
    this._isStart.set(true);

    eventLogMessage.setLogMessage( "死活監視：[起動]起動処理終了");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
  }

  /**
   * 外部から停止
   */
  @PostMapping("/stop")
  public void Stop() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("死活監視：[停止]停止処理開始");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (false == this._isStart.get()) {
      // 元々停止しているので終了
      return;
    }

    List<MstFacilityCustom> facilitySnapshot = this._lstFacility;
    if (null != facilitySnapshot) {
      for (int i = 0; i < facilitySnapshot.size(); i++) {
        // 各施設が以降に監視処理を実施しないようにフラグを設定
        // ※this._isStart を false にしないのは、停止処理中に起動させない為
        facilitySnapshot.get(i).setIsStart(false);
      }
    }

    if (null != this._lstProcInfo && 0 != this._lstProcInfo.size()) {

      eventLogMessage.setLogMessage("死活監視：[停止]起動確認中の応答状態を確認");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

      // 現在日時
      Date startDate = new Date();

      while (0 != this._lstProcInfo.size()) {
        try {
          TimeUnit.SECONDS.sleep(2);
        } catch (Exception e) {
        }

        // 起動確認中のもので、一定時間応答がないものは異常と判断
        // ConcurrentHashMapを安全に走査するため、値のスナップショットで判定する。
        List<ProcInfo> procInfoSnapshot = new ArrayList<>(this._lstProcInfo.values());
        for (ProcInfo procInfo : procInfoSnapshot) {
          // 起動要求の応答確認
          RetTimeout ret = this.aliveMoniAutoSv.CheckTimeout(procInfo.getFacilityCd(), procInfo.getDeviceEdgeNo(),
              procInfo.getProcDate(), this._procTimeout);
          if (true == RetTimeout.OVER.equals(ret)) {
            // 確認中リストから削除
            String procKey = this.aliveMoniAutoSv.createProcInfoKey(procInfo.getFacilityCd(), procInfo.getDeviceEdgeNo());
            this._lstProcInfo.remove(procKey);
          }
        }

        // 一定時間経過しても確認中データが残っている場合、破棄して処理終了
        long diff = (new Date()).getTime() - startDate.getTime();
        if (this._stopTimeout < diff) {

          eventLogMessage.setLogMessage("死活監視：[停止]一定時間経過した為、起動確認中のキャッシュ情報を削除し強制終了");
          logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.REMS, null);
          break;
        }
      }
    }

    this._isStart.set(false);
    this._lstFacility = null;
    this._lstProcInfo = null;

    eventLogMessage.setLogMessage("死活監視：[停止]停止処理完了");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
  }
  /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */

  // /**
  // * アプリ停止時処理
  // */
  // @PreDestroy
  // public void Destroy()
  // {
  // Stop();
  // }
}
