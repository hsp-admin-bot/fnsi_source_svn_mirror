package jp.co.nikkiso.ntss.admin_web.service.reportMenu;

import jp.co.nikkiso.ntss.admin_web.request.creatingReport.ReportByCdRequest;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.OrdMain;

import java.text.ParseException;
import java.util.List;
import java.util.Map;

// add #9558 機能帳票で正しく変数が引き渡されていない 高 start
public interface ReportMenuDataKeyService {
  Map<String, Object> setDataKeyMeth(Long reportCd, MstReport report, ReportByCdRequest request, NtssUser ntssUser, List<OrdMain> ordNosList) throws ParseException;

  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
  Map<String,Object> searchReportSettingForDataKey(String facilityCd, Long reportCd, Map<String, Object> dataKey);
  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

  // add #12107 帳票印刷失敗通知が行われない limingzhe start
  String getReportClassName(Integer reportClass);
  // add #12107 帳票印刷失敗通知が行われない limingzhe end
}
// add #9558 機能帳票で正しく変数が引き渡されていない 高 end
