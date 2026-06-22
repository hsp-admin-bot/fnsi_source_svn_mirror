package jp.co.nikkiso.ntss.admin_web.service;

import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.data.domain.Pageable;

public class SelectOptionsUtils {
  public static SelectOptions get(Pageable pageable, boolean countFlg) {
    int offset =  (int)pageable.getOffset();
    int limit = pageable.getPageSize();
    SelectOptions selectOptions = SelectOptions.get().offset(offset).limit(limit);
    if (countFlg) {
      selectOptions = selectOptions.count();
    }
    return selectOptions;
  }
}
