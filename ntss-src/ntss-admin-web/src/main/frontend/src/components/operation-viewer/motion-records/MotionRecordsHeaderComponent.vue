/**
 * 装置記録（詳細）ページ用ヘッダ
 */
<template>
  <div>
    <div class='header-item' v-on:click='showMachineDetail()' ref="header">
      <div style="width:60%;float:left;" class='mark-leftmost-header'>
        <!-- 利用者種別により部署符号及び病院名は表示しない -->
        <div class='row-1' v-if="!isGeneralUser">
          <label>{{ departmentCd }}</label>
          &nbsp;
          <label>{{ headerInfo.facilityName }}</label>
        </div>
        <div v-else>
          <p></p>
        </div>
        <div class='row-2'>
          <label>{{ headerInfo.machineType }}</label>
          &nbsp;
          <label>{{ headerInfo.machineSerial }}</label>
        </div>
        <div class='row-3'>
          <label>{{ headerInfo.machineName }}</label>
          &nbsp;
          <label style="overflow:hidden;">{{ headerInfo.bedName }}</label>
        </div>
      </div>
      <div class='processState'>
        <label :class="getProcessStateInfo(headerInfo.processState).class" @click='showPopover($event, getProcessStateInfo(headerInfo.processState).process_name)' >{{ getProcessStateInfo(headerInfo.processState).short_name }}</label>
      </div>
    </div>
    <!-- ヘッダクリック時に表示する画面 -->
    <div class="machine-record-detail" :style="displayDetail" style="z-index:100;">
      <div class='inner-header' style="margin:5px;" ref="innerHeader">
        <div style="text-align: center;" v-if="isDataGatheringButtonVisible">
          <button class='button btn1-execute' id='btn-data-gathering' @click='clickDataGathering()' :disabled='!isGatheringOk'>装置データファイル収集実行</button>
        </div>
        <div style="text-align: center;">
          <!--mod FNSI-編集権限の適用 江 start -->
          <!-- <button class='button btn4-alert' id='btn-all-correction-emergency' @click='clickAllCorrection(2)'>[警]全件対処</button> -->
          <button class='button btn4-alert' id='btn-all-correction-emergency' v-bind:disabled="isDisabled" @click='clickAllCorrection(2)'>[警]全件対処</button>
          <!--mod FNSI-編集権限の適用 江 end -->
          <!-- 予防保全対応不完全のため非表示とする -->
          <button class='button' id='btn-all-correction-forecast' @click='clickAllCorrection(3)' v-if='false'>[予]全件対処</button>
          <!-- 全件サービス対応済み -->
          <!-- mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start -->
          <button
            v-if="isNkkFacility"
            class="button btn4-alert"
            id="btn-all-servive-support"
            @click="changeAllServiceSupport(2)">[警]全件サービス対応済み</button>
          <!-- mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end -->
        </div>
      </div>
      <div :style="conditionStyle">
        <table class='ntss-list main-font' style="position: inherit;">
          <thead class="header-sticky" style="display:block;">
            <tr class='ntss-list-header-tr' style="display:-webkit-box;">
              <th class='ntss-list-header-th-sticky' colspan='2' style="border:none;">部品の運転／交換時間</th>
            </tr>
          </thead>
          <tbody v-if="partsRunningModel.comType === 1" style="display: block;">
            <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in dialyzeDeviceRows' :key='rows'>
              <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
              <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.dialyzeDevice[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
            </tr>
          </tbody>
          <tbody v-if="partsRunningModel.comType === 2 && partsRunningModel.comFormatCd === 'A'" style="display: block;">
            <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in dabRows' :key='rows'>
              <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
              <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.dab[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
            </tr>
          </tbody>
          <tbody v-if="partsRunningModel.comType === 2 && partsRunningModel.comFormatCd === 'D'" style="display: block;">
            <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in dadRows' :key='rows'>
              <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
              <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.dad[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
            </tr>
          </tbody>
          <tbody v-if="partsRunningModel.comType === 2 && partsRunningModel.comFormatCd === 'R'" style="display: block;">
            <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in droRows' :key='rows'>
              <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
              <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.dro[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
            </tr>
          </tbody>
          <tbody v-if="partsRunningModel.comType === 2 && (partsRunningModel.comFormatCd === 'I' || partsRunningModel.comFormatCd === 'J')" style="display: block;">
            <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in dryRows' :key='rows'>
              <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
              <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.dry[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
            </tr>
          </tbody>
          <tbody v-if="partsRunningModel.comType === 3 && partsRunningModel.comFormatCd === 'V'" style="display: block;">
            <tr class='ntss-list-body-tr' v-for='(rowItem, rows) in v4Rows' :key='rows'>
              <td class='ntss-list-body-td use-time-title-col'>{{ rowItem.itemName }}</td>
              <td class='ntss-list-body-td use-time-value-col'>{{ partsRunningModel.partsRunning.V4[rowItem.jsonAddress] }}{{ rowItem.unit }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <v-ons-popover id="pop-over-show" cancelable
                   v-model:visible='popoverTextVisible'
                   :target='popoverTextTarget'
                   :direction='popoverTextDirection'
                   :cover-target=false
                   :class="fontSizeSet"
                   >
      <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='100%' vertical-align='center'>
          <label> {{ displayShortName }} </label>
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>

  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
// 共通JavaScriptファイル
import commonjs from "@/constants/operationViewerCommon";
import PopoverMixin from "@/components/PopoverMixin";
//add FNSI-編集権限の適用 江 start
import { AUTHORITY_CODES } from "@/constants/userAuthority.js";
//add FNSI-編集権限の適用 江 end
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";

//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

/**
 * FTP収集：FTP収集する.
 */
const FTP_COLLECT_YES = "1";

export default {
  mixins: [PopoverMixin],
  data() {
    return {
     popoverTextVisible: false,
      popoverTextTarget: null,
      popoverTextDirection: "down",
      displayShortName : "",

      // ヘッダクリック時の表示
      popoverVisible: false,
      // 透析装置の場合の項目一覧
      dialyzeDeviceRows: [
        { itemName: "装置運転時間", jsonAddress: 0, unit: "h" },
        { itemName: "消耗品グループ１", jsonAddress: 1, unit: "h" },
        { itemName: "消耗品グループ２", jsonAddress: 2, unit: "h" },
        { itemName: "消耗品グループ３", jsonAddress: 3, unit: "h" },
        { itemName: "複式ポンプポペット運転時間", jsonAddress: 4, unit: "h" },
        {
          itemName: "複式ポンプキャップシール運転時間",
          jsonAddress: 5,
          unit: "h"
        },
        {
          itemName: "複式ポンプキャップスライダー運転時間",
          jsonAddress: 6,
          unit: "h"
        },
        { itemName: "背圧弁ダイアフラム運転時間", jsonAddress: 7, unit: "h" },
        { itemName: "除水ポンプポペット運転時間", jsonAddress: 8, unit: "h" },
        {
          itemName: "除水ポンプキャップシール運転時間",
          jsonAddress: 9,
          unit: "h"
        },
        { itemName: "脱気ポンプメカシ運転時間", jsonAddress: 10, unit: "h" },
        { itemName: "加圧ポンプメカシ運転時間", jsonAddress: 11, unit: "h" },
        { itemName: "原液ポンプポペット運転時間", jsonAddress: 12, unit: "h" },
        {
          itemName: "原液ポンプキャップシール運転時間",
          jsonAddress: 13,
          unit: "h"
        },
        {
          itemName: "原液背圧ダイアフラム運転時間",
          jsonAddress: 14,
          unit: "h"
        },
        { itemName: "原液フィルター運転時間", jsonAddress: 15, unit: "h" },
        { itemName: "微粒子ろ過フィルタ運転時間", jsonAddress: 16, unit: "h" },
        { itemName: "エアフィルタ運転時間", jsonAddress: 17, unit: "h" },
        { itemName: "薬液フィルタ運転時間", jsonAddress: 18, unit: "h" },
        { itemName: "透析液戻り口フィルタ", jsonAddress: 19, unit: "h" },
        { itemName: "装置背面ファン用フィルタ", jsonAddress: 20, unit: "h" },
        { itemName: "原液ノズルＯリング", jsonAddress: 21, unit: "h" },
        { itemName: "バイパスコネクタＯリング", jsonAddress: 22, unit: "h" },
        {
          itemName: "ダイアライザーカップリングＯリング",
          jsonAddress: 23,
          unit: "h"
        },
        { itemName: "電磁弁", jsonAddress: 24, unit: "h" },
        { itemName: "薬液電磁弁", jsonAddress: 25, unit: "h" },
        { itemName: "脱気ポンプインペラ", jsonAddress: 26, unit: "h" },
        { itemName: "加圧ポンプインペラ", jsonAddress: 27, unit: "h" },
        { itemName: "複式ポンプテープベアリング", jsonAddress: 28, unit: "h" },
        { itemName: "逆止弁", jsonAddress: 29, unit: "h" },
        { itemName: "脱気ポンプフィルタ", jsonAddress: 30, unit: "h" },
        {
          itemName: "微粒子ろ過フィルタ２運転時間",
          jsonAddress: 31,
          unit: "h"
        },
        { itemName: "レベル調整ポンプしごき部", jsonAddress: 32, unit: "h" },
        { itemName: "サンプルポートガスケット", jsonAddress: 33, unit: "h" },
        { itemName: "ダイアライザーカップリング", jsonAddress: 34, unit: "h" },
        { itemName: "サンプルポート逆止弁", jsonAddress: 35, unit: "h" }
      ],
      // ＤＡＢ
      dabRows: [
        { itemName: "装置運転時間", jsonAddress: 1, unit: "h" },
        { itemName: "消耗品グループ１", jsonAddress: 2, unit: "h" },
        { itemName: "消耗品グループ２", jsonAddress: 3, unit: "h" },
        { itemName: "消耗品グループ３", jsonAddress: 4, unit: "h" },
        { itemName: "水計量シリンダ（往復動運転）", jsonAddress: 5, unit: "h" },
        {
          itemName: "水計量シリンダ（バイパス運転）",
          jsonAddress: 6,
          unit: "h"
        },
        { itemName: "Ｂ原液注入ポンプＰ１運転時間", jsonAddress: 7, unit: "h" },
        { itemName: "Ａ原液注入ポンプＰ２運転時間", jsonAddress: 8, unit: "h" },
        { itemName: "送液ポンプＰ４運転時間", jsonAddress: 9, unit: "h" },
        { itemName: "薬液注入ポンプＰ５運転時間", jsonAddress: 10, unit: "h" },
        { itemName: "脱気ポンプＰ６運転時間", jsonAddress: 11, unit: "h" },
        { itemName: "脱気ポンプＰ７運転時間", jsonAddress: 12, unit: "h" },
        {
          itemName: "パワーユニットファンフィルタ",
          jsonAddress: 13,
          unit: "h"
        },
        {
          itemName: "水計量シリンダ電磁弁動作回数",
          jsonAddress: 14,
          unit: "万回"
        },
        { itemName: "給水電磁弁動作回数", jsonAddress: 15, unit: "万回" }
      ],
      // ＤＡＤ
      // NOTE: 通信仕様書は 2 -> 消耗品グループ１（時間）, 3 -> 消耗品グループ１（回数）だが、実機は逆になっている。実機に合わせる。
      dadRows: [
        { itemName: "装置運転時間", jsonAddress: 1, unit: "h" },
        /* mod #内部6475 by zhangruixue 消耗品グループ１（時間）」和「消耗品グループ１（回数）」输入的数据和遠隔監視界面显示的数据不一致 --start */
        { itemName: "消耗品グループ１（回数）", jsonAddress: 2, unit: "回" },
        { itemName: "消耗品グループ１（時間）", jsonAddress: 3, unit: "h" },
        /* mod  by zhangruixue --end */
        { itemName: "消耗品グループ２", jsonAddress: 4, unit: "h" },
        { itemName: "消耗品グループ３", jsonAddress: 5, unit: "h" },
        { itemName: "減容カッター", jsonAddress: 6, unit: "回" },
        { itemName: "微粒子除去フィルタ", jsonAddress: 7, unit: "h" },
        { itemName: "電源装置ファン用フィルタ", jsonAddress: 8, unit: "h" },
        { itemName: "ＨＥＰＡフィルタ用フィルタ", jsonAddress: 9, unit: "h" }
      ],
      // ＤＲＯ
      droRows: [
        { itemName: "１０μフィルタ", jsonAddress: 1, unit: "h" },
        { itemName: "カーボンフィルタ", jsonAddress: 2, unit: "h" },
        { itemName: "ＬＲＯ膜", jsonAddress: 3, unit: "h" },
        { itemName: "ＲＯ膜", jsonAddress: 4, unit: "h" },
        { itemName: "エアフィルタ", jsonAddress: 5, unit: "h" },
        { itemName: "ＲＯ水タンクＵＶランプ", jsonAddress: 6, unit: "h" },
        { itemName: "濃縮水タンクＵＶランプ", jsonAddress: 7, unit: "h" },
        { itemName: "排水回収ＲＯ膜", jsonAddress: 8, unit: "h" }
      ],
      // DRY-50A、DRY-50B
      dryRows: [
        { itemName: "微粒子ろ過フィルタ運転時間", jsonAddress: 1, unit: "h" },
        { itemName: "消耗品グループ運転時間", jsonAddress: 2, unit: "h" }
      ],
      // V4
      v4Rows: [
        { itemName: "ETRF1時間", jsonAddress: 16, unit: "h" },
        { itemName: "ETRF2時間", jsonAddress: 31, unit: "h" }
      ],
      headerHeight: 0
    };
  },
  computed: {
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "isDispMenu",
      "isNkkFacility"
    ]),
    // add FNSI redmine #4366修正 鄧シン start
    ...mapGetters("account-edit", [
      "getFontSize"
    ]),
    // add FNSI redmine #4366修正 鄧シン end
    ...mapGetters("user", ["isGeneralUser"]),
    ...mapGetters("operation-viewer/motion-record", [
      "getHeaderInfo",
      "getMachineTypeCd",
      "getPartsRunningResult",
      "isGatheringOk"
    ]),
    ...mapGetters("operation-viewer/machine", ["getDepartmentCd"]),
    ...mapGetters("window-size", ["getWindowHeight"]),

    // ------------------------------------------------------------------
    // 処理：装置記録のstateからヘッダ情報を取得
    // ------------------------------------------------------------------
    headerInfo() {
      return this.getHeaderInfo;
    },
    // ------------------------------------------------------------------
    // 処理：装置一覧のstateから部署符号を取得
    // ------------------------------------------------------------------
    departmentCd() {
      return this.getDepartmentCd;
    },
    displayDetail() {
      return this.popoverVisible ? "" : "display:none;";
    },
    footerHeight() {
      if (this.isDispMenu !== 1) {
        return 0;
      }
      const footer = (this.$el?.ownerDocument || document).getElementById("footer-menu");
      return Number(
        footer?.clientHeight || footer?.getBoundingClientRect?.().height || 50
      );
    },
    breadcrumbHeight() {
      const breadcrumb = (this.$el?.ownerDocument || document).querySelector(".bread-crumbs");
      return Number(
        breadcrumb?.clientHeight || breadcrumb?.getBoundingClientRect?.().height || 35
      );
    },
    conditionStyle() {
      // add FNSI redmine #4366修正 鄧シン start
      let size = this.getFontSize;
      switch (size) {
        case "0":
          this.headerHeight = 81;
          break;
        case "1":
          this.headerHeight = 100;
          break;
        case "2":
          this.headerHeight = 109;
          break;
        case "3":
          this.headerHeight = 129;
          break;
      }
      // add FNSI redmine #4366修正 鄧シン end
      const height =
        this.getWindowHeight -
        (this.headerHeight + this.footerHeight + this.breadcrumbHeight + 12);
      return {
        height: Math.max(height, 0) + "px",
        "overflow-y": "auto"
      };
    },
    partsRunningModel() {
      return this.getPartsRunningResult;
    },
    isFtp() {
      return this.headerInfo.isFtp === FTP_COLLECT_YES;
    },
    isDataGatheringButtonVisible() {
      return !this.isGeneralUser && this.isFtp;
    },
	//add FNSI-編集権限の適用 江 start
    isDisabled(){
      if(this.getStateUserAccountInfo
              .userSettings
              .authorized_authorities
              .includes(AUTHORITY_CODES.DEV_EDIT) === true){
        return false;
      }else{
        return true;
      }
    },
	//add FNSI-編集権限の適用 江 end
  },
  methods: {
    ...mapGetters("app", ["getProtocol", "getHost"]),
    ...mapGetters("user", ["getUserType"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("operation-viewer/motion-record", [
      "getPartsRunning",
      "updateAllCorrection",
      "fetchMotionRecords",
      "requestDataGathering",
      "refreshGatheringStatus",
      "updateServiceSupportAll"
    ]),

    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event, process_name) {
      this.displayShortName =  process_name;
      this.popoverTextTarget = event;
      this.popoverTextVisible = true;
    },

    // ------------------------------------------------------------------
    // 処理：ヘッダクリックイベント処理
    // ------------------------------------------------------------------
    showMachineDetail() {
      if(!this.popoverTextVisible) {
      this.popoverVisible = !this.popoverVisible;

        if (this.popoverVisible) {
          this.loadData();
          EventBus.$on("partsRunningLoad", this.loadData);
        } else {
          EventBus.$off("partsRunningLoad", this.loadData);
        }
      }
    },
    // ------------------------------------------------------------------
    // 部品の運転/交換時間の取得処理
    // ------------------------------------------------------------------
    loadData(autoRefreshFlag) {
      // 部品の運転/交換時間を取得
      this.getPartsRunning({
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        autoRefreshFlag
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('MotionRecordsHeaderComponent.vue', 'showMachineDetail', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        if (error.response.status === 400) {
          // TODO 必要に応じて、適切な業務エラー処理を実装すること。
        }
      });

      if (this.isDataGatheringButtonVisible) {
        // ボタンが表示される場合、データ収集ステータスの最新化
        this.refreshGatheringStatus({
          userId: this.getStateUserAccountInfo.userId,
          facilityCd: this.getHeaderInfo.facilityCd
        });
      }

      this.$nextTick(() => {
        this.headerHeight =
          this.$refs.header.clientHeight +
          this.$refs.innerHeader.clientHeight;
      });
    },
    // ------------------------------------------------------------------
    // 装置に該当する全ての未対処を対処済に変更するイベント
    // 引数：1 -> 緊急発報、2 -> 予防保守
    // ------------------------------------------------------------------
    async clickAllCorrection(targetDataType) {
      // 共通ローダー:表示名設定/表示開始
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // リクエスト情報を作成
      const request = {
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        userId: this.getStateUserAccountInfo.userId,
        dataType: targetDataType
      };
      // 更新処理
      this.updateAllCorrection(request)
        .then(() => {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          // mod #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen start
          // EventBus.$emit("refresh");
          EventBus.$emit("refresh", "all");
          // mod #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen end
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordsHeaderComponent.vue', 'clickAllCorrection', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    },
    /**
     * 表示している装置に該当するサービス対応区分が未受付、1次対応済みのデータをサービス対応済みに更新する.
     */
    // mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
    // async changeAllServiceSupport() {
    async changeAllServiceSupport(targetDataType) {
      // mod 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end
      // 共通ローダ：表示開始
      this.setLoadingScreenVisible(true);
      // リクエストパラメータ作成
      const param = {
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 start
        dataType: targetDataType,
        // add 11042 nkknkk施設の遠隔監視の警報対処不正動作 関 end
      }
      await this.updateServiceSupportAll(param).then(() =>{
        // 画面再描画
        EventBus.$emit("refresh", "all");
      }).catch(err => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('MotionRecordsHeaderComponent.vue', 'changeAllServiceSupport', err);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw err;
      }).finally(() => {
        // 共通ローダ：表示終了
        this.setLoadingScreenVisible(false);
      });
    },
    // ------------------------------------------------------------------
    // データ収集のRestAPI呼出しイベント
    // ------------------------------------------------------------------
    clickDataGathering() {
      // 共通ローダー:表示名設定/表示開始
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // リクエスト情報作成
      const request = {
        protocol: this.getProtocol(),
        host: this.getHost(),
        facilityCd: this.getHeaderInfo.facilityCd,
        deviceEdgeNo: this.getHeaderInfo.deviceEdgeNo,
        machineTypeCd: this.getHeaderInfo.machineTypeCd,
        comFormatCd: this.getHeaderInfo.comFormatCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        userId: this.getStateUserAccountInfo.userId
      };
      this.requestDataGathering(request);
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    // ------------------------------------------------------------------
    // 処理：工程コード(processType)に該当する略称を取得
    //       ※工程コードに該当する情報がない場合にはデフォルトの工程情報を返却する
    // 引数：processState : 工程コード
    // 戻り値：工程に関する情報(prcessStateInfosの工程コードが一致する情報)
    // ------------------------------------------------------------------
    getProcessStateInfo(processState) {
      return commonjs.getProcessStateInfo(processState);
    }
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
  beforeUnmount() {
    EventBus.$off("partsRunningLoad", this.loadData);
  }
};
</script>

<style scoped>
/* ボタン共通のスタイル */
.button {
  margin: 2px;
  font-size: 1.5em;
  border-radius: 3px;
}

/* 装置データファイル収集ボタンのスタイル */
#btn-data-gathering {
  width: 90%;
}

#btn-data-gathering:disabled {
  opacity: 0.3;
}

/* [警]全件対処ボタン、[警]全件サービス対応済みのスタイル */
#btn-all-correction-emergency,
#btn-all-servive-support {
  font-size: 1.7em;
  width: 90%;
}

/* [予]全件対処ボタンのスタイル */
#btn-all-correction-forecast {
  background-color: yellow;
}

/** 運転／交換時間の左カラムのスタイル */
.use-time-title-col {
  width:100%;
}
/** 運転／交換時間の右カラムのスタイル */
.use-time-value-col {
  white-space: nowrap;
  width:80px;
}

:deep(.popover--top) {
  width: auto !important;
}
:deep(.popover__content) {
  min-height: auto !important;
}
</style>
