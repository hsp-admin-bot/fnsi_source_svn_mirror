package jp.co.nikkiso.ntss.admin_web.response;

import java.util.Collections;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

import jp.co.nikkiso.ntss.core.entity.custom.Machine;
import lombok.AllArgsConstructor;

/**
 * 稼働ビューアのResponse.
 */
@AllArgsConstructor
public class MachinesResponse {
  
  /**
   * 装置のリスト.
   */
  @JsonProperty("machines")
  public List<Machine> machines;
  
  /**
   * 空の装置リストを返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public MachinesResponse() {
    this.machines = Collections.emptyList();
  }

}
