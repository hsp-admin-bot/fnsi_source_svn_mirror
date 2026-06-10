package jp.co.nikkiso.ntss.admin_web.request.scheduleList;

import lombok.Data;

/**
 * スケジュールデータの更新処理用リクエスト
 *
 */
@Data
public class UpdateScheduleListDataRequest {
  /**
   * 対象オーダー番号
   */
  private Long ordNo;
  /**
   * 対象患者
   */
  private String patId;
  /**
   * 元の治療予定日
   */
  private String condTreatDate;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 新しい治療予定日
   */
  private String newTreatDate;
  /**
   * クールコード
   */
  private Long kurCd;
  /**
   * ベッドコード
   */
  private Long bedCd;
  /**
   * 指示者
   */
  private Long indUserId;
  /**
   * 更新者
   */
  private Long updUserId;

  // FNSI-add 現行改善対応425 孫灝 20201117 start
  /**
   * 施設設定マスタにNo７の「検査依頼」に選択肢「４」を選択して、手動選択した値
   */
  private int facilitySetting1007SelectedVal;

  /**
   * 施設設定マスタにNo8の「一般撮影検査依頼」に選択肢「４」を選択して、手動選択した値
   */
  private int facilitySetting1008SelectedVal;
  // FNSI-add 現行改善対応425 孫灝 20201117 end

  /**
   * add FNSI 1006 No.426 20201224 -- Sanjingye Sun
   * 施設設定マスタにNo105の「患者イベント変更機能」に選択肢「４」を選択して、手動選択した値
   */
  private int facilitySetting3005SelectedVal;
  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正  zhao start
  private String isSamePatId;
  //add #10409 施設設定マスタNo7, 8の設定を4にした際の動作不正  zhao end
}
