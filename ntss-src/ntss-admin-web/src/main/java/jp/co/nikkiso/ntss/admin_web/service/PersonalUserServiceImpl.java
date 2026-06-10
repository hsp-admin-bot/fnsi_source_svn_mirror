package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.admin_web.response.personalUser.NameWithHasEmailResponse;
import jp.co.nikkiso.ntss.admin_web.response.personalUser.UserIdAndUserFullName;
import jp.co.nikkiso.ntss.admin_web.response.personalUser.UserIdAndUserName;
import jp.co.nikkiso.ntss.core.dao.MstJobDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.OrdPersonalPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.entity.MstJob;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import jp.co.nikkiso.ntss.core.entity.OrdPersonalPrescription;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;

import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import static java.util.Comparator.comparing;
import static java.util.stream.Collectors.toList;

import java.util.ArrayList;

/**
 * 利用者用のService実装クラス
 */
@Service
public class PersonalUserServiceImpl implements PersonalUserService {

  private final String DOCTOR = "1";

  /**
   * 利用者マスタのDAOインターフェース
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 職種マスタのDAOインターフェース
   */
  @Autowired
  private MstJobDao mstJobDao;

  /**
   * 選択肢マスタのDaoインタフェース.
   */
  @Autowired
  private MstSelectorDao mstSelectorDao;

  /**
   * 処方情報
   */
  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;

  /**
   * 処方情報のDaoインタフェース
   */
  @Autowired
  private OrdPersonalPrescriptionDao ordPersonalPrescriptionDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public NameWithHasEmailResponse getNameAndHasEmailByFacilityCd(String facilityCd) {
    final SelectOptions selectOptions = SelectOptions.get();
    final List<MstPersonalUser> mstPersonalUsersOrderByUserIdAsc = mstPersonalUserDao
        .selectAll(selectOptions, facilityCd, "0").stream()
        .sorted(comparing(MstPersonalUser::getUserId))
        .collect(toList());

    List<NameWithHasEmailResponse.NameWithHasEmail> nameWithHasEmails = mstPersonalUsersOrderByUserIdAsc.stream()
        .map(mstPersonalUser -> new NameWithHasEmailResponse.NameWithHasEmail(
            mstPersonalUser.getUserId(),
            mstPersonalUser.getUserLastName(),
            mstPersonalUser.getUserFirstName(),
            !Objects.isNull(mstPersonalUser.getUserEmailAddress1()),
            !Objects.isNull(mstPersonalUser.getUserEmailAddress2())))
        .collect(toList());

    return new NameWithHasEmailResponse(nameWithHasEmails);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<UserIdAndUserName> getDoctorsByFacilityCd(String facilityCd) {

    // 施設に属する利用者
    final List<MstPersonalUser> personalUsers = mstPersonalUserDao.selectAll(facilityCd, FlagType.FLAG_OFF)
        .stream()
        .filter(mstPersonalUser -> !StringUtils.isEmpty(mstPersonalUser.getJobCd()))
        .sorted(comparing(MstPersonalUser::getUserId))
        .collect(toList());
    // 医師の職種コード
    List<MstJob> mstJobs = mstJobDao.selectByFacilityCd(facilityCd, SelectOptions.get());
    List<Long> doctorsJobCds = mstJobs
        .stream()
        .filter(mstJob ->
        DOCTOR.equals(mstJob.getIsDoctor())
        && FlagType.FLAG_ON.equals(mstJob.getIsDisp())
        && FlagType.FLAG_OFF.equals(mstJob.getIsDel())
      )
      .map(MstJob::getJobCd)
      .collect(toList());

    List<UserIdAndUserName> lstOrgDoctors = personalUsers.stream()
    .filter(mstPersonalUser -> doctorsJobCds.contains(Long.valueOf(mstPersonalUser.getJobCd())))
    .map(mstPersonalUser -> new UserIdAndUserName(
       mstPersonalUser.getUserId()
       , mstPersonalUser.getUserLastName()
        , mstPersonalUser.getUserFirstName()
        , mstPersonalUser.getJobCd()
        , mstPersonalUser.getIsDel()
        // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc start
        , mstPersonalUser.getIsDisp())
        // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc end
      )
        .collect(toList());

    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_user");
    if (mstSelector != null) {
      // 返却用医師リスト
      List<UserIdAndUserName> lstSortedDoctors = new ArrayList<UserIdAndUserName>();

      // ソート用配列
      List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
          .stream()
          .map(e -> e.getCode())
          .collect(Collectors.toList());

      // 医師リストを、利用者表示順マスタで設定した並び順に並び替え
      for (Long patId : sortedCodes) {
        Optional<UserIdAndUserName> doctor = lstOrgDoctors.stream().filter(d -> d.getUserId().equals(patId))
            .findFirst();
        if (doctor.isPresent()) {
          lstSortedDoctors.add(doctor.get());
        }
      }

      // 利用者表示順マスタで並び順を設定していない医師を、リストの最後尾にそのままの順番で追加
      for (UserIdAndUserName nonSortedDoctor : lstOrgDoctors) {
        Optional<UserIdAndUserName> doctor = lstSortedDoctors.stream()
            .filter(d -> d.getUserId().equals(nonSortedDoctor.getUserId())).findFirst();
        if (!doctor.isPresent()) {
          lstSortedDoctors.add(nonSortedDoctor);
        }
      }
      // 並び替えした順番で返却
      return lstSortedDoctors;
    } else {
      // そのままの順番で返却
      return lstOrgDoctors;
    }
  }

    // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
    /**
     * {@inheritDoc}
     */
    @Override
    public List<UserIdAndUserName> getDoctorsByFacilityCdIncludeDel(String facilityCd) {

        // 施設に属する利用者
        final List<MstPersonalUser> personalUsers = mstPersonalUserDao.selectAllIncludeDel(facilityCd)
                .stream()
                .filter(mstPersonalUser -> !StringUtils.isEmpty(mstPersonalUser.getJobCd()))
                .sorted(comparing(MstPersonalUser::getUserId))
                .collect(toList());
        // 医師の職種コード
        List<MstJob> mstJobs = mstJobDao.selectByFacilityCd(facilityCd, SelectOptions.get());
        List<Long> doctorsJobCds = mstJobs
                .stream()
                .filter(mstJob ->
                        DOCTOR.equals(mstJob.getIsDoctor())
                                && FlagType.FLAG_ON.equals(mstJob.getIsDisp())
                                && FlagType.FLAG_OFF.equals(mstJob.getIsDel())
                )
                .map(MstJob::getJobCd)
                .collect(toList());

        List<UserIdAndUserName> lstOrgDoctors = personalUsers.stream()
                .filter(mstPersonalUser -> doctorsJobCds.contains(Long.valueOf(mstPersonalUser.getJobCd())))
                .map(mstPersonalUser -> new UserIdAndUserName(
                        mstPersonalUser.getUserId()
                        , mstPersonalUser.getUserLastName()
                        , mstPersonalUser.getUserFirstName()
                        , mstPersonalUser.getJobCd()
                        , mstPersonalUser.getIsDel()
                        // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc start
                        , mstPersonalUser.getIsDisp())
                        // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc end
                )
                .collect(toList());

        // mstSelectorから並び順を取得
        MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_user");
        if (mstSelector != null) {
            // 返却用医師リスト
            List<UserIdAndUserName> lstSortedDoctors = new ArrayList<UserIdAndUserName>();

            // ソート用配列
            List<Long> sortedCodes = mstSelector.getOrderSettings().getItems()
                    .stream()
                    .map(e -> e.getCode())
                    .collect(Collectors.toList());

            // 医師リストを、利用者表示順マスタで設定した並び順に並び替え
            for (Long patId : sortedCodes) {
                Optional<UserIdAndUserName> doctor = lstOrgDoctors.stream().filter(d -> d.getUserId().equals(patId))
                        .findFirst();
                if (doctor.isPresent()) {
                    lstSortedDoctors.add(doctor.get());
                }
            }

            // 利用者表示順マスタで並び順を設定していない医師を、リストの最後尾にそのままの順番で追加
            for (UserIdAndUserName nonSortedDoctor : lstOrgDoctors) {
                Optional<UserIdAndUserName> doctor = lstSortedDoctors.stream()
                        .filter(d -> d.getUserId().equals(nonSortedDoctor.getUserId())).findFirst();
                if (!doctor.isPresent()) {
                    lstSortedDoctors.add(nonSortedDoctor);
                }
            }
            // 並び替えした順番で返却
            return lstSortedDoctors;
        } else {
            // そのままの順番で返却
            return lstOrgDoctors;
        }
    }
    // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end

	/**
	 * {@inheritDoc}
	 */
	@Override
  public List<UserIdAndUserName> getDoctorsPrescriptionByFacilityCd(String facilityCd, Long ordPrescriptionNo) {
	  OrdPrescription ordPrescription = ordPrescriptionDao.selectByOrdPrescriptionNo(ordPrescriptionNo);
	  List<UserIdAndUserName> result = new ArrayList<>();
	  if(ordPrescription != null && FlagType.FLAG_ON.equals(ordPrescription.getIssueState())) {
		  OrdPersonalPrescription ordPersonal = ordPersonalPrescriptionDao.selectByOrdPrescriptionNo(ordPrescriptionNo);
		  if(ordPersonal != null) {
			  MstPersonalUser personalUser = mstPersonalUserDao.selectById(ordPersonal.getInsuDrId());
			  UserIdAndUserName doctor = new UserIdAndUserName(personalUser.getUserId(), personalUser.getUserLastName(),
					  personalUser.getUserFirstName(), personalUser.getJobCd(), personalUser.getIsDel()
                      // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc start
                      , personalUser.getIsDisp());
                      // add #10659 削除済み含むの接頭文字対応 ztc 20241022 ztc end
			  result.add(doctor);
		  }
      }else {
    	  result = getDoctorsByFacilityCd(facilityCd);
      }
	  return result;
  }

	/**
	 * {@inheritDoc}
	 */
	@Override
	public boolean checkDoctor(String facilityCd, Long user_id) {

		List<UserIdAndUserName> listDoctor = getDoctorsByFacilityCd(facilityCd);
		if (listDoctor == null || listDoctor.isEmpty()) {
			return false;
		}

		return !listDoctor.stream().filter(doctor -> doctor.getUserId().equals(user_id))
				.collect(toList()).isEmpty();
	}

  /**
   * {@inheritDoc}
   */
  @Override
  public List<UserIdAndUserFullName> getAllUserWithDel(String facilityCd, short viewDeletedUser) {

    List<UserIdAndUserFullName> ret = new ArrayList<>();
    // 施設に属する利用者
    List<MstPersonalUser> personalUsers = mstPersonalUserDao.selectAll(facilityCd, FlagType.FLAG_OFF);
    if (viewDeletedUser > 0) {
      // 削除済みを含む
      personalUsers.addAll(mstPersonalUserDao.selectAll(facilityCd, FlagType.FLAG_ON));
    }
    // mstSelectorから並び順を取得
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_user");
    if (mstSelector != null) {
      for (Item item : mstSelector.getOrderSettings().getItems()) {
        MstPersonalUser user = personalUsers.stream().filter(m -> m.getUserId().equals(item.getCode()))
            .findAny()
            .orElse(null);
        if (user != null) {
          Long userId = user.getUserId();
          String userLastName = "";
          String userFirstName = "";
          String userName = "";
          if (Objects.equals(user.getIsDel(), FlagType.FLAG_OFF)
              || (Objects.equals(user.getIsDel(), FlagType.FLAG_ON) && viewDeletedUser == 1)) {
            userLastName = user.getUserLastName();
            userFirstName = user.getUserFirstName();
            userName = userLastName + userFirstName;
          } else if (Objects.equals(user.getIsDel(), FlagType.FLAG_ON) && viewDeletedUser == 2) {
            userLastName = "(削除)";
            userFirstName = "";
            userName = userLastName + userFirstName;
          }
          ret.add(new UserIdAndUserFullName(userId, userLastName, userFirstName, userName));
          personalUsers.remove(user);
        }
      }
    }
    // mst_selectorでソートできなかったユーザー一覧
    for (MstPersonalUser user : personalUsers.stream()
        .sorted(comparing(MstPersonalUser::getUserId))
        .collect(toList())) {
      Long userId = user.getUserId();
      String userLastName = "";
      String userFirstName = "";
      String userName = "";
      if (Objects.equals(user.getIsDel(), FlagType.FLAG_OFF)
          || (Objects.equals(user.getIsDel(), FlagType.FLAG_ON) && viewDeletedUser == 1)) {
        userLastName = user.getUserLastName();
        userFirstName = user.getUserFirstName();
        userName = userLastName + userFirstName;
      } else if (Objects.equals(user.getIsDel(), FlagType.FLAG_ON) && viewDeletedUser == 2) {
        userLastName = "(削除)";
        userFirstName = "";
        userName = userLastName + userFirstName;
      }
      ret.add(new UserIdAndUserFullName(userId, userLastName, userFirstName, userName));
    }

    return ret;
  }
}
