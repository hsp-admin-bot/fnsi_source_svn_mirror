package jp.co.nikkiso.ntss.core.dao;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;

@ConfigAutowireablePersonalDb
@Dao
public interface Db6FunctionDao {

  /**
   * 個人情報DBのビットシフト暗号化関数を呼び出す
   * @param text 暗号化対象
   * @return
   */
  @Select
  String personalInfoEncrypto(String text);
  /**
   * 個人情報DBのビットシフト復号化関数を呼び出す
   * @param text 復号化対象
   * @return
   */
  @Select
  String personalInfoDecrypto(String text);
}
