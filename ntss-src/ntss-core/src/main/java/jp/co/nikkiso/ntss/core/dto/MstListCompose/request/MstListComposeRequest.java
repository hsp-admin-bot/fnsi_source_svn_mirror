package jp.co.nikkiso.ntss.core.dto.MstListCompose.request;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class MstListComposeRequest {

  /**
   * 返却対象となるリスト定義の集合
   */
  private List<MstListComposeSpec> lists;

}
