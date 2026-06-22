package jp.co.nikkiso.ntss.data_gathering.logger;

import jp.co.nikkiso.ntss.data_gathering.exception.NtssException;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.FileCopyUtils;

import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;
import java.nio.charset.StandardCharsets;

/**
 * ログ出力のユーティリティクラス.
 */
public class LogObjectUtilsDataGathering {

  /**
   * SQLファイルのベースディレクトリパス
   */
  private static final String BASE_SQL_DIR = "META-INF/jp/co/nikkiso/ntss/data_gathering/dao/";

  /**
   * SQLファイルに記述されているSQL文を取得する.
   *
   * @param filePath SQLパス(Dao名/SQLファイル名)
   *                 ※指定するSQLファイル名には拡張子は不要
   * @return SQL文
   */
  public static String readSqlFile(String filePath) throws IOException {
    InputStream is = null;
    try {
      is = new ClassPathResource(BASE_SQL_DIR + filePath + ".sql").getInputStream();
      String data = new String(FileCopyUtils.copyToByteArray(is), StandardCharsets.UTF_8);
      data = data.replaceAll("\\s+", " ");
      return data.trim();
    } catch (Exception e) {
      return "";
    } finally {
      if (is != null) {
        try {
          is.close();
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
          throw new IOException("SQLファイルのクローズに失敗しました。", e);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
        }
      }
    }
  }

  /**
   * Javaアプリケーションを実行しているマシンのIPアドレスを取得する.
   * 例外が発生した場合、{@link NtssException} をスローする.
   *
   * @return IPアドレス
   * @throws NtssException IPアドレス取得に失敗した場合
   */
  public static String getHostAddress() throws NtssException{
    try {
      return InetAddress.getLocalHost().getHostAddress();
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      throw new NtssException("アプリケーションを実行しているマシンのIPアドレスの取得に失敗しました.", e.getCause());
    }
  }
}
