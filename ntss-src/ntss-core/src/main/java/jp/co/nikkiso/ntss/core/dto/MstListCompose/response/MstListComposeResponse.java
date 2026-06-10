package jp.co.nikkiso.ntss.core.dto.MstListCompose.response;

import lombok.Getter;
import lombok.Setter;

import java.util.Map;

@Getter
@Setter
public class MstListComposeResponse {

  /**
   * key = ListSpec.id
   * value = 对应列表
   */
  private Map<String, MstListComposeWrapper> lists;
}
