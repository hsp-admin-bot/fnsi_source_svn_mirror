package jp.co.nikkiso.ntss.data_gathering_auto.constant;


/**
 * システム設定の管理番号の定義.
 */
public enum SysSystemDefineCtlNo {
  
  /** データ収集の処理実施サーバーのIPアドレス. */
  No2(2),
  /** 死活監視の処理実施サーバーのIPアドレス. */
  No3(3);
  
  /**
   * フィールドの定義.
   */
  private final int no;
  
  /**
   * コンストラクタの定義.
   * @param no
   */
  private SysSystemDefineCtlNo(int no) {
    this.no = no;
  }
  
  /**
   * フィールドの定義の値を取得.
   */
  public int getNo() {
    return this.no;
  }
}
