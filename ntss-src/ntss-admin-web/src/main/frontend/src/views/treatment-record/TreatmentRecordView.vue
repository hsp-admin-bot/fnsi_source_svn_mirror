/**
* 治療記録ページ
*/
<template>
  <ntss-layout>
    <template #header-content>
      <header-component />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng start -->
    <!-- <bread-crumbs-component slot='bread-crumbs-content' :history-key="historyKey" :no-split=true @refresh='refresh' /> -->
    <template #bread-crumbs-content>
      <bread-crumbs-component :history-key="historyKey" :no-split="true" />
    </template>
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。linjunfeng end -->
    <template #main-content>
      <main-component ref="mainComponent" :history-key="historyKey" />
    </template>
  </ntss-layout>
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import HeaderComponent from "@/components/header-contents/PatHeader";
import MainComponent from "@/components/treatment-record/TreatmentRecordMainComponent";
import BreadCrumbsComponent from "@/components/BreadCrumbsComponent";
import ViewHelper from "@/views/ViewHelperMixin";
import { HISTORY_KEY_TREATMENT_RECORD_TREATMENT } from "@/router/treatment-record/HistoryKeyConstants";
import {
  getOrdNoListWithShared,
  sendRequestGetOrdMainByOrdNo,
} from "@/apis/ord-main";
import { CODES } from "@/constants/TreatmentRecord.js";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from "@/functions/common/MessageFormat";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
const dialysisState1 = Number(CODES.DIALYSIS_STATE.AFTER_SEND_CONDITION.cd);
const dialysisState5 = Number(CODES.DIALYSIS_STATE.AFTER_WEIGHT_MEASURING.cd);
const dialysisState6 = Number(CODES.DIALYSIS_STATE.CONFIRMED_WEIGHT_MEASURING.cd);
export default {
  name: "TreatmentRecordView",
  components: {
    "header-component": HeaderComponent,
    "main-component": MainComponent,
    "bread-crumbs-component": BreadCrumbsComponent,
  },
  mixins: [ViewHelper],
  data() {
    return {
      historyKey: HISTORY_KEY_TREATMENT_RECORD_TREATMENT,
      offset: 1,
      //FNSI-修正 #6656、6526、検出件数の制御をしないように xugj modify start
      limit: 5000,
      //FNSI-修正 #6656、6526、検出件数の制御をしないように xugj modify end
      ordNoDataSources: [],
      /**
       * 遷移先のルータ名
       */
      toRouterName: null,
      // add FNSI7836-治療記録画面で患者を変更しても更新しない 周 start
      curRoute: null,
      // add FNSI7836-治療記録画面で患者を変更しても更新しない 周 end
      //add FNSI-修正 共有設定 房 start
      sharedRefresh: false,
      //add FNSI-修正 共有設定 房 end
      confirmSelectedPatIdChangeTasks: [],
      selfScreenName: "",
      dataReady: false
    };
  },
  computed: {
    ...mapGetters("pat-info", [
      "selectedPatId",
      "srcFuncName",
      "isNullPat",
      "selectedPat",
      "isPatInfoChaned",
      "isPatInfoVisible",
      "getIsOtherFacility",
      "getOtherFacilityCd",
    ]),
    ...mapGetters("treatment-record/common", [
      "getOrdNo",
      "getOrdNoForSideBarRecord",
      "getDialysisState",
      "getTreatDate",
    ]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("mst-user", { getSharedFlag: "getIsRegisteredShared" }),
    ...mapGetters("treatment-record/result-merge", ["getMergeOrderNo"]),
    ...mapGetters("account-edit", [
      "getPatientShareMode",
      "getPatientShareFacilityCdMode"
    ]),
  },
  /**
   * 画面遷移前処理.
   * 遷移先のルータ名を退避する.
   */
  async beforeRouteLeave(to, from, next) {
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    try {
      if (to.name != "signin" && !!this.isPatInfoChaned) {
        const answer = await new Promise((resolve) => {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[12000014].title,
            message: messageFormat(DIALOG_MESSAGES[12000014].message),
            callback: resolve,
          });
        });
        if (answer === 1) {
          this.setIsPatInfoChaned(false);
          this.toRouterName = to.name;
          next();
        } else {
          next(false);
        }
      } else {
        this.toRouterName = to.name;
        next();
      }
    } catch (error) {
      getErrorMessage("TreatmentRecordView.vue", "beforeRouteLeave", error);
      next();
    }
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
  },
  methods: {
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
    ]),
    ...mapActions("treatment-record/common", [
      "setOrdNo",
      "getLatestOrdNo",
      "setDialysisState",
      "setTreatDate",
      "setOrd",
    ]),
    //add FNSI-修正 共有設定 房 start
    ...mapMutations("treatment-record/common", [
      "setSharedFacilityCd",
      "setOrdNoDataSources",
      "setOrdNoDataReady"
    ]),
    //add FNSI-修正 共有設定 房 end
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
    ...mapActions("treatment-record/result-merge", ["setMergeOrderNo"]),
    // add FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end
    /* modify by chamaojia 2022-10-26 [7217] パラメータを追加し、繰り返し呼び出しを削除する  --start */
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者情報 20231218 ztc end
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
    ...mapActions("observe-record/list", {setObserveRecord: "setOrdNo"}),
    // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
    async getOrdNoListWithSharedData() {
      if (!this.selectedPatId) {
        return;
      }
      this.setOrdNoDataReady(false);
      this.dataReady = false;
      const sharedFlag = (
        this.getIsOtherFacility === false ||
        (this.getOtherFacilityCd !== null && this.getOtherFacilityCd !== this.facilityCd)
      )
        ? 0
        : (this.getPatientShareMode == 0 ? 1 : 0);
      return await getOrdNoListWithShared(
        this.selectedPatId,
        this.offset,
        this.limit,
        sharedFlag
      ).then((response) => {
        let ordNoDataSources = response.data.sort((a, b) => {
          if (a.rstDialysisState === b.rstDialysisState) {
            return b.treatDate - a.treatDate;
          }
          return a.rstDialysisState - b.rstDialysisState;
        });
        this.ordNoDataSources = ordNoDataSources;
        this.setOrdNoDataSources(ordNoDataSources);
        const current = this.ordNoDataSources.find(
          (data) => data.ordNo === this.getOrdNo
        );
        if (current) {
          this.setSharedFacilityCd(current.facilityCd);
        }
        if (this.ordNoDataSources.length === 0) {
          this.$router.push({ name: "treatment-record" });
        }
      }).finally(() => {
        this.setOrdNoDataReady(true);
        this.dataReady = true;
      });
    },
    /**
     * 患者IDをもとにオーダ番号を取得し、再描画する.
     * checkStateFlag: false (繰り返し呼び出しは不要checkRstDialysisState)
     */
    async refresh(checkStateFlag = true) {
      // 画面遷移パラメータ取得
      const queryParameters = this.getQueryParameters();
      let urlDirectFlg = false; // URLダイレクトでこの機能に遷移したか
      let moveChildFlg = false; // 子画面遷移するか
      let childRouterName = null; // 子画面の画面名
      let backHomePage = false; // ホーム画面に戻るか
      if (queryParameters.FUNC && queryParameters.FUNC.slice(0, 3) === "006") {
        urlDirectFlg = true;
        if (queryParameters.routerName !== "treatment-record") {
          moveChildFlg = true;
          childRouterName = queryParameters.routerName;
        }
      }

      // クエリパラメータをクリア
      this.setQueryParameters({});

      if (this.selectedPatId) {
        // 患者治療実績一覧の取得
        this.startLoadingScreen();
        await this.getOrdNoListWithSharedData();
      } else {
        // 患者未選択
        return;
      }

      // オーダ番号未設定
      if (!this.getOrdNo) {
        this.setOrdNo(null);
        if (!this.selectedPatId && !this.isNullPat) {
          return;
        }
        if (this.srcFuncName !== "") {
          this.$router.push({ path: this.curRoute });
          // 取得されたordNoより治療状況（rstDialysisState）を取得。
          if (this.getOrdNoForSideBarRecord) {
            await sendRequestGetOrdMainByOrdNo(this.getOrdNoForSideBarRecord, this.selectedPatId).then(
              (response) => {
                let ordMainData = response.data;
                if (ordMainData) {
                  this.setOrdNo(this.getOrdNoForSideBarRecord);
                } else {
                  this.$router.push({ name: "treatment-record" });
                  backHomePage = true;
                  this.$nextTick(() => {
                    this.setMessage("指定日の実績はありません。");
                  });
                }
              }
            );
          }
        } else {
          // リフレッシュ前の患者治療状況により、表示治療記録を分岐
          let dataSourceFilter;
          if (this.ordNoDataSources.length <= 0) {
            this.alertNotFound(null);
          } else if (this.getDialysisState === dialysisState6) {
            // 治療状況が6：実績の場合、同日過去実績を検索
            dataSourceFilter = this.ordNoDataSources.filter(
              (item) =>
                item.rstDialysisState === String(dialysisState6)
                && item.treatDate === this.getTreatDate
            );
            if (dataSourceFilter.length > 0) {
              this.setOrdNo(dataSourceFilter[0].ordNo);
              // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
              this.setObserveRecord(dataSourceFilter[0].ordNo);
              // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
              this.setOrd(dataSourceFilter[0]);
              this.setSharedFacilityCd(dataSourceFilter[0].facilityCd);
            } else {
              this.$router.push({ name: "treatment-record" });
              backHomePage = true;
              this.$nextTick(() => {
                this.setMessage("指定日の実績はありません。");
              });
            }
          } else if (
            this.getDialysisState <= dialysisState5
            && this.getDialysisState >= dialysisState1
          ) {
            // 治療状況が1~5の場合、治療中実績を検索
            dataSourceFilter = this.ordNoDataSources.filter(
              (item) =>
                item.rstDialysisState <= String(dialysisState5)
                && item.rstDialysisState >= String(dialysisState1)
            );
            // 治療中実績が存在する場合最新の実績オーダー番号をセット
            if (dataSourceFilter.length > 0) {
              this.setOrdNo(dataSourceFilter[0].ordNo);
              // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
              this.setObserveRecord(dataSourceFilter[0].ordNo);
              // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
              this.setOrd(dataSourceFilter[0]);
              this.setSharedFacilityCd(dataSourceFilter[0].facilityCd);
            } else {
              this.$router.push({ name: "treatment-record" });
              backHomePage = true;
              this.$nextTick(() => {
                this.setMessage("治療前、治療中、未確定データはありません。");
              });
            }
          } else if (this.getTreatDate && urlDirectFlg) {
            dataSourceFilter = this.ordNoDataSources.filter(
              (item) =>
                item.treatDate === this.getTreatDate
            );
            // URLダイレクト機能によって日付指定のみされて遷移
            if (dataSourceFilter.length > 0) {
              this.setOrdNo(dataSourceFilter[0].ordNo);
              this.setOrd(dataSourceFilter[0]);
              this.setSharedFacilityCd(dataSourceFilter[0].facilityCd);
            } else {
              this.setOrdNo(this.ordNoDataSources[0].ordNo);
              this.setOrd(this.ordNoDataSources[0]);
              this.setSharedFacilityCd(this.ordNoDataSources[0].facilityCd);
            }
          } else {
            this.setOrdNo(this.ordNoDataSources[0].ordNo);
            // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
            this.setObserveRecord(this.ordNoDataSources[0].ordNo);
            // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
            this.setOrd(this.ordNoDataSources[0]);
            this.setSharedFacilityCd(this.ordNoDataSources[0].facilityCd);
          }
          !backHomePage && this.$router.push({ path: this.curRoute });
        }
      }
      this.finishLoadingScreen();
      if (checkStateFlag && this.$refs["mainComponent"] != undefined) {
        this.$refs["mainComponent"].checkRstDialysisState();
      }
    },
    /**
     * オーダ番号をチェックし、設定されていない場合、メッセージを表示する.
     * @param {*} ordNo オーダ番号
     */
    alertNotFound(ordNo) {
      if (!ordNo) {
        this.setMessage("データがありません。");
      }
    },
    /**
     * クリア処理を行う.
     */
    clear() {
      this.setOrdNo(null);
      this.setDialysisState(null);
      this.setTreatDate(null);
      // 遷移先のルータ名をクリア.
      this.toRouterName = null;
    },
    // 子画面の破棄確認などを待ち、いずれかの処理結果がfalseとなった場合はfalseを返す
    async confirmSelectedPatIdChange() {
      // 治療記録画面の患者切替を通知し、"addConfirmTreatmentRecordSelectedPatIdChangeTasks"を受け付ける
      EventBus.$emit("beforeTreatmentRecordSelectedPatIdChange");
      const tasks = this.confirmSelectedPatIdChangeTasks;
      this.confirmSelectedPatIdChangeTasks = [];
      const results = [];
      while (tasks.length > 0) {
        results.push(await tasks.shift());
      }
      return results.every((result) => result);
    },
    addConfirmSelectedPatIdChangeTasks(task) {
      this.confirmSelectedPatIdChangeTasks.push(task);
    },
    setMessage(message) {
      if (this.$refs["mainComponent"] != undefined) {
        this.$refs["mainComponent"].setMessage(message);
      }
    },
  },
  watch: {
    // add start 馬 #9559
    $route: {
      handler(to) {
        this.curRoute = to.path;
      }
    },
    // add end 馬 #9559
    // modify start 馬 #9559
    // mod #10196 watchされたselectedPatに変化がなければ処理しない shiyw start
    selectedPat: {
      async handler(newVal, oldVal) {
        // if (
        //   oldVal?.pat_personal_main?.pat_id == newVal?.pat_personal_main?.pat_id
        // ) {
        //   // 1、に切り替えることを検討しています。患者時newVal=null；  2、 選択されていない患者から選択された患者に切り替えた場合oldVal=null
        //   return;
        // }
        // mod #10196 watchされたselectedPatに変化がなければ処理しない shiyw end
        // mod #9231 同じ患者をクリックしても、イベントを発火するように変更 watch対象をselectedPatIdからselectedPatへ変更 朴 end
        // #11893 同一患者の再読込は患者切替として扱わない。
        // treatment-observe-detail 新規登録時に破棄確認や一覧戻りが発生するため。
        const oldPatId = oldVal?.pat_personal_main?.pat_id;
        const newPatId = newVal?.pat_personal_main?.pat_id;
        const isSamePat = oldPatId && newPatId && oldPatId === newPatId;
        const shouldConfirmPatChange =
          !(this.$route.name === 'treatment-observe-detail' && isSamePat);
        if (shouldConfirmPatChange && !(await this.confirmSelectedPatIdChange())) {
          // 患者切替処理をキャンセルする
          // 患者を戻す処理は"addConfirmTreatmentRecordSelectedPatIdChangeTasks"した画面に任せる。
          // 患者を戻す際にも再度この処理が走るので、
          // "addConfirmTreatmentRecordSelectedPatIdChangeTasks"した画面は
          // その際にも"beforeTreatmentRecordSelectedPatIdChange"を適切に処理する必要がある。
          // （#8016対応時点では観察記録詳細のみがこの仕組みを使っている）
          // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
          if(this.$route.name === 'treatment-observe-detail'){
            this.setOrdNo(this.ordNoDataSources[0].ordNo);
          }
          // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end
          return;
        }
        // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 start
        if(this.$route.name === 'treatment-observe-detail' && !isSamePat){
          this.$router.push({ name: "treatment-record-observation" , params: { ignoreWatchGetOrdNo: '1' }});
        }
        // add #10774 治療記録＞観察記録 患者・実績を切替た場合 ztc 20240726 end

        // add FNSI7836-治療記録画面で患者を変更しても更新しない 周 start
        // this.curRoute = this.$route.path;
        // mod FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 start
        if (this.getMergeOrderNo) {
          this.setOrdNo(this.getMergeOrderNo);
          this.setMergeOrderNo(null);
        } else {
          // this.setOrdNo(null);
        }
        // mod FNSI-修正 redmine-8041「？？？？患者の実績マージ後、治療記録の患者名が？？？？患者のまま」 房 end

        // add FNSI7836-治療記録画面で患者を変更しても更新しない 周 end
        /* modify by chamaojia 2022-10-26 [7217] 繰り返し呼び出しを削除する  --start */
        // #11893 同一患者の詳細画面では refresh(false) による旧 curRoute への戻りを避ける。
        if (this.$route.name === 'treatment-observe-detail' && isSamePat) {
          return;
        }
        if (isSamePat) {
          return;
        }
        this.refresh(false);
        /* modify by chamaojia 2022-10-26 [7217] 繰り返し呼び出しを削除する  --end */
      },
    },
    // add start 馬 #10335
    getOrdNo(val) {
      if (this.srcFuncName) {
        this.curRoute = this.$route.path;
      }
      if (val) {
        this.$router.push({ path: this.curRoute });
      }
    },
    // modify end 馬 #9559
    // add end 馬 #10335
    // add FNSI-修正 共有設定 房 start
    getSharedFlag() {
      // URLダイレクト遷移時に、強制リフレッシュが行われないよう対策
      const queryParameters = this.getQueryParameters();
      if (queryParameters.FUNC && queryParameters.FUNC.slice(0, 3) === "006") {
        // クエリパラメータをクリアする
        this.setQueryParameters({});
        return;
      }

      this.sharedRefresh = true;
      this.refresh();
    },
    // add FNSI-修正 共有設定 房 end
    // add FNSI-7967 治療状況リスト，マップから治療記録を開いた後に患者を切り替えて表示できない時がある 房 start
    getOrdNoForSideBarRecord() {
      //mod 9559 teamsからの指摘 ljx start
      //this.setOrdNo(this.getOrdNoForSideBarRecord);
      //mod 9559 teamsからの指摘 ljx end
    },
    // add FNSI-7967 治療状況リスト，マップから治療記録を開いた後に患者を切り替えて表示できない時がある 房 end
    getPatientShareMode() {
      this.refresh();
    },
    getPatientShareFacilityCdMode() {
      this.refresh();
    },
  },
  /**
   * mounted
   */
  mounted() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$off(
      "addConfirmTreatmentRecordSelectedPatIdChangeTasks",
      this.addConfirmSelectedPatIdChangeTasks
    );
    EventBus.$on("refresh", this.refresh);

    EventBus.$on(
      "addConfirmTreatmentRecordSelectedPatIdChangeTasks",
      this.addConfirmSelectedPatIdChangeTasks
    );
    if (this.getOrdNo) {
      return;
    }
    if (!this.selectedPatId) {
      return;
    }
    /* modify by chamaojia 2022-10-26 [7217] 繰り返し呼び出しを削除する  --start */
    this.refresh(false);
    /* modify by chamaojia 2022-10-26 [7217] 繰り返し呼び出しを削除する  --end */
  },
  beforeUnmount() {
    if (
      !(
        this.$route.fullPath == "/observe-record/list/detail" &&
        Object.keys(this.$route.params).length === 0
      )
    ) {
      // 本画面から、治療記録の観察記録の新規作成/編集画面に遷移するときは、ordNo維持の為、リフレッシュ処理を行わない
      this.clear();
    }
    EventBus.$off("refresh", this.refresh);
    EventBus.$off(
      "addConfirmTreatmentRecordSelectedPatIdChangeTasks",
      this.addConfirmSelectedPatIdChangeTasks
    );
  },
};
</script>
