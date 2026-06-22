package jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar;

import java.sql.Date;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCoreImpl;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.Data;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 *
 * データ施設カレンダー
 */
@Data
public class FacilityCalendar implements Cloneable {

	/**
	 *
	 * 項目名
	 */
	private String itemName;

	/**
	 *
	 * アイテム値
	 */
	private String itemValue;

	/**
	 *
	 * 日付
	 */
	private String date;

	/**
	 *
	 * 単位
	 */
	private String unit;
	/**
	 *
	 * ルーターのパス
	 */
	private String routerPath;

	/**
	 * 開始日
	 */
	private String startDate;

	/**
	 * 終了日
	 */
	private String endDate;

	// add FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou start
	/**
	 * 日付
	 */
	private Date upDate;
	// add FNSI-改修内容 施設カレンダー バグ 1行で表示されるべきものが複数行に分かれる  dou end

	@Override
	public FacilityCalendar clone() {
		FacilityCalendar fac = null;
		try {
			fac = (FacilityCalendar)super.clone();
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang start
      LogServiceCoreImpl logServiceCore = new LogServiceCoreImpl();
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (logServiceCore != null) {
        logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 add yangxuewang end
		}
		return fac;
	}

}
