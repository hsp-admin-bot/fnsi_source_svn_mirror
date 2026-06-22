package jp.co.nikkiso.ntss.coop_api.utils;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.CreationDiv;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

@Component
public class CheckDivUtil {

  @Autowired
  private LogService logService;
  /**
   * 作成区分とレコードの相関チェック。
   *
   * @param div 作成区分
   * @param facilityCd 施設コード
   * @param obj エンティティ
   * @param tableName テーブル名
   */
  public void checkDiv(CreationDiv div, String facilityCd, Long patId, Object obj, String tableName) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    switch (div) {
      case CREATE:
        if (obj != null) {
          String errMsg = String.format(
              "作成区分[新規]に対して、%sテーブルにレコードが存在します。 facility_cd:[%s], pat_id:[%d]",
              tableName, facilityCd, patId);
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
        }
        break;

      case UPDATE:
        if (obj == null) {
          String errMsg = String.format(
              "作成区分[変更]に対して、%sテーブルにレコードが存在しません。 facility_cd:[%s], pat_id:[%d]",
              tableName, facilityCd, patId);
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
        }
        break;

      case DELETE:
        if (obj == null) {
          String errMsg = String.format(
              "作成区分[削除]に対して、%sテーブルにレコードが存在しません。 facility_cd:[%s], pat_id:[%d]",
              tableName, facilityCd, patId);
          eventLogMessage.setLogMessage(errMsg);
          eventLogMessage.setFacilityCd(facilityCd);
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          throw new NtssException(errMsg);
        }
        break;

      default:
        String errMsg = String.format("不正な作成区分が指定されました。 facility_cd:[%s], pat_id:[d], 作成区分:[%s]",
            facilityCd, patId, div.toString());
        eventLogMessage.setLogMessage(errMsg);
        eventLogMessage.setFacilityCd(facilityCd);
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
        eventLogMessage.setInvokeClass(this.getClass().getName());
        // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        throw new NtssException(errMsg);
    }
  }
}
