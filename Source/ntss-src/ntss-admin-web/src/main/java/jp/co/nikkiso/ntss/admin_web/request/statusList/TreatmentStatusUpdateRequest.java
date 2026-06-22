package jp.co.nikkiso.ntss.admin_web.request.statusList;

import java.util.Map;

import lombok.Data;

@Data
public class TreatmentStatusUpdateRequest {

	  /**
	   * 更新対象データ(カラム名と値のMapのリスト)
	   */
	  private Map<String, Object> data;

}
