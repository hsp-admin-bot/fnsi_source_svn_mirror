package jp.co.nikkiso.ntss.data_gathering_auto.resource;


import jp.co.nikkiso.ntss.core.utils.Ec2MetadataHelper;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.List;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.data_gathering_auto.constant.SysSystemDefineCtlNo;
import jp.co.nikkiso.ntss.data_gathering_auto.entity.MstFacilityCustom;
import jp.co.nikkiso.ntss.data_gathering_auto.service.DataGatheringAutoService;
import jp.co.nikkiso.ntss.data_gathering_auto.service.LogService;
import jp.co.nikkiso.ntss.data_gathering_auto.service.MstFacilityCustomService;
import jp.co.nikkiso.ntss.data_gathering_auto.service.SysSystemDefineService;

/**
 * データ自動収集監視Controller
 * 2018/10/19 YSK：施設マスタをキャッシュしないように修正
 */
@RestController
@RequestMapping("/api")
public class DataGatheringAutoResource {
  @Autowired
  DataGatheringAutoService dataGatheringAutoSv;

  @Autowired
  MstFacilityCustomService mstFacilityCustomSv;

  @Autowired
  SysSystemDefineService sysSystemDefineSv;

  @Autowired
  private LogService logService;
  /**
   * データ自動収集対象施設
   */
  private List<MstFacilityCustom> _lstFacility;

  /**
   * データ自動収集監視を実施するかどうかのフラグ
   */
  private boolean _isStart = true;

  /**
   * 処理が実施中かどうかのフラグ
   */
  private boolean _isProc = false;

  /**
   * データ自動収集監視(定期監視)
   *
   * @Scheduled について 定期的に処理の実行が可能 引数なしの関数のみ可能(コンパイルは通るが実行時にエラーになる)
   * @Scheduled パラメータ ※下記内容を設定ファイル(application.yml)から読み込む
   *            initialDelay：SpringBoot起動後から何ms後に開始するか(1回のみ)
   *            fixedRate：タスク(指定した関数)の実行開始時点から何ms後に再度開始するか ※ここでは未使用
   *            fixedDelay：タスク(指定した関数)の実行完了後から何ms後に再度開始するか
   */
  @Scheduled(initialDelayString = "${scheduler.initialDelay}", fixedDelayString = "${scheduler.fixedDelay}")
  public void main() {
    // データ自動収集実施フラグがfalseの場合、ここで終了
    if (false == this._isStart) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "データ自動収集監視：停止中");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
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
      eventLogMessage.setLogMessage("データ自動収集監視：PrivateIPアドレスの取得に失敗、別の方法(Java：InetAddressクラス)で取得を試みる　Exception[" + e.getMessage() + "]");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      try {
        // IPアドレスの取得
        ipAddr = InetAddress.getLocalHost().getHostAddress();
      } catch (UnknownHostException ue) {
        // 名前解決ができない
        eventLogMessage.setLogMessage("データ自動収集監視：PrivateIPアドレスの取得に失敗　UnknownHostException[" + ue.getMessage() + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return;
      } catch (SecurityException se) {
        // セキュリティ上の規制による例外
        eventLogMessage.setLogMessage("データ自動収集監視：PrivateIPアドレスの取得に失敗　SecurityException[" + se.getMessage() + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return;
      } catch (Exception ex) {
        // その他例外
        eventLogMessage.setLogMessage("データ自動収集監視：PrivateIPアドレスの取得に失敗　Exception[" + ex.getMessage() + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return;
      }
    }

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データ自動収集監視：取得したPrivateIPアドレス　[" + ipAddr + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // 自身が処理を行うサーバーかどうかの確認を行う
    if (false == this.sysSystemDefineSv.IsProcServer(SysSystemDefineCtlNo.No2, ipAddr)) {
      eventLogMessage.setLogMessage("データ自動収集監視：処理実施サーバーではないので、データ収集を行わない　PrivateIPアドレス[" + ipAddr + "]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    }

    // 処理中のフラグをON
    this._isProc = true;

    eventLogMessage.setLogMessage("データ自動収集監視：定期監視開始");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // 施設マスタ情報取得
    List<MstFacilityCustom> mstFacility = this.mstFacilityCustomSv.findAll();
    if (null == mstFacility) {
      // 取得失敗
      eventLogMessage.setLogMessage("データ自動収集監視：施設マスタの取得に失敗");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
    if (null == this._lstFacility) {
      // 初期起動時は取得情報をそのまま格納
      this._lstFacility = mstFacility;
    } else {
      // 初期起動時以外は、次回実施日時をマージする
      // ベースは上記で取得した施設マスタ情報とする(施設の増減などがあるため)
      for (MstFacilityCustom oldFacility : this._lstFacility) {
        mstFacility.stream().filter(ele -> ele.getFacilityCd().equals(oldFacility.getFacilityCd()))
            .forEach(ele -> ele.setAutoGatheringNextProcDay(oldFacility.getAutoGatheringNextProcDay()));
      }

      // マージが完了したら格納
      this._lstFacility = mstFacility;
    }

    // 施設分ループ
    for (int i = 0; i < this._lstFacility.size(); i++) {
      // 対象施設に対して自動収集を実施するタイミングがチェック
      // 収集タイミングであれば収集を実施
      this.dataGatheringAutoSv.Schedule(this._lstFacility.get(i));
    }

    eventLogMessage.setLogMessage("データ自動収集監視：定期監視終了(非同期で収集実施中の可能性あり)");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // 処理中のフラグをOFF
    this._isProc = false;
  }

  /**
   * データ自動収集監視：開始
   */
  @PostMapping("/start")
  public HttpStatus Start() {
    // データ自動収集実施フラグをON
    this._isStart = true;
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データ自動収集監視：開始要求(データ自動収集実施フラグをON)");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return HttpStatus.OK;
  }

  /**
   * データ自動収集監視：停止
   */
  @PostMapping("/stop")
  public HttpStatus Stop() {

    while (true == this._isProc) {
      try {
        // 処理中の場合は3秒待機
        TimeUnit.SECONDS.sleep(3);
      } catch (Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("データ自動収集監視：停止要求の実施中処理完了待ち時に例外発生(強制的に停止状態にする)　" + e.getMessage());
        //FNSI-修正 ログ対応 xiebzh add start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        //FNSI-修正 ログ対応 xiebzh add end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        this._isProc = false;
        break;
      }
    }

    // キャッシュ情報のクリア
    this._lstFacility = null;

    // データ自動収集実施フラグをOFF
    this._isStart = false;

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データ自動収集監視：停止完了(データ自動収集実施フラグをOFF)");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return HttpStatus.OK;
  }

  /**
   * データ自動収集監視：起動状況確認
   *
   * @return
   */
  @PostMapping("/check")
  public boolean Check() {
    String msg = true == this._isStart ? "起動中" : "停止中";
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データ自動収集監視：起動状況確認[" + msg + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return this._isStart;
  }
}
