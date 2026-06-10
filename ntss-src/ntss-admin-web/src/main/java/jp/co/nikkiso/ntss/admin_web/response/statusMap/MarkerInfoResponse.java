package jp.co.nikkiso.ntss.admin_web.response.statusMap;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 治療状況マップスケジュール表示マーカー情報のResponse.
 */
@NoArgsConstructor
@Setter
public class MarkerInfoResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public MarkerInfoResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * システムで管理する一意なオーダ番号
   */
  public Long ordNo;

  /**
   * 工程
   */
  public String processState;
  /**
   * 入外区分
   */
  public int inOutClass;
  /**
   * 感染症不一致フラグ
   */
  public boolean isInfectionMismatch;
  /**
   * シャント不一致フラグ
   */
  public boolean isShuntMismatch;
  /**
   * 治療方法不一致フラグ
   */
  public boolean isTreatmentMismatch;
  //add FNSI redmine5436 fang start
  /**
   * 患者イベント
   */
  public boolean isEventMismatch;
  /**
   * 検査予定
   */
  public boolean isInspectionMismatch;
  /**
   * 一般撮影検査予定
   */
  public boolean isRadiationMismatch;
  /**
   * 患者ID
   */
  public Long patId;
  /**
   * 治療日
   */
  public String treatDate;
  //add FNSI redmine5436 fang end

  //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 start
  /**
   * VA位置
   */
  public String patVaDirect;
  //add #11654 治療状況マップ＞スケジュール画面のVA方向一致不一致判定が不正 end

}
