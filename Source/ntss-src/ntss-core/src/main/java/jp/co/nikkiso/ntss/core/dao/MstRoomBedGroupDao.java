package jp.co.nikkiso.ntss.core.dao;

import java.util.List;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;

@ConfigAutowireable
@Dao
public interface MstRoomBedGroupDao {
  /*add FNSI-改修内容定期点検画面で虫眼鏡をクリックして、検索条件を選択してデータを抽出する 劉中夫  start*/
  @Select
  List<MstRoomBedGroup> selectAllBedGroup(String facilityCd);
  /*add FNSI-改修内容定期点検画面で虫眼鏡をクリックして、検索条件を選択してデータを抽出する 劉中夫  end*/

  @Select
  List<MstRoomBedGroup> selectAll(SelectOptions options, MstRoomBedGroup params);
  @Select
  List<MstRoomBedGroup> selectByFacility(String facilityCd);

  @Select
  List<MstRoomBedGroup> selectByListBedGroupCd(List<Integer> listBedGroupCd, String facilityCd);
  
  @Select
  MstRoomBedGroup selectByRoomBedGroupCd(String roomBedGroupCd);

  @Select
  int selectIndexBedCdIsContain(String bedCd, String facilityCd, String groupClass);

  // add #9323 donghao start
  @Select
  List<MstRoomBedGroup> selectByOrderCd(String facilityCd,boolean isDesc);
  // add #9323 donghao end
}
