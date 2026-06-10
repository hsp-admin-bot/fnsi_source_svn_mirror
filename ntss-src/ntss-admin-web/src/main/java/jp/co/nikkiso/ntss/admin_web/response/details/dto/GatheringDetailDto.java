package jp.co.nikkiso.ntss.admin_web.response.details.dto;

import lombok.Data;

/**
 * データ収集記録のJSON格納クラス.
 */
@Data
public class GatheringDetailDto {

  /**
   * ファイル名.
   */
  private String filename;
  /**
   * ファイルパス.
   */
  private String path;
}
