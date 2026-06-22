package jp.co.nikkiso.ntss.admin_web.service.deviceEdges;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.DeviceEdgesResponse;
import jp.co.nikkiso.ntss.core.dao.MstDeviceEdgeDao;
import jp.co.nikkiso.ntss.core.dao.MstStaffFacilityDao;
import jp.co.nikkiso.ntss.core.entity.custom.ChargeStaffFacility;
import jp.co.nikkiso.ntss.core.entity.custom.DeviceEdge;

/**
 * デバイスエッジ稼働監視のService実装クラス.
 */
@Service
public class DeviceEdgesServiceImpl implements DeviceEdgesService {

  /**
   * 担当者施設マスタDaoインタフェース.
   */
  @Autowired
  private MstStaffFacilityDao mstStaffFacilityDao;

  /**
   * デバイスエッジマスタDaoインタフェース.
   */
  @Autowired
  private MstDeviceEdgeDao mstDeviceEdgeDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public DeviceEdgesResponse createDeviceEdgesResponse(Long userId) {

    // ユーザIDを元に、担当者施設を取得
    List<ChargeStaffFacility> staffFacilities = mstStaffFacilityDao.selectStaffFacilities(userId);
    // 検索結果0件の場合、空のResponseを返す
    if (staffFacilities.isEmpty()) {
      return new DeviceEdgesResponse();
    }

    // 施設コードのリスト取得
    List<String> facilityCds = new ArrayList<String>();
    staffFacilities.forEach(s -> facilityCds.add(s.getFacilityCd()));

    // 施設コードに紐づくデバイスエッジ情報取得
    List<DeviceEdge> deviceEdges = mstDeviceEdgeDao.selectByFacilityCds(facilityCds);

    // 部署符号・都道府県のリスト取得
    final List<String> departmentCds = new ArrayList<String>();
    final List<List<String>> prefectures = new ArrayList<List<String>>();
    deviceEdges.forEach(d -> {
      departmentCds.add(d.getDepartmentCd());
      prefectures.add(Arrays.asList(d.getPrefCd(), d.getPrefName()));
    });

    // 部署符号リスト・都道府県リストから重複を除外
    List<String> dedupedDepartmentCds = departmentCds.stream().distinct().collect(Collectors.toList());
    List<List<String>> dedupedPrefectures = prefectures.stream().distinct().collect(Collectors.toList());

    return new DeviceEdgesResponse(dedupedDepartmentCds, dedupedPrefectures, deviceEdges);

  }

}
