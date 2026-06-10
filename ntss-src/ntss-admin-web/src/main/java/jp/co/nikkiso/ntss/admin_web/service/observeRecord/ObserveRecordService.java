package jp.co.nikkiso.ntss.admin_web.service.observeRecord;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.entity.MstObsKind;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatObsRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.PatObsRecView;

import java.util.List;

public interface ObserveRecordService {

  List<MstObsKind> getMstObsKindAll(String facilityCd);

  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //List<PatObsRecView> getPatObsRecAll(String patId,String ctlNo);
  List<PatObsRecView> getPatObsRecAll(String patId,Long ctlNo);
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

  List<PatObsRecView> getPatObsRecAll(String patId,String startDate,String endDate,String isDel,String isNewest);

  List<PatObsRecView> getPatObsRecAll(Long ordNo,String isDel,String isNewest);

  List<OrdMainPatObsRecCombo> getOrdMainPatObsRecCombo(String patId, String treatDate, String ordNo, NtssUser ntssUser);

}
