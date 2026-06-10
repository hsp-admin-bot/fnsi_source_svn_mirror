package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;

import lombok.Data;

/**
 *.
 */
@Data
public class BbsSearchRequest {
  private List<String> func_cd_list;
  private List<Long> kind_no_list;
  private String notice_start_date;
  private String notice_end_date;
  private String dialysis_date;
  private Long kur_cd;
  private List<Long> room_bed_group_cd;
  private String text;
  // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
  private Long limitFrom;
  private Long limitTo;
  private String userId;
  private String sortColumn;
  private String sortKind;
  private String targetUserId;
  // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
}
