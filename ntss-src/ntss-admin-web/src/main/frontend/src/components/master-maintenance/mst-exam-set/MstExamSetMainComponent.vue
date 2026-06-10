
<template>
  <div id="exam-set-modal-content">
    <!-- 名称など -->
    <div id="exam-set-form-wrapper" style="padding-bottom: 0.5px; min-width: 1050px;">
      <div id="exam-info-form-wrapper">
        <!-- １行目 -->
        <div id="exam-set-item">
        <v-ons-row class="input-row">
          <v-ons-col style="min-width: 160px" class="input-item-name">
            <label for="exam-set-name">検査セット名</label>
          </v-ons-col>
          <v-ons-col class="input-item-data">
              <v-ons-input
                  type="text"
                  input-id="exam-set-name"
                  :value="editRecord.name"
                  @change="changeButton"
                  @blur="updateEditRecord('name', $event)"
                  maxlength="40"
              ></v-ons-input>
          </v-ons-col>
          <!-- 検査セットマスタ変更 杜 start -->
          <!-- <v-ons-col style="display: flex;">
            <div class="exam-info-label-wrapper-right">
              <label for="is-in-hospital">院内院外<br>フラグ</label>
            </div>
            <div class="exam-info-input-wrapper">
              <v-ons-select
                class="exam-info-select-box"
                select-id="is-in-hospital"
                name="is-in-hospital"
                v-model="inputModel.is_in_hospital"
                @change="updateEditRecord('hospitalflg', $event)"
              >
                <option v-for="item in hospitalflgList" :value="item.keyName" :key="item.dispName" style="font-size: 1em;">
                  {{ item.dispName }}
                </option>
              </v-ons-select>
            </div>
          </v-ons-col>
          -->
          <!-- 検査セットマスタ変更 杜 end -->
        </v-ons-row>
          <!-- add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen start -->
          <!-- <v-ons-row class="input-row" style="flex-wrap: nowrap;">
            <v-ons-col style="display: flex;">
              <div class="input-item-name">
                <label for="is-in-hospital">院内院外フラグ</label>
              </div>
              <div class="input-item-data">
                <v-ons-select
                  class="exam-info-select-box"
                  select-id="is-in-hospital"
                  name="is-in-hospital"
                  v-model="inputModel.is_in_hospital"
                  @change="changeButton(),updateEditRecord('isInHospital', $event)"
                >
                  <option
                    v-for="item in hospitalflgList"
                    :value="item.keyName"
                    :key="item.dispName"
                  >{{ item.dispName }}</option>
                </v-ons-select>
              </div>
            </v-ons-col>
          </v-ons-row> -->
          <!-- add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen end -->

        <!-- ２行目 -->
        <v-ons-row style="flex-wrap: nowrap;" class="input-row">
          <v-ons-col  style="min-width: 160px"  class="input-item-name">
            <label for="exam-set-name">省略検査セット名</label>
          </v-ons-col>
          <v-ons-col class="input-item-data">
              <v-ons-input
                  style="min-width: 90px"
                  type="text"
                  input-id="exam-set-short-name"
                  :value="editRecord.shortname"
                  @change="changeButton"
                  @blur="updateEditRecord('shortname', $event)"
                  maxlength="40"
              ></v-ons-input>
          </v-ons-col>
        </v-ons-row>

        <!-- ３行目 -->
        <v-ons-row style="flex-wrap: nowrap;" class="input-row">
          <v-ons-col style="min-width: 160px" class="input-item-name">
            <label for="exam-set-class">セット使用区分</label>
          </v-ons-col>
          <v-ons-col class="input-item-data" style="display: flex;">
            <div style="margin-right:3%;">
              <v-ons-select
                class="exam-info-select-box"
                select-id="exam-set-class"
                name="exam-set-class"
                v-model="inputModel.exam_set_class"
                @change="changeButton(),updateEditRecord('examsetclass', $event)"
              >
                <option
                  v-for="item in examclassListcom"
                  :value="item.keyName"
                  :key="item.dispName"
                >{{ item.dispName }}</option>
              </v-ons-select>
            </div>
            <!-- 検査区分 -->
            <label for="exam-set-class" style="margin-right:3%;">検査区分</label>
            <div class="row-flex" style="margin-right:3%;">
              <v-ons-checkbox input-id="orderClassBeforeDialysis" value="1" v-model="examTypeListLocal" />
              <label for="orderClassBeforeDialysis">透析前</label>
            </div>
            <div class="row-flex" style="margin-right:3%;">
              <v-ons-checkbox input-id="orderClassAfterDialysis" value="2" v-model="examTypeListLocal" />
              <label for="orderClassAfterDialysis">透析後</label>
            </div>
            <div class="row-flex" style="margin-right:3%;">
              <v-ons-checkbox input-id="orderClassOther" value="0" v-model="examTypeListLocal" />
              <label for="orderClassOther">その他</label>
            </div>
          </v-ons-col>
        </v-ons-row>

        <!-- ４行目 -->
        <v-ons-row style="flex-wrap: nowrap;" class="input-row">
          <v-ons-col  style="min-width: 160px" class="input-item-name">
            <label for="other-exam-time">その他検査時刻</label>
          </v-ons-col>
          <v-ons-col class="input-item-data">
              <v-ons-input
                  style="min-width: 90px"
                  type="time"
                  input-id="other-exam-time"
                  :value="getTimeByField('examtime')"
                  @change="changeButton"
                  @blur="updateTimeRecord('examtime', $event)"
                  maxlength="4"
              ></v-ons-input>
          </v-ons-col>
          <v-ons-col class="input-item-name" style="max-width: 15%;min-width: 120px">
            <label >グラフセット</label>
          </v-ons-col>
          <v-ons-col class="input-item-data">
            <v-ons-checkbox
              name="graphsetCheckbox"
              :checked="checkedFlag"
              :disabled="selectingExamItemCd && selectingExamItemCd.length > 5"
              @change="updateEditRecord('graphset',$event)">
            </v-ons-checkbox>
          </v-ons-col>
        </v-ons-row>

        <!-- ５行目 -->
        <v-ons-row style="flex-wrap: nowrap;">
          <v-ons-col class="input-item-name" style="min-width: 160px">連携コード1</v-ons-col>
          <v-ons-col class="input-item-data" style="margin-right: 30px;">
               <v-ons-input
                  type="text"
                  input-id="exam-inhospital"
                  :value="editRecord.inHospitalCd1"
                  @change="changeButton"
                  @blur="updateEditRecord('inHospitalCd1', $event)"
                  maxlength="20"
                ></v-ons-input>
          </v-ons-col>
          <v-ons-col class="input-item-name">連携コード2</v-ons-col>
          <v-ons-col class="input-item-data" style="margin-right: 30px;">
               <v-ons-input
                  type="text"
                  input-id="exam-inhospital2"
                  :value="editRecord.inHospitalCd2"
                  @change="changeButton"
                  @blur="updateEditRecord('inHospitalCd2', $event)"
                  maxlength="20"
                ></v-ons-input>
          </v-ons-col>
          <v-ons-col class="input-item-name">連携コード3</v-ons-col>
          <v-ons-col class="input-item-data">
               <v-ons-input
                  type="text"
                  input-id="exam-inhospital3"
                  :value="editRecord.inHospitalCd3"
                  @change="changeButton"
                  @blur="updateEditRecord('inHospitalCd3', $event)"
                  maxlength="20"
                ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        </div>
        <v-ons-row style="margin-top: 10px;">
          <v-ons-col style="min-width: 160px" class="input-item-name">
          </v-ons-col>
          <!-- 一覧 -->
          <v-ons-col class="input-item-data">
            <div id="spitz-list-wrapper" class="print-height-auto">
              <table class="spitz-list">
                <thead>
                  <tr>
                    <th class="spitz-list-header">採血管名</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="(label, index) in calcLabelInfo"
                    :key="index"
                    :class="index%2 === 0 ? 'even-row' : 'odd-row'"
                  >
                    <td>{{ label.spitzName }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </v-ons-col>
        </v-ons-row>
      </div>
      <div class="exam-item-set-wrapper" :style="loadingFlag">
          <v-ons-row id="exam-item-set-btn-content" class="exam-item-set-row">
            <v-ons-col style="min-width: 160px" class="input-item-name">
              <div class="exam-item-title">
                <v-ons-col>セット情報</v-ons-col>
                <v-ons-col>
                  <button style="width:60px;padding: 0;margin-left: 2px; margin-block: 2px;" class="button btn3-normal" @click="addNewDropDown">追加</button>
                </v-ons-col>
              </div>
            </v-ons-col>
            <v-ons-col class="input-item-data">
              <div>
                <table class="exam-item-list">
                  <thead class="exam-item-list-thead">
                    <tr>
                      <th style="width: 95%;" class="exam-item-list-header">検査項目名</th>
                      <th style="width: 5%; min-width: 2em; text-align: center;" class="exam-item-list-header"/>
                    </tr>
                  </thead>
                  <tbody>
                    <tr ref="examDummyItem" class="non-display exam-dummy-item">
                      <th style="width: 5%; min-width: 2em; text-align: center; border: none;"></th>
                      <th style="width: 95%; border: none;"></th>
                    </tr>
                    <tr
                      v-for="(itemcd, index) in selectingExamItemCd"
                      :key="index"
                      :class="index%2 === 0 ? 'even-row' : 'odd-row'"
                    >
                      <td style="width: 95%; border: none;">
                        <kendo-dropdownlist
                          :value="itemcd"
                          :data-source="mstExamitem"
                          data-text-field="examItemName"
                          data-value-field="examItemCd"
                          :height="350"
                          :filter="'contains'"
                          @change="changeButton"
                          @select="createJsonByExamCd($event.dataItem.examItemCd, index)"
                          style="width: 99%; font-size: 1em;"
                        />
                      </td>
                      <td style="width: 5%; min-width: 2em; text-align: center; border: none;">
                        <button class="ntss-btn-outset button-delete" @click="deleteDropDown(index)">
                          <v-ons-icon icon="fa-trash"/>
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </v-ons-col>
          </v-ons-row>
      </div>

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
  </div>
</template>

<script>
import _ from 'lodash';
import { mapActions, mapGetters } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {deepCopy} from "@/functions/common/CommonFunctions";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
import {EventBus} from "@/eventBus";

//URI
const uriGetExamItem = "mstInfo/mstExamItem/";
const uriGetSpitz = "mstInfo/mstSpitz/";
const uriSelectorExamItem = "/mstInfo/mst_exam_item/mstSelector";
const uriSelectorSpitz = "/mstInfo/mst_spitz/mstSelector";

export default {
  name: "MstExamSet",

  components: {
    "message-dialog": messageDialog,
  },

  data() {
    return {
      // DBからのデータ(createdでとるだけ)
      mstExamitem: [],
      mstSpitz: [],
      facilityCd: "",
      // マスタ詳細画面がありません破棄メッセージ
      oldName:"",
      oldInHospitalCd1:"",
      oldInHospitalCd2:"",
      oldInHospitalCd3:"",
      oldShortname:"",
      oldExam:"",
      // 検査セット作成用
      ExamItemInfo: [],
      selectingExamItemCd: [],

      // ラベル情報作成用
      LabelInfo: [],
      calcLabelInfo: [],

      // ドロップダウンを選択した際のデータ
      selectedOrder: 0,
      // 高さ計算用
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      SpitzListHeight: 0,
      itemSetinfoHeight: 0,
     //8104心電図スイッチ
      facility_type : 0,
     //8104心電図スイッチ
      // メッセージダイアログ
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: "",
        type: "1",
        stringParams: [""]
      },
      // コンボボックスの選択リスト
      examclassList: [
        { keyName: "0", dispName: "両用", useable: false },
        { keyName: "1", dispName: "依頼専用", useable: false },
        { keyName: "2", dispName: "結果専用", useable: false },
        { keyName: "3", dispName: "生理検査", useable: false }
      ],
      emergencyList: [
        { keyName: "0", dispName: "通常", useable: false },
        { keyName: "1", dispName: "至急可", useable: false }
      ],
      divList: [
        { keyName: "0", dispName: "使用しない", useable: false },
        { keyName: "1", dispName: "使用する", useable: false }
      ],

      inputModel: {
        exam_set_class: "0",
        can_emergency: "0",
        exam_item_info: "0",
        label_info: "0"
        // add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen start
        // , is_in_hospital: "0"
        // add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen end
      },
      checkedFlag:false,
      loadingFlag: "visibility:hidden",
      setIntervalObj: null,
      // 【EOL対応内部】#6994 zhou add start
      addFlag: false,
      deleteFlag: false,
      // 【EOL対応内部】#6994 zhou add end
      // add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen start
      // ,hospitalflgList: [{keyName: "0", dispName: "院外"}, {keyName: "1", dispName: "院内"}]
      // add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen end
      examTypeListLocal: [], // 検査区分
      initRecord: null, // 初期値
    };
  },

  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    normalizedColumnDefinition() {
      // データの定義にあわせてcolumnを正規化する。
      const recordKeys = Object.keys(this.editRecord);
      return this.columnDefinition.filter(cd => recordKeys.includes(cd.field));
    },
   //8104   心電図展示       ljg Start
      examclassListcom(){
        // mod 10125 一般検査⇔生理検査の変更を不可能とする 関 start
        if (this.editRecord.isAddRow) {
          return  this.examclassList.filter((item)=>{
            return (item.keyName==3 && this.facility_type == 1)|| item.keyName!=3
            })
        }else {
          if (this.editRecord.examsetclass == "3") {
            return  this.examclassList.filter((item)=>{
              return (item.keyName==3 && this.facility_type == 1)
              })
          }else if (this.editRecord.examsetclass == "0" || this.editRecord.examsetclass == "1" || this.editRecord.examsetclass == "2"){
            return  this.examclassList.filter((item)=>{
              return item.keyName!=3
              })
            }
        }
        // mod 10125 一般検査⇔生理検査の変更を不可能とする 関 end
    }
   //8104   心電図展示       ljg end
  },

  async created() {
   //8104   心電図展示       ljg Start
     ApiHelper.get("/mst_synchro/sysFunctionAdvanced_facilitycd",{ facilityCd: this.getFacilitySwitch }).then(r =>{
      this.facility_type = r.data;});
   //8104   心電図展示       ljg end
    this.setLoadingScreenVisible(true);
    // 初期値設定ここから ----------
    this.inputModel.exam_set_class = this.getSelectByField("examsetclass");
    this.inputModel.can_emergency = this.getSelectByField("emergencyflg");
    // add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen start
    // this.inputModel.is_in_hospital = this.getSelectByField("isInHospital");
    // add #10027 検査セットマスタ・検査項目マスタの院外院内設定について dengshen end
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    this.oldName = this.editRecord.name;
    this.oldInHospitalCd1 = this.editRecord.inHospitalCd1;
    this.oldInHospitalCd2 = this.editRecord.inHospitalCd2;
    this.oldInHospitalCd3 = this.editRecord.inHospitalCd3;
    this.oldShortname = this.editRecord.shortname;
    this.oldExam = this.inputModel.exam_set_class;
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    // 検査項目一覧を取得
    // add マスタ一覧 施設切替を可能とする 王 start
    // const respExamItem = await ApiHelper.get(uriGetExamItem, { facilityCd: this.getStateUserAccountInfo.facilityCd })
    const respExamItem = await ApiHelper.get(uriGetExamItem, { facilityCd: this.getFacilitySwitch })
    // add マスタ一覧 施設切替を可能とする 王 end
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstExamSetMainComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });

    // 検査項目表示順を取得
    // add マスタ一覧 施設切替を可能とする 王 start
    // const respExamItemSelector = await ApiHelper.get(uriSelectorExamItem, { facilityCd: this.getStateUserAccountInfo.facilityCd })
    const respExamItemSelector = await ApiHelper.get(uriSelectorExamItem, { facilityCd: this.getFacilitySwitch })
    // add マスタ一覧 施設切替を可能とする 王 end
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstExamSetMainComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });

    // 検査項目一覧を作成（表示順つき）
    let dispOrder = 999; // 表示順(初期値999)
    for (let i = 0; i < respExamItem.data.length; i++) {
      for (
        let j = 0;
        j < respExamItemSelector.data.orderSettings.items.length;
        j++
      ) {
        if (
          respExamItemSelector.data.orderSettings.items[j].code ===
          respExamItem.data[i].examItemCd
        ) {
          dispOrder = j;
        }
      }
      // 削除済みの検査項目は対象外
      if (respExamItem.data[i].isDisp == "0") {
        continue;
      }
      this.mstExamitem.push({
        examItemName: respExamItem.data[i].examItemName,
        examItemCd: respExamItem.data[i].examItemCd,
        spitzCd: respExamItem.data[i].spitzCd,
        disp_order: dispOrder,
        isInHospital: respExamItem.data[i].isInHospital
      });
    }

    this.$nextTick(() => {
      // ソート
      this.mstExamitem.sort((a, b) => {
        if (a.disp_order > b.disp_order) {
          return 1;
        } else {
          return -1;
        }
      });

      // 未登録を追加
      this.mstExamitem.unshift({
          examItemName: " ",
          examItemCd: 0,
          spitzCd: "0",
          disp_order: "0",
          isInHospital: ""
        });
    });

    // 採血管一覧を取得
    // add マスタ一覧 施設切替を可能とする 王 start
    // const respSpitz = await ApiHelper.get(uriGetSpitz, { facilityCd: this.getStateUserAccountInfo.facilityCd })
    const respSpitz = await ApiHelper.get(uriGetSpitz, { facilityCd: this.getFacilitySwitch })
    // add マスタ一覧 施設切替を可能とする 王 end
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstExamSetMainComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });

    // 採血管表示順を取得
    // add マスタ一覧 施設切替を可能とする 王 start
    // const respSpitzSelector = await ApiHelper.get(uriSelectorSpitz, { facilityCd: this.getStateUserAccountInfo.facilityCd })
    const respSpitzSelector = await ApiHelper.get(uriSelectorSpitz, { facilityCd: this.getFacilitySwitch })
    // add マスタ一覧 施設切替を可能とする 王 end
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstExamSetMainComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        throw error;
      });

    // 採血管一覧を作成（表示順つき）
    dispOrder = 999; // 表示順(初期値999)
    for (let k = 0; k < respSpitz.data.length; k++) {
      for (
        let l = 0;
        l < respSpitzSelector.data.orderSettings.items.length;
        l++
      ) {
        if (
          respSpitzSelector.data.orderSettings.items[l].code ==
          respSpitz.data[k].spitzCd
        ) {
          dispOrder = l;
        }
      }
      this.mstSpitz.push({
        spitzCd: respSpitz.data[k].spitzCd,
        spitzName: respSpitz.data[k].spitzName,
        isDisp: respSpitz.data[k].isDisp,
        disp_order: dispOrder
      });
    }

    // 現状の検査セットを取得
    if (this.getValueByField('iteminfo') === "") {
      this.ExamItemInfo = await JSON.parse('[]');
    } else {
      this.ExamItemInfo = await JSON.parse(this.getValueByField('iteminfo'));
    }

    // 現状のラベル情報を取得
    // if (this.getValueByField('labelinfo') === "") {
    //   this.LabelInfo = await JSON.parse('[]');
    // } else {
    //   this.LabelInfo = await JSON.parse(this.getValueByField('labelinfo') ? this.getValueByField("labelinfo") : "[]");
    // }
    this.LabelInfo = [];

    // 初期値設定ここまで ----------

    // セレクトボックス関係ここから ----------
    // 選択済み項目コードをつくる
    // JSONから変換したオブジェクト ExamItemInfo を一時変数に入れる
    this.$nextTick(() => {
      // 選択中の検査項目リスト に格納
      for (let i = 0; i < this.ExamItemInfo.length; i++) {
        if (typeof this.ExamItemInfo[i].exam_item_cd === "undefined") {
          // undefinedの場合は対象外
          continue;
        }
        this.selectingExamItemCd.push(this.ExamItemInfo[i].exam_item_cd);
      }

      // データが何も無い場合、ドロップダウンリストを１つ追加する
      if (this.selectingExamItemCd.length == 0) {
        this.addNewDropDown();
        this.$nextTick(() => {
          this.keepCheckBoxStyle();
        })
      }
      const itemInfo = this.editRecord['iteminfo'] === "" ? [] : deepCopy(JSON.parse(this.editRecord['iteminfo']));
      const examItemInfo = deepCopy(this.ExamItemInfo)
      let itemInfoSize = 0;
      itemInfo.forEach( item => {
        examItemInfo.forEach( exam => {
          if (exam.exam_item_cd === item.exam_item_cd && exam.exam_item_name === item.exam_item_name) {
            itemInfoSize++;
          }
        })
      });
      // JSONをStoreに入れる
      this.editRecord['iteminfo'] = JSON.stringify(this.ExamItemInfo);
      if (itemInfoSize !== itemInfo.length) {
        this.setEditRecord(this.editRecord);
      }
      this.inputModel.exam_item_info = this.getValueByField('iteminfo');
      // ラベル情報を更新する
      this.createLabelInfo();
    });

    // セレクトボックス関係ここまで ----------
    this.loadingFlag = "";
    if (this.editRecord.graphset =='1'){
        this.checkedFlag = true;
      }

    this.$nextTick(() => {
      this.keepCheckBoxStyle();
    })


    this.setIntervalObj = window.setInterval(() => {
      setTimeout(this.keepCheckBoxStyle(), 0)
    }, 100)
    /* 画面表示用に検査区分を設定 */
    this.examTypeListLocal = this.editRecord.orderClass ? JSON.parse(this.editRecord.orderClass) : [];
    // 初期表示値
    this.editRecord.graphset = this.editRecord.graphset || "0";
    this.initRecord = JSON.parse(JSON.stringify(this.editRecord));
  },

  beforeDestroy() {
    if (this.setIntervalObj) {
      clearInterval(this.setIntervalObj);
    }
  },

  watch: {
    // add 9403 検査結果グラフのレンジが正しく表示されていない zkm start
    //mod マスタ詳細画面がありません破棄メッセージ 张博 start
    // editRecord:{
    //   handler(){
    //     if (this.editRecord.shortname === "") {
    //       this.editRecord.shortname = null;
    //     }
    //     if (this.editRecord.inHospitalCd1 === "") {
    //       this.editRecord.inHospitalCd1 = null;
    //     }
    //     if (this.editRecord.inHospitalCd2 === "") {
    //       this.editRecord.inHospitalCd2 = null;
    //     }
    //     if (this.editRecord.inHospitalCd3 === "") {
    //       this.editRecord.inHospitalCd3 = null;
    //     }
    //    if (this.editRecord.name !== this.oldName ||
    //    this.editRecord.shortname !== this.oldShortname ||
    //    this.inputModel.exam_set_class !== this.oldExam ||
    //    this.editRecord.inHospitalCd1 !== this.oldInHospitalCd1 ||
    //    this.editRecord.inHospitalCd2 !== this.oldInHospitalCd2 ||
    //    this.editRecord.inHospitalCd3 !== this.oldInHospitalCd3
    //    // 【EOL対応内部】#6994 zhou add start
    //    || this.deleteFlag || this.addFlag
    //    // 【EOL対応内部】#6994 zhou add end
    //    ) {
    //     this.changeButton();
    //    }else{
    //      EventBus.$emit("mstHolidayRegistered", true);
    //    }
    //   },
    //   deep:true
    // },
    //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    // add 9403 検査結果グラフのレンジが正しく表示されていない zkm end
    windowHeight() {
      this.calculateInfoAndListHeight();
    },
    windowWidth() {
      this.scrollHandler();
    },
    getFontSize() {
      this.calculateInfoAndListHeight();
    },
    calcLabelInfo(){
      this.calculateInfoAndListHeight();
    },
    selectingExamItemCd (){
     if (this.selectingExamItemCd.length && this.selectingExamItemCd.length > 5) {
        this.checkedFlag = false;
        this.editRecord["graphset"] = "0"
         document.getElementsByName("graphsetCheckbox")[0].checked = false;
        this.setEditRecord(this.editRecord);
     }
    },
    /** 検査区分の状態監視 */
    examTypeListLocal(newVal) {
      const jsonString = JSON.stringify(newVal);
      this.editRecord.orderClass = jsonString;
      this.setEditRecord(this.editRecord);
    },
    /** 編集項目の状態監視 */
    editRecord: {
      handler(newVal) {
        /* JSON文字列や空値を安全に配列へ変換する内部関数 */
        const safeParseArray = (val) => {
          if (Array.isArray(val)) return val;
          if (!val) return [];
          try {
            return JSON.parse(val);
          } catch {
            return [];
          }
        };
        /* recordの各フィールドをパースして整形する内部関数 */
        const normalize = (record) => {
          return {
            ...record,
            iteminfo: safeParseArray(record.iteminfo),
            labelinfo: safeParseArray(record.labelinfo),
            orderClass: safeParseArray(record.orderClass),
          };
        };
        /* 差分チェック内部関数 */
        const deepDiff = (obj1, obj2, path = '') => {
          if (_.isEqual(obj1, obj2)) return;

          if (_.isArray(obj1) && _.isArray(obj2)) {
            const sorted1 = _.sortBy(obj1, JSON.stringify);
            const sorted2 = _.sortBy(obj2, JSON.stringify);
            if (!_.isEqual(sorted1, sorted2)) {
              diffList.push(path || '(root)');
            }
          } else if (_.isObject(obj1) && _.isObject(obj2)) {
            const keys = _.union(Object.keys(obj1), Object.keys(obj2));
            keys.forEach(key => {
              deepDiff(obj1[key], obj2[key], path ? `${path}.${key}` : key);
            });
          } else {
            diffList.push(path || '(root)');
          }
        };
        // 差分リスト初期化
        const diffList = [];
        // 初期表示値
        const normalizedInit = normalize(this.initRecord);
        // 編集項目
        const normalizedEdit = normalize(newVal);
        // 初期表示値と編集項目との差分チェック
        deepDiff(normalizedInit, normalizedEdit);
        EventBus.$emit("mstHolidayRegistered", diffList.length == 0);
      },
      deep: true
    },
  },

  async mounted() {
    // スクロールイベントを追加する
    let modalObj = document.getElementsByClassName("modal-body");
    modalObj[0].addEventListener('scroll', this.scrollHandler);

    // フラグ系セレクトボックスのフォントサイズ変更
    document.getElementsByTagName(
      "ons-select"
    )[0].firstElementChild.style.fontSize = "1em";
    document.getElementsByTagName(
      "ons-select"
    )[1].firstElementChild.style.fontSize = "1em";
    this.calculateInfoAndListHeight();
    const itemSetinfoHeightStr = this.itemSetinfoHeight.toString() + "px";
    const spitzSetHeightStr = this.SpitzListHeight.toString() + "px";
    document.getElementsByClassName(
      "exam-item-set-wrapper"
    )[0].style.minHeight = itemSetinfoHeightStr;
    document.getElementById(
      "spitz-list-wrapper"
    ).style.height = spitzSetHeightStr;
    this.$nextTick(() => {
      this.keepCheckBoxStyle();
    })
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
  },

  methods: {
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible"
    }),
    ...mapActions("master-maintenance", ["setEditRecord"]),

    // モーダルの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const modal = document.getElementsByClassName("modal-container")[0];
      const modalHeight = modal.clientHeight;
      const modalHeaderHeight = modal.firstElementChild.clientHeight;
      const modalFooterHeight = modal.lastElementChild.clientHeight;
      const tabHeight = 66;
      const btnHeight = 45;
      const offset = 50;
      const contentAreaHeight =
        modalHeight - modalHeaderHeight - modalFooterHeight - offset;
      const gridOffsetHeight = tabHeight + btnHeight;
      const gridHeight = contentAreaHeight - gridOffsetHeight;
      this.kendoGridToolbarHeight =
        500 > contentAreaHeight ? 500 : contentAreaHeight;
      this.kendoGridHeight =
        this.kendoGridToolbarHeight - gridOffsetHeight > gridHeight
          ? this.kendoGridToolbarHeight - gridOffsetHeight
          : gridHeight;
    },
    calculateInfoAndListHeight() {
      let fontSize = parseInt(window.getComputedStyle(document.getElementById("spitz-list-wrapper")).fontSize, 10);

      // 採血管名の高さを計算
      if(this.calcLabelInfo.length == 0){
          document.getElementById("spitz-list-wrapper").style.height = (3*fontSize) + 4 + "px";
      }else if(this.calcLabelInfo.length <= 5){
          document.getElementById("spitz-list-wrapper").style.height = ((this.calcLabelInfo.length*3 + 3)*fontSize) + 4 +"px" ;
      }
      else
      {
        document.getElementById("spitz-list-wrapper").style.height = (18*fontSize) + 4 +"px" ;
      }

      // モーダル内部の高さを取得
      const modalBody = document.getElementsByClassName("modal-body")[0];
      const modalBodyHeight = modalBody.clientHeight;
      // 付帯情報部分の高さを取得
      const examInfoWrapper = document.getElementById("exam-info-form-wrapper");
      const examInfoWrapperHeight = examInfoWrapper.clientHeight;
      const remainHeight =modalBodyHeight - examInfoWrapperHeight - 3;
      document.getElementsByClassName("exam-item-set-wrapper")[0].style.minHeight = remainHeight + "px";
      // 縦スクロールバー表示
      let modalObj = document.getElementsByClassName("modal-body");
      if (modalObj.length >= 1){
        modalObj[0].classList.remove("modal-overflow-hidden");
        modalObj[0]?.classList?.add("modal-scroll");
      }
    },

    getTimeByField(field) {
      let strtime = this.editRecord[field];
      return strtime.substr(0,2) + ":" + strtime.substr(2,2);
    },
    getValueByField(field) {
      return this.editRecord[field];
    },
    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },
    getGraphSet(e) {
      if (e.currentTarget.checked) {
        this.editRecord.graphset = '1';
      }else{
        this.editRecord.graphset = '0';
      }
    },
    // String(0 or 1)を取得
    // 空欄の場合は0を返す
    getSelectByField(field) {
       if (this.editRecord[field] === null || this.editRecord[field] === "") {
        return 0;
       } else {
        return this.editRecord[field];
       }
    },
    // String(0:false,1:true)をBoolに変換して取得
    getBoolByField(field) {
      switch (this.editRecord[field]) {
        case "0":
          return false;
        case "1":
          return true;
        default:
          return false;
      }
    },

    // Json作成用
    createJsonByExamCd(value, order){
      // もらうデータの表示
      // itemcd に event.dataItem.value を使う
      this.selectedOrder = order;

      // 選択した値が既にリストに存在するか確認
      // 存在しない場合は0 存在する場合は何要素目かを返す
      let selIndex = this.selectingExamItemCd.indexOf(value);

      // selectingExamItemCdの編集
      // orderは0始まりの値をそのまま入れる
      this.selectingExamItemCd[order] = value;
      this.selectingExamItemCd.splice();

      // 重複の確認 重複の場合ダイアログを出す
      if (selIndex >= 0 && selIndex != order && value != 0) {
        // 検査項目情報の取得
        // 検査項目IDでフィルタリングするので一意のはず
        let selExamItem = this.mstExamitem.filter(item => item.examItemCd == value);
        let selExamItemName = selExamItem[0].examItemName;    // 検査項目名称

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
      // selectingExamItemCdの編集
      // 空欄に戻すため"0"を入れる
      if (answer === 'OK') {
        this.selectingExamItemCd[this.selectedOrder] = 0;
        this.selectingExamItemCd.splice();
        this.selectedOrder = 0;
        // JSONの作成
        this.refreshExamJson();
      }
    },

    // selectingExamItemCd をもとにJSONをつくる
    refreshExamJson(){
      // ExamItemInfoを初期化
      this.ExamItemInfo = [];

      // ExamItemInfoをつくる
      // selectingExamItemCdを変換してpushしていく
      for (let i = 0; i < this.selectingExamItemCd.length; i++) {
        if (this.selectingExamItemCd[i] == 0 || typeof this.selectingExamItemCd[i] === "undefined") {
          // 空欄もしくはundefinedは対象外
          continue;
        }

        // 検査項目情報の取得
        // 検査項目IDでフィルタリングするので一意のはず
        let selExamItem = this.mstExamitem.filter(item => item.examItemCd == this.selectingExamItemCd[i]);
        if (selExamItem.length === 0){
          continue;
        }

        let selExamItemName = selExamItem[0].examItemName;    // 検査項目名称

        this.ExamItemInfo.push({
          exam_item_cd: this.selectingExamItemCd[i],
          exam_item_name: selExamItemName
        });
      }

      // JSONにしてinputModelに代入
      this.editRecord['iteminfo'] = JSON.stringify(this.ExamItemInfo);
      this.setEditRecord(this.editRecord);
      this.inputModel.exam_item_info = this.getValueByField('iteminfo');

      // ラベル情報を更新する
      this.createLabelInfo();
    },

    // ドロップダウン追加
    addNewDropDown(){
      // 【EOL対応内部】#6994 zhou add start
      this.addFlag = true;
      // 【EOL対応内部】#6994 zhou add end
      this.selectingExamItemCd.push(0);
      this.refreshExamJson();
      this.$nextTick(() => {
        this.keepCheckBoxStyle();
      })
      this.changeButton();

      // 最後までスクロールする
      this.$nextTick(() => {
        const ele = document.getElementsByClassName("modal-body")[0];
        if (ele) {
          ele.scrollTop = ele.scrollHeight;
        }
      });
    },

    // ドロップダウン削除
    deleteDropDown(i){
      this.deleteFlag = true;
      this.selectingExamItemCd.splice(i, 1);
      this.refreshExamJson();
      this.changeButton();
    },

    // ラベル情報の作成/更新/削除
    createLabelInfo() {
      // LabelInfo(DB保存用ラベル情報)に入っている採血管コードのリスト
      let spitz_cd_list = [];

      // 採血管コードのリスト確認フラグ
      let spitz_cd_list_flg = [];

      // LabelInfo(DB保存用ラベル情報)をもとにcalclabelInfo(表示用のラベル情報)をつくる (初回)
      if (this.calcLabelInfo.length == 0) {
        for (let i = 0; i < this.LabelInfo.length; i++) {
          // 採血管情報の取得
          const lblSpitz = this.mstSpitz.filter(item => item.spitzCd == this.LabelInfo[i].spitz_cd);
          // 採血管情報なし または 削除済みの採血管は対象外
          if (lblSpitz.length === 0 || lblSpitz[0].isDisp == "0"){
            continue;
          }
          const isInHospital = this.LabelInfo[i].spitzName?.includes("（院内）") ? '1' : '0';
          const lblSpitzName = lblSpitz[0].spitzName + (isInHospital === "1" ? "（院内）" : "（院外）");   // 採血管名
          const lbldispOrder = lblSpitz[0].disp_order;   // 表示順

          this.calcLabelInfo.push({
            spitz_cd: this.LabelInfo[i].spitz_cd,
            disp_order: lbldispOrder,
            spitzName: lblSpitzName
          });

          spitz_cd_list.push(this.LabelInfo[i].spitz_cd + '-' + isInHospital);
          // 採血管コードのリスト確認
          spitz_cd_list_flg.push(0);
        }
      } else {
        for (let n = 0; n < this.LabelInfo.length; n++) {
          const isInHospital = this.LabelInfo[n].spitzName.includes("（院内）") ? '1' : '0';
          spitz_cd_list.push(this.LabelInfo[n].spitz_cd + '-' + isInHospital);
          // 採血管コードのリスト確認
          spitz_cd_list_flg.push(0);
        }
      }
      // 選択中の検査項目リストと突き合わせてラベル情報を作成（存在しない場合）
      for (let k = 0; k < this.selectingExamItemCd.length; k++) {
        const selItemCd = this.selectingExamItemCd[k];

        // 検査項目情報の取得
        // 検査項目IDでフィルタリングするので一意のはず
        const selExamItem = this.mstExamitem.filter(item => item.examItemCd == selItemCd);
        if (selExamItem.length === 0){
          continue;
        }
        const selSpitzCd = selExamItem[0].spitzCd;    // ★採血管コード(String)

        // 検査項目で指定している採血管コードの検索
        // 採血管コードのリストに存在するか
        const listindex = spitz_cd_list.indexOf(selSpitzCd + '-' + (selExamItem[0]?.isInHospital || 0));
        // 表示用のラベル情報に存在するか
        // const labelIndex = this.calcLabelInfo.findIndex(({spitz_cd}) => spitz_cd === selSpitzCd);

        // 空欄の検査項目は対象外
        if (selItemCd == 0) {
          continue;
        }

        if (listindex == -1) {
          // 存在しない場合はラベル情報を作成

          // 重複する採血管の場合、作成しない
          // if (labelIndex >= 0) {
          //   continue;
          // }

          // 採血管情報の取得
          const selSpitz = this.mstSpitz.filter(item => item.spitzCd == selSpitzCd);
          // 削除済みの採血管の場合、作成しない
          if (selSpitz.length === 0) {
            continue;
          }
          const isInHospital = selExamItem[0].isInHospital || '0';
          const selSpitzName = selSpitz[0].spitzName + (isInHospital === '1' ? "（院内）" : "（院外）");   // 採血管名
          const selIsDisp = selSpitz[0].isDisp;           // 削除フラグ
          const seldispOrder = selSpitz[0].disp_order;   // 表示順

          // 削除済みの採血管の場合、作成しない
          if (selIsDisp == "0") {
            continue;
          }

          this.calcLabelInfo.push({
            spitz_cd: selSpitzCd,   // JSONには数値で入れる
            disp_order: seldispOrder,
            spitzName: selSpitzName,
            isInHospital
          });
        } else {
          // 採血管コードのリスト確認
          spitz_cd_list_flg[listindex] = 1;
        }

      }

      // calcLabelinfoのソート
      this.calcLabelInfo.sort((a, b) => {
        if (a.disp_order > b.disp_order || (a.disp_order === b.disp_order && a.isInHospital > b.isInHospital)) {
          return 1;
        } else {
          return -1;
        }
      });
      // 余剰ラベル情報を削除
      for (let m = 0; m < spitz_cd_list.length; m++) {
        if (spitz_cd_list_flg[m] == 0) {
          const [spizeCd, isInHospital] = spitz_cd_list[m].split('-');
          const labelIndex = this.calcLabelInfo.findIndex(({spitz_cd, spitzName}) => {
            return spitz_cd === spizeCd && (spitzName.includes('（院内）') ? (isInHospital === '1') : (isInHospital === '0'));
          });
          this.calcLabelInfo.splice(labelIndex, 1);
        }
      }
      // calcLabelInfoをもとにLabelInfoをつくる（一部削除する）
      this.LabelInfo = deepCopy(this.calcLabelInfo);
      // 不要な要素を削除
      // for (let l = 0; l < this.LabelInfo.length; l++) {
      //   delete this.LabelInfo[l].spitzName;
      // }
      // #9863 Error in nextTick: "TypeError: itemInfo.forEach is not a function" 横展開2 linjunfeng start
      // const itemInfo = this.editRecord['labelinfo'] === "" ? [] : deepCopy(JSON.parse(this.editRecord['labelinfo']));
      const itemInfo = !this.editRecord['labelinfo'] ? [] : deepCopy(JSON.parse(this.editRecord['labelinfo']));
      // #9863 Error in nextTick: "TypeError: itemInfo.forEach is not a function" 横展開2 linjunfeng end
      const labelInfo = deepCopy(this.LabelInfo)
      let itemInfoSize = 0;
      itemInfo.forEach( item => {
        labelInfo.forEach( label => {
          if (label.spitz_cd === item.spitz_cd && label.disp_order === item.disp_order) {
            itemInfoSize++;
          }
        })
      });
      // JSONをStoreに入れる
      this.editRecord['labelinfo'] = "[]";
      if (itemInfoSize !== itemInfo.length) {
        this.setEditRecord(this.editRecord);
      }
      this.inputModel.label_info = this.getValueByField('labelinfo');
    },

    updateEditRecord(key, ev) {
      if(key == 'graphset') {
        if (ev.currentTarget.checked) {
          this.editRecord.graphset = '1';
        }else{
          this.editRecord.graphset = '0';
        }
        this.editRecord[key] = this.editRecord.graphset
      }else{
         this.editRecord[key] = ev.target.value;
      }
      this.setEditRecord(this.editRecord);
    },
    updateTimeRecord(key, ev) {
      let strtime = ev.target.value;
      this.editRecord[key] = strtime.substr(0,2) + strtime.substr(3,2);
      this.setEditRecord(this.editRecord);
    },
    // 更新用メソッド(チェックボックス)
    updateCheckRecord(key, ev) {
      if (ev.target.checked === false) {
        this.editRecord[key] = "0";
      } else if (ev.target.checked === true) {
        this.editRecord[key] = "1";
      }
      this.setEditRecord(this.editRecord);
    },
    keepCheckBoxStyle() {
      let list = document.getElementsByClassName("checkbox__checkmark checkbox--material__checkmark");
      if (list.length > 0) {
        for (let i = 0; i < list.length; i++) {
          list[0].classList.remove("checkbox--material__checkmark");
        }
      }
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    /**
     * スクロール時に要素を調整する
     */
    scrollHandler() {
      const body = document.getElementsByClassName('modal-body')[0];
      const examItemList  = document.getElementsByClassName('exam-item-list')[0];
      const examItemListThead  = document.getElementsByClassName('exam-item-list-thead')[0];
      const examItemTitle  = document.getElementsByClassName('exam-item-title')[0];

      let targetTop = examItemList.getBoundingClientRect().top;
      let bodyTop = body.getBoundingClientRect().top;
      if (targetTop < bodyTop) {
        this.$refs.examDummyItem.classList.remove('non-display');
        examItemListThead?.classList?.add('scroll');
        examItemListThead.style.left = examItemList.offsetLeft - body.scrollLeft + 'px';
        examItemListThead.style.width = examItemList.offsetWidth - 0.5 + 'px';
        examItemListThead.style.clip = `rect(0px, ${body.offsetLeft + body.offsetWidth - examItemListThead.offsetLeft}px, 500px, ${-examItemListThead.offsetLeft}px)`;

        examItemTitle?.classList?.add('scroll');
        examItemTitle.style.left = 6 - body.scrollLeft + 'px';
        examItemTitle.style.clip = `rect(0px, 500px, 500px, ${-examItemTitle.offsetLeft}px)`;
      } else {
        this.$refs.examDummyItem?.classList?.add('non-display');
        examItemListThead.classList.remove('scroll');
        examItemTitle.classList.remove('scroll');
      }
    }
  }
};
</script>

<style scoped>
@media print {
  .print-height-auto{
    height: auto !important;
  }
}
table {
  border-collapse: collapse;
}
table th,
table td {
  border: solid 1px var(--ntss-list-border-color) !important;
}
.modal-scroll {
  overflow-x: hidden;
  overflow-y: scroll;
}
#spitz-list-wrapper {
  width: 100%;
  height: 10em;
  overflow-y: auto;
}

/* .exam-item-set-wrapper {
  font-size: 1.0em;
  width: 100%;
  overflow: hidden;
  border: solid 1px var(--ntss-list-border-color);
} */
.exam-item-set-label {
  font-size: 1.0em;
  vertical-align: top;
  width: 18%;
  position: absolute;
}
.exam-item-set-table {
  width: 82%;
  margin: 0 0 0 auto;
}

.exam-info-select-box {
  font-size: 1.0em;
  width: 6em;
}
.exam-info-label-wrapper-left {
  display: contents;
}
.exam-info-label-wrapper-left label{
  width: 20%;
}
.exam-info-label-wrapper-left2 {
  display: contents;
}
.exam-info-label-wrapper-left3 {
  display: contents;
}
.exam-info-label-wrapper-right {
  width: 25%;
}
.exam-info-input-wrapper {
  margin: 0px 5%;
  width: 76%;
}
.exam-info-check-box-content {
    margin: 1% 1%;
}
.exam-info-check-box-wrapper {
  display: flex;
  margin: 1% 0;
}

/** iPhone X/8/7/6 or iPad or Android(M,L) */
/** Device Width:360-768                   */
@media only screen and (min-device-width:360px) and (max-device-width:768px) {
  .exam-info-label-wrapper-left {
    width: 40%;
  }
  .exam-info-label-wrapper-left2 {
    width: 34%;
  }
  .exam-info-label-wrapper-right {
    width: 40%;
  }
  .exam-info-input-wrapper {
    margin: 0px 5%;
    width: 50%;
  }
  .exam-info-check-box-wrapper {
    display: flex;
    width: fit-content;
    margin: 1% 0;
    margin-left: auto;
    margin-right: auto;
  }
}

table.exam-item-list {
  border-collapse: collapse;
  width: 100%;
}
table.exam-item-list th,
table.exam-item-list td {
  border: solid 1px var(--ntss-list-border-color);
}
table.exam-item-list {
  margin: 0 auto;
}
table.exam-item-list thead {
  color: white;
  background-color: var(--ntss-list-header-background-color);
}
table.exam-item-list thead tr {
  height: 30px;
}
table.exam-item-list thead tr th.exam-item-list-header {
  z-index: 1;
  background-color: var(--ntss-list-header-background-color);
  border: solid 1px var(--ntss-list-border-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
}
table.exam-item-list tbody tr.even-row {
  background-color: var(--ntss-base-background-color);
}
table.exam-item-list tbody tr.even-odd {
  background-color: rgba(33, 37, 41, 0.03);
}
table.exam-item-list tbody tr td.email-send-checkbox {
  text-align: center;
}


table.spitz-list {
  border-collapse: collapse;
}
table.spitz-list th,
table.spitz-list td {
  border: solid 1px var(--ntss-list-border-color);
}
table.spitz-list {
  margin: 0 auto 0 0;
  width: 98%;
}
table.spitz-list thead {
  color: white;
  background-color: var(--ntss-list-header-background-color);
}
table.spitz-list thead tr {
  height: 30px;
}
table.spitz-list thead tr th.spitz-list-header {
  z-index: 1;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
  width: 20%;
}
table.spitz-list tbody tr {
  height: 3em;
}
table.spitz-list tbody tr.even-row {
  background-color: white;
}
table.spitz-list tbody tr.even-odd {
  background-color: rgba(33, 37, 41, 0.03);
}
table.spitz-list tbody tr td.email-send-checkbox {
  text-align: center;
}
.input-item-name {
  width: 15%;
  max-width: 15%;
  margin-left: 5px;
}
@media screen and (max-width: 1050px){
  .input-item-name {
    max-width: 9rem;
  }
}
.input-item-data{
  padding-bottom: 3px;
  padding-left: 3px;
  padding-right: 3px;
}

.input-row {
  margin-bottom: 18px;
}
.inshopital-width {
  width: 29%;
  float: left;
}

.inshopital-width-margin {
  margin-left: 79px;
}

.exam-item-list-thead.scroll {
  top: 50px;
  position: fixed;
  z-index: 2;
  display: table;
}
.non-display{
  display: none !important;
}
.exam-item-title.scroll {
  top: 50px;
  position: fixed;
  z-index: 2;
}
.exam-item-set-wrapper{
  border: 1px solid;
}

/* スマホ対応 */
@media screen and (max-width: 420px) {
  .inshopital-width-margin {
    margin-left: 10px;
  }
}
</style>
