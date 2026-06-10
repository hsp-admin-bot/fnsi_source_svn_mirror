package jp.co.nikkiso.ntss.device_edge.service;

import org.springframework.beans.factory.annotation.Autowired;

/**
 * モニタデータ登録処理用スレッド
 * @author ntss
 */
public class DatabasePusherThread extends Thread {
  String strTelegram;

  @Autowired
  DatabasePusher dbPusher;


  /**
   * コンストラクタ
   * @param strTelegram 電文文字列
   */
  public DatabasePusherThread(String strTelegram) {
    this.strTelegram = strTelegram;
  }

  /**
   * DB登録処理
   */
  public void run() {
    dbPusher.run(this.strTelegram);
  }
}
