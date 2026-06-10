package jp.co.nikkiso.ntss.coop_api.response;

import jp.co.nikkiso.ntss.core.entity.custom.JournalDistribute;
import lombok.Data;

import java.util.List;
/**
 * ジャーナル送信結果
 * */
@Data
public class DeliverSendResult {
  /**
  * ジャーナル配信レスポンス
  * */
  DeliveryResults deliveryResults;

  /**
   * 配信ジャーナルのList
   */
  List<JournalDistribute> journalDistributeList;

  /* add by chamaojia 2023-05-11 [8229] 追加方法の戻り判定パラメータ  --start */
  /**
   * リターンフラグ
   * true: メソッドリターンが必要です
   */
  boolean returnFlag;
  /* add by chamaojia 2023-05-11 [8229] 追加方法の戻り判定パラメータ  --end */

}
