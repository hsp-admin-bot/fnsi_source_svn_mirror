package jp.co.nikkiso.ntss.admin_web.request.rad;

import lombok.Data;

import java.util.List;

/**
 * 放射線検査依頼APIのRequestクラス.
 */
@Data
public class RadRequest {

  /**
   * 患者IDリスト.
   */
  private List<Long> patIdList;
  
  /**
   * 表示期間(開始日).
   */
  private String startDate;
  
  /**
   * 表示期間(終了日).
   */
  private String endDate;

  //add #12462 患者共有情報 by zrx start
  /**
   * 自施設(1) or 他施設(0)
   */
  private Integer patientShareMode;
  //add #12462 患者共有情報 by zrx end

}
