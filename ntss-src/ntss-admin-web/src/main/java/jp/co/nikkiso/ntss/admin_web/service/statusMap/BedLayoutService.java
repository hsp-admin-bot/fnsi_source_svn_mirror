package jp.co.nikkiso.ntss.admin_web.service.statusMap;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstStatusMapBedLayout;

public interface BedLayoutService {

  /**
   * 施設コードから一覧を取得
   * @param facilityCd (施設コード)
   * @return
   */
  List<MstStatusMapBedLayout> selectByFacilityCd(String facilityCd);

  /**
   * レイアウトＩＤから取得
   * @param layoutId レイアウトＩＤ（主キー）
   * @return
   */
  MstStatusMapBedLayout selectByLayoutId(String facilityCd, Integer layoutId);

  /**
   * 自動生成されるINSERT
   * @param param
   * @return
   */
  int insert(MstStatusMapBedLayout param);

  /**
   * 自動生成されるDELETE
   * @param param
   * @return
   */
  int delete(MstStatusMapBedLayout param);

  /**
   * 自動生成されるUPDATE
   * @param param
   * @return
   */
  int update(MstStatusMapBedLayout param);

  /**
   * resourceでSQL文を指定するInsert
   * @param param
   * @return
   */
  Long insertRenew(MstStatusMapBedLayout param);

  /**
   * 装置一覧を取得する
   * @param facilityCd
   * @return
   */
  List<MstMachine> selectMstMachineByFacilityCd(String facilityCd);

  /**
   * ベッド一覧を取得する
   * @param facilityCd
   * @return
   */
  List<MstBed> selectMstBedByFacilityCd(String facilityCd);
}
