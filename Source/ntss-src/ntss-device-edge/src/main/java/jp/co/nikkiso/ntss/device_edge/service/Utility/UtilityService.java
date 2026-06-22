package jp.co.nikkiso.ntss.device_edge.service.Utility;

public interface UtilityService {

  /**
   * 個人情報DBのビットシフト暗号化関数を呼び出す
   * @param text 暗号化対象
   * @return
   */
  String personalInfoEncrypto(String text);
  /**
   * 個人情報DBのビットシフト復号化関数を呼び出す
   * @param text 復号化対象
   * @return
   */
  String personalInfoDecrypto(String text);
}
