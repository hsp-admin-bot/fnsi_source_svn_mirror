package jp.co.nikkiso.ntss.admin_web.response.destinationGroup;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 送信先グループ名のResponse.
 */
@AllArgsConstructor
@Getter
public class DestinationGroupNameResponse {
  /**
   * 送信先グループ名.
   */
  private String name;

  /**
   * コンストラクタ.
   */
  public DestinationGroupNameResponse() {
    name = "";
  }
}
