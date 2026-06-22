package jp.co.nikkiso.ntss.coop_api.response;

import lombok.Data;

import java.util.List;

@Data
public class JournalNotificationResult {
  Boolean beBad;

  String message;

  List<JournalConvertResult.ResultMap> resultList ;
}
