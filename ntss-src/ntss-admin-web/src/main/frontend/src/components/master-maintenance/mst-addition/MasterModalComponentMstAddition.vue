<template>
  <div>
    <div class="addition-info">
      <!-- 加算・管理料名 -->
      <v-ons-row class="wrapper">
        <v-ons-col class="item-title">加算・管理料名</v-ons-col>
        <v-ons-col class="item-data">
          <input 
            type="text" 
            id="addition-name" 
            :class="'input-required ' + handleJudgeEdited(mstAddition.addition_name, 'addition_name')" 
            v-model="mstAddition.addition_name" 
            :maxlength="256" 
            @input="closeInvalidCss"
            style="box-sizing: border-box; width: 100%;">
        </v-ons-col>
      </v-ons-row>
      <!-- 省略加算・管理料名 -->
      <v-ons-row class="wrapper">
        <v-ons-col class="item-title">省略加算・管理料名</v-ons-col>
        <v-ons-col class="item-data">
          <input 
            type="text" 
            :class="handleJudgeEdited(mstAddition.addition_short_name, 'addition_short_name')" 
            v-model="mstAddition.addition_short_name" 
            :maxlength="20" 
            style="box-sizing: border-box; width: 100%;">
        </v-ons-col>
      </v-ons-row>
      <!-- 加算種別 -->
      <v-ons-row class="wrapper">
        <v-ons-col class="item-title">加算種別</v-ons-col>
        <v-ons-col class="item-data addition-cat">
          <v-ons-select 
            :class="handleJudgeSelectEdited(mstAddition.addition_class, 'addition_class')" 
            v-model="mstAddition.addition_class" 
            @change="changeAdditionClass()">
            <option v-for="item in additionClassList" v-bind:key="item.cd" :value="item.cd">{{item.name}}</option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row>
      <!-- 算定タイミング -->
      <v-ons-row class="wrapper" v-if="mstAddition.addition_class == '12'">
        <v-ons-col class="item-title">算定タイミング</v-ons-col>
        <v-ons-col class="checkbox-area addition-kind">
          <label for="addition-kind" class="label checkbox-lable">
            <v-ons-checkbox
              id="addition-kind"
              v-model="additionKindFlg"
              class="input-checkbox"
              style="padding-left: 5px;"
            />
            <span>自動算定</span>
          </label>
        </v-ons-col>
      </v-ons-row>
      <!-- 算定回数 -->
      <v-ons-row class="wrapper caculation" v-if="isDispNumberOfCalculations">
        <v-ons-col class="item-title">算定回数</v-ons-col>
        <v-ons-row style="flex: 1;">
          <v-ons-col class="item-data radio-btn">
            <v-ons-radio
              v-model="mstAddition.addition_span"
              :value="'3'"
              input-id="show-display"
              modifier="round"
              @change="changeAdditionSpan('3')"
            />
            <label for="show-display">毎回</label>
          </v-ons-col>
          <v-ons-col class="item-data radio-btn">
            <v-ons-radio
              v-model="mstAddition.addition_span"
              :value="'1'"
              input-id="show-simple-display"
              modifier="round"
              @change="changeAdditionSpan('1')"
            />
            <label for="show-simple-display">週１回</label>
          </v-ons-col>
          <v-ons-col class="item-data radio-btn">
            <v-ons-radio
              v-model="mstAddition.addition_span"
              :value="'0'"
              input-id="show-details-display"
              modifier="round"
              @change="changeAdditionSpan('0')"
            />
            <label for="show-details-display">月１回</label>
          </v-ons-col>
          <!-- 加算・管理料マスタ：加算マスタ詳細-算定回数 2023-06-29 start  -->
          <!-- mod #9744 汎用以外でも「期限」が選択できてしまう 20230904 zhaoqi start  -->
          <v-ons-col class="item-data radio-btn"  v-if="mstAddition.addition_class == '12'">
          <!-- mod #9744 汎用以外でも「期限」が選択できてしまう 20230904 zhaoqi end  -->
          <!-- 加算・管理料マスタ：加算マスタ詳細-算定回数 2023-06-29 end  -->
            <v-ons-radio
              v-model="mstAddition.addition_span"
              :value="'4'"
              input-id="chk-deadline"
              modifier="round"
              @change="changeAdditionSpan('4')"
            />
            <label for="chk-deadline">期限</label>
          </v-ons-col>
        </v-ons-row>
       </v-ons-row>
      <!-- 算定回（月１） -->
      <v-ons-row class="wrapper" v-if="(mstAddition.addition_span == '0' && isDispNumberOfCalculations) || mstAddition.addition_class == '13'">
        <v-ons-col class="item-title">算定回（月１）</v-ons-col>
        <v-ons-row style="flex: 1; align-items: center;">
          <v-ons-col class="item-data radio-btn mst_addition_item width-fit">
            <v-ons-radio
              v-model="mstAddition.addition_limit_type"
              :value="'0'"
              input-id="beginning-of-the month"
              modifier="round"
            />
            <label for="beginning-of-the month">月初めの治療</label>
          </v-ons-col>
          <v-ons-col class="item-data radio-btn mst_addition_item width-fit">
            <v-ons-radio
              v-model="mstAddition.addition_limit_type"
              :value="'1'"
              input-id="first"
              modifier="round"
              @change="setEditAddCnt1($event.target.value)"
            />
            <label for="first" class="margin-0">第</label>
            <custom-input-number
              :value="mstAddition.add_cnt1"
              id="add-cnt1-month"
              :max-value="99"
              :min-value="1"
              :decimal-digits="0"
              :digits="2"
              :class="'input-required'"
              style="width: 50px"
            />
            <label>回目の治療</label>
          </v-ons-col>
          <v-ons-col class="item-data radio-btn mst_addition_item width-fit">
            <v-ons-radio
              :input-id="'radio-add-cnt-2'"
              v-model="mstAddition.addition_limit_type"
              :value="'2'"
              modifier="round"
            />
            <label for="radio-add-cnt-2">月最終の治療</label>
          </v-ons-col>
        </v-ons-row>
      </v-ons-row>
      <!-- 算定回（週１） -->
      <v-ons-row class="wrapper" v-if="mstAddition.addition_span == '1' && isDispNumberOfCalculations">
        <v-ons-col class="item-title">算定回（週１）</v-ons-col>
        <v-ons-row style="flex: 1; align-items: center;">
          <v-ons-col class="item-data radio-btn mst_addition_item width-fit">
            <v-ons-radio
              v-model="mstAddition.addition_limit_type"
              :value="'0'"
              input-id="early-translucency"
              modifier="round"
            />
            <label for="early-translucency">週初めの治療</label>
          </v-ons-col>
          <v-ons-col class="item-data radio-btn mst_addition_item width-fit">
            <v-ons-radio
              v-model="mstAddition.addition_limit_type"
              :value="'1'"
              input-id="first-early"
              modifier="round"
              @change="setEditAddCnt1($event.target.value)"
            />
            <label for="first-early" class="margin-0">第</label>
            <custom-input-number
              :value="mstAddition.add_cnt1"
              id="add-cnt1-week"
              :max-value="99"
              :min-value="1"
              :decimal-digits="0"
              :digits="2"
              :class="'input-required'"
              style="width: 50px"
            />
            <label>回目の治療</label>
          </v-ons-col>
          <v-ons-col class="item-data radio-btn mst_addition_item width-fit">
            <v-ons-radio
              v-model="mstAddition.addition_limit_type"
              :value="'2'"
              input-id="dialysis-end-week"
              modifier="round"
            />
            <label for="dialysis-end-week">週最終の治療</label>
          </v-ons-col>
        </v-ons-row>
      </v-ons-row>
      <!-- 算定回数上限 -->
      <v-ons-row class="wrapper" v-if="isDispNumberOfCalculations">
        <v-ons-col class="item-title">算定回数上限</v-ons-col>
        <v-ons-col class="item-data radio-btn mst_addition_item" v-if="mstAddition.addition_class == '12' && mstAddition.addition_span === '4'">
          <span>指定日から</span>
          <custom-input-number
            :value="mstAddition.addition_limit"
            :max-value="99"
            :min-value="1"
            :decimal-digits="0"
            :digits="2"
            style="width: 50px"
          />
          <span>日まで</span>
        </v-ons-col>
        <v-ons-col class="item-data radio-btn mst_addition_item" v-else>
          <custom-input-number
            input-id="addition-limit"
            :value="mstAddition.addition_limit"
            :max-value="99"
            :min-value="1"
            :decimal-digits="0"
            :digits="2"
            :disabled="isDisableAdditionLimit"
            style="width: 50px"
          />
          <span style="padding-left: 0.5em;">回／月</span>
        </v-ons-col>
      </v-ons-row>
      <!-- 算定治療時間 -->
      <v-ons-row class="wrapper" v-if="mstAddition.addition_class == '5'">
        <v-ons-col class="item-title">算定治療時間</v-ons-col>
        <v-ons-col class="item-data radio-btn mst_addition_item" style="display: flex;">
          <custom-input-time-special
            :value="mstAddition.addition_dialysis_time"
            :defaultValue="''"
          />
          <span style="padding-left: 0.5em;">以上</span>
        </v-ons-col>
      </v-ons-row>
      <!-- 連携コード -->
      <v-ons-row class="wrapper hospital-code">
        <v-ons-col class="item-title">連携コード1</v-ons-col>
        <v-ons-col class="item-data">
          <input 
            type="text" 
            maxlength="20" 
            name="in-hospital-cd-1" 
            id="in-hospital-cd-1" 
            :class="handleJudgeEdited(mstAddition.in_hospital_cd1, 'in_hospital_cd1')" 
            v-model="mstAddition.in_hospital_cd1">
        </v-ons-col>
        <v-ons-col class="item-title">連携コード2</v-ons-col>
        <v-ons-col class="item-data">
          <input 
            type="text" 
            maxlength="20" 
            name="in-hospital-cd-2" 
            id="in-hospital-cd-2" 
            :class="handleJudgeEdited(mstAddition.in_hospital_cd2, 'in_hospital_cd2')" 
            v-model="mstAddition.in_hospital_cd2">
        </v-ons-col>
        <v-ons-col class="item-title">連携コード3</v-ons-col>
        <v-ons-col class="item-data">
          <input 
            type="text" 
            maxlength="20" 
            name="in-hospital-cd-3" 
            id="in-hospital-cd-3" 
            :class="handleJudgeEdited(mstAddition.in_hospital_cd3, 'in_hospital_cd3')" 
            v-model="mstAddition.in_hospital_cd3">
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-row class="target-row" v-if="['2', '3', '4', '6', '7'].includes(mstAddition.addition_class)">
      <v-ons-col class="list-main-title">
        <v-ons-col>対象指定</v-ons-col>
        <v-ons-col>
          <v-ons-button
            class="item-button btn3-normal"
            @click="addNewDropDown()"
          >
            追加
          </v-ons-button>
        </v-ons-col>
      </v-ons-col>
      <v-ons-col class="item-data data-table">
        <div>
          <table class="ntss-list sticky_table" style="position: relative; table-layout: fixed;">
            <thead display="block">
            <tr>
              <th class="ntss-list-header-th-sticky color-header">
                {{listTitle(mstAddition.addition_class)}}
              </th>
              <th class="ntss-list-header-th-sticky list-header-delete color-header"/>
            </tr>
            </thead>
            <tr v-for="(tarItem, index) in selectTargetItem" :key="index">
              <!-- 選択肢 -->
              <td class="ntss-list-body-td ntss-list-body-td-background">
                <template v-if="mstAddition.addition_class === '3'">
                  <kendo-dropdownlist
                    :value="tarItem"
                    style="width: 100% !important;"
                    :data-source="mstDisease"
                    data-text-field="name"
                    data-value-field="cd"
                    :virtual-value-mapper="diseaseValueMapperFunc"
                    @select="(e) => { diseaseSelect(e.dataItem.cd, index) }"
                  />
                </template>
                <!--  add/ #12498 /加算マスタの種別：指定薬剤実施連動で特定の薬剤を選択するとエラーが発生 tianqidong start-->
                <select v-else ref="selectRef" style="width: 100% !important;" @change="createJsonByExamCd($event.target.value, index),changeButton()">
                  <option
                    :title="item.name"
                    v-for="item in getTargetListByTarItem(tarItem)"
                    :key="item.cd"
                    :value="item.cd"
                    :selected="tarItem == item.cd?true:false">
                    <!-- add/ #12498 プルダウンui幅異常  tianqidong start-->
                    <!--{{item.name}}-->
                    {{ truncateTextDynamic(item.displayName) }}
                    <!-- add/#12498 プルダウンui幅異常 tianqidong end-->
                  </option>
                  <!--  add/ #12498 /加算マスタの種別：指定薬剤実施連動で特定の薬剤を選択するとエラーが発生 tianqidong end--> 
                </select>
              </td>
              <!-- 削除 -->
              <td class="ntss-list-body-td ntss-list-body-td-background">
                <button class="ntss-btn-outset button-delete" @click="deleteDropDown(index)">
                  <v-ons-icon icon="fa-trash"/>
                </button>
              </td>
            </tr>
          </table>
        </div>
      </v-ons-col>
    </v-ons-row>
    <div v-if="messageDialogInfo.isDialogVisible">
      <message-dialog
        :visible.sync="messageDialogInfo.isDialogVisible"
        :message-cd="messageDialogInfo.messageCd"
        :type="messageDialogInfo.type"
        :string-params="messageDialogInfo.stringParams"
        @confirm="confirm"
      />
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// FNSI-修正 マスタ削除の対応 楊 add start
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
import {EventBus} from "@/eventBus";
// FNSI-修正 マスタ削除の対応 楊 add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber"
import customInputTimeSpecial from "@/components/common/custom-form-tags/CustomInputTimeSpecial";

export class MstAddition {

  /* 加算・管理料名 */
  addition_name;

  /* 加算略称 */
  addition_short_name;

  /* 算定タイミング */
  addition_kind;

  /* 加算種別 */
  addition_class;

  /* 算定回数 */
  addition_span;

  /* 算定回数上限 */
  addition_limit;

  /*  */
  addition_limit_type

  /* 算定回（月１） */
  add_cnt1;

  /* 算定条件 (算定対象コード)*/
  addition_tar_cd;

  /* 算定治療時間 */
  addition_dialysis_time;

  /* 連携コード1 */
  in_hospital_cd1;

  /* 連携コード2 */
  in_hospital_cd2;

  /* 連携コード3 */
  in_hospital_cd3;

}

export default {
  name: "MstAddition",
  components: {
    "message-dialog": messageDialog,
    "custom-input-number": customInputNumber,
    "custom-input-time-special": customInputTimeSpecial
  },
  data() {
    return {
      //mod マスタ詳細画面がありません破棄メッセージ
      initMstAddition:"",
      mstAddition: {
        // 加算・管理料名
        addition_name: '',
        // 加算・管理料名
        addition_short_name: '',
        // 算定タイミング
        addition_kind: '2',
        // 加算種別
        addition_class: '0',
        // 算定間隔
        addition_span: '3',
        // 算定回数上限
        addition_limit: { initValue: null, editValue: null },
        // 算定回数上限型式
        addition_limit_type: '1',
        // 算定回（週１）・算定回（月１）
        add_cnt1: { initValue: null, editValue: null },
        // 算定対象
        addition_cond: '',
        // 算定条件
        addition_target_cd: [],
        // 算定治療時間
        addition_dialysis_time: { initValue: "", editValue: "" },
        // 連携コード1
        in_hospital_cd1: '',
        // 連携コード2
        in_hospital_cd2: '',
        // 連携コード3
        in_hospital_cd3: '',
      },
      additionKindFlg: false,
      targetCheck: 0,
      targetList : [],
      // 透析困難コメント
      mstDialysisDifficulty: [{ cd: 0, name: "" }],
      // 病名
      mstDisease:[{ cd: 0, name: "" }],
      // 薬剤
      mstMedicine: [{ cd: 0, name: "" }],
      // 患者イベント
      mstPatEventSubCategory: [{cd: 0, name: ""}],
      // 治療方法
      mstTreatment: [{cd: 0, name: ""}],

      selectTargetItem: [],
      // ドロップダウンを選択した際のデータ
      selectedOrder: 0,
      // 検査セット作成用
      ExamItemInfo: [],

      /* 加算種別 */
      // mod #9936 加算種別の選択肢の並び順がバラバラである dou start
      // additionClassList: [
      //   { cd: "12", name:  "汎用" },
      //   { cd: "1",  name:  "透析液水質確保加算" },
      //   { cd: "2",  name:  "障害者加算" },
      //   { cd: "3",  name:  "指定病名連動" },
      //   { cd: "4",  name:  "指定治療方法加算" },
      //   { cd: "5",  name:  "長時間加算" },
      //   { cd: "6",  name:  "指定薬剤実施連動" },
      //   { cd: "7",  name:  "指定患者イベント連動" },
      //   { cd: "8",  name:  "検査依頼連動" },
      //   { cd: "9",  name:  "導入期加算" },
      //   { cd: "10", name:  "休日加算" },
      //   { cd: "11", name:  "時間外加算" },
      //   { cd: "13", name:  "慢性維持透析患者外来医学管理料" }
      // ],
      additionClassList: [
        { cd: "12", name:  "汎用" },
        { cd: "1",  name:  "透析液水質確保加算" },
        { cd: "10", name:  "休日加算" },
        { cd: "2",  name:  "障害者等加算" },
        { cd: "9",  name:  "導入期加算" },
        { cd: "11", name:  "時間外加算" },
        { cd: "5",  name:  "長時間加算" },
        { cd: "13", name:  "慢性維持透析患者外来医学管理料" },
        { cd: "3",  name:  "指定病名連動" },
        { cd: "4",  name:  "指定治療方法連動" },
        { cd: "7",  name:  "指定患者イベント連動" },
        { cd: "8",  name:  "検査依頼連動" },
        { cd: "6",  name:  "指定薬剤実施連動" }
      ],
      // mod #9936 加算種別の選択肢の並び順がバラバラである dou end

      // メッセージダイアログ
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: "",
        type: "1",
        stringParams: [""]
      }
    };
  },

  /**
   *
   */
  computed: {
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      getMasterRecordList: "getMasterRecordList",
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize"
    }),
    /**
     * 算定回数、算定回、算定回数上限の表示フラグ
     * 以下の条件の際に表示する カッコ内はmstAddition.addition_classの値
     * ・汎用(12) かつ 自動算定
     * ・障害者加算(2)
     * ・指定病名連動(3)
     * ・指定治療方法加算(4)
     * ・指定薬剤実施連動(6)
     * ・指定患者イベント連動(7)
     * ・検査依頼連動(8)
     */
    isDispNumberOfCalculations() {
      if (this.mstAddition.addition_class == '12' && this.additionKindFlg) {
        return true;
      }
      if (['2', '3', '4', '6', '7', '8'].includes(this.mstAddition.addition_class)) {
        return true;
      }
      return false;
    },

    /**
     * 算定回数上限の非表示フラグ
     * 算定回数が月１の場合非表示
     */
    isDisableAdditionLimit() {
      return this.mstAddition.addition_span === '0';
    }
  },

  /**
   *
   */
  watch: {
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    mstAddition:{
      handler(){
           if (this.mstAddition.addition_short_name === "") {
               this.mstAddition.addition_short_name = null
           }
            if (this.mstAddition.in_hospital_cd1 === "") {
               this.mstAddition.in_hospital_cd1 = null
           }
            if (this.mstAddition.in_hospital_cd2 === "") {
               this.mstAddition.in_hospital_cd2 = null
           }
            if (this.mstAddition.in_hospital_cd3 === "") {
               this.mstAddition.in_hospital_cd3 = null
           }
           if (JSON.stringify(this.mstAddition) !== JSON.stringify(this.initMstAddition)) {
             this.changeButton();
           }else{
             EventBus.$emit("mstHolidayRegistered", true);
           }
      },
      deep:true
    },
    //add/ #12498 プルダウンui幅異常  tianqidong start
    'mstAddition.addition_class'(newVal) {
      if (newVal !== '3') {
        this.$nextTick(() => {
          this.updateTruncatedTexts();
        });
      }
    },
    //add/#12498 プルダウンui幅異常 tianqidong end
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    windowHeight() {
      this.calculateListHeight();
    },
    windowWidth() {
      this.calculateListHeight();
    },
    getFontSize() {
      this.calculateListHeight();
    },
    /* 算定回数を監視 */
    "mstAddition.addition_span": {
      handler() {
        this.$nextTick(() => {
          // NOTE: 週1回、月１回変更時に高さが変化するため、再計算
          this.calculateListHeight();
        });
      }
    },
    /**
     * 算定タイミング「自動算定」
     */
    additionKindFlg(newVal) {
      // 自動算定ON(自動)：'1'、OFF(手動)：'2'
      const nextKind = newVal ? '1' : '2';

      // 現在値と違う場合は代入（同じ値の場合に再代入しない）
      if (this.mstAddition.addition_kind !== nextKind) {
        this.mstAddition.addition_kind = nextKind;
      }
    },
  },

  /**
   *
   */
  async created() {
    //add/ #12498 プルダウンui幅異常  tianqidong start
    EventBus.$on( "onResize", this.onResize);
    //add/#12498 プルダウンui幅異常 tianqidong end
    /* mod #8592 by zhangruixue 2023-05-18 --start */
    this.setLoadingScreenMessage("処理中・・・");
    this.setLoadingScreenVisible(true);
    /* mod #8592 by zhangruixue 2023-05-18 --end */

    // 施設コードを抽出条件に追加
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // const requestParam = { facilityCd: this.getFacilityCd };
    const requestParam = { facilityCd: this.getFacilitySwitch };
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    await Promise.all([
      // 透析困難コメント
      ApiHelper.get("/mstInfo/mstDialysisDifficulty", requestParam).then(response => {
        if(response.data) {
          response.data.forEach(element => {
            this.mstDialysisDifficulty.push({
              cd: element.dialysisDifficultyCd,
              name: element.dialysisDifficultyName,
              deleted: element.isDel === "1" || element.isDisp === "0"
            });
          });
        }
      }),
      // 病名
      ApiHelper.get("/mstInfo/mstDiseaseIncludeDeleted", requestParam).then(response => {
        if(response.data) {
          response.data.forEach(element => {
            this.mstDisease.push({
              // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start
              // cd: element.diseaseCd,
              // name: element.isDel === "1" || element.isDisp === "0" ? MASTER_DELETE_DISPLAY.DELETED + element.diseaseName : element.diseaseName,
              // deleted: element.isDel === "1" || element.isDisp === "0"
              cd: element.cd,
              name: element.flg === "0" ? MASTER_DELETE_DISPLAY.DELETED + element.nm : element.nm,
              deleted: element.flg === "0"
              // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end
            });
          });
        }
      }),
      // 治療方法
      ApiHelper.get("/mstInfo/mstTreatmentIncludeDeleted", requestParam).then(response => {
        if(response.data) {
          response.data.forEach(element => {
            this.mstTreatment.push({
              cd: element.treatmentCd,
              name: element.isDel === "1" || element.isDisp === "0" ? MASTER_DELETE_DISPLAY.DELETED + element.treatmentName : element.treatmentName,
              deleted: element.isDel === "1" || element.isDisp === "0"
            });
          });
        }
      }),
      // 薬剤
      ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", requestParam).then(response => {
        if(response.data) {
          response.data.forEach(element => {
            this.mstMedicine.push({
              cd: element.medicineCd,
              name: element.isDel === "1" || element.isDisp === "0" ? MASTER_DELETE_DISPLAY.DELETED + element.medicineName : element.medicineName,
              deleted: element.isDel === "1" || element.isDisp === "0"
            });
          });
        }
      }),
      // 患者イベント
      ApiHelper.get("/mstInfo/mstPatEventSubCategoryIncludeDeleted", requestParam).then(response => {
        if(response.data) {
          response.data.forEach(element => {
            this.mstPatEventSubCategory.push({
              cd: element.subCategoryCd,
              name: element.isDel === "1" || element.isDisp === "0" ? MASTER_DELETE_DISPLAY.DELETED + element.subCategoryName : element.subCategoryName,
              deleted: element.isDel === "1" || element.isDisp === "0"
            });
          });
        }
      })
    ])
    .catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      getErrorMessage('MasterModalComponentMstAddition.vue', 'Promise.all', error);
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      throw error;
    });

    // Fill record's data to modal
    for (const key in this.editRecord) {
      if(this.editRecord[key] !== undefined) {
        // 算定順番、算定回数上限、算定治療時間
        if (["addCnt1", "additionLimit", "additionDialysisTime"].includes(key)) {
          this.mstAddition[this.splitWords(key)].initValue = this.mstAddition[this.splitWords(key)].editValue = this.editRecord[key];
        } else {
          this.mstAddition[this.splitWords(key)] = this.editRecord[key];
        }
      }
    }

    this.changeAdditionClass();
    // 算定条件
    if(this.mstAddition['addition_tar_cd']) {
      let tarList = JSON.parse(this.mstAddition['addition_tar_cd']);
      if(tarList) {
        tarList.forEach(element => {
          this.selectTargetItem.push(element.cd);
          this.ExamItemInfo.push({
            id: element.cd,
            name: element.name
          });
        });
      }
    }
    // 算定タイミング
    this.additionKindFlg = this.mstAddition.addition_kind == '2' ? false : true;
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    this.initMstAddition=JSON.parse(JSON.stringify(this.mstAddition));
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    // 高さを計算する
    this.$nextTick(() => {
      this.calculateListHeight();
    });

    this.setLoadingScreenVisible(false);
  },

  /**
   *
   */
  mounted() {
    //add/ #12498 プルダウンui幅異常  tianqidong start
    window.addEventListener('resize',this.onResize)
    //add/#12498 プルダウンui幅異常 tianqidong end
     //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);

    // del #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 start
    // 高さを計算する
    // this.$nextTick(() => {
    //   this.calculateListHeight();
    // });
    // del #9863 加算マスタ詳細を開くとtypeエラーが発生する 蔡 end
  },
  //add/ #12498 プルダウンui幅異常  tianqidong start
  beforeDestroy(){
    window.removeEventListener('resize',this.onResize)
    EventBus.$off( "onResize", null);
  },
  //add/#12498 プルダウンui幅異常 tianqidong end
  /**
   *
   */
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),

    ...mapActions("loading-screen", ["setLoadingScreenVisible", "setLoadingScreenMessage"]),

    // add start #9482
    diseaseValueMapperFunc (options) {
      const indexArr = [];
      this.mstDisease.forEach((item, index) => {
        if (options.value === item.cd) {
          indexArr.push(index);
        }
      });
      options.success(indexArr);
    },
    // add end #9482

    closeInvalidCss(event) {
      event.target.classList.remove("input-invalid")
    },

    getValueByField(field) {
      return this.editRecord[field];
    },

    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    /**
     * 入力データの検証チェック
     */
    validateData() {
      return {
        additionNameValid: this.mstAddition.addition_name !== null
          && this.mstAddition.addition_name !== ""
          && this.mstAddition.addition_name !== undefined,
        additionClass: this.mstAddition.addition_class !== "0"
          && this.mstAddition.addition_class !== "",
        add_cnt1_week: !(this.isDispNumberOfCalculations && this.mstAddition.addition_span === "1"
          && this.mstAddition.addition_limit_type === '1' && this.mstAddition.add_cnt1.editValue === null),
        add_cnt1_month: !(this.isDispNumberOfCalculations && this.mstAddition.addition_span === "0"
          && this.mstAddition.addition_limit_type === '1' && this.mstAddition.add_cnt1.editValue === null)
      }
    },

    /**
     * 入力データの検証チェック
     */
    validateOnRegistration(){
      this.saveMasterRecord();
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      if (!validationResult.additionNameValid) {
        document.getElementById("addition-name")?.classList?.add("input-invalid");
      }
      if (!validationResult.add_cnt1_week) {
        document.getElementById("add-cnt1-week")?.classList?.add("input-invalid");
      }
      if (!validationResult.add_cnt1_month) {
        document.getElementById("add-cnt1-month")?.classList?.add("input-invalid");
      }
      // メッセージ組み立て
      let message = "";
      message = `
          ${
            //加算・管理料名 必須入力チェック
            !validationResult.additionNameValid
              // ? : "{$1}は必須入力項目です。\n必ず値を入力してください。"
              ? messageFormat(DIALOG_MESSAGES[22010001].message, "加算・管理料名") : ""
          }
        `;
      let lineBreak = "";
      lineBreak = message ? "<br>": "";
      message = message + `
          ${
            //加算種別 必須入力チェック
            !validationResult.additionClass
              // ? : "{$1}は必須入力項目です。\n必ず値を入力してください。"
              ? lineBreak + messageFormat(DIALOG_MESSAGES[22010001].message, "加算種別") : ""
          }
        `;
      lineBreak = message ? "<br>": "";
      message = message + `
          ${
            //算定回(週1)治療回数 必須入力チェック
            !validationResult.add_cnt1_week
              // ? : "{$1}は必須入力項目です。\n必ず値を入力してください。"
              ? lineBreak + messageFormat(DIALOG_MESSAGES[22010001].message, "算定回(週1)治療回数") : ""
          }
        `;
      lineBreak = message ? "<br>": "";
      message = message + `
          ${
            //算定回(月1)治療回数 必須入力チェック
            !validationResult.add_cnt1_month
              // ? : "{$1}は必須入力項目です。\n必ず値を入力してください。"
              ? lineBreak + messageFormat(DIALOG_MESSAGES[22010001].message, "算定回(月1)治療回数") : ""
          }
        `;

      const { title } = DIALOG_MESSAGES[22010001];
      // ダイアログ表示
      this.$ons.notification.alert({
        title,
        message: message
      });

      return false;
    },
    //[確認]ボタンの状態の変更をトリガーします
     changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     * 入力データの検証チェック
     */
    saveMasterRecord(){

      this.columnDefinition.forEach(element => {

        switch (element.field) {
          // 施設コード
          case "facilityCd":
            // mod マスタ一覧 1･施設切替を可能とする 孔s start
            // this.updateEditRecord("facilityCd",this.getFacilityCd);
            this.updateEditRecord("facilityCd",this.getFacilitySwitch);
            // mod マスタ一覧 1･施設切替を可能とする 孔s end
            break;
          // 加算・管理料名
          case "additionName":
            this.updateEditRecord("additionName",this.mstAddition.addition_name);
            break;
          // 加算略称
          case "additionShortName":
            this.updateEditRecord("additionShortName",this.mstAddition.addition_short_name);
            break;
          // 算定タイミング
          case "additionKind":
            this.updateEditRecord("additionKind",this.additionKindFlg == false ? '2' : '1');
            break;
          // 加算種別
          case "additionClass":
            this.updateEditRecord("additionClass",this.mstAddition.addition_class);
            break;
          // 算定回数
          case "additionSpan":
            this.updateEditRecord("additionSpan",this.mstAddition.addition_span);
            break;
          // 算定回数上限
          case "additionLimit":
            // 特定の算定種別の場合は、無制限となる為、""を代入する
            const list = ["1", "5", "9", "10", "11"];
            if(list.includes(this.mstAddition.addition_class)) {
              this.mstAddition.addition_limit.editValue = null;
            }
            this.updateEditRecord("additionLimit",this.mstAddition.addition_limit.editValue);
            break;
          // 算定回数上限 TYPE
          case "additionLimitType":
            this.updateEditRecord("additionLimitType",this.mstAddition.addition_limit_type);
            break;
          // 算定回（月１）
          case "addCnt1":
            this.updateEditRecord("addCnt1",this.mstAddition.add_cnt1.editValue);
            break;
          // 算定対象
          case "additionCond":
            this.updateEditRecord("additionCond",this.mstAddition.addition_cond);
            break;
          // 算定治療時間
          case "additionDialysisTime":
            // 加算種別：長時間加算 以外は""を代入する
            if(this.mstAddition.addition_class !== "5") {
              this.mstAddition.addition_dialysis_time.editValue = "";
            }
            this.updateEditRecord("additionDialysisTime",this.mstAddition.addition_dialysis_time.editValue);
            break;
          // 連携コード1
          case "inHospitalCd1":
            this.updateEditRecord("inHospitalCd1",this.mstAddition.in_hospital_cd1);
            break;
          // 連携コード2
          case "inHospitalCd2":
            this.updateEditRecord("inHospitalCd2",this.mstAddition.in_hospital_cd2);
            break;
          // 連携コード3
          case "inHospitalCd3":
            this.updateEditRecord("inHospitalCd3",this.mstAddition.in_hospital_cd3);
            break;

          default:
            break;
        }
      });
      this.refreshExamJson();

    },

    /**
     * Splits a camel-case or Pascal-case variable name into individual words.
     * @param {string} s
     * @returns {string[]}
     */
    splitWords(s) {
      var re, match, output = [];
      // re = /[A-Z]?[a-z]+/g
      re = /([A-Za-z0-9]?)([a-z0-9]+)/g;

      match = re.exec(s);
      while (match) {
        // output.push(match.join(""));
        output.push([match[1].toLowerCase(), match[2]].join(""));
        match = re.exec(s);
      }

      let str = "";
      for (let index = 0; index < output.length; index++) {
        str = str.concat(output[index], "_");
      }
      return str.substring(0, str.length - 1);
    },
    // selectTargetItem をもとにJSONをつくる
    refreshExamJson(){
      // ExamItemInfoを初期化
      this.ExamItemInfo = [];

      // ExamItemInfoをつくる
      // selectTargetItemを変換してpushしていく
      for (var i = 0; i < this.selectTargetItem.length; i++) {
        if (this.selectTargetItem[i] == 0 || typeof this.selectTargetItem[i] === "undefined") {
          // 空欄もしくはundefinedは対象外
          continue;
        }

        // 検査項目情報の取得
        // 検査項目IDでフィルタリングするので一意のはず
        let selExamItem = this.targetList.filter(item => item.cd == this.selectTargetItem[i]);
        if(selExamItem[0]) {
          this.ExamItemInfo.push({
            cd: this.selectTargetItem[i],
            name: selExamItem[0].name
          });
        }
      }

      // JSONにしてinputModelに代入
      this.editRecord['additionTarCd'] = JSON.stringify(this.ExamItemInfo);
      this.setEditRecord(this.editRecord);
      // this.mstAddition.addition_target_cd = this.getValueByField('additionTarCd');

      // ラベル情報を更新する
      // this.createLabelInfo();
    },

    // ドロップダウン追加
    addNewDropDown(){
      this.selectTargetItem.push(0);
      this.refreshExamJson();
      //[確認]ボタンの状態の変更をトリガーします
      this.changeButton();

      this.$nextTick(() => {
        const ele = document.getElementsByClassName("data-table")[0];
        if (ele) {
          ele.scrollTop = ele.scrollHeight;
        }
        // add/ #12498 プルダウンui異常 tianqidong start
        this.updateTruncatedTexts()
        // add/ #12498 プルダウンui異常 tianqidong end
      });
    },

    // add start #9482
    diseaseSelect(value, index) {
      this.createJsonByExamCd(value, index);
      this.changeButton();
    },
    // add end #9482
    // add/ #12498 プルダウンui異常 tianqidong start
    updateTruncatedTexts() {
      const refs = this.$refs.selectRef;
      if(!refs) return;
      const select = Array.isArray(refs) ? refs[0] : refs;
      if (!select) return;
      this.targetList = this.targetList.map(item => ({
        ...item, 
        displayName: this.truncateTextDynamic(item.name) 
      }));

    },
    onResize(){
        this.updateTruncatedTexts();
    },
    truncateTextDynamic(text) {
      const refs = this.$refs.selectRef;
      if(!refs) return text
      const select = Array.isArray(refs) ? refs[0] : refs;
      if (!select || !text) return text;

      const style = window.getComputedStyle(select);
      const font = `${style.fontSize} ${style.fontFamily}`;

      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      ctx.font = font;

      const maxWidth = select.clientWidth - 40;
      let result = '';

      for (const ch of text) {
        if (ctx.measureText(result + ch + '...').width > maxWidth) {
          result += '...';
          break;
        }
        result += ch;
      }

      return result;
    },
    // add/ #12498 プルダウンui異常 tianqidong end
     // Json作成用
    createJsonByExamCd(value, order){
      // もらうデータの表示
      // itemcd に event.dataItem.value を使う
      this.selectedOrder = order;

      let selItem = this.targetList.filter(e => {
        // add/ #12498 /加算マスタの種別：指定薬剤実施連動で特定の薬剤を選択するとエラーが発生 tianqidong start
        //return e.name == value;
        return e.cd == value;
        // add/ #12498 /加算マスタの種別：指定薬剤実施連動で特定の薬剤を選択するとエラーが発生 tianqidong end
      });
      // 選択した値が既にリストに存在するか確認
      // 存在しない場合は0 存在する場合は何要素目かを返す
      let selIndex = this.selectTargetItem.indexOf(selItem[0].cd);

      // selectTargetItemの編集
      // orderは0始まりの値をそのまま入れる
      this.selectTargetItem[order] = selItem[0].cd;
      this.selectTargetItem.splice();

      // 重複の確認 重複の場合ダイアログを出す
      if (selIndex >= 0 && selIndex != order && value != 0) {
        // 検査項目情報の取得
        // 検査項目IDでフィルタリングするので一意のはず
        let selExamItem = this.targetList.filter(item => item.cd == selItem[0].cd);
        let selExamItemName = selExamItem[0].name;    // 検査項目名称

        // 確認ダイアログ
        // 選択後は直下のconfirm関数に飛ぶ
        this.messageDialogInfo.messageCd = 60000001;
        this.messageDialogInfo.type = "1";
        this.messageDialogInfo.stringParams = [selExamItemName];
        this.messageDialogInfo.isDialogVisible = true;
      } else {
        // JSONの作成
        this.refreshExamJson();
      }
    },

    confirm(answer) {
      // 「OK」押下時の処理
      // selectTargetItemの編集
      // 空欄に戻すため"0"を入れる
      if (answer === 'OK') {
        this.selectTargetItem[this.selectedOrder] = 0;
        this.selectTargetItem.splice();
        this.selectedOrder = 0;
        // JSONの作成
        this.refreshExamJson();
      }
    },
    // ドロップダウン削除
    deleteDropDown(index){
      // 指定された要素の削除
      this.selectTargetItem.splice(index, 1);
      // 0件の場合は空欄に戻す
      if (this.selectTargetItem.length === 0) {
        this.selectTargetItem.push(0);
      }
      this.refreshExamJson();
      //[確認]ボタンの状態の変更をトリガーします
      this.changeButton();
    },

    /**
     *
     */
    changeAdditionClass() {
      // Selected list
      this.selectTargetItem = [];
      this.refreshExamJson();
      // Addition class
      if(this.mstAddition.addition_class == '2') { // 透析困難コメント
        this.targetList = this.mstDialysisDifficulty;
        this.mstAddition.addition_cond = '2';
      } else if(this.mstAddition.addition_class == '3') { // 病名
        this.targetList = this.mstDisease;
        this.mstAddition.addition_cond = '1';
      } else if(this.mstAddition.addition_class == '4') { // 治療方法
        this.targetList = this.mstTreatment;
        this.mstAddition.addition_cond = '4';
      } else if(this.mstAddition.addition_class == '6') { // 薬剤
        this.targetList = this.mstMedicine;
        this.mstAddition.addition_cond = '6';
      } else if(this.mstAddition.addition_class == '7') { // 患者イベント
        this.targetList = this.mstPatEventSubCategory;
        this.mstAddition.addition_cond = '7';
      } else if(this.mstAddition.addition_class == '0') { //// redmine 4343 加算マスタの加算種別「デフォルト」の文言不正,デフォルト→汎用 宋qy
        this.mstAddition.addition_class = '12';
      } else if(this.mstAddition.addition_class == '5') { // 長時間加算
        // 算定治療時間が空の場合はデフォルト値設定
        this.mstAddition.addition_dialysis_time.editValue ??= 0;
      } else if(this.mstAddition.addition_class === '13') {
        // NOTE: 慢性維持透析患者外来医学管理料の場合、「算定回（月１）」を表示
        this.mstAddition.addition_span = '0';
        this.mstAddition.addition_limit_type = this.mstAddition.addition_limit_type || '1';
        this.mstAddition.add_cnt1.editValue = this.mstAddition.add_cnt1.editValue || 1;
      }

      // 算定回数
      if(!this.mstAddition.addition_span) {
        this.mstAddition.addition_span = '3';
      } else if (this.mstAddition.addition_class !== '12' && this.mstAddition.addition_span === '4') {
        this.mstAddition.addition_span = '3';
        this.mstAddition.addition_limit.editValue = null;
      }
      // add start #9783
      if (this.mstAddition.addition_span === '0') {
        this.mstAddition.addition_limit.editValue = 1;
      }
      // add end #9783
      this.$nextTick(() => {
        // NOTE: 加算種別変更時に高さが変化するため、再計算
        this.calculateListHeight();
      });
    },
    /**
     * 算定回数の変更時処理
     */
    changeAdditionSpan(span){
      this.mstAddition.addition_limit_type = '1';
      if (span === '0') {
        this.mstAddition.addition_limit.editValue = 1;
      }
      //画面の初期表示後に、算定回（週１）・算定回（月１）が最初に表示された場合
      if(this.mstAddition.add_cnt1.initValue === 0){
        this.mstAddition.add_cnt1.initValue = this.mstAddition.add_cnt1.editValue = 1;
      } else {
        this.mstAddition.add_cnt1.editValue = 1;
      }
    },
    /**
     * 算定回（月１）の設定処理
     * @param selectedAdditionLimitType 算定回数上限の種別
     */
    setEditAddCnt1(selectedAdditionLimitType){
      //算定回の種別が1、かつ、算定回（月１）がnullの場合、算定回（月１）に1を設定する
      if(selectedAdditionLimitType === "1" && this.mstAddition.add_cnt1.editValue === null){
        this.mstAddition.add_cnt1.editValue = 1;
      }
    },
    /**
     * 削除済みを考慮したリストを取得
     */
    getTargetListByTarItem(tarItem){
      return this.targetList.filter(item => {
        return item.cd === 0 || item.cd === tarItem || item.deleted === false;
      });
    },

    // 高さを計算する
    calculateListHeight() {
      const dataList = document.getElementsByClassName("data-table")[0];
      if (!dataList) return;
      const modalBody = document.getElementsByClassName('modal-body')[0];
      // NOTE: 500px 以下の場合、全体スクロール（スマホサイズ）
      if (this.windowWidth <= 500) {
        dataList.style.removeProperty('height');
        dataList.style.overflowY = 'visible';
        if (modalBody) {
          modalBody.style.overflowY = 'auto';
          modalBody.classList.remove('modal-overflow-hidden');
        }
        return;
      }
      // NOTE: 501px 以上の場合、一覧のみスクロール
      const infoHeight = document.getElementsByClassName("addition-info")[0].clientHeight;
      const totalHeight = document.getElementsByClassName("modal-container")[0].clientHeight;
      const topHeight = document.getElementsByClassName("toolbar")[0].clientHeight;
      const bottomHeight = document.getElementsByClassName("modal-footer")[0].clientHeight;
      // NOTE: addition-infoエリアのマージン（14px + 7px = 21px）
      const actualHeight = totalHeight - topHeight - bottomHeight - infoHeight - 21;
      if (actualHeight > 0) {
        dataList.style.height = actualHeight + "px";
        dataList.style.overflowY = 'auto';
      }
      if (modalBody) {
        modalBody.style.removeProperty('overflow-y');
        modalBody.classList.add('modal-overflow-hidden');
      }
    },

    handleJudgeEdited (val, key) {
      if (this.initMstAddition) {
        // nullを""に置換えて判定
        const initVal = this.initMstAddition[key] != null ? this.initMstAddition[key] : "";
        const compareVal = val != null ? val : "";
        return initVal !== compareVal ? "custom-input-edited" : "";
      } else {
        return ""
      }
    },
    handleJudgeSelectEdited (val, key) {
      if (this.initMstAddition && this.initMstAddition[key] != val) {
        return "custom-select-edited"
      } else {
        return ""
      }
    },
    /** 加算種別コードから表示タイトルを返却 */
    listTitle(classNo) {
      /** 加算種別コード → 表示タイトル */
      const ADDITION_CLASS_TITLES = {
        "2": "透析困難コメント",
        "3": "病名",
        "4": "治療方法",
        "6": "薬剤",
        "7": "患者イベント",
      };
      const key = String(classNo ?? "");
      return ADDITION_CLASS_TITLES[key] ?? "";
    }
  }
};
</script>

<style scoped>
.item-button {
  width: 60px;
  padding: 0;
  margin-left: 2px;
}
/* --------------------------- */
.mst_addition select {
  padding: 3px 0;
}
ons-select >>> .select-input {
  height: 2.2em;
  line-height: 20px;
}
.mst_addition .wrapper{
  padding: 0 0px;
}
.mst_addition .wrapper {
  min-height: 35px;
}
/* 項目名 */
.mst_addition .item-title {
  width: 15%;
  max-width: 15%;
  margin-left: 5px;
  line-height: 30px;
}
/* 項目内容 */
.mst_addition .item-data {
  padding-bottom: 3px;
  padding-left: 3px;
  padding-right: 3px;
  line-height: 30px;
}
.mst_addition input {
  line-height: 20px;
}
.mst_addition .button {
  line-height: 26px;
}
.mst_addition .radio-btn label{
  padding: 5px 5px;
  margin-right: 0.5em;
}
.mst_addition .radio-btn .radio-button{
  padding: 5px 5px;
}
.mst_addition .input-number {
  max-width: 50px;
}
.mst_addition .margin-0 {
  margin-right: 0px !important;
}
.mst_addition .mst_addition_item {
  white-space: nowrap;
  overflow: hidden;
}
.mst_addition .width-fit {
  max-width: fit-content;
  min-width: fit-content;
}
.mst_addition .hospital-code {
  position: relative;
}
.mst_addition .hospital-code input:nth-child(1) {
  width: 90%;
}
.mst_addition .hospital-code input:nth-child(2) {
  margin: 0 20px;
  width: 32%;
}
.mst_addition .hospital-code input:nth-child(3) {
  width: calc(34% - 46px);
}
.mst_addition .addition-cat select{
  width: 30%;
}
.mst_addition .wrapper.caculation .item-data{
  max-width: fit-content;
  white-space: nowrap;
}
.mst_addition .addition-kind {
  padding: 0px 3px;
  padding-top: 6px;
}
.mst_addition .checkbox-lable {
  line-height: 22px;
}
.mst_addition .checkbox-lable span{
  padding-left: 5px;
}
.modal-overflow-scroll {
  overflow: scroll !important;
}
@media screen and (max-width: 500px) {
  .mst_addition .item-title {
    min-width: 100%;
  }
  .mst_addition .hospital-code input:nth-child(2) {
    margin: 0 10px;
    width: 30%;
  }
  .mst_addition .hospital-code input:nth-child(3) {
    width: calc(40% - 46px);
  }
}

@media screen and (max-width: 1050px) {
  .mst_addition .item-title {
    max-width: 9rem;
  }
}

.input-required{
  color: black;
  background-color: #ffff99;
}
.input-invalid{
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.input-required >>> input{
  color: black;
  background-color: #ffff99;
}
.input-invalid >>> input{
  color: black;
  background-color: rgba(255, 0, 0, 1);
}

.target-row{
  margin-top: 12px;
  border: 1px solid black;
}

.custom-input-edited{
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
::v-deep .custom-select-edited > select {
    color: #333333;
    font-weight: unset;
}
/* 「対象指定」表示位置 */
.list-main-title {
  max-width: 11em;
  margin-left: 5px;
}
/* 対象指定一覧 全体 */
.data-table {
  display: block;
  overflow-x: auto;
}
/* 対象指定一覧 ヘッダ */
th.ntss-list-header-th-sticky {
  z-index: 1;
}
/* 削除ボタン ヘッダ */
.list-header-delete {
  width: 3em;
}
/* 削除ボタン 各行 */
.button-delete {
  display: block;
  margin: auto;
}
</style>
