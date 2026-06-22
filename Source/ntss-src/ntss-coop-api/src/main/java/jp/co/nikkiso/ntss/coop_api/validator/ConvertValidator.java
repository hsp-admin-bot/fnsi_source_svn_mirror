package jp.co.nikkiso.ntss.coop_api.validator;

import java.util.List;

import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
import jp.co.nikkiso.ntss.coop_api.service.LogService;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

public class ConvertValidator {

  /**
   * TEXT形式電文の整合性を調べる。
   *
   * @param value 電文から切り出した項目
   * @param message 電文全体
   * @param index 電文中の位置
   * @param item レイアウト項目指定
   * @throws NtssException 不整合の場合
   */
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
  //public static void validateText(String value, byte[] message, int index, Item item ,LogService logService) {
  public static void validateText(String value, byte[] message, int index, Item item ,LogService logService) {
  //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end

    // type属性が指定されている場合
    // 指定された型の文字列表現として正しいか検証する。
    String type = item.getType();

    if (!StringUtils.isEmpty(type)) {
      // 日付型で特定文字列の場合はチェックしない
      if (!(JournalConvertConstants.TYPE_DATE.equals(type) && JournalConvertConstants.DIE_DATE_ALIVE.equals(value))) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
        //if (!TypeValidator.validate(value, type, logService)) {
        if (!TypeValidator.validate(value, type, logService)) {
        //mod FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
          String errMsg = String.format("type属性が指定された項目に不正な値があります。項目名:[%s], 値:[%s], type:[%s]",
              item.getName(), value, type);
          throw new NtssException(errMsg);
        }
      }
    }

    // 終端判定
    // term属性=trueが指定されている場合、未処理の文字列が残っていればエラーとする。
    if (item.getTerm() && index < message.length) {
      // エラー処理
      throw new NtssException("term=trueを指定された項目の後にデータが残っています。");
    }

    // 電文長判定
    // messageLen=trueが指定された項目が存在する場合、lenの長さを切り出して整数に変換し、想定される電文長とする。
    // その値と実際の電文長が一致しなければエラーとする。
    if (item.getMessageLen() && Integer.parseInt(value) != message.length) {
      throw new NtssException("電文長として指定された値と実際の電文長が一致しません。");
    }
  }

  /**
   * CSV形式電文の整合性を調べる。
   *
   * @param value 電文から切り出した項目
   * @param csvItemList 項目全体
   * @param index 電文中の位置
   * @param item レイアウト項目指定
   * @throws NtssException 不整合の場合
   */
  public static void validateCsv(String value, List<String> csvItemList, int index, Item item) {

    // TODO 未実装
  }
}
