package jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.admin_web.web.rest.util.OrdMainJournalRequestUtil;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import lombok.extern.slf4j.Slf4j;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
import org.springframework.beans.factory.annotation.Autowired;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.boot.CommandLineRunner;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
import java.util.Map;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import java.util.concurrent.DelayQueue;
import java.util.concurrent.Executors;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
// #7068 add  患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
/*
 * ordMain 遅延タスク管理
 * */
@Slf4j
@Component
public class OrdMainDelayTaskManager implements CommandLineRunner {
  //  遅延キュー
  final private DelayQueue<OrdMainDelayTask> delayQueue = new DelayQueue<>();

// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
  @Autowired
  private LogService logService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

  /**
   * 遅延キューに追加
   *
   * @param task-{@link OrdMainDelayTask }
   */
  public void put(OrdMainDelayTask task) throws Exception {
    delayQueue.put(task);
  }

  /**
   * 遅延タスクの取得
   *
   * @return 遅延キュー
   */
  public DelayQueue<OrdMainDelayTask> getDelayQueue() {
    return delayQueue;
  }

  /**
   * 遅延タスクのキャンセル
   *
   * @param task-{@link OrdMainDelayTask }
   * @return -{@link Boolean}
   */
  public boolean remove(OrdMainDelayTask task) {
    log.info("遅延タスクのキャンセル：{}", task);
    return delayQueue.remove(task);
  }

  /**
   * 遅延タスクのキャンセル
   */
  public boolean remove(Long ordNo, Long patId, String crud) {
    OrdMainJournalRequest ordMainJournalRequest = new OrdMainJournalRequest();
    ordMainJournalRequest.setCrud(crud);
    ordMainJournalRequest.setPatId(patId);
    ordMainJournalRequest.setOrdNo(ordNo);
    return remove(new OrdMainDelayTask(ordMainJournalRequest, 0));
  }

  /*
   * スレッドで動い
   * */
  @Override
  public void run(String... args) throws Exception {
    log.info("初期化遅延キュー");
    Executors.newSingleThreadExecutor().execute(new Thread(this::excuteThread));
  }

  /**
   * タスク実行スレッド
   */
  private void excuteThread() {
    while (true) {
      try {
        OrdMainDelayTask task = delayQueue.take();

        callApiTaskProcessing(task);

      } catch (InterruptedException e) {
        log.info("タスク実行スレッド エラー");
        break;
      }
    }
  }

  /**
   * apiを呼び出す
   *
   * @param task-{@link OrdMainDelayTask}
   */
  private void callApiTaskProcessing(OrdMainDelayTask task) {
    log.info("実行：{}", task);

    JournalCreateRequestPayload payload = task.getData().getPayload();
    URI uri = task.getData().getUri();

    //リクエスト
    RequestEntity<JournalCreateRequestPayload> request = RequestEntity.post(uri)
      .contentType(MediaType.APPLICATION_JSON)
      .body(payload);
    RestTemplate rt = new RestTemplate();
    try {
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<Object> response = rt.exchange(request, Object.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask.OrdMainDelayTaskManager");
      map.put("methodName", "callApiTaskProcessing");
      map.put("method", request.getMethod());
      map.put("url", uri.getPath());
      map.put("headers", request.getHeaders());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
    } catch (RestClientException e) {
      log.error(OrdMainJournalRequestUtil.logInfo("RestClient エラー:", payload.getOrdNo(), payload.getPatId()));
    }
  }
}
// #7068 add  患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end
