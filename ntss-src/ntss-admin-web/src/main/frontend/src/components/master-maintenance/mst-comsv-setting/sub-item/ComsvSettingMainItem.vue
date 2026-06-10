<template>
  <div class="main-content-area-main input-area">
    <div class="confbody">
      <div class="table-comsv-setting">
        <tbody class="tbody-left">
          <tr>
            <td style="width: 300px">
              <v-ons-checkbox
                :checked="isTimeset"
                @change="onIsTimeset($event)"
                input-id="cBoxTimeSet"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxTimeSet">新通信一斉時刻合わせ</label>
            </td>
            <td style="width: 100px">
              <time-input
                v-model="inputModel.timesetTime"
                :classes="'input-time time-input-required time-input-focus ' +isEdited('timesetTime')"
                :disabled="isDisableTimeset"
                :default-time="defaultTime('timesetTime')"
                @blur="onChangeTimesetTime"
                isRequired
              />
            </td>
          </tr>
          <tr>
            <td>
              <v-ons-checkbox
                :checked="isTimesetNx"
                @change="onIsTimesetNx($event)"
                input-id="cBoxTimeSetNx"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxTimeSetNx">NX通信一斉時刻合わせ</label>
            </td>
            <td>
              <time-input
                v-model="inputModel.timesetNxTime"
                :classes="'input-time time-input-required time-input-focus ' +isEdited('timesetNxTime')"
                :disabled="isDisableTimesetNx"
                :default-time="defaultTime('timesetNxTime')"
                @blur="onChangeTimesetNxTime"
                isRequired
              />
            </td>
          </tr>
          <!--add 「投薬変更のお知らせ」の有無を判断する項目を追加 劉 start-->
          <tr>
            <td>
              <v-ons-checkbox
                :checked="isNoticeMedi"
                @change="onIsNoticeMedi($event)"
                input-id="cBoxNoticeMedi"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxNoticeMedi">投薬変更のお知らせ</label>
            </td>
          </tr>
          <!--add 「投薬変更のお知らせ」の有無を判断する項目を追加 劉 end-->
          <tr>
            <td>
              <v-ons-checkbox
                :checked="lcdLogTime"
                @change="onLcdLogTime($event)"
                input-id="cBoxLcdLogTime"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxLcdLogTime">
                仮想端末ログ時間
                <br />(OFF:時刻、ON:経過)
              </label>
            </td>
          </tr>
          <tr>
            <td>
              <v-ons-checkbox
                :checked="lcdLogType"
                @change="onLcdLogType($event)"
                input-id="cBoxLcdLogType"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxLcdLogType">
                仮想端末ログ内容
                <br />(OFF:ログ、ON:愁訴処置)
              </label>
            </td>
          </tr>
          <!-- mod 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao start-->
          <!-- <tr>
            <td>
              <v-ons-checkbox
                :checked="isLcdMedi"
                @change="onIsLcdMedi($event)"
                input-id="cBoxLcdMedi"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxLcdMedi">
                仮想端末投与時間
                <br />(OFF:時刻、ON:経過)
              </label>
            </td>
          </tr>
          <tr> -->
          <tr>
            <td>
              <v-ons-checkbox
                :checked="isLcdMedi"
                @change="onIsLcdMedi($event)"
                input-id="cBoxLcdMedi"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxLcdMedi">
                仮想端末投与時間帯表示
              </label>
            </td>
          </tr>
          <tr>
            <td>
              <v-ons-checkbox
                :checked="lcdMediTime"
                @change="onLcdMediTime($event)"
                input-id="cBoxLcdMediTime"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxLcdMediTime">
                仮想端末投与時間
                <br />(OFF:時刻、ON:経過)
              </label>
            </td>
          </tr>
          <!-- mod 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao end-->
          <tr>
            <td style="width: 300px">
              <v-ons-checkbox
                :checked="isOfflineStartTime"
                @change="onIsDisableOfflineStartTime($event)"
                input-id="c-box-offline-start"
              ></v-ons-checkbox>
              <label class="label-titile" for="c-box-offline-start">オフライン運転自動開始時間(秒)</label>
            </td>
            <td>
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
              <!-- <v-ons-input
                class="textbox"
                style="width: 100px"
                type="number"
                :max="SMALL_INT_MAX"
                min="0"
                pattern="\d*"
                :disabled="isDisableOfflineStartTime"
                v-model="inputModel.offlineStartTime"
                v-on:change="onChangeOfflineStartTime"
              /> -->
              <v-ons-input
                :class="'textbox ' +isEdited('offlineStartTime')"
                style="width: 100px; background-color: #ffff99 !important"
                type="number"
                pattern="\d*"
                :disabled="isDisableOfflineStartTime"
                v-model="inputModel.offlineStartTime"
                @change="inputNumber($event, 0, SMALL_INT_MAX, 'offlineStartTime')"
                @focus="handleFocus(0)"
                @mousewheel.prevent="handleMouseWheel($event, 0, SMALL_INT_MAX, 'offlineStartTime', 0)"
                v-on:blur="onChangeOfflineStartTime($event, 0, SMALL_INT_MAX, 'offlineStartTime', 0)"
              />
            </td>
          </tr>
          <tr>
            <td>
              <v-ons-checkbox
                :checked="isOfflineAutoEnd"
                @change="onIsOfflineAutoEnd($event)"
                input-id="c-box-offline-end"
              ></v-ons-checkbox>
              <label class="label-titile" for="c-box-offline-end">
                オフライン運転自動終了
                <br />(OFF:しない、ON:する)
              </label>
            </td>
          </tr>
          <tr>
            <td style="width: 300px">
              <label class="label-titile">装置生存監視時間(秒)</label>
            </td>
            <td>
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
              <!-- <v-ons-input
                class="textbox"
                style="width: 100px"
                type="number"
                pattern="\d*"
                :max="SMALL_INT_MAX"
                min="0"
                v-model="inputModel.deviceTimeout"
                v-on:change="onChangeDeviceTimeout"
                @blur="onChangeDeviceTimeout($event, 0, SMALL_INT_MAX, 'deviceTimeout')"
              /> -->
              <v-ons-input
                :class="'textbox ' +isEdited('deviceTimeout')"
                style="width: 100px"
                type="number"
                pattern="\d*"
                v-model="inputModel.deviceTimeout"
                v-on:change="onChangeDeviceTimeout"
                @change="inputNumber($event, 0, SMALL_INT_MAX, 'deviceTimeout')"
                @focus="handleFocus(1)"
                @mousewheel.prevent="handleMouseWheel($event, 0, SMALL_INT_MAX, 'deviceTimeout', 1)"
                v-on:blur="onChangeOfflineStartTime($event, 0, SMALL_INT_MAX, 'deviceTimeout', 1)"
              />
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end -->
            </td>
          </tr>
          <!-- #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 start -->
          <tr>
            <td>
              <v-ons-checkbox
                :checked="isNextPatSplitarea"
                @change="onIsNextPatSplitArea($event)"
                input-id="cBoxNextPatSplitArea"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxNextPatSplitArea">
                次患者情報2段組表示
                <br />(OFF:1段組、ON:2段組)
              </label>
            </td>
          </tr>
          <!-- #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 end -->
        </tbody>
        <tbody class="tbody-right">
          <tr>
            <td style="width: 300px">
              <label class="label-titile">排液判定待機時間(秒)</label>
            </td>
            <td>
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
              <!-- <v-ons-input
                class="textbox"
                style="width: 100px"
                type="number"
                pattern="\d*"
                :max="SMALL_INT_MAX"
                min="0"
                v-model="inputModel.endWaitTime"
                v-on:change="onChangeEndWaitTime"
              /> -->
              <v-ons-input
                :class="'textbox ' +isEdited('endWaitTime')"
                style="width: 100px"
                type="number"
                pattern="\d*"
                v-model="inputModel.endWaitTime"
                v-on:blur="onChangeEndWaitTime($event, 0, SMALL_INT_MAX, 'endWaitTime', 2)"
                @focus="handleFocus(2)"
                @change="inputNumber($event, 0, SMALL_INT_MAX, 'endWaitTime')"
                @mousewheel.prevent="handleMouseWheel($event, 0, SMALL_INT_MAX, 'endWaitTime', 2)"
              />
            </td>
          </tr>
          <tr>
            <td>
              <v-ons-checkbox
                :checked="patTiming"
                @change="onPatTiming($event)"
                input-id="cBoxPatTiming"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxPatTiming">
                患者切り替えタイミング
                <br />(OFF:後体重測定、ON:実績初版確定)
              </label>
            </td>
          </tr>
          <tr>
            <td>
              <v-ons-checkbox
                :checked="isNotice"
                @change="onIsNotice($event)"
                input-id="cBoxNotice"
              ></v-ons-checkbox>
              <label class="label-titile" for="cBoxNotice">お知らせ機能補正時間(秒)</label>
            </td>
            <td>
              <v-ons-input
                :class="'textbox ' +isEdited('noticeTime')"
                style="background-color: #ffff99 !important"
                type="number"
                pattern="\d*"
                v-bind:disabled="isDisableNotice"
                v-model="inputModel.noticeTime"
                v-on:change="onChangeNoticeTime"
              />
            </td>
          </tr>
          <tr>
            <td>
              <label class="label-titile">ログのアップロード実施時刻</label>
            </td>
            <td>
              <time-input
                v-model="inputModel.logUploadTime"
                :classes="'input-time time-input-required time-input-focus ' +isEdited('logUploadTime')"
                :default-time="defaultTime('logUploadTime')"
                @blur="onChangeLogUploadTime"
                isRequired
              />
            </td>
          </tr>
          <tr>
            <td>
              <label class="label-titile">日付変更時の次患者更新時刻</label>
            </td>
            <td>
              <time-input
                v-model="inputModel.reloadNextPatTime"
                :classes="'input-time time-input-required time-input-focus ' +isEdited('reloadNextPatTime')"
                :default-time="defaultTime('reloadNextPatTime')"
                @blur="onChangeReloadNextPatTime"
                isRequired
              />
            </td>
          </tr>
          <tr>
            <td style="width: 300px">
              <label class="label-titile">次患者送信モード</label>
              <v-ons-icon icon="fa-question-circle" @click="showPopOver($event, txtHelp)"></v-ons-icon>
            </td>
            <td>
              <v-ons-select
                :class="'selectbox ' +isEdited('nextPatMode')"
                model-event="change"
                v-model="inputModel.nextPatMode"
                name="nextPatMode"
                @change="onChangeNextPatMode"
              >
                <option
                  v-for="(item, index) in comboList.nextPatMode"
                  :key="index"
                  :value="item.cd"
                >{{ item.text }}</option>
              </v-ons-select>
            </td>
          </tr>
          <tr>
            <td style="width: 300px">
              <label class="label-titile">次患者検索期間(日)</label>
            </td>
            <td>
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
              <!-- <v-ons-input
                class="textbox"
                style="width: 100px"
                type="number"
                pattern="\d*"
                max="7"
                min="0"
                v-model="inputModel.nextPatModeRange"
                v-on:change="onChangeNextPatModeRange"
              /> -->
              <v-ons-input
                :class="'textbox ' +isEdited('nextPatModeRange')"
                style="width: 100px"
                type="number"
                pattern="\d*"
                @change="inputNumber($event, 0, 7, 'nextPatModeRange')"
                @focus="handleFocus(3)"
                @mousewheel.prevent="handleMouseWheel($event, 0, 7, 'nextPatModeRange', 3)"
                v-model="inputModel.nextPatModeRange"
                v-on:blur="onChangeNextPatModeRange($event, 0, 7, 'nextPatModeRange', 3)"
              />
            </td>
          </tr>
          <tr>
            <td style="width: 300px">
              <label class="label-titile">治療中モニタ通知間隔(秒)</label>
            </td>
            <td>
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
              <!-- <v-ons-input
                class="textbox"
                style="width: 100px"
                type="number"
                pattern="\d*"
                :max="SMALL_INT_MAX"
                min="0"
                v-model="inputModel.treatMoniInterval"
                v-on:change="onChangeTreatMoniInterval"
              /> -->
              <v-ons-input
                :class="'textbox ' +isEdited('treatMoniInterval')"
                style="width: 100px"
                type="number"
                pattern="\d*"
                @change="inputNumber($event, 0, SMALL_INT_MAX, 'treatMoniInterval')"
                @focus="handleFocus(4)"
                @mousewheel.prevent="handleMouseWheel($event, 0, SMALL_INT_MAX, 'treatMoniInterval', 4)"
                v-model="inputModel.treatMoniInterval"
                v-on:blur="onChangeTreatMoniInterval($event, 0, SMALL_INT_MAX, 'treatMoniInterval', 4)"
              />
            </td>
          </tr>
          <tr>
            <td style="width: 300px">
              <label class="label-titile">治療外モニタ通知間隔(秒)</label>
            </td>
            <td>
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
              <!-- <v-ons-input
                class="textbox"
                style="width: 100px"
                type="number"
                pattern="\d*"
                :max="SMALL_INT_MAX"
                min="0"
                v-model="inputModel.otherMoniInterval"
                v-on:change="onChangeOtherMoniInterval"
              /> -->
              <v-ons-input
                :class="'textbox ' +isEdited('otherMoniInterval')"
                style="width: 100px"
                type="number"
                pattern="\d*"
                @change="inputNumber($event, 0, SMALL_INT_MAX, 'otherMoniInterval')"
                @focus="handleFocus(5)"
                @mousewheel.prevent="handleMouseWheel($event, 0, SMALL_INT_MAX, 'otherMoniInterval', 5)"
                v-model="inputModel.otherMoniInterval"
                v-on:blur="onChangeOtherMoniInterval($event, 0, SMALL_INT_MAX, 'otherMoniInterval', 5)"
              />
            </td>
          </tr>
          <!-- add 楊 start -->
          <tr>
            <td style="width: 300px">
              <label class="label-titile">治療中リアルタイムモニタ通知間隔(秒)</label>
            </td>
            <td>
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
              <!-- <v-ons-input
                class="textbox"
                style="width: 100px"
                type="number"
                pattern="\d*"
                :max="SMALL_INT_MAX"
                min="0"
                v-model="inputModel.treatRealtimeMonitoInterval"
                v-on:change="onChangeTreatRealtimeMonitoInterval"
              /> -->
              <v-ons-input
                :class="'textbox ' +isEdited('treatRealtimeMonitoInterval')"
                style="width: 100px"
                type="number"
                pattern="\d*"
                @change="inputNumber($event, 0, SMALL_INT_MAX, 'treatRealtimeMonitoInterval')"
                @focus="handleFocus(6)"
                @mousewheel.prevent="handleMouseWheel($event, 0, SMALL_INT_MAX, 'treatRealtimeMonitoInterval', 6)"
                v-model="inputModel.treatRealtimeMonitoInterval"
                v-on:blur="onChangeTreatRealtimeMonitoInterval($event, 0, SMALL_INT_MAX, 'treatRealtimeMonitoInterval', 6)"
              />
            </td>
          </tr>
          <tr>
            <td style="width: 300px">
              <label class="label-titile">治療外リアルタイムモニタ通知間隔(秒)</label>
            </td>
            <td>
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start -->
              <!-- <v-ons-input
                class="textbox"
                style="width: 100px"
                type="number"
                pattern="\d*"
                :max="SMALL_INT_MAX"
                min="0"
                v-model="inputModel.otherRealtimeMonitoInterval"
                v-on:change="onChangeOtherRealtimeMonitoInterval"
              /> -->
              <v-ons-input
                :class="'textbox ' +isEdited('otherRealtimeMonitoInterval')"
                style="width: 100px"
                type="number"
                pattern="\d*"
                @change="inputNumber($event, 0, SMALL_INT_MAX, 'otherRealtimeMonitoInterval')"
                @focus="handleFocus(7)"
                 @mousewheel.prevent="handleMouseWheel($event, 0, SMALL_INT_MAX, 'otherRealtimeMonitoInterval', 7)"
                v-model="inputModel.otherRealtimeMonitoInterval"
                v-on:blur="onChangeOtherRealtimeMonitoInterval($event, 0, SMALL_INT_MAX, 'otherRealtimeMonitoInterval', 7)"
              />
              <!-- mod #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end -->
            </td>
          </tr>
          <!-- add 楊 end -->
        </tbody>
      </div>
    </div>
    <v-ons-popover
      cancelable
      :visible.sync="userMenuPopoverVisible"
      :target="userMenuPopoverTarget"
      :cover-target="false"
      :direction="userMenuPopoverDirection"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="help-area">
        <label id="pop-over-message">テスト</label>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import PopoverMixin from "@/components/PopoverMixin";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { EventBus } from "@/eventBus.js";
import TimeInput from "@/components/common/TimeInput.vue";

export default {
  mixins: [PopoverMixin],
  name: "MstComsvSetting",
  components: {
    "time-input": TimeInput,
  },
  data() {
    return {
      show: true,
      toggleA: true,
      toggleB: false,
      inputModel: {
        comsvCd: "",
        facilityCd: "",
        deviceEdgeNo: "",
        isTimeset: "",
        timesetTime: "",
        isTimesetNx: "",
        isNoticeMedi: "", // add 「投薬変更のお知らせ」の有無を判断する項目を追加 劉
        timesetNxTime: "",
        lcdLogTime: "",
        lcdLogType: "",
        isLcdMedi: "",
        // add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao start
        lcdMediTime: "",
        // add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao end
        endWaitTime: "",
        patTiming: "",
        isNotice: "",
        noticeTime: "",
        logUploadTime: "",
        offlineStartTime: null,
        isOfflineAutoEnd: "0",
        reloadNextPatTime: "0100",
        nextPatMode: 1,
        nextPatModeRange: 7,
        lcdMenu: "",
        lcdNpat: "",
        lcdReport: "",
        lcdGraph1: "",
        lcdGraph2: "",
        lcdRadar: "",
        regDate: "",
        upDate: "",
        deviceTimeout: "",
        treatMoniInterval: "",
        otherMoniInterval: "",
        treatRealtimeMonitoInterval:"",
        otherRealtimeMonitoInterval:"",
        // #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 start
        isNextPatSplitarea: "0",
        // #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 end
      },
      isTimeset: false,
      isTimesetNx: false,
      isNoticeMedi: false, // add「投薬変更のお知らせ」の有無を判断する項目を追加 劉
      lcdLogTime: false,
      lcdLogType: false,
      isLcdMedi: false,
      // add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao start
      lcdMediTime: false,
      // add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao end
      patTiming: false,
      isNotice: false,
      // #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 start
      isNextPatSplitarea: false,
      // #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 end
      isOfflineStartTime: false,
      isOfflineAutoEnd: false,
      isDisableTimeset: false,
      isDisableTimesetNx: false,
      isDisableNotice: false,
      isDisableOfflineStartTime: true,
      // 正規表現
      regExp: {
        // 数字
        numeric: /^[0-9０-９]+$/,
        // 時間
        time: /^([0-1][0-9]|[2][0-3])[0-5][0-9]$/
      },
      SMALL_INT_MAX: 32762,
      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: "left",
      txtHelp:
        "1: 施設全体で直近の予定がある透析日の次患者を表示\n2: ベッド単位で直近の予定がある透析日の次患者を表示",
      // #5589 2023/04/24 数値IFのスタイル全不正 张博 start
      blurFlg: false,
      focusFlg: [false, false, false, false, false, false, false, false],
      // #5589 2023/04/24 数値IFのスタイル全不正 张博 end
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-com-sv-setting", {
      initEditRecord: "getInitEditRecord"
    }),
    comboList() {
      return {
        nextPatMode: [
          { cd: 1, text: "1:施設毎" },
          { cd: 2, text: "2:ベッド毎" }
        ]
      };
    }
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    isEdited(field) {
      let beforeVal = this.initEditRecord[field];
      let afterVal = this.editRecord[field];
      if (beforeVal != afterVal) {
        return "time-input-edited";
      }
      return "";
    },
    /** 
    * sys_master_define.column_infoのdefaultValueから各時刻項目のデフォルト値を"HH:mm"形式で取得
    * 未設定の場合は空文字""を返却する
    */
    defaultTime(field) {
      let defaultValue = this.getSchemaByField(field).defaultValue;
      if (/^\d{4}$/.test(defaultValue)) {
        return `${defaultValue.slice(0, 2)}:${defaultValue.slice(2)}`;
      } else if (/^\d{1,2}:\d{2}$/.test(defaultValue)) {
        let [hours, minutes] = defaultValue.split(':');
        hours = hours.padStart(2, '0');
        minutes = minutes.padEnd(2, '0');
        return `${hours}:${minutes}`;
      } else {
        return "";
      }
    },
    // add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 start
    inputNumber(event, min, max, key){
    //add 6749 仮想端末の透析日報は最大8項目まで表示可能です。 ljg start
          if(event.srcElement.value !== undefined){
            if ( event.srcElement.value == '' && key == 'endWaitTime') {
              this.$ons.notification.alert({
                title: DIALOG_MESSAGES['00200047'].title,
                message: messageFormat(DIALOG_MESSAGES['00200047'].message),
              });
              return;
            }
          }
    //add 6749 排液判定待機時間(秒)未入力時間を入力、する必要があります。 ljg end
      // 数値範囲内かどうかの確認
      if (min !== undefined && max !== undefined) {
        if (event.target.value > max) {
          this.inputModel[key] = min
          this.blurFlg = true
        } else if (event.target.value < min) {
          this.inputModel[key] = max
          this.blurFlg = true
        } else {
          this.blurFlg = false
        }
      }
    },
    handleMouseWheel(e, min, max, key, index) {
      if (!this.focusFlg[index]) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = min
      }
      let value = parseFloat(e.target.value);
      const parameterStep = 1;
      if (delta > 0) {
        // 滑ります
        value += parameterStep
      } else {
        // 下がります
        value -= parameterStep
      }
      // 数値範囲内かどうかの確認
      if (value > max) {
        value = min;
      }
      if(value < min) {
        value = max;
      }
      this.inputModel[key] = value
      EventBus.$emit("mstHolidayRegistered", false);
    },
    handleBlurNumber (event, min, max, key) {
      let blurFlg = false;
      // 数値範囲内かどうかの確認
      if (event.target.value == max && this.blurFlg) {
        this.inputModel[key] = min
        blurFlg = true
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        this.inputModel[key] = max
        blurFlg = true
        this.blurFlg = false
      } else {
        blurFlg = false
      }
      if (blurFlg) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "日付の入力内容が違います。"
          title: DIALOG_MESSAGES['00200049'].title,
          message: messageFormat(DIALOG_MESSAGES['00200049'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
    },
    handleFocus(index){
      this.focusFlg[index]=true;
    },
    // add #5589 2023/04/11 数値IFのスタイル全不正 林峻峰 end
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
    onIsTimeset(ev) {
      if (ev.target.checked) {
        this.updateEditRecord("isTimeset", "1");
        this.isDisableTimeset = false;
      } else {
        this.updateEditRecord("isTimeset", "0");
        this.isDisableTimeset = true;
      }
    },
    onIsTimesetNx(ev) {
      if (ev.target.checked) {
        this.updateEditRecord("isTimesetNx", "1");
        this.isDisableTimesetNx = false;
      } else {
        this.updateEditRecord("isTimesetNx", "0");
        this.isDisableTimesetNx = true;
      }
    },
    // add 「投薬変更のお知らせ」の有無を判断する項目を追加 劉 start
    onIsNoticeMedi(ev) {
      if (ev.target.checked) {
        this.updateEditRecord("isNoticeMedi", "1");
        this.isDisableTimesetMedi = false;
      } else {
        this.updateEditRecord("isNoticeMedi", "0");
        this.isDisableTimesetMedi = true;
      }
    },
    // add 「投薬変更のお知らせ」の有無を判断する項目を追加 劉 end
    onLcdLogTime(ev) {
      if (ev.target.checked) {
        this.updateEditRecord("lcdLogTime", "1");
      } else {
        this.updateEditRecord("lcdLogTime", "0");
      }
    },
    onLcdLogType(ev) {
      if (ev.target.checked) {
        this.updateEditRecord("lcdLogType", "1");
      } else {
        this.updateEditRecord("lcdLogType", "0");
      }
    },
    onIsLcdMedi(ev) {
      if (ev.target.checked) {
        this.updateEditRecord("isLcdMedi", "1");
      } else {
        this.updateEditRecord("isLcdMedi", "0");
      }
    },
    // add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao start
    onLcdMediTime(ev) {
      if (ev.target.checked) {
        this.updateEditRecord("lcdMediTime", "1");
      } else {
        this.updateEditRecord("lcdMediTime", "0");
      }
    },
    // add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao end
    onPatTiming(ev) {
      if (ev.target.checked) {
        this.updateEditRecord("patTiming", "1");
      } else {
        this.updateEditRecord("patTiming", "0");
      }
    },
    onIsNotice(ev) {
      if (ev.target.checked) {
        this.updateEditRecord("isNotice", "1");
        this.isDisableNotice = false;
      } else {
        this.updateEditRecord("isNotice", "0");
        this.isDisableNotice = true;
      }
    },
    onIsDisableOfflineStartTime(ev) {
      this.isOfflineStartTime = ev.target.checked;
      this.isDisableOfflineStartTime = !ev.target.checked;
      if (ev.target.checked) {
        this.updateEditRecord(
          "offlineStartTime",
          this.inputModel.offlineStartTime
        );
      } else {
        this.updateEditRecord("offlineStartTime", null);
      }
    },
    onIsOfflineAutoEnd(ev) {
      this.isOfflineAutoEnd = ev.target.checked;
      if (ev.target.checked) {
        this.updateEditRecord("isOfflineAutoEnd", "1");
      } else {
        this.updateEditRecord("isOfflineAutoEnd", "0");
      }
    },
    // #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 start
    onIsNextPatSplitArea(ev) {
      this.isNextPatSplitarea = ev.target.checked;
      if (ev.target.checked) {
        this.updateEditRecord("nextPatSplitarea", "1");
      } else {
        this.updateEditRecord("nextPatSplitarea", "0");
      }
    },
    // #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 end
    onChangeTimesetTime() {
      const timesetTime = this.getTimeNumber(this.inputModel.timesetTime);
      if (timesetTime === null || timesetTime === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間を入力する必要があります。"
          title: DIALOG_MESSAGES['00200047'].title,
          message: messageFormat(DIALOG_MESSAGES['00200047'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 型チェック-時間
      if (!this.regExp.time.test(timesetTime)) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 文字数チェック
      if (timesetTime.length !== 4) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      this.updateEditRecord("timesetTime", timesetTime);
    },
    onChangeTimesetNxTime() {
      const timesetNxTime = this.getTimeNumber(this.inputModel.timesetNxTime);
      if (timesetNxTime === null || timesetNxTime === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間を入力する必要があります。"
          title: DIALOG_MESSAGES['00200047'].title,
          message: messageFormat(DIALOG_MESSAGES['00200047'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 型チェック-時間
      if (!this.regExp.time.test(timesetNxTime)) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 文字数チェック
      if (timesetNxTime.length !== 4) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力桁数が違います。"
          title: DIALOG_MESSAGES['00200048'].title,
          message: messageFormat(DIALOG_MESSAGES['00200048'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      this.updateEditRecord("timesetNxTime", timesetNxTime);
    },
    onChangeEndWaitTime(event, min, max, key,index) {
      const endWaitTime = this.inputModel.endWaitTime;
      let blurFlg = false;
      // 数値範囲内かどうかの確認
      if (event.target.value == max && this.blurFlg) {
        this.inputModel[key] = min
        blurFlg = true
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        this.inputModel[key] = max
        blurFlg = true
        this.blurFlg = false
      } else {
        blurFlg = false
      }
      this.focusFlg[index]=false;
      if (endWaitTime === null || endWaitTime === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間を入力する必要があります。"
          title: DIALOG_MESSAGES['00200047'].title,
          message: messageFormat(DIALOG_MESSAGES['00200047'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 型チェック-数字
      if (
        // !this.regExp.numeric.test(endWaitTime) ||
        // Number(endWaitTime) > this.SMALL_INT_MAX ||
        // Number(endWaitTime) < 0
        blurFlg
      ) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc start
      // this.updateEditRecord("endWaitTime", this.inputModel.endWaitTime);
      this.updateEditRecord("endWaitTime", Number(this.inputModel.endWaitTime));
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc end
    },
    onChangeDeviceTimeout(event, min, max, key) {
      const deviceTimeout = this.inputModel.deviceTimeout;
      let blurFlg = false;
      // 数値範囲内かどうかの確認
      if (event.target.value == max && this.blurFlg) {
        this.inputModel[key] = min
        blurFlg = true
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        this.inputModel[key] = max
        blurFlg = true
        this.blurFlg = false
      } else {
        blurFlg = false
      }
      if (deviceTimeout === null || deviceTimeout === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間を入力する必要があります。"
          title: DIALOG_MESSAGES['00200047'].title,
          message: messageFormat(DIALOG_MESSAGES['00200047'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 型チェック-数字
      if (
        // !this.regExp.numeric.test(deviceTimeout) ||
        // Number(deviceTimeout) > this.SMALL_INT_MAX ||
        // Number(deviceTimeout) < 0
        blurFlg
      ) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc start
      // this.updateEditRecord("deviceTimeout", this.inputModel.deviceTimeout);
      this.updateEditRecord("deviceTimeout", Number(this.inputModel.deviceTimeout));
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc end
    },
    onChangeTreatMoniInterval(event, min, max, key,index) {
      let blurFlg = false;
      // 数値範囲内かどうかの確認
      if (event.target.value == max && this.blurFlg) {
        this.inputModel[key] = min
        blurFlg = true
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        this.inputModel[key] = max
        blurFlg = true
        this.blurFlg = false
      } else {
        blurFlg = false
      }
      this.focusFlg[index]=false;
      const treatMoniInterval = this.inputModel.treatMoniInterval;
      if (treatMoniInterval === null || treatMoniInterval === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間を入力する必要があります。"
          title: DIALOG_MESSAGES['00200047'].title,
          message: messageFormat(DIALOG_MESSAGES['00200047'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 型チェック-数字
      if (
        // !this.regExp.numeric.test(treatMoniInterval) ||
        // Number(treatMoniInterval) > this.SMALL_INT_MAX ||
        // Number(treatMoniInterval) < 0
        blurFlg
      ) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc start
      // this.updateEditRecord("treatMoniInterval", this.inputModel.treatMoniInterval);
      this.updateEditRecord("treatMoniInterval", Number(this.inputModel.treatMoniInterval));
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc end
    },
    onChangeOtherMoniInterval(event, min, max, key,index) {
      let blurFlg = false;
      // 数値範囲内かどうかの確認
      if (event.target.value == max && this.blurFlg) {
        this.inputModel[key] = min
        blurFlg = true
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        this.inputModel[key] = max
        blurFlg = true
        this.blurFlg = false
      } else {
        blurFlg = false
        this.blurFlg = false
      }
      this.focusFlg[index]=false;
      const otherMoniInterval = this.inputModel.otherMoniInterval;
      if (otherMoniInterval === null || otherMoniInterval === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間を入力する必要があります。"
          title: DIALOG_MESSAGES['00200047'].title,
          message: messageFormat(DIALOG_MESSAGES['00200047'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 型チェック-数字
      if (
        // !this.regExp.numeric.test(otherMoniInterval) ||
        // Number(otherMoniInterval) > this.SMALL_INT_MAX ||
        // Number(otherMoniInterval) < 0
        blurFlg
      ) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc start
      // this.updateEditRecord("otherMoniInterval", this.inputModel.otherMoniInterval);
      this.updateEditRecord("otherMoniInterval", Number(this.inputModel.otherMoniInterval));
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc end
    },
    // add 楊 start
    onChangeTreatRealtimeMonitoInterval(event, min, max, key, index) {
      let blurFlg = false;
      // 数値範囲内かどうかの確認
      if (event.target.value == max && this.blurFlg) {
        this.inputModel[key] = min
        blurFlg = true
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        this.inputModel[key] = max
        blurFlg = true
        this.blurFlg = false
      } else {
        blurFlg = false
      }
      this.focusFlg[index]=false;
      const treatRealtimeMonitoInterval = this.inputModel.treatRealtimeMonitoInterval;
      // if (treatRealtimeMonitoInterval === null || treatRealtimeMonitoInterval === "") {
      if (blurFlg) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000010].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          // add 全マスタメッセージ調整 王 start
          // message: "時間を入力する必要があります。"
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message: DIALOG_MESSAGES[12000010]
          message: DIALOG_MESSAGES[12000010].message
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          // add 全マスタメッセージ調整 王 end
        });
        return;
      }
      // 型チェック-数字
      if (
        !this.regExp.numeric.test(treatRealtimeMonitoInterval) ||
        Number(treatRealtimeMonitoInterval) > this.SMALL_INT_MAX ||
        Number(treatRealtimeMonitoInterval) < 0
      ) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000011].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          // add 全マスタメッセージ調整 王 start
          // message: "時間の入力内容が違います。"
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message: DIALOG_MESSAGES[12000011]
          message: DIALOG_MESSAGES[12000011].message
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // add 全マスタメッセージ調整 王 end
        });
        return;
      }
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc start
      // this.updateEditRecord("treatRealtimeMonitoInterval", this.inputModel.treatRealtimeMonitoInterval);
      this.updateEditRecord("treatRealtimeMonitoInterval", Number(this.inputModel.treatRealtimeMonitoInterval));
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc end
    },
    onChangeOtherRealtimeMonitoInterval(event, min, max, key, index) {
      let blurFlg = false;
      // 数値範囲内かどうかの確認
      if (event.target.value == max && this.blurFlg) {
        this.inputModel[key] = min
        blurFlg = true
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        this.inputModel[key] = max
        blurFlg = true
        this.blurFlg = false
      } else {
        blurFlg = false
      }
      this.focusFlg[index]=false;
      const otherRealtimeMonitoInterval = this.inputModel.otherRealtimeMonitoInterval;
      // if (otherRealtimeMonitoInterval === null || otherRealtimeMonitoInterval === "") {
      if (blurFlg) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000010].title,
          message: DIALOG_MESSAGES[12000010].message
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          // add 全マスタメッセージ調整 王 start
          // message: "時間を入力する必要があります。"
          // add 全マスタメッセージ調整 王 end
        });
        return;
      }
      // 型チェック-数字
      if (
        !this.regExp.numeric.test(otherRealtimeMonitoInterval) ||
        Number(otherRealtimeMonitoInterval) > this.SMALL_INT_MAX ||
        Number(otherRealtimeMonitoInterval) < 0
      ) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000011].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          // add 全マスタメッセージ調整 王 start
          // message: "時間の入力内容が違います。"
          message: DIALOG_MESSAGES[12000011].message
          // add 全マスタメッセージ調整 王 end
        });
        return;
      }
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc start
      // this.updateEditRecord("otherRealtimeMonitoInterval", this.inputModel.otherRealtimeMonitoInterval);
      this.updateEditRecord("otherRealtimeMonitoInterval", Number(this.inputModel.otherRealtimeMonitoInterval));
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc end
    },
    // add 楊 end
    onChangeNoticeTime() {
      const noticeTime = this.inputModel.noticeTime;
      if (noticeTime === null || noticeTime === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間を入力する必要があります。"
          title: DIALOG_MESSAGES['00200047'].title,
          message: messageFormat(DIALOG_MESSAGES['00200047'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 型チェック-数字
      if (
        !this.regExp.numeric.test(noticeTime) ||
        Number(noticeTime) > this.SMALL_INT_MAX ||
        Number(noticeTime) < 0
      ) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc start
      // this.updateEditRecord("noticeTime", this.inputModel.noticeTime);
      this.updateEditRecord("noticeTime", Number(this.inputModel.noticeTime));
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc end
    },
    onChangeLogUploadTime() {
      const logUploadTime = this.getTimeNumber(this.inputModel.logUploadTime);
      if (logUploadTime === null || logUploadTime === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間を入力する必要があります。"
          title: DIALOG_MESSAGES['00200047'].title,
          message: messageFormat(DIALOG_MESSAGES['00200047'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 型チェック-時間
      if (!this.regExp.time.test(logUploadTime)) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 文字数チェック
      if (logUploadTime.length !== 4) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力桁数が違います。"
          title: DIALOG_MESSAGES['00200048'].title,
          message: messageFormat(DIALOG_MESSAGES['00200048'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      this.updateEditRecord("logUploadTime", logUploadTime);
    },
    onChangeOfflineStartTime(event, min, max, key,index) {
      const startTime = this.inputModel.offlineStartTime;
      if (startTime === null || startTime === "") {
        this.updateEditRecord("offlineStartTime", null);
      } else {
        let blurFlg = false;
        // 数値範囲内かどうかの確認
        if (event.target.value == max && this.blurFlg) {
          this.inputModel[key] = min
          blurFlg = true
          this.blurFlg = false
        }else if (event.target.value == min && this.blurFlg) {
          this.inputModel[key] = max
          blurFlg = true
          this.blurFlg = false
        } else {
          blurFlg = false
        }
        if (blurFlg) {
            this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            // message: "時間の入力内容が違います。"
            title: DIALOG_MESSAGES[12000011].title,
            message: messageFormat(DIALOG_MESSAGES[12000011].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          return;
        }
        // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc start
        // this.updateEditRecord("offlineStartTime", startTime);
        this.updateEditRecord("offlineStartTime", Number(startTime));
        // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc end
      }
      this.focusFlg[index]=false;
    },
    onChangeReloadNextPatTime() {
      const reloadNextPatTime = this.getTimeNumber(
        this.inputModel.reloadNextPatTime
      );
      if (reloadNextPatTime === null || reloadNextPatTime === "") {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間を入力する必要があります。"
          title: DIALOG_MESSAGES['00200047'].title,
          message: messageFormat(DIALOG_MESSAGES['00200047'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 型チェック-時間
      if (!this.regExp.time.test(reloadNextPatTime)) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力内容が違います。"
          title: DIALOG_MESSAGES[12000011].title,
          message: messageFormat(DIALOG_MESSAGES[12000011].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // 文字数チェック
      if (reloadNextPatTime.length !== 4) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "時間の入力桁数が違います。"
          title: DIALOG_MESSAGES['00200048'].title,
          message: messageFormat(DIALOG_MESSAGES['00200048'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      this.updateEditRecord("reloadNextPatTime", reloadNextPatTime);
    },
    onChangeNextPatMode() {
      this.updateEditRecord("nextPatMode", this.inputModel.nextPatMode);
    },
    onChangeNextPatModeRange(event, min, max, key,index) {
      const nextPatModeRange = this.inputModel.nextPatModeRange;
      let blurFlg = false;
      // 数値範囲内かどうかの確認
      if (event.target.value == max && this.blurFlg) {
        this.inputModel[key] = min
        blurFlg = true
        this.blurFlg = false
      }else if (event.target.value == min && this.blurFlg) {
        this.inputModel[key] = max
        blurFlg = true
        this.blurFlg = false
      } else {
        blurFlg = false
      }
      this.focusFlg[index]=false;
      if (blurFlg) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          // message: "日付の入力内容が違います。"
          title: DIALOG_MESSAGES['00200049'].title,
          message: messageFormat(DIALOG_MESSAGES['00200049'].message),
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        });
        return;
      }
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc start
      // this.updateEditRecord("nextPatModeRange", nextPatModeRange);
      this.updateEditRecord("nextPatModeRange", Number(nextPatModeRange));
      // mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231130 ztc end
    },
    /**
     * 時刻表示の変換('9999' => '99:99')
     * @param str 変換前時刻('9999')
     */
    getTimeFormat(str) {
      str = str === null ? "" : str;
      str = undefined === str ? "" : str;
      return str.replace(/^(..)(..)/, "$1:$2");
    },
    /**
     * inputModelへ入力内容を適用(時間表記をhh:mmからhhmmへ変換)
     */
    getTimeNumber(targetValue) {
      targetValue = targetValue === null ? "" : targetValue;
      targetValue =
        undefined === targetValue
          ? ""
          : targetValue.replace(/^(..):(..)/, "$1$2");
      return targetValue;
    },
    /**
     * 吹き出し表示処理
     */
    showPopOver(event, message) {
      var pop = document.getElementById("pop-over-message");
      pop.innerText = message;
      this.userMenuPopoverTarget = event;
      this.userMenuPopoverVisible = true;
    }
  },
  mounted() {
    // 描画系の処理がすべて完了した後に実行される処理
    for (const columnDefinition of this.columnDefinition) {
      if (columnDefinition.field === "comsvCd") {
        this.inputModel.comsvCd = this.getValueByField(columnDefinition.field);
      }
      if (columnDefinition.field === "facilityCd") {
        this.inputModel.facilityCd = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "deviceEdgeNo") {
        this.inputModel.deviceEdgeNo = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "isTimeset") {
        this.inputModel.isTimeset = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.isTimeset == 1) {
          this.isTimeset = true;
          this.isDisableTimeset = false;
        } else {
          this.isTimeset = false;
          this.isDisableTimeset = true;
        }
      }
      if (columnDefinition.field === "timesetTime") {
        this.inputModel.timesetTime = this.getTimeFormat(
          this.getValueByField(columnDefinition.field)
        );
      }
      if (columnDefinition.field === "isTimesetNx") {
        this.inputModel.isTimesetNx = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.isTimesetNx == 1) {
          this.isTimesetNx = true;
          this.isDisableTimesetNx = false;
        } else {
          this.isTimesetNx = false;
          this.isDisableTimesetNx = true;
        }
      }
      if (columnDefinition.field === "timesetNxTime") {
        this.inputModel.timesetNxTime = this.getTimeFormat(
          this.getValueByField(columnDefinition.field)
        );
      }
      // add 「投薬変更のお知らせ」の有無を判断する項目を追加 劉 start
      if (columnDefinition.field === "isNoticeMedi") {
        this.inputModel.isNoticeMedi = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.isNoticeMedi == 1) {
          this.isNoticeMedi = true;
        } else {
          this.isNoticeMedi = false;
        }
      }
      // add 「投薬変更のお知らせ」の有無を判断する項目を追加 劉 end
      if (columnDefinition.field === "lcdLogTime") {
        this.inputModel.lcdLogTime = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.lcdLogTime == 1) {
          this.lcdLogTime = true;
        } else {
          this.lcdLogTime = false;
        }
      }
      if (columnDefinition.field === "lcdLogType") {
        this.inputModel.lcdLogType = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.lcdLogType == 1) {
          this.lcdLogType = true;
        } else {
          this.lcdLogType = false;
        }
      }
      if (columnDefinition.field === "isLcdMedi") {
        this.inputModel.isLcdMedi = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.isLcdMedi == 1) {
          this.isLcdMedi = true;
        } else {
          this.isLcdMedi = false;
        }
      }
      // add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao start
      if (columnDefinition.field === "lcdMediTime") {
        this.inputModel.lcdMediTime = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.lcdMediTime == 1) {
          this.lcdMediTime = true;
        } else {
          this.lcdMediTime = false;
        }
      }
      // add 5798仮想端末投与時間帯表示を有効にしているが、表示されない薬剤がある zhao end
      if (columnDefinition.field === "endWaitTime") {
        this.inputModel.endWaitTime = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "deviceTimeout") {
        this.inputModel.deviceTimeout = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "treatMoniInterval") {
        this.inputModel.treatMoniInterval = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "otherMoniInterval") {
        this.inputModel.otherMoniInterval = this.getValueByField(
          columnDefinition.field
        );
      }
      // add 楊 start
      if (columnDefinition.field === "treatRealtimeMonitoInterval") {
        this.inputModel.treatRealtimeMonitoInterval = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "otherRealtimeMonitoInterval") {
        this.inputModel.otherRealtimeMonitoInterval = this.getValueByField(
          columnDefinition.field
        );
      }
      // add 楊 end
      if (columnDefinition.field === "patTiming") {
        this.inputModel.patTiming = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.patTiming == 1) {
          this.patTiming = true;
        } else {
          this.patTiming = false;
        }
      }
      if (columnDefinition.field === "isNotice") {
        this.inputModel.isNotice = this.getValueByField(columnDefinition.field);
        if (this.inputModel.isNotice == 1) {
          this.isNotice = true;
          this.isDisableNotice = false;
        } else {
          this.isNotice = false;
          this.isDisableNotice = true;
        }
      }
      if (columnDefinition.field === "noticeTime") {
        this.inputModel.noticeTime = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "logUploadTime") {
        this.inputModel.logUploadTime = this.getTimeFormat(
          this.getValueByField(columnDefinition.field)
        );
      }
      if (columnDefinition.field === "offlineStartTime") {
        this.inputModel.offlineStartTime = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.offlineStartTime !== null) {
          this.isOfflineStartTime = true;
          this.isDisableOfflineStartTime = false;
        } else {
          this.isOfflineStartTime = false;
          this.isDisableOfflineStartTime = true;
        }
      }
      if (columnDefinition.field === "isOfflineAutoEnd") {
        this.inputModel.isOfflineAutoEnd = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.isOfflineAutoEnd == 1) {
          this.isOfflineAutoEnd = true;
        } else {
          this.isOfflineAutoEnd = false;
        }
      }
      // #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 start
      if (columnDefinition.field === "nextPatSplitarea") {
        this.inputModel.isNextPatSplitarea = this.getValueByField(
          columnDefinition.field
        );
        if (this.inputModel.isNextPatSplitarea == 1) {
          this.isNextPatSplitarea = true;
        } else {
          this.isNextPatSplitarea = false;
        }
      }
      // #9147 2023.11.08 add 次患者情報2段組設定の追加 TDC片口 end
      if (columnDefinition.field === "reloadNextPatTime") {
        this.inputModel.reloadNextPatTime = this.getTimeFormat(
          this.getValueByField(columnDefinition.field)
        );
      }
      if (columnDefinition.field === "nextPatMode") {
        this.inputModel.nextPatMode = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "nextPatModeRange") {
        this.inputModel.nextPatModeRange = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "lcdMenu") {
        this.inputModel.lcdMenu = this.getValueByField(columnDefinition.field);
      }
      if (columnDefinition.field === "lcdNpat") {
        this.inputModel.lcdNpat = this.getValueByField(columnDefinition.field);
      }
      if (columnDefinition.field === "lcdReport") {
        this.inputModel.lcdReport = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "lcdGraph1") {
        this.inputModel.lcdGraph1 = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "lcdGraph2") {
        this.inputModel.lcdGraph2 = this.getValueByField(
          columnDefinition.field
        );
      }
      if (columnDefinition.field === "lcdRadar") {
        this.inputModel.lcdRadar = this.getValueByField(columnDefinition.field);
      }
      if (columnDefinition.field === "regDate") {
        this.inputModel.regDate = this.getValueByField(columnDefinition.field);
      }
      if (columnDefinition.field === "upDate") {
        this.inputModel.upDate = this.getValueByField(columnDefinition.field);
      }
    }
  },
};
</script>

<style scoped>
.main {
  overflow: hidden;
  height: 100%;
}
.confbody {
  text-align: left;
  display: table;
  margin: auto;
}
#dgraph {
  border: 1px solid grey;
  width: 70%;
  margin: auto;
}
#show-modal {
  width: 50px;
  height: 20px;
  border-width: 1px;
  border-color: #b8b8b8;
  border-radius: 5px;
  -webkit-border-radius: 5px;
  -moz-border-radius: 5px;
  overflow: hidden;
  outline: none;
  padding: 0.3em;
}
div.serverKey {
  text-align: left;
  width: 100%;
  border-collapse: separate;
  border-spacing: 5px 10px;
  margin: 0px 0px 0px 0px;
  display: block;
}
.table-comsv-setting {
  border-collapse: separate;
  border-spacing: 5px 10px;
  text-align: left;
  display: flex;
  flex-wrap: wrap;
}
tbody.tbody-right {
  display: inline-block;
  width: 400px;
  text-align: left;
}
tbody.tbody-left {
  display: inline-block;
  width: 400px;
  text-align: left;
}
.btn-area {
  position: absolute;
  left: 8px;
  bottom: 3px;
  background-color: #fafafa;
}
.help-area {
  margin: 10px;
}
.help-area label {
  font-size: 1.2em;
}
div.main-content-area-main {
  height: 100%;
}
.label-titile {
  font-size: 1em;
  display: inline;
}
.input-time {
  font-size: 1em;
}
.selectbox >>> .select-input {
  font-size: 1em;
  line-height: inherit;
}
.textbox >>> .text-input {
  font-size: 1em;
  background-color: #ffff99 !important;
}
.textbox >>> .text-input:disabled {
  color: #999;
}
.time-input-edited >>> .text-input,
.time-input-edited >>> .select-input {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
</style>
