package jp.co.nikkiso.ntss.admin_web.response.details.model;

import jp.co.nikkiso.ntss.admin_web.response.details.dto.BloodLeakageTestDto;

/**
 * 漏血自己診断結果記録のResponse返却用Model.
 */
public class BloodLeakageTestModel extends BaseTestModel {
  
  /**
   * 漏血自己診断結果のJSONオブジェクト.
   */
  public BloodLeakageTestDto result;
  
//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 start
  /**
   * 漏血自己診断結果の装置動作記録番号.
   */
  public  String recordNo;
//  add 7801【デグレ】自己診断結果の集計が不正_再発 関 end

  /**
   * イベント発生日時と自己診断結果を設定するコンストラクタ.
   * 
   * @param eventRegDate イベント発生日付
   * @param eventRegTime イベント発生時刻
   * @param result 漏血自己診断結果
   */
//  mod 7801【デグレ】自己診断結果の集計が不正_再発 関 start
//  public BloodLeakageTestModel(String eventRegDate, String eventRegTime, BloodLeakageTestDto result) {
//    // イベント発生日時
//    this.eventRegDate = eventRegDate;
//    this.eventRegTime = eventRegTime;
//    // 自己診断結果
//    this.result = result;
//  }
  public BloodLeakageTestModel(String eventRegDate, String eventRegTime, BloodLeakageTestDto result,String motionRecordNo) {
    // イベント発生日時
    this.eventRegDate = eventRegDate;
    this.eventRegTime = eventRegTime;
    // 自己診断結果
    this.result = result;
    this.recordNo = motionRecordNo;
  }
//  mod 7801【デグレ】自己診断結果の集計が不正_再発 関 end
}
