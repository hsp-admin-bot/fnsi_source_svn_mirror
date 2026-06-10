package web.logger;

import org.springframework.util.ObjectUtils;
import web.exception.ConvertException;

import java.net.InetAddress;

/**
 * ログ出力のユーティリティクラス.
 */
public class LogObjectUtils {





  /**
   * Javaアプリケーションを実行しているマシンのIPアドレスを取得する.
   * 例外が発生した場合、{@link Exception} をスローする.
   *
   * @return IPアドレス
   * @throws Exception IPアドレス取得に失敗した場合
   */
  public static String getHostAddress() throws ConvertException {
    try {
      return InetAddress.getLocalHost().getHostAddress();
    } catch (Exception e) {
      e.printStackTrace();
      throw new ConvertException("アプリケーションを実行しているマシンのIPアドレスの取得に失敗しました.", e.getCause());
    }
  }

  /**
   * Javaアプリケーションを実行しているマシンのホスト名を取得する.
   * 例外が発生した場合、{@link Exception} をスローする.
   *
   * @return IPアドレス
   * @throws Exception IPアドレス取得に失敗した場合
   */
  public static String getHostName() throws ConvertException {
    try {
      String hostName = InetAddress.getLocalHost().getHostName();
      if (!ObjectUtils.isEmpty(hostName)) {
        return hostName;
      }

      return getHostAddress();
    } catch (Exception e) {
      e.printStackTrace();
      throw new ConvertException("アプリケーションを実行しているマシンのホスト名の取得に失敗しました.", e.getCause());
    }
  }
}
