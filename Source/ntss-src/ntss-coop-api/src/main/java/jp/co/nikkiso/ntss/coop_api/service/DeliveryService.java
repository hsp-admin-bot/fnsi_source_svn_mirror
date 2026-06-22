package jp.co.nikkiso.ntss.coop_api.service;

import java.util.List;

import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.response.DeliverSendResult;
import jp.co.nikkiso.ntss.coop_api.response.DeliveryResults;
import jp.co.nikkiso.ntss.core.entity.custom.JournalDistribute;

/**
 * delivery service
 *
 */
public interface DeliveryService {

  // add #10061、SQLパフォーマンス改善、 20231221 xugj start
  /**
   * 配信ジャーナルで[coop_result:1,8]のデータの件数を取得する
   *
   * @param facilityCd : 施設コード
   * @return 配信ジャーナル[coop_result:1,8]の件数
   */
  public int getStoppedCoopResultCount(String facilityCd);
  // add #10061、SQLパフォーマンス改善、 20231221 xugj end

  // mod 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start
//  /**
//   * 配信ジャーナル取得
//   *
//   * @param facilityCd : 施設コード
//   * @return 配信ジャーナルのList
//   */
//  public List<JournalDistribute> getDeliveryList(String facilityCd);
//
//  // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 start
//  /**
//   * リトライ配信ジャーナル取得
//   *
//   * @param facilityCd : 施設コード
//   * @return 配信ジャーナルのList
//   */
//  public List<JournalDistribute> getRetryDeliveryList(String facilityCd);
//  // add 2021-07-08 #5266:レポート再送信時の送信済みファイル取得方法について 孫 end
  /**
   * 配信ジャーナル取得
   *
   * @param facilityCd : 施設コード
   * @param stopCoopCdList : 配信停止の電文種別
   * @return 配信ジャーナルのList
   */
  public List<JournalDistribute> getDeliveryList(String facilityCd, List<String> stopCoopCdList);

  /**
   * リトライ配信ジャーナル取得
   *
   * @param facilityCd : 施設コード
   * @param stopCoopCdList : 配信停止の電文種別
   * @return 配信ジャーナルのList
   */
  public List<JournalDistribute> getRetryDeliveryList(String facilityCd, List<String> stopCoopCdList);
  // mod 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end

  // #8031 add 2022-10-15  journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 start
  /**
   * 配信処理
   *
   * @param JournalDeliveryRequest : ジャーナル配信リクエスト
   * @return ジャーナル送信結果
   */
  DeliverSendResult delivery(JournalDeliveryRequest request);
  // #8031 add 2022-10-15  journalの検知タイミングによって同じ電文が2回送信されてしまう。卓 end

  /**
   * もらった配信ジャーナルの配信結果を全て指定した配信結果に更新します
   *
   * @param journalDistributeList : 配信ジャーナルのList
   * @param  配信結果のList
   */
  public DeliveryResults execute(List<JournalDistribute> journalDistributeList);

  /**
   * もらった配信ジャーナルの配信結果を全て"1"(処理中)に更新します
   *
   * @param journalDistributeList : 配信ジャーナルのList
   */
  /* modify by chamaojia 2024-09-26 [10574] add the return value of the interface, of type [int] --start */
  public int updateProcessingByCoopResult(List<JournalDistribute> journalDistributeList);
  /* modify by chamaojia 2024-09-26 [10574] add the return value of the interface, of type [int] --end */

  /**
   * もらった配信ジャーナルの配信結果を全て"8"(応答待ち)に更新します
   *
   * @param journalDistributeList : 配信ジャーナルのList
   */
  public void updateWaitingByCoopResult(List<JournalDistribute> journalDistributeList);

}
