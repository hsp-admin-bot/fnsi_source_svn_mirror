package jp.co.nikkiso.ntss.admin_web.service.facilities;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebMessage;
import jp.co.nikkiso.ntss.admin_web.response.StaffFacilitySettingsResponse;
import jp.co.nikkiso.ntss.admin_web.response.facilities.FacilitiesResponse;
import jp.co.nikkiso.ntss.admin_web.response.facilities.Facility;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacility;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacilityResponse;
import jp.co.nikkiso.ntss.core.dao.FacilityDao;
import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstStaffFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.MstStaffFacility;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.custom.ChargeStaffFacility;
import jp.co.nikkiso.ntss.core.entity.custom.NoticeCounts;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * 施設系のService実装クラス.
 */
@Service
public class FacilitiesServiceImpl implements FacilitiesService {

  /**
   * 担当者施設マスタDaoインタフェース.
   */
  @Autowired
  private MstStaffFacilityDao mstStaffFacilityDao;

  /**
   * 装置状態管理Daoインタフェース.
   */
  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  /**
   * 利用者マスタDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  /**
   * 施設マスタDaoインタフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /**
   * 施設マスタ（ユーザメニュー系）のDaoインタフェース.
   */
  @Autowired
  private FacilityDao facilityDao;

  /**
   * 装置動作記録のDaoインタフェース.
   */
  @Autowired
  private MntMotionRecordDao mntMotionRecordDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public FacilitiesResponse createFacilitiesResponse(Long userId, boolean isNkkFacility) {

    // ユーザIDを元に、担当者施設を取得
    // mod FNSI redmine #4243 修正 鄧シン start
    // List<ChargeStaffFacility> staffFacilities = mstStaffFacilityDao.selectStaffFacilities(userId);
    List<ChargeStaffFacility> staffFacilities = mstStaffFacilityDao.selectStaffFacilitiesOrderByPrefCd(userId);
    // mod FNSI redmine #4243 修正 鄧シン end
    // 検索結果0件の場合、空のResponseを返す
    if (staffFacilities.isEmpty()) {
      return new FacilitiesResponse();
    }

    // 装置状態管理マスタから施設コードに紐づくデータをリストで取得
    List<Facility> facilities = new ArrayList<Facility>();
    List<String> departmentCds = new ArrayList<String>();
    List<List<String>> prefectures = new ArrayList<List<String>>();

    for (ChargeStaffFacility staffFacility : staffFacilities) {
      String facilityCd = staffFacility.getFacilityCd();
      // 施設ごとに、各項目の通知件数を取得
      NoticeCounts noticeCounts = Optional.ofNullable(
          mntMachineStateDao.selectNoticeCounts(facilityCd)).orElse(new NoticeCounts());

      // 日機装施設の場合はサービス対応件数が1以上の場合に最大イベント発生日時を取得する.
      // それ以外の場合には、対処件数が1以上の場合に最大イベント発生日時を取得する.
      Timestamp maxEventRegDate = null;
      if (isNkkFacility ? noticeCounts.getServiceSupportCnt() > 0 : noticeCounts.getMNoticeCnt() > 0) {
        maxEventRegDate = mntMotionRecordDao.selectMaxEventRegDateByFacilityCd(
          facilityCd,
          null,
          null,
          isNkkFacility);
      }

      String departmentCd = staffFacility.getDepartmentCd();
      String prefCd = staffFacility.getPrefecturesCd();
      String prefName = staffFacility.getPrefecturesName();
      // 施設情報生成
      Facility facility = new Facility(facilityCd,
          departmentCd, prefCd, staffFacility.getPrefecturesName(), staffFacility.getFacilityName(),
          noticeCounts.getMNoticeCnt(), noticeCounts.getPreventiveCnt(), noticeCounts.getComProblemCnt(),
          staffFacility.getFacilityNameKana(), noticeCounts.getServiceSupportCnt(), maxEventRegDate);
      // レスポンスに値を詰める
      facilities.add(facility);
      departmentCds.add(departmentCd);
      prefectures.add(Arrays.asList(prefCd, prefName));
    }

    // 部署符号リスト・都道府県名リストから重複を除外
    departmentCds = departmentCds.stream().distinct().collect(Collectors.toList());
    prefectures = prefectures.stream().distinct().collect(Collectors.toList());

    return new FacilitiesResponse(departmentCds, prefectures, facilities);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  public StaffFacilityResponse getStaffFacility(Long userId) {
    // 全施設の一覧を取得
    List<StaffFacility> staffFacilities = mstStaffFacilityDao.selectChargeStaffFacilities(userId)
        .stream()
        .map(e -> new StaffFacility(
          e.getIsCharge(),
          e.getDepartmentCd(),
          e.getPrefecturesCd(),
          e.getPrefecturesName(),
          e.getFacilityCd(),
          e.getFacilityName(),
          e.getFacilityNameKana()))
        .collect(Collectors.toList());

    return new StaffFacilityResponse(staffFacilities);
  }

  @Override
  public StaffFacilityResponse getStaffSharingFacility(Long userId) {
    // 全施設の一覧を取得
    List<StaffFacility> staffFacilities = mstStaffFacilityDao.selectChargeStaffSharingFacilities(userId)
        .stream()
        .map(e -> new StaffFacility(
          e.getIsCharge(),
          e.getDepartmentCd(),
          e.getPrefecturesCd(),
          e.getPrefecturesName(),
          e.getFacilityCd(),
          e.getFacilityName(),
          e.getFacilityNameKana()))
        .collect(Collectors.toList());

    return new StaffFacilityResponse(staffFacilities);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public StaffFacilitySettingsResponse updateStaffFacility(Long userId, List<String> staffFacilityCds) {
    // ユーザーIDの存在チェック
    MstUser mstUser = mstUserDao.selectById(userId);

    // 存在しないユーザーIDが指定された場合、エラーメッセージを設定したレスポンスを返却
    if (mstUser == null) {
      return new StaffFacilitySettingsResponse(AdminWebMessage.Error.USER_ID_NOT_FOUND.getMessage());
    }

    if (!CollectionUtils.isEmpty(staffFacilityCds)) {
      // 施設コードの存在チェック
      List<String> allFacilityCds = mstFacilityDao.selectAll()
        .stream()
        .map(e -> e.getFacilityCd())
        .collect(Collectors.toList());
      boolean isCorrectFacilityCd = staffFacilityCds
        .stream()
        .allMatch(e -> allFacilityCds.contains(e));

      // 存在しない施設コードが指定された場合、エラーメッセージを設定したレスポンスを返却
      if (!isCorrectFacilityCd) {
        return new StaffFacilitySettingsResponse(AdminWebMessage.Error.FACILITY_CD_NOT_FOUND.getMessage());
      }
    }

    // 既存の担当施設マスタを一旦削除
    // 削除件数0件もあり得るので戻り値のチェックはしない
    mstStaffFacilityDao.deleteByUserId(userId);

    // 追加する担当施設マスタエンティティを準備
    List<MstStaffFacility> entities = Optional.ofNullable(staffFacilityCds).orElse(Collections.emptyList())
        .stream()
        .distinct()
        .map(facilityCd -> {
          return new MstStaffFacility() {
            {
              setUserId(userId);
              setFacilityCd(facilityCd);
            }
          };
        })
        .collect(Collectors.toList());

    // 対象エンティティが存在する場合、挿入
    if (!entities.isEmpty()) {
      mstStaffFacilityDao.insert(entities);
    }

    return new StaffFacilitySettingsResponse();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<String> getUseFunctions(String facilityCd) {
    return facilityDao.selectUseFunctionByFacilityCd(facilityCd);
  }

}
