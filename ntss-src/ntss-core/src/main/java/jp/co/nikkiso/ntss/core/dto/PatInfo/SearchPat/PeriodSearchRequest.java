package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import lombok.Data;
import java.util.List;

/**
 * AUTHOR 王
 */
@Data
public class PeriodSearchRequest {
  private String bed_group_cd;
  private List<String> machine_type_list;
  private String start_date;
  private String end_date;


}
