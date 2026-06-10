package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import lombok.Data;
import java.util.List;

/**
 * add NO338 患者イベント検索条件
 * @author 劉全航
 */
@Data
public class PatEventDetailedConditions {

  private List<Long> categoryCdList;

  private String eventStartDate;

  private String eventEndDate;

}
