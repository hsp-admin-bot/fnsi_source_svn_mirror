package jp.co.nikkiso.ntss.admin_web.response.details.model;

import jp.co.nikkiso.ntss.admin_web.response.details.dto.PipingDto;

/**
 * 配管テスト結果記録のResponse返却用Model.
 */
public class PipingModel extends BaseTestModel {

  /**
   * 配管テスト結果のJSONオブジェクト.
   */
  public PipingDto result;
  //add 8306 【デグレ】自己診断結果の値が表示されない zhao start
  public  String recordNo;
  //add 8306 【デグレ】自己診断結果の値が表示されない zhao end
  /**
   * イベント発生日時とテスト結果を設定するコンストラクタ.
   *
   * @param eventRegDate イベント発生日付
   * @param eventRegTime イベント発生時刻
   * @param result 配管テスト結果
   */
  //mod 8306 【デグレ】自己診断結果の値が表示されない zhao start
//  public PipingModel(String eventRegDate, String eventRegTime, PipingDto result) {
//    // イベント発生日時
//    this.eventRegDate = eventRegDate;
//    this.eventRegTime = eventRegTime;
//    // テスト結果
//    this.result = result;
//  }
  public PipingModel(String eventRegDate, String eventRegTime, PipingDto result, String motionRecordNo) {
    // イベント発生日時
    this.eventRegDate = eventRegDate;
    this.eventRegTime = eventRegTime;
    // テスト結果
    this.result = result;
    this.recordNo = motionRecordNo;
  }
  //mod 8306 【デグレ】自己診断結果の値が表示されない zhao end

}
