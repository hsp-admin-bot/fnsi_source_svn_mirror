package jp.co.nikkiso.ntss.api.service.PatMainDeviceSetInfo;


import java.util.Map;

// add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start

/**
 * pat_mainのdevice_set_infoを更新するServiceインタフェース.
 */
public interface PatMainDeviceSetInfoService {

    void updDeviceSetInfo(String facilityCd, Long patId, Map<String, String> userAuthInfo, int isTpHTDataAvailableFlag) throws Exception;

    int isTpHTDataAvailable(String facilityCd, Long examMainCd) throws Exception;

    //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc start
    void insertPatMainHistoryByPatIdFacilityCd(String facilityCd, Long patId) throws Exception;
    //add #10632 装置設定画面の更新時にpat_main_historyがインサートされない 20240530 ztc end
}
// add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
