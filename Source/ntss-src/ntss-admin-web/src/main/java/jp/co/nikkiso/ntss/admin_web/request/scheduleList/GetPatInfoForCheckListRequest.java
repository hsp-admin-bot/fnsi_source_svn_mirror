package jp.co.nikkiso.ntss.admin_web.request.scheduleList;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import java.util.List;

/**
 * /scheduleList/getPatInfoForCheckList リクエスト.
 */
@Getter
@Setter
public class GetPatInfoForCheckListRequest {

  /**
   * オーダー番号リスト（純数字のみ）.
   * フロント互換のため JSON キーは "OrdNoList" を受け付ける.
   */
  @JsonProperty("OrdNoList")
  @NotEmpty
  private List<@Pattern(regexp = "^\\d+$", message = "ordNo must be numeric") String> ordNoList;
}

