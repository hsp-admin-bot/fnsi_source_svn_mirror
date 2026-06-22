/**
 * 治療状況ベッドレイアウト BedLayout
 */
<template>
  <div class="bed-layout-main" :style="heightStyles" ref="bedLayoutMain">
    <div style="position: relative; height: inherit;">
      <div class="wrap-block" id="bed-layout-head" style="float: right">
        <!-- 5808 mod 鞠-->
<!--        <div class="nowrap-block" style="margin-left: 1em;">-->
<!--          <v-ons-button class="bed-button btn2-cancel" @click="cancel()">キャンセル</v-ons-button>-->
<!--        </div>-->
<!--        <div class="nowrap-block" style="margin-left: 1em;">-->
<!--          <v-ons-button class="bed-button btn1-execute" :disabled="!isChanged" @click="registration()">保存</v-ons-button>-->
<!--        </div>-->
        <div class="nowrap-block" style="margin-right: 1em;">
          <v-ons-button
            class="bed-button btn3-normal"
            @click="changeHeaderMode()"
          >{{ isSmallHeader ? "▼": "▲" }}</v-ons-button>
        </div>
        <div
          class="nowrap-block"
          style="margin-left: 1em;
                 margin-top:0.6em;"
          v-show="enableHomeDialysis"
        >
          <v-ons-checkbox v-model="isHomeDialysis" @change="updateCheckAtHome($event)">在宅レイアウト</v-ons-checkbox>
        </div>
      </div>
      <div>
        <div id="condition" class="condition2">
          <div v-if="!isSmallHeader">
            <!-- レイアウト選択、名称 -->
            <div class="wrap-block">
              <div class="nowrap-block left">
                <!-- redmine 4579 特大の際のレイアウト不正 宋qy start-->
                <label class="label" style="width: 63%">レイアウト名：</label>
                <!-- redmine 4579 特大の際のレイアウト不正 宋qy end-->
                <v-ons-input class="text custom-input-required" @input="setCss($event.target.value)"  type="text" v-model="inputData.name" />
              </div>
            </div>
            <div style="display:flex; flex-wrap: wrap;">
              <div class="wrap-block">
                <!-- ベッド一覧 -->
                <div class="wrap-block left">
                  <div class="vertical-div">
                    <div class="wrap-block vertical-label left">ベッド一覧</div>
                    <div>
                      <v-ons-checkbox
                        input-id="cbPlacedHidden"
                        v-model="cbPlacedHiddenState"
                      ></v-ons-checkbox>
                      <label for="cbPlacedHidden">配置済みベッドの表示</label>
                    </div>
                    <!-- 施設 -->
                    <div
                      class="nowrap-block"
                      style="align-items: flex-end;"
                      v-show="!isHomeDialysis"
                    >
                      <v-ons-select size="6" class="bed-list select-has-size" v-model="selectedNotPlacedBedKey">
                        <option
                          class="option-bed-list"
                          v-for="(machine, idx) in notPlacedList"
                          :key="idx"
                          :value="getNotPlacedBedKey(machine)"
                          :class="setClassNotPlacedBed(machine)"
                        >{{ machine.name }}</option>
                      </v-ons-select>
                    </div>
                    <!-- 在宅 -->
                    <div
                      class="nowrap-block"
                      style="align-items: flex-end;"
                      v-show="isHomeDialysis"
                    >
                      <v-ons-select size="6" class="bed-list select-has-size" v-model="selectedNotPlacedBedKey">
                        <option
                          class="option-bed-list"
                          v-for="(machine, idx) in notPlacedListAtHome"
                          :key="idx"
                          :value="getNotPlacedBedKey(machine)"
                        >{{ machine.name }}</option>
                      </v-ons-select>
                    </div>
                  </div>
                </div>
              </div>
              <div class="wrap-block">
                <div class="wrap-block left top">
                  <!-- ボタン類 施設 -->
                  <div
                    class="nowrap-block"
                    style="align-items: flex-end;"
                    v-show="!isHomeDialysis"
                  >
                    <v-ons-button
                      class="bed-button horizontal-bed btn3-normal breakable-text"
                      :disabled="!isSelectedNotPlacedBed"
                      @click="insertSideBed(selectedNotPlacedBed)"
                    >
                      {{ selectedNotPlacedBed ? selectedNotPlacedBed.name: "" }}
                      <wbr />横ベッド
                      <wbr />配置
                    </v-ons-button>
                  </div>
                  <div
                    class="nowrap-block"
                    style="margin-left: 1em; align-items: flex-end;"
                    v-show="!isHomeDialysis"
                  >
                    <v-ons-button
                      class="bed-button vertical-bed btn3-normal breakable-text"
                      :disabled="!isSelectedNotPlacedBed"
                      @click="insertVerticalBed(selectedNotPlacedBed)"
                    >
                      {{ selectedNotPlacedBed ? selectedNotPlacedBed.name: "" }}
                      <wbr />縦ベッド
                      <wbr />配置
                    </v-ons-button>
                  </div>
                  <div
                    class="nowrap-block"
                    style="margin-left: 1em; align-items: flex-end;"
                    v-show="!isHomeDialysis"
                  >
                    <v-ons-button
                      class="bed-button square-bed btn3-normal breakable-text"
                      :disabled="!isSelectedNotPlacedBed"
                      @click="insertMachine(selectedNotPlacedBed)"
                    >
                      {{ selectedNotPlacedBed ? selectedNotPlacedBed.name: "" }}
                      <wbr />装置配置
                    </v-ons-button>
                  </div>
                  <!-- ボタン類 在宅 -->
                  <div
                    class="nowrap-block"
                    style="margin-left: 1em; align-items: flex-end;"
                    v-show="isHomeDialysis"
                  >
                    <v-ons-button
                      class="bed-button athome-bed btn3-normal"
                      :disabled="!isSelectedNotPlacedBed"
                      @click="insertHomeBed(selectedNotPlacedBed)"
                    >
                      {{ selectedNotPlacedBed ? selectedNotPlacedBed.name: "" }}
                      <wbr />在宅ベッド
                      <wbr />配置
                    </v-ons-button>
                  </div>
                </div>
              </div>
              <div class="wrap-block" style="align-items: flex-end;">
                <!-- 配置済みベッド -->
                <div class="wrap-block left top">
                  <div class="vertical-div">
                    <div class="wrap-block vertical-label left">配置済みベッド</div>
                    <div class="nowrap-block" style="align-items: flex-end;">
                      <v-ons-select size="6" class="bed-list select-has-size" v-model="selectedPlacedBedKey">
                        <option
                          class="option-bed-list"
                          v-for="machine in placedList"
                          :key="getPlacedBedKey(machine)"
                          :value="getPlacedBedKey(machine)"
                          :class="setClassPlacedBed(machine)"
                        >{{ machine.name }}</option>
                      </v-ons-select>
                    </div>
                  </div>
                  <div class="nowrap-block" style="margin-left: 1em; align-items: flex-end;">
                    <v-ons-button
                      class="bed-button square-bed btn3-normal breakable-text"
                      :disabled="!isSelectedPlacedBed"
                      @click="deleteBed(selectedPlacedBed)"
                    >
                      {{ selectedPlacedBed ? selectedPlacedBed.name: "" }}
                      <wbr />クリア
                    </v-ons-button>
                  </div>
                </div>
              </div>
              <div class="wrap-block">
                <!-- レイアウトサイズ・背景画像 -->
                <div class="wrap-block left buttom-div">
                  <div class="vertical-div">
                    <div>
                      <div class="wrap-block vertical-label left">レイアウトサイズ</div>
                      <div class="nowrap-block">
                        <label class="label">幅</label>
                        <!-- mod #5589 2023/03/29 数値IFのスタイル全不正 張博 start -->
                        <!-- <v-ons-input
                          class="text"
                          type="number"
                          step="1"
                          :max="canvasMaxWidth"
                          :min="canvasMinWidth"
                          style="width: 8em;"
                          v-model="getCanvasSize.width"
                          @input="onCanvasWidth($event.target)"
                        ></v-ons-input> -->
                        <v-ons-input
                          class="text"
                          type="number"
                          step="1"
                          style="width: 8em;"
                          v-model="getCanvasSize.width"
                          @change="onCanvasWidth($event)"
                          @mousewheel.prevent="mouseWheelWidth($event,0)"
                          @blur="formatValueWidth($event,0)"
                          @focus="handleFocus(0)"
                        ></v-ons-input>
                        <!-- mod #5589 2023/03/29 数値IFのスタイル全不正 張博 end -->
                        <label class="label">高</label>
                        <!-- mod #5589 2023/03/29 数値IFのスタイル全不正 張博 start -->
                        <!-- <v-ons-input
                          class="text"
                          type="number"
                          step="1"
                          :max="canvasMaxHeight"
                          :min="canvasMinHeight"
                          style="width: 8em;"
                          v-model="getCanvasSize.height"
                          @input="onCanvasHeight($event.target)"
                        ></v-ons-input> -->
                        <v-ons-input
                          class="text"
                          type="number"
                          step="1"
                          style="width: 8em;"
                          v-model="getCanvasSize.height"
                          @change="onCanvasHeight($event)"
                          @mousewheel.prevent="mouseWheelHeight($event,1)"
                          @blur="formatValueHeight($event,1)"
                          @focus="handleFocus(1)"
                        ></v-ons-input>
                        <!-- mod #5589 2023/03/29 数値IFのスタイル全不正 張博 end -->
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="wrap-block">
              <!-- レイアウトサイズ・背景画像 -->
              <div class="wrap-block left buttom-div">
                <div class="nowrap-block buttom-div">
                  <v-ons-button
                    class="bed-button btn2-cancel"
                    style="max-height: 3.2em;"
                    @click="resetCanvasSize()"
                  >レイアウトサイズを標準に戻す</v-ons-button>
                </div>
                <div class="nowrap-block buttom-div" style="margin-left: 1em; ">
                  <label for="fileElem" class="button bed-button btn3-normal" style="max-height: 3.2em;">
                    背景画像読み込み
                    <input
                      type="file"
                      id="fileElem"
                      multiple
                      accept="image/*"
                      style="display: none;"
                      @change="setBackgroundImage"
                    />
                  </label>
                </div>
              </div>
              <div class="wrap-block left buttom-div top">
                <div class="nowrap-block buttom-div">
                  <v-ons-button
                    class="bed-button btn3-normal"
                    style="max-height: 3.2em;"
                    @click="clearBackgroundImage"
                  >背景画像クリア</v-ons-button>
                </div>
                <div class="nowrap-block buttom-div" style="margin-left: 1em; ">
                  <label for="cssFileElem" class="button bed-button btn3-normal" style="max-height: 3.2em;">
                    CSS読み込み
                    <input
                      type="file"
                      id="cssFileElem"
                      multiple
                      accept="text/css"
                      style="display: none;"
                      @change="setCssStyle($event)"
                    />
                  </label>
                </div>
              </div>
              <div class="wrap-block left buttom-div top">
                <div class="nowrap-block buttom-div">
                  <v-ons-button
                    class="bed-button btn3-normal"
                    style="max-height: 3.2em;"
                    @click="deleteStyle"
                  >CSSクリア</v-ons-button>
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- ベッド操作 -->
        <div id="layout-controller" class="wrap-block clearboth" style="background-color: #EEFF; margin-top: 5px;">
          <div v-for="(adjustBtn, cd) in layoutAdjustBtnList" :key="cd">
            <div class="btn-wrapper" @mouseenter="adjustTooltipPosition(cd)" @mouseleave="resetTooltipPosition(cd)" :ref="'btnWrapper' + cd">
              <v-ons-button
                v-show="!isHomeDialysis || adjustBtn.isHomeDialysisDisp"
                class="adjust-btn"
                @click="runLayoutAdjust(cd)"
                :style="adjustBtnStyle(cd)"
              >
                <img :src="adjustBtn.img" class="adjust-img" />
              </v-ons-button>
              <div class="tooltips" :ref="'tooltip' + cd">
                <span class="tooltip-item">{{adjustBtn.name}}</span>
              </div>
            </div>
          </div>
        </div>
        <div :style="configBedLayoutStyles" id="configBedLayoutId">
          <!-- #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start -->
          <grid-layout
            :key="gridLayoutKey"
            v-model:layout="gridPlacementList"
            :col-num="gridColNum"
            :width="gridLayoutWidth"
            :row-height="this.GRID_SIZE"
            :max-rows="gridMaxRows"
            :is-draggable="true"
            :is-resizable="isHomeDialysis ? false : true"
            :is-mirrored="false"
            :vertical-compact="false"
            :allow-overlap="true"
            :margin="[0, 0]"
            :use-css-transforms="true"
            draggable-cancel=".button-area, .bed-delete-btn, .bed-name, .vue-resizable-handle"
            @drag="onGridDrag"
            @drag-stop="onGridDragStop"
            @resize-stop="onGridResizeStop"
            :style="{
                    backgroundColor: '#AFFF',
                    width: getCanvasSize.width + 'px',
                    height: getCanvasSize.height + 'px',
                    backgroundImage: 'url(' + backgroundImage + ')',
                    backgroundSize: getCanvasSize.width + 'px ' + getCanvasSize.height + 'px',
                    backgroundRepeat: 'no-repeat',
                    backgroundPosition: 'center'
                  }"
          >
          <!-- #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end -->
            <div
              v-for="item in gridPlacementList"
              :key="item.i"
              class="grid-bed-slot"
              @mousedown="onGridBedPointerDown(item, $event)"
              @touchstart="onGridBedPointerDown(item, $event)"
            >
              <div
                :class="getGridBedOuterClass(item)"
                :style="getGridBedBoxStyle(item)"
                :data-name="getGridBedName(item)"
              >
                <div class="bed-name">
                  {{ getGridBedName(item) }}
                </div>
                <div v-if="showGridBedDelete(item)" class="button-area">
                  <button
                    type="button"
                    class="bed-delete-btn"
                    @click.stop="deleteBed(getGridBedModel(item))"
                  >
                    <v-ons-icon icon="fa-trash" />
                  </button>
                </div>
              </div>
            </div>
          </grid-layout>
        </div>
        <!-- add 鞠 5808 キャンセルと保存のボタン start  -->
        <div  id="item-box-conf" class="item-box-conf">
          <div id="list-footer">
            <div class="dialog-cancel">
              <ons-button class="btn2-cancel denial-btn button" style="color: white" @click="cancel">キャンセル</ons-button>
            </div>
            <div class="dialog-conf">
              <ons-button class="btn1-execute registration-btn button" :disabled="!isChanged" @click="registration()">保存</ons-button>
            </div>
          </div>
        </div>
        <!-- add 鞠 5808 キャンセルと保存のボタン end  -->
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions, mapState } from "@/compat/vue/vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";

import { GridLayout } from "@/compat/grid-layout";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { getHeaderHeight, getFooterMenuClientHeight, getViewportWidth, getScopedElementsByClassName, getScopedElementById, getScopedAlertDialogs, getScopedJQuery } from "@/functions/common/LayoutMeasureHelper";

// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//add #12658 securify】SQLインジェクション(High) まとめ zrx start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
import { messageFormat } from "@/functions/common/MessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { getLatestHeaderElement } from "@/functions/common/LayoutMeasureHelper";
//add #12658 securify】SQLインジェクション(High) まとめ zrx end

const LARGE_SIZE = {
  // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng start
  // width: 18,
  // height: 27
  width: 180,
  height: 270
  // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng end
};
const MIDDLE_SIZE = {
  // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng start
  // width: 15,
  // height: 20
  width: 150,
  height: 200
  // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng end
};
const SMALL_SIZE = {
  // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng start
  // width: 12,
  // height: 18
  width: 120,
  height: 180
  // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng end
};

export default {
  name: "MstStatusMapBedLayout",
  components: { GridLayout },

  data() {
    return {
      // #9771 ベッドの図はかぶっているように見える linjunfeng start
      // GRID_SIZE: 10,
      GRID_SIZE: 1,
      // #9771 ベッドの図はかぶっているように見える linjunfeng end
      isSmallHeader: false,
      selectedNotPlacedBedKey: null,
      selectedPlacedBedKey: null,
      comboSelectedBedLayoutId: null,
      selectedBedName: "",
      druggingMachinePlace: null,
      draggingGridItemId: null,
      dragStartGridPosition: null,
      gridDragRafId: null,
      pendingGridBedSelect: null,
      gridBedPointerUpHandler: null,
      suppressLayoutMerge: false,
      inputData: {
        code: null,
        name: null,
        canvas_size: {
          width: 0,
          height: 0
        },
        obj_list: [],
        gridPlacementList: [],
        backgroundImage: "",
        bedLayout: null
      },
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      isAndroid: false,
      isIOS: false,
      //自画面の名称
      selfScreenName: "",
      formHeight: 300,
      formConfigAreaHeight: 300,
      formLayoutDesignAreaHeight: 300,
      isHomeDialysis: false,
      isChanged: false,
      canvasMaxWidth: 9999,
      canvasMinWidth: 0,
      canvasMaxHeight: 9999,
      canvasMinHeight: 0,
      blurFlg:false,
      cssText: "",
      // #5589 2023/04/24 数値IFのスタイル全不正 张博 start
      focusFlg:[false,false],
      // #5589 2023/04/24 数値IFのスタイル全不正 张博 end
      // レイアウト調整ボタンリスト
      layoutAdjustBtnList: {
        1: {
          name: "L",
          isHomeDialysisDisp: false,
          img: "img/master-maintenance/mst-status-map-bed-layout/lerge.png"
        },
        2: {
          name: "M",
          isHomeDialysisDisp: false,
          img: "img/master-maintenance/mst-status-map-bed-layout/midium.png"
        },
        3: {
          name: "S",
          isHomeDialysisDisp: false,
          img: "img/master-maintenance/mst-status-map-bed-layout/small.png"
        },
        4: {
          name: "縦横反転",
          isHomeDialysisDisp: false,
          img: "img/master-maintenance/mst-status-map-bed-layout/rotate.png"
        },
        5: {
          name: "横向き",
          isHomeDialysisDisp: false,
          img: "img/master-maintenance/mst-status-map-bed-layout/sideway.png"
        },
        6: {
          name: "縦向き",
          isHomeDialysisDisp: false,
          img: "img/master-maintenance/mst-status-map-bed-layout/vertical.png"
        },
        7: {
          name: "左揃え",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/left-align.png"
        },
        8: {
          name: "右揃え",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/right-align.png"
        },
        9: {
          name: "左右中央揃え",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/horizon-center-align.png"
        },
        10: {
          name: "上揃え",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/top-align.png"
        },
        11: {
          name: "下揃え",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/bottom-align.png"
        },
        12: {
          name: "上下中央揃え",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/vertical-center-align.png"
        },
        13: {
          name: "垂直方向の間隔を減らす",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/reduce-vertical-gap.png"
        },
        14: {
          name: "垂直方向の間隔を増やす",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/increase-vertical-gap.png"
        },
        15: {
          name: "垂直方向の間隔を無くす",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/clear-vertical-gap.png"
        },
        16: {
          name: "垂直方向に等間隔で配置する",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/set-equal-interval-vertical.png"
        },
        17: {
          name: "水平方向の間隔を減らす",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/reduce-horizontal-gap.png"
        },
        18: {
          name: "水平方向の間隔を増やす",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/increase-horizontal-gap.png"
        },
        19: {
          name: "水平方向の間隔を無くす",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/clear-horizontal-gap.png"
        },
        20: {
          name: "水平方向に等間隔で配置する",
          isHomeDialysisDisp: true,
          img: "img/master-maintenance/mst-status-map-bed-layout/set-equal-interval-horizontal.png"
        }
      },
      // 配置済みベッドの表示のチェック状態：デフォルトは非チェック
      cbPlacedHiddenState: false,
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
      type: null
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
    };
  },
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("mst-status-map-bed-layout", {
      getMachineList: "getMachineList",
      getMachineAndBedList: "getMachineAndBedList",
      getBedLayout: "getBedLayout",
      getBedLayoutList: "getBedLayoutList",
      getModel: "getModel"
    }),
    ...mapGetters("user", ["getFacilityCd", "getAdvancedSettings"]),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapState("account-edit", ["showSidebarFlg"]),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return {
        height: `${this.formHeight}px`,
        "flex-direction": "column",
        display: "flex",
        overflow: "auto"
      };
    },
    configBedLayoutStyles() {
      return {
        height: `${this.formLayoutDesignAreaHeight}px`,
        overflow: "scroll",
        minHeight: "300px"
      };
    },
    gridColNum() {
      const width = Number(this.getCanvasSize?.width);
      if (!Number.isFinite(width) || width <= 0) {
        return 1;
      }
      return Math.max(1, Math.round(width / this.GRID_SIZE));
    },
    gridLayoutWidth() {
      const width = Number(this.getCanvasSize?.width);
      if (!Number.isFinite(width) || width <= 0) {
        return 1;
      }
      return width;
    },
    gridMaxRows() {
      const height = Number(this.getCanvasSize?.height);
      if (!Number.isFinite(height) || height <= 0) {
        return Infinity;
      }
      return Math.max(1, Math.ceil(height / this.GRID_SIZE));
    },
    gridLayoutKey() {
      // 列数は幅のみに依存する。高さを key に含めると canvas 高さ変更のたびに
      // grid-layout が再生成され、layout 同期で mstBed/name が欠落してベッド名が消える。
      return String(this.gridLayoutWidth);
    },
    gridPlacementList: {
      get() {
        return this.inputData.gridPlacementList;
      },
      set(value) {
        if (this.suppressLayoutMerge) {
          return;
        }
        this.inputData.gridPlacementList = this.mergeGridPlacementList(value);
        if (!this.suppressLayoutMerge) {
          this.setIsChange(true);
        }
      }
    },
    placedList() {
      return this.inputData.obj_list;
    },
    /**
     * 施設用ベッド一覧
     */
    notPlacedList() {
      if (this.getMachineAndBedList) {
        let ret = this.getMachineAndBedList.filter(
          dat =>
            !this.placedList.find(
              dt => dt.machine_no === dat.machineNo.toString() && dt.bed_cd === dat.bedCd
            ) && dat.isHomeDialysis == false
        );
        if (!this.cbPlacedHiddenState) {
          // 配置済みベッドの表示が非チェックの場合は、配置済みのベッドをリストに表示しない
          let cdList = { "bedCd":[], "machineNo":[]};
          this.inputData.obj_list.forEach(obj => {
            if (obj.bed_cd > 0) {
              cdList.bedCd.push(obj.bed_cd);
            } else if (obj.bed_cd === -1 && obj.machine_no > 0) {
              cdList.machineNo.push(obj.machine_no);
            }
          });
          ret = ret.filter(
            obj =>
              (obj.bedCd > 0 && !cdList.bedCd.includes(obj.bedCd)) ||
              (obj.bedCd === -1 && obj.machineNo > 0 && !cdList.machineNo.includes(obj.machineNo))
          );
        }
        if (!this.isHomeDialysis) {
          this.selectedRowNotPlaced(ret);
        }
        return ret;
      } else {
        return [];
      }
    },
    /**
     * 在宅用ベッド一覧
     */
    notPlacedListAtHome() {
      if (this.getMachineAndBedList) {
        const ret = this.getMachineAndBedList.filter(
          dat =>
            !this.placedList.find(
              dt => dt.machine_no === dat.machineNo && dt.bed_cd === dat.bedCd
            ) && dat.isHomeDialysis == true
        );
        if (this.isHomeDialysis) {
          this.selectedRowNotPlaced(ret);
        }
        return ret;
      } else {
        return [];
      }
    },
    getCanvasSize() {
      return this.inputData.canvas_size
        ? this.inputData.canvas_size
        : { width: 0, height: 0 };
    },
    backgroundImage() {
      if (this.inputData.backgroundImage !== null) {
        return this.inputData.backgroundImage;
      } else {
        return "";
      }
    },
    /**
     * 選択中の装置一覧
     */
    selectedMachineList() {
      return this.gridPlacementList.filter(machine => machine.selected);
    },
    /**
     * 装置背景色（選択中/非選択）
     */
    machineBackgroundColor() {
      return machine => (machine.selected ? "#FEDF" : "#FFFF");
    },
    selectedNotPlacedBed() {
      if (!this.selectedNotPlacedBedKey) {
        return null;
      }
      const list = this.isHomeDialysis
        ? this.notPlacedListAtHome
        : this.notPlacedList;
      return (
        list.find(
          bed => this.getNotPlacedBedKey(bed) === this.selectedNotPlacedBedKey
        ) || null
      );
    },
    selectedPlacedBed() {
      if (!this.selectedPlacedBedKey) {
        return null;
      }
      return (
        this.placedList.find(
          bed => this.getPlacedBedKey(bed) === this.selectedPlacedBedKey
        ) || null
      );
    },
    isSelectedNotPlacedBed() {
      return !!this.selectedNotPlacedBedKey;
    },
    isSelectedPlacedBed() {
      return !!this.selectedPlacedBedKey;
    },
    enableHomeDialysis() {
      return this.getAdvancedSettings.func_advcds.some(
        setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
      );
    },
    // ベッド一覧のフォーカス
    setClassNotPlacedBed: function () {
      const that = this;
      return function (data) {
        if (that.getNotPlacedBedKey(data) === that.selectedNotPlacedBedKey) {
          return { "selected-color": true };
        } else {
          return {};
        }
      }
    },
    // 配置済みベッドのフォーカス
    setClassPlacedBed: function () {
      const that = this;
      return function (data) {
        if (that.getPlacedBedKey(data) === that.selectedPlacedBedKey) {
          return { "selected-color": true };
        } else {
          return {};
        }
      }
    }
  },
  methods: {
    requestViewForceUpdate() {
      if (this.$?.isMounted) {
        this.$forceUpdate();
      }
    },
    ...mapActions("mst-status-map-bed-layout", {
      stateInitialize: "stateInitialize",
      selectBedLayout: "selectBedLayout",
      registrationBedLayout: "registrationBedLayout"
    }),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("master-maintenance", [
      "setEditRecord",
      "setMasterRecordList",
      "editRecordBeEmpty"
    ]),
    buildGridItem(item) {
      const bed = item?.mstBed;
      const pixelWidth = bed?.width ?? item.w * this.GRID_SIZE;
      const pixelHeight = bed?.height ?? item.h * this.GRID_SIZE;
      return {
        minW: Math.max(1, pixelWidth / this.GRID_SIZE / 10),
        minH: Math.max(1, pixelHeight / this.GRID_SIZE / 10)
      };
    },
    withGridItemConstraints(item) {
      const constraints = this.buildGridItem(item);
      return {
        ...item,
        i: String(item.i),
        x: Number(item.x),
        y: Number(item.y),
        w: Number(item.w),
        h: Number(item.h),
        minW: constraints.minW,
        minH: constraints.minH
      };
    },
    mergeGridPlacementList(nextLayout) {
      if (!Array.isArray(nextLayout)) {
        return this.inputData.gridPlacementList;
      }
      const currentMap = new Map(
        this.inputData.gridPlacementList.map(item => [String(item.i), item])
      );
      return nextLayout.map(item => {
        const currentItem = currentMap.get(String(item.i));
        if (!currentItem) {
          const obj = this.inputData.obj_list.find(
            dat => String(dat.disp_order_no) === String(item.i)
          );
          if (obj) {
            const resolvedName = obj.name || obj.mstBed?.name || "";
            return this.withGridItemConstraints({
              i: String(item.i),
              x: item.x,
              y: item.y,
              w: item.w,
              h: item.h,
              selected: false,
              name: resolvedName,
              mstBed: {
                mstBed: obj.mstBed,
                machine_no: obj.machine_no,
                bed_cd: obj.bed_cd,
                name: resolvedName,
                width: item.w * this.GRID_SIZE,
                height: item.h * this.GRID_SIZE,
                top: item.y * this.GRID_SIZE,
                left: item.x * this.GRID_SIZE,
                disp_order_no: obj.disp_order_no,
                sortNo: obj.sortNo
              }
            });
          }
          return item;
        }
        const merged = this.withGridItemConstraints({
          ...currentItem,
          x: item.x,
          y: item.y,
          w: item.w,
          h: item.h,
          i: String(item.i)
        });
        if (merged.mstBed) {
          merged.mstBed = {
            ...merged.mstBed,
            width: merged.w * this.GRID_SIZE,
            height: merged.h * this.GRID_SIZE
          };
        }
        if (!this.suppressLayoutMerge) {
          this.syncObjListFromGridItem(merged);
        }
        return merged;
      });
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
    resizedEvevt() {
      this.setIsChange(true);
    },
    applyCanvasSizeChange() {
      this.suppressLayoutMerge = true;
      this.restoreGridPlacementFromObjList();
      this.$nextTick(() => {
        this.refreshGridPlacementFromState();
        this.requestViewForceUpdate();
        requestAnimationFrame(() => {
          this.suppressLayoutMerge = false;
        });
      });
    },
    restoreGridPlacementFromObjList() {
      const currentMap = new Map(
        this.inputData.gridPlacementList.map(item => [String(item.i), item])
      );
      this.inputData.gridPlacementList = this.inputData.obj_list.map(obj => {
        const orderNo = String(obj.disp_order_no);
        const existing = currentMap.get(orderNo);
        const pixelWidth = Number(obj.width);
        const pixelHeight = Number(obj.height);
        const pixelLeft = Number(obj.left);
        const pixelTop = Number(obj.top);
        const mstBed = existing?.mstBed ?? {
          mstBed: obj.mstBed,
          machine_no: obj.machine_no,
          bed_cd: obj.bed_cd,
          name: obj.name,
          width: pixelWidth,
          height: pixelHeight,
          top: pixelTop,
          left: pixelLeft,
          disp_order_no: obj.disp_order_no,
          sortNo: obj.sortNo
        };
        const resolvedName =
          obj.name ??
          existing?.name ??
          mstBed.name ??
          mstBed.mstBed?.name ??
          "";
        return this.withGridItemConstraints({
          ...(existing || {}),
          i: orderNo,
          x: pixelLeft / this.GRID_SIZE,
          y: pixelTop / this.GRID_SIZE,
          w: pixelWidth / this.GRID_SIZE,
          h: pixelHeight / this.GRID_SIZE,
          selected: existing?.selected ?? false,
          name: resolvedName,
          mstBed: {
            ...mstBed,
            name: resolvedName,
            width: pixelWidth,
            height: pixelHeight,
            top: pixelTop,
            left: pixelLeft
          }
        });
      });
    },
    applyGridLayoutFromEvent(layout) {
      if (!Array.isArray(layout) || !layout.length) {
        return;
      }
      this.gridPlacementList = layout;
    },
    gridLayoutItemsOverlap(a, b) {
      return (
        a.x < b.x + b.w &&
        a.x + a.w > b.x &&
        a.y < b.y + b.h &&
        a.y + a.h > b.y
      );
    },
    gridLayoutItemsShareColumn(a, b) {
      return a.x < b.x + b.w && a.x + a.w > b.x;
    },
    applyGridBedOverlapStack(items, dragged, draggedIdStr, capY) {
      const draggedKey = String(draggedIdStr);
      const overlapped = items.filter(
        (item) =>
          item.i !== draggedKey && this.gridLayoutItemsOverlap(dragged, item)
      );
      if (!overlapped.length) {
        return;
      }
      const sorted = [...overlapped].sort((a, b) => a.y - b.y);
      let stackEdge = dragged.y + dragged.h;
      for (const item of sorted) {
        const targetY = capY(stackEdge, item.h);
        if (item.y !== targetY) {
          item.y = targetY;
        }
        stackEdge = targetY + item.h;
      }
    },
    resolveGridBedDisplacedChain(items, dragged, draggedIdStr, capY) {
      const draggedKey = String(draggedIdStr);
      const displacedIds = new Set(
        items
          .filter(
            (item) =>
              item.i !== draggedKey &&
              this.gridLayoutItemsOverlap(dragged, item)
          )
          .map((item) => item.i)
      );
      if (!displacedIds.size) {
        return;
      }
      const inDragColumn = (item) =>
        item.i !== draggedKey && this.gridLayoutItemsShareColumn(item, dragged);
      const maxGuard = Math.max(1, items.length * (items.length + 1));

      for (let guard = 0; guard < maxGuard; guard++) {
        let changed = false;
        for (const item of items) {
          if (!inDragColumn(item)) {
            continue;
          }
          let pushBelow = null;
          for (const other of items) {
            if (item.i === other.i) {
              continue;
            }
            const otherIsDragged = other.i === draggedKey;
            const otherIsDisplaced = displacedIds.has(other.i);
            if (!otherIsDragged && !otherIsDisplaced) {
              continue;
            }
            if (
              !this.gridLayoutItemsShareColumn(item, other) ||
              !this.gridLayoutItemsOverlap(item, other)
            ) {
              continue;
            }
            pushBelow = Math.max(pushBelow ?? 0, other.y + other.h);
          }
          if (pushBelow == null) {
            continue;
          }
          const targetY = capY(pushBelow, item.h);
          if (item.y !== targetY) {
            item.y = targetY;
            changed = true;
            displacedIds.add(item.i);
          }
        }
        if (!changed) {
          break;
        }
      }
    },
    resolveGridBedPushCollisions(layout, draggedId) {
      if (!Array.isArray(layout) || draggedId == null) {
        return layout;
      }
      const maxRows = Number.isFinite(this.gridMaxRows) ? this.gridMaxRows : Infinity;
      const items = layout.map((item) => ({
        ...item,
        i: String(item.i),
        x: Number(item.x),
        y: Number(item.y),
        w: Number(item.w),
        h: Number(item.h)
      }));
      const draggedIdStr = String(draggedId);
      const dragged = items.find((item) => item.i === draggedIdStr);
      const capY = (y, itemH) => Math.max(0, Math.min(y, maxRows - itemH));

      if (dragged) {
        this.applyGridBedOverlapStack(items, dragged, draggedIdStr, capY);
        this.resolveGridBedDisplacedChain(items, dragged, draggedIdStr, capY);
      }
      return items;
    },
    patchGridPlacementPositions(resolvedLayout) {
      if (!Array.isArray(resolvedLayout) || !resolvedLayout.length) {
        return;
      }
      const posMap = new Map(
        resolvedLayout.map((item) => [String(item.i), item])
      );
      let changed = false;
      const nextList = this.inputData.gridPlacementList.map((item) => {
        const pos = posMap.get(String(item.i));
        if (!pos) {
          return item;
        }
        const x = Number(pos.x);
        const y = Number(pos.y);
        if (Number(item.x) === x && Number(item.y) === y) {
          return item;
        }
        changed = true;
        const patched = {
          ...item,
          x,
          y,
          i: String(item.i)
        };
        if (patched.mstBed) {
          patched.mstBed = {
            ...patched.mstBed,
            top: y * this.GRID_SIZE,
            left: x * this.GRID_SIZE
          };
        }
        return patched;
      });
      if (changed) {
        this.inputData.gridPlacementList = nextList;
      }
    },
    applyGridBedPushLayout(layout) {
      if (!Array.isArray(layout) || !layout.length) {
        return;
      }
      const resolvedLayout = this.draggingGridItemId
        ? this.resolveGridBedPushCollisions(layout, this.draggingGridItemId)
        : layout;
      this.patchGridPlacementPositions(resolvedLayout);
    },
    clearGridBedDragState() {
      if (this.gridDragRafId != null) {
        cancelAnimationFrame(this.gridDragRafId);
        this.gridDragRafId = null;
      }
      this.suppressLayoutMerge = false;
      this.draggingGridItemId = null;
      this.dragStartGridPosition = null;
    },
    onGridDrag(layout) {
      if (!this.draggingGridItemId) {
        return;
      }
      if (this.gridDragRafId != null) {
        cancelAnimationFrame(this.gridDragRafId);
      }
      this.gridDragRafId = requestAnimationFrame(() => {
        this.gridDragRafId = null;
        this.applyGridBedPushLayout(layout);
      });
    },
    onGridDragStop(layout) {
      const resolvedLayout = this.draggingGridItemId
        ? this.resolveGridBedPushCollisions(layout, this.draggingGridItemId)
        : layout;
      this.clearGridBedDragState();
      this.inputData.gridPlacementList = this.mergeGridPlacementList(resolvedLayout);
      this.setIsChange(true);
    },
    onGridResizeStop(layout) {
      this.resizedEvevt();
      this.applyGridLayoutFromEvent(layout);
    },
    runLayoutAdjust(cd) {
      const handlers = {
        1: this.setLargeSizeSelectedMachine,
        2: this.setMiddleSizeSelectedMachine,
        3: this.setSmallSizeSelectedMachine,
        4: this.rotateSelectedMachine,
        5: this.sidewaySelectedMachine,
        6: this.verticalSelectedMachine,
        7: this.leftAlignSelectedMachine,
        8: this.rightAlignSelectedMachine,
        9: this.horizonCenterAlignSelectedMachine,
        10: this.topAlignSelectedMachine,
        11: this.bottomAlignSelectedMachine,
        12: this.verticalCenterAlignSelectedMachine,
        13: this.reduceVerticalGapSelectedMachine,
        14: this.increaseVerticalGapSelectedMachine,
        15: this.clearVerticalGapSelectedMachine,
        16: this.setEqualIntervalVerticalSelectedMachine,
        17: this.reduceHorizontalGapSelectedMachine,
        18: this.increaseHorizontalGapSelectedMachine,
        19: this.clearHorizontalGapSelectedMachine,
        20: this.setEqualIntervalHorizontalSelectedMachine
      };
      const handler = handlers[Number(cd)];
      if (typeof handler !== "function") {
        return;
      }
      this.suppressLayoutMerge = true;
      try {
        handler.call(this);
      } catch (error) {
        console.error("[MstStatusMapBedLayout] runLayoutAdjust failed:", error);
      } finally {
        this.$nextTick(() => {
          this.suppressLayoutMerge = false;
        });
      }
    },
    clearGridBedPointerListener() {
      if (!this.gridBedPointerUpHandler) {
        return;
      }
      window.removeEventListener("mouseup", this.gridBedPointerUpHandler);
      window.removeEventListener("touchend", this.gridBedPointerUpHandler);
      this.gridBedPointerUpHandler = null;
    },
    finishGridBedPointer(item) {
      this.clearGridBedPointerListener();
      const pending = this.pendingGridBedSelect;
      this.pendingGridBedSelect = null;
      if (!pending || String(pending.item?.i) !== String(item?.i)) {
        this.clearGridBedDragState();
        this.druggingMachinePlace = null;
        return;
      }
      const gridItem = this.gridPlacementList.find(
        gridEntry => String(gridEntry.i) === String(item.i)
      );
      if (!gridItem) {
        this.clearGridBedDragState();
        this.druggingMachinePlace = null;
        return;
      }
      if (pending.x === gridItem.x && pending.y === gridItem.y) {
        gridItem.selected = !gridItem.selected;
        this.commitGridPlacementList();
      }
      this.clearGridBedDragState();
      this.druggingMachinePlace = null;
    },
    refreshGridPlacementFromState() {
      this.inputData.gridPlacementList = this.inputData.gridPlacementList.map(
        gridItem => this.withGridItemConstraints({
          ...gridItem,
          selected: !!gridItem.selected,
          name: gridItem.name,
          mstBed: gridItem.mstBed ? { ...gridItem.mstBed } : gridItem.mstBed
        })
      );
    },
    commitGridPlacementList() {
      this.refreshGridPlacementFromState();
    },
    onGridBedPointerDown(item, event) {
      if (
        event?.target?.closest?.(
          ".button-area, .bed-delete-btn, .vue-resizable-handle, [class*='resizable-handle']"
        )
      ) {
        return;
      }
      this.clearGridBedPointerListener();
      this.pendingGridBedSelect = {
        item,
        x: item.x,
        y: item.y
      };
      this.draggingGridItemId = String(item.i);
      this.dragStartGridPosition = {
        x: Number(item.x),
        y: Number(item.y)
      };
      this.suppressLayoutMerge = true;
      this.keepPlace(item);
      this.selectBed(this.getGridBedModel(item));
      this.gridBedPointerUpHandler = () => this.finishGridBedPointer(item);
      window.addEventListener("mouseup", this.gridBedPointerUpHandler);
      window.addEventListener("touchend", this.gridBedPointerUpHandler);
    },
    getGridBedModel(item) {
      return item?.mstBed || item;
    },
    getGridBedName(item) {
      if (item?.name) {
        return item.name;
      }
      const bed = this.getGridBedModel(item);
      if (!bed) {
        return "";
      }
      return bed.name || bed.mstBed?.name || "";
    },
    getGridBedOuterClass(item) {
      const bed = this.getGridBedModel(item);
      const inner = bed?.mstBed || bed;
      return {
        bed: !inner?.isHomeDialysis,
        "bed-home": !!inner?.isHomeDialysis,
        "bed-selected": !!item.selected
      };
    },
    getGridBedBoxStyle(item) {
      return {
        width: "100%",
        height: "100%",
        position: "relative",
        boxSizing: "border-box"
      };
    },
    showGridBedDelete(item) {
      const bed = this.getGridBedModel(item);
      return !(
        this.isHomeDialysis ||
        bed?.isHomeDialysis ||
        bed?.mstBed?.isHomeDialysis
      );
    },
    selectBed(mstBed) {
      const bed = mstBed?.mstBed || mstBed;
      this.selectedBedName = bed?.name || mstBed?.name || "";
    },
    /**
     * 在宅フラグのチェック
     */
    async updateCheckAtHome(event) {
      this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            this.initialize();
          } else {
            this.isHomeDialysis = !event.target.checked;
          }
        }
      });
      this.$nextTick(() => {
        this.calculateHeight();
      });
    },
    /**
     * 初期化
     */
    async initialize() {
      // add マスタ一覧 施設切替を可能とする 王 start
      // await this.stateInitialize(this.getFacilityCd);
      await this.stateInitialize(this.getFacilitySwitch);
      // add マスタ一覧 施設切替を可能とする 王 start
      this.clearBedLayout();
      this.comboSelectedBedLayoutId = null;
      this.setIsChange(false);
      this.insIdx = -1;
      this.delIdx = -1;
      this.selectedNotPlacedBedKey = null;
      this.selectedPlacedBedKey = null;
    },
    getNotPlacedBedKey(bed) {
      if (!bed) {
        return "";
      }
      return `${bed.machineNo}_${bed.bedCd}`;
    },
    getPlacedBedKey(bed) {
      if (!bed) {
        return "";
      }
      const orderNo = this.resolveDispOrderNo(bed);
      if (orderNo != null) {
        return String(orderNo);
      }
      return `${bed.machine_no}_${bed.bed_cd}`;
    },
    resolveDispOrderNo(bed) {
      if (!bed) {
        return null;
      }
      if (bed.disp_order_no != null) {
        return bed.disp_order_no;
      }
      if (bed.mstBed?.disp_order_no != null) {
        return bed.mstBed.disp_order_no;
      }
      return null;
    },
    /**
     * キャンパスサイズリセット
     */
    resetCanvasSize() {
      // add bug 8358 修正 chen start
      if (this.inputData.canvas_size.width != 500 || this.inputData.canvas_size.height != 500) {
        this.setIsChange(true);
      }
      // add bug 8358 修正 chen end
      this.inputData.canvas_size.width = 500;
      this.inputData.canvas_size.height = 500;
      this.applyCanvasSizeChange();
    },
    getScopedElementById(id) {
      return getScopedElementById(id, this.$el || this);
    },
    getScopedClassElement(className) {
      return getScopedElementsByClassName(className, this.$el || this)[0] || null;
    },
    getScopedElementsByClassName(className) {
      return getScopedElementsByClassName(className, this.$el || this);
    },
    getScopedOwnerWindow(element = null) {
      return element?.ownerDocument?.defaultView || this.$el?.ownerDocument?.defaultView || window;
    },
    getScopedComputedStyle(element) {
      if (!element) {
        return null;
      }
      return this.getScopedOwnerWindow(element).getComputedStyle(element);
    },
    setCss(value) {
      // add bug 8358 修正 chen start
      this.setIsChange(true);
      // add bug 8358 修正 chen end
      if (value && this.getScopedClassElement("custom-input-invalid")) {
        this.getScopedClassElement("custom-input-invalid").classList.remove("custom-input-invalid");
      }
    },
    // Windowの高さから領域の高さを算出
    calculateHeight() {
      if (!this.editingFlg) {
        const wh = this.windowHeight;
        const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
        const fmh =
          (this.isDispMenu === 1
            ? getFooterMenuClientHeight(this.$el || null)
            : 0) + 5;

        this.formHeight = wh - hh - fmh;

        // 縦スクロール発生抑制の為、ベッドレイアウトエリアのmaxHeightにminHeight値を設定
        // (処理中に一時的に発生した縦スクロールが各要素の表示に影響を与え、取得する要素の高さが想定値とならないケースがある)
        // (maxHeightにminHeight値を設定した状態で縦スクロール発生する場合は、一時的ではなく必ず縦スクロールが発生する)
        this.getScopedElementById("configBedLayoutId").style.maxHeight =
          this.getScopedElementById("configBedLayoutId").style.minHeight;

        const ch = this.getScopedElementById("bed-layout-head");
        const chh = ch ? ch.clientHeight : 0;
        this.formConfigAreaHeight = this.formHeight - chh;
        const lc = this.getScopedElementById("layout-controller");
        const lh = lc ? lc.clientHeight : 0;
        const cn = this.getScopedElementById("condition");
        const cnh = cn ? cn.clientHeight : 0;
        this.formLayoutDesignAreaHeight = this.formConfigAreaHeight - lh - cnh +40;
        //5099 スマホレイアウトの調整 add 鞠 start
        if (this.androidFlg && this.getFontSize.toString()=="3") {
          this.getScopedClassElement("horizontal-bed") && (this.getScopedClassElement("horizontal-bed").style.width = "8em")
          this.getScopedClassElement("vertical-bed") && (this.getScopedClassElement("vertical-bed").style.width = "5em")
          this.getScopedClassElement("square-bed") && (this.getScopedClassElement("square-bed").style.width = "5em")
        }
        // 5808 add 鞠 拡大縮小のボタン:"▲""▼"の時に最大の高さ start
        this.$nextTick(() => {
          this.calculateConfigBedLayoutMaxHeight();
        });
        // 5808 add 鞠 拡大縮小のボタン:"▲""▼"の時に最大の高さ end
      }
    },

    calculateConfigBedLayoutMaxHeight() {
      const conditionHeight = this.getScopedElementById("condition").offsetHeight;

      // レイアウトコントローラーエリアのみmarginTopが設定されている。別途取得し、conditionエリアを開いている時はmarginTopを加算
      const layoutControllerEl = this.getScopedElementById("layout-controller");
      const layoutControllerMarginTop = this.isSmallHeader ? 0 : parseInt(this.getScopedComputedStyle(layoutControllerEl)?.marginTop || 0);
      const layoutControllerHeight = layoutControllerEl.offsetHeight + layoutControllerMarginTop;

      const itemBoxConfHeight = this.getScopedElementById("item-box-conf").offsetHeight;

      let configBedLayoutMaxHeight = this.getScopedElementById("configBedLayoutId")?.style?.minHeight || "";
      // conditionエリアは閉じているか
      if (this.isSmallHeader) {
        // 計算式：this.formConfigAreaHeight－conditionエリアのoffsetHeight－レイアウトコントローラーエリアのoffsetHeight(marginTop含まない)－itemBoxConfエリアのoffsetHeight
        configBedLayoutMaxHeight = 
          this.formConfigAreaHeight - conditionHeight - layoutControllerHeight - itemBoxConfHeight;
      } else {
        // 計算式：this.formHeight－conditionエリアのoffsetHeight－レイアウトコントローラーエリアのoffsetHeight(marginTop含む)－itemBoxConfエリアのoffsetHeight
        configBedLayoutMaxHeight = 
          this.formHeight - conditionHeight - layoutControllerHeight - itemBoxConfHeight;
      }

      this.getScopedElementById("configBedLayoutId").style.maxHeight = configBedLayoutMaxHeight + "px";
    },

    /**
     * ベッド削除
     */
    deleteBed(placedBed) {
      if (!placedBed) {
        return;
      }
      this.setIsChange(true);
      const orderNo = this.resolveDispOrderNo(placedBed);
      let gridDelIdx = -1;
      if (orderNo != null) {
        this.delIdx = this.placedList.findIndex(
          dat => String(dat.disp_order_no) === String(orderNo)
        );
        gridDelIdx = this.inputData.gridPlacementList.findIndex(
          dat => String(dat.i) === String(orderNo)
        );
      } else {
        this.delIdx = this.placedList.findIndex(
          dat =>
            dat.machine_no === placedBed.machine_no &&
            dat.bed_cd === placedBed.bed_cd
        );
        gridDelIdx = this.inputData.gridPlacementList.findIndex(
          dat =>
            dat.mstBed?.machine_no === placedBed.machine_no &&
            dat.mstBed?.bed_cd === placedBed.bed_cd
        );
      }
      if (this.delIdx >= 0) {
        this.inputData.obj_list.splice(this.delIdx, 1);
        if (gridDelIdx >= 0) {
          this.inputData.gridPlacementList.splice(gridDelIdx, 1);
        }
        let blnSelect = false;
        for (let i = 0; i < this.inputData.obj_list.length + 1; i++) {
          if (this.inputData.obj_list[this.delIdx] === undefined) {
            this.delIdx = this.delIdx - 1;
          } else {
            this.selectedPlacedBedKey = this.getPlacedBedKey(
              this.inputData.obj_list[this.delIdx]
            );
            blnSelect = true;
            break;
          }
        }
        if (!blnSelect) {
          this.selectedPlacedBedKey = null;
        }
      }
    },
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    placementBed(bed, layout) {
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
      // console.log("placementBed/bed is %o.", bed);
      // 配置済みベッドの並べ替えを実施
      let tmpObj = deepCopy(this.inputData.obj_list);
      tmpObj.push(bed);
      tmpObj.sort((a, b) => (a.sortNo > b.sortNo ? 1 : -1));
      this.inputData.obj_list = tmpObj;
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
      if (this.type == undefined) {
          this.inputData.gridPlacementList.push({
          mstBed: bed,
          name: bed.name,
          w: bed.width / this.GRID_SIZE,
          h: bed.height / this.GRID_SIZE,
          x: bed.left / this.GRID_SIZE,
          y: bed.top / this.GRID_SIZE,
          i: String(bed.disp_order_no),
          selected: false
        });
      } else {
        this.inputData.gridPlacementList = []
        layout.forEach((item) => {
          this.inputData.gridPlacementList.push({
            mstBed: item,
            name: item.name,
            w: item.width / this.GRID_SIZE,
            h: item.height / this.GRID_SIZE,
            x: item.left / this.GRID_SIZE,
            y: item.top / this.GRID_SIZE,
            i: String(item.disp_order_no),
            selected: false
          });
        })
      }
      // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
    },
    /**
     * ベッド追加
     */
    insertBed(notPlacedBed, width, height) {
      // console.log("insertBed/notPlacedBed is %o.", notPlacedBed);
      if (this.isHomeDialysis) {
        this.insIdx = this.notPlacedListAtHome.findIndex(
          dat =>
            dat.machineNo === notPlacedBed.machineNo &&
            dat.bedCd === notPlacedBed.bedCd
        );
      } else {
        this.insIdx = this.notPlacedList.findIndex(
          dat =>
            dat.machineNo === notPlacedBed.machineNo &&
            dat.bedCd === notPlacedBed.bedCd
        );
      }
      //
      let newOrderNo;
      if (this.placedList[0]) {
        newOrderNo =
          this.placedList
            .map(dat => dat.disp_order_no)
            .reduce((a, b) => (a > b ? a : b)) + 1;
      } else {
        newOrderNo = 1;
      }
      //
      const addBed = {
        mstBed: notPlacedBed,
        machine_no: notPlacedBed.machineNo,
        bed_cd: notPlacedBed.bedCd,
        name: notPlacedBed.name,
        width: width,
        height: height,
        top: notPlacedBed.top ? notPlacedBed.top : 20,
        left: notPlacedBed.left ? notPlacedBed.left : 20,
        disp_order_no: newOrderNo,
        sortNo: notPlacedBed.sortNo
      };
      this.placementBed(addBed);
      //this.selectedNotPlacedBed = null;
      this.setIsChange(true);
    },
    insertSideBed(notPlacedBed) {
      this.insertBed(notPlacedBed, 160, 120);
    },
    insertVerticalBed(notPlacedBed) {
      this.insertBed(notPlacedBed, 160, 200);
    },
    insertMachine(notPlacedBed) {
      this.insertBed(notPlacedBed, 160, 160);
    },
    insertHomeBed(notPlacedBed) {
      this.insertBed(notPlacedBed, 40, 40);
    },
    changeHeaderMode() {
      this.isSmallHeader = !this.isSmallHeader;
      this.$nextTick(() => {
        // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng start
        setTimeout(()=>{
        // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng end  
          this.changeAdjustBtnSize();
          this.calculateHeight();
        // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng start  
        })
        // #10348 ベッドレイアウトマスタでの編集動作が不正 linjunfeng end
      });

    },
    /**
     * 画面上のレイアウト情報のクリア
     */
    clearBedLayout() {
      this.setIsChange(true);
      this.clearBackgroundImage();
      this.resetCanvasSize();
      this.inputData.obj_list.splice(0, this.inputData.obj_list.length);
      this.inputData.gridPlacementList.splice(
        0,
        this.inputData.gridPlacementList.length
      );
    },
    setBedLayout(bedLayout) {
      if (bedLayout.bedLayout !== "" && bedLayout.bedLayout !== null) {
        const layout = JSON.parse(bedLayout.bedLayout);
        // console.log("setBedLayout/layout is %o.", layout);
        this.inputData.canvas_size.width = layout.canvas_size.width;
        this.inputData.canvas_size.height = layout.canvas_size.height;
        layout.obj_list.forEach(element => {
          const tmpBedObj = this.getMachineAndBedList.find(
            dat =>
              dat.machineNo === element.machine_no &&
              dat.bedCd === element.bed_cd
          );
          // add #8118 2022/11/24 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou start
          if (tmpBedObj) {
          // add #8118 2022/11/24 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou end
            element.mstBed = tmpBedObj;
            element.sortNo = tmpBedObj.sortNo;
            // add #8118 2022/12/07 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou start
          }
          // add #8118 2022/12/07 装置マスタから装置を削除すると治療状況ベッドレイアウトマスタが編集不可 dou end
          // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
          this.placementBed(element, layout.obj_list);
          // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
        });
        this.applyCanvasSizeChange();
        this.inputData.backgroundImage = bedLayout.backgroundImage;
      }
    },
    validateRegData() {
      let isError = false;
      let message = "";

      // レイアウト名チェック
      if (this.inputData.name.length === 0) {
        isError = true;
        this.getScopedClassElement("custom-input-required")?.classList?.add("custom-input-invalid");
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "<div>・レイアウト名が入力されていません</div>";
        message = `<div>${messageFormat(DIALOG_MESSAGES[12000130].message)}</div>`;
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      } else if (this.inputData.name.length > 20) {
        isError = true;
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "<div>・レイアウト名は最大20文字まで入力可能です</div>";
        message = `<div>${messageFormat(DIALOG_MESSAGES[12000131].message)}</div>`;
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }

      // 装置台数チェック
      if (this.inputData.obj_list.length === 0) {
        isError = true;
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = `${message}<div>・装置が一台も配置されていません</div>`;
        message = `${message}<div>${messageFormat(DIALOG_MESSAGES[12000132].message)}</div>`;
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }

      // レイアウトサイズチェック
      const checkMaxMinWidth = num => num > this.canvasMaxWidth || num < 0;
      if (checkMaxMinWidth(this.inputData.canvas_size.width)) {
        isError = true;
        message = `${message}<div>・レイアウトサイズの幅が0～9999の範囲外です</div>`;
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = `${message}<div>・レイアウトサイズの幅が0～9999の範囲外です</div>`;
        message = `${message}<div>${messageFormat(DIALOG_MESSAGES[12000133].message)}</div>`;
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      const checkMaxMinHeight = num => num > this.canvasMaxHeight || num < 0;
      if (checkMaxMinHeight(this.inputData.canvas_size.height)) {
        isError = true;
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = `${message}<div>・レイアウトサイズの高さが0～9999の範囲外です</div>`;
        message = `${message}<div>${messageFormat(DIALOG_MESSAGES[12000134].message)}</div>`;
        // add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }

      return { hasError: isError, message: message };
    },
    async registration() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // データチェック
      const checkResult = this.validateRegData();
      if (checkResult.hasError) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "データチェック",
          title: DIALOG_MESSAGES[12000130].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: checkResult.message
        });
        return;
      } else {
        // mod #12658 【securify】SQLインジェクション(High) ユーザフロートボタンメニュー zrx start
        try {
          const bedLayout = {
            layoutId: this.inputData.code,
            // add マスタ一覧 施設切替を可能とする 王 start
            // facilityCd: this.getFacilityCd,
            facilityCd: this.getFacilitySwitch,
            // add マスタ一覧 施設切替を可能とする 王 end
            layoutName: this.inputData.name,
            bedLayout: JSON.stringify({
              canvas_size: {
                width: this.inputData.canvas_size.width,
                height: this.inputData.canvas_size.height
              },
              obj_list: this.gridPlacementList.map(dat => {
                const machine = this.getMachineList.find(
                  machine => machine.machineNo === dat.mstBed.machine_no
                );
                return {
                  is_home_dialysis: this.isHomeDialysis ? "1" : "0",
                  machine_type_cd: machine ? machine.machineTypeCd : "",
                  machine_serial: machine ? machine.machineSerial : "",
                  model: machine ? this.getModel(machine.machineTypeCd) : "",
                  machine_no: dat.mstBed.machine_no,
                  bed_cd: dat.mstBed.bed_cd,
                  top: dat.y * this.GRID_SIZE,
                  left: dat.x * this.GRID_SIZE,
                  name: dat.name,
                  width: dat.w * this.GRID_SIZE,
                  height: dat.h * this.GRID_SIZE,
                  disp_order_no: dat.i
                };
              })
            }),
            backgroundImage: this.inputData.backgroundImage,
            isHomeDialysis: this.isHomeDialysis ? "1" : "0",
            isDel: "0",
            isDisp: "1"
          };
          const result = await this.registrationBedLayout(bedLayout);
          // await console.log(result);
          this.setBedLayout;
          // リザルトメッセージ
          let message = "";
          switch (result) {
            case 0: {
              this.setIsChange(false);
              break;
            }
            case 1: {
              this.setIsChange(false);
              break;
            }
            case -1: {
              message = {
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "登録失敗",
                // message:
                //   "他のユーザーによって既に更新されています。</br>治療状況ベッドレイアウトを登録できませんでした。"
                title: DIALOG_MESSAGES[12000135].title,
                message: messageFormat(DIALOG_MESSAGES[12000135].message)
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              };
              break;
            }
            default: {
              message = {
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "登録失敗",
                // message: "治療状況ベッドレイアウトを登録できませんでした。"
                title: DIALOG_MESSAGES[12000136].title,
                message: messageFormat(DIALOG_MESSAGES[12000136].message)
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              };
              break;
            }
          }
          this.updateEditRecord("name", this.inputData.name);
          const masterRecordList = this.getMasterRecordList;
          // state.editRecordを取得
          const editRecord = this.editRecord;
          // operationがないときは編集とみなす
          if (!editRecord.operation) {
            editRecord.operation = 2;
          } else if (editRecord.operation === 1) {
            // "追加"の場合は、"編集済"フラグを立てる
            editRecord.edited = true;
          }
          // state.masterRecordListにマージ
          const index = masterRecordList.data.findIndex(
            masterRecord => masterRecord.code === editRecord.code
          );
          masterRecordList.data[index] = editRecord;
          // TODO: 共通マスメン側で修正するかも？
          this.setMasterRecordList(undefined);
          this.setMasterRecordList(masterRecordList);

          // state.editRecordを空にする
          this.editRecordBeEmpty();
          // 治療状況ベド・レイ・ウットマスタ：保存後のポップアップ提示なし 関　start
          this.$ons.notification.alert({
              title: DIALOG_MESSAGES[12000004].title,
              message: messageFormat(DIALOG_MESSAGES[12000004].message),
            });
          // 治療状況ベド・レイ・ウットマスタ：保存後のポップアップ提示なし 関　end
          if (message !== "") {
            this.$ons.notification.alert(message);
          } else {
            // mod #8119 2022/11/24 治療状況ベッドレイアウトマスタのパンくずリストが消える dou start
            // this.$router.go(-1);
            this.cancel();
            // mod #8119 2022/11/24 治療状況ベッドレイアウトマスタのパンくずリストが消える dou end
          }
        } catch (error) {
          getErrorMessage(
            "IndividualMasterComponentMstStatusMapBedLayout.vue",
            "registration",
            error
          );
          // registration 先頭の true と postWithLoader のカウンタずれを収束
          this.resetLoadingScreenVisibleCount();
        } finally {
          // 例外時も registration 先頭で付けたローダーを必ず閉じる
          this.setLoadingScreenVisible(false);
        }
        // mod #12658 【securify】SQLインジェクション(High) ユーザフロートボタンメニュー zrx end
      }
    },
    cancel() {
      // mod #8119 2022/11/24 治療状況ベッドレイアウトマスタのパンくずリストが消える dou start
      // this.$router.go(-1);
      this.$router.push({ name: "individual-master" });
      // mod #8119 2022/11/24 治療状況ベッドレイアウトマスタのパンくずリストが消える dou end
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$route.name
          && getScopedAlertDialogs(this.$el || this).length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                // state.editRecordを空にする
                this.editRecordBeEmpty();
                this.dataLoad();
              }
            }
          });
        } else {
          // state.editRecordを空にする
          this.editRecordBeEmpty();
          // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
          this.dataLoad('refresh');
          // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
        }
      }
    },
    async setBackgroundImage(e) {
      this.setIsChange(true);
      // console.log("setBackgroundImage/e.targer is %o", e.target);
      e.preventDefault();
      const fr = new FileReader();
      fr.onload = () => {
        this.inputData.backgroundImage = fr.result;
        e.target.value = "";
        this.setWidthHeight(fr.result);
      };
      fr.readAsDataURL(e.target.files[0]);

    },
    // 治療状況ベッドレイアウトマスタ DU Start
    async setCssStyle(e) {
      // console.log("setBackgroundImage/e.targer is %o", e.target );
      e.preventDefault();
      const fr = new FileReader();
      fr.onload = () => {
        this.cssText = fr.result+Math.random();
      };
      fr.readAsText(e.target.files[0]);
      this.getScopedElementById("cssFileElem").value=null;
    },
    deleteStyle() {
      // console.log(e);
      // console.log(this.gridPlacementList);
      // #9771 CSSスタイル削除 一部だけ削除します linjunfeng start
      // this.gridPlacementList.forEach(e =>{
      //   this.deleteBed(e.mstBed)
      // })
      this.inputData.obj_list.splice(0, this.inputData.obj_list.length);
      this.inputData.gridPlacementList.splice(
        0,
        this.inputData.gridPlacementList.length
      );
      // #9771 CSSスタイル削除 一部だけ削除します linjunfeng end
    },
    // 治療状況ベッドレイアウトマスタ DU End
    setWidthHeight(imageData) {
      const image = new Image();
      // #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start
      // let self = this;
      // image.onload = () => {
      //   const result = {
      //     width: image.naturalWidth,
      //     height: image.naturalHeight
      //   };
      //   self.inputData.canvas_size.width = result.width;
      //   self.inputData.canvas_size.height = result.height;
      // };
      // #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end
      image.src = imageData;
    },
    clearBackgroundImage() {
      this.inputData.backgroundImage = null;
    },
    // ベッド操作
    /**
     * 装置の場所を保持
     */
    keepPlace(machine) {
      this.setIsChange(true);
      this.druggingMachinePlace = {
        x: machine.x,
        y: machine.y
      };

    },
    /**
     * 選択状態反転
     */
    switchMachineSelectionState(machine) {
      this.setIsChange(true);
      if (
        this.druggingMachinePlace &&
        this.druggingMachinePlace.x === machine.x &&
        this.druggingMachinePlace.y === machine.y
      ) {
        machine.selected = !machine.selected;
      }
      this.druggingMachinePlace = null;
    },
    /**
     * ベッドサイズを大に
     */
    setLargeSizeSelectedMachine() {
      this.setSizeSelectedMachine(LARGE_SIZE);
    },
    /**
     * ベッドサイズを中に
     */
    setMiddleSizeSelectedMachine() {
      this.setSizeSelectedMachine(MIDDLE_SIZE);
    },
    /**
     * ベッドサイズを小に
     */
    setSmallSizeSelectedMachine() {
      this.setSizeSelectedMachine(SMALL_SIZE);
    },
    /**
     * 選択中のベッドサイズを変更
     */
    setSizeSelectedMachine(size) {
      if (!this.selectedMachineList.length) {
        return;
      }
      this.selectedMachineList.forEach(machine => {
        this.setSize(machine, size);
      });
      this.refreshGridPlacementFromState();
    },
    /**
     * 選択中のベッドを縦横入れ替え
     */
    rotateSelectedMachine() {
      if (!this.selectedMachineList.length) {
        return;
      }
      this.selectedMachineList.forEach(machine => {
        this.setSize(machine, {
          width: machine.h * this.GRID_SIZE,
          height: machine.w * this.GRID_SIZE
        });
      });
      this.commitGridPlacementList();
    },
    /**
     * 選択中のベッドを横向きに
     */
    sidewaySelectedMachine() {
      if (!this.selectedMachineList.length) {
        return;
      }
      this.selectedMachineList.forEach(machine => {
        if (machine.h >= machine.w) {
          this.setSize(machine, {
            width: machine.h * this.GRID_SIZE,
            height: machine.w * this.GRID_SIZE
          });
        }
      });
      this.commitGridPlacementList();
    },
    /**
     * 選択中のベッドを縦向きに
     */
    verticalSelectedMachine() {
      if (!this.selectedMachineList.length) {
        return;
      }
      this.selectedMachineList.forEach(machine => {
        if (machine.h <= machine.w) {
          this.setSize(machine, {
            width: machine.h * this.GRID_SIZE,
            height: machine.w * this.GRID_SIZE
          });
        }
      });
      this.commitGridPlacementList();
    },
    /**
     * 選択中装置の垂直方向の間隔を減らす
     */
    // #9863 Error in v-on handler: "TypeError: Cannot read properties of undefined (reading 'x、y、w、h')" 横展開2 linjunfeng start
    // getMachineX: machine => machine.x,
    // setMachineX: (machine, value) => (machine.x = value),
    // getMachineWidth: machine => machine.w,
    // getMachineY: machine => machine.y,
    // setMachineY: (machine, value) => (machine.y = value),
    // getMachineHeight: machine => machine.h,
    getMachineX: machine => machine?.x,
    setMachineX(machine, value) {
      machine.x = value;
      this.syncObjListFromGridItem(machine);
    },
    getMachineWidth: machine => machine?.w,
    getMachineY: machine => machine?.y,
    setMachineY(machine, value) {
      machine.y = value;
      this.syncObjListFromGridItem(machine);
    },
    getMachineHeight: machine => machine?.h,
    // #9863 Error in v-on handler: "TypeError: Cannot read properties of undefined (reading 'x、y、w、h')" 横展開2 linjunfeng end
    compareMachinePos(getPos, a, b) {
      if (getPos(a) !== getPos(b)) {
        return getPos(a) - getPos(b);
      } else {
        return a.i - b.i;
      }
    },
    reduceVerticalGapSelectedMachine() {
      this.reduceGapSelectedMachine(this.getMachineY, this.setMachineY);
    },
    /**
     * 選択中装置の水平方向の間隔を減らす
     */
    reduceHorizontalGapSelectedMachine() {
      this.reduceGapSelectedMachine(this.getMachineX, this.setMachineX);
    },
    /**
     * 選択中装置の水平方向の間隔をゼロにする
     */
    clearHorizontalGapSelectedMachine() {
      this.clearGapSelectedMachine(
        this.getMachineX,
        this.getMachineWidth,
        this.setMachineX
      );
    },
    /**
     * 選択中装置の垂直方向の間隔をゼロにする
     */
    clearVerticalGapSelectedMachine() {
      this.clearGapSelectedMachine(
        this.getMachineY,
        this.getMachineHeight,
        this.setMachineY
      );
    },
    /**
     * 選択中装置の垂直方向の間隔を増やす
     */
    increaseVerticalGapSelectedMachine() {
      this.increaseGapSelectedMachine(
        this.getCanvasSize.height / this.GRID_SIZE,
        this.getMachineY,
        this.getMachineHeight,
        this.setMachineY
      );
    },
    /**
     * 選択中装置の水平方向の間隔を増やす
     */
    increaseHorizontalGapSelectedMachine() {
      this.increaseGapSelectedMachine(
        this.getCanvasSize.width / this.GRID_SIZE,
        this.getMachineX,
        this.getMachineWidth,
        this.setMachineX
      );
    },
    /**
     * 選択中装置を垂直方向に等間隔で配置する
     */
    setEqualIntervalVerticalSelectedMachine() {
      this.setEqualIntervalSelectedMachine(
        this.getMachineY,
        this.getMachineHeight,
        this.setMachineY
      );
    },
    /**
     * 選択中装置を水平方向に等間隔で配置する
     */
    setEqualIntervalHorizontalSelectedMachine() {
      this.setEqualIntervalSelectedMachine(
        this.getMachineX,
        this.getMachineWidth,
        this.setMachineX
      );
    },
    /**
     * 選択中装置を左端揃え
     */
    leftAlignSelectedMachine() {
      const alignComp = (a, b) => {
        const aX = this.getMachineX(a);
        const bX = this.getMachineX(b);
        if (aX !== bX) {
          return bX - aX;
        } else {
          return a.i - b.i;
        }
      };
      this.setAlignPosSelectedMachine(
        this.getCanvasSize.width / this.GRID_SIZE,
        this.getMachineX,
        this.getMachineWidth,
        this.getMachineX,
        this.setMachineX,
        alignComp
      );
    },
    /**
     * 選択中装置を右揃え
     */
    rightAlignSelectedMachine() {
      const getAlignPoint = machine =>
        this.getMachineX(machine) + this.getMachineWidth(machine);
      const alignComp = (a, b) => {
        const aX = getAlignPoint(a);
        const bX = getAlignPoint(b);
        if (aX !== bX) {
          return aX - bX;
        } else {
          return a.i - b.i;
        }
      };
      this.setAlignPosSelectedMachine(
        this.getCanvasSize.width / this.GRID_SIZE,
        this.getMachineX,
        this.getMachineWidth,
        getAlignPoint,
        this.setMachineX,
        alignComp
      );
    },
    /**
     * 選択中装置を左右中央揃え
     */
    horizonCenterAlignSelectedMachine() {
      const getAlignPoint = machine =>
        this.getMachineX(machine) +
        Math.round(this.getMachineWidth(machine) / 2);
      const alignComp = (a, b) => {
        return a.i - b.i;
      };
      this.setAlignPosSelectedMachine(
        this.getCanvasSize.width / this.GRID_SIZE,
        this.getMachineX,
        this.getMachineWidth,
        getAlignPoint,
        this.setMachineX,
        alignComp
      );
    },
    /**
     * 選択中装置を上端揃え
     */
    topAlignSelectedMachine() {
      const alignComp = (a, b) => {
        const aY = this.getMachineY(a);
        const bY = this.getMachineY(b);
        if (aY !== bY) {
          return bY - aY;
        } else {
          return a.i - b.i;
        }
      };
      this.setAlignPosSelectedMachine(
        this.getCanvasSize.height / this.GRID_SIZE,
        this.getMachineY,
        this.getMachineHeight,
        this.getMachineY,
        this.setMachineY,
        alignComp
      );
    },
    /**
     * 選択中装置を下端揃え
     */
    bottomAlignSelectedMachine() {
      const getAlignPoint = machine =>
        this.getMachineY(machine) + this.getMachineHeight(machine);
      const alignComp = (a, b) => {
        const aY = getAlignPoint(a);
        const bY = getAlignPoint(b);
        if (aY !== bY) {
          return aY - bY;
        } else {
          return a.i - b.i;
        }
      };
      this.setAlignPosSelectedMachine(
        this.getCanvasSize.height / this.GRID_SIZE,
        this.getMachineY,
        this.getMachineHeight,
        getAlignPoint,
        this.setMachineY,
        alignComp
      );
    },
    /**
     * 選択中装置を上下中央揃え
     */
    verticalCenterAlignSelectedMachine() {
      const getAlignPoint = machine =>
        this.getMachineY(machine) +
        Math.round(this.getMachineHeight(machine) / 2);
      const alignComp = (a, b) => {
        return a.i - b.i;
      };
      this.setAlignPosSelectedMachine(
        this.getCanvasSize.height / this.GRID_SIZE,
        this.getMachineY,
        this.getMachineHeight,
        getAlignPoint,
        this.setMachineY,
        alignComp
      );
    },

    /**
     * 選択中の装置の間隔を減らす
     * ※水平/垂直は引数にした関数で決定
     */
    reduceGapSelectedMachine(getPos, setPos) {
      if (!this.selectedMachineList.length) {
        return;
      }
      let moveLength = 0;
      this.selectedMachineList
        .sort((a, b) => this.compareMachinePos(getPos, a, b))
        .forEach((machine, idx, array) => {
          if (idx !== 0 && getPos(array[idx - 1]) !== getPos(machine)) {
            // 原点方向に最も近い装置との間隔がゼロでない場合間隔を詰める
            setPos(
              machine,
              this.getReduceGapPos(
                getPos(array[idx - 1]),
                getPos(machine),
                ++moveLength
              )
            );
          }
        });
      this.commitGridPlacementList();
      this.setIsChange(true);
    },
    /**
     * 選択中の装置の間隔を増やす
     * ※水平/垂直は引数にした関数で決定
     */
    increaseGapSelectedMachine(fieldSize, getPos, getSize, setPos) {
      if (!this.selectedMachineList.length) {
        return;
      }
      let moveLength = 0;
      this.selectedMachineList
        .sort((a, b) => this.compareMachinePos(getPos, a, b))
        .forEach((machine, idx) => {
          if (idx !== 0 && fieldSize !== getPos(machine) + getSize(machine)) {
            moveLength++;
            setPos(
              machine,
              this.getIncreaseGapPos(
                fieldSize,
                getPos(machine),
                getSize(machine),
                moveLength
              )
            );
          }
        });
      this.commitGridPlacementList();
      this.setIsChange(true);
    },
    /**
     * 選択中の装置の間隔をゼロにする
     * ※水平/垂直は引数にした関数で決定
     */
    clearGapSelectedMachine(getPos, getSize, setPos) {
      if (!this.selectedMachineList.length) {
        return;
      }
      this.selectedMachineList
        .sort((a, b) => this.compareMachinePos(getPos, a, b))
        .forEach((machine, idx, array) => {
          if (idx !== 0) {
            // 原点方向に最も近い装置との間隔がゼロでない場合間隔を詰める
            setPos(machine, getPos(array[idx - 1]) + getSize(array[idx - 1]));
          }
        });
      this.commitGridPlacementList();
      this.setIsChange(true);
    },
    /**
     * 選択中装置を等間隔に配置する
     * ※水平/垂直は引数にした関数で決定
     */
    setEqualIntervalSelectedMachine(getPos, getSize, setPos) {
      if (this.selectedMachineList.length > 1) {
        // 選択中装置の両端座標
        const edgePos = this.selectedMachineList.reduce(
          (edge, machine) => ({
            max:
              edge.max < getPos(machine) + getSize(machine)
                ? getPos(machine) + getSize(machine)
                : edge.max,
            min: edge.min > getPos(machine) ? getPos(machine) : edge.min
          }),
          {
            max: 0,
            min: getPos(this.selectedMachineList[0])
          }
        );
        const machineSizeSum = this.selectedMachineList.reduce(
          (sum, machine) => sum + getSize(machine),
          0
        );
        const interval = Math.floor(
          (edgePos.max - edgePos.min - machineSizeSum) /
            (this.selectedMachineList.length - 1)
        );
        this.selectedMachineList
          .sort((a, b) => this.compareMachinePos(getPos, a, b))
          .forEach((machine, idx, array) => {
            if (idx !== 0) {
              setPos(
                machine,
                this.getEqualIntervalPos(
                  edgePos.max,
                  getPos(array[idx - 1]) + getSize(array[idx - 1]),
                  getSize(machine),
                  interval
                )
              );
            }
          });
        this.commitGridPlacementList();
        this.setIsChange(true);
      }
    },

    /**
     * 選択中装置を上下左右中央揃えする
     * 揃え位置は引数にした関数で決定
     */
    setAlignPosSelectedMachine(
      fieldSize,
      getPos,
      getSize,
      getAlignPoint,
      setPos,
      alignComp
    ) {
      if (!this.selectedMachineList.length) {
        return;
      }
      // 揃える基準の装置を取得
      const alignMachine = this.selectedMachineList.reduce(
        (acc, machine) => (alignComp(acc, machine) > 0 ? acc : machine),
        this.selectedMachineList[0]
      );
      // 揃える基準位置を取得
      const alignPoint = getAlignPoint(alignMachine);
      this.selectedMachineList.forEach(machine => {
        setPos(
          machine,
          this.getAlignPos(
            fieldSize,
            alignPoint,
            getPos(machine),
            getSize(machine),
            getAlignPoint(machine)
          )
        );
      });
      this.commitGridPlacementList();
      this.setIsChange(true);
    },

    /**
     * 間隔を詰めた後の座標を取得
     */
    getReduceGapPos(prevPos, currentPos, moveLength) {
      if (prevPos !== currentPos) {
        if (prevPos > currentPos - moveLength) {
          return prevPos;
        } else {
          return currentPos - moveLength;
        }
      } else {
        return currentPos;
      }
    },
    /**
     * 間隔を広げた後の座標を取得
     */
    getIncreaseGapPos(fieldSize, currentPos, currentSize, moveLength) {
      if (fieldSize < currentPos + currentSize + moveLength) {
        return fieldSize - currentSize;
      } else {
        return currentPos + moveLength;
      }
    },
    /**
     * 等間隔に配置した場合の座標を取得
     */
    getEqualIntervalPos(fieldSize, prevEdge, currentSize, interval) {
      if (fieldSize < prevEdge + interval + currentSize) {
        // はみ出す場合は端に置く
        return fieldSize - currentSize;
      } else {
        return prevEdge + interval;
      }
    },
    /**
     * 上下左右中央よせした場合の座標を取得
     */
    getAlignPos(
      fieldSize,
      alignPoint,
      currentPos,
      currentSize,
      currentAlignPoint
    ) {
      const alignPos = currentPos + (alignPoint - currentAlignPoint);
      if (0 > alignPos) {
        return 0;
      } else if (fieldSize < alignPos) {
        return fieldSize - currentSize;
      } else {
        return alignPos;
      }
    },

    /**
     * ベッドサイズを変更
     */
    setSize(machine, size) {
      const pixelWidth = Number(size.width);
      const pixelHeight = Number(size.height);
      machine.w = pixelWidth / this.GRID_SIZE;
      machine.h = pixelHeight / this.GRID_SIZE;
      if (machine.mstBed) {
        machine.mstBed.width = pixelWidth;
        machine.mstBed.height = pixelHeight;
      }
      this.syncObjListFromGridItem(machine);
      this.setIsChange(true);
    },
    syncObjListFromGridItem(gridItem) {
      const bed = gridItem?.mstBed;
      if (!bed) {
        return;
      }
      const orderNo = gridItem.i ?? bed.disp_order_no;
      let obj = this.inputData.obj_list.find(
        dat => String(dat.disp_order_no) === String(orderNo)
      );
      if (!obj) {
        obj = this.inputData.obj_list.find(
          dat =>
            dat.machine_no === bed.machine_no && dat.bed_cd === bed.bed_cd
        );
      }
      if (!obj) {
        return;
      }
      obj.width = gridItem.w * this.GRID_SIZE;
      obj.height = gridItem.h * this.GRID_SIZE;
      obj.top = gridItem.y * this.GRID_SIZE;
      obj.left = gridItem.x * this.GRID_SIZE;
    },
    resolveNumberInputElement(ev) {
      const candidate = ev?.target ?? ev;
      if (!candidate) {
        return null;
      }
      if (candidate.validity != null) {
        return candidate;
      }
      if (typeof candidate.querySelector === "function") {
        return candidate.querySelector("input") || candidate;
      }
      return candidate;
    },
    onCanvasWidth(ev) {
      const input = this.resolveNumberInputElement(ev);
      if (input?.validity?.badInput) {
        this.getCanvasSize.width = 0;
        return;
      }
      const value = Number(input?.value ?? this.getCanvasSize.width);
      this.getCanvasSize.width = value;
      this.setIsChange(true);
      if (this.canvasMaxWidth < value) {
        this.getCanvasSize.width = this.canvasMaxWidth;
      }
      if (this.canvasMinWidth > value) {
        this.getCanvasSize.width = this.canvasMinWidth;
      }
    // mod #5589 2023/03/29 数値IFのスタイル全不正 張博 start
        // 数値範囲内かどうかの確認
      if (value > this.canvasMaxWidth) {
        this.getCanvasSize.width = this.canvasMinWidth;
        this.blurFlg=true;
      } else if (value < this.canvasMinWidth) {
        this.getCanvasSize.width = this.canvasMaxWidth;
        this.blurFlg=true;
      }else{
        this.blurFlg=false;
      }
      this.applyCanvasSizeChange();
    },
    mouseWheelWidth(e,index){
      if (!this.focusFlg[index]) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
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
      if (value > this.canvasMaxWidth) {
        value = this.canvasMinWidth;
      }
      if(value < this.canvasMinWidth) {
        value = this.canvasMaxWidth;
      }
      this.getCanvasSize.width = value
      this.setIsChange(true)
      this.applyCanvasSizeChange();

    },
    // mod #5589 2023/03/29 数値IFのスタイル全不正 張博 end
    onCanvasHeight(ev) {
      const input = this.resolveNumberInputElement(ev);
      if (input?.validity?.badInput) {
        this.getCanvasSize.height = 0;
        return;
      }
      const value = Number(input?.value ?? this.getCanvasSize.height);
      this.setIsChange(true);
      this.getCanvasSize.height = value;
      if (this.canvasMaxHeight < value) {
        this.getCanvasSize.height = this.canvasMaxHeight;
      }
      if (this.canvasMinWidth > value) {
        this.getCanvasSize.height = this.canvasMinHeight;
      }
      // mod #5589 2023/03/29 数値IFのスタイル全不正 張博 start
        // 数値範囲内かどうかの確認
      if (value > this.canvasMaxHeight) {
        this.getCanvasSize.height = this.canvasMinHeight;
        this.blurFlg=true;
      } else if (value < this.canvasMinHeight) {
        this.getCanvasSize.height = this.canvasMaxHeight;
        this.blurFlg=true;
      }else{
        this.blurFlg=false;
      }
      this.applyCanvasSizeChange();
    },
    mouseWheelHeight(e,index){
      if (!this.focusFlg[index]) {
        return;
      }
      let delta = (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
                      (e.detail && (e.wheelDelta > 0 ? -1 : 1))
      if (!e.target.value) {
        e.target.value = 0
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
      if (value > this.canvasMaxHeight) {
        value = this.canvasMinHeight;
      }
      if(value < this.canvasMinHeight) {
        value = this.canvasMaxHeight;
      }
      this.getCanvasSize.height = value
      this.setIsChange(true)
      this.applyCanvasSizeChange()
    },
    formatValueWidth(event,index){
      // 限界値判定
      let value = event.target.value;
      if (value == this.canvasMaxWidth && this.blurFlg) {
        this.getCanvasSize.width = this.canvasMinWidth;
        this.blurFlg = false;
      }else if (value == this.canvasMinWidth && this.blurFlg) {
        this.getCanvasSize.width = this.canvasMaxWidth;
        this.blurFlg = false;
      }
      this.focusFlg[index]=false;
      this.requestViewForceUpdate();
    },
    formatValueHeight(event,index){
      // 限界値判定
      let value = event.target.value;
      if (value == this.canvasMaxHeight && this.blurFlg) {
        this.getCanvasSize.height = this.canvasMinHeight;
        this.blurFlg = false;
      }else if (value == this.canvasMinHeight && this.blurFlg) {
        this.getCanvasSize.height = this.canvasMaxHeight;
        this.blurFlg = false;
      }
      this.focusFlg[index]=false;
      this.requestViewForceUpdate();
    },
    handleFocus(index){
      this.focusFlg[index]=true;
    },
    // mod #5589 2023/03/29 数値IFのスタイル全不正 張博 end
    selectedRowNotPlaced(machineAndBedList) {
      const listSize = machineAndBedList.length;
      if (listSize === 0) {
        this.selectedNotPlacedBedKey = null;
      }
      for (let i = 0; i <= listSize; i++) {
        if (machineAndBedList[this.insIdx] === undefined) {
          this.insIdx = this.insIdx - 1;
        } else {
          this.selectedNotPlacedBedKey = this.getNotPlacedBedKey(
            machineAndBedList[this.insIdx]
          );
          break;
        }
      }
    },
    setIsChange(value) {
      this.isChanged = value;
      this.$emit("change", value);
    },
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 start
    async dataLoad(type) {
      this.type = type
    // #8029 観察記録詳細のパンくずリストを押下しても最新データを表示せず、観察記録詳細を開いた時点のデータを表示する。横展開 訾浩 end
      await this.initialize();
      await this.selectBedLayout({
        // add マスタ一覧 施設切替を可能とする 王 start
        // facilityCd: this.getFacilityCd,
        facilityCd: this.getFacilitySwitch,
        // add マスタ一覧 施設切替を可能とする 王 start
        layoutId: this.inputData.code
      });
      // #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start
      // 操作卓エラーです layoutName undefined
      // this.inputData.name = this.getBedLayout.layoutName
      this.inputData.name = this.getBedLayout ? this.getBedLayout.layoutName : ""
      // #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end
      if (this.getBedLayout) {
        this.setBedLayout(this.getBedLayout);
        this.isHomeDialysis = this.getBedLayout.isHomeDialysis == "1";
      }
    },
    // フォントサイズ変更時のレイアウト調整ボタンのサイズ変更
    changeAdjustBtnSize() {
      const scoped$ = getScopedJQuery(this.$el || this) || $;
      const setAdjustSize = (buttonSize, imageSize) => {
        scoped$(".adjust-btn").css("width", buttonSize);
        scoped$(".adjust-btn").css("height", buttonSize);
        scoped$(".adjust-img").css("width", imageSize);
      };

      switch(this.getFontSize.toString()) {
        case "0":
          setAdjustSize("32px", "24px");
          break
        case "1":
          setAdjustSize("40px", "32px");
          break
        case "2":
          setAdjustSize("48px", "40px");
          break
        case "3":
          setAdjustSize("56px", "48px");
          break
      }
    },
    adjustBtnStyle(cd) {
      if (cd === "1" || (cd === "7" && this.isHomeDialysis)) {
        return {
          borderRadius: "5px 0 0 5px",
        }
      }
      else if (cd === "20") {
        return {
          borderRadius: "0 5px 5px 0",
        }
      }
      else {
        return {
          borderRadius: 0,
        }
      }
    },
    // 治療状況ベッドレイアウトマスタ DU Start
    cssFormat(){
      let csstext = this.cssText;
      // #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start
      //   let result = null;
      //   let n=0;
      //   let keyvalueList = [];
      //   let keyvalueListsize = [];
      //   let cssObject={};
      //   let cssObjectlist = [];   
      //   csstext = csstext.replace(/\n|\r|\t|px/g,"");
      //   for(let i = 0;i<csstext.length;i++){
      //     let item = csstext.charAt(i)
      //     switch (item) {
      //       case ".":
      //         n=i+1;
      //         break;
      //       case "{":
      //         result = csstext.substring(n,i);
      //         keyvalueList.push("name");
      //         keyvalueList.push(result);
      //         n = i+1;
      //         break;
      //         case ":":
      //         result = csstext.substring(n,i);
      //         keyvalueList.push(result);
      //         n = i+1;
      //         break;
      //         case " ":
      //         n=i+1
      //         break;
      //         case ";":
      //         result = csstext.substring(n,i);
      //         keyvalueList.push(result);
      //         n = i+1;
      //         break;
      //         case "}":
      //         n = i+1;
      //         keyvalueListsize.push(keyvalueList.length)
      //         break;
      //     }
      // }
      
      // for(let k = 0;k<keyvalueList.length;k+=2) {
      //   cssObject[keyvalueList[k]] = keyvalueList[k+1];

      //   if(keyvalueListsize.indexOf(k+2) != -1) {
      //       cssObjectlist.push(cssObject);
      //       cssObject= {};
      //    }
      //   }
      let cssObjectlist = [];
      csstext = csstext.split(/\n/);
      let obj = {};
      for(let item of csstext) {
        let str = item.replaceAll(/\n|\r|\t|px|;/g,"").trim();
        if (str === "" || str === "{") {
          continue;
        }
        if (str.charAt(0) === '.') {
          obj = {
            name : str.slice(1)
          }
          continue;
        }
        if (str.indexOf(':') > -1) {
          let key = str.slice(0, str.indexOf(':'));
          let value = str.slice(str.indexOf(':')+1, str.length);
          obj[key] = value.trim();
          continue;
        }
        if (str === "}") {
          cssObjectlist.push(obj);
          obj = {};
        }
      }
      // #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng end
      return cssObjectlist;
    },
    // 治療状況ベッドレイアウトマスタ DU End

    adjustTooltipPosition(cd) {
      this.$nextTick(() => {

        const tooltipEl = this.$refs["tooltip" + cd][0];
        tooltipEl.style.display = "none";

        const bedLayoutMainRect = this.$refs.bedLayoutMain.getBoundingClientRect();
        const btnWrapperRect = this.$refs["btnWrapper" + cd][0].getBoundingClientRect();

        // コンテンツ表示域左座標と対象ボタン左座標の差を取得
        const leftDiff = bedLayoutMainRect.left - btnWrapperRect.left;

        // 縦横スクロール発生抑制の為、コンテンツ表示域左端に一旦表示する
        // (処理中に一時的に発生した縦横スクロールが各要素の表示に影響を与え、レイアウト崩れを起こすケースがある)
        // (display:blockしないと座標やwidthなど取得できないが、初期位置で表示させると上記可能性がある為、一旦左端に表示する)
        tooltipEl.style.left = leftDiff + "px";
        tooltipEl.style.right = "auto";
        tooltipEl.style.display = "block";

        // ツールチップ右座標の想定値を算出
        // (計算式：対象ボタン左座標＋left初期位置0.3em＋ツールチップのoffsetWidth＋右側余白1.5em)
        const fontPixelSize = parseInt(this.getScopedComputedStyle(tooltipEl)?.fontSize || 0);
        const rightPosition = btnWrapperRect.left + (fontPixelSize * 0.3) + tooltipEl.offsetWidth + (fontPixelSize * 1.5);
        const viewportWidth = this.getScopedOwnerWindow(tooltipEl)?.innerWidth || getViewportWidth();

        // ツールチップの右座標の想定値が、ウィンドウ幅を超えるか
        const isOverflowRight = rightPosition > viewportWidth;
        if (isOverflowRight) {
          // ウィンドウ外に出ないよう、飛び出した分だけツールチップの左座標をマイナス移動し表示する
          const leftPosition = rightPosition - viewportWidth;
          tooltipEl.style.left = "-" + leftPosition + "px";

          // 表示位置調整後の位置情報取得
          const tooltipRect = tooltipEl.getBoundingClientRect();

          // 表示位置調整した結果、ツールチップの左座標がコンテンツ表示域左側を超えるか
          const isOverflowLeft = tooltipRect.left < bedLayoutMainRect.left;
          if (isOverflowLeft) {
            // ツールチップ左右両端がコンテンツ表示域外に出るようなら、ウィンドウサイズが通常使用の範疇を超えた小ささと判断し、初期位置に表示する
            tooltipEl.style.left = "0.3em";
          }
        } else {
          // 初期位置に表示する
          tooltipEl.style.left = "0.3em";
        }
      });
    },
    resetTooltipPosition(cd) {
      const tooltipEl = this.$refs["tooltip" + cd][0];
      tooltipEl.style.left = "0.3em";
      tooltipEl.style.right = "auto";
      tooltipEl.style.display = "none";
    }

  },
  watch: {
    windowHeight() {
      this.calculateHeight();
    },
    windowWidth() {
      this.calculateHeight();
    },
    isDispMenu() {
      this.calculateHeight();
    },
    getFontSize() {
      this.changeAdjustBtnSize();
      this.calculateHeight();
    },
    showSidebarFlg() {
      this.calculateHeight();
    },
    // 治療状況ベッドレイアウトマスタ DU Start
    cssText() {
      let csslist = this.cssFormat();
      let bedList = this.inputData.gridPlacementList;
      // #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start
      const layoutObj = csslist.find(item => item.name === "Layout_Size")
      if (layoutObj) {
        this.inputData.canvas_size.width = layoutObj.width;
        this.inputData.canvas_size.height = layoutObj.height;
        this.applyCanvasSizeChange();
      }
      // #9771 FNWから取得したVisualLayoutが正しく取り込めていない linjunfeng start
      this.getMachineAndBedList.forEach(machine => {
        /* modify by chamaojia 2023-06-27 [8894] 照合フィールドの変更  --start */
        // fnBedNoを使用した照合
        if (machine.fnBedNo && machine.fnBedNo != 0) {
          csslist.forEach(css => {
            // if( css.name =='Bed'+(Array(4).join('0')+machine.fnBedNo).slice(-4)+'_common' && css.display == undefined){
            if( css.name =='Bed'+(Array(4).join('0')+machine.fnBedNo).slice(-4)+'_common'){
              machine["top"] = css.top ;
              machine["left"] = css.left ;
            }
            // if( css.name =='Bed'+(Array(4).join('0')+machine.fnBedNo).slice(-4)+'_main' && css.display == undefined){
            if( css.name =='Bed'+(Array(4).join('0')+machine.fnBedNo).slice(-4)+'_main'){
              bedList.forEach(e =>{
                if(e.mstBed.mstBed.bedCd == machine.bedCd) {
                  this.deleteBed(e.mstBed);
                }
              })
              this.insertBed(machine,css.width,css.height);
            }
          })
        }
        /* modify by chamaojia 2023-06-27 [8894] 照合フィールドの変更  --end */
      });
    }
    // 治療状況ベッドレイアウトマスタ DU End
  },

  async created() {
    // 端末判別 add 鞠
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "");
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // console.log("this.getMachineAndBedList is %o.", this.getMachineAndBedList);
    this.selfScreenName = this.$route.name;
    EventBus.$on("refresh", this.refresh);
    // 内部処理用ローカル配列に、入力項目をコピー
    for (const num in this.columnDefinition) {
      if (this.columnDefinition[num].field === "code") {
        this.inputData.code = this.getValueByField(
          this.columnDefinition[num].field
        );
      } else if (this.columnDefinition[num].field === "name") {
        this.inputData.name = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
    }
    await this.dataLoad();
    // this.setIsChange(true);  // 起動時に編集中フラグＯＮ？？
    await this.calculateHeight();
  },
  mounted() {
    this.$nextTick(() => {
      this.changeAdjustBtnSize();
      this.calculateHeight();
    });

  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    this.clearGridBedPointerListener();
    EventBus.$off("refresh", this.refresh);
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.main {
  height: 100%;
}
.bed-button {
  font-size: 1em;
}
.horizontal-bed {
  width: 9em;
  height: 6em;
}
.vertical-bed {
  width: 6em;
  height: 9em;
}
.square-bed {
  width: 6em;
  height: 6em;
}
.athome-bed {
  width: 8em;
  height: 8em;
}
.custom-input-required {
  color: black;
  background-color: #ffff99;
}
.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.nowrap-block {
  display: flex;
  overflow: hidden;
  flex-direction: row;
  flex-wrap: nowrap;
}
.left {
  margin-left: 10px;
}
.top {
  margin-top: 10px;
}
.label {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-right: 0.2rem;
  margin-bottom: 0.3rem;
  text-align: left;
  color: var(--treatment-status-font-color);
}
.text {
  justify-content: flex-end;
  align-items: center;
  margin-right: 0.2rem;
  margin-bottom: 0.3rem;
  text-align: left;
  width: 98%;
}
.vertical-label {
  align-items: center;
  margin-right: 0.2rem;
  margin-bottom: 0.5rem;
  text-align: left;
  height: 1.2em;
  color: var(--treatment-status-font-color);
}
.bed-list {
  width: 12em;
  overflow-y: auto;
  height: 10em;
}
.bed-list.select-has-size .select-input {
  height: 100%;
  width: auto;
  min-width: 100%;
}
.grid-bed-slot {
  width: 100%;
  height: 100%;
  cursor: grab;
}
:deep(.vue-grid-item) .grid-bed-slot {
  width: 100%;
  height: 100%;
}
:deep(.vue-grid-item) .bed,
:deep(.vue-grid-item) .bed-home {
  z-index: 1;
  pointer-events: none;
  border: 1px solid #000;
  border-radius: 5px;
  background-color: #ffff;
  box-sizing: border-box;
}
:deep(.vue-grid-item) .bed.bed-selected,
:deep(.vue-grid-item) .bed-home.bed-selected {
  background-color: #fedf;
}
:deep(.vue-grid-item.vue-draggable-dragging) .grid-bed-slot {
  cursor: grabbing;
}
:deep(.vue-grid-item.vue-draggable-dragging) .bed,
:deep(.vue-grid-item.vue-draggable-dragging) .bed-home {
  cursor: grabbing;
}
:deep(.vue-grid-item) .bed-name,
:deep(.vue-grid-item) div.button-area,
:deep(.vue-grid-item) .grid-bed-slot {
  pointer-events: auto;
}
:deep(.vue-grid-item > .vue-resizable-handle),
:deep(.vue-grid-item [class*="resizable-handle"]) {
  z-index: 10;
}
:deep(.vue-grid-item) .bed-home {
  border-radius: 30px 30px 30px 0;
  transform: rotate(-45deg);
}
:deep(.vue-grid-item) .bed-home::before {
  position: absolute;
  content: attr(data-name);
  top: -10px;
  left: 10px;
  transform: rotate(45deg);
  width: 150%;
  text-align: center;
  background: white;
  border-radius: 2px;
}
:deep(.vue-grid-item) .bed-home .bed-name {
  display: none;
}
:deep(.vue-grid-item) .bed-name {
  position: absolute;
  top: 4px;
  left: 6px;
  right: 36px;
  z-index: 1;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #101010;
  text-align: left;
  font-size: 14px;
  line-height: 1.2;
}
:deep(.vue-grid-item) div.button-area {
  position: absolute;
  top: 5px;
  right: 5px;
  z-index: 2;
}
:deep(.vue-grid-item) div.button-area .bed-delete-btn {
  width: 22px;
  height: 22px;
  min-width: 22px;
  padding: 0;
  margin: 0;
  border: 1px solid #c8c8c8;
  border-radius: 3px;
  background-color: #fff;
  color: #101010;
  box-shadow: none;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
}
:deep(.vue-grid-item) div.button-area .bed-delete-btn .ons-icon {
  font-size: 12px;
  color: #101010;
}
.clearboth {
  clear: both;
}
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
}
.buttom-div {
  align-items: flex-end;
}
.option-bed-list {
  color: #101010;
}
.adjust-btn {
  background: #fff;
  color: #000;
  box-shadow: none;
  display: inline-block;
  position: relative;
  padding: 0;
  border: 1px solid #a9a9a9;
  margin-left: -1px;
}
.adjust-btn:hover {
  background: #d3d3d3;
}
.adjust-img {
  height: auto;
  position: absolute;
  transform: translate(-50%, -50%);
  top: 50%;
  left: 50%;
  -webkit-transform: translate(-50%, -50%);
}
.btn-wrapper{
  position:relative;
}
.tooltips {
  display: none;
  position: absolute;
  bottom: -2.4em;
  left: 0.3em;
  z-index: 999;
}
.tooltip-item {
  display: inline-block;
  padding: 3px 5px;
  background: #000;
  color: #fff;
  border-radius: 5px;
  opacity: 0.6;
  font-size: 1.1em;
  max-width: 300px;
  white-space: nowrap;
}
#layout-controller {
  padding: 5px 10px;
}
/*add 鞠 5808 キャンセルと保存のボタン start*/
#item-box-conf{
  padding: 5px 5px 0px 5px;
  /*padding: 5px 20px;*/
  /*margin: 0px auto;*/
  margin: 0;
  width: 98%;
}
.dialog-cancel,.dialog-conf{
  background:none;
}
#list-footer{
  display: flex;
  justify-content: space-between;
}
/*add 鞠 5808 キャンセルと保存のボタン end*/
.selected-color {
  background-color: #1e90ff !important;
  color: white;
}
/* ボタン内文言の表示調整 */
.breakable-text {
  word-wrap: break-word;
  white-space: normal;
  line-height: 1.2;
}
</style>
