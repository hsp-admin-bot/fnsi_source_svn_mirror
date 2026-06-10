package jp.co.nikkiso.ntss.admin_web.response.creatingReport;

import jp.co.nikkiso.ntss.core.entity.MstReport;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

/**
 * 帳票マスタ取得のResponse.
 */
@AllArgsConstructor
@Getter
public class MstReportResponse {

  /**
   * 帳票マスタ情報.
   */
  private List<MstReport> mstReports;

  /**
   * プレビューフラグ（"1":する "0":しない）.
   */
  private String isPreview;

  /**
   * プリンター情報.
   */
  private List<PrinterInfo> printerInfos;

}
