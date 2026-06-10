package jp.co.nikkiso.ntss.core.constant;


import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.utils.AppContextUtils;

import java.util.Arrays;
import java.util.Objects;
import java.util.Optional;

public enum MedicineTypeDaoEum {

  /**  */
  NOR_MEDIC_DAO(1) {
    @Override
    public MstMedicineDao getMedicDaoBean() {
      return AppContextUtils.getBean(MstMedicineDao.class);
    }

    @Override
    public String getMedicUnit(String facilityCd, Integer medicCd) {
      // 列挙クラスは単一例モードであるため、Beanのインスタンスを使用するとロックされて安全性が保証されます
      synchronized (this.getMedicDaoBean()) {
        MstMedicine medicine = this.getMedicDaoBean().selectByCd(facilityCd, medicCd);
        return Objects.isNull(medicine) ? null : medicine.getUnit();
      }
    }

    @Override
    public String getMedicName(String facilityCd, Integer medicCd) {
      synchronized (this.getMedicDaoBean()) {
        MstMedicine medicine = this.getMedicDaoBean().selectByCd(facilityCd, medicCd);
        return Objects.isNull(medicine) ? null : medicine.getMedicineName();
      }
    }
  },
  /**  */
  MIX_MEDIC_DAO(2) {
    @Override
    public MstMedicineMixDao getMedicDaoBean() {
      return AppContextUtils.getBean(MstMedicineMixDao.class);
    }

    @Override
    public String getMedicUnit(String facilityCd, Integer medicCd) {
      // 列挙クラスは単一例モードであるため、Beanのインスタンスを使用するとロックされて安全性が保証されます
      synchronized (this.getMedicDaoBean()) {
        MstMedicineMix medicine = this.getMedicDaoBean().selectByCd(facilityCd, medicCd);
        return Objects.isNull(medicine) ? null : medicine.getUnit();
      }
    }
    @Override
    public String getMedicName(String facilityCd, Integer medicCd) {
      synchronized (this.getMedicDaoBean()) {
        MstMedicineMix medicine = this.getMedicDaoBean().selectByCd(facilityCd, medicCd);
        return Objects.isNull(medicine) ? null : medicine.getMedicineMixName();
      }
    }
  };

  private final Integer medicType;

  MedicineTypeDaoEum(Integer medicType) {
    this.medicType = medicType;
  }


  public static Optional<MedicineTypeDaoEum> getMedicEnum(Integer medicType) {
    return Arrays.stream(MedicineTypeDaoEum.values())
      .filter(v -> Objects.equals(v.medicType, medicType)).findFirst();
  }

  public abstract Object getMedicDaoBean();


  public abstract String getMedicUnit(String facilityCd, Integer medicCd);

  public abstract String getMedicName(String facilityCd, Integer medicCd);

}
