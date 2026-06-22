package jp.co.nikkiso.ntss.coop_api.utils;

import lombok.Getter;
//#7781 add 2022-11-24 削除電文の連携オーダ番号が取得できず内部エラーになる 卓 start
public class OrdCoopNoConstant {

  /**
   * ステータス enum
   *
   */
  @Getter
  public enum Status {
    UNPROCESS("0"),
    DONE("1");

    private String result;

    public boolean isSameResult(String target) {
      return this.result.equals(target);
    }

    Status(String result) {
      this.result = result;
    }
  }
}
//#7781 add 2022-11-24 削除電文の連携オーダ番号が取得できず内部エラーになる 卓 end

