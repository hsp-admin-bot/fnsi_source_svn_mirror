package jp.co.nikkiso.ntss.device_edge.response.checkList;

import lombok.Data;

@Data
public class ComsvChecklistResponse {

  /**
   * チェックリストマスタ.チェックリスト設定.機能リスト.分類コード,
   */
  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  //  private Integer classCd;
  private String classCd;
  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end

  /**
   * 各マスタの主キー
   */
  private Integer code;

  /**
   * 実施状態
   */
  private String isCheck;

  /**
   * チェックリストマスタ.チェックリスト設定.機能リスト.項目番号
   */
  private Short itemNumber;

  /**
    * 項目名称
   */
  private String name;

  /**
   * 実施者更新日時
  */
  private String regStaffUpDate;
  /**
   * チェック発生日時
   */
  private String occurDate;

  /**
    * 更新日付
   */
  private String upDate;

  /**
   * 表示順
   */
  private Integer dispNo;

}
