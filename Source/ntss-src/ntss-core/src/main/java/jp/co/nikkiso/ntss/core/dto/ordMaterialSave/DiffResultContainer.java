package jp.co.nikkiso.ntss.core.dto.ordMaterialSave;

import jp.co.nikkiso.ntss.core.entity.OrdMaterialSave;
import jp.co.nikkiso.ntss.core.utils.MaterialSaveCacheHandler;
import lombok.Getter;
import lombok.Setter;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class DiffResultContainer {
  @Getter
  private final List<OrdMaterialSave> insList = new ArrayList<>();
  @Getter
  private final List<OrdMaterialSave> updList = new ArrayList<>();
  @Getter
  private final List<OrdMaterialSave> delList = new ArrayList<>();

  @Getter
  @Setter
  private List<OrdMaterialSave> originalList = new ArrayList<>();

  @Getter
  @Setter
  private Map<Long, List<OrdMaterialSave>> ordMaterialSaveMap;

  public DiffResultContainer() {}
  public DiffResultContainer(List<Long> ordNos) {
    this.originalList = MaterialSaveCacheHandler.get().getMaterialSaveListByOrdNo(ordNos);
    if (!CollectionUtils.isEmpty(this.originalList)) {
      this.ordMaterialSaveMap = this.originalList.stream().collect(
        Collectors.groupingBy(
          OrdMaterialSave::getOrdMaterialSaveNo, Collectors.toList()
        )
      );
    }
  }

  public void setInsList(List<OrdMaterialSave> insList) {
    if (!CollectionUtils.isEmpty(insList)) this.insList.addAll(insList);
  }

  public void setUpdList(List<OrdMaterialSave> updList) {
    if (!CollectionUtils.isEmpty(updList)) this.updList.addAll(updList);
  }

  public void setDelList(List<OrdMaterialSave> delList) {
    if (!CollectionUtils.isEmpty(delList)) this.delList.addAll(delList);
  }
}
