// #11827 2025.05.16 add 仮想端末姓名結合サービス TDC米沢 start
package jp.co.nikkiso.ntss.api.service.NameConcat;

import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * {@link NameConcatService}の実装クラス.
 */
@Service
public class NameConcatServiceImpl implements NameConcatService {

  /**
   * ログ処理
   */
  @Autowired
  private LogService logService;

  /**
   * DB access
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  /**
   * 姓名結合設定値
   */
  public static final class NameConcatType {
    // 設定値：0(全角スペース)
    public static final int FULL_WIDTH_SPACE = 0;
    // 設定値：1(半角スペース)
    public static final int HALF_WIDTH_SPACE = 1;
    // 設定値：2(なし)
    public static final int NONE  = 2;
  };
  // 設定値による結合文字(0:全角スペース、1:半角スペース、2:なし)
  private static final String[] ConcatChar = {"　", " ", ""};

  /**
   * 施設設定値
   */
  // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
//  private int settingValue = NameConcatType.FULL_WIDTH_SPACE;
  private final ThreadLocal<Integer> settingValue = ThreadLocal.withInitial(
    () -> NameConcatType.FULL_WIDTH_SPACE
  );
  // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end

  /**
   * 設定値チェック
   *
   * @param value 設定値
   * @return 有効な設定値を返す(範囲外の場合は0)
   */
  private static int checkSettingValue(int value) {
    // 設定値範囲チェック
    if (value < NameConcatType.FULL_WIDTH_SPACE || NameConcatType.NONE < value) {
      // 設定範囲外の場合は初期値
      value = NameConcatType.FULL_WIDTH_SPACE;
    }
    return value;
  }
  /**
   * 姓名結合
   *
   * @param settingValue  設定値(0:全角スペース、1:半角スペース、2:なし)
   * @param firstName     姓
   * @param lastName      名
   * @return 結合文字により結合した姓名を返す
   */
  private static String NameConcatFunc(int settingValue, String firstName, String lastName) {
    return
      (lastName == null ? "" : lastName)
        + ConcatChar[checkSettingValue(settingValue)]
        + (firstName == null ? "" : firstName);
  }

  /**
   * 施設設定値取得
   *
   * @param facilityCd    施設コード
   * @param facilityKeyCd 施設キー値
   */
  public void ReadFacilitySettingValue(String facilityCd, String facilityKeyCd) {
    try {
      FacilitySettingInfo rec = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, facilityKeyCd);
      if(rec != null) {
        // 設定値取得
        // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
        settingValue.set(checkSettingValue(Integer.parseInt(rec.getValue())));
        // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
      }
    } catch (Exception ex) {
      //
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(facilityCd);
      eventLogMessage.setLogMessage("NameConcatServiceImpl：施設設定値取得[" + facilityCd + "/" + facilityKeyCd + "]に失敗" + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS, null);
    }
  }

  // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 add yangxuewang start
  /**
   * スレッドローカルの施設設定値をクリア
   */
  public void ClearFacilitySettingValue() {
    settingValue.remove();
  }
  // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 add yangxuewang end

  /**
   * 姓名結合
   *
   * @param firstName 姓
   * @param lastName  名
   * @return 施設設定により結合した姓名を返す
   */
  public String NameConcat(String firstName, String lastName) {
    return NameConcatFunc(
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
      this.settingValue.get(),
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
      firstName,
      lastName);
  }
  /**
   * 姓名結合
   *
   * @param settingValue  設定値(0:全角スペース、1:半角スペース、2:なし)
   * @param firstName     姓
   * @param lastName      名
   * @return 設定値により結合した姓名を返す
   */
  public String NameConcat(int settingValue, String firstName, String lastName) {
    return NameConcatFunc(
      settingValue,
      firstName,
      lastName);
  }
}
// #11827 2025.05.16 add 仮想端末姓名結合サービス TDC米沢 end
