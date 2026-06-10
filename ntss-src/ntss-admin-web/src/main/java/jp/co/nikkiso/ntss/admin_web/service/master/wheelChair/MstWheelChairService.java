package jp.co.nikkiso.ntss.admin_web.service.master.wheelChair;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.wheelChair.WheelChairWithNameResponse;

public interface MstWheelChairService {

  /**
   * 施設内車いす一覧取得
   * @param facilityCd 施設コード
   * @return
   */
  List<WheelChairWithNameResponse> getWheelChairList(String facilityCd);
  /**
   * 施設内車いす一覧取得(削除済み含む)
   * @param facilityCd 施設コード
   * @return
   */
  List<WheelChairWithNameResponse> getWheelChairAllList(String facilityCd);
  /**
   * 車いす取得
   * @param patId 患者コード
   * @param facilityCd 施設コード
   * @return
   */
  List<WheelChairWithNameResponse> getWheelChairListByPatId(Long patId, String facilityCd);
  /**
   * 車いす取得
   * @param wheelChairCd 車いすコード
   * @return
   */
  WheelChairWithNameResponse getWheelChair(Long wheelChairCd);
  /**
   * 車いす取得
   * @param facilityCd 施設コード
   * @param fnWheelChairCd 施設内車いすコード
   * @return
   */
  WheelChairWithNameResponse getWheelChairByFnCd(String facilityCd, String fnWheelChairCd);
  /**
   * 校正切れチェック
   * @param facilityCd 施設コード
   * @param fnWheelChairCd 施設内車いすコード
   * @return
   */
  Boolean WheelChairCalibrationCheck(String facilityCd, Long wheelChairCd);
}
