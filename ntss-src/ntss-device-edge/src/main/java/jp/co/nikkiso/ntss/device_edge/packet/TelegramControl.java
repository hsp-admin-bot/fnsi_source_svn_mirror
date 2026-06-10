package jp.co.nikkiso.ntss.device_edge.packet;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;

public class TelegramControl {

  /**
   * 受信データLF区切り1行分のTAB区切り配列から特定のキーの値を取得する
   * @param telegramLine TAB区切りした受信電文
   * @param key キー
   * @return value, keyがない場合はnull
   */
  public static String getTelegramValue(String[] telegramLine, String key) {
    
    for (String item : telegramLine) {
      if(item.startsWith(key)) {
        // key=以降の文字列を返す
        return item.substring(key.length() + 1);
      }
    }
    
    return null;
  }
  
  /**
   * 受信データ文字列を項目ごとの配列に分割する
   * @param telegram 受信データ文字列
   * @return Tab区切りした文字列配列のLF区切りされた行数分のリスト
   */
  public static ArrayList<String[]> convertTelegramToStringList(String telegram){
    
    ArrayList<String[]> returnTelegram = new ArrayList<>();
    
    // LFで分割
    String[] telegramLines = normalizeLineBreak(telegram).split("\n");
    
    for (String line : telegramLines) {
      // Tabで分割   
      returnTelegram.add(line.split("\t"));
    }
    
    return returnTelegram;
  }
  
  /**
   * セパレータのCRLFをLFにする
   * @param value
   * @return
   */
  public static String normalizeLineBreak(String value) {
    if (value == null)
        return null;

    return value.replaceAll("\\r\\n", "\n").replaceAll("\\r", "\n");
}
  
  /**
   * InputStreamの内容を文字列化する
   * @param is InputStream
   * @return 文字列
   * @throws IOException
   */
  public static String convertInputStreamToString(InputStream is) throws IOException {
    InputStreamReader reader = new InputStreamReader(is);
    StringBuilder builder = new StringBuilder();
    char[] buffer = new char[512];
    int read;
    while (0 <= (read = reader.read(buffer))) {
        builder.append(buffer, 0, read);
    }
    return builder.toString();
  }
}
