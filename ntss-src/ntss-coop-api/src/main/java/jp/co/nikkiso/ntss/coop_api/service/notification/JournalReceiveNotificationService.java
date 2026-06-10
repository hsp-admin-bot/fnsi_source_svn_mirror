package jp.co.nikkiso.ntss.coop_api.service.notification;

import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult;
import jp.co.nikkiso.ntss.coop_api.response.JournalNotificationResult;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

import java.net.URISyntaxException;
import java.util.List;
import java.util.Map;

public interface JournalReceiveNotificationService {
  JournalNotificationResult notification(List<JournalConvertResult.ResultMap> resultList, List<SysCoopJournal> journalList,
                                         Map<Long,PatMain> orgPatMainMap,
                                         Map<Long, PatPersonalMain> orgPatPersonalMainMap,
                                         Map<Long, PatUnique> orgPatUniqueMap) throws URISyntaxException,RuntimeException ;
}
