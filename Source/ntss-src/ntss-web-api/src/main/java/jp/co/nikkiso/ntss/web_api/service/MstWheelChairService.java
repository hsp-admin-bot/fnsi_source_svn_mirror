package jp.co.nikkiso.ntss.web_api.service;

import jp.co.nikkiso.ntss.web_api.response.WheelChairWithNameResponse;

import java.util.List;
//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
public interface MstWheelChairService {

  /**
   * 施設内車いす一覧取得
   * @param facilityCd 施設コード
   * @return
   */
  List<WheelChairWithNameResponse> getWheelChairList(String facilityCd);
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
   * @param isDisp 表示フラグ
   * @param isDel 削除フラグ
   * @return
   */
  WheelChairWithNameResponse getWheelChair(Long wheelChairCd, String isDisp, String isDel);
  /**
   * 車いす取得
   * @param facilityCd 施設コード
   * @param fnWheelChairCd 施設内車いすコード
   * @return
   */
  WheelChairWithNameResponse getWheelChairByFnCd(String facilityCd, String fnWheelChairCd);
}
//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
