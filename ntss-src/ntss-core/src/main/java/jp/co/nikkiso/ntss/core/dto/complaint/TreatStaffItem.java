package jp.co.nikkiso.ntss.core.dto.complaint;

import lombok.Data;

@Data
public class TreatStaffItem {
  private Integer ctl_no;
  private Integer row_no;
  private Integer checkFlag;
  private String occur_date;
  private Integer input_class;
  private String is_editable;
  private String cop_order_no;
  private Integer treat_staff_cd;
  private String treat_staff_name;
  private Boolean is_del;
  private Integer index;
}
