package jp.co.nikkiso.ntss.api.service;


import jp.co.nikkiso.ntss.api.model.HighchartGenerateModel;
import jp.co.nikkiso.ntss.api.pool.PlaywrightWorker;
import jp.co.nikkiso.ntss.api.pool.RenderTask;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jakarta.annotation.PreDestroy;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

@Service
public class RenderPoolService {

  @Autowired
  LogService logService;

  private static final int WORKER_COUNT = 3;

  private final BlockingQueue<RenderTask> taskQueue = new LinkedBlockingQueue<>();

  private final List<Thread> workerThreads = new ArrayList<>();
  public void init() {
    for (int i = 0; i < WORKER_COUNT; i++) {
      PlaywrightWorker worker = new PlaywrightWorker(taskQueue, logService);
      Thread t = new Thread(worker, "playwright-worker-" + i);
      t.setDaemon(false);
      t.start();
      workerThreads.add(t);
    }

    EventLogMessage msg = new EventLogMessage();
    msg.setLogMessage("PlaywrightWorker pool init: " + WORKER_COUNT);
    logService.log(LogLevel.INFO, msg,
      LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU,
      LoggingConstant.SERVICE_NAME.FNSI, null);
  }

  public List<String> renderCharts(
    List<HighchartGenerateModel> models,
    List<String> tableList,
    Map<String, Object> dataKey,
    String highchartsJs) throws Exception {

    RenderTask task = new RenderTask(models, tableList, dataKey, highchartsJs);
    taskQueue.put(task);

    try {
      return task.future.get(90, TimeUnit.SECONDS);
    } catch (TimeoutException e) {
      // timeout
      task.future.cancel(true);
      throw new RuntimeException("Render chart timeout after 90 seconds", e);
    } catch (ExecutionException e) {
      // Worker erro
      throw new RuntimeException("Render chart failed", e.getCause());
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
      throw new RuntimeException("Render interrupted", e);
    }
  }
  @PreDestroy
  public void shutdown() {
    for (Thread t : workerThreads) {
      t.interrupt();
    }
  }
}
