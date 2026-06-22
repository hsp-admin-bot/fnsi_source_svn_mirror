package jp.co.nikkiso.ntss.core.dto.MstListCompose.response;

import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

@Getter
@Setter
public class MstListComposeResponse {

  /**
   * key = ListSpec.id
   * value = 对应列表
   */
  private List<Map<String, MstListComposeWrapper>> filterList;

  private MstListComposeWrapper master;
}
