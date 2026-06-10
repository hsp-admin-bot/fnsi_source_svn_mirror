package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;
import lombok.Data;

/**
 * 簡易検索リクエスト
 */
@Data
public class SimpleSearchRequest {
  private OrdScheduleSimpleConditions ord_schedule;
  private List<Long> patIdList;
  private List<String> facilityCdList;
  private PatGroupSearchRequest patGroupSearch;
}