package jp.co.nikkiso.ntss.core.dto.complaint;

import lombok.Data;

@Data
public class ComplaintItem {
  // modify #11342 by kangjie 20241219 start
//  private String checkFlag;
  private Integer checkFlag;
  // modify #11342 by kangjie 20241219 end
  private Integer ctl_no;
  private Integer input_class;
  private Integer row_no;
  private String occur_date;
  private Integer comp_cd;
  private String complaint;
  private Boolean is_del;
}
