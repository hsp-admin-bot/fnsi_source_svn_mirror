// #11827 2025.05.16 add 仮想端末姓名結合サービス TDC米沢 start
package jp.co.nikkiso.ntss.api.service.NameConcat;

// 姓名結合処理サービス
public interface NameConcatService {
  /**
   * 施設設定値取得
   *
   * @param facilityCd    施設コード
   * @param facilityKeyCd 施設キー値
   */
  public void ReadFacilitySettingValue(String facilityCd, String facilityKeyCd);
// #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 add yangxuewang start
  /**
   * スレッドローカルの施設設定値をクリア
   */
  public void ClearFacilitySettingValue();
// #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 add yangxuewang end
  /**
   * 姓名結合
   *
   * @param firstName 姓
   * @param lastName  名
   * @return 施設設定により結合した姓名を返す
   */
  public String NameConcat(String firstName, String lastName);
  /**
   * 姓名結合
   *
   * @param settingValue  設定値(0:全角スペース、1:半角スペース、2:なし)
   * @param firstName     姓
   * @param lastName      名
   * @return 設定値により結合した姓名を返す
   */
  public String NameConcat(int settingValue, String firstName, String lastName);
}
// #11827 2025.05.16 add 仮想端末姓名結合サービス TDC米沢 end
