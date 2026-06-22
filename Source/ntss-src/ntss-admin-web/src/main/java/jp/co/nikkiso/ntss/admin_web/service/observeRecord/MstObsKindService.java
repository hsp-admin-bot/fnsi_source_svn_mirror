package jp.co.nikkiso.ntss.admin_web.service.observeRecord;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstObsKind;

public interface MstObsKindService {

  /**
   * 施設コードから取得する（resourceあり）
   * @param facilityCd 施設コード
   * @return
   */
  List<MstObsKind> selectAll(String facilityCd);

  /**
   * 主キーから取得する（resourceあり）
   * @param kindNo 管理番号(主キー)
   * @return
   */
  List<MstObsKind> selectByKindNo(Long kindNo);

  /**
   * 自動生成されるINSERT
   * @param param
   * @return
   */
  int insert(MstObsKind param);

  /**
   * 自動生成されるDELETE
   * @param param
   * @return
   */
  int delete(MstObsKind param);

  /**
   * 自動生成されるUPDATE
   * @param param
   * @return
   */
  int update(MstObsKind param);
}
