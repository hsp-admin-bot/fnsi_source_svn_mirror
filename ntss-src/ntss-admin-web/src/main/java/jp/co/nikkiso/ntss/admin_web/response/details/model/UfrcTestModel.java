package jp.co.nikkiso.ntss.admin_web.response.details.model;

import jp.co.nikkiso.ntss.admin_web.response.details.dto.UfrcTestDto;

/**
 * 配管(UFRC)自己診断結果記録のResponse返却用Model.
 */
public class UfrcTestModel extends BaseTestModel {
  /**
   * 配管(UFRC)自己診断結果のJSONオブジェクト.
   */
  public UfrcTestDto result;

  //  add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
  /**
   * 漏血自己診断結果の装置動作記録番号.
   */
  public  String recordNo;
 //  add 7801【デグレ】自己診断結果の集計が不正_再発 関 end

  /**
   * 発生日時と自己診断結果を設定するコンストラクタ.
   * 
   * @param eventRegDate イベント発生日付
   * @param eventRegTime イベント発生時刻
   * @param result 透析液流量自己診断結果
   */
//  mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start
//  public UfrcTestModel(String eventRegDate, String eventRegTime, UfrcTestDto result) {
//    // イベント発生日時
//    this.eventRegDate = eventRegDate;
//    this.eventRegTime = eventRegTime;
//    // 自己診断結果
//    this.result = result;
//  }
  public UfrcTestModel(String eventRegDate, String eventRegTime, UfrcTestDto result, String motionRecordNo) {
    // イベント発生日時
    this.eventRegDate = eventRegDate;
    this.eventRegTime = eventRegTime;
    // 自己診断結果
    this.result = result;
    this.recordNo = motionRecordNo;
  }
//  mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end
}
