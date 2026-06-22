package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCoreImpl;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 水質検査箇所マスタのEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@NoArgsConstructor
@ToString
public class WaterSurveyPoint implements Cloneable {

	/**
	 * 調査箇所コード.
	 */
	private Long surveyPointCd;

	/**
	 * 水質検査箇所名.
	 */
	private String pointName;

	/**
	 * 施設コード.
	 */
	private String facilityCd;

	/**
	 * 装置番号.
	 */
	private Long machineNo;

  //6375　検査日付・装置名・種別・検査箇所の情報を取得　add start ljx
  /**
   * 装置番号.
   */
  private String machineName;
  //6375　検査日付・装置名・種別・検査箇所の情報を取得　add end ljx

	/**
		* リスト水質調査タイプ.
		*/
	private Long surveyTypeCd;

	/**
   * 水質検査種別名.
   */
	private String surveyTypeName;

	/**
	 * 表示フラグ.
	 */
	private String isDisp;

	/**
	 * 削除フラグ.
	 */
	private String isDel;

	/**
	 * 登録日.
	 */
	private Timestamp regDate;

	/**
	 * 更新日.
	 */
	private Timestamp upDate;
	
  /**
   * 水質検査箇所マスタ並び順
   */
  private Long waterSurveyPointOrderIndex;
  /**
   * 水質検査種別マスタ並び順
   */
  private Long waterSurveyTypeOrderIndex;
  /**
   * 装置マスタ並び順
   */
  private Long machineOrderIndex;

	@Override
    public WaterSurveyPoint clone() {
		WaterSurveyPoint point = null;
        try {
        	point = (WaterSurveyPoint)super.clone();
        }catch (Exception e){
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
      return point;
    }
}
