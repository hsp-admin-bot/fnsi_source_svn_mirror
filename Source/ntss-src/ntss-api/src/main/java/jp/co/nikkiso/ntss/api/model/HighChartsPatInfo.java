package jp.co.nikkiso.ntss.api.model;

import lombok.Data;

import java.util.List;

@Data
public class HighChartsPatInfo {

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * 一時ファイルパース
   */
  private List<String> tempFilePaths;
}
