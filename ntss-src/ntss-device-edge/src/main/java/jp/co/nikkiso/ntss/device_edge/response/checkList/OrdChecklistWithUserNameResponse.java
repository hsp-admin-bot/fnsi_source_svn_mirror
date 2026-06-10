package jp.co.nikkiso.ntss.device_edge.response.checkList;

import com.fasterxml.jackson.annotation.JsonProperty;

import jp.co.nikkiso.ntss.core.entity.OrdChecklist;
import lombok.Data;

@Data
public class OrdChecklistWithUserNameResponse {

  @JsonProperty("user_name")
  private String userName;

  @JsonProperty("ord_checklist")
  private OrdChecklist ordChecklist;

}
