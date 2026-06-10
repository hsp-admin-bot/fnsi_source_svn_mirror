package jp.co.nikkiso.ntss.admin_web.request.periodicInspection;

import java.util.List;

import lombok.Data;

/**
 * 点検結果の更新処理用リクエスト
 *
 */
@Data
public class UpdateMainteMainRequest {
  /**
   * 点検日
   */
  private String mainteDate;
  /**
   * 装置番号リスト
   */
  private List<Long> machineNoList;
}
