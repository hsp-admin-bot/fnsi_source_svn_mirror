/**
 * 計算式入力
 */
<template>
  <transition name="modal">
    <div class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container" id="editFormulaModalContainer">
          <div class="modal-header">
            <ons-toolbar>
              <div class="left toolbar__title" style="padding-left: 0.5em;">
                検査計算式編集
              </div>
              <div class="right">
                <ons-toolbar-button class="close-btn" @click="cancel">
                  <ons-icon icon="fa-times"></ons-icon>
                </ons-toolbar-button>
              </div>
            </ons-toolbar>
          </div>
          <div class="modal-body">
            <div class="inputFormulaArea">
              <div style="display: flex; flex-wrap: nowrap; height: 100%;">
                <div style="flex: 1;">
                  <textarea
                    id="inputFormula"
                    style="font-family: inherit; font-size: 1em;"
                    v-model="inputFormulaVal">
                  </textarea>
                </div>
                <div style="flex-direction: column; min-width: 12.4em; margin-left: 0.5em;">
                  <div style="display: flex; flex-wrap: wrap;">
                    <v-ons-button class="btn3-normal calc-btn" @click="clickOperator('+')">+</v-ons-button>
                    <v-ons-button class="btn3-normal calc-btn" @click="clickOperator('-')">-</v-ons-button>
                    <v-ons-button class="btn3-normal calc-btn" @click="clickOperator('*')">×</v-ons-button>
                    <v-ons-button class="btn3-normal calc-btn" @click="clickOperator('/')">/</v-ons-button>
                    <v-ons-button class="btn3-normal calc-btn" @click="clickOperator('.')">.</v-ons-button>
                    <v-ons-button class="btn3-normal calc-btn" @click="clickOperator('(')">(</v-ons-button>
                    <v-ons-button class="btn3-normal calc-btn" @click="clickOperator(')')">)</v-ons-button>
                  </div>
                  <div>
                    <div style="margin-bottom: 0.5em;">
                      <kendo-dropdownlist
                        id="categoryName"
                        v-model="selCategoryNameInfo"
                        :data-source="categoryNameList"
                        :data-text-field="'value'"
                        :data-value-field="'key'"
                        @select="onSelectCategoryInfo">
                      </kendo-dropdownlist>
                    </div>
                    <div style="margin-bottom: 0.5em;">
                      <kendo-dropdownlist
                        id="indicatesName"
                        v-model="selindicatesNameInfo"
                        :data-source="indicatesNameList"
                        :data-text-field="'value'"
                        :data-value-field="'key'"
                        @select="onSelectIndicatesInfo">
                      </kendo-dropdownlist>
                    </div>
                    <!-- modify by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- start-->
                    <!--<div style="margin-bottom: 0.5em;" v-if="selectDisplayList.length != 0">
                      <kendo-dropdownlist
                        id="selectDisplay"
                        v-model="selDispInfo"
                        :data-source="selectDisplayList"
                        :data-text-field="'value'"
                        :data-value-field="'key'"
                        @select="onSelectDisplayInfo">
                      </kendo-dropdownlist>
                    </div>
                    <div style="margin-bottom: 0.5em;" v-if="selCategoryNameInfo == '1' && selindicatesNameInfo == '2' && selDispInfo != ''">-->
                    <div style="margin-bottom: 0.5em;" v-if="selectDisplayList.length != 0 && selSexFlag != '1'">
                      <div>
                        <kendo-dropdownlist
                        id="selectDisplay"
                        v-model="selDispInfo"
                        :data-source="selectDisplayList"
                        :data-text-field="'value'"
                        :data-value-field="'key'"
                        @select="onSelectDisplayInfo">
                        </kendo-dropdownlist>
                      </div>
                    </div>
                    <div style="margin-bottom: 0.5em;" v-if="selSexFlag == '1'">
                      <table>
                        <tr>
                          <td>男：</td>
                          <td>
                            <v-ons-input
                            style="width: 10.1em;"
                            type="number"
                            step="0.01"
                            v-model="inputNumMan">
                            </v-ons-input>
                          </td>
                        </tr>
                        <tr>
                          <td>女：</td>
                          <td>
                            <v-ons-input
                            style="width: 10.1em;"
                            type="number"
                            step="0.01"
                            v-model="inputNumWoman">
                            </v-ons-input>
                          </td>
                        </tr>
                      </table>
                    </div>
                    <div style="margin-bottom: 0.5em;" v-if="selCategoryNameInfo == '1' && selindicatesNameInfo == '2' && selDispInfo != '' && selSexFlag != '1'">
                    <!-- modify by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- end-->
                      <v-ons-input
                        style="width: 12.4em;"
                        type="number"
                        step="0.01"
                        v-model="inputNum">
                      </v-ons-input>
                    </div>
                    <!-- modify by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- start-->
                    <!--<div style="margin-bottom: 0.5em;" v-if="distinguishList.length != 0"></div>-->
                    <div style="margin-bottom: 0.5em;" v-if="distinguishList.length != 0 && selSexFlag != '1'">
                    <!-- modify by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- end-->
                      <kendo-dropdownlist
                        id="selDistinguishInfo"
                        v-model="selDistinguishInfo"
                        :data-source="distinguishList"
                        :data-text-field="'value'"
                        :data-value-field="'key'">
                      </kendo-dropdownlist>
                    </div>
                  </div>
                  <div>
                    <v-ons-button class="btn3-normal" style="width: 5em;"
                      :disabled="codeNot1()"
                      @click="clickReflect">
                      反映
                    </v-ons-button>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <v-ons-bottom-toolbar>
              <div class="flex-container">
                <div class="denial-btn-area" style="background:none">
                  <v-ons-button class="button btn2-cancel denial-btn" @click="cancel">キャンセル</v-ons-button>
                </div>
                <div class="registration-btn-area" style="background:none">
                  <v-ons-button class="button btn3-normal registration-btn common-style-select-button" @click="registration">確定</v-ons-button>
                </div>
              </div>
            </v-ons-bottom-toolbar>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { messageFormat } from '@/functions/common/MessageFormat';
// mod #6107 2023/03/23 メッセージボックス全調整 張博 end

//URI
const uriGetExamItem = "/mstInfo/mstExamItemForExamCalc/";
const uriSelectorExamItem = "/mstInfo/mst_exam_item/mstSelector";

export default {
  name: "multi-calender",
  mixins: [MultiModalMixin],
  components: {
  },
  data() {
    return {
      // 取得可能情報リスト
      defaultCalcList: [],
      // カテゴリ名
      categoryNameList: [],
      // 表示名称
      indicatesNameList: [],
      // 選択中の取得カテゴリ名
      selCategoryNameInfo: "1",
      // 表示を選択
      selectDisplayList: [],
      //add by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- start
      // 性別表示フラグ
      selSexFlag: "",
      // 男性
      inputNumMan: 0,
      // 女性
      inputNumWoman: 0,
      //add by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- end
      // 表示名称
      selindicatesNameInfo: "",
      // 表示を選択
      selDispInfo: "",
      // 表示を選択2
      selDispInfo2: "",
      // 区分・項目選択
      distinguishList:  [],
      // 区分・項目選択
      selDistinguishInfo: "",
      // 検査項目リスト
      mstExamitem: [],
      // 検査タイミングリスト
      examClassList: [],
      // 選択中の取得可能情報リスト
      selAcquiredInfo: "",
      // 選択中の検査項目ID
      selExamItem: "",
      // 選択中の検査タイミング
      selExamClass: "",
      // 入力数値
      inputNum: 0,
      // 計算式領域テキスト
      inputFormulaVal: ""
    };
  },
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("mst-exam-item", [
      "getStrFormula"
    ]),
    ...mapGetters("account-edit", {
        getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
  },
  methods: {
    ...mapActions("mst-exam-item", [
      "setIsShowEditFormulaModal",
      "setStrFormula"
    ]),
    //ボタンのグレーの配置方法
  //7107 --------------------------------------- ljg start
    codeNot1(){
     return (this.selindicatesNameInfo == ''|| this.selectDisplayList.length != 0 && this.selDispInfo =='' || this.selectDisplayList.length != 0 && this.distinguishList.length != 0 && this.selDistinguishInfo=='' )
            //mid by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- start
            //||(this.selCategoryNameInfo == '1' && this.selindicatesNameInfo == '2' && this.selDispInfo != '' && this.inputNum == "" )
            ||(this.selCategoryNameInfo == '1' && this.selindicatesNameInfo == '2' && this.selDispInfo != '' && this.inputNum == "" && this.selSexFlag != '1')
            //mid by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- end
            //update                  7126選択肢を空欄のまま反映ができてしまう ----------------------ljg start
            || (this.selCategoryNameInfo == '' || this.categoryNameList==''|| this.categoryNameList.length=='0')
            //update                  7126選択肢を空欄のまま反映ができてしまう ----------------------ljg end
            //add by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- start
            || (this.selSexFlag == '1' && this.inputNumMan == '' && this.inputNumWoman == '')
            //add by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- end
     },
  //7107----------------------------------------ljg end
    clickReflect() {
      var strAddWord = "";
      if (this.selCategoryNameInfo !== ""){
        // 取得可能情報反映
        strAddWord += "”";
        const strSelAcInf = this.selCategoryNameInfo;
        var objDefCalc = this.categoryNameList.filter( function (val) {
          if (val.key === strSelAcInf) return true;
        });
        strAddWord += objDefCalc[0].value;
        strAddWord += ",";
        if (this.selindicatesNameInfo !== ""){
          const strSelExamItem = this.selindicatesNameInfo;
          var objSelExamItem = this.indicatesNameList.filter( function (val) {
            if (val.key === strSelExamItem) return true;
          });
          strAddWord += objSelExamItem[0].value;
        }
        strAddWord += ",";
        if (this.selDispInfo2 == "2") {
          strAddWord += "";
          strAddWord += ",";
        }else if (this.selDispInfo2 == "5" || this.selDispInfo2 == "6" || this.selDispInfo2 == "1" || this.selDispInfo2 == "7") {
          strAddWord += "";
        }else {
          strAddWord += "";
          strAddWord += ",";
        }
        //mid by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- start
        //if (this.selDispInfo !== ""){
        if (this.selDispInfo !== "" && this.selSexFlag !== '1'){
        //mid by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- end
          const strSelExamClass = this.selDispInfo;
          var objSelExamClass = this.selectDisplayList.filter( function (val) {
            if (val.key.toString()== strSelExamClass) return true;
          });
          strAddWord += objSelExamClass[0].value;
        }
        if (this.selDispInfo2 == "1") {
          strAddWord += ",";
          strAddWord += "";
        } else if (this.selDispInfo2 == "5" || this.selDispInfo2 == "7") {
          strAddWord += ",";
           if (this.selDistinguishInfo !== ""){
            const strSelExamClass = this.selDistinguishInfo;
            var objSelExamClasslist = this.distinguishList.filter( function (val) {
            if (val.key.toString()== strSelExamClass) return true;
          });
          strAddWord += objSelExamClasslist[0].value;
         }
        }else if (this.selDispInfo2 == "6"){
          strAddWord += ",";
        }
        strAddWord += "【";
        strAddWord += this.selCategoryNameInfo;
        strAddWord += ",";
        strAddWord += this.selindicatesNameInfo;
        strAddWord += ",";
        if (this.selDispInfo2 == "1") { //検査結果計算式作成時、患者情報に性別が反映された場合に男女入力値を計算式に保存する
          //mod 9480 検査計算に透析時間を使用すると計算結果が表示されない guan start
          //strAddWord += this.inputNum;
          strAddWord += this.inputNumMan;
          strAddWord += ",";
          strAddWord += this.inputNumWoman;
          //mod 9480 検査計算に透析時間を使用すると計算結果が表示されない guan end
        }else if (this.selDispInfo2 == "2") {
          strAddWord += "";
          strAddWord += ",";
          strAddWord += this.inputNum;
        }else if (this.selDispInfo2 == "5" || this.selDispInfo2 == "6" || this.selDispInfo2 == "7"){
          strAddWord += this.selDispInfo;
          strAddWord += ",";
          strAddWord += this.selDistinguishInfo;
        }else{
          strAddWord += "";
          strAddWord += ",";
          strAddWord += this.selDispInfo;
        }
        strAddWord += "】";
        strAddWord += "”";
      }
      // テキスト欄に反映
      this.clickOperator(strAddWord);
    },
    clickOperator(addWord) {
      var textarea = document.getElementById("inputFormula");
      var sentence = textarea.value;
      var len = sentence.length;
      var pos = textarea.selectionStart;
      var before = sentence.substr(0, pos);
      var after = sentence.substr(pos, len);
      sentence = before + addWord + after;
      this.inputFormulaVal = sentence;
      pos = parseInt(pos) + parseInt(addWord.length);
      textarea.focus();
      textarea.setSelectionRange(pos, pos);
    },
    // onSelectAcquiredInfo(e){
    //   // 取得可能情報の切り替え時に入力欄を切り替える
    //   switch (e.dataItem.key){
    //     case "1":
    //     case "5":
    //       // 検査結果・前回結果
    //       this.selExamItem = this.mstExamitem.length > 0 ? this.mstExamitem[0].examItemCd : "";
    //       this.selExamClass = "1";
    //       break;
    //     case "2":
    //     case "3":
    //       // 除去率・除去率(ヘマトクリット補正)
    //       this.selExamItem = this.mstExamitem.length > 0 ? this.mstExamitem[0].examItemCd : "";
    //       this.selExamClass = "";
    //       break;
    //     case "4":
    //       // 体重情報
    //       this.selExamItem = "";
    //       this.selExamClass = "1";
    //       break;
    //     case "6":
    //       // 透析時間
    //       this.selExamItem = "";
    //       this.selExamClass = "";
    //       break;
    //     default:
    //       break;
    //   }
    // },
    onSelectCategoryInfo(e){
      this.indicatesNameList = [];
      this.selectDisplayList = [];
      this.distinguishList = [];
      this.selindicatesNameInfo =""
      this.selDispInfo2 = "";
      this.selDispInfo = "";
      this.selDistinguishInfo = "";
      // 取得可能情報の切り替え時に入力欄を切り替える
      switch (e.dataItem.key){
        case "1":
          // 患者情報
          this.indicatesNameList.push({"key": "", "value": ""});
          this.indicatesNameList.push({"key": "1", "value": "年齢（歳）"});
          this.indicatesNameList.push({"key": "2", "value": "性別"});
          this.indicatesNameList.push({"key": "3", "value": "身長"});
          this.indicatesNameList.push({"key": "4", "value": "患者メモ"});
          break;
        case "3":
          // 実績情報
          this.indicatesNameList.push({"key": "", "value": ""});
          this.indicatesNameList.push({"key": "1", "value": "前体重"});
          this.indicatesNameList.push({"key": "2", "value": "後体重"});
          this.indicatesNameList.push({"key": "3", "value": "透析時間（H）"});
          this.indicatesNameList.push({"key": "4", "value": "前回からの体重増加量（Kg）"});
          this.indicatesNameList.push({"key": "5", "value": "体重減少量（Kg）"});
          this.indicatesNameList.push({"key": "6", "value": "今回除水量（L）"});
          this.indicatesNameList.push({"key": "7", "value": "次回透析までの時間（H）"});
          this.indicatesNameList.push({"key": "8", "value": "週あたり透析回数（回）"});
          this.indicatesNameList.push({"key": "9", "value": "前血圧"});
          this.indicatesNameList.push({"key": "10", "value": "後血圧"});
          this.indicatesNameList.push({"key": "11", "value": "補液積算値（L）"});
          break;
        case "4":
          // 検査結果
          this.indicatesNameList.push({"key": "", "value": ""});
          this.indicatesNameList.push({"key": "1", "value": "今回検査値"});
          this.indicatesNameList.push({"key": "2", "value": "前回検査値"});
          this.indicatesNameList.push({"key": "3", "value": "次回検査値"});
          this.indicatesNameList.push({"key": "4", "value": "前々回検査値"});
          this.selindicatesNameInfo = "";
          break;
        case "5":
          // 関数
          this.indicatesNameList.push({"key": "", "value": ""});
          this.indicatesNameList.push({"key": "1", "value": "除去率"});
          this.indicatesNameList.push({"key": "2", "value": "除去率（ヘマトクリット補正）"});
          break;
      }
    },
    async onSelectIndicatesInfo(e){
      this.selectDisplayList = [];
      this.distinguishList = [];
      this.selindicatesNameInfo = e.dataItem.key;
      this.selDispInfo = "";
      this.selDispInfo2 = "";
      this.inputNum = "";
      let masterName1 = "mst_pat_memo";
      //add by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- start
      this.selSexFlag = "";
      this.inputNumMan = "";
      this.inputNumWoman = "";
      //add by liuzhibo 2022-12-15[7639]検査計算項目を編集する際、性別による分岐が設定できない問題の修正 -- end
      // 取得可能情報の切り替え時に入力欄を切り替える
      switch (this.selCategoryNameInfo =="1" && e.dataItem.key){
        case "2":
          this.selDispInfo = "1";
          this.selDispInfo2 = "1";
          // 患者情報
          // modify by liuzhibo 2022-12-07[7639]検査計算項目を編集する際、性別による分岐が設定できない -- start /
          // this.selectDisplayList.push({"key": "1", "value": "男"});
          // this.selectDisplayList.push({"key": "2", "value": "女"});
          this.selSexFlag = "1";
          // modify by liuzhibo 2022-12-07[7639]検査計算項目を編集する際、性別による分岐が設定できない -- end /
          break;
        case "3":
          // 患者情報
          this.selectDisplayList.push({"key": "", "value": ""});
          this.selectDisplayList.push({"key": "1", "value": "単位切替(m)"});
          this.selectDisplayList.push({"key": "2", "value": "単位切替(cm)"});
          break;
        case "4":
          // 患者情報
          await Promise.all([
            // add マスタ一覧 施設切替を可能とする 王 start
            // ApiHelper.get(`/master_maintenance/${masterName1}/data/${this.getFacilityCd}`).then(response => {
            ApiHelper.get(`/master_maintenance/${masterName1}/data/${this.getFacilitySwitch}`).then(response => {
            // add マスタ一覧 施設切替を可能とする 王 end
              if(response.data) {
                this.selectDisplayList.push({
                    key: "",
                    value: "",
                  });
                response.data.localDataSource.data.forEach(element => {
                  if(element.isDisp =="1" && element.name != "" && element.name != null) {
                  this.selectDisplayList.push({
                    key: element.code,
                    value: element.name ? element.name :"",
                  });
                  }
                });
              }
            })
          ])
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('EditExamFormulaComponent.vue', 'onSelectIndicatesInfo', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
          });
          this.distinguishList.push({"key": "", "value": ""});
          this.distinguishList.push({"key": "1", "value": "空白時エラー"});
          this.distinguishList.push({"key": "2", "value": "空白時ゼロ"});
          break;
        default:
          break;
      }
      switch (this.selCategoryNameInfo =="3" && e.dataItem.key){
        case "9":
        case "10":
          // 前血圧
          // 後血圧
          this.selectDisplayList.push({"key": "", "value": ""});
          this.selectDisplayList.push({"key": "1", "value": "最高血圧"});
          this.selectDisplayList.push({"key": "2", "value": "最低血圧"});
          this.selectDisplayList.push({"key": "3", "value": "平均血圧"});
          break;
        default:
          break;
      }
      switch (this.selCategoryNameInfo =="4" && e.dataItem.key){
        case "1":
        case "2":
        case "3":
        case "4":
          // 検査項目
          this.selectDisplayList = this.mstExamitem;
          break;
        default:
          break;
      }
      switch (this.selCategoryNameInfo =="5" && e.dataItem.key){
        case "1":
        case "2":
          // 検査項目
          this.selectDisplayList = this.mstExamitem;
          break;
        default:
          break;
      }
    },
    onSelectDisplayInfo(e){
      if (!(this.selCategoryNameInfo =="1" && this.selindicatesNameInfo == "4")) {
        this.distinguishList = [];
      }
      // 取得可能情報の切り替え時に入力欄を切り替える
      this.selDispInfo2 = "";
      switch (this.selCategoryNameInfo =="1" && this.selindicatesNameInfo == "2" && e.dataItem.key){
        case "1":
          this.selDispInfo = e.dataItem.key;
          this.selDispInfo2 = "1";
          break;
        case "2":
          this.selDispInfo2 = "2";
          break;
        default:
          break;
      }
      if (this.selCategoryNameInfo =="1" && this.selindicatesNameInfo == "4") {
        this.selDispInfo2 = "7";
      }
      if (this.selCategoryNameInfo =="4") {
        this.selDispInfo2 = "5";
        this.selDistinguishInfo = "1";
        this.distinguishList.push({"key": "", "value": ""});
        this.distinguishList.push({"key": "1", "value": "透析前"});
        this.distinguishList.push({"key": "2", "value": "透析後"});
        this.distinguishList.push({"key": "3", "value": "その他"});
      }
      if (this.selCategoryNameInfo =="5") {
        this.selDispInfo2 = "6";
      }
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 変更の有無を判断
      var isChange = (document.getElementById("inputFormula").value !== this.getStrFormula);

      // 変更がある場合はメッセージを表示
      if (isChange) {
        this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
              //OK
              this.close();
            }
          }
        });
      } else {
        this.close();
      }
    },
    /**
     * 確定処理
     */
    registration() {
      // 入力数式のチェック処理を行う
      const strFormula = document.getElementById("inputFormula").value;
      var validateErrMsg = this.validateFormula(strFormula);
      if (validateErrMsg != ""){
        // エラーメッセージ表示
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "数式チェックエラー",
          title: DIALOG_MESSAGES['00200051'].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: validateErrMsg
        });
      } else {
        this.setStrFormula(strFormula);
        this.close();
      }
    },
    /**
     * 計算式のチェック
     */
    validateFormula(strFormula){
      var retMsg = "";

      // 括弧("("と")","{"と"}","["と"]")の数が一致するか
      if (strFormula.split("(").length !== strFormula.split(")").length){
        // mod #6107 2023/03/23 メッセージボックス全調整 林峻峰 start
        // retMsg += "括弧の数が不一致です。計算式を確認してください。<BR>"
        retMsg += messageFormat(DIALOG_MESSAGES['00200051'].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 林峻峰 end
      }

      // 計算式の末尾に演算子
      const lastChar = strFormula.slice(-1);
      if (lastChar === "+" || lastChar === "-" ||
          lastChar === "*" || lastChar === "/" ){
        // mod #6107 2023/03/23 メッセージボックス全調整 林峻峰 start
        // retMsg += "計算式の末尾に演算子が入力されています。<BR>"
        retMsg += messageFormat(DIALOG_MESSAGES['00200052'].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 林峻峰 end
      }

       // 複雑な計算公式を入力できません
       let flag = false;
       let str = ["∪","∩","√￣","log","lg","ln","d","∫","∮"];
       str.forEach(e =>{
         if(strFormula.includes(e)){
           flag = true;
         }
       });

      if (flag){
        // mod #6107 2023/03/23 メッセージボックス全調整 林峻峰 start
        // retMsg += "複雑な計算公式を入力できません。<BR>"
        retMsg += messageFormat(DIALOG_MESSAGES['00200053'].message);
        // mod #6107 2023/03/23 メッセージボックス全調整 林峻峰 end
      }
      return retMsg;
    },
    /**
     * ダイアログを閉じる
     */
    close(){
      this.setIsShowEditFormulaModal(false);
    }
  },
  async created() {
    // 計算式領域のテキストを編集
    this.inputFormulaVal = this.getStrFormula;
    this.categoryNameList.push({"key": "1", "value": "患者情報"});
    this.categoryNameList.push({"key": "3", "value": "実績情報"});
    this.categoryNameList.push({"key": "4", "value": "検査結果"});
    this.categoryNameList.push({"key": "5", "value": "関数"});
    // 表示名称
    this.indicatesNameList.push({"key": "", "value": ""});
    this.indicatesNameList.push({"key": "1", "value": "年齢（歳）"});
    this.indicatesNameList.push({"key": "2", "value": "性別"});
    this.indicatesNameList.push({"key": "3", "value": "身長"});
    this.indicatesNameList.push({"key": "4", "value": "患者メモ"});
    // 取得可能情報
    this.defaultCalcList.push({"key": "", "value": ""});
    this.defaultCalcList.push({"key": "1", "value": "検査結果"});
    this.defaultCalcList.push({"key": "2", "value": "除去率"});
    this.defaultCalcList.push({"key": "3", "value": "除去率(ヘマトクリット補正)"});
    this.defaultCalcList.push({"key": "4", "value": "体重情報"});
    this.defaultCalcList.push({"key": "5", "value": "前回結果"});
    this.defaultCalcList.push({"key": "6", "value": "透析時間"});

    // 検査タイミング情報
    this.examClassList.push({"key": "", "value": ""});
    this.examClassList.push({"key": "1", "value": "透析前"});
    this.examClassList.push({"key": "2", "value": "透析後"});
    this.examClassList.push({"key": "3", "value": "その他"});
    // 検査項目
    // 検査項目一覧を取得
    // add マスタ一覧 施設切替を可能とする 王 start
    // var respExamItem = await ApiHelper.get(uriGetExamItem, { facilityCd: this.getStateUserAccountInfo.facilityCd })
    var respExamItem = await ApiHelper.get(uriGetExamItem, { facilityCd: this.getFacilitySwitch })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('EditExamFormulaComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
    // 検査項目表示順を取得
    // var respExamItemSelector = await ApiHelper.get(uriSelectorExamItem, { facilityCd: this.getStateUserAccountInfo.facilityCd })
    var respExamItemSelector = await ApiHelper.get(uriSelectorExamItem, { facilityCd: this.getFacilitySwitch })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('EditExamFormulaComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      });
    // add マスタ一覧 施設切替を可能とする 王 end
    // 検査項目一覧を作成（表示順つき）
    var dispOrder = 999; // 表示順(初期値999)
    for (var i = 0; i < respExamItem.data.length; i++) {
      for (var j = 0; j < respExamItemSelector.data.orderSettings.items.length; j++) {
        if (respExamItemSelector.data.orderSettings.items[j].code == respExamItem.data[i].examItemCd) {
          dispOrder = j;
        }
      }
      // 削除済みの検査項目は対象外
      if (respExamItem.data[i].isDisp == "0") {
        continue;
      }
      this.mstExamitem.push({
        value : respExamItem.data[i].examItemName,
        key: respExamItem.data[i].examItemCd.toString(),
        disp_order: dispOrder
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
    });
    this.mstExamitem.push({"key": "", "value": ""});
  },
};
</script>

<style scoped>
#editFormulaModalContainer {
  height: 100%;
  width: 100%;
}
.inputFormulaArea {
  margin-left: 1em;
  margin-top: 0.8em;
  height: calc(100% - 1.5em);
  width: calc(100% - 1.5em);
}
.calc-btn {
  margin-right: 0.3em;
  margin-bottom: 0.5em;
  min-width: 2em;
  width: 2em;
}
#inputFormula {
  height: 100%;
  width: 100%;
  min-width: 50vw;
  max-width: 100vw;
  max-height: 80vh;
}
@import "../../../assets/styles/modal.css";
</style>
