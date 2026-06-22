package jp.co.nikkiso.ntss.admin_web.service.sysReleaseInfo;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.SysReleaseInfo;

/**
 * リリース情報一覧のServiceインタフェース.
 */
public interface SysReleaseInfoService {

  /**
   * リリース情報を取得
   */
  List<SysReleaseInfo> getSysReleaseInfoAll();

  /**
   * リリース明細テキストを取得
   */
  String getReleaseDetail(Long ctl_no) throws Exception;

}
