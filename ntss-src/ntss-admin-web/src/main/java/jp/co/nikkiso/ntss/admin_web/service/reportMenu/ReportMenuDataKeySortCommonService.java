// add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 start
package jp.co.nikkiso.ntss.admin_web.service.reportMenu;

import java.text.ParseException;
import java.util.Map;

public interface ReportMenuDataKeySortCommonService {
  void dataKeySortCommonMeth(Long reportCd, Map<String, Object> dataKey) throws ParseException;
}
// add #11257 機能帳票の出力に帳票保存のソート条件を適用する 高 end
