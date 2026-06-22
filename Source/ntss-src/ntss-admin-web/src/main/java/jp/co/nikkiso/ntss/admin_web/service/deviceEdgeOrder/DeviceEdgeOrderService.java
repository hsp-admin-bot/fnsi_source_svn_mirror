package jp.co.nikkiso.ntss.admin_web.service.deviceEdgeOrder;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.request.deviceEdgeOrder.DeviceEdgeOrderRequest;
import jp.co.nikkiso.ntss.admin_web.response.deviceEdgeOrder.DeviceEdgeOrderResponse;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;

/**
 * 通信サーバー指示出しのServiceインタフェース.
 */
public interface DeviceEdgeOrderService {
  /**
   * request構造体の不足している情報をDBから取得（machineNoまたはordNoが必須）
   * @param request
   * @return
   */
  public DeviceEdgeOrderRequest findMissingData(DeviceEdgeOrderRequest request);
  /**
   * 施設内の有効なデバイスエッジをリストで返す
   * @param facilityCd
   * @return
   */
  public List<MstDeviceEdge> findMstDeviceEdgeNo(String facilityCd);

  /**
   * 通信サーバーに対して指示を出す
   * @param facilityCd 対象施設コード
   * @param deviceEdgeNo 対象デバイスエッジ番号
   * @param topicKey
   * @param payload
   * @return
   */
  public DeviceEdgeOrderResponse sendMessageToComServer(String facilityCd, Integer deviceEdgeNo, String topicKey,
      String payload);

  /**
   * 装置オプション読出し指示
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param machineNo 装置番号
   * @return
   */
  public DeviceEdgeOrderResponse orderReadOption(String facilityCd, Integer deviceEdgeNo, Long machineNo);

  /**
   * 設定値読出し
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @param ordNo
   * @return
   */
  public DeviceEdgeOrderResponse orderReadSettingValue(String facilityCd, Integer deviceEdgeNo, Long machineNo,
      Long ordNo);

  /**
   * 次患者情報転送指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @param ordNo
   * @return
   */
  public DeviceEdgeOrderResponse orderSendNextPat(String facilityCd, Integer deviceEdgeNo, Long machineNo, Long ordNo);

  /**
   * 通信サーバー設定更新指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  public DeviceEdgeOrderResponse orderReloadComsvSetting(String facilityCd, Integer deviceEdgeNo);

  /**
   * 愁訴処置マスタ更新指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  public DeviceEdgeOrderResponse orderReloadTreatMaster(String facilityCd, Integer deviceEdgeNo);

  /**
   * スタッフマスタ更新指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  public DeviceEdgeOrderResponse orderReloadStaffMaster(String facilityCd, Integer deviceEdgeNo);

  /**
   * 未登録患者割付
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @param ordNo
   * @return
   */
  public DeviceEdgeOrderResponse orderSetUnknownPat(String facilityCd, Integer deviceEdgeNo, Long machineNo,
      Long ordNo);

  /**
   * 条件送信キャンセル指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @return
   */
  public DeviceEdgeOrderResponse orderCancelCondition(String facilityCd, Integer deviceEdgeNo, Long machineNo);

  /**
   * 投薬指示変更指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @param ordNo
   * @return
   */
  public DeviceEdgeOrderResponse orderChangeIndMedi(String facilityCd, Integer deviceEdgeNo, Long machineNo,
      Long ordNo);

  /**
   * 治療時間変更指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @param ordNo
   * @return
   */
  public DeviceEdgeOrderResponse orderChangeTreatTime(String facilityCd, Integer deviceEdgeNo, Long machineNo,
                                                    Long ordNo);

  /**
   * 後体重測定指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @return
   */
  public DeviceEdgeOrderResponse orderAfterWeight(String facilityCd, Integer deviceEdgeNo, Long machineNo);

  /**
   * 治療状況確認指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @return
   */
  public DeviceEdgeOrderResponse orderCheckStatus(String facilityCd, Integer deviceEdgeNo, Long machineNo);

  /**
   * チェックリストマスタ更新指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  public DeviceEdgeOrderResponse orderReloadChecklistMaster(String facilityCd, Integer deviceEdgeNo);

  /**
   * 仮想端末キャッシュ更新指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @return
   */
  public DeviceEdgeOrderResponse orderCacheClear(String facilityCd, Integer deviceEdgeNo, Long machineNo);

  /**
   * 検査項目マスタ更新指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @return
   */
  public DeviceEdgeOrderResponse orderReloadExamMaster(String facilityCd, Integer deviceEdgeNo);

  /**
   * オフライン運転開始指示
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param machineNo 装置番号
   * @return
   */
  public DeviceEdgeOrderResponse orderStartTreatOffline(String facilityCd, Integer deviceEdgeNo, Long machineNo);

  // #11192 2025.03.26 mod 治療終了指示にオーダー番号を含める TDC片口 start
//  /**
//   * オフライン運転終了指示
//   * @param facilityCd 施設コード
//   * @param deviceEdgeNo デバイスエッジ番号
//   * @param machineNo 装置番号
//   * @return
//   */
//  public DeviceEdgeOrderResponse orderEndTreatOffline(String facilityCd, Integer deviceEdgeNo, Long machineNo);

  /**
   * オフライン運転終了指示
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param machineNo 装置番号
   * @param ordNo 治療番号
   * @return
   */
  DeviceEdgeOrderResponse orderEndTreatOffline(String facilityCd, Integer deviceEdgeNo, Long machineNo, Long ordNo);
  // #11192 2025.03.26 mod 治療終了指示にオーダー番号を含める TDC片口 end

  // add 通信サーバー通信追加 房 start
  // #10518 2024.04.19 mod 実績確定時に現患者で装置表示レポート対象であった実績の場合のみ「実績版確定時装置レポート画像更新」通知を行うメソッド定義の引数を変更 TDC米沢 start
  // /**
  //  * オフラインレポート更新
  //  * @param ordNo 治療番号
  //  * @param facilityCd 施設コード
  //  * @param deviceEdgeNo デバイスエッジ番号
  //  * @param machineNo 装置番号
  //  * @return
  //  */
  // public DeviceEdgeOrderResponse orderReportUpdate(Long ordNo, String facilityCd, Integer deviceEdgeNo, Long machineNo);
  /**
   * 実績版確定時装置レポート画像更新
   * @param patId 患者Id
   * @param ordNo 治療番号
   * @param facilityCd 施設コード
   * @return
   */
  public DeviceEdgeOrderResponse orderReportUpdate(Long patId, Long ordNo, String facilityCd);
  // #10518 2024.04.19 mod 実績確定時に現患者で装置表示レポート対象であった実績の場合のみ「実績版確定時装置レポート画像更新」通知を行うメソッド定義の引数を変更 TDC米沢 end

  /**
   * オフライン終了日更新
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param machineNo 装置番号
   * @return
   */
  public DeviceEdgeOrderResponse orderEndDateUpdate(String facilityCd, Integer deviceEdgeNo, Long machineNo);
  // add 通信サーバー通信追加 房 end

  // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うメソッド定義を追加 TDC米沢 start
  /**
   * 実績確定・削除時装置レポート画像更新
   * @param facilityCd 施設コード
   * @param patId 患者Id
   * @return
   */
  public DeviceEdgeOrderResponse orderAllReportUpdateByPatId(String facilityCd, Long patId);
  // #10518 2024.04.19 add 対象患者が現患者のベッドに対して「実績確定・削除時装置レポート画像更新」通知を行うメソッド定義を追加 TDC米沢 end

  // #10889 2024.09.05 del 治療終了処理を修正 TDC片口 start
//  // add FNSI-redime5618 fang start
//  public boolean updateOrdmainAndNextPat(Long ordNo) throws URISyntaxException;
//  // add FNSI-redime5618 fang end
  // #10889 2024.09.05 del 治療終了処理を修正 TDC片口 end

  // add FNSI-修正 5525 xugj start
  /**
   * 当該患者は次患者であるかどうかを判断する。
   * @param ordNo 治療番号
   * @return
   */
  public boolean getIsNextPatInfo(Long ordNo);

  //add FNSI-redmine6535 fang start
  /**
   * 未登録患者割付
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @param ordNo
   * @return
   */
  public DeviceEdgeOrderResponse orderSetUnknownPat(String facilityCd, Integer deviceEdgeNo, Long machineNo,
                                                    Long ordNo, Timestamp rstStartDate);
  //add FNSI-redmine6535 fang edn
  //    add 7074 2022-12-02 設定していないホスト報知が通知される 張 start
  /**
   * ホスト報知定義更新指示
   * @param facilityCd
   * @param deviceEdgeNo
   * @param machineNo
   * @return
   */
  public DeviceEdgeOrderResponse sendHostNotificationDefinition(String facilityCd, Integer deviceEdgeNo, Long machineNo,Long ordNo);
  //    add 7074 2022-12-02 設定していないホスト報知が通知される 張 end

  // #10889 2024.09.05 add 治療終了処理を修正 TDC片口 start
  enum EndTreatResponse {
    /** 成功 */
    SUCCESS,
    /** 失敗 */
    FAILED,
    /** 不要 */
    ALREADY,
    /** DE通知要求 */
    MUST_NOTIFY,
  }

  /**
   * 治療終了処理
   * @param facilityCd 施設コード
   * @param ordNo オーダーNo
   * @return オフライン治療の場合はDE通知要求を返し、それ以外の場合は治療終了処理の結果を返す
   */
  EndTreatResponse endTreat(String facilityCd, Long ordNo);
  // #10889 2024.09.05 add 治療終了処理を修正 TDC片口 end
}
