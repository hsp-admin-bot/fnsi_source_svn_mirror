/** * スケジュール編集 */
<template>
  <div>
    <v-ons-row style="padding: 5px 0;">
      <v-ons-col class="indInfo-style-label-position">
        <label>クール</label>
      </v-ons-col>
      <v-ons-col>
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-select -->
        <!--   ref="kur" -->
        <!--   :value="structData.selectedKur" -->
        <!--   class="input-style common-style-input" -->
        <!--   :options="structData.kurOptions" -->
        <!--   @change="createBedList" -->
        <!-- /> -->
        <custom-select
          ref="kur"
          :value="structData.selectedKur"
          class="input-style common-style-input"
          :options="structData.kurOptions"
          @change="createBedList"
          :disabled="!getItemAuthorized('Indication', 'item_schedule')"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row style="padding: 5px 0;">
      <v-ons-col class="indInfo-style-label-position">
        <label>治療開始時刻</label>
      </v-ons-col>
      <v-ons-col>
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-input-time -->
        <!--   ref="time" -->
        <!--   :value="structData.indTreatStartTime" -->
        <!--   :disabled="treatStartTimeFlag" -->
        <!--   style="color: #333333;" -->
        <!-- /> -->
        <custom-input-time
          ref="time"
          :value="structData.indTreatStartTime"
          :disabled="treatStartTimeFlag || !getItemAuthorized('Indication', 'item_schedule')"
          style="color: #333333;"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </v-ons-col>
    </v-ons-row>
    <v-ons-row style="padding: 5px 0;">
      <v-ons-col class="indInfo-style-label-position">
        <label>ベッド</label>
      </v-ons-col>
      <v-ons-col>
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-select -->
        <!--   ref="bed" -->
        <!--   :value="structData.selectedBed" -->
        <!--   class="input-style common-style-input" -->
        <!--   :options="structData.bedOptions" -->
        <!-- /> -->
        <custom-select
          ref="bed"
          :value="structData.selectedBed"
          class="input-style common-style-input"
          :options="structData.bedOptions"
          :disabled="!getItemAuthorized('Indication', 'item_schedule')"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </v-ons-col>
    </v-ons-row>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import moment from "moment";
import CustomSelect from "@/components/common/custom-form-tags/CustomSelect";
import CustomInputTime from "@/components/common/custom-form-tags/CustomInputTime";
import { EventBus } from "@/eventBus.js";
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
// add #6107 2023/03/27 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/27 メッセージボックス全調整 林峻峰 end
export default {
  components: {
    "custom-select": CustomSelect,
    "custom-input-time": CustomInputTime
  },
mixins: [NextTransitionMixin, MasterMaintenanceMixin, PatHeaderControlMixin],
  props: {
    /**
     * 施設コード
     */
    propsFacilityCd: {
      type: String,
      default: null
    },
    /**
     * 透析開始時刻
     */
    propsIndTreatStartTime: {
      type: String,
      default: null
    },
    /**
     * クール
     */
    propsSelectedKur: {
      type: Number,
      default: null
    },
    /**
     * ベッド
     */
    propsSelectedBed: {
      type: Number,
      default: null
    },
    // コンソールエラー対応、必須属性を外す
    historyKey: {
      type: String,
      required: false
    }
  },
  data() {
    return {
      //add 2023-02-16 8383 感染症のメッセージが繰返し表示される 張 start
      showDialogMessage:true,
      //add 2023-02-16 8383 感染症のメッセージが繰返し表示される 張 end
      searchData: {
        facilityCd: this.propsFacilityCd,
        isDel: "0",
        isDisp: "1"
      },
      structData: {
        /**
         * 治療開始時刻
         */
        indTreatStartTime: {
          initValue: null,
          editValue: null
        },
        /**
         * クール
         */
        selectedKur: {
          initValue: null,
          editValue: null
        },
        /**
         * クール選択肢
         */
        kurOptions: [],
        /**
         * ベッド
         */
        selectedBed: {
          initValue: null,
          editValue: null
        },
        /**
         * ベッド選択肢
         */
        bedOptions: []
      },
      /**
       * クール標準時刻
       */
      kurStandardStartTime: [],
      /**
       * デフォルトデータバインドフラグ
       */
      isDefaultBind: false,
      /**
       * 治療開始時刻操作フラグ
       */
      treatStartTimeFlag: false,
      /**
       * 除去対象ベッドコードリスト
       */
      targetRemoveBedCdList: [],
      oldOrdMainList: [],

      // del #11004 連携イベント発生部分不正 piao start
      // objModSendClass: "",
      // del #11004 連携イベント発生部分不正 piao end

      initValueModel: {
        kur: this.propsSelectedKur,
        time: this.propsIndTreatStartTime,
        bed: this.propsSelectedBed
      },
      // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 start
      //不一致チェック結果格納
      unmatchResultJson: {}
      // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 end
    };
  },
   computed: {
    ...mapGetters("pat-viewer-modal", { settingIndData: "getSettingIndData" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    ...mapGetters("pat-info", ["selectedPat"]),
    ...mapGetters("pat-viewer", { ordNoList: "getOrdNoList" }),
     //add 5619 装置と紐づいていないベッドも表示 張 start
    ...mapGetters("pat-viewer", ["getIndEndDate"]),
     //add 5619 装置と紐づいていないベッドも表示 張 end
    // add FNSI-スケジュールを変更、条件送信の場合、遷移しない 徐 start
    ...mapGetters("send-condition/scale", ["getIsInitialized"]),
    // add FNSI-スケジュールを変更、条件送信の場合、遷移しない 徐 end
    // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 start
     ...mapGetters("schedule-list", [
       "getUnmatchInfo",//不一致情報の取得
       "getSystemSettingUnmatchShowMsgFlag" //システム設定:不一致情報の確認メッセージ表示非表示フラグの取得
     ]),
     ...mapGetters("user", ["getFacilityCd"]) //施設コード取得用
    // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 end
  },

  watch: {
    "structData.selectedKur.editValue"(value) {
      // クールの初回変更時にデフォルトバインドフラグをtrueに変換
      if (value !== this.structData.selectedKur.initValue) {
        this.isDefaultBind = true;
      }

      // デフォルトデータがバインド後であれば、標準時刻を設定する
      if (this.isDefaultBind) {
        // クール選択時の標準時刻設定
        this.kurStandardStartTime.forEach(element => {
          if (element.kurCd === value) {
            this.structData.indTreatStartTime.editValue =
              element.kurStandardStartTime;
          }
        });
      }

      // クールが未選択の場合は、治療開始時刻は編集不可
      if (0 === value) {
        this.treatStartTimeFlag = true;
      } else {
        this.treatStartTimeFlag = false;
      }
    },
    //add 5619 装置と紐づいていないベッドも表示 張 start
    getIndEndDate(){
      this.createBedList()
    }
    //add 5619 装置と紐づいていないベッドも表示 張 start
  },

  async created() {
    // クールリスト作成
    await this.createKurList();
    // ベッドリスト作成
    await this.createBedList();
    // 透析開始時刻格納
    if (
      null !== this.propsIndTreatStartTime &&
      "" !== this.propsIndTreatStartTime
    ) {
      this.structData.indTreatStartTime.initValue = this.propsIndTreatStartTime;
      this.structData.indTreatStartTime.editValue = this.propsIndTreatStartTime;
    }

    // IndEditBaseでクール選択の最大選択数を1に設定
    this.$parent.$parent.kurMaxSelectedItems = 1;

    // IndEditBaseの変更イベント発火フラグをtrueに設定
    this.$parent.$parent.isWatchParent = true;

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    this.$parent.$parent.isDialogType9 = true;
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
    //FNSI-修正 #5525 横展開対応、xugj add start
    this.$parent.$parent.isSendNextPatInfoFlg = true;
    //FNSI-修正 #5525 横展開対応、xugj add end
  },

  methods: {
    ...mapActions('loading-screen', [
      "startLoadingScreen",
      "finishLoadingScreen"
    ]),
    // 予実リストへの変更通知
      //mod 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 start
      //...mapActions("indication-result", ["setResultUpdate"]),
    ...mapActions("indication-result", ["setResultUpdate","getIndicationResultList"]),
      //mod 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 end
    ...mapActions("send-condition/scale", {sendConditionSetSelectOrdNo: "setSelectOrdNo"}),
    //mod FNSI-6590 劉全航 start
    ...mapActions("treatment-record/common",
      [
        "getMstMachineByOrdNoRst",
        "sendNextPatInfoViewer"
      ]),
      //mod FNSI-5525 劉全航 end
      // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 start
    ...mapActions("schedule-list", [
      "setBedAndKurInfo", //ベッドとクールの取得設定
    ]),
      // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // del #11004 連携イベント発生部分不正 piao start
    // async getSchModifySendClass() {
    //   let retVal = 0;
    //   const prmfacilityCd = this.getFacilityCd;
    //   this.objModSendClass = sendRequestGetCoopIniSchModifySendClass(prmfacilityCd);
    //
    //   try {
    //     const response = await this.objModSendClass;
    //     retVal = response.data;
    //   } catch (error) {
    //     retVal = 0;
    //   }
    //   return retVal;
    // },
    // del #11004 連携イベント発生部分不正 piao end
    /**
     * 自患者内の使用ベッドリストを取得
     * @description 1日限定で編集中の時のみ作成
     */
    async getTargetRemoveBedCdList() {
      // 除去対象ベッドリストを初期化
      this.targetRemoveBedCdList = new Array();
      // 1日限定でない場合処理終了
      if (!this.$parent.$parent.weekEdit) {
        return;
      }
      // 選択クール初期値
      const initKur = this.propsSelectedKur;
      // 選択クール変更値
      let editKur = this.structData.selectedKur.editValue;
      // 選択ベッド初期値
      const initBed = this.propsSelectedBed;
      // 初回検索時に、クール変更値が格納されていない場合、初期値を変更値とみなす
      editKur = null === editKur ? initKur : editKur;

      const paramJson = {};
      paramJson.facility_cd = this.$parent.$parent.structData.facilityCd;
      paramJson.pat_id = this.$parent.$parent.structData.patId;
      paramJson.ind_start_date = this.$parent.$parent.structData.indStartDate;
      paramJson.ind_end_date = this.$parent.$parent.structData.indStartDate;
      paramJson.week_pattern = "[{'text': '全','done': false,'value': 0}]";

      const response = await ApiHelper.post(
        `/mainData/TreatDateList`,
        paramJson
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndSchEdit.vue', 'getTargetRemoveBedCdList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });

      const ordMainList = response.data;
      if (0 !== ordMainList.length) {
        ordMainList.forEach(item => {
          // 変更したクールと一致したものがある場合、以下の処理を実行
          if (item.indKurCd === editKur && 0 !== editKur) {
            // 取り出したものでベッドが未登録以外のものに絞る
            if (0 !== item.indBedCd) {
              // 自分自身を除去対象にいれないよう修正
              if (item.indBedCd !== initBed || item.indKurCd !== initKur) {
                this.targetRemoveBedCdList.push(item.indBedCd);
              }
            }
          }
        });
      }
    },

    /**
     * クールリスト作成
     */
    async createKurList() {
      this.structData.kurOptions = [];
      // リスト情報取得
      const params = {
        facility_cd: this.searchData.facilityCd,
        is_del: this.searchData.isDel
      };
      await ApiHelper.get("/mstInfo/mstKur", params)
        .then(response => {
          if (0 !== response.data.length) {
            // クールリスト作成
            this.createList(
              response.data,
              "kurCd",
              "kurName",
              "kurOptions",
              "selectedKur"
            );

            // クール標準時刻を初期化
            this.kurStandardStartTime = [];
            // クール標準時時刻格納
            for (let i = 0; i < response.data.length; i++) {
              const standardDataObj = {};
              // クール標準時刻リスト格納
              standardDataObj.kurCd = response.data[i].kurCd;
              // フォーマットの変更
              standardDataObj.kurStandardStartTime = moment(
                response.data[i].kurStandardStartTime,
                "HHmmss"
              ).format("HH:mm");
              // 正確な時間データが入っていない場合は、00:00を格納
              if ("Invalid date" === standardDataObj.kurStandardStartTime) {
                standardDataObj.kurStandardStartTime = "00:00";
              }
              this.kurStandardStartTime.push(standardDataObj);
            }
            // クール未登録時はクール標準時刻を未選択に設定
            this.kurStandardStartTime.push({
              kurCd: 0,
              kurStandardStartTime: null
            });
          }
          // デフォルト値の格納
          if (null !== this.propsSelectedKur) {
            this.structData.selectedKur.initValue = this.propsSelectedKur;
            this.structData.selectedKur.editValue = this.propsSelectedKur;
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndSchEdit.vue', 'createKurList', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });
    },

    /**
     * ベッドリスト作成
     */
    async createBedList() {
      // 重複対象ベッドリストの取得
      await this.getTargetRemoveBedCdList();
      this.structData.bedOptions = [];
      // ベッドリスト再作成前の情報をバックアップ
      const backBed = this.structData.selectedBed.editValue;
      //add 5619 装置と紐づいていないベッドも表示 張 start
      // let initBedCd = null;
      let initBedCd = 0;
      //add 5619 装置と紐づいていないベッドも表示 張 start
      // 初期値と同じクールを選んだときはベッドコードに初期値ベッドをセット
      const initKur = this.structData.selectedKur.initValue ?? this.propsSelectedKur;
      if (this.structData.selectedKur.editValue === initKur) {
        initBedCd = this.structData.selectedBed.initValue ?? this.propsSelectedBed;
      }
      //add 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 start
      // 画面集計情報検索条件
      const searchCondition = {
        // 治療日FROM
        'treat_date_from': this.$parent.$parent.structData.indStartDate.replace(/-/g, ''),
        // 治療日TO
        //upd 設定が終了してから削除すると、ベッドが表示されなくなります 修正 20230705 ztc start
        // 'treat_date_to': this.$parent.$parent.structData.indEndDate ==="" ?'99991231':this.$parent.$parent.structData.indEndDate
        'treat_date_to': !this.$parent.$parent.structData.indEndDate ? '99991231' : this.$parent.$parent.structData.indEndDate
        //upd 設定が終了してから削除すると、ベッドが表示されなくなります 修正 20230705 ztc end
      };
      const patViewResponsesData = await this.getIndicationResultList({patId:this.$parent.$parent.structData.patId, condition: searchCondition});
      //add 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 end
      // リスト情報取得
      const params = {
        facility_cd: this.searchData.facilityCd,
        pat_id: this.$parent.$parent.structData.patId,
        kur_cd: this.structData.selectedKur.editValue,
        treat_week_list: JSON.stringify(
          this.$parent.$parent.structData.indWeeks
        ),
        ind_start_date: this.$parent.$parent.structData.indStartDate,
        ind_end_date: this.$parent.$parent.structData.indEndDate,
        is_all: 0 === this.structData.selectedKur.editValue,
        init_bed_cd: initBedCd,
        // 変更対象クールコード
        ind_kur_cd: JSON.stringify(this.$parent.$parent.structData.selectedKur),
        // 変更対象治療方法コード
        ind_treatment_cd: JSON.stringify(this.$parent.$parent.structData.selectedTreat),
      };
      // add #10196 スキジュール行ヘッター、クリア開始日の年、管制所エラーです yangqingzhe start
      if(params.ind_start_date == "") return
      // add #10196 スキジュール行ヘッター、クリア開始日の年、管制所エラーです yangqingzhe end
      await ApiHelper.post("/mstInfo/getSelectForSearchFreeBeds", params)
        .then(response => {
          this.targetRemoveBedCdList.forEach(removeBedCd => {
            response.data = response.data.filter(item => {
              return removeBedCd !== item.bedCd;
            });
          });
          //del 5619 装置と紐づいていないベッドも表示 張 start
          // if (0 !== response.data.length) {
          //del 5619 装置と紐づいていないベッドも表示 張 end
            // ベッドリスト作成
            this.createList(
              response.data,
              "bedCd",
              "bedName",
              "bedOptions",
              "selectedBed"
            );
            //del 5619 装置と紐づいていないベッドも表示 張 start
          // }
          //del 5619 装置と紐づいていないベッドも表示 張 end
          // デフォルト値の格納
          if (null !== this.initValueModel.bed) {
            this.structData.selectedBed.initValue = this.initValueModel.bed;
            let setBed = this.initValueModel.bed;
            // ベッドリスト再作成前の情報があれば設定
            if (null !== backBed) {
              setBed = backBed;
            }
            // 選択ベッドがリストに存在しない場合は未登録を設定
            const searchRet = this.structData.bedOptions.filter(item => {
              return setBed === item.value;
            });
            // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
            //add 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 start
            // if (0 === searchRet.length) setBed = 0;
            // if (params.ind_end_date === "" || params.ind_end_date === null ) {
            //   for (let i = 0; i < patViewResponsesData.data.length; i++) {
            //     if (patViewResponsesData.data[i].bed_cd !== setBed) {
            //       setBed = 0;
            //       break;
            //     }
            //   }
            // }
            if (0 === searchRet.length && setBed) {
                const param = {
                  bedCd: setBed
                };
                ApiHelper.get("/mstInfo/mstBed/getBedName", param).then((res) => {
              this.structData.bedOptions.push({
                    displayValue: res.data,
                    value: setBed,
                    isShow: false
                  })
                  this.structData.selectedBed.editValue = setBed;
                });
            } else {
              this.structData.selectedBed.editValue = setBed;
            }
            //add 8085 【デグレ】患者経過総合ビューア>スケジュール編集にてベッドが登録されているのに未登録となる。 周安寧 end
            // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
          }
          //del 5619 装置と紐づいていないベッドも表示 張 start
          // if(this.initValueModel.bed !== null) {
          //   this.structData.selectedBed.editValue = this.initValueModel.bed;
          // }
          //del 5619 装置と紐づいていないベッドも表示 張 end
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndSchEdit.vue', 'createBedList', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });
    },

    /**
     * リスト作成
     * @param {object} リスト作成元データ[{},{}...]
     * @param {string} コードのカラム名
     * @param {string} 名称のカラム名
     * @param {string} プルダウンリスト名
     * @param {string} プルダウン選択コード
     */
    createList(dataList, columnCode, columnName, srcList, srcSelect) {
      // コードと名称のリストを作成
      let jsonData = {};
      const createList = [];
      // 未登録行をリストに追加
      jsonData.displayValue = "未登録";
      jsonData.value = 0;
      createList.push(jsonData);
      // 取得データをリストに追加
      if (0 !== dataList.length) {
        for (let i = 0; i < dataList.length; i++) {
          //add FutreNetWeb+SI課題管理No4676対応 于 start
          if(dataList.rst_dialysis_state > 0){
            return;
          }else {
            //add FutreNetWeb+SI課題管理No4676対応 于 end
            jsonData = {};
            jsonData.displayValue = dataList[i][columnName];
            jsonData.value = dataList[i][columnCode];
            createList.push(jsonData);
          }
        }
      }
      this.structData[srcList] = createList;
      this.structData[srcSelect].initValue = createList[0].value;
      this.structData[srcSelect].editValue = createList[0].value;
    },

    // mod #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
    /**
     * updateIndScheduleByOrdMoveCheck を呼ぶ保存（ボタン「new」）
     */
    async saveScheduleViaOrdMoveCheck() {
      const structData =
        this.$parent && this.$parent.$parent && this.$parent.$parent.baseData;
        
      if (!structData) {
        return;
      }
      await this.updateIndInfo(structData, { useOrdMoveCheckApi: true });
    },

    /**
     * DB登録処理
     * @param {Object} structData
     * @param {Object} [options]
     * @param {boolean} [options.useOrdMoveCheckApi] true のとき /mainData/updateIndScheduleByOrdMoveCheck を呼ぶ
     */
    async updateIndInfo(structData, options = {}) {
      const useOrdMoveCheckApi =
        options.useOrdMoveCheckApi === true ||
        (structData && structData.useOrdMoveCheckApi === true);
        // mod #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end
      this.startLoadingScreen();
      let mod_Flag = 0;

      // 変更箇所がなければ、メッセージ表示後処理終了
      if (this.checkEdit(0)) {
        console.log("IndSchEdit.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // 治療開始時刻
      if (null !== this.structData.indTreatStartTime.editValue) {
        this.structData.indTreatStartTime.editValue = moment(
          this.structData.indTreatStartTime.editValue,
          "HHmm"
        ).format("HH:mm");
      }

      const sendJson = {
        // 施設コード
        facility_cd: structData.facilityCd,
        // 患者ID
        pat_id: structData.patId,
        // 治療開始日
        ind_start_date: structData.indStartDate,
        // 治療終了日
        ind_end_date: structData.indEndDate,
        // 曜日パターン
        week_pattern: JSON.stringify(structData.indWeeks),
        // 変更対象クールコード
        ind_kur_cd: JSON.stringify(structData.selectedKur),
        // 変更対象治療方法コード
        ind_treatment_cd: JSON.stringify(structData.selectedTreat),
        // 変更後クールコード
        edit_ind_kur_cd: this.structData.selectedKur.editValue,
        // 変更後クール名
        edit_ind_kur_name: null,
        // 治療開始時刻
        edit_ind_treat_start_time: this.structData.indTreatStartTime.editValue,
        // 変更後ベッドコード
        edit_ind_bed_cd: this.structData.selectedBed.editValue,
        // 変更後ベッド名
        edit_ind_bed_name: null,
        // 指示者コード
        ind_user_id: structData.indUser,
        // 更新者
        upd_user_id: structData.updUser,
        // 終了日存在フラグ
        is_deadline: structData.isDeadline,
        // 更新モード
        update_mode: structData.updateMode ? structData.updateMode : null,
        // スキップ更新フラグ
        is_skip_update: structData.isSkipFlag ? structData.isSkipFlag : null,
// add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
        is_ind_sch_edit: false,
        is_rst_update: false,
// add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
        //add #10266 start
        update_flag: this.settingIndData.update_flag
        //add #10266 end
      };

      // 古いリスト
      const startDate = structData.indStartDate.replace(/-/g, '');
      const endDate = structData.indEndDate == null ? null : structData.indEndDate.replace(/-/g, '');
      const searchData = await ApiHelper.get(
        `/mainData/getByPatIdAndTreatDate/${structData.facilityCd}/${structData.patId}/${startDate}/${endDate}`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndSchEdit.vue', 'updateIndInfo', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        console.log("IndSchEdit.vue updateIndInfo throw error; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        throw error;
      });
      this.oldOrdMainList = searchData.data;
      // add FNSI-【1006】最新の改修対象一覧のIES89対応 韓 start
      let rstState = "0";
// mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
      let hasState1 = false;
      let hasState2 = false;
      let hasState4 = false;
      let ordNo = "";
      let patSwitchFlg = false;
      if (this.oldOrdMainList) {
        this.oldOrdMainList.forEach(item => {
          if(item.rstDialysisState ==="1") {
            hasState1 = true;
          }
          if(item.rstDialysisState ==="2") {
            rstState = item.rstDialysisState;
            hasState2 = true;
          }
          if((item.rstDialysisState ==="4" || item.rstDialysisState ==="5" || item.rstDialysisState ==="6") &&
            this.oldOrdMainList.length ===1) {
              // 期間指定：変更不可のため、oldOrdMainList.length ===1のみ変更できる
            rstState = item.rstDialysisState;
            hasState4 = true;
            ordNo = item.ordNo;
          }
        });

      }

      // add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng start
      let msg = "";
      // add #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng end
      if (hasState4 && this.structData.selectedKur.editValue === 0 && this.structData.selectedBed.editValue === 0) {
      // クール、ベッドともに未登録に変更は不可
        
      // #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng start
        // this.showMessage(12000061);
        // console.log("IndSchEdit.vue updateIndInfo return; this.finishLoadingScreen();");
        // this.finishLoadingScreen();
        // return;  
        msg = "クール・ベッド";
      } else if (hasState4 && this.structData.selectedKur.editValue === 0 && this.structData.selectedBed.editValue !== 0) {
        msg = "クール";
      } else if (hasState4 && this.structData.selectedBed.editValue === 0 && this.structData.selectedKur.editValue !== 0) {
        msg = "ベッド";
      }
      if (msg !== "") {
        this.showMessage(12000061, msg);
        console.log("IndSchEdit.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        return;
      }
      // #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng end

      if (rstState === "4" || rstState === "5" ) {
        const res = await ApiHelper.get(
          `/mainData/getPatSwitchFlag/${structData.facilityCd}/${ordNo}/${rstState}`
          ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndSchEdit.vue', 'updateIndInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          console.log("IndSchEdit.vue updateIndInfo throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });
        if (res) {
          patSwitchFlg = res.data;
        }
      }

      if (hasState2 || hasState4) {
     // 【指示変更前に警告】
          if (!await this.showChangeConfirmDialog(rstState,patSwitchFlg)) {
            this.$parent.$parent.isUpdating = false;
            this.$parent.$parent.updateDisable = false;
            console.log("IndSchEdit.vue updateIndInfo return; this.finishLoadingScreen();");
            this.finishLoadingScreen();
            return;
          } else{
            if (hasState4) {
              sendJson.is_ind_sch_edit = true;
              //mod 9806 ljx start
              /**
               * 正しい動作：
               * ①　クール・ベッドの変更は実績側に反映するかダイアログ表示し、選択に合わせて実績側への反映をする・しない
               * ②  開始時刻については、実績側に反映させたくないのでダイアログ自体を表示しない
               */
              //9806追加判断：開始時刻のみが変更される場合、ダイアログ自体を表示しない、それ以外は表示する
              if(this.getIsEdit("selectedKur") ||
                this.getIsEdit("selectedBed")){
                if (await this.showUpdateCheckDialog()) {
                  sendJson.is_rst_update = true;
                } else {
                  sendJson.is_rst_update = false;
                }
              }
              //mod 9806 ljx end
            }
          }
      }

      if (rstState != "0") {
        // 変更後クール名
        for (let i = 0; i < this.structData.kurOptions.length; i++) {
          if (this.structData.kurOptions[i].value == this.structData.selectedKur.editValue) {
            sendJson.edit_ind_kur_name = this.structData.kurOptions[i].displayValue;
          }
        }
        // 変更後ベッド名
        for (let i = 0; i < this.structData.bedOptions.length; i++) {
          if (this.structData.bedOptions[i].value == this.structData.selectedBed.editValue) {
            sendJson.edit_ind_bed_name = this.structData.bedOptions[i].displayValue;
          }
        }
      }

      // add FNSI-【1006】最新の改修対象一覧のIES89対応 韓 end
      // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 start
      //mod 8611 デグレ】ベッド条件不一致のメッセージが二度表示される 張 start
      // if (!await this.showUnmatchResultDialog()) {
        //     return;
      //   }

      if(!structData.showMessageFlg){
        if (!await this.showUnmatchResultDialog()) {
          console.log("IndSchEdit.vue updateIndInfo return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
      }
      //mod 8611 デグレ】ベッド条件不一致のメッセージが二度表示される 張 end
      // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 end

      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      let funcCd = "004";
      // 条件送信画面
      if (this.getIsInitialized) {
        funcCd = "013";
      }
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
      // mod #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
      const scheduleUrl = useOrdMoveCheckApi
        ? "/mainData/updateIndScheduleByOrdMoveCheck?sendCreateJournal=true&funcCd=" + funcCd
        : "/mainData/updateIndSchedule?sendCreateJournal=true&funcCd=" + funcCd;
      let response;
      try {
        response = await ApiHelper.post(scheduleUrl, sendJson);
      } catch (error) {
        if (
          useOrdMoveCheckApi &&
          error.response &&
          error.response.status === 400 &&
          error.response.data
        ) {
          getErrorMessage("IndSchEdit.vue", "updateIndInfo", error);
          const ed = error.response.data;
          if (ed.msgCd !== undefined && ed.msgCd !== null && ed.msgCd !== "") {
            const n = Number(ed.msgCd);
            this.showMessage(Number.isNaN(n) ? ed.msgCd : n);
          } else if (ed.message) {
            this.$ons.notification.alert(ed.message);
          }
          console.log(
            "IndSchEdit.vue updateIndScheduleByOrdMoveCheck 400; this.finishLoadingScreen();"
          );
          this.finishLoadingScreen();
          return;
        }
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage("IndSchEdit.vue", "updateIndInfo", error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        console.log(
          "IndSchEdit.vue updateIndInfo throw error; this.finishLoadingScreen();"
        );
        this.finishLoadingScreen();
        throw error;
      }

      if (
        useOrdMoveCheckApi &&
        response.data &&
        response.data.PROC_RESULT &&
        response.data.PROC_RESULT !== "SUCCESS"
      ) {
        const d = response.data;
        if (d.msgCd !== undefined && d.msgCd !== null && d.msgCd !== "") {
          const n = Number(d.msgCd);
          this.showMessage(Number.isNaN(n) ? d.msgCd : n);
        } else if (d.message) {
          this.$ons.notification.alert(d.message);
        }
        console.log(
          "IndSchEdit.vue updateIndScheduleByOrdMoveCheck non-SUCCESS; this.finishLoadingScreen();"
        );
        this.finishLoadingScreen();
        return;
      }

      if (useOrdMoveCheckApi && response.data) {
        const d = response.data;
        if (d.msgCd !== undefined && d.msgCd !== null && d.msgCd !== "") {
          const n = Number(d.msgCd);
          if (!Number.isNaN(n)) {
            d.msgCd = n;
          }
        }
        if (d.ordNo === undefined && d.doCancelGoSendordNo != null) {
          d.ordNo = d.doCancelGoSendordNo;
        }
      }
      // mod #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end
      //mod FNSI-6590 劉全航 start
      if(200 === response.status){

        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm start
        if (22020004 === response.data.msgCd) {
          this.$parent.$parent.messageDialogInfo.messageCd = response.data.msgCd;
          this.$parent.$parent.messageDialogInfo.type = "1";
          this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
          console.log("IndSchEdit.vue updateIndSchedule return; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          return;
        }
        // add #10712 日次スケジュール自動延長処理の除外考慮修正 zkm end

        this.oldOrdMainList.forEach(async ordMain => {
          if(ordMain.rstDialysisState !== "0") {
            const tempOrdNo = ordMain.ordNo;
            // 装置マスタの取得
            this.getMstMachineByOrdNoRst(tempOrdNo).then(machineRes => {
              let mstMachine = machineRes.data;
              if (mstMachine.length > 0){
                ApiHelper.get(
                  `/master_maintenance/mst_comsv_setting/data/${structData.facilityCd}`
                ).then((response) =>
                  {
                    let diviceEgeList = response.data.localDataSource.data;
                    let diviceEge = diviceEgeList.find(o =>{
                      return o.deviceEdgeNo == mstMachine[0].deviceEdgeNo;
                    });
                    let npatItem = JSON.parse(diviceEge.lcdNpat).npat_item;
                    let codeList = npatItem.map(o=>{
                      return o.code;
                    });
                    let changeFlag = false;
                    if(codeList.includes(9)){
                      changeFlag = this.initValueModel.time != this.structData.indTreatStartTime.editValue;
                    }
                    if(changeFlag){
                      const params = {
                        ordNo: tempOrdNo, //オーダー番号
                        machineNo: mstMachine[0].machineNo, //装置マスタ.装置番号
                        deviceEdgeNo: mstMachine[0].deviceEdgeNo, //デバイスエッジ番号
                        facilityCd: structData.facilityCd //施設コード
                      };
                      this.sendNextPatInfoViewer(params);
                    }
                  }
                ).catch(error => {
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
                  getErrorMessage('IndActionChart.vue', 'updateInfo', '送信失敗しました。');
                  //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
                  console.log("IndSchEdit.vue updateIndInfo throw error; this.finishLoadingScreen();");
                  this.finishLoadingScreen();
                  throw error;
                });
              }
            });
          }
        });
      }
      //mod FNSI-6590 劉全航 end
      // mod #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
      if (200 === response.status && response.data.msgCd) {
        // mod #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end
        this.showMessage(response.data.msgCd);
        // add FNSI-【1006】最新の改修対象一覧のIES89対応 韓 start
        // add FNSI-スケジュールを変更、条件送信の場合、遷移しない 徐 start
        // if (response.data.msgCd === 22010007 && (rstState ==="1" || rstState ==="2")) {
        if (response.data.msgCd === 22010007 && (hasState1 || hasState2) && !this.getIsInitialized) {
// mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
        // add FNSI-スケジュールを変更、条件送信の場合、遷移しない 徐 end
          if (await this.showMoveConfirmDialog()) {
            // 【指示変更後に確認】
            // ordNoセット
            this.sendConditionSetSelectOrdNo({
              ordNo: response.data.ordNo,
              ordNo2: null
            }).then(() => {
              // 条件送信画面へ遷移
              this.goSpecifiedView("send-condition");
            });
          }
        }
        // add FNSI-【1006】最新の改修対象一覧のIES89対応 韓 end
        console.log("IndSchEdit.vue updateIndInfo return; this.finishLoadingScreen();");
        this.finishLoadingScreen();
        // 処理終了
        return;
      }
      let BedUnregistSchInfo = [];
      if (200 === response.status && response.data.BedUnregistOrdList
          && response.data.BedUnregistOrdList.length > 0 && structData.updateMode) {
        // ベッド未登録となったオーダー情報を取得
        const responseScheduleInfo = await ApiHelper.post(
          `/mainData/getProcessOrdSchedule/${structData.facilityCd}/${structData.updateMode}`,
          response.data.BedUnregistOrdList
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndSchEdit.vue', 'updateIndInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          console.log("IndSchEdit.vue updateIndInfo throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });
        BedUnregistSchInfo = responseScheduleInfo.data;
      }

      let duplicatedOrdInfo = [];
      if (200 === response.status && response.data.DuplicatedOrdNoList
          && response.data.DuplicatedOrdNoList.length > 0) {
        // 同日予定でベッド未登録となったオーダー情報を取得
        const responseDuplicatedOrdInfo = await ApiHelper.post(
          `/mainData/getDuplicatedOrdList/${structData.facilityCd}`,
          response.data.DuplicatedOrdNoList
        ).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndSchEdit.vue', 'updateIndInfo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          console.log("IndSchEdit.vue updateIndInfo throw error; this.finishLoadingScreen();");
          this.finishLoadingScreen();
          throw error;
        });

        duplicatedOrdInfo = responseDuplicatedOrdInfo.data;
      }
      // mod #11147 患者経過総合ビューアの子画面で編集後に親画面のスクロール位置を元の位置のままとする。 start
      // 引数にtrueを指定すると患者経過総合ビューアでは患者切替時の動作となるため、trueを渡すのはNG
      // 体重測定＞スケジュール編集で編集後に破棄確認を表示しないようにするために"1"を渡す。
      // 体重測定では渡した引数を!reFlagで判定しているので、trueを渡した時と同じ動作となるため影響なし
      // 患者経過総合ビューアでは渡した引数を===trueで判定しているので影響なし
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20240105 ztc start
      // EventBus.$emit("isRefresh");
      // EventBus.$emit("isRefresh", true);
      EventBus.$emit("isRefresh", "1");
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20240105 ztc end
      // mod #11147 患者経過総合ビューアの子画面で編集後に親画面のスクロール位置を元の位置のままとする。end

      // ベッド未登録となった予定が存在する場合メッセージ表示
      if (structData.updateMode && BedUnregistSchInfo.length > 0) {
        const params = {
          updateMode: structData.updateMode,
          BedUnregistSchInfo: BedUnregistSchInfo
        }
        EventBus.$emit("isBedUnregist", params);
      }

      // ベッド未登録となった重複した予定が存在する場合メッセージ表示
      if (duplicatedOrdInfo.length > 0) {
        const params = {
          DuplicatedOrdInfo: duplicatedOrdInfo
        }
        EventBus.$emit("isDuplicated", params);
      }

      // 予実リストの更新
      this.setResultUpdate(new Date());
      console.log("IndSchEdit.vue updateIndInfo hide-modal this.finishLoadingScreen();");
      this.finishLoadingScreen();
      // モーダルを閉じる
      this.$parent.$parent.$emit("hide-modal");
    },

    // add FNSI-【1006】最新の改修対象一覧のIES89対応 韓 start
    // 条件送信以降の場合、実績の変更をするか確認する。
    async showMoveConfirmDialog() {
      let rtn = false;
      // rst_dialisys_stateが1,2の場合
// mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
      let msg = this.messageInfo('12000056');
      let mTitle = DIALOG_MESSAGES[12000056].title;
      await this.$ons.notification.confirm({
        title: mTitle,
        message: msg,
        callback: answer => {
          if (answer === 1) {
            rtn = true;
          }
        }
      });
      return rtn;
    },

    async showChangeConfirmDialog(rstState,patSwitchFlg) {
      let rtn = false;
      let msg = "";
      let mTitle = "";
      switch (rstState) {
        case "2" :
          mTitle = DIALOG_MESSAGES[12000058].title
          msg = this.messageInfo('12000058');
          break;
        case "4" :
        case "5" :
        case "6" :
          mTitle = DIALOG_MESSAGES[12000057].title;
          if (patSwitchFlg) {
            msg = this.messageInfo('12000057');
          } else {
            msg = this.messageInfo('12000059');
          }
          break;
        default: break;
      }

      await this.$ons.notification.confirm({
        title: mTitle,
        message: msg,
        callback: answer => {
          if (answer === 1) {
            rtn = true;
          }
        }
      });
      return rtn;
    },

    // 実績の変更をするか確認する。
    async showUpdateCheckDialog() {
        let rtn = false;
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[12000060].title,
          message: this.messageInfo('12000060'),
          callback: answer => {
            if (answer === 1) {
              rtn = true;
            }
          }
        });
        return rtn;
    },
    // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 start
    async showUnmatchResultDialog() {
      let rtn = true;
  //mod 2023-02-16 8383 感染症のメッセージが繰返し表示される 張 end
  if (this.showDialogMessage) {
    this.showDialogMessage = false;
      //  add by ShiHongda 2023-02-08 [optimize] --start /
      let oldOrdMainOrdNoList = this.oldOrdMainList.map((item) => {
        return item.ordNo
      })

      const facilityCd = this.getFacilityCd;
      await ApiHelper.get("/scheduleList/getBedAndKurInfo", {
        // ここにクエリパラメータを指定する
        facilityCd
      })
        //成功した場合の処理
        .then(response => {
          //ストアにセット
          this.setBedAndKurInfo(response);
        })

      // let OrdNoList = JSON.stringify(oldOrdMainOrdNoList);

      let response = await ApiHelper.post("/scheduleList/getPatInfoForCheckList", { OrdNoList:oldOrdMainOrdNoList })
      .catch(error => {
        getErrorMessage('IndSchEdit.vue', 'updateIndInfo', error);
        //mod #12661 securify SQLインジェクション(High) まとめ zrx start
        // 400系等はここで false を返し、呼び出し元(updateIndInfo)の既存分岐で
        // finishLoadingScreen() を実行させる
        return null;
      });
      if (!response) {
        this.showDialogMessage = true;
        return false;
      }
      //mod #12661 securify SQLインジェクション(High) まとめ zrx end
      console.log(response)
      let retJsonList = response.data.patInfoList;

      for(let i = 0;i<retJsonList.length;i++){
        let retJson = retJsonList[i];
        let checkTargetJson = {};
        checkTargetJson.kur_cd = this.structData["selectedKur"].initValue;
        checkTargetJson.bed_cd = this.structData["selectedBed"].initValue;
        checkTargetJson.target_bed_cd = this.structData.selectedBed.editValue;
        checkTargetJson.vaDirect = retJson.va_direct;
        checkTargetJson.isInfect = retJson.is_infect;
        checkTargetJson.deviceMode = retJson.device_mode
        //ベッドコードが未配置以外の場合
        if (checkTargetJson.target_bed_cd !== 0) {
          //不一致チェックを実施
          this.unmatchResultJson = this.getUnmatchInfo(checkTargetJson);
          let outMsg = "";
          if (this.unmatchResultJson.unmatchFlag && this.getSystemSettingUnmatchShowMsgFlag) {
            //不一致があり&&システム設定での不一致確認がtrue
            if (!this.unmatchResultJson.infectionFlag) {
              if (outMsg.indexOf("感染症")<0) {
                if (outMsg !== "") {
                  outMsg += "・";
                }
                outMsg += "感染症";
              }
            }
            if (!this.unmatchResultJson.shuntFlag) {
              if (outMsg.indexOf("VA位置")<0) {
                if (outMsg !== "") {
                  outMsg += "・";
                }
                outMsg += "VA位置";
              }
            }
            if (!this.unmatchResultJson.deviceModeFlag) {
              if (outMsg.indexOf("治療方法")<0) {
                if (outMsg !== "") {
                  outMsg += "・";
                }
                outMsg += "治療方法";
              }
            }
          }
          //if (outMsg != "") {
          if (outMsg != ""&&retJsonList.length-1===i) {
            const resOk = await this.$ons.notification.confirm({
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
              // title: "ベッド条件不一致",
              title: DIALOG_MESSAGES[13000071].title,
              // message: outMsg + "が不一致ですが移動しますか?"
              message: messageFormat(DIALOG_MESSAGES[13000071].message,outMsg),
              // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            });
            if (resOk === 1) {
              rtn = true;
            } else {
              this.$parent.$parent.isUpdating = false;
              this.$parent.$parent.updateDisable = false;
              rtn = false;
            }
            this.showDialogMessage=true;
          }
        }
      }
      //  add by ShiHongda 2023-02-08 [optimize] --end /
    }
            //mod 2023-02-16 8383 感染症のメッセージが繰返し表示される 張 end

      return rtn;
    },
    // add 7579-【デグレ】対応していない治療方法，シャント位置のベッドへ移動した時に注意喚起メッセージが出ない 周安寧 end
    messageInfo(messageCd) {
      // 定義ファイルから対応するメッセージコードの文字列を取得
      const message = DIALOG_MESSAGES[messageCd].message;
      if (message === undefined) {
        return "メッセージが定義されていません。";
      }
      // パラメータ文字列を置換
      let replacedMessage = message;

      // 改行文字列をbrタグに置換
      replacedMessage = replacedMessage.replace(/\n/g, "<br>");
      return replacedMessage;
    },
// mod FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
    // add FNSI-【1006】最新の改修対象一覧のIES89対応 韓 end

    /**
     *
     */
    getCrud(item){
      let kurEditMode = null;
      if (item.indKurCd == 0) {
        // ビューア画面のスケジュールモーダルにてクールを未確定状態からクールを選択し保存した時
        if (this.structData.selectedKur.editValue != 0) {
          kurEditMode = "C";
        }
      } else {
        if (this.structData.selectedKur.editValue == 0) {
          // ビューア画面のスケジュールモーダルにてクールを確定状態から未確定を選択し保存した時
          kurEditMode = "D";
        } else {
          // add FNSI-7216 治療開始時刻を変更してもsys_coop_journalにイベントが作成されない 劉全航 start
          var treatStartTime = this.structData.indTreatStartTime.editValue.replaceAll(":", "");
          // add FNSI-7216 治療開始時刻を変更してもsys_coop_journalにイベントが作成されない 劉全航 end
          if (
            item.indKurCd != this.structData.selectedKur.editValue
            // add FNSI-7216 治療開始時刻を変更してもsys_coop_journalにイベントが作成されない 劉全航 start
            || treatStartTime != item.indTreatStartTime
            || item.indBedCd != this.structData.selectedBed.editValue
            // add FNSI-7216 治療開始時刻を変更してもsys_coop_journalにイベントが作成されない 劉全航 end
          ) {
            // ビューア画面のスケジュールモーダルにてクール・ベッドを修正し保存した時
            kurEditMode = "U";
          }
        }
      }
      return kurEditMode;
    },

    /**
     * 変更チェック処理
     * @param num 0->保存時変更チェック処理 1->キャンセル時変更チェック処理
     * @description 保存時チェック処理時に変更がなければメッセージを表示
     *              キャンセルチェック処理時に変更があればメッセージを表示
     */
    checkEdit(num) {
      // 変更箇所数
      let editCount = 0;

      for (let i = 0; i < 3; i++) {
        let varName;
        switch (i) {
          case 0:
            // クール
            varName = "selectedKur";
            break;

          case 1:
            // 治療開始時刻
            varName = "indTreatStartTime";
            break;

          case 2:
            // ベッド
            varName = "selectedBed";
            break;

          default:
            break;
        }

        // 変更あり
        if (this.getIsEdit(varName)) {
          editCount++;
        }
      }
      let isShowMessage = false;
      // 変更箇所無し
      if (0 !== editCount) {
        // キャンセル時メッセージ表示
        if (1 === num) {
          this.showMessage(20010001);
          isShowMessage = true;
        }
      } else {
        // データセルクリック時以外は以下の処理は行わない
        if (
          !this.$parent.$parent.settingData.startDateEdit ||
          !this.$parent.$parent.settingData.endDateEdit
        ) {
          return;
        }

        // 保存時メッセージ表示
        if (0 === num) {
          this.showMessage(20010003);
          isShowMessage = true;
        }
      }
      return isShowMessage;
    },

    /**
     * 変更有無チェック
     * @param variableName 変数名
     * クール      selectedKur
     * 治療開始時刻 indTreatStartTime
     * ベッド      selectedBed
     */
    getIsEdit(variableName) {
      const checkData = this.structData[variableName];
      return checkData.initValue !== checkData.editValue ? true : false;
    },

    /**
     * IndEditBaseのwatch対象コントロールで変更が行われた際の制御
     * @summary IndEditBaseのwatch対象コントロールで変更が行われた際に再描画するように制御
     * @description IndEditBasaeのstructDataの対象コントロールに割り当てられた変数をwatchし変更されたタイミングでこの関数を呼び出す
     */
    //del FNSI-5639 劉全航 start
    // changeParentInfo() {
    //   this.createBedList();
    // },
    //del FNSI-5639 劉全航 end
    // del #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
    //add 5619 装置と紐づいていないベッドも表示 張 start
      //  changeParentInfo() {
      //   this.createBedList();
      //  },
     //add 5619 装置と紐づいていないベッドも表示 張 end
     // del #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end

    /**
     * メッセージ表示処理
     * @param msgCd メッセージコード
     * @param strParam 置換文字列
     */
    showMessage(msgCd, strParam) {
      let messageType = null;
      let stringParams = [];
      const content1 = "<br>以下を選択してください。<br>";
      const content2 = "・キャンセル: 登録を取りやめる<br>";
      const content3 =
        "・いいえ: 登録済みの予定がある日以外を指定ベッドで登録し、登録済み予定がある日はベッド未登録とする。<br>";
      const content4 = "・はい: 登録済みの予定をベッド未登録にして、指定ベッドで登録する。";
      switch (parseInt(msgCd)) {
        case 12010001:
          messageType = "2";
          stringParams = ["<br>予定が重ならない日のみ登録しますか？"];
          break;

        case 12010002:
          messageType = "6";
          stringParams = [`${content1}${content2}${content3}${content4}`];
          break;

        // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 start
        case 12000240:
          messageType = "1";
          stringParams = [""];
          break;
          // add #10772 10601で作成したスケジュール移動処理を拡張して全機能に展開する。 関 end

        case 20010001:
          messageType = "2";
          stringParams = [""];
          break;

        case 20010003:
// add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 start
        case 12000061:
// add FNSI-障害票一覧_患者経過総合ビューア.xlsxのNo.79(外結)対応 韓 end
          // del #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng start
          // messageType = "1";
          // stringParams = [""];
          // break;
          // del #10748 患者経過総合ビューアで治療終了と実績確定をベッド，クールが未登録で移動可能 linjunfeng end

        case 22010001:
          messageType = "1";
          stringParams = [strParam];
          break;

        case 22010004:
          messageType = "1";
          stringParams = [""];
          break;

        case 22010005:
          messageType = "1";
          stringParams = ["治療方法", "クール・ベッド"];
          break;

        case 22010006:
          messageType = "1";
          stringParams = ["移動"];
          break;

        case 22010007:
          messageType = "1";
          stringParams = ["移動"];
          break;

        case 22010011:
          messageType = "1";
          stringParams = [""];
          break;

        default:
          break;
      }
      this.$parent.$parent.messageDialogInfo.messageCd = parseInt(msgCd);
      this.$parent.$parent.messageDialogInfo.type = messageType;
      this.$parent.$parent.messageDialogInfo.stringParams = stringParams;
      this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
    },

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    isEdit() {
      const treatCondItems = this.$refs;
      let editCount = 0;
      Object.keys(treatCondItems).forEach(key => {
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240227 ztc start
        if(key === 'time'){
          if(!!treatCondItems[key]){
            let initTimeValue = JSON.parse(JSON.stringify(treatCondItems[key].value.initValue));
            let editTimeValue = JSON.parse(JSON.stringify(treatCondItems[key].value.editValue));
            if(!!initTimeValue && initTimeValue.indexOf(":") === -1){
              initTimeValue = `${initTimeValue.substr(0, 2)}:${initTimeValue.substr(2, 2)}`;
            }
            if(!!editTimeValue && editTimeValue.indexOf(":") === -1){
              editTimeValue = `${editTimeValue.substr(0, 2)}:${editTimeValue.substr(2, 2)}`;
            }
            if(initTimeValue != editTimeValue){
              editCount += 1;
            }
          }
        }else{
          if ((treatCondItems[key] && treatCondItems[key].isEdited)
              || (treatCondItems[key][0] && treatCondItems[key][0].isEdited)) {

            // 変更箇所数格納
            editCount += 1;
          }
        }
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者経過総合ビューア 20240227 ztc end
      });
      if (0 === editCount) {
        return false;
      }
      return true;
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async resetComponentIndData(structData){
      if (this.isEdit()) {
        this.$parent.$parent.messageDialogInfo.messageCd = 70000028;
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx start */
        this.$parent.$parent.messageDialogInfo.type = "9";
        /* mod FNSI-4212 更新対象変更時のウインドウが不正 liumx end */
        this.$parent.$parent.messageDialogInfo.isDialogVisible = true;
        return;
      } else {
        this.getComponentData(structData,2);
      }
    },
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end

    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add start
    async getComponentData(structData,answer) {

      if (answer === 1) {
        return;
      }

      let indWeeks = [
        {
          text: "全",
          done: true,
          value: 0
        },
        {
          text: "月",
          done: true,
          value: 1
        },
        {
          text: "火",
          done: true,
          value: 2
        },
        {
          text: "水",
          done: true,
          value: 3
        },
        {
          text: "木",
          done: true,
          value: 4
        },
        {
          text: "金",
          done: true,
          value: 5
        },
        {
          text: "土",
          done: true,
          value: 6
        },
        {
          text: "日",
          done: true,
          value: 7
        }
      ];
      const paramJson = {};
      // 施設情報
      paramJson.facility_cd = structData.facilityCd;
      // 患者情報
      paramJson.pat_id = structData.patId;
      // 治療開始日時
      paramJson.start_date = structData.indStartDate;
      // 治療終了日時
      paramJson.end_date = "";
      // クール
      paramJson.ind_kur_cd = JSON.stringify(structData.selectedKur);
      // 治療方法
      paramJson.ind_treatment_cd = JSON.stringify(structData.selectedTreat);
      // 曜日パターン
      paramJson.weeks = JSON.stringify(indWeeks);

      // 対象日時の治療情報取得(開始日付・治療方法・クールで絞り込み)
      let response = await ApiHelper.post(
        "/mainData/getOrdMainDataInfo",
        paramJson
      ).catch(error => {
        getErrorMessage('IndEquipmentEditBase.vue', 'getComponentData', error);
        throw error;
      });

      let ordMainData = response.data;
      if(ordMainData && ordMainData.length > 0) {
        ordMainData = ordMainData[0];
      } else {
        return;
      }

      // 最新の検索結果すべてを画面に設定する
      if(ordMainData) {
        const ordMainDataOld = {
          indKurCd : ordMainData.indKurCd,
          indTreatStartTime: ordMainData.indTreatStartTime,
          indBedCd : ordMainData.indBedCd
        };
        if(answer === 3) {
          if (this.structData.selectedKur.editValue != this.initValueModel.kur) {
            ordMainData.indKurCd = this.structData.selectedKur.editValue;
          }
          if (this.structData.indTreatStartTime.editValue != this.initValueModel.time) {
            ordMainData.indTreatStartTime = this.structData.indTreatStartTime.editValue;
          }
          // mod 5619 装置と紐づいていないベッドも表示 張 start
          if (this.structData.selectedBed.editValue != this.initValueModel.bed) {
            ordMainData.indBedCd = this.structData.selectedBed.editValue;
          }
          // mod 5619 装置と紐づいていないベッドも表示 張 end
        }

        /* modify by chamaojia 2023-05-04 [8560] 最初の値と後の値のフォーマットが一致しません  --start */
        if(ordMainData.indTreatStartTime && ordMainData.indTreatStartTime.indexOf(":") === -1) {
          ordMainData.indTreatStartTime =
              ordMainData.indTreatStartTime.slice(0, 2) + ":" + ordMainData.indTreatStartTime.slice(2, 4);
        }
        /* modify by chamaojia 2023-05-04 [8560] 最初の値と後の値のフォーマットが一致しません  --end */
        if(ordMainData.indKurCd === 0) {
          ordMainData.indTreatStartTime = null;
        }
        // 初期値再設定
        if(ordMainDataOld.indTreatStartTime) {
          ordMainDataOld.indTreatStartTime = ordMainDataOld.indTreatStartTime.slice(0, 2)
              + ":" + ordMainDataOld.indTreatStartTime.slice(2, 4);
        }
        this.initValueModel = {
          kur: ordMainDataOld.indKurCd,
          time: ordMainDataOld.indTreatStartTime,
          bed: ordMainDataOld.indBedCd
        }
        this.structData.indTreatStartTime.initValue = ordMainDataOld.indTreatStartTime;
        this.structData.selectedBed.initValue = ordMainDataOld.indBedCd;
        this.structData.selectedKur.initValue = ordMainDataOld.indKurCd;

        this.structData.indTreatStartTime.editValue = ordMainData.indTreatStartTime;
        this.structData.selectedBed.editValue = ordMainData.indBedCd;
        this.structData.selectedKur.editValue = ordMainData.indKurCd;

        // クールの値が同じ場合はデフォルトバインドフラグをfalseに戻す
        if (this.structData.selectedKur.editValue === this.structData.selectedKur.initValue) {
          this.isDefaultBind = false;
        }
        //add 5619 装置と紐づいていないベッドも表示 張 start
        // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
        const params = {
          facility_cd: this.searchData.facilityCd,
          pat_id: this.$parent.$parent.structData.patId,
          kur_cd: this.structData.selectedKur.editValue,
          treat_week_list: JSON.stringify(
            this.$parent.$parent.structData.indWeeks
          ),
          ind_start_date: this.$parent.$parent.structData.indStartDate,
          ind_end_date: this.$parent.$parent.structData.indEndDate,
          is_all: 0 === this.structData.selectedKur.editValue,
          init_bed_cd: ordMainData.indBedCd,
          // 変更対象クールコード
          ind_kur_cd: JSON.stringify(this.$parent.$parent.structData.selectedKur),
          // 変更対象治療方法コード
          ind_treatment_cd: JSON.stringify(this.$parent.$parent.structData.selectedTreat),
        };
        if(params.ind_start_date == "") return
        const response = await ApiHelper.post("/mstInfo/getSelectForSearchFreeBeds", params)
        this.targetRemoveBedCdList.forEach(removeBedCd => {
          response.data = response.data.filter(item => {
            return removeBedCd !== item.bedCd;
          });
        });
        const dataList = response.data;
        const columnCode = "bedCd"
        const columnName = "bedName"
        const srcList = "bedOptions"
        let jsonData = {};
        const createList = [];
        // 未登録行をリストに追加
        jsonData.displayValue = "未登録";
        jsonData.value = 0;
        createList.push(jsonData);
        // 取得データをリストに追加
        if (0 !== dataList.length) {
          for (let i = 0; i < dataList.length; i++) {
            //add FutreNetWeb+SI課題管理No4676対応 于 start
            if(dataList.rst_dialysis_state > 0){
              return;
            }else {
              //add FutreNetWeb+SI課題管理No4676対応 于 end
              jsonData = {};
              jsonData.displayValue = dataList[i][columnName];
              jsonData.value = dataList[i][columnCode];
              createList.push(jsonData);
            }
          }
        }
        this.structData[srcList] = createList;
        // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
        const beds=this.structData.bedOptions.map(item=>item.value)
        if (!beds.includes(this.structData.selectedBed.editValue)) {
          // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng start
          // this.structData.selectedBed.initValue = 0;
          // this.structData.selectedBed.editValue = 0;
          const param = {
            bedCd: ordMainData.indBedCd
          };
          ApiHelper.get("/mstInfo/mstBed/getBedName", param).then((res) => {
            this.structData.bedOptions.push({
              displayValue: res.data,
              value: ordMainData.indBedCd,
              isShow: false
            })
            this.structData.selectedBed.editValue = ordMainData.indBedCd;
          });
          // #10266 スケジュール親/子ヘッダー押下　NG linjunfeng end
        }
        //add 5619 装置と紐づいていないベッドも表示 張 start
      }
    }
    //FNSI-修正【患者経過総合ビューア】#4859 横展開対応、xugj add end
  }
};
</script>

<style scoped>
.div-style {
  padding: 5px 10px;
}

.input-style {
  width: 100%;
}

.input-time-style {
  width: 98%;
  text-align: left;
}
</style>
