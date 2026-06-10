package jp.co.nikkiso.ntss.admin_web.service.patHomeDialysis;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.response.patHomeDialysis.DialysisStatusResponse;
import jp.co.nikkiso.ntss.admin_web.response.patHomeDialysis.DialysisWeightResponse;
import jp.co.nikkiso.ntss.core.entity.PatHhdPattern;
import jp.co.nikkiso.ntss.core.entity.custom.PatEventData;

/**
 * 在宅透析患者向けのServiceインタフェース.
 */
public interface PatHomeDialysisService {

  /**
   * 在宅透析患者向け 透析状態確認画面のResponse作成.
   * @param patId 患者ID.
   * @param facilityCd 施設コード.
   * @return 透析状態のResponse
   */
  DialysisStatusResponse createDialysisStatusResponse(Long patId, String facilityCd);

  /**
   * 在宅患者の治療条件を取得
   * @param facility_cd 施設コード
   * @return 検査結果のResponse
   */
  List<PatHhdPattern> FindPatHhdPatternByFacilityCd(String facility_cd);

  /**
   * 在宅患者の治療条件を取得
   * @param pat_id 患者ID
   * @return 検査結果のResponse
   */
  List<PatHhdPattern> FindPatHhdPatternByPatId(Long pat_id);


  /**
   * 前体重入力時：治療情報データ作成用在宅患者治療パターンファイル取得
   * @param facility_cd 施設コード
   * @param pat_id 患者ID
   * @return 検査結果のResponse
   */
  List<PatHhdPattern> getPatHhdPatternData(String facility_cd, Long pat_id);

  /**
   * 更新対象 治療情報テーブルデータ　状況確認
   * @param ord_no
   * @return dialysisWeightResponse 治療情報 体重関連データ
   */
  DialysisWeightResponse getDialysisStateByOrdNo(Long ord_no);

  /**
   * 前体重入力時：治療情報データ 条件送信前データ取得
   * @param patId
   * @param vacilityCd
   * @return
   */
  DialysisWeightResponse getDialysisWeightBefore(Long patId, String facilityCd) ;

  
  /**
   * rst_dialisys_state=1~5のデータが存在する場合にマスタの編集をできなくする。
   * @param facilityCd
   * @param arr
   * @return
   */
  DialysisWeightResponse getStatue(String facilityCd, String[] arr);
  
    /**
   * 後体重入力時：治療情報データ 条件送信前データ取得
   * @param patId
   * @param vacilityCd
   * @return
   */
  DialysisWeightResponse getDialysisWeightAfter(Long patId, String facilityCd) ;

  /**
   * 在宅患者のイベントを取得
   * @param pat_id 患者ID
   * @param startEventDate 開始日時
   * @param endEventDate 終了日時
   * @return 検索結果のResponse
   */
  List<PatEventData> findEventByPatIdNewest(Long patId, String startEventDate, String endEventDate);

  /**
   * 前体重入力時：治療情報データ 実績：体重情報更新処理
   * @param ord_no オーダ番号
   * @param weightBefore 前体重情報
   */
  boolean updateWeightBefore(Long ord_no, String weightBefore);


  /**
   * 後体重入力時：治療情報データ 実績：体重情報更新処理
   * @param ord_no オーダ番号
   * @param weightAfter 後体重情報
   */
  boolean updateWeightAfter(Long ord_no,String weightAfter);


  /**
   * 在宅患者情報登録
   * @param request 登録情報
   */
  int insert(Map<String, String> request);

  /**
   * 在宅患者登録通知の送信
   * @param patId 登録患者の内部患者ID
   */
  void registerPushNotification(Long patId);
}