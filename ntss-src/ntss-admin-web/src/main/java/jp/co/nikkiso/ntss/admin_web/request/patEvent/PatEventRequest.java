package jp.co.nikkiso.ntss.admin_web.request.patEvent;

import jp.co.nikkiso.ntss.core.entity.PatEvent;
import lombok.Data;

@Data
public class PatEventRequest {
	  /**
	   * 期間指定区分モード
	   */
	  private String mode;
	  /**
	   * 期間開始
	   */
	  private String startDate;
	  /**
	   * 期間終了
	   */
	  private String endDate;
	  /**
	   * 作成間隔
	   */
	  private String interval;
	  /**
	   * 毎週・毎月の曜日・月区分
	   */
	  private String[] intervalClass;

	  /**
	   * 開始時刻
	   */
      private String startTime;
      /**
       * 日付区分
       */
      private String dateClass;

      /**
       * 終了時刻
       */
      private String endTime;

	  /**
	   * 指示情報
	   */
	  private PatEvent patEventParam;

      /**
       * 通知フラグ
       */
      private Boolean isNotification;
}
