package jp.co.nikkiso.ntss.admin_web.request.statusList;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Getter
@Setter
public class DeleteRecordRequest {
  /**
   * 治療番号
   */
  private Long ordNo;
}
