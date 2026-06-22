package jp.co.nikkiso.ntss.admin_web.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.roundType.RoundTypeNameAndContentResponse;
import jp.co.nikkiso.ntss.core.dao.MstRoundTypeDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.entity.MstRoundType;
import jp.co.nikkiso.ntss.core.entity.MstSelector;

import static java.util.Collections.emptyList;

/**
 * 種別マスタのService実装クラス.
 */
@Service
public class RoundTypeServiceImpl implements RoundTypeService {

  /**
   * 種別のDaoインターフェース.
   */
  @Autowired
  private MstRoundTypeDao mstRoundTypeDao;

  /**
   * 並び順管理マスタのDaoインタフェース.
   */
  @Autowired
  private MstSelectorDao mstSelectorDao;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<RoundTypeNameAndContentResponse> createRoundTypeNameAndContentResponse(String facilityCd) {
    final List<MstRoundType> roundTypes = mstRoundTypeDao
        .selectByFacilityCd(facilityCd);

    if (roundTypes.isEmpty()) {
      return emptyList();
    }

    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "mst_round_type");
    if(Objects.isNull(mstSelector)) {
      return emptyList();
    }

    final List<MstSelector.Item> orderSettingItems = mstSelector.getOrderSettings().getItems();
    if(orderSettingItems.isEmpty()) {
      return emptyList();
    }

    final List<RoundTypeNameAndContentResponse> result = new ArrayList<>();
    orderSettingItems.stream()
      .map(MstSelector.Item::getCode)
      .forEach(code -> {
        MstRoundType mstRoundType = roundTypes.stream()
            .filter(value -> value.getRoundTypeCd().equals(code))
            .findFirst()
            .get();
        RoundTypeNameAndContentResponse response
          = new RoundTypeNameAndContentResponse(
            mstRoundType.getRoundTypeCd(),
            mstRoundType.getRoundTypeName(),
            mstRoundType.getContent(),
            mstRoundType.getIsContentOmission(),
            mstRoundType.getCommentPostDefault(),
            mstRoundType.getPostingClassDefault(),
            mstRoundType.getHighlighting()
          );
        result.add(response);
      });

    return result;
  }

}
