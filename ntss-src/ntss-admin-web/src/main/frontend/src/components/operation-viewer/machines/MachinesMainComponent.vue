/**
 * 稼働ビューア MainContent
 */
<template>
  <div class="main-content-area" id="myTable" ref="scrollContainer">
    <table class="ntss-list">
      <thead>
        <tr>
          <th v-for='column in getDisplayColumns()'
              :key='column.key'
              :class="[sortedClass(column.key), column.centerAlign ? 'list-header-th-center' : '']"
              class="ntss-list-header-th-sticky"
              :style="{ width:column.width + '%' }"
              @click="sortBy(column.key)">{{ column.colName }}</th>
        </tr>
      </thead>
      <tbody>
        <!-- mod FNSI-add refresh 江 start -->
        <!-- <tr v-for='machine in filterMachines(sortedItems)'
            :key='machine.machineSerial + machine.bedName'
            class="ntss-list-body-tr"
            :class="getBackgroudColorClass(machine)"> -->
        <tr v-for='machine in this.machinesData'
            :key='machine.machineSerial + machine.bedName'
            class="ntss-list-body-tr"
            :class="getBackgroudColorClass(machine)">
        <!-- mod FNSI-add refresh 江 end -->
          <!-- 起動時はベッド名を表示、装置名は非表示 -->
          <td class='ntss-list-body-td' v-if="getDisplayNameFlag"  @click='goNext(machine)' >{{ machine.bedName }}</td>
          <td class='ntss-list-body-td' v-else  @click='goNext(machine)'>{{ machine.machineName }}</td>
          <td class='ntss-list-body-td'  @click='goNext(machine)'>{{ machine.machineType }}</td>
          <td class='ntss-list-body-td'  @click='goNext(machine)'>{{ machine.machineSerial }}</td>
          <!-- 工程列 -->
          <td class='ntss-list-body-td ntss-list-body-td-text-center'
            :class="getProcessStateInfo(machine.processState).class"
            @click='showPopover($event, machine, getProcessStateInfo(machine.processState).process_name)'
          >
            {{ getProcessStateInfo(machine.processState).short_name }}
          </td>
          <!-- 隠し列 -->
          <td class='ntss-list-body-td' style="display:none">{{ machine.processState }}</td>
          <!-- 自己診断結果列 -->
          <td class='ntss-list-body-td ntss-list-body-td-text-center'
            :class="getSelfMeasureResultInfo(machine.selfMeasureResult).class"
            @click='showPopover($event, machine, getSelfMeasureResultInfo(machine.selfMeasureResult).self_measure_name)'
          >
            {{ getSelfMeasureResultInfo(machine.selfMeasureResult).short_name }}
          </td>
        </tr>
      </tbody>
    </table>

        <v-ons-popover id="pop-over-show" cancelable
                   :visible.sync='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target="false"
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
import NextTransitionMixin from "@/components/NextTransitionMixin";
// 共通JavaScriptファイル
import commonjs from "@/constants/operationViewerCommon";
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import { OPERATION_VIEWER_AUTO_SETTING, OPERATION_VIEWER_FORCE_SIGNOUT } from "@/constants/facilitySetting";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import PopoverMixin from "@/components/PopoverMixin";

//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
import { initForceSignOutFlag } from "@/functions/common/CommonFunctions.js";

export default {
  mixins: [NextTransitionMixin, PopoverMixin],
  data() {
    return {
     popoverVisible: false,
      popoverTarget: null,
      displayShortName : "",
      popoverDirection: "down up",

      userid: "",
      columns: [
        {
          key: "bedName",
          colName: "ベッド名",
          width: 30,
          centerAlign: false
        },
        {
          key: "machineName",
          colName: "装置名　",
          width: 30,
          centerAlign: false
        },
        {
          key: "machineType",
          colName: "型式",
          width: 40,
          centerAlign: false
        },
        {
          key: "machineSerial",
          colName: "製造番号",
          width: 30,
          centerAlign: false
        },
        {
          key: "processState",
          colName: "工",
          width: 10,
          centerAlign: true
        },
        {
          key: "selfMeasureResult",
          colName: "自",
          width: 10,
          centerAlign: true
        }
      ],
      sort: {
        key: "",
        isAsc: true
      },
      timerObj: null,
      /**
       * 「警報通知発生降順のソート」がチェックされている時にソートするキー名
       */
      isAlarmSortKey: "maxEventRegDate",
      machinesData : null,
      selfScreenPath: "",
      scrollTop: 0,
      refreshInterval: 0
    };
  },
	//add FNSI-add refresh 江 start
  watch:{
    condition:{
      handler:function(val,oldVal){
        this.getMachinesData();
      },
      deep: true
    },
    sort:{
      handler:function(val,oldVal){
        this.getMachinesData();
      },
      deep: true
    }
  },
	//add FNSI-add refresh 江 end
  computed: {
    ...mapGetters("operation-viewer/machine", [
      "getMachines",
      "getFacilityCd",
      "getCondition",
      "getDisplayNameFlag"
    ]),
    ...mapGetters("account-edit", [
      "isNkkFacility",
      "getStateUserAccountInfo"
    ]),
    ...mapGetters("user", [
      "getUserType"
    ]),
    ...mapGetters("operation-viewer/facility", [
      "isAlarmSort"
    ]),
    /**
     * ソートを行う.
     */
    sortedItems() {
      let list = this.getMachines.slice(); // ソート時でstate自体の順序を書き換えないため

      if (!this.isNkkFacility && !this.sort.key) {
        // 顧客施設用、且つ sort.key が指定されていない場合のソート処理

        // 未対処の装置記録を含む装置を抽出し、最新順にソート
        const hasLatestPendingDateList = list
          .filter(r => r.latestPendingDate)
          .sort((a, b) => commonjs.compareTimeKey(a, b, "latestPendingDate", false));

        // 対処中の装置記録を含む装置を抽出し、最新順にソート
        const hasLatestWipDateList = list
          .filter(r => r.latestWipDate && !r.latestPendingDate)
          .sort((a, b) => commonjs.compareTimeKey(a, b, "latestWipDate", false));

        // 未対処、対処中以外(対処済/装置記録が存在しない装置)のソート
        let otherEventlist = [];
        if (this.getDisplayNameFlag) {
          // ベッド名表示
           otherEventlist = list
          .filter(r => !r.latestPendingDate && !r.latestWipDate)
          .sort(function(a, b) {
            let nullLast = 1;
            // 第1条件：model で並び替え
            if (a.model !== b.model) {
              nullLast = a.model === null || b.model === null ? -1 : 1;
              if (a.model < b.model) {
                return -1 * nullLast;
              }
              if (a.model > b.model) {
                return 1 * nullLast;
              }
            }
            // 第2条件：ベッドマスタ表示順で並び替え
            if (a.bedDispNo !== b.bedDispNo) {
              nullLast = a.bedDispNo === null || b.bedDispNo === null ? -1 : 1;
              const bNoA = a.bedDispNo === null ? a.bedDispNo : Number(a.bedDispNo);
              const bNoB = b.bedDispNo === null ? b.bedDispNo : Number(b.bedDispNo);
              if (bNoA < bNoB) {
                return -1 * nullLast;
              }
              if (bNoA > bNoB) {
                return 1 * nullLast;
              }
            }
            // 第3条件：装置マスタ表示順で並び替え
            if (a.machineDispNo !== b.machineDispNo) {
              nullLast = a.machineDispNo === null || b.machineDispNo === null ? -1 : 1;
              const mNoA = a.machineDispNo === null ? a.machineDispNo : Number(a.machineDispNo);
              const mNoB = b.machineDispNo === null ? b.machineDispNo : Number(b.machineDispNo);
              if (mNoA < mNoB) {
                return -1 * nullLast;
              }
              if (mNoA > mNoB) {
                return 1 * nullLast;
              }
            }
            return 0;
          });
        } else {
          // 装置名表示
          otherEventlist = list
          .filter(r => !r.latestPendingDate && !r.latestWipDate)
          .sort(function(a, b) {
            let nullLast = 1;
            // 装置マスタ表示順で並び替え
            if (a.machineDispNo !== b.machineDispNo) {
              if (a.machineDispNo === null || b.machineDispNo === null) {
                nullLast = -1;
              }
              const mNoA = a.machineDispNo === null ? a.machineDispNo : Number(a.machineDispNo);
              const mNoB = b.machineDispNo === null ? b.machineDispNo : Number(b.machineDispNo);
              if (mNoA < mNoB) {
                return -1 * nullLast;
              }
              if (mNoA > mNoB) {
                return 1 * nullLast;
              }
            }
          });
        }

        // 未対処→対処中→それ以外(対処済/装置記録が存在しない装置)の順で表示する
        return [
          ...hasLatestPendingDateList,
          ...hasLatestWipDateList,
          ...otherEventlist
        ]
      }

      // サインイン者の利用者種別を取得する.
      // 利用者種別が'1' かつ警報通知発生降順のソートがtrueの場合
      // 最大イベント発生日時が含まれるリスト
      const hasMaxEventRegDateList = list.filter(r => {
        return (r.maxEventRegDate);
      });
      const notHasMaxEventRegDateList = list.filter(r => {
        return (!r.maxEventRegDate);
      });
      if (this.sort.key) {
        if (this.getUserType === 1 && this.isAlarmSort) {
          list = [
              ...hasMaxEventRegDateList.sort((a, b) =>
                commonjs.compareKey(a, b, this.isAlarmSortKey, false)
              ),
              ...notHasMaxEventRegDateList.sort((a, b) =>
                commonjs.compareKey(a, b, this.sort.key, this.sort.isAsc)
              )
            ];
        } else {
          list.sort((a, b) =>
            commonjs.compareKey(a, b, this.sort.key, this.sort.isAsc)
          );
        }
      } else {
        if (this.getUserType === 1 && this.isAlarmSort) {
          list = [
            ...hasMaxEventRegDateList.sort((a, b) =>
              commonjs.compareKey(a, b, this.isAlarmSortKey, false)
            ),
            ...notHasMaxEventRegDateList
          ];
        }
      }
      return list;
    },
	  //add FNSI-add refresh 江 start
    condition:{
      get(){
        return this.getCondition
      },
      set (val) {
        this.setCondition(val)
      }
    }
	  //add FNSI-add refresh 江 end
  },
  methods: {
    ...mapActions("operation-viewer/motion-record", ["setHeaderInfo"]),
	  //mod FNSI-add refresh 江 start
    // ...mapActions("operation-viewer/machine", ["findMachines", "getSelfMeasureResultInfo"]),
    ...mapActions("operation-viewer/machine", ["findMachines", "getSelfMeasureResultInfo", "setCondition"]),
    // 共通ローダー設定
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
	  //mod FNSI-add refresh 江 end
    ...mapGetters("app", ["getQueryParameters"]),
    /**
     * 表示する列情報を取得する.
     *
     * @returns 表示する列情報
     */
    getDisplayColumns() {
      // 非表示とする列名を取得
      const hiddenColName = this.getDisplayNameFlag ? "machineName" : "bedName";
      // 非表示とする列名以外の列情報を取得
      const dispColumns = this.columns.filter(c => {
        return c.key !== hiddenColName;
      });
      return dispColumns;
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event, machine, name) {
      //this.addMotionRecordState(machine);
      this.displayShortName = name;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    /**
     * 装置記録画面に遷移する.
     *
     * @param {*} machine 選択された装置
     */
    goNext(machine) {
      this.addMotionRecordState(machine);
      this.setSelfMeasureResult(machine);
      this.goNextView();
    },
    // 昇順/降順のclassを作成
    sortedClass(key) {
      return this.sort.key === key
        ? `sorted-${this.sort.isAsc ? "desc" : "asc"}`
        : "";
    },
    // ソートするキーを設定する
    sortBy(key) {
      if (key === this.sort.key && !this.sort.isAsc) {
        // ソートをクリア
        this.sort.key = "";
        this.sort.isAsc = true;
        return;
      }
      this.sort.isAsc = this.sort.key === key ? !this.sort.isAsc : true;
      this.sort.key = key;
    },
    /**
     * 背景色用のクラスを取得する.
     *
     * サインイン者が日機装施設に属している場合は、サービス対応件数で背景色(赤)の制御を行う.
     * それ以外は、緊急発報件数で背景色(赤)の制御を行う.
     * どちらの場合も、予防保守件数、通信不良件数での背景色の制御を行う.
     * :class="[machine.colorFlg  === 1 ? 'ntss-list-body-tr, emergency-row' : [machine.colorFlg === 2 ? 'ntss-list-body-tr, preventive-row' : [machine.colorFlg === 3 ? 'ntss-list-body-tr, com-problem-row' : 'ntss-list-body-tr']]]"
     *
     * @param {*} facility リスト1行毎の装置情報
     * @returns クラス名
     */
    getBackgroudColorClass(machine) {
      // 日機装施設の場合
      if (this.isNkkFacility) {
        if (machine.serviceSupportCnt > 0) {
          return "emergency-row";
        } else if (machine.isPreventiveMainte === 1) {
          return "com-problem-row";
        } else if (machine.colorFlg === 2) {
          return "preventive-row";
        } else if (machine.colorFlg === 3) {
          return "com-problem-row";
        }
      } else {
        if (machine.colorFlg === 1) {
          return "emergency-row";
        } else if (machine.colorFlg === 2) {
          return "preventive-row";
        } else if (machine.colorFlg === 3) {
          return "com-problem-row";
        }
      }
      return "";
    },
    // 装置動作記録一覧用stateに登録する
    addMotionRecordState(machine) {
      this.setHeaderInfo(machine);
    },
    // ------------------------------------------------------------------
    // 処理：工程コード(processType)に該当する略称を取得
    //       ※工程コードに該当する情報がない場合にはデフォルトの工程情報を返却する
    // 引数：processState : 工程コード
    // 戻り値：工程に関する情報(prcessStateInfosの工程コードが一致する情報)
    // ------------------------------------------------------------------
    getProcessStateInfo(processState) {
      return commonjs.getProcessStateInfo(processState);
    },
    // ------------------------------------------------------------------
    // 処理：自己診断結果情報の取得
    // 引数：selfMeasureResult(自己診断結果)
    // 戻値：selfMeasureResultInfos(自己診断結果情報)該当の情報
    // 備考：selfMeasureResultInfos(自己診断結果情報)該当の情報無しの場合、デフォルト(未実施)返却
    // ------------------------------------------------------------------
    getSelfMeasureResultInfo(selfMeasureResult) {
      return commonjs.getSelfMeasureResultInfo(selfMeasureResult);
    },
    filterMachines(machines) {
      // 緊急発報の表示可否
      const isEmergency = this.getCondition.machineEmergency;
      // 予防保守の表示可否
      const isProphylaxis = this.getCondition.machineProphylaxis;
      // 通信不要の表示可否
      const isDefect = this.getCondition.machineDefect;
      // 全情報の表示可否
      const isAll = this.getCondition.machineAll;
      // 抽出条件で絞り込んだ結果を格納する変数
      const filterMachines = [];
      // -----------------------------------------
      // 抽出条件が入力されている場合
      // -----------------------------------------
      for (let idx = 0; idx < machines.length; idx++) {
        // mod 9970 遠隔監視における緊急発報と通信不良の絞り込み条件の動作が不正 関 start
        // if (isAll) {
        //   filterMachines.push(machines[idx]);
        // } else if (isEmergency) {
        //   // filterMachines.push(machines[idx]);
        //   if (this.isNkkFacility ? machines[idx].serviceSupportCnt > 0 : machines[idx].mnoticeCnt > 0) {
        //     filterMachines.push(machines[idx]);
        //   }
        // } else if (isProphylaxis && machines[idx].preventiveMainteCnt > 0) {
        //   filterMachines.push(machines[idx]);
        // } else if (isDefect && machines[idx].isPreventiveMainte > 0) {
        //   filterMachines.push(machines[idx]);
        // }
        if (isAll) {
          filterMachines.push(machines[idx]);
        } else {
          let pushFalg = false
          if (isEmergency) {
            if (this.isNkkFacility ? machines[idx].serviceSupportCnt > 0 : machines[idx].mnoticeCnt > 0) {
              pushFalg = true;
            }
          }
          if (isProphylaxis && machines[idx].preventiveMainteCnt > 0) {
            pushFalg = true;
          }
          if (isDefect && machines[idx].isPreventiveMainte > 0) {
            pushFalg = true;
          }
          if (pushFalg) {
            filterMachines.push(machines[idx]);
          }
        }
        // mod 9970 遠隔監視における緊急発報と通信不良の絞り込み条件の動作が不正 関 end
      }
      return filterMachines;
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    async refresh(isMainContent, autoRefreshFlag) {
      if (isMainContent === undefined){
        const paths = this.$route.matched.map(item => item.path);
        if (!paths?.includes(this.selfScreenPath)) {
          return;
        }
      } else if (isMainContent === "Machines") {
        return;
      }
	    //add FNSI-add refresh 江 start
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.machinesData = null ;
      // del #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen start
      // this.sort.key="";
      // del #8640 「【デグレ】警報を対処済にしてもバックカラーが赤いまま」について、対応する。 dengshen end
	    //add FNSI-add refresh 江 end
      const queryParameters = this.getQueryParameters();
      if (this.getFacilityCd === "") {
        const facilityCd = this.getStateUserAccountInfo.facilityCd;
	      //add FNSI-add refresh 江 start
        // this.findMachines(facilityCd).catch(error => {
        //   if (error.response.status === 400) {
        //     // TODO 必要に応じて、適切な業務エラー処理を実装すること。
        //   }
        // });
        await this.findMachines({facilityCd, autoRefreshFlag}).then(
          response => {
            // 指定された間隔で一覧の再取得を行う
            clearTimeout(this.timerObj);
            this.timerObj = setTimeout(() => {
              this.refresh(undefined, true);
            }, this.refreshInterval);
           isMainContent !== "all" && EventBus.$emit("refresh", 'Machines', autoRefreshFlag);
           EventBus.$emit("partsRunningLoad", autoRefreshFlag);
           this.getMachinesData();
          }
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MachinesMainComponent.vue', 'refresh', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
	      //mod FNSI-add refresh 江 end
      } else {
	      //mod FNSI-add refresh 江 start
        // this.findMachines(this.getFacilityCd).catch(error => {
        //   if (error.response.status === 400) {
        //     // TODO 必要に応じて、適切な業務エラー処理を実装すること。
        //   }
        // });
        await this.findMachines({facilityCd: this.getFacilityCd, autoRefreshFlag}).then(
          response => {
            // 指定された間隔で一覧の再取得を行う
            clearTimeout(this.timerObj);
            this.timerObj = setTimeout(() => {
              this.refresh(undefined, true);
            }, this.refreshInterval);
            isMainContent !== "all" && EventBus.$emit("refresh", 'Machines', autoRefreshFlag);
            EventBus.$emit("partsRunningLoad", autoRefreshFlag);
            this.getMachinesData();
          }
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add starts
          getErrorMessage('MachinesMainComponent.vue', 'refresh', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
	      //mod FNSI-add refresh 江 end
      }
	  //del FNSI-add refresh 江 start
    //   // 指定された間隔で一覧の再取得を行う
    //   clearTimeout(this.timerObj);
    //   this.timerObj = setTimeout(
    //     this.refresh,
    //     systemSettings.reloadInterval.operationViewer.machines
    //   );
	  //del FNSI-add refresh 江 end
      //add FNSI-add refresh 江 start
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
      // #8640 警報を対処済にしてもバックカラーが赤いまま start
      // add 12409 治療状況リストから治療記録に遷移しサイドメニューから画面を開きパンくずリストの治療状況リストを押下すると画面遷移せずパンくずリストが消える zkm start
      if (undefined !== this.$refs.scrollContainer) {
        // add 12409 治療状況リストから治療記録に遷移しサイドメニューから画面を開きパンくずリストの治療状況リストを押下すると画面遷移せずパンくずリストが消える zkm end
        this.$refs.scrollContainer.scrollTop = this.scrollTop
      }
      // #8640 警報を対処済にしてもバックカラーが赤いまま end
      //add FNSI-add refresh 江 end
    },
    /**
     * 選択した装置から自己診断判定情報を取得する
     * @param {*} machine 選択された装置
     */
    setSelfMeasureResult(machine) {
      this.getSelfMeasureResultInfo(machine);
    },
	  //add FNSI-add refresh 江 start
    async getMachinesData(){
      let itemsData = this.getSortedItemsData();
      this.machinesData = this.filterMachines(itemsData);
    },
    getSortedItemsData(){
      let list = this.getMachines.slice(); // ソート時でstate自体の順序を書き換えないため

      if (!this.isNkkFacility && !this.sort.key) {
        // 顧客施設用、且つ sort.key が指定されていない場合のソート処理

        // 未対処の装置記録を含む装置を抽出し、最新順にソート
        const hasLatestPendingDateList = list
          .filter(r => r.latestPendingDate)
          .sort((a, b) => commonjs.compareTimeKey(a, b, "latestPendingDate", false));

        // 対処中の装置記録を含む装置を抽出し、最新順にソート
        const hasLatestWipDateList = list
          .filter(r => r.latestWipDate && !r.latestPendingDate)
          .sort((a, b) => commonjs.compareTimeKey(a, b, "latestWipDate", false));

        // 未対処、対処中以外(対処済/装置記録が存在しない装置)のソート
        let otherEventlist = [];
        if (this.getDisplayNameFlag) {
          // ベッド名表示
           otherEventlist = list
          .filter(r => !r.latestPendingDate && !r.latestWipDate)
          .sort(function(a, b) {
            let nullLast = 1;
            // 第1条件：model で並び替え
            if (a.model !== b.model) {
              nullLast = a.model === null || b.model === null ? -1 : 1;
              if (a.model < b.model) {
                return -1 * nullLast;
              }
              if (a.model > b.model) {
                return 1 * nullLast;
              }
            }
            // 第2条件：ベッドマスタ表示順で並び替え
            if (a.bedDispNo !== b.bedDispNo) {
              nullLast = a.bedDispNo === null || b.bedDispNo === null ? -1 : 1;
              const bNoA = a.bedDispNo === null ? a.bedDispNo : Number(a.bedDispNo);
              const bNoB = b.bedDispNo === null ? b.bedDispNo : Number(b.bedDispNo);
              if (bNoA < bNoB) {
                return -1 * nullLast;
              }
              if (bNoA > bNoB) {
                return 1 * nullLast;
              }
            }
            // 第3条件：装置マスタ表示順で並び替え
            if (a.machineDispNo !== b.machineDispNo) {
              nullLast = a.machineDispNo === null || b.machineDispNo === null ? -1 : 1;
              const mNoA = a.machineDispNo === null ? a.machineDispNo : Number(a.machineDispNo);
              const mNoB = b.machineDispNo === null ? b.machineDispNo : Number(b.machineDispNo);
              if (mNoA < mNoB) {
                return -1 * nullLast;
              }
              if (mNoA > mNoB) {
                return 1 * nullLast;
              }
            }
            return 0;
          });
        } else {
          // 装置名表示
          otherEventlist = list
          .filter(r => !r.latestPendingDate && !r.latestWipDate)
          .sort(function(a, b) {
            let nullLast = 1;
            // 装置マスタ表示順で並び替え
            if (a.machineDispNo !== b.machineDispNo) {
              if (a.machineDispNo === null || b.machineDispNo === null) {
                nullLast = -1;
              }
              const mNoA = a.machineDispNo === null ? a.machineDispNo : Number(a.machineDispNo);
              const mNoB = b.machineDispNo === null ? b.machineDispNo : Number(b.machineDispNo);
              if (mNoA < mNoB) {
                return -1 * nullLast;
              }
              if (mNoA > mNoB) {
                return 1 * nullLast;
              }
            }
          });
        }

        // 未対処→対処中→それ以外(対処済/装置記録が存在しない装置)の順で表示する
        return [
          ...hasLatestPendingDateList,
          ...hasLatestWipDateList,
          ...otherEventlist
        ]
      }

      // サインイン者の利用者種別を取得する.
      // 利用者種別が'1' かつ警報通知発生降順のソートがtrueの場合
      // 最大イベント発生日時が含まれるリスト
      const hasMaxEventRegDateList = list.filter(r => {
        return (r.maxEventRegDate);
      });
      const notHasMaxEventRegDateList = list.filter(r => {
        return (!r.maxEventRegDate);
      });
      if (this.sort.key) {
        if (this.getUserType === 1 && this.isAlarmSort) {
          list = [
              ...hasMaxEventRegDateList.sort((a, b) =>
                commonjs.compareKey(a, b, this.isAlarmSortKey, false)
              ),
              ...notHasMaxEventRegDateList.sort((a, b) =>
                commonjs.compareKey(a, b, this.sort.key, this.sort.isAsc)
              )
            ];
        } else {
          list.sort((a, b) =>
            commonjs.compareKey(a, b, this.sort.key, this.sort.isAsc)
          );
        }
      } else {
        if (this.getUserType === 1 && this.isAlarmSort) {
          list = [
            ...hasMaxEventRegDateList.sort((a, b) =>
              commonjs.compareKey(a, b, this.isAlarmSortKey, false)
            ),
            ...notHasMaxEventRegDateList
          ];
        }
      }
      return list;
    },
    async refreshVal() {
      let data = await getMstFacilitySettingValue(this.getFacilityCd, OPERATION_VIEWER_AUTO_SETTING);
      if (data.status == 200) {
        if (data.data) {
          this.refreshInterval = data.data * 1000;
        } else {
          this.refreshInterval = 30000;
        }
      } else if (data.status == 400) {
        getErrorMessage("MachinesMainComponent.vue", "startPolling", error);
        this.refreshInterval = 30000;
      }
      /* 自動更新サインアウトフラグ取得 */
      await initForceSignOutFlag("operation-viewer/facility/setForceSignOutFlag", OPERATION_VIEWER_FORCE_SIGNOUT);
    },
	//add FNSI-add refresh 江 end
  },
  async created() {
    // 画面名称取得
    this.selfScreenPath = this.$router.currentRoute.path;
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh", this.refresh);
    await this.refreshVal();
    await this.refresh();
  },
  // #8640 警報を対処済にしてもバックカラーが赤いまま start
  mounted () {
    this.$nextTick(() => {
      let table = document.getElementById('myTable');
      table.addEventListener('scroll', async(event) => {
      const scrollTop = table.scrollTop;
      const scrollHeight = table.scrollHeight;
      table.scrollTop = scrollTop + (scrollHeight - table.scrollHeight);
      if (table.scrollTop > 0) {
        this.scrollTop = table.scrollTop
      }
      event.target.scrollTop = this.scrollTop
      table.scrollTop = this.scrollTop
      this.$refs.scrollContainer.scrollTop = this.scrollTop
      });
    });
  },
  // #8640 警報を対処済にしてもバックカラーが赤いまま end
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
    clearTimeout(this.timerObj);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.list-header-th-center {
  text-align: center;
}



</style>
<style>
#pop-over-show .popover--top,
#pop-over-show .popover--bottom {
  width: auto !important;
}

#pop-over-show .popover__content{
  min-height: 100% !important;
}

#pop-over-show .popover--bottom__content{
  width: 100%;
}
</style>
