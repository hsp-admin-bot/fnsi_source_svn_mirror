/**
 * マスタメンテナンスページ用ヘッダ
 */
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <!-- add マスタ一覧 1･施設切替を可能とする 孔s start -->
        <v-ons-col class='condition-search-col' style="height: auto; margin: auto;">
          <kendo-dropdownlist ref="dropDownList" v-if="getStateUserAccountInfo.userType === 1"
              v-model="facilitySwitchValue"
              :data-source="getFacilityList"
              :data-text-field="'facilityName'"
              :data-value-field="'facilityCd'"
              :filter="'contains'"
              @change="facilityValueChange($event),onChangeFacility($event)"
              style="width: 100%; max-width: 30em; font-size: 1.5em;">
          </kendo-dropdownlist>
        </v-ons-col>
        <!-- add マスタ一覧 1･施設切替を可能とする 孔s end -->
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
                   :visible.sync='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target=false
                   :class="[fontSizeSet, 'master-search']">
      <!--mod FNSI-画面部品デザイン じょはく start-->
      <div class="fab-font-color" style='margin:10px;'>
        <!--mod FNSI-画面部品デザイン じょはく end-->
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>マスタ名</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input input-id='masterName' type='text' float  v-model='condition.inProgress.masterName' @keydown.enter='onSearchEnter'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='btn2-cancel clear' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='btn3-normal ok' @click='dialogOk'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import PopoverMixin from "@/components/PopoverMixin";
import commonSearchArea from "@/components/common/CommonSearchArea";
import {ApiHelper} from "@/apis/AxiosHelper";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [PopoverMixin],
  data() {
    const defaultCondition = {
      masterName: ""
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      defaultCondition: defaultCondition,
      condition: {
        // 入力中の検索条件
        inProgress: {
          ...defaultCondition
        },
        // 実際に検索に使用される条件
        inUsed: {
          ...defaultCondition
        },
        // mod 障害票一覧_ログイン画面 修正 xie start
        userCondition: [{
           "userId": "",
           "methodName": ""
        }]
        // mod 障害票一覧_ログイン画面 修正 xie end
      },
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      // add マスタ一覧 1･施設切替を可能とする 孔s start
      facilitySwitchValue: ""
      // add マスタ一覧 1･施設切替を可能とする 孔s end
    };
  },
  computed: {
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // ...mapGetters("master-maintenance", ["getSearchMasterName"])
    ...mapGetters("master-maintenance", ["getSearchMasterName","getUserCondition","getFacilityList","getFacilitySwitch",]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // mod 障害票一覧_ログイン画面 修正 xie start
    ...mapGetters("account-edit", ["getUserId", "getUserName"])
    // mod 障害票一覧_ログイン画面 修正 xie end
  },
  methods: {
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // ...mapActions("master-maintenance", ["setSearchMasterName"]),
    ...mapActions("master-maintenance", ["setSearchMasterName", "setUserCondition", "facilityList","setFacilitySwitch","setScrollToTop","setFacilityList"]),
    ...mapActions("bread-crumb", ["resetTitle"]),
    // mod マスタ一覧 1･施設切替を可能とする 孔s end

    // add マスタ一覧 1･施設切替を可能とする 孔s start
    onChangeFacility(event){
      this.setFacilitySwitch(event.sender._old);
      this.setTitle(event.sender._old);
      this.setScrollToTop(0)
      EventBus.$emit("mstFacilitySwitch");
    },
    //add #9311 v-model発効します 張博 start
    facilityValueChange(event){
      this.facilitySwitchValue = event.sender._old
    },
    //add #9311 v-model発効します 張博 end
    setTitle(facilityCd){
      if (this.getStateUserAccountInfo.facilityCd !== facilityCd) {
        const myFacilityList = this.getFacilityList.filter(
          e => e.facilityCd === facilityCd
        )
        if (myFacilityList.length > 0) {
          this.resetTitle({
            depth: 1,
            newTitle: `マスタ一覧(${myFacilityList[0].facilityName})`
          })
        }
      } else {
        this.resetTitle({
          depth: 1,
          newTitle: `マスタ一覧`
        })
      }
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s end
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.condition.inProgress.masterName = this.condition.inUsed.masterName;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.condition.inProgress.masterName = this.defaultCondition.masterName;
      this.condition.inUsed.masterName = this.defaultCondition.masterName;
      // 共通検索エリア部品に表示するデータのリストを初期化
      this.conditionList = [];
      // 画面を閉じる
      this.popoverVisible = false;
      this.setSearchMasterName(this.condition.inUsed.masterName);
      // mod 障害票一覧_ログイン画面 修正 xie start
      this.setDataUserCondition(this.condition.inUsed.masterName);
      // mod 障害票一覧_ログイン画面 修正 xie end
      this.search();
    },
    // -----------------------------------------
    // 抽出条件Enter押下時イベント
    // -----------------------------------------
    onSearchEnter : function(){
        this.dialogOk();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      // 画面を閉じる
      this.popoverVisible = false;
      this.condition.inUsed.masterName = this.condition.inProgress.masterName;
      // mod 障害票一覧_ログイン画面 修正 xie start
      try {
         this.setDataUserCondition(this.condition.inUsed.masterName);
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('MasterListHeaderComponent.vue', 'dialogOk', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      }
      // mod 障害票一覧_ログイン画面 修正 xie end
      this.setConditionList();
      this.setSearchMasterName(this.condition.inUsed.masterName);
      this.search();
    },
    // mod 障害票一覧_ログイン画面 修正 xie start
    setDataUserCondition(methodName) {
        var isExists = false;
        for(var i in this.condition.userCondition) {
           if (this.condition.userCondition[i].userId === this.getUserId) {
               this.condition.userCondition[i].methodName = methodName;
               isExists = true;
               break;
           }
        }
        if (!isExists) {
          var userConditionObj = {"userId": this.getUserId, methodName: this.condition.inUsed.masterName}
          this.condition.userCondition.push(userConditionObj);
        }

        this.setUserCondition(this.condition.userCondition);
    },
    getUserConditionMethodName() {
        try {
          var isExists = false;
          for(var i in this.condition.userCondition) {
             if (this.condition.userCondition[i].userId === this.getUserId) {
                 return this.condition.userCondition[i].methodName;
             }
          }
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MasterListHeaderComponent.vue', 'getUserConditionMethodName', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          return '';
        }
        return '';
    },
    // mod 障害票一覧_ログイン画面 修正 xie end
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      // 検索条件の内容で画面を更新
      EventBus.$emit("filterMasterList", this.condition.inUsed);
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.condition.inUsed;
      // マスタ名
      if (condObj.masterName != "") {
        condList.push({ name:"マスタ名", text:condObj.masterName });
      }
      this.conditionList = condList;
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    // 施設一覧のデータを取得
    findFacilityList() {
      if (this.getStateUserAccountInfo.userType !== 1 || this.getFacilitySwitch === "") {
        this.setFacilitySwitch(this.getStateUserAccountInfo.facilityCd);
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(async() => {
          // ログイン者の担当施設を選択
          this.facilitySwitchValue = this.getFacilitySwitch;
          this.setTitle(this.getFacilitySwitch);

          // マスタ一覧 施設切替 施設解約後は表示されません start
          await ApiHelper.get("/facilities/MntFacilityCancelManage/SelectAll")
            .then((response) => {
              const mntFacilityCancelManageList = response.data.map(e => {
                // mod redmine4484 解約予約は表示対象 孔 start
                // return e.facilityCd
                if (e.procStatus !== "0") return e.facilityCd
                // mod redmine4484 解約予約は表示対象 孔 end
              });
              const notCancelList = this.getFacilityList.filter(item => !mntFacilityCancelManageList.includes(item.facilityCd))

              this.setFacilityList(notCancelList)
              // add #10627 マスタ一覧画面への遷移でエラーが発生し拡張機能に関するマスタが表示されてしまう linjunfeng start
              EventBus.$emit("mstFacilitySwitch");
              // add #10627 マスタ一覧画面への遷移でエラーが発生し拡張機能に関するマスタが表示されてしまう linjunfeng end
            })
            .catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
              getErrorMessage('MasterListHeaderComponent.vue', 'findFacilityList', error);
              //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
              throw error;
            });
          // マスタ一覧 施設切替 施設解約後は表示されません end

          // add redmine4484 並び順は施設マスタの並び順に合わせる 孔 start
          const sort = await ApiHelper.get("/mstInfo/mst_facility/mstSelector/", {
            facilityCd: "nkknkk"
          }).catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add start
            getErrorMessage('MasterListHeaderComponent.vue', 'findFacilityList', error);
            //FNSI-修正 VUEのエラー場合のログ対応 xiebzh add end
            throw error;
          });
          if (sort.data && sort.data.orderSettings) {
            const sortList = sort.data.orderSettings.items;

            //表示順設定
            this.getFacilityList.forEach(facility => {
              const index = sortList.findIndex(item => facility.facilityName === item.name)
              if (index > -1) {
                facility.sort_rank = index + 1
              } else {
                facility.sort_rank = 999999
              }
            })

            this.getFacilityList.sort((a, b) => {
              return a.sort_rank - b.sort_rank
            })
          }
          // add redmine4484 並び順は施設マスタの並び順に合わせる 孔 end
        })
        .catch(error => {
          if (error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MasterListHeaderComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          else{
            getErrorMessage('MasterListHeaderComponent.vue', 'findFacilityList', error);
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        });
    },
    // add マスタ一覧 1･施設切替を可能とする 孔s end
  },
  created() {
    // mod 障害票一覧_ログイン画面 修正 xie start
    try {
      if (this.getUserCondition) {
        this.condition.userCondition = this.getUserCondition;
      }
      var methodName = this.getUserConditionMethodName();
      if (methodName !== '') {
        this.setSearchMasterName(methodName);
        this.condition.inUsed.masterName = methodName;
      } else {
        this.setSearchMasterName(this.condition.inUsed.masterName);
      }
    } catch (error) {
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      getErrorMessage('MasterListHeaderComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      this.setSearchMasterName(this.condition.inUsed.masterName);
    }
    // mod 障害票一覧_ログイン画面 修正 xie end

    this.setConditionList();
    // add マスタ一覧 1･施設切替を可能とする 孔s start
    this.findFacilityList();
    // add マスタ一覧 1･施設切替を可能とする 孔s end
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
  // // add FNSI-改修内容再次迁移回master一览画面后，应该显示所有情报横展开No liang start
  // destroyed() {
  //  this.dialogClear();
  // }
  // // add FNSI-改修内容再次迁移回master一览画面后，应该显示所有情报横展开No liang end

};
</script>
