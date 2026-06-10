package jp.co.nikkiso.ntss.core.dto.complaint;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class TreatmentItem {
  private Integer checkFlag;
  private Integer ctl_no;
  private Integer input_class;
  private Integer row_no;
  private String occur_date;
  private Integer treat_class;
  private Integer treat_cd;
  private String treat_name;
  private Integer medicine_cd;
  private Integer medicine_name;
  private BigDecimal amount;
  private String unit;
  private Integer procedure_cd;
  private String procedure_name;
  private Integer medicine_type;
  private Integer treat_medicine_cd;
  private String treat_medicine_name;
  private String oxygen_start;
  private Integer oxygen_time;
  private BigDecimal oxygen_amount;
  private BigDecimal oxygen_speed;
  private String cop_order_no;
  private String is_editable;
  private Integer electrocardiogram_type;
  private String electrocardiogram_start;
  private Integer over_time;
  private String linkStartDate;
  private Boolean is_del;
  private Integer index;
}
