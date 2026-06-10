package jp.co.nikkiso.ntss.admin_web.service.patGroupDetail;

import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.patGroup.PatGroupDetailRequest;
import jp.co.nikkiso.ntss.core.dao.PatGroupDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatGroupDetail;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustom;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 患者グループ詳細のService実装クラス.
 */
@Service
public class PatGroupDetailServiceImpl implements PatGroupDetailService {

	@Autowired
	private PatGroupDetailDao patGroupDetailDao;

	@Autowired
	private PatPersonalMainDao patPersonalMainDao;

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public List<PatGroupDetail> selectByPatId(Long patId) {
		return patGroupDetailDao.selectByPatId(patId);
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public List<PatGroupDetail> selectByPatGroupCd(Long patGroupCd, String facilityCd) {

		List<PatGroupDetail> listPatGroupDetail = patGroupDetailDao.selectByPatGroupCd(patGroupCd);
		List<PatGroupDetail> resultListPatGroupDetail = new ArrayList<PatGroupDetail>();

		if (listPatGroupDetail.size() > 0) {
			List<Long> listPatId = new ArrayList<Long>();

			for (PatGroupDetail item : listPatGroupDetail) {
				listPatId.add(item.getPatId());
			}

			List<PatGroupDetail> tmpListPatGroupDetail = new ArrayList<PatGroupDetail>();
			List<PatPersonalMain> listPersonMain = patPersonalMainDao.selectByIdListFacilityCd(listPatId, facilityCd);
			for (PatGroupDetail patGroupDetail : listPatGroupDetail) {
				for (PatPersonalMain patPersonalMain : listPersonMain) {
					if (patGroupDetail.getPatId().equals(patPersonalMain.getPat_id())) {
						tmpListPatGroupDetail.add(patGroupDetail);
						break;
					}
				}
			}

			for (int i = 0; i < tmpListPatGroupDetail.size(); i++) {
				resultListPatGroupDetail.add(
					getDetailFromPatPersonalMain(tmpListPatGroupDetail.get(i).getPatId(), listPersonMain, patGroupCd)
				);
			}
		} else {
			return new ArrayList<PatGroupDetail>();
		}

		return resultListPatGroupDetail;
	}

	/**
	 * 患者リストから情報の習得
	 *
	 * @param patId
	 * @param listPersonalMain
	 * @param patGroupCd
	 * @return
	 */
	private PatGroupDetail getDetailFromPatPersonalMain(Long patId, List<PatPersonalMain> listPersonalMain,
			Long patGroupCd) {
		PatGroupDetail detail = new PatGroupDetail();
		for (PatPersonalMain item : listPersonalMain) {
			if (item.getPat_id().equals(patId)) {
				detail.setPatGroupCd(patGroupCd);
				detail.setPatId(patId);
				detail.setPatFirstName(item.getPat_first_name());
				detail.setPatLastName(item.getPat_last_name());
				detail.setPatHospId(item.getHosp_pat_id());
        /*add FNSI-改修内容入外区分が入院の場合、患者名は紫色にする 任 start*/
				detail.setInOutClass(item.getIn_out_class());
        /*add FNSI-改修内容入外区分が入院の場合、患者名は紫色にする 任 end*/
			}
		}
		return detail;

	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public void deleteByPatGroupId(Long patGroupId) {
		patGroupDetailDao.deleteByPatGroupId(patGroupId);
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public void insert(PatGroupDetail patGroupDetail) {
		patGroupDetailDao.insert(patGroupDetail);

	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public List<PatGroupCustom> selectPatGroupByPatId(Long patId) {
		return patGroupDetailDao.selectPatGroupByPatId(patId);
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
  @Transactional
	public void updateByPatId(Long patId, Map<String, String> payload) throws Exception {
		// 各レコードのJSONを対応するクラスにマッピング
		ObjectMapper mapper = new ObjectMapper();
		PatGroupDetailRequest patGroupDetail = mapper.readValue(payload.get("pat_group_detail"),
				PatGroupDetailRequest.class);

		patGroupDetailDao.deleteByPatId(patId);

		// 患者IDより患者情報を取得
		PatPersonalMain userInf = patPersonalMainDao.selectById(patId);
		// insert detail
		PatGroupDetail temp = new PatGroupDetail();
		for (Long item : patGroupDetail.getPatGroupList()) {
			temp.setPatGroupCd(item);
			temp.setPatId(patId);
			temp.setFacilityCd(userInf.getFacility_cd());
			patGroupDetailDao.insert(temp);
		}

		return;

	}

}
