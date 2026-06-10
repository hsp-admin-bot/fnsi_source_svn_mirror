<template>
  <div>
    <table class="insurance-table">
      <thead>
        <tr>
          <th scope="col">主</th>
          <th scope="col">区分</th>
          <th scope="col">保険名 / 公費名 / セット名</th>
          <th scope="col">
            終了日
          </th>
          <th scope="col">
            当月確認
          </th>
          <th scope="col"></th>
        </tr>
      </thead>

      <draggable
        v-model="jsonArray"
        tag="tbody"
        v-bind="{
          animation: 200,
          delay: 10,
          disabled: !actionMode,
          forceFallback: true
        }"
        @update="onUpdate"
      >
        <!-- modify #11362 by kangjie 20241205 start        -->
<!--        <tr v-show="getDataFromJson(json, 'insu_name').initValue"-->
<!--            v-for="(json, index) in jsonArray"-->
<!--            :key="index">-->
        <tr
            v-for="(json, index) in jsonArray"
            :key="index">
          <!-- modify #11362 by kangjie 20241205 end        -->
          <td>
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <custom-radio -->
            <!--   :value="getDataFromJson(json, 'is_selected')" -->
            <!--   :disabled="editFlag" -->
            <!--   name="is_selected" -->
            <!--   radio-value="1" -->
            <!--   @change="changeSelected(json, index)" -->
            <!-- ></custom-radio> -->
            <custom-radio
              :value="getDataFromJson(json, 'is_selected')"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              name="is_selected"
              radio-value="1"
              @change="changeSelected(json, index)"
            ></custom-radio>
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
          </td>
          <td class="insu-class-name">{{ getInsuClassName(json) }}</td>
          <td class="title">
            {{ json.insu_class.editValue ==  3 ? json.insu_self_info.insu_self_name.initValue: json.insu_name.initValue  }}
          </td>
          <td>
            <span :style="{ color: getEndDate(json).color }">{{
              getEndDate(json).value
            }}</span>
          </td>
          <td>
            <span :style="{ color: getCheckDate(json).color }">{{
              getCheckDate(json).value
            }}</span>
          </td>
          <td class="tr-last">
            <v-ons-button
              v-if="getItemAuthorized('PatInfo', 'default_authority') && !getIsOtherFacility"
              class="common-style-select-button btn3-normal"
              @click="openEdit(json, index)"
            >編集</v-ons-button>
            <v-ons-button
              v-else
              class="common-style-select-button btn3-normal"
              @click="openEdit(json, index)"
            >詳細</v-ons-button>
            <button
              v-show="actionMode"
              class="button-delete ntss-btn-outset"
              @click="deleteRecord(json, index)"
              :disabled="!isOwnFacility"
            >
            <!-- mod FNSI-患者情報共有よりの改修 江 end -->
              <v-ons-icon icon="fa-trash"/>
            </button>
          </td>
        </tr>
      </draggable>
    </table>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import moment from "moment";
import { mapGetters, mapActions, mapMutations } from "vuex";
import { encodeEditableRecord, decodeEditableRecord } from '@/functions/PatInfoFunctions';
import { EventBus } from "@/eventBus.js";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';

const JSON_EMPTY = {
  editValue: null,
  initValue: null
};

export default {
  name: "InsuranceInfoCard",
  mixins: [baseCardContent],

  data() {
    return {
      // add 7778 limingyang start
      cardDiff: true,
      // add 7778 limingyang end
      isChanged: false,
      selectedInsuranceCd: 0,
      popOverInsuranceInfo: null
    };
  },
  // add 編集権限の適用 じょはく start
  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },
  // add 編集権限の適用 じょはく end
  computed: {
    // add 編集権限の適用 じょはく start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 じょはく end
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    // mod FNSI-患者情報共有よりの改修 江 start
    ...mapGetters("pat-info", ["selectedPatId", "isOwnFacility", "getIsOtherFacility", "getOtherFacilityCd"]),
    // mod FNSI-患者情報共有よりの改修 江 end
    ...mapGetters("pat-insurance", ["insuranceList", "reloadRequired", "isCreate"]),
    ...mapGetters("multi-modal", ["isModalOpened"]),

    jsonArray: {
      get() {
        return this.insuranceList;
      },
      set(sortedAry) {
        this.setInsuranceList(sortedAry);
      }
    },
  },
  async created() {
    this.init()
    EventBus.$off('reloadListInsurance', this.reloadData);
    EventBus.$on('reloadListInsurance', this.reloadData);
  },
  watch: {
    insuranceList: {
      handler (val) {
        const isEdited = val.some((item) => {
          return item.is_selected.editValue !== item.is_selected.initValue;
        })
        if (isEdited) {
          this.setEditedComponent(this.$options.name);
        } else {
          this.removeEditedComponent(this.$options.name);
        }
      },
      deep: true
    },
    reloadRequired(val) {
      if (val) {
        // モーダルで保存、削除成功時、load実行
        this.load();
        this.setReloadRequired(false);
      }
    },
    selectedPatId: {
      handler () {
        this.reloadData()
      },
      deep: true,
      immediate: true
    }
  },
  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    ...mapActions("pat-insurance", ["setInsuranceList", "setReloadRequired", "setIsCreate"]),
    ...mapActions("multi-modal", ["showInsuranceInfoAddEditModal"]),
    // 編集対象データのセット（InsuranceInfoAddEditModal が computed で参照する）
    ...mapMutations("pat-insurance", [
      "setSelectedInsuranceJson",
      "setSelectedInsuranceIndex",
      "setMstInsurance",
      "setPopOverInsuranceInfo"
    ]),

    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    async reloadData() {
      this.load();
      this.isChanged = false;
    },
    async load() {
      this.setLoadingScreenVisible(true);
      try {
        if (this.selectedPatId) {
	  // mod #12462 患者情報共有 Ji start
          // const resPatInsurance = await ApiHelper.get(`/patInfo/getPatInsuById/${this.selectedPatId}`);
          const facilityCd = this.getIsOtherFacility ? this.getOtherFacilityCd : this.facilityCd
          const resPatInsurance = await ApiHelper.get(`/patInfo/getPatInsuById/${this.selectedPatId}/${facilityCd}`);
	  // mod #12462 患者情報共有 Ji end
          if (resPatInsurance) {
            resPatInsurance.data = this.mappingTempalte(resPatInsurance.data);
            const encodeInsuranceInfo = resPatInsurance.data.map(item => {
              item.insu_info = JSON.parse(item.insu_info);
              item.insu_pub_info = JSON.parse(item.insu_pub_info);
              item.insu_set_info = JSON.parse(item.insu_set_info);
              item.insu_self_info = JSON.parse(item.insu_self_info);
              return encodeEditableRecord(item);
            });
            // mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
            // 「主」選択位置の保持
            if (this.isChanged) {
              for (let i = 0; i < encodeInsuranceInfo.length; i++) {
                if (encodeInsuranceInfo[i].insurance_cd.editValue == this.selectedInsuranceCd) {
                  encodeInsuranceInfo[i].is_selected.editValue = "1";
                } else {
                  encodeInsuranceInfo[i].is_selected.editValue = "0";
                }
              }
            }
            this.popOverInsuranceInfo = encodeInsuranceInfo;
            const listFilter = encodeInsuranceInfo.filter(item => {
              return item.is_del.initValue != "1" && item.is_disp.initValue != "0"
            })
            this.setInsuranceList(listFilter);
            // this.setInsuranceList(encodeInsuranceInfo);
            // mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
          }
        }
      } catch (error) {
        this.setLoadingScreenVisible(false);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('InsuranceInfoCardContent.vue', 'load', error);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        console.log(error);
      }
      this.setLoadingScreenVisible(false);
    },
    //mod 患者は保険データを更新していません。 張start
    async init(){
      this.setLoadingScreenVisible(true);
      
      // 保険マスタ取得
      const resMstInsurance = await ApiHelper.get("/master_maintenance/mst_insurance/data/", { facility_cd: this.facilityCd });
      this.mstInsurance = resMstInsurance.data.localDataSource.data.filter(item => +item.isDisp === 1);
      
      // InsuranceInfoAddEditModal が参照できるよう store にも反映
      this.setMstInsurance(this.mstInsurance);
      this.isChanged = false;
      
      this.setLoadingScreenVisible(false);
    },
    async restore() {
      let encodeInsuranceInfo = [];
      const resPatInsurance = await ApiHelper.get(`/patInfo/getPatInsuById/${this.selectedPatId}`);
      resPatInsurance.data = this.mappingTempalte(resPatInsurance.data);
      try {
        const insuranceInfo = resPatInsurance.data.map(item => {
          item.insu_info = JSON.parse(item.insu_info);
          item.insu_pub_info = JSON.parse(item.insu_pub_info);
          item.insu_set_info = JSON.parse(item.insu_set_info);
          item.insu_self_info = JSON.parse(item.insu_self_info);
          return encodeEditableRecord(item);
        });
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
        this.popOverInsuranceInfo = insuranceInfo;
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
        // 並び順の保持
        for (let i = 0; i < this.jsonArray.length; i++) {
          const result = insuranceInfo.find((item) => { return item.insurance_cd.editValue == this.jsonArray[i].insurance_cd.editValue })
          encodeInsuranceInfo.push(result);
        }
        // 「主」選択位置の保持
        if (this.isChanged) {
          for (let i = 0; i < encodeInsuranceInfo.length; i++) {
            if (encodeInsuranceInfo[i].insurance_cd.editValue == this.selectedInsuranceCd) {
              encodeInsuranceInfo[i].is_selected.editValue = "1";
            } else {
              encodeInsuranceInfo[i].is_selected.editValue = "0";
            }
          }
        }
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
        const listFilter = encodeInsuranceInfo.filter(item => {
          return item.is_del.initValue != "1" && item.is_disp.initValue != "0"
        })
        this.setInsuranceList(listFilter);
        // this.setInsuranceList(encodeInsuranceInfo);
        // mod #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
      } catch (error) {
        getErrorMessage('InsuranceInfoCardContent.vue', 'restore', error);
        console.log(error);
      }
    },
    onUpdate() {
      this.isChanged = true;
    },
    //mod 患者は保険データを更新していません。 張end
    // add FNSI-保険選択の変更 関 start
    getIsInsuranceChange() {
      return this.isChanged;
    },
    getIsInsuranceSelectCd() {
      return this.selectedInsuranceCd;
    },
    // add FNSI-保険選択の変更 関 end

    changeSelected(json, index) {
      // add FNSI-保険選択の変更 関 start
      this.isChanged = true;
      this.selectedInsuranceCd = json.insurance_cd.editValue;
      // add FNSI-保険選択の変更 関 start
      const findItem = this.jsonArray.find((js, i) => {
        return js.is_selected.editValue === "1" && index !== i;
      });
      if (findItem) {
        findItem.is_selected.editValue = "0";
      }
    },
    getDataFromJson(json, jsonKey) {
      if (!json) return JSON_EMPTY;
      return json[jsonKey];
    },

    getDateInfo(date) {
      if (!date) return null;
      const year = date.substring(0, 4);
      const month = date.substring(4, 6);
      const day = date.substring(6, 8);
      return {
        year: year,
        month: month,
        day: day
      };
    },
    getEndDate(index) {
      const date = this.getDataFromJson(index, "end_date").initValue;
      const f = this.getDateInfo(date);
      if (!f) {
        return {
          value: "",
          color: ""
        };
      }
      const endDate = `${f.year}/${f.month}/${f.day}`;
      const convertISOEndDate = `${f.year}-${f.month}-${f.day}`;
      const parseEndDate = moment(convertISOEndDate);
      if (moment().isAfter(parseEndDate, "day")) {
        return {
          value: endDate,
          color: "#d20404"
        };
      }
      return {
        value: endDate,
        color: ""
      };
    },
    getCheckDate(json) {
      const checkDate = this.getDataFromJson(json, "check_date").initValue;
      if (!checkDate) {
        return {
          value: "",
          color: ""
        };
      }
      const today = new Date();
      const currentMonth = today.getMonth() + 1;
      const inputMonth = this.getDateInfo(checkDate).month;
      if (currentMonth == inputMonth) {
        return {
          value: "済",
          color: ""
        };
      }
      return {
        value: "未",
        color: "#d20404"
      };
    },
    getInsuClassName(json) {
      const insuClass = this.getDataFromJson(json, "insu_class").initValue;
      if (insuClass === null || insuClass === undefined) {
        return null;
      }
      const insuClassList = {
        0: "保険",
        1: "公費",
        2: "セット",
        3: "自費"
      };
      return insuClassList[insuClass];
    },

    /** 項目追加処理 ＋ボタン押下 */
    addItem() {
      // 新規項目作成
      const length = this.jsonArray.length;
      let ctl_no = 0;
      let is_selected = "0";
      if (length > 0) {
        ctl_no = this.jsonArray[length-1].ctl_no.editValue + 1;
      }
      // #11601 保険情報を最初に登録した時に「主」にチェックを入れる start 
      else {
        is_selected = "1";
      }
      // #11601 保険情報を最初に登録した時に「主」にチェックを入れる end
      const newItem = {
        ctl_no: ctl_no,
        pat_id: this.selectedPatId,
        fn_pat_id: null,
        facility_cd: this.facilityCd,
        insu_class: 0,
        insu_name: null,
        insu_name_short: null,
        start_date: null,
        end_date: null,
        check_date: null,
        is_selected: is_selected,
        insu_info: {
          insu_no: null,
          insu_pat_name: null,
          insu_kbn: "0",
          insu_pat_mark: null,
          insu_pat_no: null,
          cki_class: "0",
          kki_class: "0",
          und_six: "0",
          "futan-g": null,
          "futan-n": null,
          insu_name: null,
          start_date: null,
          end_date: null,
          check_date: null,
          insu_name_short: null
        },
        insu_pub_info: {
          insu_pub_no: null,
          insu_pub_name: null,
          insu_pub_pat_no: null,
          insu_name: null,
          start_date: null,
          end_date: null,
          check_date: null,
          insu_name_short: null,
          passbook_no: null
        },
        insu_set_info: {
          insu_cd: null,
          insu_pub1_cd: null,
          insu_pub2_cd: null,
          insu_pub3_cd: null,
          insu_pub4_cd: null,
          insu_name: null,
          insu_name_short: null
        },
        insu_self_info: {
          insu_self_name: null
        },
        is_disp: "1",
        is_del: "0",
        reg_date: moment().format("YYYY-MM-DD HH:mm:ss"),
        up_date: moment().format("YYYY-MM-DD HH:mm:ss"),
        is_new: true,
        memo1: null,
        memo2: null
      };
      this.jsonArray.push(encodeEditableRecord(newItem));
      
      this.setIsCreate(true);
      const lastIndex = this.jsonArray.length - 1;
      this.openModal(this.jsonArray[lastIndex], lastIndex);
    },

    /**
     * 編集ボタン押下
     * 保険詳細モーダル表示
     */
    openEdit(json, index) {
      this.setIsCreate(false);
      this.openModal(json, index);
    },

    /**
     * モーダルを開く共通処理
     * store に編集対象データをセットしてから showInsuranceInfoAddEditModal() を呼ぶ
     */
    openModal(json, index) {
      this.setSelectedInsuranceJson(json);
      this.setSelectedInsuranceIndex(index);
      this.setPopOverInsuranceInfo(this.popOverInsuranceInfo);
      this.showInsuranceInfoAddEditModal();
    },

    async deleteRecord(json, index) {
      const answer = await this.$ons.notification.confirm({
        title: DIALOG_MESSAGES[13000111].title,
        message: messageFormat(DIALOG_MESSAGES[13000111].message),
      });
      if (answer === 1) {
        if (!json["is_new"]) {
          json.is_disp.editValue = "0";
          json.up_date.editValue = moment().format("YYYY-MM-DD HH:mm:ss");
          const decodeJsonArray = decodeEditableRecord(json);
          await ApiHelper.put(`/patInfo/bulkUpdatePatInsu`, [decodeJsonArray])
            .then(() => { this.load(); })
            .catch(() => {
              getErrorMessage('InsuranceInfoCardContent.vue', 'deleteRecord', "保険情報削除に失敗しました。");
            });
        } else {
          const list = [...this.jsonArray];
          list.splice(index, 1);
          this.setInsuranceList(list);
        }
      }
    },
    mappingTempalte(data) {
      if (data) {
       data.forEach(item => {
          const insu_info = JSON.parse(item.insu_info);
          const insu_pub_info = JSON.parse(item.insu_pub_info);
          const insu_set_info = JSON.parse(item.insu_set_info);
         // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
          let detailInsuIsDel = false;
          if (item.insu_class == 2) {
            const insurances = Object.keys(insu_set_info)
                .filter(key => key.endsWith('_cd') && insu_set_info[key] !== null && insu_set_info[key].editValue !== null)
                .map(key => +insu_set_info[key])
            detailInsuIsDel = data.some(item => {
              // modify #11362 by kangjie 202412009 start 削除したデータのフィルタリング
              // return insurances.includes(item.insurance_cd) && item.is_del == '1' && item.is_disp == '1'
              return insurances.includes(item.insurance_cd) && item.is_del == '0' && item.is_disp == '0'
              // modify #11362 by kangjie 202412009 end 削除したデータのフィルタリング
            })
          }
         // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
          switch (item.insu_class) {
            case 0:
              // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
              // modify #11362 by kangjie 20241205 start
              // 1.TypeError: Cannot read properties of null (reading 'includes')
              // 2.削除したデータのフィルタリング
              // item.insu_name = item.is_del == '1' && item.is_disp == '1' ?
              //   (!item.insu_name.includes("【削除済み】") ? "【削除済み】" + item.insu_name : item.insu_name)
              //   : item.insu_name;
              item.insu_name = item.is_del == '0' && item.is_disp == '0' ?
                (item.insu_name==null ? item.insu_name :
                  (!item.insu_name.includes("【削除済み】") ? "【削除済み】" + item.insu_name : item.insu_name))
                : item.insu_name;
              // modify #11362 by kangjie 20241205 end
              // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
              insu_info.insu_name = item.insu_name;
              insu_info.start_date = item.start_date;
              insu_info.end_date = item.end_date;
              insu_info.check_date = item.check_date;
              insu_info.insu_name_short = item.insu_name_short;
              item.insu_info = JSON.stringify(insu_info);

              insu_pub_info.insu_name = null;
              insu_pub_info.start_date = null;
              insu_pub_info.end_date = null;
              insu_pub_info.check_date = null;
              insu_pub_info.insu_name_short = null;
              item.insu_pub_info = JSON.stringify(insu_pub_info);

              insu_set_info.insu_name = null;
              insu_set_info.insu_name_short = null;
              item.insu_set_info = JSON.stringify(insu_set_info);
              break;
            case 1:
              insu_info.insu_name = null;
              insu_info.start_date = null;
              insu_info.end_date = null;
              insu_info.check_date = null;
              insu_info.insu_name_short = null;
              item.insu_info = JSON.stringify(insu_info);

              // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
              // modify #11362 by kangjie 20241205 start
              // 1.TypeError: Cannot read properties of null (reading 'includes')
              // 2.削除したデータのフィルタリング
              // item.insu_name = item.is_del == '1' && item.is_disp == '1' ?
              //     (!item.insu_name.includes("【削除済み】") ? "【削除済み】" + item.insu_name : item.insu_name)
              //     : item.insu_name;
              item.insu_name = item.is_del == '0' && item.is_disp == '0' ?
                (item.insu_name ==null ? item.insu_name :
                  (!item.insu_name.includes("【削除済み】") ? "【削除済み】" + item.insu_name : item.insu_name))
                : item.insu_name;
              // modify #11362 by kangjie 20241205 end
              // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
              insu_pub_info.insu_name = item.insu_name;
              insu_pub_info.start_date = item.start_date;
              insu_pub_info.end_date = item.end_date;
              insu_pub_info.check_date = item.check_date;
              insu_pub_info.insu_name_short = item.insu_name_short;
              item.insu_pub_info = JSON.stringify(insu_pub_info);

              insu_set_info.insu_name = null;
              insu_set_info.insu_name_short = null;
              item.insu_set_info = JSON.stringify(insu_set_info);
              break;
            case 2:
              insu_info.insu_name = null;
              insu_info.start_date = null;
              insu_info.end_date = null;
              insu_info.check_date = null;
              insu_info.insu_name_short = null;
              item.insu_info = JSON.stringify(insu_info);

              insu_pub_info.insu_name = null;
              insu_pub_info.start_date = null;
              insu_pub_info.end_date = null;
              insu_pub_info.check_date = null;
              insu_pub_info.insu_name_short = null;
              item.insu_pub_info = JSON.stringify(insu_pub_info);

              // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc start
              // modify #11362 by kangjie 20241205 start
              // 1.TypeError: Cannot read properties of null (reading 'includes')
              // item.insu_name = detailInsuIsDel ?
              //     (!item.insu_name.includes("【削除済みを含む】") ? "【削除済みを含む】" + item.insu_name : item.insu_name)
              //     : item.insu_name;
              item.insu_name = detailInsuIsDel ?
                (item.insu_name== null ? item.insu_name :
                  (!item.insu_name.includes("【削除済みを含む】") ? "【削除済みを含む】" + item.insu_name : item.insu_name))
                : item.insu_name;
              // modify #11362 by kangjie 20241205 end
              // add #10659 削除済み含むの接頭文字対応 ztc 20241025 ztc end
              insu_set_info.insu_name = item.insu_name;
              insu_set_info.insu_name_short = item.insu_name_short;
              item.insu_set_info = JSON.stringify(insu_set_info);
              break;
            default:
              insu_info.insu_name = null;
              insu_info.start_date = null;
              insu_info.end_date = null;
              insu_info.check_date = null;
              insu_info.insu_name_short = null;
              item.insu_info = JSON.stringify(insu_info);

              insu_pub_info.insu_name = null;
              insu_pub_info.start_date = null;
              insu_pub_info.end_date = null;
              insu_pub_info.check_date = null;
              insu_pub_info.insu_name_short = null;
              item.insu_pub_info = JSON.stringify(insu_pub_info);

              insu_set_info.insu_name = null;
              insu_set_info.insu_name_short = null;
              item.insu_set_info = JSON.stringify(insu_set_info);
              break;
          }
        });
        return data;
      }
    }
  },
  beforeDestroy() {
    EventBus.$off('reloadListInsurance', this.reloadData);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.card-table >>> textarea.custom-textarea {
  color: black !important;
}
</style>
<style lang="scss" scoped>
.insurance-table {
  border-collapse: collapse;
  width: 100%;
  th,
  td {
    border: solid 1px;
  }
  td:not(.title) {
    text-align: center;
  }
  td.title {
    padding-left: 0.5em;
    word-break: break-word;
    min-width: 5.5em;
  }
}
.body-table td {
  border-top: none;
}
.button-delete {
  position: absolute;
  top: 0;
  right: 0;
  height: 100%;
}
.tr-last {
  position: relative;
}
.insu-class-name {
  min-width: 2em;
}
</style>
