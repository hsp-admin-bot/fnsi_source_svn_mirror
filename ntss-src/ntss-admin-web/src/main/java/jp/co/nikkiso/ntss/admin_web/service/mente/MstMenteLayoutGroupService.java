package jp.co.nikkiso.ntss.admin_web.service.mente;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroup;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayoutGroupByMachineType;

/**
 * 検査レイアウトグループのServiceインタフェース.
 */
public interface MstMenteLayoutGroupService {

  /**
   * すべての検査レイアウトグループを取得
   *
   * @param facilityCd 施設コード
   * @return 検査レイアウト一覧
   */
  List<MstMenteLayoutGroup> getAllLayoutGroup(String facilityCd) throws Exception;
  // add   吉 start
  Map<String,Object> getAllLayout(String facilityCd) throws Exception;
  // add  吉 end
  //add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27　周安寧 start
  /**
   * 対象機種のレイアウトグループ情報取得
   *
   * @param facilityCd 施設コード
   * @return 検査レイアウト一覧
   */
  List<MstMenteLayoutGroupByMachineType> getAllLayoutGroupByMachineType(String facilityCd) throws Exception;
    //add FNSI-8013 定期点検でマスタで設定した機種に該当しない定期点検が作成できる 2022/10/27　周安寧 end
}
