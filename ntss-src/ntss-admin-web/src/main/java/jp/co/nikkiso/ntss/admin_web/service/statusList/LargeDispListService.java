package jp.co.nikkiso.ntss.admin_web.service.statusList;

import jp.co.nikkiso.ntss.admin_web.response.statusList.LargeDispListResponse;

public interface LargeDispListService {
  public LargeDispListResponse getLargeDispPatList(String facilityCd, String treatDate);
}
