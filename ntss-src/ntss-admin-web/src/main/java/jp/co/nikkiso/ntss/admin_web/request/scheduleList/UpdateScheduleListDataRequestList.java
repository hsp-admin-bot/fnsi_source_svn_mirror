package jp.co.nikkiso.ntss.admin_web.request.scheduleList;

import jp.co.nikkiso.ntss.admin_web.service.indschedule.dto.IndscheduleChangeUserSelectedInfo;
import jp.co.nikkiso.ntss.core.dto.indSchedule.IndScheduleInfo;
import lombok.Data;

import java.util.List;

/**
 * スケジュールデータの更新処理用リクエスト
 */
@Data
public class UpdateScheduleListDataRequestList {

  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 指示者
   */
  private Long indUserId;
  /**
   * 更新者
   */
  private Long updUserId;

  private IndscheduleChangeUserSelectedInfo indscheduleChangeUserSelectedInfo;

  private List<IndScheduleInfo> beforeIndScheduleInfoList;

  private List<IndScheduleInfo> afterIndScheduleInfoList;

}
