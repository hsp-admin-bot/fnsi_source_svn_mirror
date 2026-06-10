package jp.co.nikkiso.ntss.core.entity.custom;

import java.util.Map;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCoreImpl;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Getter
@Setter
@NoArgsConstructor
public class PatInsuInfo implements Cloneable {
  private Long insurance_cd;
  private Long pat_id;
  private String facility_cd;
  private Long ctl_no;
  private String fn_pat_id;
  private Integer insu_class;
  private String insu_name;
  private String insu_name_short;
  private String start_date;
  private String end_date;
  private String check_date;
  private Map<String, String> insu_info;
  private Map<String, String> insu_pub_info;
  private Map<String, String> insu_set_info;
  private Map<String, String> insu_self_info;
  private String is_selected;
  private String is_disp;
  private String is_del;
  private String coop_code;
  private String is_coop;
  private String reg_date;
  private String up_date;
  // add FNSI-排他処理 劉 start
  private String old_up_date;
  // add FNSI-排他処理 劉 end
  private String memo1;
  private String memo2;
  @Override
    public PatInsuInfo clone() {
      PatInsuInfo pat = null;
        try {
          pat = (PatInsuInfo)super.clone();
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
      return pat;
    }

  @Override
  public String toString() {
    return this.insurance_cd + " " +
    this.pat_id + " " +
    this.facility_cd + " " +
    this.ctl_no + " " +
    this.fn_pat_id + " " +
    this.insu_class + " " +
    this.insu_name + " " +
    this.insu_name_short + " " +
    this.start_date + " " +
    this.end_date + " " +
    this.check_date + " " +
    this.is_selected + " " +
    this.is_disp + " " +
    this.is_del + " " +
    this.coop_code + " " +
    this.is_coop + " " +
    this.reg_date + " " +
    this.up_date + " " +
    this.old_up_date ;
  }
}
