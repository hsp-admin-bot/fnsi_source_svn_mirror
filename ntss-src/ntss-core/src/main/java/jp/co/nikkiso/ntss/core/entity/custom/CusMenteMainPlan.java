package jp.co.nikkiso.ntss.core.entity.custom;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CusMenteMainPlan {

  private List<Long> cancelIdList;

  private List<CusMenteMainAddMore> addMoreList;
}
