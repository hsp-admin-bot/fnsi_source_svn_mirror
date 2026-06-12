package jp.co.nikkiso.ntss.data_gathering_auto.service;

import java.net.URI;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import tools.jackson.core.JacksonException;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.data_gathering_auto.entity.MstFacilityCustom;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Service
public class DataGatheringAutoService {
  @Autowired
  private Environment environment;

  @Autowired
  private LogService logService;
  /**
   * REST API側へ渡す情報の格納用クラス
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
     * 全装置かどうか
     */
    boolean isAll = false;

    /**
     * 再送対象のデータ収集管理番号
     */
    Long retryManageNo;

    /**
     * 再送時の装置が、「失敗した装置のみ」or「成功含め全ての装置」のどちらかのフラグ(true:成功含め全て(マスタではなく再送対象元の装置に限る)、false:失敗のみ)
     */
    boolean isRetryAll = false;

    /**
     * 操作情報(0：自動収集、1：手動収集、2：失敗時の再要求)
     */
    Integer opeInfo;

    public String getFacilityCd() {
      return this.facilityCd;
    }

    public void setFacilityCd(String facilityCd) {
      this.facilityCd = facilityCd;
    }

    public List<String> getMachineNo() {
      return this.machineNo;
    }

    public void setMachineNo(List<String> machineNo) {
      this.machineNo = machineNo;
    }

    public boolean getIsAll() {
      return this.isAll;
    }

    public void setIsAllCd(boolean isAll) {
      this.isAll = isAll;
    }

    public Long getRetryManageNo() {
      return this.retryManageNo;
    }

    public void setRetryManageNo(Long retryManageNo) {
      this.retryManageNo = retryManageNo;
    }

    public boolean getIsRetryAll() {
      return this.isRetryAll;
    }

    public void setIsRetryAll(boolean isRetryAll) {
      this.isRetryAll = isRetryAll;
    }

    public Integer getOpeInfo() {
      return this.opeInfo;
    }

    public void setOpeInfo(Integer opeInfo) {
      this.opeInfo = opeInfo;
    }
  }

  /**
   * 自動収集確認・実施処理
   *
   * @Async について 本アノテーションを付与することで非同期処理可能な関数となる
   *        (但し、同じクラス(今回はDataGatheringAutoService)内で呼んでも非同期処理をしてくれない模様)
   */
  @Async
  public void Schedule(MstFacilityCustom facilityData) {
    if (null == facilityData) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("データ自動収集監視：引数[facilityData]がnull");
      eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    }

    // ログ用に施設情報の文字列を作成
    String logFacilityInfo = "対象施設[" + facilityData.getFacilityCd() + "：" + facilityData.getFacilityName() + "]";

    // 日付変換フォーマット
    SimpleDateFormat sdfOnlyDay = new SimpleDateFormat("yyyy/MM/dd");
    SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy/MM/dd HHmm");
    SimpleDateFormat sdfLog = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");

    // 現在日時
    Calendar nowCal = Calendar.getInstance();
    Date nowDate = nowCal.getTime();

    // 次回実施日付をキャッシュデータから取得
    String nextProcDay = facilityData.getAutoGatheringNextProcDay();
    if (StringUtils.isEmpty(nextProcDay)) {
      // 日付(年月日)部分作成
      nextProcDay = nowCal.get(Calendar.YEAR) + "/" + (nowCal.get(Calendar.MONTH) + 1) + "/" + nowCal.get(Calendar.DATE);

      // 日付部分をキャッシュデータに格納(このデータのみキャッシュする必要がある(毎回実施することを防ぐため))
      facilityData.setAutoGatheringNextProcDay(nextProcDay);
    }

    // 次回実施日付と自動収集開始時刻を結合して日時に変換
    Date nextProcDate;
    try {
      nextProcDate = sdfDate.parse(nextProcDay + " " + facilityData.getAutoGatheringStartTime());
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("データ自動収集監視：データ自動収集開始時刻の時刻変換処理に失敗　データ自動収集開始時刻[" + facilityData.getAutoGatheringStartTime() + "]、" + logFacilityInfo);
      eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    }

    // 現在日時が次回開始日時を超えているかチェック
    if (nowDate.compareTo(nextProcDate) < 0) {
      // 超えていない場合は実施しない
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("データ自動収集監視：現在日時が次回開始日時を超えていない為、自動収集を実施しない　現在日時["
      + sdfLog.format(nowDate) + "]、次回実施日時[" + sdfLog.format(nextProcDate) + "]、" + logFacilityInfo);
      eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    }

    // 次回実施日時を+1日して格納
    nowCal.setTime(nextProcDate);
    nowCal.add(Calendar.DATE, 1);
    facilityData.setAutoGatheringNextProcDay(sdfOnlyDay.format(nowCal.getTime()));

    // REST APIへ渡すパラメータの作成
    GatheringTarget target = new GatheringTarget();
    // 施設コード
    target.facilityCd = facilityData.getFacilityCd();
    // 操作情報(自動なので0)
    target.opeInfo = 0;

    try {
      // パラメータをJson形式(文字列)に変換
      ObjectMapper mapper = new ObjectMapper();

      // 変換
      String json = mapper.writeValueAsString(target);

      // URL取得
      String urlRequest = this.environment.getProperty("gatheringApi.uri");

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("データ自動収集監視：現在日時が次回開始日時を超えていない為、自動収集を実施しない　現在日時["
      + sdfLog.format(nowDate) + "]、次回実施日時[" + sdfLog.format(nextProcDate) + "]、" + logFacilityInfo);
      eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      // 送信URI
      URI uri = new URI(urlRequest);
      RestTemplate rt = new RestTemplate();

      // リクエスト作成
      RequestEntity<String> request = RequestEntity.post(uri).contentType(MediaType.APPLICATION_JSON)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").body(json);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
      HttpStatus status = HttpStatus.valueOf(response.getStatusCode().value());
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.data_gathering_auto.service.DataGatheringAutoService");
      map.put("methodName", "Schedule");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      if (facilityData != null && !StringUtils.isEmpty(facilityData.getFacilityCd())) {
        restTemplateEventLogMessage.setFacilityCd(facilityData.getFacilityCd());
      }
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      if (HttpStatus.OK != status) {
        eventLogMessage.setLogMessage("データ自動収集監視：REST API側で異常発生　" + logFacilityInfo);
        eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("データ自動収集監視：REST API側で異常発生　" + logFacilityInfo);
      eventLogMessage.setFacilityCd(facilityData.getFacilityCd());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }
  }
}
