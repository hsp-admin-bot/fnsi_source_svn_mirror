package jp.co.nikkiso.ntss.core.entity;

import lombok.Data;

@Data
public class DataListAggregationParam {

  private Long dataListDetailCd;

  private Integer itemId;

  private String dateFrom;

  private String dateTo;

  private Integer type;

  private Integer kubun;
}
