package jp.co.nikkiso.ntss.admin_web.request.statusMap;

import lombok.Getter;
import lombok.Setter;

/**
 * 治療状況マップ: {@code updateIndSchedule2} 統合リクエスト
 *
 * <p>{@link #operation} に応じて必須項目が異なる。
 * <ul>
 *   <li>{@link StatusMapIndSchedule2Operation#MOVE}: {@code facilityCd}, {@code ordNo}, {@code bedCd}, {@code userId}</li>
 *   <li>{@link StatusMapIndSchedule2Operation#SWAP}: {@code ordNo1}, {@code ordNo2}, {@code userId}</li>
 * </ul>
 */
@Getter
@Setter
public class StatusMapIndSchedule2Request {
  private StatusMapIndSchedule2Operation operation;

  /** MOVE 時: 施設コード */
  private String facilityCd;
  /** MOVE 時: 対象オーダ */
  private Long ordNo;
  /** MOVE 時: 移動先ベッド */
  private Long bedCd;

  /** SWAP 時 */
  private Long ordNo1;
  /** SWAP 時 */
  private Long ordNo2;

  private Long userId;
  /** 互換用（未使用） */
  private String isSendCondition;
}
