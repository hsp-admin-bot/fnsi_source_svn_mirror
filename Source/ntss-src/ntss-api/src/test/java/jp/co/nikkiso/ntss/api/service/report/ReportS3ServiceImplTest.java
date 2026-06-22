package jp.co.nikkiso.ntss.api.service.report;

import org.joda.time.DateTime;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

@RunWith(SpringRunner.class)
@SpringBootTest
public class ReportS3ServiceImplTest {
  /**
   * テスト対象クラス
   */
  @Autowired
  private ReportS3Service target;

  /**
   * 帳票ファイルをキャッシュするディレクトリ
   */
  @Value("${ntss.report.cache-dir}")
  private String cacheDir;

  @Before
  public void setUp() throws IOException {
    // 帳票ファイルのキャッシュをクリアする
    Path cacheDirPath = Paths.get(this.cacheDir);
    if (Files.exists(cacheDirPath)) {
      Files.list(cacheDirPath)
        .forEach(f -> f.toFile().delete());
    }
  }

  /**
   * putFile()の検証.
   *
   * 条件：なし
   * 結果：指定されたS3（疑似環境）の場所にファイルがアップロードされること
   */
  @Test
  public void test_putFile_成功() {
    // 事前準備
    String bucket = "ntss-esm";
    String filePath = "pdf/sample-data.pdf";
    String data = DateTime.now().toString();

    // 実行
    Path tmpPath = null;
    try {
      tmpPath = Files.createTempFile("ReportS3ServiceImplTest", "");
      Files.write(tmpPath, data.getBytes(StandardCharsets.UTF_8));

      try {
        target.putFile(bucket, filePath, tmpPath);
      } catch (software.amazon.awssdk.core.exception.SdkClientException e) {
        // S3疑似環境だと、アップロードに成功してから例外が発生するので無視する
      }

      byte[] file = target.getReportFile(bucket, filePath, Timestamp.valueOf("2019-09-03 09:30:00"));
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    } finally {
      if (tmpPath != null) {
        tmpPath.toFile().delete();
      }
    }
  }

  /**
   * getReportFile()の検証.
   *
   * 条件：なし
   * 結果：渡された更新日時が同一の場合はS3（疑似環境）からのファイル取得が行われないこと
   */
  @Test
  public void test_getReportFile_成功() {
    // 事前準備
    String bucket = "ntss-esm";
    String filePath = "pdf/sample-data.pdf";
    String data = DateTime.now().toString();

    // 実行
    Path tmpPath = null;
    try {
      tmpPath = Files.createTempFile("ReportS3ServiceImplTest", "");
      Files.write(tmpPath, data.getBytes(StandardCharsets.UTF_8));

      try {
        target.putFile(bucket, filePath, tmpPath);
      } catch (software.amazon.awssdk.core.exception.SdkClientException e) {
        // S3疑似環境だと、アップロードに成功してから例外が発生するので無視する
      }

      // 初回読み込み
      byte[] file1 = target.getReportFile(bucket, filePath, Timestamp.valueOf("2019-09-03 09:30:00"));

      // 更新日付同一で読み込み
      // キャッシュが効いてS3に参照に行かないはず
      byte[] file2 = target.getReportFile(bucket, filePath, Timestamp.valueOf("2019-09-03 09:30:00"));

      // 更新日付を変えて読み込み
      // S3に参照に行き、古いキャッシュファイルが消えているはず
      byte[] file3 = target.getReportFile(bucket, filePath, Timestamp.valueOf("2019-09-03 09:31:00"));

      // 生成されたキャッシュファイルの検証
      long cacheFileCnt = Files.list(Paths.get(this.cacheDir)).count();
      File cacheFile = new File(this.cacheDir, "pdf_sample-data.pdf.20190903093100.cache");
      assertThat(cacheFileCnt, is(1L));
      assertThat(cacheFile.exists(), is(true));
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    } finally {
      if (tmpPath != null) {
        tmpPath.toFile().delete();
      }
    }
  }

}
