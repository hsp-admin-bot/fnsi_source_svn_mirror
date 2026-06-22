package jp.co.nikkiso.ntss.api.service.report;

import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

/**
 * {@link ReportChartServiceImpl} の動作確認用クラス.
 *
 * 本クラスは、{@link ReportChartServiceImpl}の動作確認の為のクラスです.
 * ビルド時のテスト実行ではメソッドに「@Ignore」が付与されている為、スキップされます.
 *
 * このクラスを作成した理由は、画像作成の動作確認を行う際、確認の為に都度サーバ側の再起動を行う事で時間を要してしまう為、
 * 本クラスを使用して、{@link ReportChartServiceImpl}の動作確認を行う事を目的としています.
 * 本クラスを使用する場合、以下の変更を行い、テストを実行して下さい.
 *
 * 　1. ntss-apiのテスト用のapplication.ymlのデータベース接続先を通常使用するデータベース接続先に変更
 *     ※ntss-admin-web の application.yml のデータベース接続情報部分を上書すればOK
 *  2. {@link ReportChartServiceImpl}の186行目付近の「// 一時ファイルを削除」の処理をコメントアウトする.
 *    ※作成した一時ファイルを確認の為、削除しないようにします.
 *  3. テスト用メソッドの「@Ignore」をコメントアウトする.
 *  4. テストを実行（デバック）する.
 *
 * テストでは実データを使用します.
 * 必要に応じて、別にアプリケーションを起動させ、画面(ntss-admin-web)で入力する事で確認する事が出来ます.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
public class ReportChartServiceImplTestForDebug {
  /**
   * テスト対象クラス
   */
  @Autowired
  private ReportChartService target;

  /**
   * {@link ReportChartService#getMonitorChartData(Long, ReportChartService.ChartImageType)}の検証.
   * ※テストで使用するオーダ番号(ordNo)は必要に応じて変更して下さい.
   */
  @Test
  @Ignore
  public void test_getMonitorChartData() {
    // 事前準備
    Long ordNo = 5L;
    // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    int colWidth = 500;
    int rowHeight = 300;
    // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    // 実行
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
//    target.getMonitorChartData(ordNo, ReportChartService.ChartImageType.PNG);
    target.getPngByPlayWright(ordNo, ReportChartService.ChartImageType.PNG, false, null);
    // mod #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
  }
}
