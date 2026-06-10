<template>
  <div id="main-id" class="main-content-area">
    <div class="disp-item-header">
      <v-ons-row>
        <v-ons-col width="30%" class="header-title-style facility-label-style">
          在宅透析指示書
        </v-ons-col>
        <v-ons-col width="70%" class="header-info-style facility-label-style">
          {{toDay + "  " + getUserName}}
        </v-ons-col>
      </v-ons-row>
    </div>
    <div class="disp-item-content-area">
      <table class="disp-item-area">
        <tr>
          <td>
            <v-ons-row>
                <v-ons-col class="cond-title-style cond-td-style">
                適用開始日
                </v-ons-col>
                <v-ons-col class="cond-td-style cond-td-padding">
                  <div class="flex-align-center">
                    <input
                      input-id='treatStartDate'
                      name='treatStartDate'
                      type='date'
                      v-model="treatStartDate"
                      model-event="change"
                      @change="editUpdate"
                      class="kendo-width-style ntss-input-date" />
                    <common-calendar v-model="treatStartDate" @input="editUpdate" />
                  </div>
                </v-ons-col>
            </v-ons-row>
            <v-ons-row>
                <v-ons-col class="cond-title-style cond-td-style">
                  ベッド
                </v-ons-col>
                <v-ons-col class="cond-td-style cond-td-padding">
                  <kendo-dropdownlist
                    v-model="bedCd"
                    :data-source="bedList"
                    :data-text-field="'bedName'"
                    :data-value-field="'bedCd'"
                    :filter="'contains'"
                    @open="addMaxContentStyle"
                    @change="bedListChange($event),editUpdate()"
                    class="kendo-width-style">
                  </kendo-dropdownlist>
                </v-ons-col>
            </v-ons-row>
            <v-ons-row>
                <v-ons-col class="cond-title-style cond-td-style">
                  治療方法
                </v-ons-col>
                <v-ons-col class="cond-td-style cond-td-padding none-border-bot">
                <kendo-dropdownlist
                  v-model="treatMethodCd"
                  :data-source="treatMethod"
                  :data-text-field="'treatmentName'"
                  :data-value-field="'treatmentCd'"
                  :filter="'contains'"
                  @open="addMaxContentStyle"
                  @change="treatMethodChange($event),editUpdate()"
                  class="kendo-width-style">
                </kendo-dropdownlist>
                </v-ons-col>
            </v-ons-row>
            <v-ons-row>
                <v-ons-col class="cond-title-style cond-td-style">
                治療条件
                </v-ons-col>
                <v-ons-col class="cond-td-style">
                <div v-for="(treat, cd) in treatCond" :key="treat.id">
                    <div v-if="treat.isUse">
                    <!-- eslint-disable-next-line vue/require-component-is -->
                    <component
                        :is="treat.component"
                        :ref="cd"
                        :value="treat.value"
                        @input="editItem('cond', $event, cd)"
                        class="facility-label-style"
                    />
                    </div>
                    <div v-else class="cond-disabled">
                    <!-- eslint-disable-next-line vue/require-component-is -->
                    <component
                        :is="treat.component"
                        :ref="cd"
                        :value="treat.value"
                    />
                    </div>
                </div>
                </v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col class="cond-title-style cond-td-style">
                <v-ons-col>投与薬剤</v-ons-col>
                <v-ons-col>
                  <button class="button btn-ntss-custom" @click="addItem('medicine')">追加</button>
                </v-ons-col>
              </v-ons-col>
              <transition-group
                name="cond-transition"
                class="cond-td-style none-border-top"
                tag="ons-col"
              >
                <v-ons-row v-for="(medi, index) in medicine" :key="medi.id">
                  <v-ons-col>
                    <ind-medicine-edit
                      :fields-data="medi"
                      @input="editItem('medicine', $event, medi.id)"
                      class="facility-label-style"
                    />
                  </v-ons-col>
                  <v-ons-col class="cond-del-style">
                    <button @click="deleteItem('medicine', index)">
                      <v-ons-icon icon="fa-trash" />
                    </button>
                  </v-ons-col>
                </v-ons-row>
              </transition-group>
            </v-ons-row>
          </td>
        </tr>
      </table>
    </div>
    <!-- 下部ボタン部 -->
    <div id="bottom-buttons">
      <div class="bottom-buttons-div">
        <v-ons-button class="button denial-btn" style="margin-left:10px; width: 120px;" @click="clear">キャンセル</v-ons-button>
        <!-- 在宅機能無効化に伴い常時無効にしています -->
        <v-ons-button class="button registration-btn" style="margin-left:10px; width: 120px;"  @click="saveRecord" disabled="disabled">確定</v-ons-button>
      </div>
    </div>
  </div>
</template>

<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapGetters, mapActions } from "vuex";
import { treatment } from "@/functions/mst/MstGetters.js";
import _ from "underscore";
import IndMedicineEdit from "@/components/indication/IndMedicineEdit";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "ind-medicine-edit": IndMedicineEdit,
    "common-calendar": commonCalender
  },

  data() {
    return {
      treatMethodCd: null,
      treatMethod: null,
      treatCond: {
        "1": {
          id: _.uniqueId("cond"),
          component: () => import("@/components/indication/IndTreatCondTime"),
          value: null,
          medicineType: null
        },
        "2": {
          id: _.uniqueId("cond"),
          component: () => import("@/components/indication/IndTreatCondVa"),
          value: null,
          medicineType: null
        },
        "3": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondTargetWeight"),
          value: null,
          medicineType: null
        },
        "4": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondFilterLimit"),
          value: null,
          medicineType: null
        },
        "5": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondDialyzer"),
          value: null,
          medicineType: null
        },
        "6": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondSeparatoryColumn"),
          value: null,
          medicineType: null
        },
        "7": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondFirstPass"),
          value: null,
          medicineType: null
        },
        "8": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondSecondPass"),
          value: null,
          medicineType: null
        },
        "9": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondNeedleA"),
          value: null,
          medicineType: null
        },
        "10": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondNeedleV"),
          value: null,
          medicineType: null
        },
        "11": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondNeedleSN"),
          value: null,
          medicineType: null
        },
        "12": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondNeedleSelection"),
          value: null,
          medicineType: null
        },
        "13": {
          id: _.uniqueId("cond"),
          component: () => import("@/components/indication/IndTreatCondTube"),
          value: null,
          medicineType: null
        },
        "14": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondBloodFlowRate"),
          value: null,
          medicineType: null
        },
        "15": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondDialysate"),
          value: null,
          medicineType: null
        },
        "16": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondDialysateAmount"),
          value: null,
          medicineType: null
        },
        "17": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondDialysateFlowRate"),
          value: null,
          medicineType: null
        },
        "18": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondDialysateTemperature"),
          value: null,
          medicineType: null
        },
        "19": {
          id: _.uniqueId("cond"),
          component: () => import("@/components/indication/IndTreatCondIv"),
          value: null,
          medicineType: null
        },
        "20": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIvAmount"),
          value: null,
          medicineType: null
        },
        "21": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIvSelection"),
          value: null,
          medicineType: null
        },
        "22": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIvCount"),
          value: null,
          medicineType: null
        },
        "23": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIvTemperature"),
          value: null,
          medicineType: null
        },
        "24": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIvFlowRate"),
          value: null,
          medicineType: null
        },
        "25": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondAntiCoagulant"),
          value: null,
          medicineType: null
        },
        "26": {
          id: _.uniqueId("cond"),
          component: () =>
            import(
              "@/components/indication/IndTreatCondAntiCoagulantOneshotAmount"
            ),
          value: null,
          medicineType: null
        },
        "27": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondAntiCoagulantFlowRate"),
          value: null,
          medicineType: null
        },
        "28": {
          id: _.uniqueId("cond"),
          component: () =>
            import(
              "@/components/indication/IndTreatCondAntiCoagulantAmountTotal"
            ),
          value: null,
          medicineType: null
        },
        "29": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpSelection"),
          value: null,
          medicineType: null
        },
        "30": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpStart"),
          value: null,
          medicineType: null
        },
        "31": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpOneshotAmount"),
          value: null,
          medicineType: null
        },
        "32": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpFlowRate"),
          value: null,
          medicineType: null
        },
        "33": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpFlowRateLimit"),
          value: null,
          medicineType: null
        },
        "34": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpOneshotSelection"),
          value: null,
          medicineType: null
        },
        "35": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpAutoOff"),
          value: null,
          medicineType: null
        },
        "36": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpAutoOffTiming"),
          value: null,
          medicineType: null
        },
        "37": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpMonitorOff"),
          value: null,
          medicineType: null
        },
        "38": {
          id: _.uniqueId("cond"),
          component: () =>
            import("@/components/indication/IndTreatCondIpMonitorOffTiming"),
          value: null,
          medicineType: null
        }
      },
      medicine: [
        {
          id: _.uniqueId("medicine"),
          cd: null,
          amount: null,
          timingCd: null,
          procedureCd: null,
          medicineType: null,
          comment: ""
        }
      ],
      /**
       * レコードデフォルトデータ
       */
      recordDefaultData: {},
      editTreatCondData:{},
      editMediCondData:[],
      treatStartDate: null,
      toDay: "",
      isEdit: false,
      isNew: true,
      bedList: null,
      bedCd: null,
      oldSelectedPatId: null
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("pat-info", ["selectedPat","selectedPatName", "selectedPatId"]),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
      getTheme: "getTheme",
      getStateUserAccountInfo: "getStateUserAccountInfo",
      getUserName: "getUserName"
    }),

    treatCondSetting() {
      const setting = this.treatMethod.find(item => {
        return item.treatmentCd === this.treatMethodCd;
      });

      return setting ? JSON.parse(setting.treatmentConditionSetting) : [];
    },
  },

  watch: {

    selectedPatId() {
      this.setInit()
      if(!this.oldSelectedPatId && this.selectedPatId)
      {
        this.retrieveMstData()
      }
      this.oldSelectedPatId = this.selectedPatId
    },

    treatMethodCd() {
      this.changeUseTreatCond()
    },

    treatCond: {
      handler(data) {
        this.setIndCondInfo(data);
      },
      deep: true
    },

    medicine(data) {
      this.setIndMediInfo(data);
    },
  },
  async created() {
    // 共通ローダー:表示開始
    this.setLoadingScreenMessage("処理中・・・");
    this.setLoadingScreenVisible(true);
    // 現在日付の取得
    let dt = new Date();
    let y = dt.getFullYear();
    let m = ("00" + (dt.getMonth()+1)).slice(-2);
    let d = ("00" + dt.getDate()).slice(-2);
    dt = y + "年" + m + "月" + d + "日";
    this.toDay = dt;

    // 治療方法セットのデフォルト値を取得
    await this.getDropDownData()
    await this.getDefaultRecordData()
    await this.retrieveMstData()
    await this.changeUseTreatCond()
    this.isEdit = this.isNew ? true : false;
    // 共通ローダー:表示終了
    this.setLoadingScreenVisible(false);
  },
  mounted() {
    this.oldSelectedPatId = this.selectedPatId;
  },

  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
    ...mapActions("mst-user", [
      "sendRequestAddNewPatUser",
      "setUserData",
    ]),
    ...mapActions("multi-modal", [
      "showUserMasterIdReset"
    ]),

    // dropDownを開いた時にデータに応じて表示枠を広げる
    addMaxContentStyle() {
      this.$nextTick(() => {
        document.getElementsByClassName("k-animation-container")[0].firstElementChild.style.width = "max-content";
        document.getElementsByClassName("k-animation-container")[0].firstElementChild.style.bottom = "0px";
      });
    },
    /**
     * @description 編集データを取得
     */
    async retrieveMstData() {
      // 新規追加の際に、それぞれの項目にデフォルト値を格納する
      let treatCond = JSON.parse(this.recordDefaultData.indCondInfo)
      let medicine = JSON.parse(this.recordDefaultData.indMediInfo)

      // 治療条件
      treatCond = _.mapObject(treatCond, (value, key) => {
            return {
              component: this.treatCond[key].component,
              value: value.value,
              medicineType: value.medicine_type ? value.medicine_type : null,
              ind_user_id: this.getStateUserAccountInfo.userId,
              upd_user_id: this.getStateUserAccountInfo.userId,
            };
          });
      this.treatCond = Object.assign({}, this.treatCond, treatCond)

      this.treatMethodCd = this.recordDefaultData.treatmentCd;

      // ベッドコード
      this.bedCd = this.recordDefaultData.bedCd;

      // 適用開始日の設定
      let dispDay = this.recordDefaultData.treatStartDate;
      dispDay = dispDay ? dispDay.slice(0 ,-4) + "-" + dispDay.slice(4 ,-2) + "-" + dispDay.slice(6) : "";
      this.treatStartDate = dispDay

      // 投与薬剤
      this.medicine = !medicine
        ? this.medicine
        : medicine.map(item => {
            return {
              id: _.uniqueId("medicine"),
              cd: item.cd,
              amount: item.amount,
              timingCd: item.timing_cd,
              procedureCd: item.procedure_cd,
              medicineType: item.medicine_type,
              comment: item.comment
            };
          });
    },

    /**
     * @description 治療条件変更
     * @param value 治療条件のオブジェクト
     */
    setIndCondInfo(value) {
      const indCondInfo = JSON.stringify(
        _.mapObject(value, o => {
          return {
            value: o.value,
            medicine_type: o.medicineType,
            ind_user_id: this.getStateUserAccountInfo.userId,
            upd_user_id: this.getStateUserAccountInfo.userId,
          };
        })
      );

      // 編集中マスタを更新
      this.editTreatCondData = indCondInfo;
      if (this.editTreatCondData.replace(/ /g,'') !== this.recordDefaultData.indCondInfo.replace(/ /g,''))
      {
        this.isEdit = true;
      }
    },

    /**
     * @description 投与薬剤変更
     * @param value 投与薬剤の配列
     */
    setIndMediInfo(value) {
      // 投与薬剤のcdがnullのものを医療材料の配列から外す
      value = value.filter(item => {
        return null !== item.cd;
      });
      const indMediInfo = JSON.stringify(
        value.map(item => {
          return {
            cd: item.cd,
            amount: item.amount,
            timing_cd: item.timingCd,
            procedure_cd: item.procedureCd,
            medicine_type: item.medicineType,
            comment: item.comment
          };
        })
      );

      this.editMediCondData = indMediInfo

      if (this.editMediCondData.replace(/ /g,'') !== this.recordDefaultData.indMediInfo.replace(/ /g,''))
      {
        this.isEdit = true;
      }
    },

    /**
     * @description 項目内容編集後コールバック
     * @param type  編集項目の種類
     * @param data  編集内容
     * @param id    内部識別キー
     */
    editItem(type, data, id) {
      let editIndex = null;
      switch (type) {
        case "cond":
          this.$set(this.treatCond[id], "value", data);
          break;
        case "medicine":
          editIndex = this.medicine.findIndex(item => {
            return item.id === id;
          });

          this.$set(this.medicine, editIndex, {
            ...this.medicine[editIndex],
            ...data
          });
          break;
        default:
          break;
      }
    },

    /**
     * @description 項目を配列にアペンド
     * @param type  追加項目の種類
     */
    addItem(type) {
      switch (type) {
        case "medicine":
          this.medicine.push({
            id: _.uniqueId("medicine"),
            cd: null,
            amount: null,
            timingCd: null,
            procedureCd: null,
            medicineType: null,
            comment: ""
          });
          break;
        default:
          break;
      }
    },

    /**
     * @description 項目を配列から削除
     * @param type  削除項目の種類
     * @param index 要素番号
     */
    deleteItem(type, index) {
      switch (type) {
        case "medicine":
          this.medicine.splice(index, 1);
          break;
        default:
          break;
      }
    },

    editUpdate(){
      this.isEdit = true;
    },
    // add #9311 v-model発効します 張博 start
    bedListChange(event){
    this.bedList = event.sender._old;
    },
    treatMethodChange(event){
    this.treatMethod = event.sender._old;
    },
    // add #9311 v-model発効します 張博 end
    async changeUseTreatCond(){
      // 治療方法による治療条件設定の可否チェック
      _.each(this.treatCond, (value, key) => {
        const settingItems = this.treatCondSetting
          ? _.flatten(
              this.treatCondSetting.map(item => {
                return item.items;
              })
            )
          : null;
        const setting = settingItems
          ? settingItems.find(item => {
              return item.ctl_no === key;
            })
          : null;
        const isUse = setting ? Number(setting.is_use) : 1;

        this.$set(this.treatCond[key], "isUse", isUse);

        if (!isUse) {
          this.$set(this.treatCond[key], "value", null);
        }
      });
      // 補液が編集不可の場合、未登録を格納
      0 === Number(this.treatCond["19"].isUse)
        ? this.$set(this.treatCond["19"], "value", null)
        : null;
      // 補液が未登録になった場合
      this.setTreatCondDefault("19", this.treatCond["19"].value);
    },
    /**
     * 治療条件情報値の変更
     * @description 編集コンポーネントの表示値と内部値の変更
     * @param id   内部識別キー
     * @param data 編集内容
     */
    setTreatCondValue(id, data) {
      // 編集コンポーネントの値格納
      this.$set(this.$refs[id][0].displayInputValue, "editValue", data);
      // 内部値の格納
      this.$set(this.treatCond[id], "value", data);
    },

    /**
     * 治療条件デフォルト値変換
     * @description
     * 治療方法変更時に補液、補液量、補液使用数、補液速度を変更
     * 抗凝固剤変更時に抗凝固剤ワンショット量、抗凝固剤持続速度、抗凝固剤持続総量を変更
     * @param id   内部識別キー
     * @param data 編集内容
     */
    setTreatCondDefault(id, data) {
      // デフォルト値格納先内部識別キー
      let idList = [];
      switch (Number(id)) {
        // 補液
        case 19:
          // 補液が未登録になった場合
          if (null === data) {
            // 補液量、補液使用数、補液速度が編集不可の場合、内部識別キーを格納
            idList =
              0 === Number(this.treatCond["20"].isUse) ? [20, 22, 24] : [];
          }
          break;

        // 抗凝固剤
        case 25:
          // 抗凝固剤が変更された時
          if (this.treatCond[id].value !== data) {
            // 抗凝固剤ワンショット量、抗凝固剤持続速度、抗凝固剤持続総量の内部識別キーを格納
            idList = [26, 27, 28];
          }
          break;

        // 異常値
        default:
          break;
      }
      // 格納された識別キー分ループ
      idList.forEach(index => {
        this.setTreatCondValue(
          String(index),
          this.getTreatCondDefaultValue(index)
        );
      });
    },

    async getDropDownData(){
      // 治療方法
      this.treatMethod = await treatment(this.facilityCd).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FacilityHomeDialysisComponent.vue', 'getDropDownData', error);
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw error;
      });
      //ベッドマスタ情報を取得
      const params = {
        facility_cd: this.facilityCd,
        is_disp: "1",
        is_del: "0"
      };
      const result = await ApiHelper.get("/mstInfo/mstBed", params).catch(
        () => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FacilityHomeDialysisComponent.vue', 'getDropDownData', 'ベッドマスタ取得失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          throw new Error("ベッドマスタ取得失敗");
        }
      );
      for (var i = result.data.length - 1; i >= 0; i--) {
        if (result.data[i].isHomeDialysis === "0")
          result.data.splice(i, 1)
      }
      this.bedList = result.data;
    },

    /**
     * デフォルト値を格納
     * @description
     */
    async getDefaultRecordData() {

      const d = {
        indCondInfo: `{"1": {"value": 0}, "2": {"value": null}, "3": {"value": null}, "4": {"value": 0}, "5": {"value": null}, "6": {"value": null}, "7": {"value": null}, "8": {"value": null}, "9": {"value": null}, "10": {"value": null}, "11": {"value": null}, "12": {"value": 0}, "13": {"value": null}, "14": {"value": 300}, "15": {"value": null}, "16": {"value": 0}, "17": {"value": 500}, "18": {"value": 36}, "19": {"value": null}, "20": {"value": 0}, "21": {"value": 0}, "22": {"value": 0}, "23": {"value": 36}, "24": {"value": 0}, "25": {"value": null}, "26": {"value": 0}, "27": {"value": 0}, "28": {"value": 0}, "29": {"value": 1}, "30": {"value": 1}, "31": {"value": 0}, "32": {"value": 0}, "33": {"value": 10}, "34": {"value": 1}, "35": {"value": 0}, "36": {"value": 0}, "37": {"value": 0}, "38": {"value": 0}}`,
        treatmentCd: "",
        treatStartDate: "",
        bedCd: "",
        indMediInfo: "[]"
      }

      //患者情報の取得
      if (this.selectedPatId)
      {
        const requestParam = {
          pat_id: this.selectedPatId,
        };
        const uri = "/pat_home_dialysis/getPatHhdPatternByPatId";
        const response = await ApiHelper.get(uri, requestParam).catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
          getErrorMessage('FacilityHomeDialysisComponent.vue', 'getDefaultRecordData', '取得失敗');
          //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
          throw new Error(
            `[OtherContactCardContent.vue]created(): 取得失敗
            エラー内容: ${error}`
          );
        });

        if(response.data.length > 0){
          d.indCondInfo = response.data[0].indCondInfo,
          d.treatmentCd = response.data[0].indTreatmentCd
          d.treatStartDate = response.data[0].indTreatStartDate
          d.bedCd = response.data[0].bedCd,
          d.indMediInfo = response.data[0].indMediInfo,
          this.isNew = false
        }else{
          this.isNew = true
        }
      }
      this.recordDefaultData = d;
    },

    /**
     * 治療条件のデフォルト値を取得
     * @param id 治療条件内部識別キー
     */
    getTreatCondDefaultValue(id) {
      let value = null;
      switch (Number(id)) {
        // 治療時間, IP使用選択, IPスタート
        case 1:
        case 29:
        case 30:
          value = 1;
          break;

        /**
         * 除水量制限, シングルニードル, 透析液流量,
         * 補液, 補液量, 補液選択, 補液使用数, 補液速度,
         * IPワンショット量, IPワンショットスタート, IP電源自動切り,
         * IP電源自動切り時間, IP電源OKモニタ切り,
         * IP電源OKモニタ切り時間
         */
        case 4:
        case 12:
        case 16:
        case 19:
        case 20:
        case 21:
        case 22:
        case 24:
        case 26:
        case 27:
        case 28:
        case 31:
        case 32:
        case 34:
        case 35:
        case 36:
        case 37:
        case 38:
          value = 0;
          break;

        // 血液流量
        case 14:
          value = 300;
          break;

        // 透析液流量
        case 17:
          value = 500;
          break;

        // 透析液温度, 補液温度
        case 18:
        case 23:
          value = 36;
          break;

        // IP速度最大値
        case 33:
          value = 10;
          break;

        default:
          break;
      }
      return value;
    },

    // 再描画処理
    async setInit(){
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      await this.getDropDownData()
      await this.getDefaultRecordData()
      await this.retrieveMstData()
      await this.changeUseTreatCond()
      this.isEdit = this.isNew ? true : false;
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },

    // 保存処理
    async saveRecord() {

      if(this.treatStartDate.length > 10 ){
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "適用開始日を正しく入力してください"
          title: DIALOG_MESSAGES['00200026'].title,
          message: messageFormat(DIALOG_MESSAGES['00200026'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }

      if(!this.selectedPatId){
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "更新失敗",
          // message: "患者を選択してください"
          title: DIALOG_MESSAGES[50000006].title,
          message: messageFormat(DIALOG_MESSAGES[50000006].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }

      let machineNo = ""
      if (this.bedCd) {
        this.bedList.some(item =>{
          if (item.bedCd == this.bedCd){
            machineNo = item.machineNo;
            return true;
          }
        });
      }

      const request = {
        patId: this.selectedPatId,
        facilityCd: this.facilityCd,
        indCondInfo: this.editTreatCondData,
        indMediInfo: this.editMediCondData,
        indTreatmentCd: this.treatMethodCd ? this.treatMethodCd : "",
        indTreatStartDate: this.treatStartDate ? this.treatStartDate.replace(/-/g,"") : "",
        bedCd: this.bedCd ? this.bedCd : "",
        machineNo: machineNo
      };

      const uri = "/pat_home_dialysis/insert";
      const response = await ApiHelper.put(uri, request).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
        getErrorMessage('FacilityHomeDialysisComponent.vue', 'saveRecord', '登録失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
        throw new Error(
          `[OtherContactCardContent.vue]登録失敗
          エラー内容: ${error}`
        );
      });

      const add = await this.dispModalAddUser();

      if (add === 0)
      {
        this.setInit();
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "更新完了",
          // message: "更新が完了しました。"
          title: DIALOG_MESSAGES['00100002'].title,
          message: messageFormat(DIALOG_MESSAGES['00100002'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
      }
      else if (add === 1)
      {
        this.setInit();
      }
      else if (add === -1)
      {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "更新失敗",
          // message: "更新が失敗しました。"
          title: DIALOG_MESSAGES['00200017'].title,
          message: messageFormat(DIALOG_MESSAGES['00200017'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
      }

      return response;
    },

    // ユーザ追加/モーダル表示
    async dispModalAddUser() {
      // 新規登録用のユーザデータを設定
      const userData = {
        userId: "",
        facilityCd: this.facilityCd,
        facilityName: "",
        administrator: 0,
        userName: this.selectedPatName,
        isProvisional: 1,
        failure_cnt: 0,
        dispUserId: "",
        userType: this.facilitylistValue === "nkknkk" ? 1 : 0,
        userLastName: this.selectedPat.pat_personal_main.pat_last_name,
        userFirstName: this.selectedPat.pat_personal_main.pat_first_name,
        userPassword: "",
        loginUrl: "",
        patId: this.selectedPatId
      };
      this.setUserData(userData);
      // 新規ユーザ登録
      const response = await this.sendRequestAddNewPatUser(userData);
      if (response === 1) {
        // モーダルを表示
        await this.showUserMasterIdReset();
      }
      return response;
    },

        // クリアボタン処理
    clear() {
      if (this.isEdit) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
          // title: "更新確認",
          title: DIALOG_MESSAGES[13000041].title,
          // message: "編集内容を破棄し、編集前の状態にしてもよろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000041].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer === 1) {
              this.setInit();
            }
          }
        });
      } else {
        this.setInit();
      }
    },
  },
};
</script>

<style scoped>
.layout-name-area,
.disp-item-name-area {
  padding-left: 8px;
  vertical-align: top;
}

.disp-item-no,
.k-textbox {
  width: 100%;
}

.disp-item-header{
  height: 5%;
}

.disp-item-content-area {
  overflow-y: scroll;
  height: 85%;
}

.disp-item-content-area ons-row {
  height: auto;
}

.disp-item-area {
  height: 100%;
  width: 100%;
  border-collapse: collapse;
}

.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr td:first-child {
  border: 1px solid lightgray;
  text-align: left;
  width: 25%;
}

.disp-item-area tr td:nth-child(2) {
  border: 1px solid lightgray;
  text-align: left;
}

.cond-title-style {
  color: #fafafa;
  background-color: #333333;
  text-align: left;
  padding: 5px;
  width: 185px;
  flex: 0 0 185px;
  max-width: 185px;
}

.cond-td-style {
  border: 1px solid var(--ntss-border-color);
}

.none-border-bot {
  border-bottom: 0px;
}

.none-border-top {
  border-top: 0px;
}

.cond-td-treat {
  padding-bottom: 4px;
}

.cond-td-padding {
  padding: 3px;
}

.cond-td-style > ons-row {
  padding: 10px;
  border: 1px solid var(--ntss-border-color);
}

.cond-del-style {
  max-width: 25px;
}

.cond-del-style > * {
  height: 100%;
}

.cond-disabled * {
  opacity: 0.5;
  pointer-events: none;
}

.cond-transition-enter-active {
  transition: opacity 0.5s, max-height 0.5s;
}

.cond-transition-enter {
  opacity: 0.5;
  max-height: 0px;
}
.bottom-buttons-div {
  margin: 0px 0px 0px auto;
  display: flex;
  align-items: center;
}
.bottom-buttons-label {
  white-space: nowrap;
  width: 5em;
  text-align: right;
  margin-right: 0.5em;
}
#bottom-buttons {
  width: 100%;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  justify-content: space-around;
  height: 10%;
}
.header-title-style{
  font-weight: 500;
  width: 35%;
}
.header-info-style{
  font-weight: 500;
  text-decoration: underline;
  text-align: right;
  width: 65%;
}
.facility-label-style{
  color: var(--all-label-color);
}
@media screen and (max-width: 480px) {
  .cond-title-style{
    width: 100%;
    flex: 0 0 100%;
    max-width: 100%;
  }
}
</style>
<style>
/* UPDATE レイアウト調整 楊zc  start */
.kendo-width-style{
  /* width: 50% !important;  */
  width: 24rem !important;
  font-size: 1.6em !important;
  box-sizing: content-box !important;
}
@media screen and (max-width: 480px) {
.kendo-width-style{
  /* width: 100% !important;  */
  width: 24rem !important;
  font-size: 1.6em !important;
  box-sizing: content-box !important;
  height: 1.4em !important;
}
}
/* UPDATE レイアウト調整 楊zc end */
</style>
