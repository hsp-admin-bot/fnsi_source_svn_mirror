/**
 * 治療記録の子機能 体重ページ
 */
<template>
  <submenu-base v-if="hasOrdNo">
    <div slot="main" id="weight-component">
      <v-ons-list class="treatment-record-accordion">
        <v-ons-list-item expandable :expanded.sync="isExpandedWeight" id="weight-sub">
          <label>体重</label>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
<!--          <weight-sub v-model="actualModel.weight" :authorityCds="authorityCds" ref='weight' />-->
          <weight-sub v-model="actualModel.weight"  ref='weight' />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
        </v-ons-list-item>
        <v-ons-list-item expandable :expanded.sync="isExpandedMonitor" ref="monitorSub" id="monitor-sub">
          <label>モニタ</label>
          <monitor-sub v-model="actualModel.monitor" :ord-no="getOrdNo" ref='monitor' />
        </v-ons-list-item>
      </v-ons-list>
    </div>
    <div slot="footer" class="flex-container treatment-submenu">
      <div class="denial-btn-area">
        <!-- add FNSI-「キャンセル」権限の修正 徐 start -->
        <!-- <v-ons-button class="button denial-btn" @click="onClickCancel">キャンセル</v-ons-button> -->
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
        <v-ons-button class="button denial-btn btn2-cancel" data-non-authorize="true" @click="onClickCancel">キャンセル</v-ons-button>
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
        <!-- add FNSI-「キャンセル」権限の修正 徐 end -->
      </div>
      <div class="registration-btn-area">
        <!-- mod FNSI-共有を追加 王 20200921 start -->
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
        <v-ons-button class="button registration-btn btn1-execute" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!canSave || isReadOnly || !isShared" @click="onClickSave">保存</v-ons-button>
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
        <!-- mod FNSI修正 画面スタイル(ボタン)対応 房 end -->
        <!-- mod FNSI-共有を追加 王 20200921 end -->
      </div>
    </div>
  </submenu-base>
</template>

<script>
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
import {mapActions, mapGetters, mapMutations} from "vuex";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
import SubmenuBase from "@/components/treatment-record/SubmenuBaseComponent";
import WeightSubComponent from "@/components/treatment-record/submenu/weight/WeightSubComponent";
import MonitorSubComponent from "@/components/treatment-record/submenu/weight/MonitorSubComponent";
import DiscardConfirmationMixin from "@/components/treatment-record/DiscardConfirmationMixin";
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import { Weight } from "@/models/treatment-record/weight/Weight";
import { Monitor } from "@/models/treatment-record/weight/Monitor";
import { WeightModal } from "@/models/treatment-record/weight/WeightModal";
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { EventBus } from "@/eventBus.js";
// add FNSI-日付書式の修正 徐 start
import { dateFormat, DATE_TIME_FORMAT, DATE_FORMAT } from "@/functions/common/DateTimeUtils";
// add FNSI-日付書式の修正 徐 end
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import { getAuthorized, isJsonChanged } from "@/functions/common/CommonFunctions";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
export default {
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
  // mixins: [DiscardConfirmationMixin, ComponentGuardMixin],
  mixins: [DiscardConfirmationMixin],
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  components: {
    "submenu-base": SubmenuBase,
    "weight-sub": WeightSubComponent,
    "monitor-sub": MonitorSubComponent
  },
  props: [
    'openSecondBarfromBvms'
  ],
  data() {
    return {
      originalWeight: null,
      comparisonModel: null,
      actualModel: {
        weight: new Weight(),
        monitor: new Monitor()
      },
      isExpandedWeight: false,
      isExpandedMonitor: false,
//#10359 del 編集権限の動作不正 2024-06-05 卓 start
      // authorityCds: [AUTHORITY_CODES.RST_PEDIT, AUTHORITY_CODES.RST_EDIT],
//#10359 del 編集権限の動作不正 2024-06-05 卓 end
      selfScreenName: "",
      recrclRt: null,
      recrclRtList: [],
      //add メッセージ順番修正 房 start
      alertFlag: true,
      urrOld: null,
      ktVMeasureOld: null,
      sttcVnsPrssrOld: null,
      iapRtOld: null
      //add メッセージ順番修正 房 end
    };
  },
  computed: {
    ...mapGetters("treatment-record/common", [
      "getOrd"
    ]),
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    },
    // add FNSI-共有を追加 王 20200921 end
    /**
     * データの編集があるかどうか.
     */
    isChanged() {
      // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
      for(let key in this.actualModel.weight) {
        if ((this.actualModel.weight[key] == undefined)&& this.comparisonModel) {
          if (!this.comparisonModel.weight[key]) {
            this.comparisonModel.weight[key] = null
          }
          this.actualModel.weight[key] = null
        } else if (this.comparisonModel && this.comparisonModel.weight && this.comparisonModel.weight[key]) {
          this.comparisonModel.weight.weightDecreased = this.actualModel.weight.weightDecreased
        }
      }
      if (this.comparisonModel && this.comparisonModel.monitor) {
        this.actualModel.monitor.recrclRtList.forEach((item, index) => {
          if (item.rate == null || item.rate === '') {
            this.actualModel.monitor.recrclRtList[index].rate = null
          }
          if (item.time == null || item.time === '') {
            this.actualModel.monitor.recrclRtList[index].time = ''
          }
          if (item.bldVl && typeof(item.bldVl) === 'string') {
            this.actualModel.monitor.recrclRtList[index].bldVl = Number(item.bldVl)
          }
          this.comparisonModel.monitor.recrclRtList[index].bldVl = this.comparisonModel.monitor.recrclRtList[index].bldVl? Number(this.comparisonModel.monitor.recrclRtList[index].bldVl) : this.comparisonModel.monitor.recrclRtList[index].bldVl
          this.comparisonModel.monitor.recrclRtList[index].date = item.date
          if (item.rate && typeof(item.rate) === 'string') {
            this.actualModel.monitor.recrclRtList[index].rate = Number(item.rate)
          }
          this.comparisonModel.monitor.recrclRtList[index].rate = this.comparisonModel.monitor.recrclRtList[index].rate? Number(this.comparisonModel.monitor.recrclRtList[index].rate) : this.comparisonModel.monitor.recrclRtList[index].rate
        })
      }
      return this.actualModel && this.comparisonModel
        ? isJsonChanged(JSON.stringify(this.actualModel), JSON.stringify(this.comparisonModel))
        : false;
      // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
    },
    /**
     * 保存ボタンがクリックできるかどうか.
     * （編集あり、かつ、エラーなしの場合のみクリック可能）
     */
    canSave() {
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
      this.setIsPatInfoChaned(this.isChanged && this.$validator.errors.items.length === 0)
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
      return this.isChanged && this.$validator.errors.items.length === 0;
    },
    /**
     * 後体重測定済みにすることができるかどうか
     * rst_dialysis_state が 4 後体重測定前 で、後体重測定日時が設定されていればtrueを返す
     */
    isCanChangeStateWeightAfter() {
      return this.getDialysisState === 4 && this.actualModel.weight.weightAfterDate
    },

    isReadOnly() {
      return this.getOrd.readOnly;
    }
  },
  methods: {
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_治療記録 20231207 ztc end
    // del #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    // compareObjects(obj1, obj2) {
    //   const keys1 = Object.keys(obj1);
    //   const keys2 = Object.keys(obj2);

    //   if (keys1.length !== keys2.length) {
    //     return false;
    //   }
    //   for (let i = 0; i < keys1.length; i++) {
    //     const key = keys1[i];
    //     if (obj1[key] !== obj2[key]) {
    //       return false;
    //     }
    //   }
    //   return true;
    // },
    // del #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    compareObjects(obj1, obj2) {

      // 基本型(文字列、数字など)の場合は、そのまま等価比較をします。
      if (!this.isObject(obj1)) {
        // add #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng start
        if ((obj1 === 0 && obj2 === "") ||  (obj1 === "" && obj2 === 0)) {
          return false;
        }
        // add #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng end
        return obj1 == obj2;
      }
      // オブジェクトの属性名を全て取得します
      const keys = Object.keys(obj1);
      for (let key of keys) {
        // 属性を横断して深さを比較します
        if (obj2[key] === undefined) {
          return false;
        }
        if (!this.compareObjects(obj1[key], obj2[key])) {
          return false;
        }
      }
      return true;
    },

    isObject(value) {
      return value && typeof value === 'object';
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    ...mapActions("treatment-record/weight", [
      "getTreatmentRecordWeight",
      "updateTreatmentRecordWeight",
      "updateTreatmentRecordStateAfterWeight"
    ]),
    //#10359 add 編集権限の動作不正 2024-06-05 卓 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    //#10359 add 編集権限の動作不正 2024-06-05 卓 end
    /**
     * 初期化処理（体重情報取得）.
     */
    init() {
      if (!this.getOrdNo) {
        return;
      }
      this.getTreatmentRecordWeight(this.getOrdNo).then(response => {
        const w = response.data;
        const rstOffWaterInfo = JSON.parse(w.rst_off_water_info);
        const rstTareInfo = JSON.parse(w.rst_tare_info);
        const rstTareInfoBefore = rstTareInfo != null ? rstTareInfo.before : {};
        const rstTareInfoAfter = rstTareInfo != null ? rstTareInfo.after : {};

        //mod 内結バッグ62修正 房 start
        let rstWeightInfo = JSON.parse(w.rst_weight_info);
        let recrcls = {};
        if (rstWeightInfo != null && rstWeightInfo.recrcl_rt != null && rstWeightInfo.recrcl_rt != undefined) {
          recrcls = rstWeightInfo.recrcl_rt;
        } else if (rstWeightInfo == null) {
          rstWeightInfo = {};
        }
        let maxKey = 0;
        for (let index = 5; index > 0; index--) {
          let hasKey = "" + index;
          if (recrcls.hasOwnProperty(hasKey)) {
            maxKey = index;
            break;
          }
        }
        if (maxKey === 0) {
          recrcls["valid_no"] = 0;
        }
        if (maxKey < 5) {
          for (let index = (maxKey + 1); index < 6; index++) {
            let key = "" + index;
            recrcls[key] = {
              // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
              // "rate": "",
              "rate": null,
              // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
              "bld_vl": null,
              "comment": "",
              "datetime": ""
            };
          }
        } else {
          for (let index = 1; index < 6; index++) {
            if (recrcls[index] == null) {
              recrcls[index] = {
                // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
                // "rate": "",
                "rate": null,
                // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
                "bld_vl": null,
                "comment": "",
                "datetime": ""
              };
            }
          }
        }
        rstWeightInfo.recrcl_rt = recrcls;
        //mod 内結バッグ62修正 房 end
        if (rstWeightInfo) {
          // add FNSI-日付書式の修正 徐 start
          // rstWeightInfo.weight_before_date = rstWeightInfo.weight_before_date
          //   ? new Date(rstWeightInfo.weight_before_date)
          //   : null;
          // const ctrMeasureDateOptional = rstWeightInfo.ctr_measure_date;
          //   rstWeightInfo.ctr_measure_date = ctrMeasureDateOptional
          //     ? new Date(ctrMeasureDateOptional)
          //     : null;
          // rstWeightInfo.weight_after_date = rstWeightInfo.weight_after_date
          //   ? new Date(rstWeightInfo.weight_after_date)
          //   : null;
          rstWeightInfo.weight_before_date = rstWeightInfo.weight_before_date
            ? new Date(dateFormat.utc2Jst(dateFormat.format(new Date(rstWeightInfo.weight_before_date), DATE_TIME_FORMAT)))
            : null;
          const ctrMeasureDateOptional = rstWeightInfo.ctr_measure_date;
            rstWeightInfo.ctr_measure_date = ctrMeasureDateOptional
              ? new Date(dateFormat.utc2Jst(dateFormat.format(new Date(ctrMeasureDateOptional), DATE_FORMAT)))
              : null;
          rstWeightInfo.weight_after_date = rstWeightInfo.weight_after_date
            ? new Date(dateFormat.utc2Jst(dateFormat.format(new Date(rstWeightInfo.weight_after_date), DATE_TIME_FORMAT)))
            : null;
          // add FNSI-日付書式の修正 徐 end
        }

        this.actualModel.weight = new Weight(
          w.last_weight,
          w.rst_dw,
          w.target_weight,
          rstWeightInfo,
          new WeightModal(
            rstWeightInfo ? rstWeightInfo.weight_before : null,
            null,
            rstWeightInfo ? rstWeightInfo.weight_measure_before : null,
            w ? w.target_weight : null,
            rstWeightInfo ? rstWeightInfo.water_removal_target : null,
            w ? w.water_removal_amount_limit : null,
            rstTareInfoBefore,
            rstOffWaterInfo
          ),
          new WeightModal(
            rstWeightInfo ? rstWeightInfo.weight_before : null,
            rstWeightInfo ? rstWeightInfo.weight_after : null,
            rstWeightInfo ? rstWeightInfo.weight_measure_after : null,
            w ? w.target_weight : null,
            rstWeightInfo ? rstWeightInfo.water_removal_rst : null,
            w ? w.water_removal_amount_limit : null,
            rstTareInfoAfter,
            rstOffWaterInfo
          )
        );
        // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
        this.actualModel.monitor = new Monitor({

          // add FNSI-測定前の値は空欄とする 徐 start
          // kt_v_measure: rstWeightInfo ? rstWeightInfo.kt_v_measure : null,
          // urr: rstWeightInfo ? rstWeightInfo.urr : null,
          kt_v_measure: this.safeField(rstWeightInfo, 'kt_v_measure'),
          urr: this.safeField(rstWeightInfo, 'urr'),
          // add FNSI-測定前の値は空欄とする 徐 end
          re_loop_rate_main: this.safeField(rstWeightInfo, 're_loop_rate_main'),
          // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
          sttc_vns_prssr: this.safeField(rstWeightInfo, 'sttc_vns_prssr'),
          iap_rt: this.safeField(rstWeightInfo, 'iap_rt'),
          recrcl_rt: rstWeightInfo ? rstWeightInfo.recrcl_rt : null
          // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
        });
        // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
        this.originalWeight = w;
        this.comparisonModel = JSON.parse(JSON.stringify(this.actualModel));
        if (this.actualModel && this.actualModel.monitor) {
          this.ktVMeasureOld = this.actualModel.monitor.ktVMeasure
          this.urrOld = this.actualModel.monitor.urr
          this.sttcVnsPrssrOld = this.actualModel.monitor.sttcVnsPrssr
          this.iapRtOld = this.actualModel.monitor.iapRt
        }
        // アコーディオンを開く
        this.isExpandedWeight = true;
        this.isExpandedMonitor = true;
      });
    },
    /**
     * 再初期化処理.
     */
    refresh() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      //mod メッセージ順番修正 房 start
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 start
      // if (this.isChanged && this.alertFlag) {
      //   this.discardConfirm(this.init);
      // } else {
      //   this.init();
      // }
      this.init();
      //mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。 張玲 end
      this.alertFlag = true;
      //mod メッセージ順番修正 房 end
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    eventBusRefresh() {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      if (this.isChanged && this.alertFlag) {
        this.discardConfirm(this.init);
      } else {
        this.init();
      }
      this.alertFlag = true;
    },
    // add #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    /**
     * 更新API用RequestBody生成.
     */
    createUpdateRequestBody() {
      const weightInfo = this.originalWeight.rst_weight_info ? JSON.parse(this.originalWeight.rst_weight_info) : {};
      Object.assign(weightInfo, this.actualModel.weight.toJson());
      Object.assign(weightInfo, this.actualModel.monitor.toJson());

      const tareInfo = {
        before: this.actualModel.weight.modalBefore.toJsonTareInfo(),
        after: this.actualModel.weight.modalAfter.toJsonTareInfo()
      };
      const offWaterInfo = this.actualModel.weight.modalBefore.toJsonOffWaterInfo();
      //mod 内結バッグ62修正 房 start
      let recrclRts = weightInfo.recrcl_rt;
      for (let index = 5; index > 0; index--) {
        let recrclRt = recrclRts[index];
        if (recrclRt.rate == 0 && recrclRt.bld_vl == 0 && recrclRt.datetime == "Invalid date") {
          delete weightInfo.recrcl_rt[index];
        }
      }
      //mod 内結バッグ62修正 房 end

      // 並び順を測定日時昇順、データなし後方にソート後、ソート順でキーを1から5に振り直す
      weightInfo.recrcl_rt = this.sortByDateTime(weightInfo);

      return {
        rst_weight_info: JSON.stringify(weightInfo),
        rst_tare_info: JSON.stringify(tareInfo),
        rst_off_water_info: JSON.stringify(offWaterInfo),
        // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
        rst_dw: this.actualModel.weight.rstDw? parseFloat(this.actualModel.weight.rstDw) : null
        // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
      };
    },
    //mod 内結バッグ62修正 房 start
    doValidate() {
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng start
      const weightBeforeDate = this.$refs.weight.weightBeforeDate;
      const weightBeforeTime = this.$refs.weight.weightBeforeTime;
      const weightAfterDate = this.$refs.weight.weightAfterDate;
      const weightAfterTime = this.$refs.weight.weightAfterTime;
      if ((weightBeforeDate && !weightBeforeTime) ||
          (!weightBeforeDate && weightBeforeTime) ||
          (weightAfterDate && !weightAfterTime) ||
          (!weightAfterDate && weightAfterTime)
          ) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000340].title,
          message: messageFormat(DIALOG_MESSAGES[12000340].message)
        });
        return true;
      }
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng end
      let recrclRts = this.actualModel.monitor.recrclRtList;
      let errorItem = [];
      for (let index = 4; index >= 0; index--) {
        let recrclRt = recrclRts[index];

        const rate = recrclRt.rate !== "" && recrclRt.rate !== null ? recrclRt.rate : null;
        // 再循環率以外に値がある場合、再循環率必須
        if (rate === null && (recrclRt.bldVl !== null || recrclRt.time || recrclRt.comment)) {
          if (!errorItem.includes("再循環率")) {
            errorItem.splice(0, 0, "再循環率");
          }
        }
        // 再循環率に値がある場合、測定日時必須
        if (rate !== null && !recrclRt.time) {
          if (!errorItem.includes("測定日時")) {
            errorItem.push("測定日時");
          }
        }
      }

      if (errorItem.length > 0) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000272].title,
          message: messageFormat(DIALOG_MESSAGES[12000272].message, errorItem.join("、"))
        });
        return true;
      }

      return false;
    },
    //mod 内結バッグ62修正 房 end
    /**
     * "保存"ボタンクリックハンドラ.
     */
    async onClickSave() {
      //mod 内結バッグ62修正 房 start
      if (this.doValidate()) {
        return;
      }
      //mod 内結バッグ62修正 房 end
      if(this.isReadOnly) {
        return;
      }
      const payload = {
        ordNo: this.getOrdNo,
        treatmentRecordWeight: this.createUpdateRequestBody()
      };

      let isChangeStateWeightAfter = this.isCanChangeStateWeightAfter;
      if (isChangeStateWeightAfter) {
        await this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "確認",
          title: DIALOG_MESSAGES[13000150].title,
          // message: "後体重測定済として良いですか？",
          message: messageFormat(DIALOG_MESSAGES[13000150].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 0) {
              // 後体重測定済みとしない
              isChangeStateWeightAfter = false;
            }
          }
        });
      }

      this.updateTreatmentRecordWeight(payload)
        .then(async () => {
          if (isChangeStateWeightAfter) {
            // 治療状況を後体重測定済みにする
            try {
              await this.updateTreatmentRecordStateAfterWeight(payload);
            } catch (error) {
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
              getErrorMessage('WeightComponent.vue','onClickSave','後体重測定済み状態への更新に失敗しました。');
              //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
              await this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "状態更新失敗",
                // message: "後体重測定済み状態への更新に失敗しました。"
                title: DIALOG_MESSAGES[12000273].title,
                message: messageFormat(DIALOG_MESSAGES[12000273].message)
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              });
            }
          }
          // 初期化処理を実行
          this.init();
          // 子機能ボタンエリアの更新
          this.$emit("update");
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('WeightComponent.vue','onClickSave','必須項目が入力されていません。');
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              // message: "必須項目が入力されていません。"
              title: DIALOG_MESSAGES['00200070'].title,
              message: messageFormat(DIALOG_MESSAGES['00200070'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
/*      if (this.$refs['weight'] != undefined) {
        this.$refs['weight'].initValueEdit();
      }*/
      // del #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start
      // let elements = document.getElementsByClassName("custom-input-edited");
      // for (let i = elements.length-1; i >= 0; i--) {
      //   elements[i].classList.remove("custom-input-edited");
      // }
      // del #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end
      if (this.$refs['monitor'] != undefined) {
        this.$refs['monitor'].initValueEdit();
      }
      if (this.$refs['weight'] != undefined) {
        this.$refs['weight'].initValueEdit();
      }
    },
    /**
     * "キャンセル"ボタンクリックハンドラ.
     */
    onClickCancel() {
      // 編集済みであれば確認ダイアログを表示して初期化処理を実行
      if (this.isChanged) {
        this.discardConfirm(this.backTreatmentRecord);
      } else {
        this.backTreatmentRecord();
      }
    },
    /**
     * 治療記録のトップ画面に遷移.
     */
    backTreatmentRecord() {
      // 画面遷移前に変更内容を同期する.
      // 理由は画面遷移時に変更破棄ダイアログが2回表示されてしまう為.
      this.comparisonModel = JSON.parse(JSON.stringify(this.actualModel));
      this.refresh();
      // this.$nextTick(() => {
      //   this.$router.push({ name: "treatment-record" });
      // });
    },
    //add メッセージ順番修正 房 start
    getChangeStatus(){
      return this.isChanged;
    },
    updateChangeStatus(){
      this.alertFlag = false;
    },
    //add メッセージ順番修正 房 end
    /**
     * 並び順を測定日時昇順、データなし後方にソート後、ソート順でキーを1から5に振り直す
     * valid_noの値についてもソート後のキーの値で更新する
     */
    sortByDateTime(weightInfo) {
      const recrclRtEntries = Object.entries(weightInfo.recrcl_rt);

      // データなし（再循環率未設定）、もしくは、キーが"valid_no"のオブジェクトを除外
      const filteredEntries = recrclRtEntries.filter(([key, value]) => {
        return !(value.rate === null || value.rate === "" || key === "valid_no");
      });

      // filter後、"datetime"昇順でソート
      filteredEntries.sort((a, b) => {
        return new Date(a[1].datetime).getTime() - new Date(b[1].datetime).getTime();
      });

      // ソート後のentriesにデータなしの要素追加
      const nullEntries = recrclRtEntries.filter(([key, value]) => (value.rate === null || value.rate === "") && key !== "valid_no");
      nullEntries.forEach(([key, value]) => {
        filteredEntries.push([key, value]);
      });

      // valid_noの元の値を保存
      const originalValidNo = weightInfo.recrcl_rt.valid_no.toString();
      // ソート順でキーを1から振り直し、valid_noの新しい値を取得
      const sortedRecrclRt = {};
      let newValidNo = null;
      filteredEntries.forEach(([key, value], index) => {
        const newKey = (index + 1).toString();
        sortedRecrclRt[newKey] = value;
        if (key === originalValidNo && value.rate !== null && value.rate !== "") {
          newValidNo = newKey;
        }
      });

      // ソート後のentriesに"valid_no"の要素追加
      // データなし行チェックONで保存した場合はvalid_noは0にする
      if (originalValidNo === "0" || newValidNo === null) {
        sortedRecrclRt["valid_no"] = 0;
      } else {
        sortedRecrclRt["valid_no"] = parseInt(newValidNo);
      }

      return sortedRecrclRt;
    },
    // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 start
    safeField(obj, key) {
      const val = obj && obj[key];
      return val != null && val !== -1 ? val : null;
    }
    // mod #12313 【因島】過去の治療記録-体重で無編集にも関わらず別画面に遷移すると「内容破棄」のメッセージが表示される 関 end
  },
  created() {
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    // イベント登録
    EventBus.$on("refresh", this.eventBusRefresh);
    // OrdMainレコードをチェックする
    if (!this.checkOrdNo()) {
      return;
    }
    this.init();
  },
  /**
   * コンポーネント破棄
   */
  beforeDestroy() {
    // イベント解除
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue start
    // EventBus.$off("refresh", this.refresh);
    EventBus.$off("refresh", this.eventBusRefresh);
    // mod #10774 治療記録＞体重にて未編集なのに破棄確認メッセージが出てしまう。zhangyue end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  mounted() {
    // BVMS画面からこのコンポーネントを開くと自動的に展開されます
    if (this.openSecondBarfromBvms === true) {
      this.$refs.monitorSub.$el.showExpansion();
      this.isExpandedMonitor = true;
    }
  }
};
</script>
<style scoped>
  #weight-sub {
    overflow: hidden;
    border: 1px solid #dddddd;
  }
  #monitor-sub {
    overflow: hidden;
    border: 1px solid #dddddd;
  }
</style>
