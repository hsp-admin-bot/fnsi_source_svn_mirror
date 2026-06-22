package jp.co.nikkiso.ntss.core.logger;

import org.springframework.util.StringUtils;

import java.io.PrintWriter;
import java.io.StringWriter;

public class ExceptionMessageUtil {
  //FNSI-修正 6358 xiebzh add start
  /**
   * エラーメッセージ取得
   * @return
   */
  public static String getErrorMessage(Exception e) {
    try {
      if (!StringUtils.isEmpty(e.getMessage())) {
        return e.getMessage();
      }
      StringWriter stringWriter = new StringWriter();
      PrintWriter writer = new PrintWriter(stringWriter);
      e.printStackTrace(writer);
      StringBuffer buffer = stringWriter.getBuffer();
      return buffer.toString();
    } catch (Exception ex){
      return ex.getMessage();
    }
  }
  //FNSI-修正 6358 xiebzh add end


}
