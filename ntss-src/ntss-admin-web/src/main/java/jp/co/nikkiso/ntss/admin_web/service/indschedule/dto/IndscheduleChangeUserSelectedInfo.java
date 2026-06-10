package jp.co.nikkiso.ntss.admin_web.service.indschedule.dto;

import lombok.Data;


@Data
public class IndscheduleChangeUserSelectedInfo {

  /**
   * 施設設定マスタにNo７の「検査依頼」に選択肢「４」を選択して、手動選択した値
   *
   */
  private String facilitySetting1007SelectedVal;

  /**
   * 施設設定マスタにNo8の「一般撮影検査依頼」に選択肢「４」を選択して、手動選択した値
   */
  private String facilitySetting1008SelectedVal;

  /**
   * 施設設定マスタにNo105の「患者イベント変更機能」に選択肢「４」を選択して、手動選択した値
   */
  private String facilitySetting3005SelectedVal;

  /**
   * スケジュールdupulicate更新モード
   */
  private String dupulicateUpdateMode;

  /**
   * 実績更新あり？
   */
  private String updateRst;

  /**
   * 検査依頼締切Action
   */
  private String examDeadlineSelectedVal;

  /**
   * 一般撮影検査依頼締切Action
   */
  private String radDeadlineSelectedVal;


}
