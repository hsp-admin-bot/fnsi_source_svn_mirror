package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.coop_api.request.HealthUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalCreateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalUpdateRequest;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

/**
 * エッジヘルスモニタデータ操作サービス
 */
public interface HealthService {

  /**
   * ヘルスモニタテーブルを指定したパラメータに更新します
   *
   * @param request 対象条件と更新する値
   * @return 更新したレコードデータ（更新対象が存在しない場合はNULLを返す）
   */
  public MntIfEdgeHealthmon update(HealthUpdateRequest request);

  /**
   * 指定したパラメータを元に ヘルスモニタテーブルを更新します
   *
   * @param request ジャーナル更新リクエスト
   */
  public void update(JournalUpdateRequest request);

  /**
   * 指定したパラメータを元に ヘルスモニタテーブルを更新します
   *
   * @param journal ジャーナル作成リクエスト
   */
  public void update(SysCoopJournal journal, String anaResult);
  /**
   * 指定したパラメータを元に ヘルスモニタテーブルを更新します
   *
   * @param request ジャーナル作成リクエスト
   */
  public void update(JournalCreateRequest request);

  /**
   * 指定したパラメータを元に ヘルスモニタテーブルを更新します
   *
   * @param request ジャーナル配信要求リクエスト
   */
  public void update(JournalDeliveryRequest request);

}
