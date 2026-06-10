package jp.co.nikkiso.ntss.api.model;

import lombok.Data;

@Data
public class PatReportInfo {

  private Long patId;

  private String fileName;

  private int fileIndex;

  private Long ordNo;
}
