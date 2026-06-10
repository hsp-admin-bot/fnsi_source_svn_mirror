package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import lombok.Data;
import java.util.List;

/**
 * 日常点検画面の対象装置検索API用のリクエストパラメータクラス
 */
@Data
public class DailySearchRequest {
  private Long bedGroupCd;
  private List<String> machineTypeList;
  private String keyword;
}
