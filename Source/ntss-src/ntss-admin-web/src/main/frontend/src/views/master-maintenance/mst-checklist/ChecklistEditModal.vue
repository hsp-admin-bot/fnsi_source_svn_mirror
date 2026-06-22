/**
 * チェックリストモーダル画面用ページ
 */
<template>
  <modal-base @onClose="closeChecklistEditModal">
    <template #header>
      <component :is="header"></component>
    </template>
    <template #body>
      <div>
      <div>
        <!-- リスト名 -->
        <table class="grid-list custom-input-grid">
      <tbody>
          <tr v-bind:class="{ 'changestyle': getSelectChecklistSetting.chgflg_listname }">
            <!--  mod redmine 5004 入力IFの位置不正 孔 start-->
            <!--  <td class="text-font-style">-->
            <td class="text-font-style" style="width: 220px;">
            <!--  mod redmine 5004 入力IFの位置不正 孔 end-->
              <label>リスト名</label>
            </td>
            <td v-bind:class="{ 'checklist-edited-cell': getSelectChecklistSetting.chgflg_listname }">
              <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start-->
              <!-- <v-ons-input
                v-model="getSelectChecklistSetting.list_name"
                :class="handleJudgeEdited(getSelectChecklistSetting.list_name, 'list_name')"
                @change="changeListName(),changeButton()"
              ></v-ons-input> -->
              <v-ons-input
                v-model="getSelectChecklistSetting.list_name"
                :class="handleJudgeEdited(getSelectChecklistSetting.list_name, 'list_name')"
                @change="changeListName()"
              ></v-ons-input>
              <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end-->
            </td>
          </tr>
        
      </tbody></table>
        <table class="grid-list">
      <tbody>
          <tr>
            <!-- 工程 -->
            <!--  mod redmine 5004 入力IFの位置不正 孔 start-->
            <!--  <td class="text-font-style" v-bind:class="{ 'changestyle': getSelectChecklistSetting.chgflg_progcd }">-->
            <td class="text-font-style" v-bind:class="{ 'changestyle': getSelectChecklistSetting.chgflg_progcd }" style="width: 220px;">
            <!--  mod redmine 5004 入力IFの位置不正 孔 end-->
              <label>工程</label>
            </td>
            <td v-bind:class="{ 'changestyle': getSelectChecklistSetting.chgflg_progcd, 'checklist-edited-cell': getSelectChecklistSetting.chgflg_progcd }" >
              <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start-->
              <!-- <v-ons-select
                :class="handleJudgeEdited(getSelectChecklistSetting.dialysis_prog_cd, 'dialysis_prog_cd')"
                v-model="dialysisProg"
                @change="changeListName(),changeButton()"
              > -->
              <v-ons-select
                :class="handleJudgeEdited(getSelectChecklistSetting.dialysis_prog_cd, 'dialysis_prog_cd')"
                v-model="dialysisProg"
                @change="changeListName()"
              >
              <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end-->
                <option v-for='option in getMstDialysisProgressList' :key=option.length :value='option.dialysisProgCd'>
                  {{ option.dialysisProgName }}
                </option>
              </v-ons-select>
            </td>
            <td class='header-btn-area right custom-toolbar-btn'>
              <!-- del チェックリスト設定画面の並び順変更を修正する。孔s start -->
              <!-- <v-ons-button modifier="outline" class="toolbar-btn" v-show="!isSortMode" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
              <v-ons-button modifier="outline" class="toolbar-btn" v-show="isSortMode" @click="sortBtnClick()">反映</v-ons-button> -->
              <!-- del チェックリスト設定画面の並び順変更を修正する。孔s end -->
            </td>
          </tr>
        
      </tbody></table>

        <div>
          <table class="grid-list">
            <thead>
              <tr class="master-grid-header grid-header">
                <!-- class="text-font-style grid-header ntss-list-body-td-header grid-border" -->
                <td v-show="!isSortMode" class="text-font-style ntss-list-body-td-header grid-border" width='10px'></td>
                <td v-show="isSortMode" class="text-font-style ntss-list-body-td-header grid-border" width='60px' >並び順</td>
                <td class="text-font-style ntss-list-body-td-header grid-border" width='140px'>データ種別</td>
                <td class="text-font-style ntss-list-body-td-header grid-border" >名称</td>
              </tr>
            </thead>

            <!-- <div v-for='category in getSelectChecklistSetting.funclist' :key=category.no> -->
            <tbody>
              <tr class="checklist-modal-row" v-for='(category, idx) in getSelectChecklistSetting.funclist' :key=category.item_number>
                <td v-show="!isSortMode" width='10px' class="grid-border" v-bind:class="{ 'dispno-changestyle': category.chgflg_disp_no }">
                </td>
                <!-- 表示順 -->
                <td v-show="isSortMode" width='60px'
                 class="ntss-list-body-td grid-border"
                 v-bind:class="{ 'dispno-changestyle': category.chgflg_disp_no }">
                  <!-- mod チェックリスト設定画面でデータ種別を未登録にした場合は、並び順を後方にする 孔s start -->
                  <!-- <v-ons-input type="number" min="1" v-model.number="category.disp_no"  @change="changeListName"> -->
                    <!-- mod #5589 2023/04/03 数値IFのスタイル全不正 張博 start -->
                  <!-- <v-ons-input type="number" min="0" v-model.number="category.disp_no"
                    @change="changeListName(),changeButton()"
                    :class="handleJudgeEdited(category.disp_no, 'disp_no', idx)"
                    @blur="sortBtnClick"> -->
                    <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start-->
                    <!-- <v-ons-input
                    type="number" 
                    v-model.number="category.disp_no"
                    @change="changeListName(),changeButton()"
                    @input="inputNumber($event, 1 ,10)"
                    @mousewheel="(e)=>{ return e.target.value}"
                    :class="handleJudgeEdited(category.disp_no, 'disp_no', idx)"
                    @blur="sortBtnClick"
                    > -->
                  <v-ons-input
                    type="number" 
                    v-model.number="category.disp_no"
                    @change="changeListName()"
                    @input="inputNumber($event, 1 ,10)"
                    @mousewheel="(e)=>{ return e.target.value}"
                    :class="handleJudgeEdited(category.disp_no, 'disp_no', idx)"
                    @blur="sortBtnClick"
                    >
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end-->
                    <!-- mod #5589 2023/04/03 数値IFのスタイル全不正 張博 end -->
                  <!-- mod チェックリスト設定画面でデータ種別を未登録にした場合は、並び順を後方にする 孔s end-->
                  </v-ons-input>
                </td>
                <!-- データ種別 -->
                <td width='140px' class="check-style ntss-list-body-td grid-border" v-bind:class="{ 'changestyle': category.chgflg, 'checklist-edited-cell': category.chgflg_func_class }">
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start-->
                   <!-- <v-ons-select v-model.number=category.func_class
                    @change="changeKind(idx),changeButton()"
                    :class="handleJudgeEdited(category.func_class, 'func_class', idx)">
                    <option v-for='option in dataKindList' :key=option.length :value=option.func_class>
                      {{ option.name }}
                    </option>
                  </v-ons-select> -->
                  <v-ons-select
                    :model-value="getFuncClassSelectValue(category.func_class)"
                    @update:model-value="value => updateFuncClass(idx, value)"
                    :class="handleJudgeEdited(category.func_class, 'func_class', idx)">
                    <option
                      v-for="option in dataKindList"
                      :key="option.name"
                      :value="getFuncClassSelectValue(option.func_class)">
                      {{ option.name }}
                    </option>
                  </v-ons-select>
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end-->
                </td>
                <!-- 未登録 -->
                <td v-if="category.func_class === null" class="ntss-list-body-td grid-border" v-bind:class="{'changestyle': category.chgflg}">
                </td>
                <!-- フリーワード -->
                <td v-if="category.func_class === 0" class="ntss-list-body-td grid-border" v-bind:class="{'changestyle': category.chgflg, 'checklist-edited-cell': category.chgflg_list_name }">
                  <!-- del チェックリスト設定画面のデータ種別フリーワードの場合の名称列の画面部品はテキストエリアではなくテキストボックス。孔s start-->
                  <!-- <com-textarea
                    :content="category.list_name"
                    cssClass="textarea-custom-text-font textareaCheckList textarea-resize-vertical"
                    :idTextarea="'com-textarea-check-list' + idx"
                    @set-content-data="setContentData($event, idx)"
                  /> -->
                  <!-- del チェックリスト設定画面のデータ種別フリーワードの場合の名称列の画面部品はテキストエリアではなくテキストボックス。孔s end-->
                  <!-- add チェックリスト設定画面のデータ種別フリーワードの場合の名称列の画面部品はテキストエリアではなくテキストボックス。孔s start-->
                  <!-- <v-ons-input
                      class="v-ons-input com-sv"
                      type="text"
                      v-model="category.list_name"
                      :class="handleJudgeEdited(category.list_name, 'list_name', idx)"
                      @input="changeColor(category.list_name,$event)"
                      @change="setContentData(category.list_name, idx),changeButton()"
                  ></v-ons-input> -->
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start-->
                  <v-ons-input
                      class="v-ons-input com-sv"
                      type="text"
                      v-model="category.list_name"
                      :class="handleJudgeEdited(category.list_name, 'list_name', idx)"
                      @input="changeColor(category.list_name,$event)"
                      @change="setContentData(category.list_name, idx)"
                  ></v-ons-input>
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end-->
                  <!-- add チェックリスト設定画面のデータ種別フリーワードの場合の名称列の画面部品はテキストエリアではなくテキストボックス。孔s end-->
                </td>
                <!-- 治療条件 -->
                <td v-if="category.func_class === 1" class="ntss-list-body-td grid-border" v-bind:class="{'changestyle': category.chgflg, 'checklist-edited-cell': category.chgflg_class_cd }">
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start-->
                  <!-- <v-ons-select v-model.number=category.class_cd
                      :class="handleJudgeEdited(category.class_cd, 'class_cd', idx)" @change="changeListName(),changeButton()"> -->
                  <v-ons-select v-model.number=category.class_cd
                      :class="handleJudgeEdited(category.class_cd, 'class_cd', idx)" @change="changeListName()">
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end-->
                    <option v-for='option in getCondList' :key=option.length :value='option.class_cd'>
                      {{ option.list_name }}
                    </option>
                  </v-ons-select>
                </td>
                <!-- 医療材料 -->
                <td v-if="category.func_class === 2" class="ntss-list-body-td grid-border" v-bind:class="{'changestyle': category.chgflg, 'checklist-edited-cell': category.chgflg_class_cd }">
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start-->
                  <!-- <v-ons-select v-model.number=category.class_cd
                      :class="handleJudgeEdited(category.class_cd, 'class_cd', idx)" @change="changeListName(),changeButton()"> -->
                  <v-ons-select v-model.number=category.class_cd
                      :class="handleJudgeEdited(category.class_cd, 'class_cd', idx)" @change="changeListName()">
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end-->
                    <option v-for='option in getMstEquipClassList' :key=option.length :value='option.class_cd'>
                      {{ option.list_name }}
                    </option>
                  </v-ons-select>
                </td>
                <!-- ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する 孔s start -->
                <!-- 投与薬剤 -->
                <td v-if="category.func_class === 3" class="ntss-list-body-td grid-border" v-bind:class="{'changestyle': category.chgflg, 'checklist-edited-cell': category.chgflg_class_cd }">
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start-->
                  <!-- <v-ons-select v-model.number=category.class_cd
                      :class="handleJudgeEdited(category.class_cd, 'class_cd', idx)" @change="changeListName(),changeButton()"> -->
                  <v-ons-select v-model.number=category.class_cd
                      :class="handleJudgeEdited(category.class_cd, 'class_cd', idx)" @change="changeListName()">
                   <!-- mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end-->

                    <template v-for='option in getMstMedicineClassList' :key='option.class_cd'>
                      <option v-if='option.list_name.indexOf("【削除済み】") !=-1' style="display:none" :value='option.class_cd'>
                        {{ option.list_name }}
                      </option>
                      <option v-else :value='option.class_cd'>
                        {{ option.list_name }}
                      </option>
                    </template>
                  </v-ons-select>
                </td>
                <!-- ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する 孔s end -->
              </tr>
            </tbody>
            <!-- </div> -->
          </table>
        </div>
      </div>
    </div>
    </template>

    <template #footer>
      <div class="flex-container footer">
      <div class="denial-btn-area" style="background:none">
        <button class="btn2-cancel button denial-btn" @click="closeChecklistEditModal">キャンセル</button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- mod チェックリスト設定画面の並び順変更を修正する。孔s start -->
        <!-- <button class="button registration-btn" v-show="!isSortMode" @click="saveChecklistEditModalStore">確定</button> -->
        <button class="common-style-select-button button registration-btn" :disabled="registeredFlag" @click="saveChecklistEditModalStore">確定</button>
        <!-- mod チェックリスト設定画面の並び順変更を修正する。孔s end -->
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import ModalBase from "@/components/modals/ModalBase";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import customInputNumber from "@/components/common/custom-form-tags/CustomInputNumber";
import CommonTextArea from "@/components/common/CommonTextArea";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/10 start
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
// add #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/10 end
export default {
  name: "ChecklistEditModal",
  components: {
    "modal-base": ModalBase,
    "custom-input-number": customInputNumber,
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      main: "",
      header: "",
      // mod チェックリスト設定画面の並び順変更を修正する 孔s start
      // isSortMode: false,
      isSortMode: true,
      registeredFlag: true,
      // mod チェックリスト設定画面の並び順変更を修正する 孔s end
      dataKindList: [
        { func_class: null, name: "未登録" },
        { func_class: 0, name: "フリーワード" },
        { func_class: 1, name: "治療条件" },
        { func_class: 2, name: "医療材料" }
        // ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する 孔s start
        ,{ func_class: 3, name: "投与薬剤" }
        // ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する 孔s end
      ],
      getSelectChecklistSetting_clone: {},
      //mod マスタ詳細画面がありません破棄メッセージ 张博 start
      getSelectChecklistSetting_init:[],
      giveUpFlg:false,
      //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    };
  },
  computed: {
    ...mapGetters("mst-checklist", [
      "getMstDialysisProgressList",
      "getSelectChecklistSetting",
      "getCondList",
      "getMstEquipClassList"
      // ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する 孔s start
      ,"getMstMedicineClassList"
      // ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する 孔s end
    ]),
    // 工程
    dialysisProg: {
      get() {
        return this.getSelectChecklistSetting.dialysis_prog_cd;
      },
      set(val) {
        this.setDialysisProgName(val);
      }
    }
  },

  created() {},
  //mod マスタ詳細画面がありません破棄メッセージ 张博 start
  watch:{
    getSelectChecklistSetting:{
       handler(newValue){
        if (JSON.stringify(newValue) !== JSON.stringify(this.getSelectChecklistSetting_init)) {
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start 
                //  this.giveUpFlg = true   
                 this.registeredFlag = false
          //mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end
        }else{
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start 
                //  this.giveUpFlg = false
                 this.registeredFlag = true
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end
        }
      },
      deep:true
    }
  },
  //mod マスタ詳細画面がありません破棄メッセージ 张博 end
  mounted() {
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/10 start
    // this.getSelectChecklistSetting_init = JSON.stringify(this.getSelectChecklistSetting);
    const normalizedSetting = cloneDeep(this.getSelectChecklistSetting);
    this.normalizeFunclistFuncClass(normalizedSetting);
    this.setSelectEditSetting(normalizedSetting);
    this.getSelectChecklistSetting_init = cloneDeep(normalizedSetting);
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/10 end
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    this.getSelectChecklistSetting_clone = JSON.parse(JSON.stringify(normalizedSetting));
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal"]),
    ...mapActions("mst-checklist", [
      "setSelectEditSetting",
      "setDialysisProgName",
      "regEditData",
      "sortData"
    ]),
     //  mod #5589 2023/03/28 数値IFのスタイル全不正 張博 start
    inputNumber(e,min,max){
        // 数値範囲内かどうかの確認
        if (min !== undefined && max !== undefined) {
          if (e.target.value > max) {
            e.target.value = min;
          } else if (e.target.value < min) {
            e.target.value = max;
          }
        }
    },
    //  mod #5589 2023/03/28 数値IFのスタイル全不正 張博 end
    handleJudgeEdited (val, key, index) {
      let cloneObj
      if ((index || index === 0) && this.getSelectChecklistSetting_clone.funclist) {
        cloneObj = this.getSelectChecklistSetting_clone.funclist[index]
      } else {
        cloneObj = this.getSelectChecklistSetting_clone
      }
      if ([null, undefined, ''].includes(cloneObj[key]) && !val && val !== 0) {
        return ''
      }
      if (cloneObj && cloneObj[key] != val) {
        return 'custom-input-edited'
      } else {
        return ''
      }
    },
    // 並べ替えボタン
    toRankEditBtnClick() {
      this.isSortMode = true;
    },
    // 並べ替え反映ボタン
    sortBtnClick() {
      this.sortData();
      // mod チェックリスト設定画面の並び順変更を修正する 孔s start
      this.changeListName();
      // this.isSortMode = false;
      // mod チェックリスト設定画面の並び順変更を修正する 孔s end
    },
    normalizeFuncClassValue(funcClass) {
      if (funcClass === null || funcClass === undefined || funcClass === "" || funcClass === "null") {
        return null;
      }
      const parsed = Number(funcClass);
      return Number.isNaN(parsed) ? null : parsed;
    },
    normalizeFunclistFuncClass(setting) {
      if (!setting?.funclist) {
        return;
      }
      setting.funclist.forEach(item => {
        item.func_class = this.normalizeFuncClassValue(item.func_class);
      });
    },
    getFuncClassSelectValue(funcClass) {
      const normalized = this.normalizeFuncClassValue(funcClass);
      if (normalized === null) {
        return "null";
      }
      return String(normalized);
    },
    parseFuncClassSelectValue(value) {
      return this.normalizeFuncClassValue(value);
    },
    updateFuncClass(idx, value) {
      const setting = this.getSelectChecklistSetting;
      setting.funclist[idx].func_class = this.parseFuncClassSelectValue(value);
      this.setSelectEditSetting(setting);
      this.changeKind(idx);
    },
    // 種別変更イベント
    changeKind(idx) {
      // チェックリスト設定
      let setting = this.getSelectChecklistSetting;
      setting.funclist[idx].func_class = this.normalizeFuncClassValue(
        setting.funclist[idx].func_class,
      );

      if (setting.funclist[idx].func_class === 1) {
        // 治療条件をセットした場合
        const condList = this.getCondList;
        setting.funclist[idx].class_cd = condList?.length ? condList[0].class_cd : null;
      } else if (setting.funclist[idx].func_class === 2) {
        // 医療材料をセットした場合
        const equipList = this.getMstEquipClassList;
        setting.funclist[idx].class_cd = equipList?.length ? equipList[0].class_cd : null;
      //ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する 孔s start
      } else if (setting.funclist[idx].func_class === 3) {
        // 投与薬剤をセットした場合
        const medicineList = this.getMstMedicineClassList;
        setting.funclist[idx].class_cd = medicineList?.length ? medicineList[0].class_cd : null;
      //ADD チェックリストマスタ データ種別に「投与薬剤」を「医療材料」の下の選択肢に追加する 孔s end
      } else {
        // フリーワードまたは未登録をセットした場合
        setting.funclist[idx].class_cd = null;
      }
      this.setSelectEditSetting(setting);
      // add チェックリスト設定画面でデータ種別を未登録にした場合は、並び順を後方にする 孔s start
      this.sortData()
      // add チェックリスト設定画面でデータ種別を未登録にした場合は、並び順を後方にする 孔s end
    },
     //[確認]ボタンの状態の変更をトリガーします
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start
    // changeButton() {
    //  this.registeredFlag=false;
    // },
    // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end
    // 名称変更イベント
    changeListName() {
      // チェックリスト設定
      let setting = this.getSelectChecklistSetting;
      // 変更チェック
      this.setSelectEditSetting(setting);
    },
    // 確定ボタン
    saveChecklistEditModalStore() {
      // 内部 車いすマスタ 50以上文字文字チェックがない start
      if (this.getSelectChecklistSetting.list_name && this.getSelectChecklistSetting.list_name.length > 50) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES['00200101'].title,
            message: messageFormat(DIALOG_MESSAGES['00200101'].message)  
          });
          return
        }
        // 内部 車いすマスタ 50以上文字文字チェックがない end
      // 編集内容を登録
      this.regEditData().then(res => {
        // 編集内容OK
        if (res === true) {
          // モーダルを非表示に
          this.hideModal();
        } else {
          for(let dom of getScopedElementsByClassName("v-ons-input", this.$el || this)){
            if(dom.value === ""){
              dom?.classList?.add("custom-input-invalid")
            }
          }
          // エラーメッセージ表示
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "チェックリストマスタ登録失敗",
            // message: "フリーワードは空白で登録できません。"
            title: DIALOG_MESSAGES[12000288].title,
            message: messageFormat(DIALOG_MESSAGES[12000288].message)  
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
          
        }
      });
    },
    // キャンセルボタン
    closeChecklistEditModal() {
      //mod マスタ詳細画面がありません破棄メッセージ 张博 start
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 start 
      // if(this.giveUpFlg){
      if (!this.registeredFlag) {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_チェックリストマスタ 張玲 2024/01/04 end
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: async answer => {
            if (answer === 1) {
              // モーダルを非表示に
              this.hideModal();
            }
          }
        })
      }else{
              // モーダルを非表示に
              this.hideModal();
      }
     //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    },

    setContentData(newValue, index) {
      this.getSelectChecklistSetting.funclist[index].list_name = newValue;

      // チェックリスト設定
      let setting = this.getSelectChecklistSetting;
      // 変更チェック
      this.setSelectEditSetting(setting);
    },
    changeColor(newValue,e){
      let dom =  e.target.parentElement.classList
      if(dom.length === 3){
        dom.remove("custom-input-invalid");
      }
    }
  }
};
</script>

<style scoped>

/* リスト行 */
.checklist-modal-row {
  background-color: var(--ntss-base-background-color);
  color: var(--pat-event-text-color);
}
/* ラベルのスタイル */
.text-font-style {
  text-align: center;
}
/* ヘッダ */
.grid-header,
.grid-header .ntss-list-body-td-header {
  height: 2em;
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
/* 並び順/反映ボタン */
.toolbar-btn {
  font-size: small;
  padding: 0.2em 0.8em;
  line-height: 2.3em;
  width: auto;
  right: 0em;
  border: 1px solid #0076ff;
  color: #0076ff;
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
  height: 100%;
}
.right {
  text-align: right;
}
/* データ種別 */
.check-style {
  text-align: center;
}
.grid-list {
  border-collapse: collapse;
  margin: 0 auto;
  width: -webkit-fill-available;
}
/* グリッド用線 */
.grid-border {
  border-collapse: collapse;
}
/* del チェックリスト設定画面の変更箇所の行の背景色が緑色になるが、共通部品で変更箇所がわかるようにして、これを廃止する。 孔s start   */
/* 変更箇所 */
/* .changestyle {
  background-color: #ccffcc;
} */
/* del チェックリスト設定画面の変更箇所の行の背景色が緑色になるが、共通部品で変更箇所がわかるようにして、これを廃止する。 孔s start
/* del チェックリスト設定画面の並び順変更を修正する。孔s start */
/* .dispno-changestyle {
  background-color: #ffff66;
} */
/* del チェックリスト設定画面の並び順変更を修正する。孔s end */
/* ons-select :deep(.select-input){
  color: var(--ntss-base-color);
}
ons-select :deep(.select-input option){
  color: #000;
} */

.ntss-list-body-td {
  padding: 4px;
}
.ntss-list-body-tr:nth-child(2n) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.ntss-list-body-tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}
div :deep(.textareaCheckList) {
  width: 100%;
  box-sizing: border-box;
  border-radius: 5px;
  background-color:  #F7F7F7;
  border-width: 2px;
  height: 2em;
  border-radius: 5px;
}
div :deep(.textareaCheckList:focus) {
  border-top: 2px solid #9A9A9A;
  border-left: 2px solid #9A9A9A;
  border-bottom: 2px solid #EEEEEE;
  border-right: 2px solid #EEEEEE;
  box-sizing: border-box;
}

.custom-input-grid :deep(.text-input) {
  font-size: unset;
}

.custom-toolbar-btn :deep(.toolbar-btn) {
  font-size: unset;
}

.custom-input-invalid {
	color: black;
	background-color: rgba(255, 0, 0, 0.6);
}
:deep(.custom-input-edited>input[type="number"]), :deep(.custom-input-edited>select){
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
</style>
