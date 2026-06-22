package jp.co.nikkiso.ntss.core.logger;

import java.io.InputStream;
import java.net.InetAddress;
import java.nio.charset.StandardCharsets;

import jp.co.nikkiso.ntss.core.exception.NtssException;
import org.springframework.core.io.ClassPathResource;
import org.springframework.util.FileCopyUtils;
import org.springframework.util.StringUtils;

public class LogObjectUtils {

  /**
   * ReadSqlFile
   */
  public String readSqlFile(String filePath) {
    try {
      final String path = "META-INF/jp/co/nikkiso/ntss/core/dao/";
      InputStream is = new ClassPathResource(path + filePath + ".sql").getInputStream();
      String data = new String(FileCopyUtils.copyToByteArray(is), StandardCharsets.UTF_8);
      data = data.replaceAll("\\s+", " ");
      return data;
    } catch (Exception e) {
      return "";
    }
  }

  /**
   * Javaアプリケーションを実行しているマシンのホスト名を取得する.
   * 例外が発生した場合、{@link NtssException} をスローする.
   *
   * @return IPアドレス
   * @throws NtssException IPアドレス取得に失敗した場合
   */
  public static String getHostName() throws NtssException{
    try {
      String hostName = InetAddress.getLocalHost().getHostName();
      if (!StringUtils.isEmpty(hostName)) {
        return hostName;
      }

      return getHostAddress();
    } catch (Exception e) {
      e.printStackTrace();
      throw new NtssException("アプリケーションを実行しているマシンのホスト名の取得に失敗しました.", e.getCause());
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
      e.printStackTrace();
      throw new NtssException("アプリケーションを実行しているマシンのIPアドレスの取得に失敗しました.", e.getCause());
    }
  }

}
