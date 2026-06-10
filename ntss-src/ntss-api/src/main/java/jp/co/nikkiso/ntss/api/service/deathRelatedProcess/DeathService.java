package jp.co.nikkiso.ntss.api.service.deathRelatedProcess;


import jp.co.nikkiso.ntss.api.model.JournalCreateRequestPayload;

import java.text.ParseException;
import java.util.List;

public interface DeathService {

  // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm start
//  List<JournalCreateRequestPayload> deathRelatedProcess(String facilityCd, List<Long> patIdList, Long updId) throws ParseException;
  List<JournalCreateRequestPayload> deathRelatedProcess(String facilityCd, List<Long> patIdList, Long updId, String actionMode) throws ParseException;
  // mod 12005 患者削除時の予定中止は行われるが検査依頼・一般撮影検査依頼の削除が行われない zkm end
}
