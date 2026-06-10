/**
 * 生体モニタリングページ用ヘッダ
 */
<template>
  <div class='header-item'>
    <div class="mark-leftmost-header">
    <!-- リストグラフ用ヘッダ -->
      <div>
      <v-ons-row>
      <v-ons-col vertical-align='center' width='50%'>
      <!-- <v-ons-button class='search' @click='showPopover($event)' style='width:40%; height:30px; text-align: right; padding: 0px 10px 0px 0px;'><v-ons-icon icon='fa-search' /></v-ons-button> -->
      <div>
      <div class='condition-search-area' @click='showPopover($event)'>
        <div class='condition-search-icon-area' style='overfliw:auto'>
          <v-ons-icon icon='fa-search' size='2.0em' style='color:gray;'></v-ons-icon>
        </div>

        <!-- 抽出条件表示エリア[始] -->
        <div id='condition-items' class='ntss-monitoring-condition-items-area'>
          <!-- ベッドグループ -->
          <label class='ntss-monitoring-condition-label' v-if='viewCondition.bedGroupName!="" && viewCondition.bedGroupIndex!="0"'>
            {{ viewCondition.bedGroupName }}
          </label>
          <!-- 名前 -->
          <label class='ntss-monitoring-condition-label' v-if='viewCondition.inputname!=""'>
            {{ viewCondition.inputname }}
          </label>
          <!-- 治療中 -->
          <label class='ntss-monitoring-condition-label' v-if='viewCondition.seltreat!="" && viewCondition.seltreat!="すべて"'>
            {{ viewCondition.seltreat }}
          </label>
          <!-- 警報 -->
          <label class='ntss-monitoring-condition-label' v-if='viewCondition.checkedalert.indexOf("alert") > -1'>
            警報
          </label>
          <!-- 報知 -->
          <label class='ntss-monitoring-condition-label' v-if='viewCondition.checkedalert.indexOf("info") > -1'>
            報知
          </label>
          <!-- 主治医 -->
          <label class='ntss-monitoring-condition-label' v-if='viewCondition.checkedstaff.indexOf("doctor") > -1'>
            主治医
          </label>
          <!-- 担当 -->
          <label class='ntss-monitoring-condition-label' v-if='viewCondition.checkedstaff.indexOf("staff") > -1'>
            担当
          </label>
          <!-- 穿刺 -->
          <label class='ntss-monitoring-condition-label' v-if='viewCondition.checkedstaff.indexOf("puncture") > -1'>
            穿刺
          </label>
        </div>
      </div>
      <!-- 抽出条件表示エリア[終] -->
    </div>
    </v-ons-col>
    <v-ons-col class='ntss-monitoring-head-col-right'>
      <v-ons-select
        @change='setGraphSetting'
        style='width: 60%; background-color:white; height: 2em;'
        v-model=settingNo
        v-bind:disabled="isLoading"
        id='tempname'>
        <option id='selectctlno' v-for='option in listgraph_settingslist' :key=option.length :value='option.ctlNo'>
          {{ option.templateName }}
        </option>
      </v-ons-select>
    </v-ons-col>
    </v-ons-row>
    </div>

    <!-- 抽出ダイアログ[始] -->
    <v-ons-popover cancelable
                   :visible.sync='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target=false
                   :class="fontSizeSet"
                   >
      <div style='margin:10px;'>
      <!-- <v-ons-card style='width:350px;'> -->
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label >透析室<br>ベッドグループ</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-select style='width: 100%' v-model=bedgrouplist.bedGroupIndex>
              <option id='selectbedgrp'  v-for='(option,index) in bedgrouplist' :key=option.length :value=index>
                {{ option.bedGroupName }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label >名前</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input  input-id='searchname' type='text' float v-model='inputname'></v-ons-input>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class='condition-row'>
             <v-ons-col width='50%' vertical-align='center' v-for='(radioitem, index) in checktreat' :key='radioitem'>
              <label class='left'>
                <v-ons-radio
                  :input-id="'radio-' + index"
                  :value='radioitem'
                  v-model=' seltreat'
                  modifier="round"
                >
                </v-ons-radio>
              </label>
              <label :for="'radio-' + index" class='center' style='line-height: 2.5;'>
                {{ radioitem }}
              </label>
            </v-ons-col>
        </v-ons-row>


        <v-ons-row class='condition-row'>
          <v-ons-col width='30%' vertical-align='center'>
            <label class='left'>
              <input type='checkbox' id='check-alert' value='alert' v-model='checkedalert' style='vertical-align: middle;'/>
            </label>
            <label for='check-alert' class='center'>
              警報
            </label>
          </v-ons-col>
          <v-ons-col width='30%' vertical-align='center'>
            <label class='left'>
              <input type='checkbox' id='check-info' value='info' v-model='checkedalert'  style='vertical-align: middle;'/>
            </label>
            <label for='check-info' class='center'>
              報知
            </label>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class='condition-row'>
          <v-ons-col width='30%' vertical-align='center'>
            <label class='left'>
              <input type='checkbox' id='check-doctor' value = 'doctor' v-model='checkedstaff'  style='vertical-align: middle;'/>
            </label>
            <label for='check-doctor' class='center'>
              主治医
            </label>
          </v-ons-col>
          <v-ons-col width='30%' vertical-align='center'>
            <label class='left'>
              <input type='checkbox' id='check-staff'  value = 'staff' v-model='checkedstaff'  style='vertical-align: middle;'/>
            </label>
            <label for='check-staff' class='center'>
              担当
            </label>
          </v-ons-col>
          <v-ons-col width='30%' vertical-align='center'>
            <label class='left'>
              <input type='checkbox' id='check-puncture'  value = 'puncture' v-model='checkedstaff'  style='vertical-align: middle;'/>
            </label>
            <label for='check-puncture' class='center'>
              穿刺
            </label>
          </v-ons-col>
        </v-ons-row>

        <v-ons-row class='condition-row' style="margin-bottom: 0;">
          <v-ons-col width='30%' vertical-align='center'>
            <v-ons-button class='clear' @click='dialogClear'>クリア</v-ons-button>
          </v-ons-col>
          <v-ons-col width='40%' vertical-align='center'>
          </v-ons-col>
          <v-ons-col width='30%' vertical-align='center'>
            <v-ons-button class='ok' @click='dialogOk'>OK</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      <!-- </v-ons-card> -->
      </div>
      </v-ons-popover>
    <!-- 抽出ダイアログ[終] -->
    </div>
  </div>
</template>

<script>
/* eslint-disable */
import { mapState, mapActions } from 'vuex';
import PopoverMixin from "@/components/PopoverMixin";

export default {
  mixins: [PopoverMixin],
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: 'down',
      checktreat:['すべて', '治療中'],
      seltreat: 'すべて',
      checkedstaff: [],
      checkedalert: [],
      inputname: '',
      viewCondition:{
        bedGroupIndex:0,
        bedGroupName:'',
        seltreat: 'すべて',
        checkedstaff: [],
        checkedalert: [],
        inputname: ''
      }
    };
  },
  computed: {
    ...mapState('listGraph', [
      'bedgrouplist',
      'listgraph_settingslist',
      'listgraph_settings_select_no',
      'machinedata',
      'detailGraphIndex',
      'staffcd']),
    ...mapState('user', ['facilityCd']),
    isLoading(){
      return this.$store.state.listGraph.loadstate;
    },
    settingNo:{
      get: function() {
        return this.listgraph_settings_select_no;
      },
      set: function(value) {
        this.$store.commit('listGraph/CHANGE_GRAPHSETTING_LIST', {
          listgraph_settings_select_no: value
          });
      }
    }
  },
  methods: {
    ...mapActions('listGraph',
    {
      'fetchBedGroupList':'fetchBedGroupList',
      'fetchGraphSetting':'fetchGraphSetting',
      'fetchDataMachine':'fetchDataMachine',
      'fetchDataMonitor':'fetchDataMonitor',
      'fetchDataResult':'fetchDataResult',
      'reDrawChart': 'reDrawChart',
      'setState': 'setState'
    }),
    loadData() {
      // ベッドグループ一覧情報取得
      this.fetchBedGroupList(this.facilityCd).then(result => {
        if (result == false) {
          alert('ベッドグループ一覧情報の取得失敗');
        }
      });
    },
    showPopover(event) {
      this.popoverTarget = event;

      // 抽出条件をセット
      this.bedgrouplist.bedGroupIndex =this.viewCondition.bedGroupIndex;
      this.seltreat = this.viewCondition.seltreat;
      this.checkedstaff = this.viewCondition.checkedstaff;
      this.checkedalert = this.viewCondition.checkedalert;
      this.inputname = this.viewCondition.inputname;

      this.popoverVisible = true;
    },
    dialogClear() {
      this.bedgrouplist.bedGroupIndex = 0;
      this.seltreat = 'すべて';
      this.inputname = '';
      this.checkedstaff = [];
      this.checkedalert = [];
      //this.popoverVisible = false;
    },
    dialogOk() {
      this.popoverVisible = false;

      // 抽出条件がセットされている場合
      if(this.conditionChange() == true)
      {
        // 抽出条件記憶
        this.viewCondition.bedGroupIndex = this.bedgrouplist.bedGroupIndex;
        this.viewCondition.bedGroupName = this.bedgrouplist[this.bedgrouplist.bedGroupIndex].bedGroupName;
        this.viewCondition.seltreat = this.seltreat;
        this.viewCondition.checkedstaff = this.checkedstaff;
        this.viewCondition.checkedalert = this.checkedalert;
        this.viewCondition.inputname = this.inputname;

        // 抽出条件でデータを絞り込む
        for (let i = 0; i < this.machinedata.length; i++)
        {
          this.conditionSetting(i);
        }
      }

    },
    // 1装置分の抽出条件検索
    conditionSetting(machineindex)
    {
      let visiblestate = true;
      let chkdata = this.machinedata[machineindex];

      // ベッドグループ
      if(this.bedgrouplist.bedGroupIndex > 0)
      {
        for (let j = 0; j < this.bedgrouplist[this.bedgrouplist.bedGroupIndex].bedList.bed_list.length; j++)
        {
          let bedlist = this.bedgrouplist[this.bedgrouplist.bedGroupIndex].bedList.bed_list[j];
          if(bedlist.bed_cd == chkdata.bedCd)
          {
            visiblestate = true;
            break;
          }
          visiblestate = false;
        }
      }

      // 患者名
      // 入力された検索文字列
      let searchname = document.getElementById('searchname').value;
      if(visiblestate == true && searchname != '')
      {
        // 患者名、患者名カナ検索、患者名アルファベットがすべてnullの場合は非表示
        if(chkdata.patName == null && chkdata.patNameKana == null && chkdata.patNameAlpha == null)
        {
          visiblestate = false;
        }

        // 患者名が検索で一致、または
        if((chkdata.patName != null && chkdata.patName.indexOf(searchname) >= 0) ||
           // 患者名カナが検索で一致、または
           (chkdata.patNameKana != null && chkdata.patNameKana.indexOf(searchname) >= 0) ||
           // 患者名アルファベットが検索で一致
           (chkdata.patNameAlpha != null && chkdata.patNameAlpha.indexOf(searchname) >= 0))
        {
          visiblestate = true;
        }else{
          visiblestate = false;
        }
      }

      // 治療状況(すべて/治療中)
      // 治療中の場合
      if( this.seltreat == '治療中' && visiblestate == true)
      {
        // 治療中でない装置を非表示にする
        if(chkdata.machinestate == 0)
        {
          visiblestate = false;
        }
      }

      // 警報・報知情報[0:通常,1:警報,2:報知] alertstate
      if( this.checkedalert.length > 0 && visiblestate == true)
      {
        // 両方にチェックが入っている場合
        if(this.checkedalert.length == 2 )
        {
          // 通常の場合
          if(chkdata.alertstate == 0)
          {
              visiblestate = false;
          }
        }
        else
        {
          // 警報にチェックが入っている場合
          if(this.checkedalert.indexOf('alert') > -1 && chkdata.alertstate != 1)
          {
              visiblestate = false;
          }

          // 報知にチェックが入っている場合
          if(this.checkedalert.indexOf('info') > -1 && chkdata.alertstate != 2)
          {
              visiblestate = false;
          }
        }
      }

      // スタッフ情報(主治医/担当スタッフ/穿刺)
      if( this.checkedstaff.length > 0 && visiblestate == true)
      {
        // スタッフ情報がない場合
        if(chkdata.patChargeStaffInfo == null)
        {
          visiblestate = false;
        }
        // スタッフ情報がある場合
        else
        {
          // ログイン中のスタッフコード
          let staff = this.staffcd.trim();
          let staffdata = JSON.parse(chkdata.patChargeStaffInfo);
          let staffflg = false;

          let is_main = false;
          let is_staff = false;
          let is_puncture = false;

          for(let j = 0; j < staffdata.length; j++)
          {
            // ログイン中のスタッフの場合
            if(staff == staffdata[j].staff_cd.trim())
            {
              staffflg = true;

              // 主治医にチェックが入っていて、ログイン中のスタッフが主治医の場合
              if(this.checkedstaff.indexOf('doctor') > -1 && staffdata[j].is_main == 1)
              {
                is_main = true;
              }

              // 担当にチェックが入っていて、ログイン中のスタッフが担当の場合
              if(this.checkedstaff.indexOf('staff') > -1 && staffdata[j].is_charge == 1)
              {
                is_staff = true;
              }

              // 穿刺にチェックが入っていて、ログイン中のスタッフが穿刺の場合
              if(this.checkedstaff.indexOf('puncture') > -1 && staffdata[j].is_puncture == 1)
              {
                is_puncture = true;
              }

              // 主治医/担当/穿刺のいずれにも該当しない場合
              if(is_main == false && is_staff == false && is_puncture == false)
              {
                visiblestate = false;
              }
            }
          }

          // ログイン中のスタッフがスタッフ情報にいなかった場合
          if(staffflg == false)
          {
            visiblestate = false;
          }

        }
      }

      // 表示/非表示セット
      this.machinedata[machineindex].visible = visiblestate;
    },
    // 抽出条件の有無チェック
    conditionExists()
    {
      // 抽出条件チェック
      if(this.viewCondition.bedGroupIndex != 0){return true;}
      if(this.viewCondition.seltreat == '治療中'){return true;}
      if(this.viewCondition.checkedstaff.length > 0){return true;}
      if(this.viewCondition.checkedalert.length > 0){return true;}
      if(this.viewCondition.inputname != ''){return true;}

      // 抽出条件がない場合
      return false;
    },
    // 抽出条件の変更チェック
    conditionChange()
    {

      // 抽出条件チェック
      if(this.viewCondition.bedGroupIndex != this.bedgrouplist.bedGroupIndex){return true;}
      if(this.viewCondition.seltreat != this.seltreat){return true;}
      if(this.viewCondition.checkedstaff.toString() != this.checkedstaff.toString()){return true;}
      if(this.viewCondition.checkedalert.toString() != this.checkedalert.toString()){return true;}
      if(this.viewCondition.inputname != this.inputname){return true;}

      // 抽出条件に変更がない場合
      return false;
    },
    setGraphSetting() {

      // データ取得開始
      this.setState(true);

      // グラフ設定情報取得
      this.fetchGraphSetting({listmode:true, facilityCd: this.facilityCd}).then(result => {
        if (result == false) {
          alert('グラフの設定情報の取得失敗');
        }

        // モニタデータ項目情報取得
        this.fetchDataMonitor(this.facilityCd).then(result => {
          if (result == false) {
            alert('モニタデータ項目情報の取得失敗');
          }

          // 装置一覧取得
          this.fetchDataMachine({mode:2, facilityCd:this.facilityCd}).then(async (result) =>
          {
            if(result == false)
            {
              alert('装置一覧情報の取得失敗');
            };

            // グラフ読み込み
            for (let i = 0; i < this.machinedata.length; i++) {
              await this.fetchDataResult({
                mode: 0,
                index: i
              });
              await this.reDrawChart(i);
              // 抽出条件がセットされている場合
              if(this.conditionExists() == true)
              {
                // 抽出条件セット
                this.conditionSetting(i);
              }
            }

            // データ取得完了
            this.setState(false);
          });
        });
      });
    }
  },
  mounted() {
    // ベッドグループ一覧情報取得
    this.loadData();
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<style scoped>
.fab-top-right {
  top: 10px;
  bottom: auto;
  right: 10px;
  left: auto;
  position: absolute;
}
.img-icon {
  width: 100%;
  height: auto;
  max-width: 60px;
}
.textitems {
  font-size: 24px;
}
#tempname {
  height: 26px;
  margin-top: 2px;
  margin-left: 5px;
}
/* Herader 右列*/
.ntss-monitoring-head-col-right {
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding-bottom: 10px;
}
/* Headerの検索条件エリアのスタイル定義 */
.ntss-monitoring-condition-search-area {
  margin:5px;
  /* width:100%; */
  height:50px;
  border:solid 1px lightgray;
  background-color:#FAFAFA;
  border-radius:10px;
  overflow:auto;
}
/* Headerの検索アイコン表示エリアのスタイル定義 */
.ntss-monitoring-condition-search-icon-area {
  float: left;
  line-height:17px;
  margin-left:2px;
  margin-right:2px;
}
/* Headerの検索条件（検索アイコン以外）の外枠のスタイル定義 */
.ntss-monitoring-condition-items-area {
  margin-left:5px;
  padding:1px;
}
/* 検索条件の項目毎のスタイル定義 */
.ntss-monitoring-condition-label {
  border:solid 1px lightgray; /* 枠線のスタイル */
  /*font-size:1.3em;*/ /* フォントサイズ */
  border-radius:30px; /* 枠線の角 */
  padding:2px; /* 外枠と内枠のスペース */
  margin-left: 5px;
  line-height: 20px;
}
ons-popover >>> .popover__content {
  min-width: 400px;
}
</style>
