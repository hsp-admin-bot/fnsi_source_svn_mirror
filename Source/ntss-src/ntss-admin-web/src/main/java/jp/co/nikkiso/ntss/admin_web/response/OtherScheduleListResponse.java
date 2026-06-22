package jp.co.nikkiso.ntss.admin_web.response;

import java.util.HashMap;
import java.util.Set;

import lombok.AllArgsConstructor;

/**
 *　スケジュール表、その他予定リストのResponse.
 */
@AllArgsConstructor
public class OtherScheduleListResponse {

  /**
   * 検査依頼のリスト.
   */
  public HashMap<String, Set<Long>> examList;

  /**
   * 放射線検査依頼のリスト.
   */
  public HashMap<String, Set<Long>> radList;

  /**
   * 患者イベントのリスト.
   */
  public HashMap<String, Set<Long>> eventList;
  
  /**
   * 定期点検のリスト.
   */
  public HashMap<String, Set<Long>> mainteList;
  
  /**
   * 水質管理のリスト.
   */
  public HashMap<String, Set<Long>> waterSurveyList;
}
