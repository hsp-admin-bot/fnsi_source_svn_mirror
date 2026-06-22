package jp.co.nikkiso.ntss.coop_api.mapping;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Getter;
import lombok.Setter;

/**
 * PDFファイル名
 * mst_coop_filename.pdf_nameのマッピング
 */
@Getter
@Setter
public class PdfName {
  /** レポートCD */
  @JsonProperty("report_cd")
  private Long reportCd;
  /** ファイル名 */
  @JsonProperty("name")
  private Map<String, Object> name;
}
