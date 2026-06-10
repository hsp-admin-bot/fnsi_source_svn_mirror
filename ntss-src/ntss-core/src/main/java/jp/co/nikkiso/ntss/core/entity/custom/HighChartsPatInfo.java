package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Data;

import java.util.List;

@Data
public class HighChartsPatInfo {

  private Long patId;

  private List<String> tempFilePaths;

  private List<Long> ordNos;
}
