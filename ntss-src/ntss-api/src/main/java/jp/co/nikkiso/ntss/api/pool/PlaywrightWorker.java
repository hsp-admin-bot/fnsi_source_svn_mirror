package jp.co.nikkiso.ntss.api.pool;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.BrowserType;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Playwright;
import jp.co.nikkiso.ntss.api.model.HighchartGenerateModel;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.BlockingQueue;

/**
 * Playwrightワーカースレッドクラス
 *
 * このクラスは、ブラウザ自動化ライブラリPlaywrightを使用して、
 * Highchartsチャートを画像としてレンダリングする専用ワーカースレッドです。
 *
 * 主な機能：
 * 1. タスクキューからレンダリングタスクを取得
 * 2. ヘッドレスChromiumブラウザでチャートをレンダリング
 * 3. 生成された画像をファイルに保存
 * 4. 結果を結果キューに送信
 *
 * このクラスは並列処理をサポートし、複数のワーカーインスタンスが
 * 同時に実行されることで、高いスループットを実現します。
 */
public class PlaywrightWorker implements Runnable {

    /**
     * タスクキュー
     * レンダリング待ちのタスクを保持するブロッキングキューです。
     * ワーカースレッドは、このキューからタスクを取得します。
     * キューが空の場合、スレッドはタスクが追加されるまでブロックされます。
     */
    private final BlockingQueue<RenderTask> taskQueue;

    /**
     * Playwrightインスタンス
     *
     * ブラウザの起動と管理を行うPlaywrightのメインインスタンスです。
     *
     * ワーカーの初期化時に作成され、ワーカーのライフサイクル全体で
     * 使用されます。
     */
    private Playwright playwright;

    /**
     * ブラウザインスタンス
     * Chromiumブラウザのインスタンスです。ヘッドレスモードで起動され、
     * チャートのレンダリングに使用されます。
     * 複数のページ（タブ）を作成してチャートを並列にレンダリングできます。
     */
    private Browser browser;

    /**
     * ログサービス
     * ワーカーの動作、パフォーマンス、エラーを記録するための
     * ログサービスです。
     * レンダリング処理の開始、完了、所要時間などのイベントを
     * ログに記録します。
     */
    private LogService logService;


    private volatile boolean running = true;

    /**
     * コンストラクタ
     *
     * PlaywrightWorkerを初期化します。ブラウザの起動は、
     * run()メソッドが呼ばれるまで遅延されます。
     * @param taskQueue タスクキュー
     *                  レンダリングタスクの供給元。nullは許可されません。
     * @param logService ログサービス
     *                   イベントログの記録に使用。nullは許可されません。
     */
    public PlaywrightWorker(
      BlockingQueue<RenderTask> taskQueue,
      LogService logService) {
      this.taskQueue = taskQueue;
      this.logService = logService;
    }

    /**
     * ワーカースレッドのメイン実行メソッド
     *
     * このメソッドは、スレッドが開始されると自動的に呼び出されます。
     * 処理フロー：
     * 1. Playwrightとブラウザを初期化
     * 2. 開始ログを記録
     * 3. 無限ループでタスクを処理：
     *    - タスクキューからタスクを取得（ブロッキング）
     *    - タスクをレンダリング
     *    - 処理時間を記録
     *    - 結果を結果キューに送信
     * 4. エラーが発生した場合は例外をキャッチしてログに記録
     * 注意：このメソッドは無限ループのため、通常は終了しません。
     * スレッドを停止するには、外部からの割り込みが必要です。
     */
    @Override
    public void run() {
        // Playwrightインスタンスを作成
        try {
          playwright = Playwright.create();

          // Chromiumブラウザをヘッドレスモードで起動
          // ヘッドレスモード：GUIなしでブラウザを実行
          browser = playwright.chromium().launch(
            new BrowserType.LaunchOptions().setHeadless(true)
          );

          // ワーカー起動ログを記録
          log("PlaywrightWorker started");

          // メインループ：タスクを継続的に処理
          while (running && !Thread.currentThread().isInterrupted()) {
            RenderTask task = null;
            try {
              task = taskQueue.take();

              long t0 = System.currentTimeMillis();
              List<String> images = render(
                task.highchartGenerateModels,
                task.tableList,
                task.dataKey,
                task.highchartsJs
              );
              long used = System.currentTimeMillis() - t0;

              log("Render success, used " + used + " ms");

              // ⭐ true  return result
              task.future.complete(images);
            } catch (InterruptedException  e) {
              Thread.currentThread().interrupt();
              break;
            } catch (Exception e) {
              log("Render failed: " + e.getMessage());
              if (task != null) {
                task.future.completeExceptionally(e);
              }
            }
          }
        }
        finally {
          shutdownBrowser();
        }
    }

    /**
     * チャートレンダリングメソッド
     * 指定されたHighchartsチャート設定を使用して、ブラウザでチャートを
     * レンダリングし、スクリーンショットを撮影します。
     * @param highchartGenerateModels チャート生成モデルのリスト
     *                                各モデルはチャート設定と出力パスを含みます。
     * @param tableList HTMLテーブルコンテンツのリスト
     *                  各チャートの下に表示されるテーブルデータ。
     * @param dataKey レンダリングパラメータのマップ
     * @param highchartsJs Highchartsライブラリのスクリプトコード
     *                     ページに注入されるJavaScriptコード。
     * @return 生成された画像ファイルの絶対パスのリスト
     * @throws Exception レンダリング中にエラーが発生した場合
     */
    private List<String> render(List<HighchartGenerateModel> highchartGenerateModels,
                                List<String> tableList,
                                Map<String, Object> dataKey,
                                String highchartsJs) throws Exception {
        // 生成された画像ファイルパスを保持するリスト
        List<String> files = new ArrayList<>();

        // レンダリング開始時刻を記録
        long t0 = System.currentTimeMillis();

        // dataKeyからレンダリングパラメータを取得
        Integer width = (Integer) dataKey.get("countWidth");        // ビューポート幅
        Integer heigth = (Integer) dataKey.get("countHeight");      // ビューポート高さ
        Integer chartheigth = (Integer) dataKey.get("charHeight");  // チャート高さ
        Integer tableHeight = (Integer) dataKey.get("tableHeight"); // テーブル高さ

        // try-with-resources: コンテキストは自動的にクローズされます
        try (BrowserContext ctx = browser.newContext(
                new Browser.NewContextOptions().setViewportSize(width, heigth))) {
            // ページコンテンツ読み込みオプションを設定
            // タイムアウト：60秒
            Page.SetContentOptions options = new Page.SetContentOptions();
            options.setTimeout(60000);
            // 各チャートモデルを処理
            for (int i = 0; i < highchartGenerateModels.size(); i++) {
                HighchartGenerateModel model = highchartGenerateModels.get(i);
                // 新しいページ（タブ）を作成
                Page page = ctx.newPage();

                String tableHtml = "";
                if (tableList.size() > i) {
                  tableHtml = tableList.get(i);
                } else {
                  tableHtml = "";
                }
                // HTMLコンテンツを生成
                // このHTMLには以下が含まれます：
                // 1. Highchartsライブラリのスクリプト
                // 2. チャートを表示するためのdiv要素
                // 3. テーブルを表示するためのdiv要素
                // 4. チャートを初期化するJavaScriptコード
                String htmlContent = "<!DOCTYPE html>\n<html>\n<head>\n<meta charset='UTF-8'>\n" +
                        "<script>\n" + highchartsJs + "\n</script>\n" +
                        "</head>\n<body>\n" +
                        "<div id='container' style='width:" + width + "px;height:" + chartheigth + "px\"'></div>\n" +
                        "<div id='table' style='width:" + width + "px;height:" + tableHeight + "px\"' >" + tableHtml + "</div>\n" +
                        "<script>\n" +
                        "const chartOptions = " + model.getInJsonFilePath() + ";\n" +
                        "chartOptions.chart = chartOptions.chart || {};\n" +
                        "chartOptions.chart.animation = false;\n" +
                        "const chart = Highcharts.chart('container', chartOptions);\n" +
                        "window.chartReady = true;\n" +
                        "</script>\n" +
                        "</body>\n</html>";

                // HTMLをページに読み込み
                page.setContent(htmlContent, options);

                page.waitForFunction("() => window.chartReady === true");
                // ページ全体のスクリーンショットを撮影
                // fullPage: ページ全体をキャプチャ
                // path: 保存先のファイルパス
                page.screenshot(new Page.ScreenshotOptions()
                        .setFullPage(true)
                        .setPath(Paths.get(model.getOutImagefilePath())));
                // 生成された画像ファイルパスをリストに追加
                files.add(model.getOutImagefilePath());
            }

            // レンダリング処理の所要時間を計算
            long used = System.currentTimeMillis() - t0;
            log("Worker- PlaywrightWorker waitForFunction and screenshot used time :" + used + "ms");
        } catch (Exception e) {
            // エラーをラップして再スロー
            throw new RuntimeException(e);
        }
        // 生成されたすべての画像ファイルパスを返す
        return files;
    }

  public void shutdown() {
    running = false;
  }
  private void shutdownBrowser() {
    try {
      if (browser != null) browser.close();
      if (playwright != null) playwright.close();
    } catch (Exception ignored) {
    }
  }
  private void log(String msg) {
    EventLogMessage elm = new EventLogMessage();
    elm.setLogMessage(msg);
    logService.log(LogLevel.INFO, elm, null, LoggingConstant.SERVICE_NAME.FNSI, null);
  }
}
