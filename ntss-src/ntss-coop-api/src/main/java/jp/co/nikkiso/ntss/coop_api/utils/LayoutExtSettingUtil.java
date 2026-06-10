package jp.co.nikkiso.ntss.coop_api.utils;

import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.EXT_SETTING_KEY_DEFAULT;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.EXT_SETTING_TOP_KEY_KEY;
import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.EXT_SETTING_TOP_KEY_VALUE_JSON;

import java.util.Map;

import org.apache.commons.collections.MapUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

/**
 * レイアウト拡張設定のユーティリティクラス。
 */
@Component
public class LayoutExtSettingUtil {

  @Autowired
  private LogService logService;

  /**
   * レイアウト拡張設定から電文種別詳細コードとキーを条件として電文種別詳細補足コードを取得する。（key属性用）
   *
   * @param extSetting レイアウト拡張設定
   * @param coopCdDetail 電文種別詳細コード
   * @param value 電文から抽出した値
   * @return 電文種別詳細補足コード
   */
  public String lookupExtSetting(LayoutExtSetting extSetting, String coopCdDetail, String value) {
    return lookupExtSettingCommon(extSetting, coopCdDetail, value, EXT_SETTING_TOP_KEY_KEY);
  }

  /**
   * レイアウト拡張設定から電文種別詳細コードとキーを条件として電文種別詳細補足コードを取得する。（value="json:～"属性用）
   *
   * @param extSetting レイアウト拡張設定
   * @param coopCdDetail 電文種別詳細コード
   * @param value 電文から抽出した値
   * @return 電文種別詳細補足コード
   */
  public String lookupExtSettingJsonValue(LayoutExtSetting extSetting, String coopCdDetail, String value) {
    return lookupExtSettingCommon(extSetting, coopCdDetail, value, EXT_SETTING_TOP_KEY_VALUE_JSON);
  }

  /**
   * レイアウト拡張設定から電文種別詳細コードとキーを条件として電文種別詳細補足コードを取得する。
   *
   * @param extSetting レイアウト拡張設定
   * @param coopCdDetail 電文種別詳細コード
   * @param value 電文から抽出した値
   * @param topLevelKey 拡張設定のトップレベルキー
   * @return 電文種別詳細補足コード
   */
  public String lookupExtSettingCommon(LayoutExtSetting extSetting, String coopCdDetail, String value,
      String topLevelKey) {
    EventLogMessage eventLogMessage = new EventLogMessage();

    if (MapUtils.isEmpty(extSetting)) {
      String errMsg = "レイアウト拡張設定が設定されていません。";
      eventLogMessage.setLogMessage(errMsg);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(extSetting.get(topLevelKey));
    if (MapUtils.isEmpty(m1)) {
      String errMsg = String.format("レイアウト拡張設定で%sが設定されていません。", topLevelKey);
      eventLogMessage.setLogMessage(errMsg);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    Map<String, Object> m2 = ObjectMapperUtil.castToStringObjectMap(m1.get(coopCdDetail));
    if (MapUtils.isEmpty(m2)) {
      String errMsg = String.format("レイアウト拡張設定でキー[%s]に対応する値が設定されていません。", coopCdDetail);
      eventLogMessage.setLogMessage(errMsg);
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    // 指定されたエントリが存在する場合
    // キーに対応する値を返す。
    String v = (String) m2.get(value);
    if (v != null) {
      return v;
    }

    // "_DEFAULT"エントリが存在する場合
    // デフォルト値を返す。
    v = (String) m2.get(EXT_SETTING_KEY_DEFAULT);
    if (v != null) {
      return v;
    }
    //7282----対象とならない項目があってもエラーとならないこと  LJG START
    if(v == null && coopCdDetail != null && coopCdDetail.equals("項目属性") ){
      v="空データ";
      return v;
    }
    //7282----対象とならない項目があってもエラーとならないこと  LJG END
    // エントリが存在しない場合
    // 例外を発生させる。
    String errMsg = String.format("電文から抽出した値[%s]は、キー[%s]で指定された候補と一致しません。", value, coopCdDetail);
    eventLogMessage.setLogMessage(errMsg);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    throw new NtssException(errMsg);
  }

  /**
   * レイアウト拡張設定から電文種別詳細コードとキーを条件として電文種別詳細補足コードを取得する。</br>
   * 存在しない場合はデフォルト値を返す。
   *
   * @param extSetting レイアウト拡張設定
   * @param coopCdDetail 電文種別詳細コード
   * @param value 電文から抽出した値
   * @param topLevelKey 拡張設定のトップレベルキー
   * @param defaultValue 存在しない場合のデフォルト値
   * @return 電文種別詳細補足コード
   */
  public String lookupExtSettingWithDefault(LayoutExtSetting extSetting, String coopCdDetail, String value,
      String topLevelKey, String defaultValue) {
    if (MapUtils.isEmpty(extSetting)) {
      return defaultValue;
    }

    Map<String, Object> m1 = ObjectMapperUtil.castToStringObjectMap(extSetting.get(topLevelKey));
    if (MapUtils.isEmpty(m1)) {
      return defaultValue;
    }

    Map<String, Object> m2 = ObjectMapperUtil.castToStringObjectMap(m1.get(coopCdDetail));
    if (MapUtils.isEmpty(m2)) {
      return defaultValue;
    }

    // 指定されたエントリが存在する場合
    // キーに対応する値を返す。
    String v = (String) m2.get(value);
    if (v != null) {
      return v;
    }

    // "_DEFAULT"エントリが存在する場合
    // エントリで指定された値を返す。
    v = (String) m2.get(EXT_SETTING_KEY_DEFAULT);
    if (v != null) {
      return v;
    }

    // エントリが存在しない場合
    return defaultValue;
  }
}
