package jp.co.nikkiso.ntss.core.utils;


import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineMixDao;
import jp.co.nikkiso.ntss.core.dao.OrdMaterialSaveDao;
import jp.co.nikkiso.ntss.core.dto.ordMaterialSave.OrdMaterialSaveDto;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineMix;
import jp.co.nikkiso.ntss.core.entity.OrdMaterialSave;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.apache.commons.lang3.StringUtils;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * ord_material_saveロギング操作のキャッシュコントローラ
 *
 * @author Tao.zhou
 * @since 2024-01-05
 */
@NoArgsConstructor
public class MaterialSaveCacheHandler {

  /**
   * Maybe a temporarily set length.
   * Because the cached key is ordNo, the actual cache size is determined by
   * the number of MaterialSave records pointed to by each ordNo multiplied by 14.
   * And ConcurrentHashMap's DEFAULT_CAPACITY is 16.(one for pending mission, one for redundant)
   * So, this will effectively reduce or even prevent Map resizing operations.
   */
//  private static final int MAX_CACHE_LEN = 0xE;
//  private static final int DEFAULT_CAPACITY = 0x10;

  private static final int MAX_CACHE_LEN = 0x1E;
  private static final int DEFAULT_CAPACITY = MAX_CACHE_LEN * 20;

  /**
   * A Cache container of ord_material_save.
   * For calculate the difference between old and new records.
   * It's maximum length was defined as 16, to ensure that multiple threads operate without causing memory overflow.
   */
  private final ConcurrentHashMap<Long, MaterialSaveContainer> materialSaveCacheList
    = new ConcurrentHashMap<>(DEFAULT_CAPACITY);

  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by  shiyw 20250528 start
//  /**  */
//  private static final ConcurrentLinkedQueue<Long> pendingOrdNoQueue = new ConcurrentLinkedQueue<>();
  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by  shiyw 20250528 end


  public static final List<String> COND_SCODE_LIST = List.of("000", "001", "002", "003", "004", "005"
                                                  , "006", "007", "008", "009", "010", "017", "022");

  public static final List<String> MEDI_SCODE_LIST = List.of("112", "113", "120");


  public static final List<String> EQUIP_SCODE_LIST = List.of("201", "211");


  public static final List<String> COMP_SCODE_LIST = List.of("314", "315", "321");

  /** A Container for loading cache records  */
  static class MaterialSaveContainer {
    private Long timeStamp = 0L;

    private List<OrdMaterialSave> materialSaveList;

    private boolean hasUsed = false;

    public MaterialSaveContainer(List<OrdMaterialSave> materialSaveList) {
      this.materialSaveList = materialSaveList;
      this.timeStamp = System.currentTimeMillis();
    }

    public Long getTimeStamp() { return this.timeStamp; }

    public void setTimeStamp(Long timeStamp) { this.timeStamp = timeStamp; }

    public List<OrdMaterialSave> getMaterialSaveList() { return this.materialSaveList; }

    public void setMaterialSaveList(List<OrdMaterialSave> materialSaveList) {
      this.materialSaveList = materialSaveList;
    }

    public boolean getHasUsed() { return this.hasUsed; }

    public void setHasUsed(boolean u) { this.hasUsed = u; }

    public int getListSize() { return this.materialSaveList == null ? 0 : this.materialSaveList.size(); }

    public boolean isEmptyNode() { return this.getListSize() == 0; }
  }

  public static class DiffResultContainer {
    @Getter
    private final List<OrdMaterialSave> insList = new ArrayList<>();
    @Getter
    private final List<OrdMaterialSave> updList = new ArrayList<>();
    @Getter
    private final List<OrdMaterialSave> delList = new ArrayList<>();

    @Getter
    @Setter
    private List<OrdMaterialSave> originalList = new ArrayList<>();

    public DiffResultContainer(Long ordNo, String facilityCd) {
      this.originalList = get().getMaterialSaveListByOrdNo(ordNo, facilityCd);
    }

    public void setInsList(List<OrdMaterialSave> insList) {
      this.insList.addAll(insList);
    }

    public void setUpdList(List<OrdMaterialSave> updList) {
      this.updList.addAll(updList);
    }

    public void setDelList(List<OrdMaterialSave> delList) {
      this.delList.addAll(delList);
    }
  }

  /** A Cache Thead */
  private static final InheritableThreadLocal<MaterialSaveCacheHandler> materialSaveCache = new InheritableThreadLocal<>();

  /**  */
  public MaterialSaveCacheHandler(String facilityCd, List<Long> ordNoList) {

    materialSaveCacheList.clear();
    if (!CollectionUtils.isEmpty(ordNoList) && StringUtils.isNotEmpty(facilityCd)) {

//      List<Long> tmpParamCd = new ArrayList<>(MAX_CACHE_LEN);
//      List<Long> tmpParamCd = new ArrayList<>(DEFAULT_CAPACITY);

      OrdMaterialSaveDao materialSaveDao = AppContextUtils.getBean(OrdMaterialSaveDao.class);
//      if (ordNoList.size() >= MAX_CACHE_LEN) {
//      if (ordNoList.size() >= DEFAULT_CAPACITY) {
//
//        pendingOrdNoQueue.addAll(ordNoList);
//        // Take 14 items first, and for each completed item,
//        // retrieve the next item in the queue and automatically place it in the cache map.
//        for (int i = 0; i < MAX_CACHE_LEN; i++) {
//          tmpParamCd.add(i, pendingOrdNoQueue.poll());
//        }
//      } else {
//        tmpParamCd.addAll(ordNoList);
//      }

      //
      List<OrdMaterialSave> nOmsCacheResult = materialSaveDao.selectOrdMaterialSaveBySBNos(ordNoList, facilityCd);

      // Convert to Map and convert it to cache Map
      materialSaveCacheList.putAll(nOmsCacheResult
        .stream()
        // Grouping the result set in units of ordNo
        .collect(Collectors.groupingBy(OrdMaterialSave::getSuppliesBaseNo))
        .entrySet().stream()
        // Re encapsulate this collection so that it can be directly placed in the cache container
        .collect(Collectors.toMap(
          Map.Entry::getKey,
          kvSet -> new MaterialSaveContainer(kvSet.getValue())
        )));
    }
  }

  public void initialization(String facilityCd, List<Long> ordNoList) {

    materialSaveCacheList.clear();
    if (!CollectionUtils.isEmpty(ordNoList) && StringUtils.isNotEmpty(facilityCd)) {
      OrdMaterialSaveDao materialSaveDao = AppContextUtils.getBean(OrdMaterialSaveDao.class);
      List<OrdMaterialSave> nOmsCacheResult = materialSaveDao.selectOrdMaterialSaveBySBNos(ordNoList, facilityCd);
      // Convert to Map and convert it to cache Map
      materialSaveCacheList.putAll(nOmsCacheResult
        .stream()
        // Grouping the result set in units of ordNo
        .collect(Collectors.groupingBy(OrdMaterialSave::getSuppliesBaseNo))
        .entrySet().stream()
        // Re encapsulate this collection so that it can be directly placed in the cache container
        .collect(Collectors.toMap(
          Map.Entry::getKey,
          kvSet -> new MaterialSaveContainer(kvSet.getValue())
        )));

    }
  }

  // add #10843 djy start
  public void initializationForConvert(String facilityCd,List<Long> ordNoList) {
    materialSaveCacheList.clear();
    if (!CollectionUtils.isEmpty(ordNoList)) {
      // mod #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
      for (Long key : ordNoList) {
        OrdMaterialSave ordMaterialSave = new OrdMaterialSave();
        ordMaterialSave.setOrdMaterialSaveNo(0l);
        ordMaterialSave.setFacilityCd(facilityCd);
        ordMaterialSave.setPatId(0l);
        ordMaterialSave.setSuppliesBaseNo(0l);
        ordMaterialSave.setSuppliesSourceClass("0");
        ordMaterialSave.setSuppliesClass("0");
        ordMaterialSave.setSuppliesCd("0");
        ordMaterialSave.setIndRstClass("0");
        ordMaterialSave.setIndRstValue("0");
        ordMaterialSave.setIsConfirm("0");
        MaterialSaveContainer materialSaveContainer = new MaterialSaveContainer(Collections.singletonList(ordMaterialSave));
        materialSaveCacheList.put(key, materialSaveContainer);
      }
      // mod #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end
    }
  }
  // add #10843 djy end

  /** static method to reach this container */
  public static MaterialSaveCacheHandler get() {
    if (materialSaveCache.get() == null) {
      materialSaveCache.set(new MaterialSaveCacheHandler());
    }
    return materialSaveCache.get();
  }

  // add #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
  public static void setMaterialSaveCacheForSubThread(MaterialSaveCacheHandler materialSaveCacheHandler){
    materialSaveCache.set(materialSaveCacheHandler);
  }
  // add #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end

  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by  shiyw 20250528 start
//  /**  */
//  public static MaterialSaveCacheHandler clearAndGet(String facilityCd, List<Long> ordNoList) {
//    if (materialSaveCache.get() == null) {
//      materialSaveCache.set(new MaterialSaveCacheHandler(facilityCd, ordNoList));
//    } else if (!runningFetching()) {
//      materialSaveCache.set(new MaterialSaveCacheHandler());
//    }
//
//    return materialSaveCache.get();
//  }
  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by  shiyw 20250528 end

  // add #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
  // Map<equipmentCd,MstEquipment>
  private final Map<Integer, MstEquipment>  mstEquipmentMap = new ConcurrentHashMap<>();
  private final Map<Integer, MstMedicineMix>  mstMedicineMixIncludeDelMap = new ConcurrentHashMap<>();
  private final Map<Integer, MstMedicine>  mstMedicineIncludeDelMap = new ConcurrentHashMap<>();
  /**
   * get Equipment info
   * @param equipmentCd
   * @return
   */
  public MstEquipment getEquipmentByCd(Integer equipmentCd){
    MstEquipmentDao mstEquipDao = AppContextUtils.getBean(MstEquipmentDao.class);
    if(!mstEquipmentMap.containsKey(equipmentCd)){
      MstEquipment equipment = mstEquipDao.selectByEquipmentCd(equipmentCd);
      //mod equipmentCd存在しない場合のnullpointerexceptionの解決(#8186の検証にて発見)  ljx start
      if(equipment !=null){
        mstEquipmentMap.put(equipment.getEquipmentCd(),equipment);
      }else{
        return null;
      }
      //mod equipmentCd存在しない場合のnullpointerexceptionの解決(#8186の検証にて発見) ljx end
    }
    return mstEquipmentMap.get(equipmentCd);
  }
  /**
   * get MstMedicineMix info include del
   * @param medicineMixCd
   * @return
   */
  public MstMedicineMix getMstMedicineMixIncludeDelByCd(Integer medicineMixCd){
    MstMedicineMixDao mstMedicineMixDao = AppContextUtils.getBean(MstMedicineMixDao.class);
    if(!mstMedicineMixIncludeDelMap.containsKey(medicineMixCd)){
      MstMedicineMix obj = mstMedicineMixDao.selectByMedicineMixIncludeDelByCd(medicineMixCd);
      if (obj != null) {
        mstMedicineMixIncludeDelMap.put(medicineMixCd, obj);
      } else {
        return null;
      }
    }
    return mstMedicineMixIncludeDelMap.get(medicineMixCd);
  }
  /**
   * get MstMedicine info include del
   * @param medicineCd
   * @return
   */
  public MstMedicine getMstMedicineIncludeDelByCd(Integer medicineCd){
    MstMedicineDao mstMedicineDao = AppContextUtils.getBean(MstMedicineDao.class);
    if(!mstMedicineIncludeDelMap.containsKey(medicineCd)){
      MstMedicine obj = mstMedicineDao.selectIncludeDelByMediCd(medicineCd);
      if (obj != null) {
        mstMedicineIncludeDelMap.put(medicineCd, obj);
      }  else {
        return null;
      }
    }
    return mstMedicineIncludeDelMap.get(medicineCd);
  }
  // add #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end
  /** We will remove all cache when this thead run completed. */
  public void clearCache(){
    if(materialSaveCache.get() != null){
      materialSaveCacheList.clear();
      // add #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
      mstEquipmentMap.clear();
      mstMedicineMixIncludeDelMap.clear();
      mstMedicineIncludeDelMap.clear();
      // add #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end
      materialSaveCache.remove();
    }
  }
  // add #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
  public void clearCacheForSubThread(){
    if(materialSaveCache.get() != null){
      materialSaveCache.remove();
    }
  }
  // add #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end

  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by  shiyw 20250528 start
//  /**  */
//  public static boolean runningFetching() {
//    return !pendingOrdNoQueue.isEmpty();
//  }
  // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by  shiyw 20250528 end

  /**
   * Search a record form cache.
   * If the corresponding value is not found in the cache, query the real database data.
   * And put this record into cache map.
   * if cache map's reaches its maximum capacity, the empty record will be deleted.
   * If the empty record cannot be deleted, the earliest used record will automatically delete.
   *
   * @param ordNo        オーダ番号
   * @param facilityCd   施設コード
   * @return  record list
   */
  public List<OrdMaterialSave> getMaterialSaveListByOrdNo(Long ordNo, String facilityCd) {
    if (!materialSaveCacheList.containsKey(ordNo)
      || materialSaveCacheList.get(ordNo).isEmptyNode()) {
      List<OrdMaterialSave> result = AppContextUtils.getBean(OrdMaterialSaveDao.class)
        .selectOrdMaterialSaveBySuppliesBaseNo(ordNo, facilityCd);

      // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 start
//      if (materialSaveCacheList.size() >= MAX_CACHE_LEN) {    // i think use while will be better.
//
//        Optional<Long> keyToRemove;
//
//        // Remove empty node first.
//        keyToRemove =
//          materialSaveCacheList.entrySet().stream()
//            .filter(node -> node.getValue().isEmptyNode())
//            .map(Map.Entry::getKey)
//            .findFirst();
//
//        // if there is no empty nodes, then we will find the earliest used node.
//        if (keyToRemove.isEmpty()) {
//          keyToRemove =
//            materialSaveCacheList.entrySet().stream()
//              .filter(entry -> entry.getValue().getHasUsed())
//              .sorted(Map.Entry.comparingByValue( Comparator.comparingLong(MaterialSaveContainer::getTimeStamp) ))
//              .map(Map.Entry::getKey)
//              .findFirst();
//        }
//
//        /* So, at this time, there always has keys to remove. */
//        /* *** !!!But!!! ***
//         It doesn't matter if the record is not deleted,
//           as there is still one redundant bit between the maximum volume and maximum length.
//           Theoretically, an expiration operation can be performed on the next call.*/
//        keyToRemove.ifPresent(materialSaveCacheList::remove);
//      }
      // del #11905  器材準備リスト"の内容が正しく抽出されない場合がある by shiyw 20250528 end
      // add node normally.
      materialSaveCacheList.put(ordNo, new MaterialSaveContainer(result));
      return result;
    }
    // return result normally
    else {
      return materialSaveCacheList.get(ordNo).getMaterialSaveList();
    }
  }

  /** A temp method get a lots of record */
  public List<OrdMaterialSave> getMaterialSaveListByOrdNo(List<Long> ordNos) {

    return ordNos.stream()
      .filter(materialSaveCacheList::containsKey)
      .map(ordNo -> materialSaveCacheList.get(ordNo).getMaterialSaveList())
      .flatMap(List::stream)
      .collect(Collectors.toCollection(ArrayList::new));
  }
  /**
   * パラメータリストとキャッシュに指定されたリストに差分を行い、更新リストを得ます。
   *
   * @param ordNo        オーダ番号
   * @param facilityCd   施設コード
   * @param listToDiff   差分待ちリスト
   * @param diffMode     差分Mode
   * @return  更新リスト
   */
  public DiffResultContainer diffMaterialSaveResult(Long ordNo, String facilityCd
    , List<OrdMaterialSave> listToDiff, int diffMode) {

    final DiffResultContainer resultContainer = new DiffResultContainer(ordNo, facilityCd);

    List<String> scodeToDiff = new LinkedList<>();
    // 差分Modeにようり、指定されたパターンの差分のみを行う
    String binaryStr = Integer.toBinaryString(diffMode);
    if (binaryStr.length() < 5)
      binaryStr = StringUtils.leftPad(binaryStr, 5, "0");
    // 元素の繰り返しはどうでもよく、包含判断のみをする
    String indRstClass = StringUtils.equals("1", String.valueOf(binaryStr.charAt(0)))
      ? OrdMaterialSaveDto.RST_CLASS : OrdMaterialSaveDto.IND_CLASS;
    if (StringUtils.equals("1", String.valueOf(binaryStr.charAt(4))))
      scodeToDiff.addAll(COND_SCODE_LIST);
    if (StringUtils.equals("1", String.valueOf(binaryStr.charAt(3))))
      scodeToDiff.addAll(MEDI_SCODE_LIST);
    if (StringUtils.equals("1", String.valueOf(binaryStr.charAt(2))))
      scodeToDiff.addAll(EQUIP_SCODE_LIST);
    if (StringUtils.equals("1", String.valueOf(binaryStr.charAt(1))))
      scodeToDiff.addAll(COMP_SCODE_LIST);

    resultContainer.setOriginalList(
      resultContainer.getOriginalList().stream()
        .filter(
          r -> scodeToDiff.contains( StringUtils.join(r.getSuppliesSourceClass(), r.getSuppliesClass()) )
          && StringUtils.equals(indRstClass, r.getIndRstClass())
        )
        .toList()
    );

    // 20240207 追記
    // 現在生成されている更新対象リストは必ずしもordMain中のすべてのレコードではないので、条件に応じて更新削除する必要があります
    // 差分リストが空の場合、すべて削除
    if (CollectionUtils.isEmpty(listToDiff)) {
      resultContainer.setDelList(resultContainer.getOriginalList());
    } else
    // 追記 END

    // 元のレコードが空で、差分リストに値がある場合は、すべて挿入
    if (CollectionUtils.isEmpty(resultContainer.getOriginalList())) {
      resultContainer.setInsList(listToDiff);
    }
    // 残りの場合は差分判定が必要
    else {

      /* Start ***** 昇竜拳 ***** Start */

      /* 差分状況：   新しいレコード ⇒ |====A====|///B///|                        */
      /*                                     |///D///|====C====| ⇐ 元のレコード */
      /* A: need to insert   B: ins + going update + as same                  */
      /* C: need to delete   D: del + to be update + as same                  */
      // 20240207 追記 => Part C is will be the part of they are. Because of not every function

      // グループ化関数式パラメータ -> データ基準日、発生元区分、物品区分、指示・実績区分 JOIN with ";"
      Function<OrdMaterialSave, String> compositeKeys = or ->
        StringUtils.join(new String[]{
          or.getSuppliesBaseDate(),
          or.getSuppliesSourceClass()
          , or.getIndRstClass(), or.getSuppliesClass(), or.getSuppliesCd(), or.getMedicineNo()}, ";");

      // 新しいレコードグループ化
      Map<String, List<OrdMaterialSave>> forDiffRecMap = listToDiff.stream().collect(
        Collectors.groupingBy( compositeKeys , Collectors.toList() ) );

      // 元のレコードグループ化
      Map<String, List<OrdMaterialSave>> orgRecordMap = resultContainer.getOriginalList().stream().collect(
        Collectors.groupingBy( compositeKeys , Collectors.toList() ) );

    /* ========== 第一回双方向短絡 Start ========== */
      // to find A & B:新のレコード操作 ⇒ 新Key == 元Key → Map.key ⇒　true:レコード差分継続 || false:新規必要なレコード
      Map<Boolean, List<String>> diffMapKeyGroups = forDiffRecMap.keySet().stream().collect(
        Collectors.groupingBy(
          fdk -> orgRecordMap.keySet().stream().anyMatch(ork -> StringUtils.equals(fdk, ork))
          , Collectors.toList()
        )
      );
       // 20240207 追記 => Part C is will be the part of as they are.
      // to find C & D:元のレコード操作 ⇒  元Key == 新Key → Map.key ⇒　true:レコード差分継続 || false:削除必要なレコード
      Map<Boolean, List<String>> orgMapKeyGroups = orgRecordMap.keySet().stream().collect(
        Collectors.groupingBy(
          odk -> forDiffRecMap.keySet().stream().anyMatch(nk ->  StringUtils.equals(odk, nk))
          , Collectors.toList()
        )
      );

      // 新規必要なレコード (Part A)
      if (diffMapKeyGroups.containsKey(false))
        resultContainer.setInsList(
          diffMapKeyGroups.get(false)
            .stream()
              .filter(forDiffRecMap::containsKey)
                .flatMap(dKey -> forDiffRecMap.get(dKey).stream())
                  .toList()
        );
       // 20240207 追記 => Part C is will be the part of as they are.
      // 削除必要なレコード (Part C)
      if (orgMapKeyGroups.containsKey(false))
        resultContainer.setDelList(
          orgMapKeyGroups.get(false)
            .stream()
              .filter(orgRecordMap::containsKey)
                .flatMap(oKey -> orgRecordMap.get(oKey).stream())
                  .toList()
        );

    /* ========== 第一回双方向短絡 End ========== */


      /* 差分状況：   新しいレコード ⇒ |--A--|////////B///////////|                           */
      /*                                 |//B1//|%%B2%%|**B3**|                           */
      /*                                        |%%D2%%|**D3**|//D1//|                    */
      /*                                        |/////////D//////////|--C--| ⇐ 元のレコード */
      /* B1: 調製薬剤の変更なパート、新規待つ; 　B2: 更新必要な新レコード;　 B3: 変更しないなレコード  */
      /* D1: 調製薬剤の変更なパート、削除待つ; 　D2: 更新必要の元レコード; 　D3: 変更しないなレコード  */
    /* ========== 第二回双方向短絡 Start ========== */
      // 物品区分:投与薬剤と調製薬剤@分解薬剤コード
      final List<String> mixMedicCodeList = List.of("12", "13", "14", "15", "20", "21", "22");

      // 残りは差分処理が必要: Part B & D
      if (diffMapKeyGroups.containsKey(false))
        forDiffRecMap.keySet().removeIf(key -> diffMapKeyGroups.get(false).contains(key));
      if (orgMapKeyGroups.containsKey(false))
        orgRecordMap.keySet().removeIf(key -> orgMapKeyGroups.get(false).contains(key));

      // 調製薬剤とその他の状況を区別する
      Function<OrdMaterialSave, Boolean> compositeMixMedicKeys =
        ordMaterialSave -> mixMedicCodeList.contains(ordMaterialSave.getSuppliesClass());

      // 新しいListを循環させ、keyを通じてそれが子供であるかどうかを判断する。
      // 子どもの場合は、次のサイクルを行うには、増減項目も判断する必要があります(B1 & D1)。
      // 残りの場合、理論的にはこの項目のリストには1つの要素、つまり対応する品物区分の値しかありません。
      // つまり各フィールドが異なると判断するだけでよい(B2,B3 & D2,D3)。
      // D3とB3確認必要がありません
      // 20240207 追記 => (B1 & D1)判断項目、薬剤識別番号を追加する
      //TODO ここはしばらく簡略化されていないので、先ずに論理コードを実装する
      for (Map.Entry<String, List<OrdMaterialSave>> entry : forDiffRecMap.entrySet()) {

        // これは何を区別しても一致する元のリストです
        List<OrdMaterialSave> orgEntityValue = orgRecordMap.get(entry.getKey());

        // さらに薬剤コードと薬剤識別番号で比較する
        // 同じ薬剤コードと薬剤識別番号の更新、再新規リストでは発生しないものは削除、旧リストでは発生しないものは新規
        Map<Boolean, List<OrdMaterialSave>> k1 = entry.getValue().stream().collect(
          Collectors.groupingBy( compositeMixMedicKeys , Collectors.toList() )
        );

        Map<Boolean, List<OrdMaterialSave>> k2 = orgEntityValue.stream().collect(
          Collectors.groupingBy( compositeMixMedicKeys , Collectors.toList() )
        );

        if (k1.containsKey(true)) {
          if (k2.containsKey(true)) {
            // 両方のリストに薬剤があり、比較が必要です
            List<OrdMaterialSave> medicineCol = k1.get(true);
            List<OrdMaterialSave> orgMediCol = k2.get(true);

            // 更新が必要なのは、コード一致ですが、他の項目は一致しません
            resultContainer.setUpdList(medicineCol.stream()
              .filter(
                fr -> {
                  Optional<OrdMaterialSave> fs =  orgMediCol.stream()
                    .filter(
                      or ->
                        (StringUtils.equals(fr.getSuppliesCd(), or.getSuppliesCd())
                          && StringUtils.equals(fr.getMedicineNo(), or.getMedicineNo()))
                        &&
                        (!StringUtils.equals(fr.getMedicineMixCd(), or.getMedicineMixCd())
                          || !StringUtils.equals(fr.getClassCd(), or.getClassCd())
                          || !StringUtils.equals(fr.getProcedureCd(), or.getProcedureCd())
                          || !StringUtils.equals(fr.getTimingCd(), or.getTimingCd())
                          || !StringUtils.equals(fr.getIndRstValue(), or.getIndRstValue())
                          || !StringUtils.equals(fr.getReceiptValue(), or.getReceiptValue())
                          || !StringUtils.equals(fr.getReceiptConversion(), or.getReceiptConversion())
                          // add 11613 by kangjie 20250227 start
                          || !StringUtils.equals(fr.getEffectFlg(), or.getEffectFlg())
                          // add 11613 by kangjie 20250227 end
//                          || !StringUtils.equals(fr.getIsConfirm(), or.getIsConfirm())
                        )
                    ).findFirst();
                  boolean result = fs.isPresent();
                  if (result) fr.setOrdMaterialSaveNo(fs.get().getOrdMaterialSaveNo());
                  return result;
                }
              )
              .toList()
            );

            // 新しいのは、古いリストにはありません
            resultContainer.setInsList(medicineCol.stream().filter(
              fr ->
                orgMediCol.stream().noneMatch(or ->
                  (StringUtils.equals(fr.getSuppliesCd(), or.getSuppliesCd())
                    && StringUtils.equals(fr.getMedicineNo(), or.getMedicineNo()))
                )
            ).toList());

            // 削除されたのは、新しいリストにはありません
            resultContainer.setDelList(orgMediCol.stream().filter(or ->
              medicineCol.stream().noneMatch(
                fr -> (StringUtils.equals(fr.getSuppliesCd(), or.getSuppliesCd())
                  && StringUtils.equals(fr.getMedicineNo(), or.getMedicineNo()))
              )).toList());
          }
          // 元の薬剤がない場合は、すべて新規に追加
          else {
            resultContainer.setInsList(k1.get(true));
          }
        }
        // ソースリストに薬剤がある場合は、すべて削除されます
        else if (k2.containsKey(true)) {
          resultContainer.setDelList(k2.get(true));
        }
        // その他場合
        if (k1.containsKey(false)) {
          // 更新が必要なのみ
          comparingOms(resultContainer, entry, orgEntityValue);
        }

//
//        if (!CollectionUtils.isEmpty(entry.getValue()) && !CollectionUtils.isEmpty(orgEntityValue)) {
//          // 投与薬剤 & 子供の場合
//          if (mixMedicCodeList.stream().anyMatch(entry.getKey()::endsWith))
//          {
//            // 1. 新しいリストに追加された (D1)
//            resultContainer.setInsList(entry.getValue()
//              .stream().filter( fOms ->
//                orgEntityValue.stream()
//                  .noneMatch(oOms ->
//                    StringUtils.equals(fOms.getSuppliesCd(), oOms.getSuppliesCd())
//                    && StringUtils.equals(fOms.getMedicineNo(), oOms.getMedicineNo()))
//              )
//              .toList());
//            // 2. 更新が必要な (D2)
//            comparingOms(resultContainer, entry, orgEntityValue);
//
//            // 3. 古いリストから削除する必要がある残りの (B1)
//            resultContainer.setDelList(
//              orgEntityValue.stream().filter(
//                oOms -> entry.getValue().stream()
//                  .noneMatch(fOms -> StringUtils.equals(oOms.getSuppliesCd(), fOms.getSuppliesCd())
//                    && StringUtils.equals(oOms.getMedicineNo(), fOms.getMedicineNo()))
//              )
//              .toList()
//            );
//
//          }
//          // 普通の場合
//          else {
//            // 更新が必要なのみ
//            comparingOms(resultContainer, entry, orgEntityValue);
//          }
//        }
//        // 理論上起こらない分岐は、念のために
//        else {
//          if (CollectionUtils.isEmpty(entry.getValue()) && !CollectionUtils.isEmpty(orgEntityValue))
//            resultContainer.setDelList(orgEntityValue);
//
//          if (!CollectionUtils.isEmpty(entry.getValue()) && CollectionUtils.isEmpty(orgEntityValue))
//            resultContainer.setUpdList(entry.getValue());
//        }

      }

      /* ========== 第二回双方向短絡 End ========== */

      /* End ***** 昇竜拳 ***** End */

    }

    // このレコードはすでに使用されており、削除を待つ
    materialSaveCacheList.get(ordNo).setHasUsed(true);

    return resultContainer;
  }

  private void comparingOms(DiffResultContainer resultContainer
    , Map.Entry<String, List<OrdMaterialSave>> entry
    , List<OrdMaterialSave> orgEntityValue) {

    resultContainer.setUpdList(
      entry.getValue()
        .stream()
        .filter( fOms -> {
            Optional<OrdMaterialSave> findCase = orgEntityValue.stream().filter(
              oOms ->
                !StringUtils.equals(fOms.getSuppliesCd(), oOms.getSuppliesCd())
                  || !StringUtils.equals(fOms.getMedicineMixCd(), oOms.getMedicineMixCd())
                  || !StringUtils.equals(fOms.getMedicineNo(), oOms.getMedicineNo())
                  || !StringUtils.equals(fOms.getClassCd(), oOms.getClassCd())
                  || !StringUtils.equals(fOms.getProcedureCd(), oOms.getProcedureCd())
                  || !StringUtils.equals(fOms.getTimingCd(), oOms.getTimingCd())
                  || !StringUtils.equals(fOms.getIndRstValue(), oOms.getIndRstValue())
                  || !StringUtils.equals(fOms.getReceiptValue(), oOms.getReceiptValue())
                  || !StringUtils.equals(fOms.getReceiptConversion(), oOms.getReceiptConversion())
//                  || !StringUtils.equals(fOms.getIsConfirm(), oOms.getIsConfirm())
            ).findFirst();
            boolean result = findCase.isPresent();
            if (result) fOms.setOrdMaterialSaveNo(findCase.get().getOrdMaterialSaveNo());
            return result;
          }
        ).toList()
    );
  }
}
