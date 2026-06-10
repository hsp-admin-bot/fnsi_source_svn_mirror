package jp.co.nikkiso.ntss.admin_web.response.weight;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import lombok.NoArgsConstructor;

/**
 * 条件送信時のResponse.
 */
@NoArgsConstructor
public class WeightKurBedResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public WeightKurBedResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 絞り込みクールリスト.
   */
  public List<MstSelector.Item> kurSelector;

  /**
   * ベッドグループ
   */
  public List<MstRoomBedGroup> bedGroupList;
}
