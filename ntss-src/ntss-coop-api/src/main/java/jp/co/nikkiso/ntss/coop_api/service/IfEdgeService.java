package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.coop_api.request.IfEdgeWebsocketRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.response.IfEdgeRestResult;

/**
 * 連携エッジ関連のサービス
 */
public interface IfEdgeService {

  /**
   * RESTリクエスト振り分け
   *
   * @param request 連携エッジwebsocket通信リクエスト
   * @return 連携エッジ指示レスポンス
   */
  IfEdgeRestResult devide(IfEdgeWebsocketRequest request);

  /**
   * サーバ側エラー制御時連携エッジ制御指示管理更新
   *
   * @param facilityCd 施設コード
   * @param result連携エッジ指示レスポンス
   */
  void clearData(String facilityCd, IfEdgeRestResult result);

  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 start
  /**
   * ジャーナル作成時連携エッジ送信
   *
   * @param request ジャーナル作成APIリクエスト
   */
  boolean SendJournal(JournalDeliveryRequest request);
  // add 2020-11-16 各API間の呼び出しフローの修正（エッジ主体からAWS主体へ）→負荷増加回避策が必要 孫 end
}
