package jp.co.nikkiso.ntss.admin_web.response.statusList;

import com.fasterxml.jackson.databind.node.ArrayNode;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 治療状況リストのResponse.
 */
@NoArgsConstructor
@Setter
@Getter
public class TreatmentStatusListResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public TreatmentStatusListResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   * 透析装置(ベッド)
   */
  private ArrayNode dcs;
  /**
   * 供給装置
   */
  private ArrayNode dab;
  /**
   * 溶解装置
   */
  private ArrayNode dad;
  /**
   * RO装置
   */
  private ArrayNode dro;


}
