package jp.co.nikkiso.ntss.admin_web.service.master;

import static java.util.Collections.emptyList;

import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.InformationSchemaDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.ReferenceComboGenericDao;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceCombo;
import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import jp.co.nikkiso.ntss.core.exception.InvalidSchemaDefinitionException;
import org.springframework.util.StringUtils;

/**
 * 参照型コンボのService実装クラス
 */
@Service
public class ReferenceComboServiceImpl implements ReferenceComboService {

  /**
   * 並び順管理マスタのDaoインタフェース.
   */
  @Autowired
  private final MstSelectorDao mstSelectorDao;

  /**
   * 参照型コンボ用の汎用Daoインターフェース
   */
  @Autowired
  private final ReferenceComboGenericDao referenceComboGenericDao;

  /**
   * information_schemaを参照するDaoインターフェース
   */
  @Autowired
  private final InformationSchemaDao informationSchemaDao;

  @Autowired
  private final JdbcTemplate jdbcTemplate;

  public ReferenceComboServiceImpl(
    MstSelectorDao mstSelectorDao,
    ReferenceComboGenericDao referenceComboGenericDao,
    InformationSchemaDao informationSchemaDao,
    JdbcTemplate jdbcTemplate) {
    this.mstSelectorDao = mstSelectorDao;
    this.referenceComboGenericDao = referenceComboGenericDao;
    this.informationSchemaDao = informationSchemaDao;
    this.jdbcTemplate = jdbcTemplate;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<ReferenceCombo> build(String facilityCd, ReferenceComboTargetTable referenceComboTargetTable) throws InvalidSchemaDefinitionException {

    if(!informationSchemaDao.isTableExist(referenceComboTargetTable.getName())) {
      throw new InvalidSchemaDefinitionException("参照型コンボの設定に、存在しないマスタを指定しています。") {};
    }

    if(!isAllColumnsExistAtTargetTable(referenceComboTargetTable)) {
      throw new InvalidSchemaDefinitionException("参照型コンボの設定に、存在しないカラムを指定しています。") {};
    }

    final MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, referenceComboTargetTable.getName());
    if(Objects.isNull(mstSelector)) {
      return emptyList();
    }

    //FNSI-修正 #5614 横展開対応、xugj add start
    final List<MstSelector.Item> itemList = mstSelector.getOrderSettings().getItems();
    final List<MstSelector.Item> orderSettingItems = new ArrayList<>();
    for (MstSelector.Item item : itemList) {
      if (StringUtils.hasLength(item.getName())) {
        orderSettingItems.add(item);
      }
    }
    //FNSI-修正 #5614 横展開対応、xugj add end

    if(orderSettingItems.isEmpty()) {
      return emptyList();
    }

    List<ReferenceCombo> comboValues
      = selectComboValuesBySerial(referenceComboTargetTable, orderSettingItems);

    final List<ReferenceCombo> result = new ArrayList<>();
    orderSettingItems.stream()
      .map(MstSelector.Item::getCode)
      .forEach(code -> {
        Optional<ReferenceCombo> optionalCombo = comboValues.stream()
                .filter(value -> value.getIdentifierValue().equals(code))
                .findFirst();
        // upd 検査項目マスタ loading bug 20230627 ztc start
//        ReferenceCombo referenceCombo = comboValues.stream()
//            .filter(value -> value.getIdentifierValue().equals(code))
//            .findFirst()
//            .get();
//        result.add(referenceCombo);
        optionalCombo.ifPresent(result::add);
        // upd 検査項目マスタ loading bug 20230627 ztc end
      });

    return result;
  }

  /**
   * 指定したテーブルから、mst_selector.order_settingsに存在するレコードのみを抽出し、構造定義に合わせて変換する
   * @param targetTable 参照先マスタの構造定義データ
   * @param orderSettingItems order_settings.codeの配列
   * @return 構造定義に合わせて変換されたデータ
   */
  private List<ReferenceCombo> selectComboValuesBySerial(ReferenceComboTargetTable targetTable, List<MstSelector.Item> orderSettingItems) {
    List<Long> codes = orderSettingItems.stream()
      .map(MstSelector.Item::getCode)
      .collect(Collectors.toList());

    return referenceComboGenericDao.selectTargetTableByCode(targetTable, codes);
  }

  /**
   * 参照先マスタの構造定義データより、カラムの存在チェックをする。
   * @param targetTable
   * @return 参照先マスタに全てのカラムが存在していればtrue、ひとつでも存在しないカラムがあればfalse
   */
  private boolean isAllColumnsExistAtTargetTable(ReferenceComboTargetTable targetTable) {
    final String targetTableName = targetTable.getName();

    return
      informationSchemaDao.isColumnExistAtTable(targetTableName, targetTable.getReferencedColumn())
      && informationSchemaDao.isColumnExistAtTable(targetTableName, targetTable.getDisplayColumn())
      && informationSchemaDao.isColumnExistAtTable(targetTableName, targetTable.getIdentifier());
  }
}
