/**
 * 治療状況マップ MainContent
 */
<template>
  <!-- 背景画像の設定、周囲余白無し、最大化ボタン、ズームスライダの配置 -->
  <div class="mapcontent" :style="mapContentHeight">
    <!-- <div style="z-index: 10; position: absolute;">
      {{ targetTransFormStyle }}/layoutNo:{{ selectedStatusLayoutNo }}/layoutId:{{ selectedBedLayoutId }}/isTouch:{{ isTouch }}/currentDate:{{ currentDate }}
    </div>-->
    <div id="bedroom" class="bedroom" @touchend="listenerEnd">
      <!-- mod FNSI-No388 font-size 付 start -->
      <div
        id="target"
        :style="targetStyle"
        @mousedown="listenerStart"
        @mouseup="listenerEnd"
        @mousemove="listenerMove"
        @mousewheel="listenerWheel"
        @touchstart="listenerStart"
        @touchend="listenerEnd"
        @touchmove="listenerMove"
        :class="fontSizeSet"
      >
        <template v-for="machineData in machineDataList">
          <StatusMapMachine
            v-if="isTreatStateMode && machineData.isInBedGroup"
            :key="machineData.bedLayout.disp_order_no"
            :machineData="machineData"
          ></StatusMapMachine>
          <ScheduleMapMachine
            v-if="!isTreatStateMode && machineData.isInBedGroup"
            :key="machineData.bedLayout.disp_order_no"
            :machineData="machineData"
          ></ScheduleMapMachine>
        </template>
      </div>
    </div>
    <!-- ズームスライダー -->
    <div class="zoom-slider">
      <span class="zoom-slider-label" @click="zoomIn()">+</span>
      <v-ons-range
        class="zoom-slider"
        style="display: inline-block; width: 10em; transform: rotateY(180deg);"
        v-model="sliderVal"
        :max="300"
        :min="50"
      ></v-ons-range>
      <span class="zoom-slider-label" @click="zoomOut()">-</span>
    </div>
    <!--最大表示ボタン-->
    <div class="display-full auto-event" @click="displayFull" v-show="!this.isDisplayFullMode">
      <img class="img-icon none-event" :src="image_src_full_screen" />
    </div>
    <!--通常表示ボタン-->
    <div class="display-full auto-event" @click="cancelDisplayFull" v-show="this.isDisplayFullMode">
      <img class="img-icon none-event" :src="image_src_normal_screen" />
    </div>
    <!--インフォメーション表示ボタン-->
    <div class="display-info auto-event" @click="showInfoPopover($event)">
      <img class="img-icon none-event" :src="image_src_info_icon" />
    </div>
    <v-ons-popover
      v-if="popoverVisible"
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      animation="none"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <img class="show-info" :src="image_src_info" alt="Infomation Image" />
      <v-ons-button class="ok auto-event btn2-cancel" @click="dialogClose()">閉じる</v-ons-button>
    </v-ons-popover>
  </div>
</template>

<script>
import { mapGetters, mapActions, mapMutations, mapState } from "vuex";
import StatusMapMachine from "@/components/status-map/StatusMapMachineComponent";
import ScheduleMapMachine from "@/components/status-map/schedule/ScheduleMapMachineComponent";
import { EventBus } from "@/eventBus.js";
import moment from "moment";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import PopoverMixin from "@/components/PopoverMixin";
// add FNSI-画面リロードの修正 付 start
import {
  STATUS_AUTO_SETTING,
  STATUS_MAP_FORCE_SIGNOUT,
  STATUS_MAP_TREATMENT_INDICATOR,
  STATUS_MAP_SCHEDULE_INDICATOR
} from "@/constants/facilitySetting";
import { NOTIFY_TOPIC_MACHINE_RESULT } from "@/constants/websocketNotifyTopic";
import {
  sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue,
  sendRequestGetMstFacilitySettingValueMap as getMstFacilitySettingValueMap
} from "@/apis/facility-setting";
// add FNSI-画面リロードの修正 付 end
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import cloneDeep from "lodash/cloneDeep";
import { initForceSignOutFlag } from "@/functions/common/CommonFunctions.js";

const TOUCHSTART = "touchstart";
const TOUCHMOVE = "touchmove";
const TOUCHEND = "touchend";

const MOUSEDOWN = "mousedown";
const MOUSEMOVE = "mousemove";
const MOUSEUP = "mouseup";
const MOUSEOUT = "mouseout";

const MOUSEWHEEL = "mousewheel";

const NOTCH = 0.009;
const SLIDER_MAX = 300;
const SLIDER_MIN = 50;
const SLIDER_STEP = 10;

export default {
  mixins: [PopoverMixin],
  components: {
    StatusMapMachine,
    ScheduleMapMachine
  },
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    ...mapState("status-map/map", ["treatmentStatusList", "treatmentScheduleList"]),
    ...mapGetters("status-map/map", {
      selectedBedLayout: "getSelectedBedLayout",
      selectedStatusLayout: "getSelectedStatusLayout",
      currentDate: "getConditionTreatMapCurrentDate",
      isTreatStateMode: "isTreatStateMode",
      isDisplayFullMode: "isDisplayFullMode",
      getSelectedTreatmentSchedule: "getSelectedTreatmentSchedule",
      getLayoutState: "getLayoutState"
    }),
    ...mapGetters("window-size", {
      getWindowWidth: "getWindowWidth",
      getWindowHeight: "getWindowHeight",
      sidebarWidth: "getSidebarWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    // add FNSI-警報報知修正 付 start
    ...mapGetters("user", ["getFacilityCd"]),
    // add FNSI-警報報知修正 付 end
    // add 機能帳票パラメータ確認 陳 start
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-info", ["searchedPatList","selectedPatId"]),
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // add 機能帳票パラメータ確認 陳 end
    isTouch() {
      return this.mouseListenerInf.touchListArray.length
        ? this.mouseListenerInf.touchListArray.length
        : 0;
    },
    zoomPos() {
      return `zoomPos(${this.mouseListenerInf.zoomPos.x}, ${this.mouseListenerInf.zoomPos.y})`;
    },
    selectedStatusLayoutNo() {
      if (
        this.selectedStatusLayout !== null &&
        this.selectedStatusLayout !== undefined &&
        this.selectedStatusLayout.layoutNo !== undefined
      ) {
        return this.selectedStatusLayout.layoutNo;
      } else {
        return "未設定";
      }
    },
    selectedBedLayoutId() {
      if (
        this.selectedBedLayout !== null &&
        this.selectedBedLayout !== undefined
      ) {
        return this.selectedBedLayout.layoutId;
      } else {
        return "未設定";
      }
    },
    targetTransFormStyle() {
      return `translate(${this.targetTransForm.x}px, ${this.targetTransForm.y}px) scale(${this.targetScale})`;
    },
    targetStyle() {
      return {
        transform: `translate(${this.targetTransForm.x}px, ${this.targetTransForm.y}px) scale(${this.targetScale})`,
        width:
          (this.selectedBedLayout
            ? this.selectedBedLayout.bedLayout.canvas_size.width
            : "0") + "px",
        height:
          (this.selectedBedLayout
            ? this.selectedBedLayout.bedLayout.canvas_size.height
            : "0") + "px",
        backgroundImage: this.selectedBedLayout&&this.selectedBedLayout.backgroundImage
          ? "url(" + this.selectedBedLayout.backgroundImage + ")"
          : "none",
        backgroundSize: (this.selectedBedLayout
            ? this.selectedBedLayout.bedLayout.canvas_size.width
            : "0") + "px " + (this.selectedBedLayout
            ? this.selectedBedLayout.bedLayout.canvas_size.height
            : "0") + "px"
      };
    },
    targetScale() {
      return this.minimumScale + NOTCH * this.sliderVal;
    },
    image_src_info() {
      return this.isTreatStateMode
        ? this.image_src_info_treatmentStatus
        : this.image_src_info_schedule;
    },
    machineDataList() {
      const baseList = this.isTreatStateMode
        ? this.treatmentStatusList
        : this.treatmentScheduleList;
      if (baseList === null) return;

      const additionalProp = this.isTreatStateMode
        ? { indicatorDispTreatment: this.indicatorDispTreatment }
        : { indicatorDispSchedule: this.indicatorDispSchedule };

      // 各要素に施設設定マスタのインジケータ表示設定を追加
      return baseList.map(item => ({
        ...item,
        ...additionalProp
      }));
    },
  },
  data() {
    return {
      isFooterDisp: true,
      sliderVal: SLIDER_MAX * 0.5,
      minimumScale: 0.1,
      sliderWatchOff: false,
      targetTransForm: {
        x: 0,
        y: 0,
        scale: 1.0
      },
      displayAreaElm: null,
      mouseListenerInf: {
        containerElm: null,
        targetElm: null,
        basePoint: {
          x: Number,
          y: Number
        },
        basisTouchID: Number,
        touchListArray: [],
        lastWheelEvent: 0,
        isTouched: false,
        oldDistance: null,
        zoomPos: {
          x: 0,
          y: 0
        }
      },
      target: document.getElementById("target"),
      body: document.body,
      timerId: 0,
      image_src_full_screen: require("../../assets/status-map-full-screen.png"),
      image_src_normal_screen: require("../../assets/status-map-normal-screen.png"),
      image_src_info_icon: require("../../assets/info_icon.png"),
      image_src_info_treatmentStatus: require("../../assets/info_img_treatmentStatus.png"),
      image_src_info_schedule: require("../../assets/info_img_schedule.png"),
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "left",
      mapContentHeight: "height:100%;",
      // 現在の画面名
      selfScreenName: "",
      //ベッド移動用設定
      movingChipElem: null,
      parentElem: null,
      //チップ移動時のスクロール設定
      autoScrollX: 0,
      autoScrollY: 0,
      scrollIntervalId: 0,
      clickEventNowFlag: false,
      // add FNSI-警報報知修正 付 start
      notifyTopic: NOTIFY_TOPIC_MACHINE_RESULT,
      notifyValue: [],
      refreshInterval: 0,
      // add FNSI-警報報知修正 付 end
      // add #11285 機能帳票の印刷情報対応② 高 start
      bedCdListString: "",
      // add #11285 機能帳票の印刷情報対応② 高 end
      indicatorDispTreatment: [],
      indicatorDispSchedule: [],
    };
  },
  methods: {
    ...mapActions("status-map/map", {
      setColItemGroupList: "setColItemGroupList",
      reFetchTreatmentStatus: "reFetchTreatmentStatus",
      setDisplayFullMode: "setDisplayFullMode",
      setFilterSignal: "setFilterSignal",
      setLayoutState: "setLayoutState"
    }),
    ...mapActions("window-size", ["setSize"]),
    ...mapActions("account-edit", [
      "setDispMenuBar",
      "setIsDispFloatMenu",
      "setIsDispSidebarBtn"
    ]),
    // add FNSI-画面リロードの修正 付 start
    ...mapActions("websocket", ["addWatchTopics", "removeWatchTopics", "dequeueMessage"]),
    // add FNSI-画面リロードの修正 付 end
    // ベッドレイアウト表示領域の高さ調整

    ...mapMutations("external-coop", ["setCloudInfo"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    calculateHeight() {
      this.$nextTick(() => {
        const wh = this.getWindowHeight;
        const hh = Array.prototype.slice
          .call(document.getElementsByClassName("header"))
          .shift().clientHeight;
        const fmh =
          (this.isDispMenu === 1
            ? document.getElementById("footer-menu").clientHeight
            : 0) + 5;
        const height = wh - hh - fmh;
        //
        //this.setSize( this.getWindowWidth, height );
        // console.log(
        //   "caluHeight clientH:" +
        //     wh +
        //     " / headerH:" +
        //     hh +
        //     " / footerH:" +
        //     fmh +
        //     " / contentH:" +
        //     height
        // );
        this.mapContentHeight = "height:" + height + "px;";
      });
    },
    // 全画面表示
    displayFull(e) {
      e.preventDefault();

      // ヘッダ非表示
      this.setDisplayFullMode();

      // フッターの表示設定取得
      this.isFooterDisp = this.isDispMenu === 1 ? true : false;

      // フッター非表示
      if (this.isFooterDisp === true) {
        this.setDispMenuBar(0);
      }
      // 画面高さ再計算
      this.calculateHeight();

      // フロートメニュー非表示
      this.setIsDispFloatMenu(false);
      // サイドメニューを閉じる
      EventBus.$emit("forceCloseSideBar");
      // サイドメニュー展開ボタン非表示
      this.setIsDispSidebarBtn(false);
    },
    // 全画面表示解除
    cancelDisplayFull(e) {
      e.preventDefault();

      // ヘッダ表示
      this.setDisplayFullMode();

      // サイドメニュー展開ボタン表示
      this.setIsDispSidebarBtn(true);
      // フロートメニュー表示
      this.setIsDispFloatMenu(true);

      // フッター表示
      if (this.isFooterDisp === true) {
        this.setDispMenuBar(1);
      }

      // 画面高さ再計算
      this.calculateHeight();
    },
    // ベッドレイアウト表示位置調整
    adjustBedLayourtAreaPosition() {
      const displayArea = document
        .getElementById("bedroom")
        .getBoundingClientRect();
      const targetArea = document
        .getElementById("target")
        .getBoundingClientRect();
      const areaX = displayArea.width / 2;
      const areaY = displayArea.height / 2;

      // 表示位置調整
      let posX = this.targetTransForm.x;
      let posY = this.targetTransForm.y;
      const posX2 = posX + targetArea.width;
      const posY2 = posY + targetArea.height;
      if (areaX < posX) {
        posX = areaX;
      }
      if (areaY < posY) {
        posY = areaY;
      }
      if (posX2 < areaX) {
        posX += areaX - posX2;
      }
      if (posY2 < areaY) {
        posY += areaY - posY2;
      }

      this.targetTransForm.x = posX;
      this.targetTransForm.y = posY;
    },
    listenerStart(event) {
      // console.log("listenerStart/event.type is %o.", event.type);
      // event.preventDefault();
      switch (event.type) {
        case TOUCHSTART:
          for (let i = 0; i < event.changedTouches.length; i++) {
            const touch = {
              x: event.changedTouches[i].pageX,
              y: event.changedTouches[i].pageY,
              identifier: event.changedTouches[i].identifier
            };
            this.mouseListenerInf.touchListArray.push(touch);
          }
          // 初回タッチのとき
          // 開始点の取得
          if (event.changedTouches.length === 1) {
            // タッチ座標を取得し、開始点とする
            this.mouseListenerInf.basePoint.x = event.touches[0].pageX;
            this.mouseListenerInf.basePoint.y = event.touches[0].pageY;

            // 基準点タッチIDを登録
            this.mouseListenerInf.basisTouchID = event.touches[0].identifier;

            // タッチ状態に変更
            this.mouseListenerInf.isTouched = true;
          } else if (event.changedTouches.length > 1) {
            const newP1 = {
              x: event.changedTouches[0].pageX,
              y: event.changedTouches[0].pageY
            };
            const newP2 = {
              x: event.changedTouches[1].pageX,
              y: event.changedTouches[1].pageY
            };
            this.mouseListenerInf.oldDistance = this.getDistance(newP1, newP2);
          }
          this.mouseListenerInf.zoomPos = null;
          break;

        case MOUSEDOWN:
          // console.log("listenerStart/mouse down.");
          // 開始点の取得
          this.mouseListenerInf.basePoint.x = event.pageX;
          this.mouseListenerInf.basePoint.y = event.pageY;

          // マウスのボタンが押されている状態に変更
          this.mouseListenerInf.isTouched = true;
          break;

        default:
          break;
      }
    },
    listenerEnd(event) {
      if (this.mouseListenerInf.isTouched) {
        // event.preventDefault();

        // console.log("listenerEnd/event.type is %o.", event.type);
        // タッチイベントのとき
        switch (event.type) {
          case TOUCHEND: {
            for (let i = 0; i < event.touches.length; i++) {
              this.mouseListenerInf.touchListArray = this.mouseListenerInf.touchListArray.filter(
                x => x.identifier !== event.changedTouches[i].identifier
              );
            }
            // 他のタッチが存在する場合
            if (event.touches.length > 0) {
              // 基準となるタッチが離れた場合
              if (
                event.changedTouches[0].identifier ===
                this.mouseListenerInf.basisTouchID
              ) {
                // 基準となるタッチの更新
                this.mouseListenerInf.basisTouchID =
                  event.touches[0].identifier;
              }
            } else if (event.touches.length === 0) {
              // タッチ状態を解除
              this.mouseListenerInf.isTouched = false;
            }
            this.mouseListenerInf.oldDistance = 0;
            this.mouseListenerInf.zoomPos = null;
            break;
          }
          case MOUSEUP:
          case MOUSEOUT: {
            // タッチ状態を解除
            this.mouseListenerInf.isTouched = false;
            break;
          }

          default:
            break;
        }
      }
    },
    listenerWheel(event) {
      const nowTime = new Date().getTime();
      if (event.type === MOUSEWHEEL) {
        if (nowTime - this.mouseListenerInf.lastWheelEvent > 12) {
          // 前回から100ミリ秒以上経過している場合にズーム処理
          this.mouseListenerInf.lastWheelEvent = nowTime;
          // ホイール量取得
          const dy = event.deltaY;
          // 拡大率
          const scale = this.targetScale + -0.00025 * dy;
          if (scale > 0) {
            // ズームする場所(ターゲット要素内座標)
            // mod FNSI-横展開対応 付 start
            // const zoomPosX = event.offsetX + event.toElement.offsetLeft;
            // const zoomPosY = event.offsetY + event.toElement.offsetTop;
            const zoomPosX = event.offsetX + event.target.offsetLeft;
            const zoomPosY = event.offsetY + event.target.offsetTop;
            // ターゲットのイベント要素内での座標
            // const targetPosX = event.layerX + event.toElement.offsetLeft;
            // const targetPosY = event.layerY + event.toElement.offsetTop;
            const targetPosX = event.layerX + event.target.offsetLeft;
            const targetPosY = event.layerY + event.target.offsetTop;
            // mod FNSI-横展開対応 付 end
            this.targetZoom(
              scale,
              {
                x: zoomPosX,
                y: zoomPosY
              },
              {
                x: targetPosX,
                y: targetPosY
              }
            );
          }
        }
      }
    },
    listenerMove(event) {
      if (this.mouseListenerInf.isTouched) {
        event.preventDefault();
        switch (event.type) {
          case TOUCHMOVE: {
            if (event.touches.length === 1) {
              const p1 = {
                x: event.touches[0].pageX,
                y: event.touches[0].pageY
              };
              this.targetMove(p1);
            } else if (event.touches.length > 1) {
              const newP1 = {
                x: event.touches[0].pageX,
                y: event.touches[0].pageY
              };
              const newP2 = {
                x: event.touches[1].pageX,
                y: event.touches[1].pageY
              };
              const newDistance = this.getDistance(newP1, newP2);
              if (this.mouseListenerInf.oldDistance === 0) {
                this.mouseListenerInf.oldDistance = newDistance;
              }
              // 拡大率
              const scale =
                this.targetScale +
                (newDistance / this.mouseListenerInf.oldDistance - 1);
              if (scale > 0) {
                // ズームする場所(ターゲット要素内座標)
                const zoomPosX = Math.floor((newP1.x + newP2.x) / 2);
                const zoomPosY = Math.floor((newP1.y + newP2.y) / 2);
                const displayArea = document
                  .getElementById("bedroom")
                  .getBoundingClientRect();

                if (this.mouseListenerInf.zoomPos === null) {
                  this.mouseListenerInf.zoomPos = {
                    x:
                      (zoomPosX - (displayArea.left + this.targetTransForm.x)) /
                      this.targetScale,
                    y:
                      (zoomPosY - (displayArea.top + this.targetTransForm.y)) /
                      this.targetScale
                  };
                }
                this.targetZoom(
                  scale,
                  {
                    x: this.mouseListenerInf.zoomPos.x,
                    y: this.mouseListenerInf.zoomPos.y
                  },
                  {
                    x: zoomPosX - displayArea.left,
                    y: zoomPosY - displayArea.top
                  }
                );
              }
              this.mouseListenerInf.oldDistance = newDistance;
            }
            break;
          }

          case MOUSEMOVE: {
            if (event.buttons === 0) {
              // タッチ状態を解除
              this.mouseListenerInf.isTouched = false;
            } else {
              const p1 = {
                x: event.pageX,
                y: event.pageY
              };
              this.targetMove(p1);
            }
            break;
          }

          default:
            break;
        }
      }
      //ツールチップ移動
      if (null === this.movingChipElem) {
        //移動チップまたは移動ブロックがいないので処理しない
        return;
      }
      if (this.clickEventNowFlag) {
        //クリックイベント処理中は処理しない
        return;
      }
      //移動対象を確認&設定
      const targetElem = this.movingChipElem;

      //チップの移動
      targetElem.style.top = `${event.clientY - 100}px`;
      targetElem.style.left = `${event.clientX - this.sidebarWidth}px`;

      //スクロール判定
      const areaElem = document.getElementById("target");
      const areaRect = areaElem.getBoundingClientRect();

      const posX = event.clientX - areaRect.left;
      const posY = event.clientY - areaRect.top;

      //左右の判定
      const scrollWidth = 10;
      const scrollHeight = 10;

      this.autoScrollX = 0;
      this.autoScrollY = 0;

      const defaultVal = 5;

      //左右の判定
      if (posX >= 0 && 0 + scrollWidth >= posX) {
        //左スクロール
        this.autoScrollX = -defaultVal;
      } else if (
        posX <= areaRect.width &&
        0 + (areaRect.width - scrollWidth) <= posX
      ) {
        //右スクロール
        this.autoScrollX = defaultVal;
      }
      //上下の判定
      if (posY >= 0 && 0 + scrollHeight >= posY) {
        //上スクロール
        this.autoScrollY = -defaultVal;
      } else if (
        posY <= areaRect.height &&
        0 + (areaRect.height - scrollHeight) <= posY
      ) {
        //下スクロール
        this.autoScrollY = defaultVal;
      }

      //スクロールの繰り返し処理
      clearInterval(this.scrollIntervalId);

      if (!(this.autoScrollX === 0 && this.autoScrollY === 0)) {
        this.scrollIntervalId = setInterval(
          function() {
            const areaElem = document.getElementById("target");
            areaElem.scrollTop += this.autoScrollY;
            areaElem.scrollLeft += this.autoScrollX;
            this.autoScrollY *= 1.3;
            if (this.autoScrollY > 20) this.autoScrollY = 20;
            this.autoScrollX *= 1.3;
            if (this.autoScrollX > 20) this.autoScrollX = 20;
          }.bind(this),
          100
        );
      }
    },
    createChip(e) {
      //クリックしたセルのIDを取得
      const nowId = e.target.id;
      if (!(0 === nowId.indexOf("machine"))) {
        //idで判定。ベッドセル以外は非移動対象、何もしない
        return;
      }
      let dimIndex = nowId.replace("machine", "").split("-");
      //識別名称の格納
      this.moveFromInfo = "machine";
      //インデックス情報の格納
      this.moveFromIndex = dimIndex;

      const machineInfo = this.treatmentScheduleList.find(
        s => s.bedLayout.machine_no == Number(dimIndex[1])
      );
      // mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc start
      // if (!machineInfo.treatment || !machineInfo.isClickable) {
      if (!machineInfo.treatment || !!machineInfo.treatment && !machineInfo.treatment.ordNo || !machineInfo.isClickable) {
      // mod #10649 治療状況マップのスケジュール表示にてスケジュール割り当てができない【マニュアル検証指摘】20240618 ztc end
        return;
      }
      if (!this.isTreatStateMode) {
        e.target.classList.add("selected-map-style");
      }
      //チップの作成(クローン)
      this.movingChipElem = e.target.cloneNode(true);
      const rect = e.target.getBoundingClientRect();

      this.movingChipElem.style.width = `${parseInt(rect.width)}px`;
      this.movingChipElem.style.height = `${parseInt(rect.height)}px`;

      //クラス設定
      this.movingChipElem?.classList?.add("cls_move_chip");

      //id設定
      this.movingChipElem.id = `id_chip_${nowId}`;

      //親要素に追加
      //ベッド移動処理の初期化(親要素の取得)
      this.parentElem = document.getElementById("bedroom");
      this.parentElem.appendChild(this.movingChipElem);

      this.movingChipElem.style.top = `${parseInt(rect.top) - 100}px`;
      this.movingChipElem.style.left = `${parseInt(rect.left) -
        this.sidebarWidth}px`;
    },
    showChip(event) {
      //ツールチップ表示
      this.clickEventNowFlag = true;
      if (null === this.movingChipElem) {
        // ポーリング停止
        this.endPolling();
        this.createChip(event);
        this.clickEventNowFlag = false;
      } else {
        this.movingChipElem.style.display = "none";
        const underElem = document.elementFromPoint(
          event.clientX,
          event.clientY
        );

        //チップをだす
        this.movingChipElem.style.display = "inline";
        //下のセルのチェック
        const nowId = underElem.id;
        const parent = underElem.parentNode.id;

        if (
          !(0 === nowId.indexOf("machine")) &&
          !(0 === parent.indexOf("machine"))
        ) {
          //非移動対象の場合(idがid_bedで始まらない(つまりベッドセル以外の)セルな)ので)、何もしない
          this.clickEventNowFlag = false;
          return;
        }
        let dimIndex = 0;
        if (0 === nowId.indexOf("machine")) {
          dimIndex = nowId.replace("machine", "").split("-");
        }
        if (0 === parent.indexOf("machine")) {
          dimIndex = parent.replace("machine", "").split("-");
        }
        const machineInfo = this.treatmentScheduleList.find(
          s => s.bedLayout.machine_no == Number(dimIndex[1])
        );
        if (!machineInfo.isClickable) {
          this.clickEventNowFlag = false;
          return;
        }
        //チップを削除
        this.movingChipElem.parentNode.removeChild(this.movingChipElem);
        //もう移動が終わったのでポインタを初期化
        this.movingChipElem = null;
        this.clickEventNowFlag = false;
        document.getElementsByClassName("selected-map-style")[0].classList.remove("selected-map-style");
        // ポーリング再開
        this.startPolling();
      }
    },
    removeShowChip(isBeforeDestroy) {
      //ツールチップ表示
      this.clickEventNowFlag = true;
      if (null !== this.movingChipElem) {
        this.movingChipElem.style.display = "none";
        //チップをだす
        this.movingChipElem.style.display = "inline";
        //チップを削除
        this.movingChipElem.parentNode.removeChild(this.movingChipElem);
        //もう移動が終わったのでポインタを初期化
        this.movingChipElem = null;
        if (document.getElementsByClassName("selected-map-style")[0]) {
          document.getElementsByClassName("selected-map-style")[0].classList.remove("selected-map-style");
        }
        if (!isBeforeDestroy) {
          // ポーリング再開
          this.startPolling();
        }
      }
      this.clickEventNowFlag = false;
    },
    /**
     * 拡大率変更
     * @param scale 拡大率
     * @param zoomPos ズームする場所（ターゲット要素内座標）
     * @param targetPos ターゲット要素の座標
     */
    targetZoom(scale, zoomPos, targetPos) {
      // console.log("targetZoom");
      const moveScale = scale - this.minimumScale;
      if (moveScale > 0) {
        if (SLIDER_MAX < Math.ceil(moveScale / NOTCH)) {
          this.sliderVal = SLIDER_MAX;
        } else if (SLIDER_MIN > Math.ceil(moveScale / NOTCH)) {
          this.sliderVal = SLIDER_MIN;
        } else {
          this.sliderVal = Math.ceil(moveScale / NOTCH);
          // console.log(
          //   "targetZoom/%f = Math.ceil(%f / %d)",
          //   this.sliderVal,
          //   moveScale,
          //   NOTCH
          // );
        }
      } else {
        this.sliderVal = 0;
      }
      this.targetTransForm.x = targetPos.x - this.targetScale * zoomPos.x;
      this.targetTransForm.y = targetPos.y - this.targetScale * zoomPos.y;
      this.sliderWatchOff = true;

      // Zoom後の表示位置調整
      this.adjustBedLayourtAreaPosition();
    },
    /**
     * ターゲット要素を動かす。
     * @param newMousePos マウス位置
     */
    targetMove(newMousePos) {
      const newPos = {
        x:
          this.targetTransForm.x +
          (newMousePos.x - this.mouseListenerInf.basePoint.x),
        y:
          this.targetTransForm.y +
          (newMousePos.y - this.mouseListenerInf.basePoint.y)
      };
      // X軸方向への動き
      const canvasWidth =
        this.selectedBedLayout.bedLayout.canvas_size.width * this.targetScale;
      const displayArea = document
        .getElementById("bedroom")
        .getBoundingClientRect();
      this.targetTransForm.x = this.getTransform(
        canvasWidth,
        displayArea.width,
        newPos.x,
        this.targetTransForm.x
      );
      this.mouseListenerInf.basePoint.x = newMousePos.x;

      // y軸方向への動き
      const canvasHeight =
        this.selectedBedLayout.bedLayout.canvas_size.height * this.targetScale;
      this.targetTransForm.y = this.getTransform(
        canvasHeight,
        displayArea.height,
        newPos.y,
        this.targetTransForm.y
      );
      this.mouseListenerInf.basePoint.y = newMousePos.y;
    },
    getTransform(canvasLength, displayAreaLength, newPosition, oldPosition) {
      const moveArea = displayAreaLength;
      //  表示開始位置判定
      if (moveArea < newPosition) {
        return oldPosition;
      }
      //  最終端右位置判定
      if (newPosition > moveArea * 0.99) {
        return oldPosition;
      }
      //  最終端左位置判定
      if (newPosition < -(canvasLength * 0.99)) {
        return oldPosition;
      }
      return newPosition;
    },
    /**
     * 線の衝突判定
     */
    isLineInner(line1, line2) {
      const dist = Math.abs(
        line1.pos * 2 + line1.length - (line2.pos * 2 + line2.length)
      );
      const sumLen = line1.length + line2.length;
      return dist < sumLen;
    },
    /**
     * 一点の範囲内判定
     */
    isRectInner(point, x1, x2, y1, y2) {
      return point.x >= x1 && point.x <= x2 && point.y >= y1 && point.y <= y2;
    },

    /**
     * 二点間距離の計算
     */
    getDistance(p1, p2) {
      return Math.sqrt((p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2);
    },
    /**
     * 指定したidentifierのタッチ開始時の座標を返す
     */
    getInitialXYById(touchId) {
      const bufArray = this.mouseListenerInf.touchListArray.filter(
        x => x.identifier === touchId
      );
      const rtn = {
        x: bufArray[0].x,
        y: bufArray[0].y
      };
      return rtn;
    },
    async refreshVal(parama) {
      let data = await getMstFacilitySettingValue(this.getFacilityCd, STATUS_AUTO_SETTING);
      if (data.status == 200) {
        if (data.data) {
          this.refreshInterval = data.data * 1000;
        } else {
          this.refreshInterval = 20000;
        }
      } else if (data.status == 400) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('StatusMapMainComponent.vue','startPolling',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.refreshInterval = 20000;
      }
      /* 自動更新サインアウトフラグ取得 */
      await initForceSignOutFlag("status-map/map/setForceSignOutFlag", STATUS_MAP_FORCE_SIGNOUT);
      if (parama != undefined) {
        parama();
      }
    },
    startPolling() {
      this.endPolling();
      /* modify by chamaojia 2022-11-26 [6746] タイミングリフレッシュにloadingは必要ありません  --start */
      this.timerId = setInterval(this.autoRefreshMap, this.refreshInterval);
      /* modify by chamaojia 2022-11-26 [6746] タイミングリフレッシュにloadingは必要ありません  --end */
    },
    async autoRefreshMap(){
      // Intervalのクリア
      this.endPolling();
      await this.reFetchTreatmentStatus(true);
      EventBus.$emit("alarmSettingLoad", true);
      // Intervalを再開
      this.startPolling();
    },
    endPolling() {
      clearInterval(this.timerId);
    },
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name) {
        // ポーリング停止
        this.endPolling();
        // インジケータ表示設定取得
        this.getindicatorDispValues();
        // 治療状況再取得
        this.reFetchTreatmentStatus();
        // ポーリング再開
        this.startPolling();
      }
    },
    showInfoPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    dialogClose() {
      this.popoverVisible = false;
    },
    requestrReportParams(param) {
      // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
      let treatmentStatusListTemp = null
      if (this.isTreatStateMode) {
        // const treatmentStatusListTemp = cloneDeep(this.treatmentStatusList);
        treatmentStatusListTemp = cloneDeep(this.treatmentStatusList);
      }else {
        treatmentStatusListTemp = cloneDeep(this.treatmentScheduleList);
      }
      // mod #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {

        // add #11285 機能帳票の印刷情報対応② 高 start
        var expressCondCd="";
        if (null != this.getStorSimlpSearchQurey.rstDialysisState && this.getStorSimlpSearchQurey.rstDialysisState.length > 0) {
          if (this.getStorSimlpSearchQurey.rstDialysisState.length == 2) {
            expressCondCd = "予定・実績";
          } else {
            if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
              expressCondCd = "予定";
            } else {
              expressCondCd = "実績";
            }
          }
        }
        let kurNames = null;
        // del #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
        // if(this.getStorSimlpSearchQurey.kurNames && this.getStorSimlpSearchQurey.kurNames.length > 0) {
        //   kurNames = this.getStorSimlpSearchQurey.kurNames.join("・");
        // } else {
        //   kurNames = "すべて";
        // }
        // del #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        // eslint-disable-next-line vue/no-side-effects-in-computed-properties
        this.bedCdListString = JSON.parse(sessionStorage.getItem('roomBedGroupNameStatusMap')) || [];
        // add #11285 機能帳票の印刷情報対応② 高 end
        // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
        kurNames = JSON.parse(sessionStorage.getItem('kurGroupNameStatusList'));
        // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        // 機能一致
        //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
        // var patIds = treatmentStatusListTemp.map( item => {
        //   if(item.treatment != undefined){
        //     if(item.treatment.patId != null){
        //       return item.treatment.patId
        //     }
        //   }
        // });
        // patIds=patIds.filter(res=>{return res!=undefined})
        // add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
        var patIds = treatmentStatusListTemp.map( item => {
          if(item.treatment != undefined){
            if(item.treatment.patId != null){
              return item.treatment.patId
            }
          }
        });
        patIds=patIds.filter(res=>{return res!=undefined})
        // add #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start

        var orderON = treatmentStatusListTemp.map( item => {
          if(item.treatment != undefined){
            if(item.treatment.ordNo != null){
              return item.treatment.ordNo
            }
          }
        });
        orderON=orderON.filter(res=>{return res!=undefined})

        var machineNos = treatmentStatusListTemp.map( item => {
          if(item.treatment != undefined){
            if(item.treatment.machineNo != null){
              return item.treatment.machineNo
            }
          }
        });
        machineNos=machineNos.filter(res=>{return res!=undefined})
        //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
        // 印刷パラメータを応答
        const param1 = {
          // add 機能帳票パラメータ確認 陳 start
          // del #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
          // patId: this.selectedPatId,
          // del #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
          patIds: patIds,
          // patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          ordNos:orderON,
          // add 機能帳票パラメータ確認 陳 end
          facilityCd: this.getFacilityCd,
          date: moment(this.currentDate).format("YYYY/MM/DD"),
          fromDate: moment(this.currentDate).format("YYYY/MM/DD"),
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"01201",
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          //add FNSI redmine 5984 劉祥霖 start
          machineNos: machineNos,
          //add FNSI redmine 5984 劉祥霖 end
          toDate: moment(this.currentDate).format("YYYY/MM/DD"),
          // add #11285 機能帳票の印刷情報対応② 高 start
          treatDate:this.getStorSimlpSearchQurey.treatDate,
          bedCdListString:this.bedCdListString,
          freeWord:this.getStorSimlpSearchQurey.freeWord,
          expressCondCdStr:expressCondCd,
          kurNames:kurNames,
          patGroups:patGroups,
          // add #11285 機能帳票の印刷情報対応② 高 end
        };
        EventBus.$emit("sendReportParams", param1);
      }
    },
    zoomIn() {
      if (+this.sliderVal === SLIDER_MAX) {
        return;
      }
      this.sliderVal =
        +this.sliderVal >= SLIDER_MAX - SLIDER_STEP
          ? SLIDER_MAX
          : +this.sliderVal + SLIDER_STEP;
    },
    zoomOut() {
      if (+this.sliderVal === SLIDER_MIN) {
        return;
      }
      this.sliderVal =
        +this.sliderVal <= SLIDER_MIN + SLIDER_STEP
          ? SLIDER_MIN
          : +this.sliderVal - SLIDER_STEP;
    },
    /**
     * インジケータ表示設定の取得
     */
    async getindicatorDispValues() {
      const settingNos = [
        STATUS_MAP_TREATMENT_INDICATOR,
        STATUS_MAP_SCHEDULE_INDICATOR,
      ];
      await getMstFacilitySettingValueMap(this.getFacilityCd, settingNos)
       .then((response) => {
          this.indicatorDispTreatment = response.data[STATUS_MAP_TREATMENT_INDICATOR] ? eval(response.data[STATUS_MAP_TREATMENT_INDICATOR]) : [];
          this.indicatorDispSchedule = response.data[STATUS_MAP_SCHEDULE_INDICATOR] ? eval(response.data[STATUS_MAP_SCHEDULE_INDICATOR]) : [];
        })
        .catch((error) => {
          getErrorMessage(
            "StatusMapMainComponent.vue",
            "getindicatorDispValues",
            error
          );
        });
    },
    /** 画面印刷時の処理 */
    handleBeforePrint() {
      // レイアウト位置を左上端固定にする
      const el = document.querySelector('#target');
      if (el) {
        this.originalTransform = el.style.transform;
        el.style.transform = el.style.transform.replace(/translate\([^)]*\)\s*/g, '');
      }
    },
    handleAfterPrint() {
      // レイアウト位置を元に戻す
      const el = document.querySelector('#target');
      if (el) {
        el.style.transform = this.originalTransform ?? '';
        this.originalTransform = null;
      }
    },
  },
  watch: {
    getWindowHeight() {
      // 画面高さ再計算
      this.calculateHeight();
    },
    isTreatStateMode() {
      // 画面切り替えを監視
      this.reFetchTreatmentStatus();
    },
    selectedBedLayout() {
      this.sliderWatchOff = true;
      if (this.getLayoutState.sliderVal === 0) {
        // サインイン後の初回表示時 or 抽出条件のベッドレイアウト変更時
        this.sliderVal = SLIDER_MAX / 2;
        this.$nextTick(() => {
          this.targetTransForm.x = 0;
          this.targetTransForm.y = 0;
        });
      } else {
        // 機能遷移後の表示時
        // 先に実行されるmountedでストアの値は復元済のため、ストアに記憶しているsliderValをクリア
        this.setLayoutState({
          sliderVal: 0
        });
      }
    },
    /**
     * スライダー変更時の拡大縮小処理
     */
    targetScale(newScale, oldScale) {
      if (false === this.sliderWatchOff) {
        const displayArea = document
          .getElementById("bedroom")
          .getBoundingClientRect();
        const bedRoomCenter = {
          x: displayArea.width / 2,
          y: displayArea.height / 2
        };
        const canvas = this.selectedBedLayout.bedLayout.canvas_size;

        // 拡大縮小の中心を取得
        const getZoomCenter = (roomCenter, transForm, canvasSize, scale) => {
          if (roomCenter > transForm + canvasSize * scale) {
            // 拡大対象の正方向端が表示領域中心に達しない
            return canvasSize;
          } else if (roomCenter < transForm) {
            // 拡大対象の負方向端が表示領域中心を通り過ぎている
            return 0;
          } else {
            // 拡大対象の内側に表示領域中心が存在する
            return (roomCenter - transForm) / scale;
          }
        };

        const zoomCenter = {
          x: getZoomCenter(
            bedRoomCenter.x,
            this.targetTransForm.x,
            canvas.width,
            oldScale
          ),
          y: getZoomCenter(
            bedRoomCenter.y,
            this.targetTransForm.y,
            canvas.height,
            oldScale
          )
        };
        // const zoomCenter = {
        //   x: (bedRoomCenter.x - this.targetTransForm.x) / oldScale,
        //   y: (bedRoomCenter.y - this.targetTransForm.y) / oldScale
        // };

        this.targetTransForm.x += zoomCenter.x * (oldScale - newScale);
        this.targetTransForm.y += zoomCenter.y * (oldScale - newScale);
      } else {
        this.sliderWatchOff = false;
      }
      // Zoom後の表示位置調整
      this.adjustBedLayourtAreaPosition();
    },
    // add FNSI-警報報知修正 付 start
    /**
     * WebSocket通知監視
     */
    "notifyValue.length"(newValue) {
      if (newValue > 0) {
        this.dequeueMessage(this.notifyTopic).then(value => {
          let statusOrdNo = value.split(",");
          this.treatmentStatusList.forEach( e => {
          if (e != undefined && e.treatment != undefined && e.treatment.ordNo != undefined) {
            if (e != null && e.treatment != null && e.treatment.ordNo != null) {
              if (e.treatment.ordNo == statusOrdNo[1]) {
                if (e.treatment.machineStatus != undefined) {
                  e.treatment.machineStatus = statusOrdNo[0];
                  }
                }
              }
            }
          });
        });
      }
    }
    // add FNSI-警報報知修正 付 end
  },
  beforeCreate() {},
  created() {
    // add 性能改善メモリ不足 shan start
    EventBus.$off("dataUpdate", this.reFetchTreatmentStatus);
    EventBus.$off("stopMapPolling", this.endPolling);
    EventBus.$off("startMapPolling", this.startPolling);
    EventBus.$off("showNotAssignedScheduleModal", this.endPolling);
    EventBus.$off("hideNotAssignedScheduleModal", this.startPolling);
    EventBus.$off("showScheduleAssignmentModal", this.endPolling);
    EventBus.$off("hideScheduleAssignmentModal", this.startPolling);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("showChip", this.showChip);
    EventBus.$off("removeShowChip", this.removeShowChip);
    // add 性能改善メモリ不足 shan end
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // ？？？？患者割り付け後イベントセット
    EventBus.$on("dataUpdate", this.reFetchTreatmentStatus);
    EventBus.$on("stopMapPolling", this.endPolling);
    EventBus.$on("startMapPolling", this.startPolling);
    EventBus.$on("showNotAssignedScheduleModal", this.endPolling);
    EventBus.$on("hideNotAssignedScheduleModal", this.startPolling);
    EventBus.$on("showScheduleAssignmentModal", this.endPolling);
    EventBus.$on("hideScheduleAssignmentModal", this.startPolling);
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("showChip", this.showChip);
    EventBus.$on("removeShowChip", this.removeShowChip);
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);

    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;

    // add FNSI-警報報知修正 付 start
    this.$nextTick(() => {
      this.notifyTopic = `${NOTIFY_TOPIC_MACHINE_RESULT}/${this.getFacilityCd}`;
      this.addWatchTopics({
        topic: this.notifyTopic,
        obj: this.notifyValue
      });
    });
    // add FNSI-警報報知修正 付 end
  },
  beforeMount() {},
  mounted() {
    // インジケータ表示設定取得
    this.getindicatorDispValues();

    // ポーリング開始
    // mod FNSI-redmine#3941 付 start
    this.refreshVal(this.startPolling);
    // mod FNSI-redmine#3941 付 end

    // ストアに退避してあるレイアウトの状態を復元
    if (this.getLayoutState.sliderVal !== 0) {
      this.sliderVal = this.getLayoutState.sliderVal;
      this.$nextTick(() => {
        this.targetTransForm.x = this.getLayoutState.targetTransForm.x;
        this.targetTransForm.y = this.getLayoutState.targetTransForm.y;
      });
    }
    
    window.addEventListener("beforeprint", this.handleBeforePrint);
    window.addEventListener("afterprint", this.handleAfterPrint);
  },
  beforeUpdate() {},
  updated() {},
  beforeDestroy() {
    // add FNSI-画面リロードの修正 徐 start
    this.removeWatchTopics(this.notifyTopic);
    // add FNSI-画面リロードの修正 徐 end
    // 選択解除＋画面更新
    this.setFilterSignal(true);
    this.removeShowChip(true);
    // ？？？？患者割り付け後イベント削除
    EventBus.$off("dataUpdate", this.reFetchTreatmentStatus);
    EventBus.$off("stopMapPolling", this.endPolling);
    EventBus.$off("startMapPolling", this.startPolling);
    EventBus.$off("showNotAssignedScheduleModal", this.endPolling);
    EventBus.$off("hideNotAssignedScheduleModal", this.startPolling);
    EventBus.$off("showScheduleAssignmentModal", this.endPolling);
    EventBus.$off("hideScheduleAssignmentModal", this.startPolling);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("showChip", this.showChip);
    EventBus.$off("removeShowChip", this.removeShowChip);
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);
    
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);

    // ポーリングクリア
    this.endPolling();

    // レイアウトの状態をストアに退避
    this.setLayoutState({
      targetTransForm: {
        x: this.targetTransForm.x,
        y: this.targetTransForm.y
      },
      sliderVal: this.sliderVal
    });

    // dataの初期化
    Object.assign(this.$data, this.$options.data());

    clearInterval(this.scrollIntervalId);
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.mapcontent {
  /* background-color: #f99f; */
  width: 100%;
  height: 100%;
  position: absolute;
}
.bedroom {
  background-repeat: no-repeat;
  /* background-position: center; */
  background-size: contain;
  width: auto;
  height: auto;
  position: absolute;
  display: block;
  top: 0px;
  right: 0px;
  bottom: 0px;
  left: 0px;
  margin: 0.5rem;
  /* add FNSI-387 付 start */
  word-break: break-all;
  /* add FNSI-387 付 end */
}
#under {
  position: absolute;
  z-index: 1;
  width: 100%;
  height: 100%;
}
#target {
  position: relative;
  display: flex;
  flex-wrap: wrap;
  transform-origin: left top 0;
  background-size: 100%;
  background-repeat: no-repeat;
  background-position: center;
  background-color: #99f5;
}
.display-full {
  position: absolute;
  top: 0.5em;
  right: 1em;
  background-color: #eeef;
}
.display-info {
  position: absolute;
  top: 2.8em;
  right: 1em;
  background-color: #eeef;
}
/*mod FNSI-画面部品デザイン じょはく start*/
div.zoom-slider {
  position: absolute;
  bottom: -1em;
  right: 0.2em;
  /*background-color: #fff4;*/
  background-color: #e4d8d8;
  display: flex;
  align-items: center;
  font-size: 3em;
  transform: rotate(90deg);
  transform-origin: right top;
  padding: 0em 0.3em 0em 0.3em;
  opacity: 0.2;
}
/*mod FNSI-画面部品デザイン じょはく end*/
.zoom-slider:active {
  opacity: 1;
}
@media screen and (orientation: landscape) and (max-height: 440px) {
  div.zoom-slider {
    font-size: 1em;
  }
}
span.zoom-slider-label {
  transform: rotate(-90deg);
}
img.img-icon {
  display: block;
  cursor: pointer;
  height: 1.5em;
  width: 1.5em;
}

img.show-info {
  width: 100%;
}

ons-popover >>> .popover--right__content {
  width: 440px;
  text-align: center;
  padding: 2px;
}

ons-popover >>> .button {
  cursor: pointer;
}

ons-popover >>> .popover__arrow {
  width: 15px;
  height: 15px;
}

.cls_move_chip {
  position: absolute;
  background: pink;
  border: #595959 solid 1px;
  user-select: none;
  z-index: 6;
  pointer-events: none;
}
.selected-map-style.cls_move_chip {
  border: none;
}

::v-deep .selected-map-style .bed-inner {
  border: 4px solid #f77903;
  background-color: #fedf;
}

@media print {
  .mapcontent {
    height: auto !important;
  }
  div.zoom-slider {
    display: none !important;
  }
}
</style>
