package jp.co.nikkiso.ntss.coop_api.validator;

import java.text.ParseException;

import org.apache.commons.lang3.time.DateUtils;
import org.springframework.beans.factory.annotation.Autowired;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

/**
 * 電文項目が指定した型の表現として正しいか判別するクラス。
 */
public class TypeValidator {

  @Autowired
  //del FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
  //private static LogService logService;
  //del FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

  /**
   * 電文項目を、指定した型の文字列表現として正しいかチェックする。
   *
   * @param value 電文から切り出した項目
   * @param type 型
   * @return 正しい場合はtrue、誤りの場合はfalse
   */
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
  //public static boolean validate(String value, String type) {
  public static boolean validate(String value, String type, LogService logService) {
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    switch (type) {
    case JournalConvertConstants.TYPE_STRING:
      return TypeValidator.validateString(value);

    case JournalConvertConstants.TYPE_NUMERIC:
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //return TypeValidator.validateNumeric(value);
      return TypeValidator.validateNumeric(value, logService);
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

    case JournalConvertConstants.TYPE_DATE:
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //return TypeValidator.validateDate(value);
      return TypeValidator.validateDate(value, logService);
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

    case JournalConvertConstants.TYPE_TIME:
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      //return TypeValidator.validateTime(value);
      return TypeValidator.validateTime(value, logService);
      //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

    default:
      return true;
    }
  }

  /**
   * 文字列として正しいかチェックする。
   *
   * @param value チェック対象
   * @return 正しい場合はtrue、誤りの場合はfalse
   */
  public static boolean validateString(String value) {
    // エンコーディングは考慮しない。常に正とする。
    return true;
  }

  /**
   * 数値として正しいかチェックする。
   *
   * @param value チェック対象
   * @return 正しい場合はtrue、誤りの場合はfalse
   */
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
  //public static boolean validateNumeric(String value) {
  public static boolean validateNumeric(String value,LogService logService) {
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    try {
      Double.parseDouble(value);
      return true;
    } catch (NumberFormatException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("文字列[" + value + "]は数値として不正です。");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(TypeValidator.class.getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }
  }

  /**
   * 日付（年月日）として正しいかチェックする。<br/>
   * 2019-11-31のように書式は正しいがあり得ない日付は誤りと判定する。
   *
   * @param value チェック対象
   * @return 正しい場合はtrue、誤りの場合はfalse
   */
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
  //public static boolean validateDate(String value) {
  public static boolean validateDate(String value,LogService logService) {
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    try {
      DateUtils.parseDateStrictly(value, JournalConvertConstants.PATTERN_DATE);
      return true;
    } catch (ParseException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("文字列[" + value + "]は日付（年月日）として不正です。");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(TypeValidator.class.getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }
  }

  /**
   * 時間（時分秒）として正しいかチェックする。<br/>
   * 17:65:00のようにあり得ない時間は誤りと判定する。
   *
   * @param value チェック対象
   * @return 正しい場合はtrue、誤りの場合はfalse
   */
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
  //public static boolean validateTime(String value) {
  public static boolean validateTime(String value, LogService logService) {
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
    try {
      DateUtils.parseDateStrictly(value, JournalConvertConstants.PATTERN_TIME);
      return true;
    } catch (ParseException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("文字列[" + value + "]は時間（時分秒）として不正です。");
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(TypeValidator.class.getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }
  }
}
