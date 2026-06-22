package jp.co.nikkiso.ntss.admin_web.service.access;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.ShrPatInfoDao;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.utils.InvestigateLogUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class FacilityAccessService {

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private ShrPatInfoDao shrPatInfoDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  private PatMainDao patMainDao;

  /**
   * ログインユーザーが指定施設にアクセス可能か（NKK管理者は常に許可）。
   */
  public boolean hasFacilityAccess(NtssUser ntssUser, String facilityCd) {
    if (ntssUser == null || ntssUser.isNkkAdminUser()) {
      return true;
    }
    boolean hasAccess = facilityCd != null && !facilityCd.isEmpty()
        && facilityCd.equals(ntssUser.getFacilityCd());
    if (!hasAccess) {
      logForbidden(ntssUser, "facilityCd=" + facilityCd);
    }
    return hasAccess;
  }

  /**
   * ログインユーザーが指定患者（自施設所属または患者共有）にアクセス可能か。
   */
  public boolean hasPatientShareAccess(NtssUser ntssUser, Long patId) {
    if (ntssUser == null || ntssUser.isNkkAdminUser()) {
      return true;
    }
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
    if (patPersonalMain == null) {
      logForbidden(ntssUser, "patId=" + patId + " not found");
      return false;
    }
    if (ntssUser.getFacilityCd().equals(patPersonalMain.getFacility_cd())) {
      return true;
    }
    List<String> shareFacilityCds = shrPatInfoDao.selectFacilityCdsByPatId(patId);
    boolean hasAccess = shareFacilityCds.contains(ntssUser.getFacilityCd());
    if (!hasAccess) {
      logForbidden(ntssUser, "patId=" + patId);
    }
    return hasAccess;
  }

  /**
   * selectedPatId 付き参照 API 用：患者共有画面では患者共有判定、それ以外は施設判定。
   */
  public boolean hasFacilityOrSelectedPatShareAccess(NtssUser ntssUser, String facilityCd, Long selectedPatId) {
    if (selectedPatId != null) {
      return hasPatientShareAccess(ntssUser, selectedPatId);
    }
    return hasFacilityAccess(ntssUser, facilityCd);
  }

  /**
   * 結果集の施設コード一覧に対する認可。
   * selectedPatId あり：患者共有＋結果施設が当該患者の許可施設に含まれること。
   * selectedPatId なし：一覧内の全施設がログイン施設と一致すること。
   */
  public boolean hasFacilityOrSelectedPatShareAccessForFacilityCds(
      NtssUser ntssUser, Collection<String> facilityCdList, Long selectedPatId) {
    if (selectedPatId != null) {
      return hasPatientShareAccessForFacilityCds(ntssUser, facilityCdList, selectedPatId);
    }
    return hasFacilityAccessForAllFacilityCds(ntssUser, facilityCdList);
  }

  /**
   * 患者共有画面向け：ログインユーザーの共有権限と、結果集施設が患者関連施設に属することを検証。
   */
  public boolean hasPatientShareAccessForFacilityCds(
      NtssUser ntssUser, Collection<String> facilityCdList, Long selectedPatId) {
    if (ntssUser == null || ntssUser.isNkkAdminUser()) {
      return true;
    }
    PatientShareContext context = loadPatientShareContext(selectedPatId);
    if (!checkPatientShareAccess(ntssUser, selectedPatId, context)) {
      return false;
    }
    Set<String> distinctFacilityCds = collectDistinctFacilityCds(facilityCdList);
    if (distinctFacilityCds.isEmpty()) {
      return true;
    }
    Set<String> allowedFacilityCds = buildAllowedFacilityCds(context, ntssUser);
    for (String facilityCd : distinctFacilityCds) {
      if (!allowedFacilityCds.contains(facilityCd)) {
        logForbidden(ntssUser, "patId=" + selectedPatId + " facilityCd=" + facilityCd);
        return false;
      }
    }
    return true;
  }

  private PatientShareContext loadPatientShareContext(Long patId) {
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
    Set<String> facilityCds = new LinkedHashSet<>();
    if (patPersonalMain != null) {
      addTrimmedFacilityCd(facilityCds, patPersonalMain.getFacility_cd());
    }
    List<String> shrFacilityCds = shrPatInfoDao.selectFacilityCdsByPatId(patId);
    if (shrFacilityCds != null) {
      for (String facilityCd : shrFacilityCds) {
        addTrimmedFacilityCd(facilityCds, facilityCd);
      }
    }
    return new PatientShareContext(patPersonalMain, new ArrayList<>(facilityCds));
  }

  private boolean checkPatientShareAccess(NtssUser ntssUser, Long patId, PatientShareContext context) {
    if (context.patPersonalMain == null) {
      logForbidden(ntssUser, "patId=" + patId + " not found");
      return false;
    }
    if (ntssUser.getFacilityCd().equals(context.patPersonalMain.getFacility_cd())) {
      return true;
    }
    boolean hasAccess = context.shareFacilityCds.contains(ntssUser.getFacilityCd());
    if (!hasAccess) {
      logForbidden(ntssUser, "patId=" + patId);
    }
    return hasAccess;
  }

  private Set<String> buildAllowedFacilityCds(PatientShareContext context, NtssUser ntssUser) {
    Set<String> allowedFacilityCds = new LinkedHashSet<>();
    addTrimmedFacilityCd(allowedFacilityCds, ntssUser.getFacilityCd());
    for (String shareFacilityCd : context.shareFacilityCds) {
      addTrimmedFacilityCd(allowedFacilityCds, shareFacilityCd);
    }
    return allowedFacilityCds;
  }

  private void addTrimmedFacilityCd(Set<String> facilityCds, String facilityCd) {
    if (facilityCd == null) {
      return;
    }
    String trimmed = facilityCd.trim();
    if (!trimmed.isEmpty()) {
      facilityCds.add(trimmed);
    }
  }

  private static final class PatientShareContext {
    private final PatPersonalMain patPersonalMain;
    private final List<String> shareFacilityCds;

    private PatientShareContext(PatPersonalMain patPersonalMain, List<String> shareFacilityCds) {
      this.patPersonalMain = patPersonalMain;
      this.shareFacilityCds = shareFacilityCds;
    }
  }

  private boolean hasFacilityAccessForAllFacilityCds(NtssUser ntssUser, Collection<String> facilityCdList) {
    if (ntssUser == null || ntssUser.isNkkAdminUser()) {
      return true;
    }
    Set<String> distinctFacilityCds = collectDistinctFacilityCds(facilityCdList);
    if (distinctFacilityCds.isEmpty()) {
      return true;
    }
    String loginFacilityCd = ntssUser.getFacilityCd();
    for (String facilityCd : distinctFacilityCds) {
      if (!facilityCd.equals(loginFacilityCd)) {
        logForbidden(ntssUser, "facilityCd=" + facilityCd);
        return false;
      }
    }
    return true;
  }

  private Set<String> collectDistinctFacilityCds(Collection<String> facilityCdList) {
    Set<String> distinctFacilityCds = new LinkedHashSet<>();
    if (facilityCdList == null) {
      return distinctFacilityCds;
    }
    for (String facilityCd : facilityCdList) {
      addTrimmedFacilityCd(distinctFacilityCds, facilityCd);
    }
    return distinctFacilityCds;
  }

  /**
   * selectedPatId 付き ordNo 参照 API 用：患者共有画面では患者共有判定、それ以外はオーダ施設判定。
   */
  public boolean hasOrdOrSelectedPatShareAccess(NtssUser ntssUser, Long ordNo, Long selectedPatId) {
    if (selectedPatId != null) {
      return hasPatientShareAccess(ntssUser, selectedPatId);
    }
    return hasOrdAccess(ntssUser, ordNo);
  }

  /**
   * selectedPatId 付き patId リスト参照 API 用。
   * selectedPatId あり：患者共有＋リスト内の全 patId にアクセス可能であること。
   * selectedPatId なし：各 patId がログイン施設に属すること（#11205）。
   */
  public boolean hasPatIdsOrSelectedPatShareAccess(
      NtssUser ntssUser, Collection<Long> patIds, Long selectedPatId) {
    if (ntssUser == null || ntssUser.isNkkAdminUser()) {
      return true;
    }
    Set<Long> distinctPatIds = collectDistinctPatIds(patIds);
    if (distinctPatIds.isEmpty()) {
      return true;
    }
    List<Long> patIdList = new ArrayList<>(distinctPatIds);
    if (selectedPatId != null) {
      List<PatPersonalMain> pats = patPersonalMainDao.selectByIdList(patIdList);
      if (pats.size() != distinctPatIds.size()) {
        logForbidden(ntssUser, "patIdList not found");
        return false;
      }
      List<String> facilityCdList = pats.stream()
          .map(PatPersonalMain::getFacility_cd)
          .collect(Collectors.toList());
      return hasPatientShareAccessForFacilityCds(ntssUser, facilityCdList, selectedPatId);
    }
    List<PatMain> matched = patMainDao.selectByIdListFacilityCd(patIdList, ntssUser.getFacilityCd());
    if (matched.size() != distinctPatIds.size()) {
      logForbidden(ntssUser, "patIdList facility mismatch");
      return false;
    }
    return true;
  }

  private Set<Long> collectDistinctPatIds(Collection<Long> patIds) {
    Set<Long> distinctPatIds = new LinkedHashSet<>();
    if (patIds == null) {
      return distinctPatIds;
    }
    for (Long patId : patIds) {
      if (patId != null) {
        distinctPatIds.add(patId);
      }
    }
    return distinctPatIds;
  }

  /**
   * selectedPatId 付き facilityCd + ordNo 参照 API 用。
   */
  public boolean hasFacilityAndOrdOrSelectedPatShareAccess(
      NtssUser ntssUser, String facilityCd, Long ordNo, Long selectedPatId) {
    if (selectedPatId != null) {
      return hasPatientShareAccess(ntssUser, selectedPatId);
    }
    if (ntssUser == null) {
      return false;
    }
    if (ntssUser.isNkkAdminUser()) {
      return true;
    }
    if (!hasFacilityAccess(ntssUser, facilityCd)) {
      return false;
    }
    return hasOrdAccess(ntssUser, ordNo);
  }

  private boolean hasOrdAccess(NtssUser ntssUser, Long ordNo) {
    if (ntssUser == null) {
      return false;
    }
    if (ntssUser.isNkkAdminUser()) {
      return true;
    }
    if (ordNo == null) {
      return false;
    }
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    boolean hasAccess = ordMain == null || ordMain.getFacilityCd() == null
        || ordMain.getFacilityCd().equals(ntssUser.getFacilityCd());
    if (!hasAccess) {
      logForbidden(ntssUser, "ordNo=" + ordNo + " facilityCd=" + ordMain.getFacilityCd());
    }
    return hasAccess;
  }

  private void logForbidden(NtssUser ntssUser, String detail) {
    String msg = "ntssUser.getFacilityCd()=" + ntssUser.getFacilityCd() + " " + detail + " ";
    InvestigateLogUtils.info("11205", msg, "11205-FORBIDDEN");
  }
}
