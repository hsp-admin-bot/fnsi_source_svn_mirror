package jp.co.nikkiso.ntss.api.pool;

import jp.co.nikkiso.ntss.api.model.HighchartGenerateModel;

import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

/**
 * レンダリングタスククラス
 * このクラスは、Highchartsチャートをレンダリングするために必要な
 * すべてのデータとパラメータを保持します。
 * PlaywrightWorkerに渡され、ブラウザ上でチャートを生成し、
 * 画像やPDFとして出力するために使用されます。
 */
public class RenderTask {
  /**
   * Highchartチャート生成モデルのリスト
   * 複数のチャート設定を含むリストです。各モデルには、
   * チャートのタイプ、データ系列、軸の設定、凡例などの
   * Highcharts設定オプションが含まれます。
   * 一度に複数のチャートを生成する場合に使用されます。
   */
  public final List<HighchartGenerateModel> highchartGenerateModels;

  /**
   * Highchartsライブラリのスクリプトコード
   * Highcharts JavaScriptライブラリの完全なソースコードを含む文字列です。
   * Playwrightがブラウザでチャートをレンダリングする際に、
   * このスクリプトをページに注入して使用します。
   * バージョン互換性やカスタム機能のために、
   * 特定のバージョンのHighchartsコードを指定できます。
   */
  public final String highchartsJs;

  /**
   * データキーマップ
   * レンダリング処理に必要な追加のメタデータやパラメータを格納します。
   */
  public final Map<String, Object> dataKey;

  /**
   * テーブル名のリスト
   * レンダリングに関連するデータベーステーブルの名前リストです。
   * データの取得元や処理対象のテーブルを追跡するために使用されます。
   */
  public final List<String> tableList;


  public final CompletableFuture<List<String>> future = new CompletableFuture<>();
  /**
   * コンストラクタ
   * レンダリングタスクを初期化します。すべてのパラメータは
   * レンダリング処理を実行するために必須です。
   *
   * @param highchartGenerateModels チャート生成設定のリスト
   *                                nullまたは空のリストは許可されません。
   * @param tableList テーブル名のリスト
   *                  データソースの追跡に使用されます。
   * @param dataKey メタデータとパラメータのマップ
   * @param highchartsJs Highchartsライブラリのスクリプト
   *                     nullまたは空文字列は許可されません。
   */
  public RenderTask(List<HighchartGenerateModel> highchartGenerateModels,
                    List<String> tableList,
                    Map<String, Object> dataKey,
                    String highchartsJs) {
    this.highchartGenerateModels = highchartGenerateModels;
    this.dataKey = dataKey;
    this.highchartsJs = highchartsJs;
    this.tableList = tableList;
  }
}

