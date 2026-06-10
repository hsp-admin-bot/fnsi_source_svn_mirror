<template>
  <div class="main-area" style="height: 98%">
    <table style="min-width: 1100px; overflow-x: auto" class="disp-item-area">
      <tr>
        <td class="layout-name-area" height="30" width="130">レイアウト名</td>
        <td>
          <input
            :value="editRecord.name"
            class="k-textbox"
            @blur="setLayoutName($event.target.value)"
          />
        </td>
      </tr>
      <tr>
        <td class="disp-period" height="30">
          <label>表示区分</label>
        </td>
        <td>
          <v-ons-radio
            v-model="selectedDispClass"
            :input-id="'rdoPeriod0'"
            :value="'0'"
            modifier="round"
            @change="setDispClass($event.target.value)"
          />
          <label :for="'rdoPeriod0'" class="rdo-period">指示/実績</label>
          <v-ons-radio
            v-model="selectedDispClass"
            :input-id="'rdoPeriod1'"
            :value="'1'"
            modifier="round"
            @change="setDispClass($event.target.value)"
          />
          <label :for="'rdoPeriod1'" class="rdo-period">指示</label>
          <v-ons-radio
            v-model="selectedDispClass"
            :input-id="'rdoPeriod2'"
            :value="'2'"
            modifier="round"
            @change="setDispClass($event.target.value)"
          />
          <label :for="'rdoPeriod2'">実績</label>
        </td>
      </tr>
      <tr>
        <td class="disp-item-name-area">表示項目</td>
        <td>
          <div class="disp-item-content-area">
            <draggable
              v-model="dispItemInfo"
              v-bind="{ ...dragOptions, handle: '.category-handle' }"
              @choose="isDraggingCategory = true"
              @end="isDraggingCategory = false"
            >
              <v-ons-row
                v-for="category in dispItemInfo"
                :key="category.categoryNo"
                :class="{ 'layout-item-dragging': isDraggingCategory }"
                class="layout-item"
                @mouseup="isDraggingCategory = false"
                @touchend="isDraggingCategory = false"
              >
                <v-ons-col class="color-header flex-container" width="20%">
                  <label>
                    <v-ons-checkbox
                      v-model="category.isDisp"
                      class="checkbox-style"
                      @input="checkDispToggle('category', category.categoryNo)"
                    />
                    {{ category.categoryName }}
                  </label>
                  <v-ons-icon icon="fa-bars" class="category-handle" />
                </v-ons-col>
                
                <!-- category: 大項目＞治療情報 start -->
                <v-ons-col
                  v-if="category.categoryNo === treatmentItemCategoryNo"
                >
                  <draggable
                    v-model="category.categoryItem"
                    v-bind="{
                      ...dragOptions,
                      handle: '.sub-category-handle',
                    }"
                    @choose="choose(category.categoryNo)"
                    @end="isDraggingSubCategory = false"
                  >
                    <v-ons-row
                      v-for="subCategory in dispItemInfoTreatCond[0].categoryItem"
                      :key="`${category.categoryNo}_${subCategory.subCategoryNo}`"
                      :class="{
                        'layout-item-dragging': isDraggingSubCategory,
                      }"
                      class="layout-item"
                      @mouseup="isDraggingSubCategory = false"
                      @touchend="isDraggingSubCategory = false"
                    >
                      <v-ons-row class="color-header">
                        <v-ons-col class="layout-item">
                          <!-- subCategory: 中項目＞実績情報はチェックボックス非表示 -->
                          <v-ons-checkbox
                            v-if="subCategory.subCategoryNo !== 5"
                            v-model="subCategory.isDisp"
                            class="checkbox-style"
                            style="float: left; margin-top: 5px"
                            @input="
                              checkDispToggle(
                                'subCategory',
                                category.categoryNo,
                                subCategory.subCategoryNo
                              )
                            "
                          />
                          <div
                            style="
                              width: 45%;
                              display: inline-block;
                              height: 30px;
                              float: left;
                              overflow: hidden;
                              white-space: nowrap;
                              text-overflow: ellipsis;
                            "
                          >
                            {{ subCategory.subCategoryName }}
                          </div>
                          <div
                            style="
                              width: 15%;
                              display: inline-block;
                              float: left;
                              margin-left: 5px;
                              overflow: hidden;
                              white-space: nowrap;
                              text-overflow: ellipsis;
                            "
                            v-if="vitalMonitorItemTargetSubCategoryNoList.includes(subCategory.subCategoryNo)"
                          >
                            グラフの色
                          </div>
                          <div
                            style="
                              width: 15%;
                              display: inline-block;
                              float: left;
                              overflow: hidden;
                              white-space: nowrap;
                              text-overflow: ellipsis;
                            "
                            v-if="vitalMonitorItemTargetSubCategoryNoList.includes(subCategory.subCategoryNo)"
                          >
                            グラフの形状
                          </div>
                          <span class="sub-category-handle-area">
                            <button
                              class="btn3-normal"
                              @click="
                                changeColorDetail(
                                  category.categoryNo,
                                  subCategory.subCategoryNo
                                )
                              "
                              v-if="vitalMonitorItemTargetSubCategoryNoList.includes(subCategory.subCategoryNo)"
                            >
                              ランダム
                            </button>
                            <v-ons-icon
                              v-if="
                                isSelectIcon(
                                  category.categoryNo,
                                  subCategory.subCategoryNo
                                )
                              "
                              class="item-handle-icon"
                              icon="plus"
                              @click="
                                showSelector(
                                  $event,
                                  category.categoryNo,
                                  subCategory.subCategoryNo,
                                  subCategory.subCategoryName
                                )
                              "
                            />
                            <v-ons-icon
                              icon="fa-bars"
                              class="sub-category-handle"
                              style="width: 9%; margin-right: 10px"
                            />
                          </span>
                        </v-ons-col>
                      </v-ons-row>
                      <v-ons-col>
                        <draggable
                          v-model="subCategory.subCategoryItem"
                          v-bind="{
                            ...dragOptions,
                            handle: '.sub-category-item-handle',
                          }"
                          @choose="choose(category.categoryNo)"
                          @end="isDraggingSubCategoryItem = false"
                          v-if="
                            showGrandson(
                              category.categoryNo,
                              subCategory.subCategoryNo
                            )
                          "
                        >
                          <v-ons-col
                            v-for="subCategoryItem in subCategory.subCategoryItem"
                            :key="`${category.categoryNo}_${subCategory.subCategoryNo}_${subCategoryItem.tableType}_${subCategoryItem.itemNo}`"
                            :class="{
                              'layout-item-dragging': isDraggingSubCategoryItem,
                            }"
                            class="layout-item"
                            @mouseup="isDraggingSubCategoryItem = false"
                            @touchend="isDraggingSubCategoryItem = false"
                          >
                            <v-ons-checkbox
                              v-model="subCategoryItem.isDisp"
                              class="checkbox-style"
                              @input="
                                checkDispToggle(
                                  'subCategoryItem',
                                  category.categoryNo,
                                  subCategory.subCategoryNo,
                                  subCategoryItem.itemNo
                                )
                              "
                            />
                            <span>
                              <div style="width: 45%; display: inline-block">
                                {{
                                  subCategoryItem.isDispflag == true
                                    ? "【削除済み】"
                                    : ""
                                }}
                                {{ subCategoryItem.itemName }}
                              </div>
                              <div
                                style="width: 15%; display: inline-block"
                                v-if="vitalMonitorItemTargetSubCategoryNoList.includes(subCategory.subCategoryNo)"
                              >
                                <input
                                  v-model="subCategoryItem.itemColor"
                                  style="
                                    margin-top: 3px;
                                    border: none;
                                    outline: none;
                                  "
                                  type="color"
                                />
                              </div>
                              <div
                                style="width: 15%; display: inline-block"
                                v-if="vitalMonitorItemTargetSubCategoryNoList.includes(subCategory.subCategoryNo)"
                              >
                                <kendo-dropdownlist
                                  v-model="subCategoryItem.itemPoint"
                                  :data-source="getPlotType()"
                                  :data-text-field="'text'"
                                  :data-value-field="'value'"
                                  style="
                                    width: 80px;
                                    z-index: 1;
                                    font-size: inherit;
                                    text-align: center;
                                  "
                                  class="common-style-input"
                                />
                              </div>
                            </span>
                            <v-ons-icon
                              icon="fa-bars"
                              class="sub-category-item-handle sub-category-handle-area"
                            />
                          </v-ons-col>
                        </draggable>
                      </v-ons-col>
                      <v-ons-row
                        v-for="vitalChildItem in subCategory.vitalChild"
                        :key="`${category.categoryNo}_${vitalChildItem.subCategoryNo}`"
                        :class="{
                          'layout-item-dragging': isDraggingSubCategory,
                        }"
                        class="layout-item"
                        @mouseup="isDraggingSubCategory = false"
                        @touchend="isDraggingSubCategory = false"
                      >
                        <v-ons-row class="color-header">
                          <v-ons-col class="layout-item">
                            <v-ons-checkbox
                              v-model="vitalChildItem.isDisp"
                              class="checkbox-style"
                              style="float: left; margin-top: 5px"
                              @input="
                                checkDispToggle(
                                  'subCategory',
                                  category.categoryNo,
                                  vitalChildItem.subCategoryNo
                                )
                              "
                            />
                            <div
                              style="
                                width: 45%;
                                display: inline-block;
                                height: 30px;
                                float: left;
                                overflow: hidden;
                                white-space: nowrap;
                                text-overflow: ellipsis;
                              "
                            >
                              {{ vitalChildItem.subCategoryName }}
                            </div>
                            <div
                              style="
                                width: 15%;
                                display: inline-block;
                                float: left;
                                margin-left: 5px;
                                overflow: hidden;
                                white-space: nowrap;
                                text-overflow: ellipsis;
                              "
                            >
                              グラフの色
                            </div>
                            <div
                              style="
                                width: 15%;
                                display: inline-block;
                                float: left;
                                overflow: hidden;
                                white-space: nowrap;
                                text-overflow: ellipsis;
                              "
                            >
                              グラフの形状
                            </div>
                            <span class="sub-category-handle-area">
                              <button
                                class="btn3-normal"
                                @click="
                                  changeColorDetail(
                                    category.categoryNo,
                                    vitalChildItem.subCategoryNo
                                  )
                                "
                              >
                                ランダム
                              </button>
                              <v-ons-icon
                                v-if="
                                  isSelectIcon(
                                    category.categoryNo,
                                    vitalChildItem.subCategoryNo
                                  )
                                "
                                class="item-handle-icon"
                                icon="plus"
                                @click="
                                  showSelector(
                                    $event,
                                    category.categoryNo,
                                    vitalChildItem.subCategoryNo,
                                    vitalChildItem.subCategoryName
                                  )
                                "
                              />
                              <span style="width: 9%; margin-right: 23px" />
                            </span>
                          </v-ons-col>
                        </v-ons-row>
                        <v-ons-col>
                          <draggable
                            v-model="vitalChildItem.subCategoryItem"
                            v-bind="{
                              ...dragOptions,
                              handle: '.sub-category-item-handle',
                            }"
                            v-if="
                              showGrandson(
                                category.categoryNo,
                                vitalChildItem.subCategoryNo
                              )
                            "
                            @choose="choose(category.categoryNo)"
                            @end="isDraggingSubCategoryItem = false"
                          >
                            <v-ons-col
                              v-for="vitalChildSubCategoryItem in vitalChildItem.subCategoryItem"
                              :key="`${category.categoryNo}_${vitalChildItem.subCategoryNo}_${vitalChildSubCategoryItem.tableType}_${vitalChildSubCategoryItem.itemNo}`"
                              :class="{
                                'layout-item-dragging':
                                  isDraggingSubCategoryItem,
                              }"
                              class="layout-item"
                              @mouseup="isDraggingSubCategoryItem = false"
                              @touchend="isDraggingSubCategoryItem = false"
                            >
                              <v-ons-checkbox
                                v-model="vitalChildSubCategoryItem.isDisp"
                                class="checkbox-style"
                                @input="
                                  checkDispToggle(
                                    'subCategoryItem',
                                    category.categoryNo,
                                    vitalChildItem.subCategoryNo,
                                    vitalChildSubCategoryItem.itemNo
                                  )
                                "
                              />
                              <span>
                                <div style="width: 45%; display: inline-block">
                                  {{
                                    vitalChildSubCategoryItem.isDispflag == true
                                      ? "【削除済み】"
                                      : ""
                                  }}
                                  {{ vitalChildSubCategoryItem.itemName }}
                                </div>
                                <div
                                  v-if="vitalMonitorItemTargetSubCategoryNoList.includes(subCategory.subCategoryNo)"
                                  style="width: 15%; display: inline-block"
                                >
                                  <input
                                    v-model="
                                      vitalChildSubCategoryItem.itemColor
                                    "
                                    style="
                                      margin-top: 3px;
                                      border: none;
                                      outline: none;
                                    "
                                    type="color"
                                  />
                                </div>
                                <div
                                  v-if="vitalMonitorItemTargetSubCategoryNoList.includes(subCategory.subCategoryNo)"
                                  style="width: 15%; display: inline-block"
                                >
                                  <kendo-dropdownlist
                                    v-model="
                                      vitalChildSubCategoryItem.itemPoint
                                    "
                                    :data-source="getPlotType()"
                                    :data-text-field="'text'"
                                    :data-value-field="'value'"
                                    style="
                                      width: 80px;
                                      z-index: 1;
                                      font-size: inherit;
                                      text-align: center;
                                    "
                                    class="common-style-input"
                                  />
                                </div>
                              </span>
                              <v-ons-icon
                                icon="fa-bars"
                                class="sub-category-item-handle sub-category-handle-area"
                              />
                            </v-ons-col>
                          </draggable>
                        </v-ons-col>
                      </v-ons-row>
                    </v-ons-row>
                  </draggable>
                </v-ons-col>
                <!-- category: 大項目＞治療情報 end -->
                
                <!-- category: 大項目＞患者情報、その他 start -->
                <v-ons-col v-else>
                  <draggable
                    v-model="category.categoryItem"
                    v-bind="{
                      ...dragOptions,
                      handle: '.sub-category-handle',
                    }"
                    @choose="choose(category.categoryNo)"
                    @end="isDraggingSubCategory = false"
                  >
                    <v-ons-row
                      v-for="subCategory in category.categoryItem"
                      :key="`${category.categoryNo}_${subCategory.subCategoryNo}`"
                      :class="{
                        'layout-item-dragging': isDraggingSubCategory,
                      }"
                      class="layout-item"
                      @mouseup="isDraggingSubCategory = false"
                      @touchend="isDraggingSubCategory = false"
                    >
                      <v-ons-row class="color-header">
                        <v-ons-checkbox
                          v-model="subCategory.isDisp"
                          class="checkbox-style"
                          @input="
                            checkDispToggle(
                              'subCategory',
                              category.categoryNo,
                              subCategory.subCategoryNo
                            )
                          "
                          style="
                            height: 22px;
                            display: inline-block;
                            margin-top: 5px;
                          "
                        />
                        <div
                          style="
                            width: 31%;
                            display: inline-block;
                            height: 30px;
                          "
                        >
                          {{ subCategory.subCategoryName }}
                        </div>

                        <v-ons-col class="layout-item">
                          <span class="sub-category-handle-area">
                            <v-ons-icon
                              :ref="
                                category.categoryNo +
                                '_' +
                                subCategory.subCategoryNo
                              "
                              v-if="
                                isSelectIcon(
                                  category.categoryNo,
                                  subCategory.subCategoryNo
                                )
                              "
                              class="item-handle-icon"
                              icon="plus"
                              @click="
                                showSelector(
                                  $event,
                                  category.categoryNo,
                                  subCategory.subCategoryNo,
                                  subCategory.subCategoryName
                                )
                              "
                            />
                            <v-ons-icon
                              icon="fa-bars"
                              class="sub-category-handle right-category-handle"
                            />
                          </span>
                        </v-ons-col>
                      </v-ons-row>
                      <v-ons-col>
                        <draggable
                          v-model="subCategory.subCategoryItem"
                          v-bind="{
                            ...dragOptions,
                            handle: '.sub-category-item-handle',
                          }"
                          @choose="isDraggingSubCategoryItem = true"
                          @end="isDraggingSubCategoryItem = false"
                          v-if="
                            showGrandson(
                              category.categoryNo,
                              subCategory.subCategoryNo
                            )
                          "
                        >
                          <v-ons-col
                            :class="{
                              'layout-item-dragging': isDraggingSubCategoryItem,
                            }"
                            :key="`${category.categoryNo}_${subCategory.subCategoryNo}_${subCategoryItem.isPatEventSub}_${subCategoryItem.itemNo}`"
                            @mouseup="isDraggingSubCategoryItem = false"
                            @touchend="isDraggingSubCategoryItem = false"
                            class="layout-item"
                            v-for="subCategoryItem in subCategory.subCategoryItem"
                          >
                            <v-ons-checkbox
                              v-model="subCategoryItem.isDisp"
                              class="checkbox-style"
                              :disabled="false"
                              @input="
                                checkDispToggle(
                                  'subCategoryItem',
                                  category.categoryNo,
                                  subCategory.subCategoryNo,
                                  subCategoryItem.itemNo,
                                  subCategoryItem.isPatEventSub
                                )
                              "
                            />
                            <span>
                              <div style="width: 32%; display: inline-block">
                                {{
                                  subCategoryItem.isDispflag
                                    ? "【削除済み】"
                                    : ""
                                }}
                                {{ subCategoryItem.itemName }}
                              </div>
                            </span>
                            <v-ons-icon
                              icon="fa-bars"
                              class="sub-category-item-handle sub-category-handle-area"
                            />
                          </v-ons-col>
                        </draggable>
                      </v-ons-col>
                    </v-ons-row>
                  </draggable>
                </v-ons-col>
                <!-- category: 大項目＞患者情報、その他 end -->
              </v-ons-row>
            </draggable>
          </div>
        </td>
      </tr>
    </table>

    <v-ons-popover
      cancelable
      :visible.sync="popoverInfo.popoverVisible"
      :target="popoverInfo.popoverTarget"
      :direction="popoverInfo.popoverDirection"
      :class="[fontSizeSet, 'popover-style']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div>
        <h2 class="selector-title">
          {{ popoverInfo.titleLabel }}
        </h2>
        <hr />
        <!-- バイタル・モニタグラフ、患者イベント、施設イベント 吹き出し -->
        <v-ons-row>
          <div>
            <v-ons-col class="graph-setting">
              <div
                v-if="vitalMonitorItemTargetSubCategoryNoList.includes(popoverInfo.targetInfo.subCategoryNo)"
              >
                グラフ縦線
              </div>
              <div
                v-if="vitalMonitorItemTargetSubCategoryNoList.includes(popoverInfo.targetInfo.subCategoryNo)"
              >
                <label>上限値</label>
                <keep-alive>
                  <component
                    :is="'custom-input-number-pro'"
                    class="search-style"
                    :step="0.01"
                    :value="graphMax"
                    :key="`${popoverInfo.targetInfo.categoryNo}_${popoverInfo.targetInfo.subCategoryNo}`"
                    :min="min"
                    :max="max"
                    @handlerInput="
                      (val) => {
                        graphMax = val;
                      }
                    "
                    @blur="graphValueChange($event, 1, 0)"
                  />
                </keep-alive>
              </div>
              <div
                v-if="vitalMonitorItemTargetSubCategoryNoList.includes(popoverInfo.targetInfo.subCategoryNo)"
              >
                <label>下限値</label>
                <keep-alive>
                  <component
                    :is="'custom-input-number-pro'"
                    class="search-style"
                    :step="0.01"
                    :value="graphMin"
                    :key="`${popoverInfo.targetInfo.categoryNo}_${popoverInfo.targetInfo.subCategoryNo}`"
                    :min="min"
                    :max="max"
                    @handlerInput="
                      (val) => {
                        graphMin = val;
                      }
                    "
                    @blur="graphValueChange($event, 2, 1)"
                  />
                </keep-alive>
              </div>
              <!--フリーワード-->
              <v-ons-row
                v-if="popoverInfo.targetInfo.categoryNo === 5 || popoverInfo.targetInfo.categoryNo === 7"
                style="height: auto; margin-bottom: 10px"
                class="div-style"
              >
                <v-ons-col width="9em">
                  <label class="label-style">フリーワード</label>
                </v-ons-col>
                <v-ons-col>
                  <input
                    v-model="popoverSearchQuery"
                    class="search-style"
                    style="min-width: 200px"
                    type="search"
                    placeholder="検索"
                  />
                </v-ons-col>
              </v-ons-row>
              <div>選択:</div>
              <div class="mult-selector" style="min-width: 200px">
                <div
                  v-for="(selectedInfo, index) in popoverInfo.selectInfoOptions"
                  :key="index"
                  :class="[
                    setListClass(selectedInfo.itemNo),
                    {
                      'category-disabled': !isSelectable(popoverInfo.targetInfo.categoryNo, selectedInfo)
                    }
                  ]"
                  class="select-label-style"
                  @click="isSelectable(popoverInfo.targetInfo.categoryNo, selectedInfo) && storageInfo(selectedInfo, $event)"
                >
                  <label
                    v-if="
                      isPatEventSub(
                        popoverInfo.targetInfo.categoryNo,
                        selectedInfo
                      )
                    "
                    >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label
                  >
                  {{ selectedInfo.isDisp === "0" ? "【削除済み】" : "" }}
                  {{ selectedInfo.itemName }}
                </div>
              </div>
            </v-ons-col>
          </div>
        </v-ons-row>
        <v-ons-row class="justify-content-space-between">
          <v-ons-button
            class="common-style-cancel-button button-cancel btn2-cancel"
            @click="closePopover()"
            >キャンセル
          </v-ons-button>
          <v-ons-button
            class="common-style-ok-button button-confirm btn1-execute"
            @click="saveChanges"
            >OK</v-ons-button
          >
        </v-ons-row>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import {
  mstPatCalendarLayoutDefine,
  CATEGORY_NO,
  SUB_CATEGORY_NO,
} from "@/constants/mstPatCalendarLayoutDefine";
import { deepCopy } from "@/functions/common/CommonFunctions";
import vuedraggable from "vuedraggable";
import { ApiHelper } from "@/apis/AxiosHelper";
import PopoverMixin from "@/components/PopoverMixin";
import { REPORT_GRAPH } from "@/constants/mstTreatmentDefine";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import { EventBus } from "@/eventBus";
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";

const MAX_COLUMN = 5;

export default {
  mixins: [PopoverMixin],
  components: {
    draggable: vuedraggable,
    "custom-input-number-pro": CustomInputNumberPro,
  },
  data() {
    return {
      dragOptions: {
        animation: 250,
        ghostClass: "ghost",
        dragClass: "drag",
        forceFallback: true,
        fallbackClass: "layout-item-fallback",
      },
      isDraggingCategory: false,
      isDraggingSubCategory: false,
      isDraggingSubCategoryItem: false,
      /**
       * 表示項目情報
       */
      dispItemInfo: [],
      /**
       * 表示項目情報初期値
       */
      initdispItemInfo: [],
      /**
       * 未処理フラグ
       */
      ignoreWatchDispItemInfo: true,
      /**
       * 初期表示内容
       */
      initDispItemInfoJSON: [],
      /**
       * ポップオーバー情報
       */
      popoverInfo: {
        popoverVisible: false,
        popoverTarget: null,
        popoverDirection: null,
        // ポップオーバータイトル
        titleLabel: null,
        // ポップオーバーで選択された情報リスト
        selectedList: [],
        // 対象となる項目情報
        targetInfo: {
          categoryNo: null,
          subCategoryNo: null,
        },
      },
      /**
       * 選択情報リスト
       */
      selectedList: [],
      /**
       * モニタグラフ設定
       */
      selectedSetting: {
        min: {
          initValue: "",
          editValue: "",
        },
        max: {
          initValue: "",
          editValue: "",
        },
      },
      /**
       * 治療方法項目のカテゴリ番号
       */
      treatmentItemCategoryNo: CATEGORY_NO.TREATMENT_CONTENT,
      /**
       * バイタル・モニタ項目の選択肢を表示するサブカテゴリ番号
       */
      vitalMonitorItemTargetSubCategoryNoList: [
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_2,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_3,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_2,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_3,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_2,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_3,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_2,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_3,
      ],
      
      /** バイタル・モニタグラフN-1 */
      vitalMonitorSubCategoryNo1: [
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1
      ],
      /** バイタル・モニタグラフN-2 */
      vitalMonitorSubCategoryNo2: [
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_2,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_2,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_2,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_2
      ],
      /** バイタル・モニタグラフN-3 */
      vitalMonitorSubCategoryNo3: [
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_3,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_3,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_3,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_3
      ],
      
      graphMax: "",
      graphMin: "",

      min: -99999.99,
      max: 99999.99,
      blurFlg: false,
      focusFlg: [false, false],
      initName: "",
      isEditedName: false,
      initDispClass: "",
      
      /**
       * フリーワード入力値
       */
      popoverSearchQuery: "",
      
      /**
       * 患者イベントカテゴリマスタ
       */
      mstPatEventCategory: [],
      /**
       * 患者イベントサブカテゴリマスタ
       */
      mstPatEventSubCategory: null,
      /**
       * 患者イベント
       */
      mstPatEventSubCategoryPat: [],
      
      /**
       * 施設イベントカテゴリマスタ
       */
      mstBbsKind: [],
      
      /**
       * バイタル・モニタ項目の選択肢リスト
       */
      selectVitalMonitorItemList: [],
      
      /**
       * バイタル・モニタ項目追加マスタ
       */
      mstAddMonitor: [],
      /**
       * バイタル・モニタ
       */
      mstAddMonitorListDisp: [],
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      editRecord: "getEditRecord",
      getFacilitySwitch: "getFacilitySwitch",
    }),
    selectedDispClass: {
      get() {
        return this.editRecord.dispClass
          ? this.editRecord.dispClass
          : "0";
      },
      set(value) {
        this.editRecord.dispClass = value;
      },
    },
    dispItemInfoTreatCond() {
      const treatCond = this.dispItemInfo.filter((item) => {
        return item.categoryNo === CATEGORY_NO.TREATMENT_CONTENT;
      });

      if (!treatCond || !treatCond[0]) {
        return [];
      }
      return treatCond;
    }
  },
  async created() {
    this.setLoadingScreenVisible(true);

    const requestParam = {
      facilityCd: this.getFacilitySwitch,
    };

    const [
      mstPatEventSubCategory,
      mstEventCategory,
      mstBbsKind,
      selectVitalMonitorItemList,
      mstAddMonitor,
    ] = await Promise.all([
      ApiHelper.get("/mstInfo/mstPatEventSubCategory", requestParam),
      ApiHelper.get(
        `/master_maintenance/mst_pat_event_category/data/${this.getFacilitySwitch}`
      ),
      ApiHelper.get("/mstInfo/mstBbsKind", requestParam),
      // バイタルモニタ項目取得
      ApiHelper.get("/mstInfo/mstPatViewerLayout/monitorItem", {
        facilityCd: this.getFacilitySwitch,
        isAllDisp: "1",
      }),
      ApiHelper.get(
        `/master_maintenance/mst_add_monitor/data/${this.getFacilitySwitch}`
      ),
    ]);
    
    // 患者イベントサブカテゴリマスタ
    this.mstPatEventSubCategory = mstPatEventSubCategory.data;
    // 患者イベントカテゴリマスタ
    this.mstPatEventCategory =
      mstEventCategory.data.localDataSource.data.filter(
        (e) => e.isDisp === "1"
      );

    // 患者イベントカテゴリマスタと患者イベントサブカテゴリマスタを区別すために
    // 患者イベントサブカテゴリマスタのデータ isPatEventSub に 1 を設定します。
    mstPatEventSubCategory.data.forEach((e) => (e.isPatEventSub = 1));
    // 患者イベントカテゴリマスタのデータ isPatEventSub に 0 を設定します。
    this.mstPatEventCategory.forEach((e) => (e.isPatEventSub = 0));

    // 患者イベントカテゴリと患者イベントサブカテゴリの整合を取り、存在しないカテゴリ／サブカテゴリを除外
    this.mstPatEventSubCategoryPat = mstPatEventSubCategory.data;
    this.mstPatEventCategory = this.mstPatEventCategory.filter(cate =>
      this.mstPatEventSubCategoryPat.some(pat => pat.categoryCd === cate.code)
    );
    this.mstPatEventSubCategoryPat = this.mstPatEventSubCategoryPat.filter(pat =>
      this.mstPatEventCategory.some(cate => cate.code === pat.categoryCd)
    );
    
    // 施設イベントカテゴリマスタ
    this.mstBbsKind = mstBbsKind.data;
    
    // バイタルモニタ情報セット
    for (let i = 0; i < selectVitalMonitorItemList.data.length; i++) {
      let vitalItem = {
        tableType: selectVitalMonitorItemList.data[i].tableType,
        moniDataNo: selectVitalMonitorItemList.data[i].moniDataNo,
        vitalMonitorClass: selectVitalMonitorItemList.data[i].vitalMonitorClass,
        vitalMonitorItemName:
          selectVitalMonitorItemList.data[i].vitalMonitorItemName,
        moniDataType: selectVitalMonitorItemList.data[i].moniDataType,
        moniDataNoSort: selectVitalMonitorItemList.data[i].moniDataNoSort,
        purificationType: selectVitalMonitorItemList.data[i].purificationType,
        isDisp: selectVitalMonitorItemList.data[i].isDisp,
        lineColor: "#000000", // グラフの色
        pointType: "triangle",// グラフの形状
        medDate: null,
      };

      const DISPLAYLIST = [
        "31",
        "0",
        "A1",
        "D1",
        "Z11",
        "Z21",
        "Z232",
        "Z364",
        "I1",
        "J1",
      ];

      //
      let DISPLAYLIST_ADD = [
        "Z101",
        "Z102",
        "Z202",
        "Z222",
        "Z103",
        "Z104",
        "Z354",
        ...DISPLAYLIST,
      ];

      if (
        !DISPLAYLIST_ADD.includes(selectVitalMonitorItemList.data[i].moniDataNo)
      ) {
        this.selectVitalMonitorItemList.push(vitalItem);
      }
    }

    const mstAddMonitorFinal = mstAddMonitor.data.localDataSource.data.map(
      ({ code, name, ...rest }) => {
        return {
          vitalMonitorItemCd: code,
          vitalMonitorItemName: name,
          facilityCd: this.getFacilitySwitch,
          ...rest,
        };
      }
    );
    this.mstAddMonitor = mstAddMonitorFinal;
    this.mstAddMonitor.forEach((item) => {
      if (item.isDisp === "0") {
        this.mstAddMonitorListDisp.push(item.vitalMonitorItemCd);
      }
    });

    this.initName = this.editRecord.name;
    this.initDispClass = this.selectedDispClass;

    this.retrieveMstData();
    this.initdispItemInfo = deepCopy(this.dispItemInfo);

    this.changeDispItem();

    this.setLoadingScreenVisible(false);
  },

  watch: {
    /**
     * @description 表示項目並び替えウォッチャー
     */
    dispItemInfo: {
      handler(newValue, oldValue) {
        const convData = this.removeIsDispOption(newValue);
        this.setDispItemInfo(convData);
        // 表示・非表示切替
        this.switchingItemDisp();
        // 指示/実績
        if (this.selectedDispClass === "0") {
          // 初期更新(DOM)の場合
          if (this.ignoreWatchDispItemInfo) {
            // 初期表示内容の取得
            this.initDispItemInfoJSON = convData;
            // 未処理(以降の初期表示内容は取得しない)
            this.ignoreWatchDispItemInfo = false;
          }
        // 指示、実績 以外
        } else {
          // 初期更新(DOM)の場合
          if (oldValue !== null && oldValue.length === 0) {
            // 初期表示内容の取得
            this.initDispItemInfoJSON = convData;
            // 未処理(以降の初期表示内容は取得しない)
            this.ignoreWatchDispItemInfo = false;
            // 終了
            return;
          }
        }
        // 確認ボタンの活性切替
        this.switchButton();
      },
      deep: true,
    },
    
    /**
     * フリーワード入力値
     */
    popoverSearchQuery: {
      handler() {
        this.fuzzyQuery();
      },
    },

    /**
     * 期間が選択された際に項目を入れ替える
     */
    selectedDispClass() {
      // レイアウトデータの取得
      this.changeDispItem();
    },
  },

  mounted() {
    this.$el.parentElement.style.height = "100%";
    // 表示項目を初期値として格納する
    this.initdispItemInfo = deepCopy(this.dispItemInfo);
    // 表示項目のデフォルト値を格納する
    if ("" === this.editRecord.dispClass) {
      this.setDispClass(this.selectedDispClass);
    }
    // 表示期間に対応するレイアウトデータの取得
    this.changeDispItem();
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },

  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-complaint", ["getMstComplaintByFacilityCd"]),
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
    }),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    choose(categoryNo) {
      this.isDraggingSubCategory = false;
      this.isDraggingSubCategoryItem = false;
    },
    getPlotType() {
      return REPORT_GRAPH.SELECT_ITEM_PLOT_TYPE;
    },

    /**
     * @description レイアウトデータ取得
     */
    retrieveMstData() {
      const temp = this.editRecord.dispItemInfo
        ? JSON.parse(this.editRecord.dispItemInfo)
        : mstPatCalendarLayoutDefine;
      let rtnTmp = this.insertIsDispOption(temp);

      // バイタル・モニタグラフ　入室～退室の親子化
      let convertRtnTmp = [];
      for (let i = 0; i < rtnTmp.length; i++) {
        if (rtnTmp[i].categoryNo === CATEGORY_NO.TREATMENT_CONTENT) {
          let convertTreateCategoryItem = [];
          let excludeSubCategoryNoList = [];
          let treateCategoryItemList = rtnTmp[i].categoryItem;
          for (let j = 0; j < treateCategoryItemList.length; j++) {
            if (
              !excludeSubCategoryNoList.includes(
                treateCategoryItemList[j].subCategoryNo
              )
            ) {
              let treateCategoryItem = null;
              let vitalChild = [];
              if (
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1 ||
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_2 ||
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_3
              ) {
                // バイタル・モニタグラフ①-1～①-3　入室～退室
                treateCategoryItem = treateCategoryItemList.find(
                  (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_2
                  )
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_3
                  )
                );
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1);
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_2);
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_3);
              } else if (
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1 ||
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_2 ||
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_3
              ) {
                // バイタル・モニタグラフ②-1～②-3　入室～退室
                treateCategoryItem = treateCategoryItemList.find(
                  (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_2
                  )
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_3
                  )
                );
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1);
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_2);
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_3);
              } else if (
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1 ||
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_2 ||
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_3
              ) {
                // バイタル・モニタグラフ③-1～③-3　入室～退室
                treateCategoryItem = treateCategoryItemList.find(
                  (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_2
                  )
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_3
                  )
                );
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1);
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_2);
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_3);
              } else if (
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1 ||
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_2 ||
                treateCategoryItemList[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_3
              ) {
                // バイタル・モニタグラフ④-1～④-3　入室～退室
                treateCategoryItem = treateCategoryItemList.find(
                  (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_2
                  )
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_3
                  )
                );
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1);
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_2);
                excludeSubCategoryNoList.push(SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_3);
              } else {
                treateCategoryItem = treateCategoryItemList[j];
                excludeSubCategoryNoList.push(
                  treateCategoryItemList[j].subCategoryNo
                );
              }
              if (treateCategoryItem.vitalChild === undefined) {
                if (this.vitalMonitorSubCategoryNo1.includes(treateCategoryItem.subCategoryNo)) {
                  let treateCategoryItemInfo = treateCategoryItem;
                  treateCategoryItemInfo.vitalChild = vitalChild;
                  convertTreateCategoryItem.push(treateCategoryItemInfo);
                } else {
                  convertTreateCategoryItem.push(treateCategoryItem);
                }
              } else {
                convertTreateCategoryItem.push(treateCategoryItem);
              }
            }
          }
          rtnTmp[i].categoryItem = convertTreateCategoryItem;
        }
        convertRtnTmp.push(rtnTmp[i]);
      }
      this.dispItemInfo = convertRtnTmp;
    },
    /**
     * @description レイアウト名更新
     * @param { String } value 編集内容
     */
    setLayoutName(value) {
      const name = value;
      // 編集中マスタを更新
      this.setEditRecord({ ...this.editRecord, name });
      if (name !== this.initName) {
        this.changeButton();
        this.isEditedName = true;
      } else {
        EventBus.$emit("mstHolidayRegistered", true);
        this.isEditedName = false;
      }
    },

    /**
     * @description 表示項目の選択値更新
     * @param { String } dispClass 0: 指示/実績、1: 指示、2: 実績
     */
    setDispClass(dispClass) {
      // 編集中マスタを更新
      this.setEditRecord({ ...this.editRecord, dispClass });
    },

    /**
     * @description 表示項目変更
     * @param { Array } value 編集内容
     */
    setDispItemInfo(value) {
      const dispItemInfo = JSON.stringify(value);
      // 編集中マスタを更新
      this.setEditRecord({ ...this.editRecord, dispItemInfo });
    },

    /**
     * @description 編集レイアウト項目ごとに内部処理用表示フラグを挿入して、レイアウトマスタ定義を元に
     *              存在しない項目を非表示扱いとする
     * @param { Array } data 編集レイアウト
     */
    insertIsDispOption(data) {
      // 患者カレンダーレイアウトマスタの項目定義
      const src = deepCopy(mstPatCalendarLayoutDefine);
      // 編集中マスタ
      data.forEach((item) => {
        // 処理対象 > 指示/実績、実績：治療情報 / バイタル・モニタグラフ(入室～退室)
        // 大項目
        if (
          item.categoryNo === CATEGORY_NO.TREATMENT_CONTENT
        ) {
          // 中項目
          item.categoryItem.forEach((catItem) => {
            if (catItem.dataKey?.startsWith("vital")) {
              // ■バイタル・モニタグラフ(入室～退室)
              catItem.subCategoryItem.forEach((subItem) => {
                var isAddMonitor = subItem.itemNo > 10000 ? true : false;
                if (
                  isAddMonitor &&
                  this.mstAddMonitorListDisp.includes(subItem.itemNo - 10000)
                ) {
                  subItem.isDispflag = true;
                }
              });
            }
          });
        }
      });

      const dest = deepCopy(data);

      src.forEach((srcCategory) => {
        const destCategory = dest.find((categoryOther) => {
          return categoryOther.categoryNo === srcCategory.categoryNo;
        });

        // 編集中マスタに項目が存在しないと非表示にする
        if (!destCategory) {
          srcCategory.isDisp = false;
          srcCategory.categoryItem.forEach((subCat) => {
            subCat.isDisp = false;
            subCat.subCategoryItem.forEach((item) => {
              item.isDisp = false;
            });
          });
          dest.push(srcCategory);
        } else {
          destCategory.categoryName = srcCategory.categoryName;
          destCategory.isDisp = true;
          srcCategory.categoryItem.forEach((srcSubCategory) => {
            const destSubCategory = destCategory.categoryItem.find(
              (subCategoryOther) => {
                return (
                  subCategoryOther.subCategoryNo ===
                  srcSubCategory.subCategoryNo
                );
              }
            );

            // 編集中マスタに項目が存在しないと非表示にする
            if (!destSubCategory) {
              srcSubCategory.isDisp = false;
              srcSubCategory.subCategoryItem.forEach((item) => {
                item.isDisp = false;
              });
              destCategory.categoryItem.push(srcSubCategory);
            } else {
              destSubCategory.subCategoryName = srcSubCategory.subCategoryName;
              if (destSubCategory.isDisp === undefined) {
                destSubCategory.isDisp = true;
              }
              
              // 治療情報の場合
              if (CATEGORY_NO.TREATMENT_CONTENT === srcCategory.categoryNo) {
                // 小項目番号を格納
                const cateNo = destSubCategory.subCategoryNo;
                // バイタル情報の場合、レイアウトマスタ情報に定義がなくても非表示にされない
                if (this.vitalMonitorItemTargetSubCategoryNoList.includes(cateNo)) {
                  srcSubCategory.subCategoryItem = 
                  destSubCategory.subCategoryItem;
                }
              // 患者イベント、施設イベント
              } else if (
                CATEGORY_NO.PAT_EVENT_CONTENT === srcCategory.categoryNo ||
                CATEGORY_NO.BBS_CONTENT === srcCategory.categoryNo
              ) {
                srcSubCategory.subCategoryItem =
                  destSubCategory.subCategoryItem;
              }

              // 患者イベント、施設イベント
              if (
                CATEGORY_NO.PAT_EVENT_CONTENT === srcCategory.categoryNo ||
                CATEGORY_NO.BBS_CONTENT === srcCategory.categoryNo
              ) {
                srcSubCategory.subCategoryItem.forEach((srcItem) => {
                  let destItem;
                  // 施設イベント → isPatEventSub を使わない
                  if (CATEGORY_NO.BBS_CONTENT === srcCategory.categoryNo) {
                    destItem = destSubCategory.subCategoryItem.find(
                      (itemOther) => itemOther.itemNo === srcItem.itemNo
                    );
                  // 患者イベント → isPatEventSub も比較
                  } else {
                    destItem = destSubCategory.subCategoryItem.find(
                      (itemOther) =>
                        itemOther.itemNo === srcItem.itemNo &&
                        itemOther.isPatEventSub === srcItem.isPatEventSub
                    );
                  }

                  // 編集中マスタに項目が存在しないと非表示にする
                  if (!destItem) {
                    srcItem.isDisp = false;
                    destSubCategory.subCategoryItem.push(srcItem);
                  } else {
                    destItem.itemName = srcItem.itemName;
                    destItem.isDisp = true;
                  }
                });
              } else {
                srcSubCategory.subCategoryItem.forEach((srcItem) => {
                  const destItem = destSubCategory.subCategoryItem.find(
                    (itemOther) => {
                      if (
                        this.isVitalMonitor(
                          srcCategory.categoryNo,
                          srcSubCategory.subCategoryNo
                        )
                      ) {
                        return (
                          itemOther.tableType === srcItem.tableType &&
                          itemOther.itemNo === srcItem.itemNo
                        );
                      } else {
                        return (
                          itemOther.itemNo ===
                          (srcItem.itemNo ?? srcItem.itemInfo.itemNo)
                        );
                      }
                    }
                  );
                  // 編集中マスタに項目が存在しないと非表示にする
                  if (!destItem) {
                    srcItem.isDisp = false;
                    destSubCategory.subCategoryItem.push(srcItem);
                  } else {
                    destItem.itemName = srcItem.itemName;
                    destItem.isDisp = true;
                  }
                });
              }
            }
          });
        }
      });
      return dest;
    },

    /**
     * @description チェックボックスOFFの項目を保存データから削除。ただし、子がONの場合は親を残す。
     * @param { Array } data 編集レイアウト
     */
    removeIsDispOption(data) {
      let res = deepCopy(data);

      // 非表示とした項目を配列から削除
      res = res.filter((category) => {
        category.categoryItem = category.categoryItem.filter((subCategory) => {
          // 小項目フィルタ
          subCategory.subCategoryItem = subCategory.subCategoryItem.filter(
            (item) => item.isDisp
          );
          // バイタル・モニタグラフ 入室～退室 N-1 系は無条件で残す
          if (this.vitalMonitorSubCategoryNo1.includes(subCategory.subCategoryNo)) {
            return true;
          }
          // 小項目が残っていれば中項目を残す
          if (subCategory.subCategoryItem.length > 0) {
            return true;
          }
          // 上記以外は isDisp 判定
          return subCategory.isDisp;
        });
        // 大項目は isDisp で判断
        return category.isDisp;
      });

      // 「バイタル・モニタグラフ 入室～退室①～④」の(不要)キーを削除
      res.forEach((category) => {
        category.categoryItem.forEach((subCategory) => {
          if (this.vitalMonitorSubCategoryNo1.includes(subCategory.subCategoryNo)) {
            if (!subCategory.isDisp) {
              delete subCategory.drugStatus;
              delete subCategory.graphMax;
              delete subCategory.graphMin;
              delete subCategory.inspectionStatus;
              delete subCategory.treatmentStatus;
            }
            subCategory.vitalChild.forEach((vitalChild) => {
              if (!vitalChild.isDisp) {
                delete vitalChild.drugStatus;
                delete vitalChild.graphMax;
                delete vitalChild.graphMin;
                delete vitalChild.inspectionStatus;
                delete vitalChild.treatmentStatus;
              }
            });
          }
        });
      });
      
      // 「治療情報」表示配列の再作成
      if (res.length > 0) {
        for (let i = 0; i < res.length; i++) {
          const category = res[i];
      
          // 治療情報カテゴリだけ処理
          if (category.categoryNo !== CATEGORY_NO.TREATMENT_CONTENT) continue;
      
          const vitalRootNos = this.vitalMonitorSubCategoryNo1;
      
          /* -----------------------------------------------------
           * 1. N-1 の下にある N-2/N-3 の subCategoryItem を isDisp で絞り込む
           * ----------------------------------------------------- */
          category.categoryItem = category.categoryItem.map((subCategory) => {
            const isVitalRoot = vitalRootNos.includes(subCategory.subCategoryNo);
      
            if (isVitalRoot && Array.isArray(subCategory.vitalChild)) {
      
              const newVitalChild = subCategory.vitalChild.map((child) => ({
                ...child,
                subCategoryItem: child.subCategoryItem.filter((item) => item.isDisp),
              }));
      
              return { ...subCategory, vitalChild: newVitalChild };
            }
      
            return subCategory;
          });
      
          /* -----------------------------------------------------
           * 2. バイタル・モニタグラフ N単位で削除判定
           * ----------------------------------------------------- */
          category.categoryItem = category.categoryItem.filter((subCategory) => {
            if (!vitalRootNos.includes(subCategory.subCategoryNo)) return true;
      
            const root = subCategory;
      
            const parentHidden = root.isDisp === false;
            const allVitalChildHidden =
              root.vitalChild?.every((child) => child.isDisp === false) ?? true;
            const childrenHidden =
              root.vitalChild?.every(
                (child) => child.subCategoryItem.length === 0
              ) ?? true;

            /* -----------------------------------------------------
             * 3. 条件すべて満たせば削除
             * ----------------------------------------------------- */    
            return !(parentHidden && allVitalChildHidden && childrenHidden);
          });
        }
      }
      
      return res;
    },

    /**
     * @description 表示非表示チェックボックストグル後のコールバック
     *              表示非表示したものによるグループ表示非表示をする
     * @param { String } type イベント発生元 (期待値: category, subCategory, subCategoryItem)
     * @param { Array } path 項目番号
     */
    checkDispToggle(type, ...path) {
      // 大項目 ON/OFF
      const toggleCategory = (category, newValue) => {
        category.isDisp = newValue;
      
        category.categoryItem.forEach(sub => {
          sub.isDisp = newValue;
      
          if (sub.vitalChild) {
            // N-1, N-2, N-3 すべて独立して更新
            sub.vitalChild.forEach(vc => {
              vc.isDisp = newValue;
              vc.subCategoryItem.forEach(item => item.isDisp = newValue);
            });
          }
      
          if (sub.subCategoryItem) {
            sub.subCategoryItem.forEach(item => item.isDisp = newValue);
          }
        });
      };
      
      // 小項目の ON/OFF
      const toggleItem = (item, newValue) => {
        item.isDisp = newValue;
      };
      
      // 大項目の全 OFF 判定
      const isAllOff = (category) => {
        return category.categoryItem.every(sub => {
          const noDispSub = !sub.isDisp;
          const noDispChild = sub.vitalChild
            ? sub.vitalChild.every(vc =>
                !vc.isDisp && vc.subCategoryItem.every(i => !i.isDisp)
              )
            : true;
      
          const noDispItems = sub.subCategoryItem
            ? sub.subCategoryItem.every(i => !i.isDisp)
            : true;
      
          return noDispSub && noDispChild && noDispItems;
        });
      };
 
      const categoryNo = path[0];
      const subCategoryNo = path[1];
      const itemNo = path[2];
      const isPatEventSub = path[3];

      let parentSubCategoryNo = this.getParentSubCategoryNo(subCategoryNo);

      // 大項目群 取得
      const category =
        categoryNo &&
        this.dispItemInfo.find((item) => {
          return item.categoryNo === categoryNo;
        });
      // 中項目の一番最初の要素取得
      let subCategory =
        parentSubCategoryNo &&
        category.categoryItem.find((item) => {
          return item.subCategoryNo === parentSubCategoryNo;
        });

      // 小項目の一番最初の要素取得
      let subCategoryItem = null;
      if (this.vitalMonitorSubCategoryNo2.includes(subCategoryNo)) {
        // バイタル・モニタグラフN-2
        subCategoryItem =
          itemNo &&
          subCategory.vitalChild[0].subCategoryItem.find((item) => {
            return item.itemNo === itemNo;
          });
      } else if (this.vitalMonitorSubCategoryNo3.includes(subCategoryNo)) {
        // バイタル・モニタグラフN-3
        subCategoryItem =
          itemNo &&
          subCategory.vitalChild[1].subCategoryItem.find((item) => {
            return item.itemNo === itemNo;
          });
      } else {
        subCategoryItem =
          itemNo &&
          subCategory.subCategoryItem.find((item) => {
            return item.itemNo === itemNo && item.isPatEventSub === isPatEventSub;
          });
      }
      
      // =====================================================
      //  大項目
      // =====================================================
      if (type === "category") {
        const newValue = !category.isDisp;
        toggleCategory(category, newValue);
        return;
      }
    
      // =====================================================
      //  中項目
      // =====================================================
      if (type === "subCategory") {
        let targetSub = null;
      
        // N-1
        if (subCategory.subCategoryNo === subCategoryNo) {
          targetSub = subCategory;
        }
        // N-2
        else if (this.vitalMonitorSubCategoryNo2.includes(subCategoryNo)) {
          targetSub = subCategory.vitalChild[0];
        }
        // N-3
        else if (this.vitalMonitorSubCategoryNo3.includes(subCategoryNo)) {
          targetSub = subCategory.vitalChild[1];
        }
      
        const newValue = !targetSub.isDisp;
      
        // ON → 大項目 ON
        if (newValue) {
          targetSub.isDisp = true;
          category.isDisp = true;
          return;
        }
      
        // OFF（小項目は連動しない）
        targetSub.isDisp = false;
      
        // 大項目が全部 OFF なら大項目 OFF
        if (isAllOff(category)) {
          category.isDisp = false;
        }
        return;
      }
    
      // =====================================================
      //  小項目
      // =====================================================
      if (type === "subCategoryItem") {
      
        const newValue = !subCategoryItem.isDisp;
        toggleItem(subCategoryItem, newValue);
      
        if (newValue) {
          // 小項目 ON → 大項目 ON
          category.isDisp = true;
          return;
        }
      
        // OFF の場合
        if (isAllOff(category)) {
          category.isDisp = false;
        }
        return;
      }
    },
    
    /**
     * 選択されている表示項目のレイアウトを取得する
     * @param 表示項目を選択した際にレイアウト項目を入れ替える
     */
    changeDispItem() {
      // 初期表示項目リストが1つも格納されていない場合処理終了
      if (this.initdispItemInfo.length === 0) {
        return;
      }
      this.dispItemInfo = this.initdispItemInfo.map(category => {
        // 指示/実績の場合、すべての項目を表示
        if (this.selectedDispClass === "0") {
          return category;
        }
      
        // 「指示」の場合
        if (this.selectedDispClass === "1") {
          return {
            ...category,
            categoryItem: category.categoryItem
              // 1. rstCd を持つ中項目を除外
              // 2. dataKey が vitalX の中項目を除外
              .filter(sub =>
                sub.rstCd === undefined &&
                !(sub.dataKey ?? "").startsWith("vital_")
              )
              .map(sub => ({
                ...sub,
                // 3. rstCd を持つ小項目を除外
                subCategoryItem: sub.subCategoryItem.filter(
                  item => item.rstCd === undefined
                )
              }))
          };
        }
        return category;
      });
    },

    /**
     * 大項目の表示非表示切替
     * @description
     *  中項目・小項目にひとつでもONがあれば大項目をONにする
     *  中項目・小項目がすべてOFFの場合は大項目をOFFにする
     */
    switchingItemDisp() {
      this.dispItemInfo.forEach(categoryInfo => {
        categoryInfo.isDisp = categoryInfo.categoryItem.some(sub => {
          // 中項目
          if (sub.isDisp) return true;
      
          // バイタル・モニタグラフ N-2 / N-3
          if (sub.vitalChild?.some(vc =>
            vc.isDisp || vc.subCategoryItem.some(item => item.isDisp)
          )) {
            return true;
          }
          // 通常小項目
          return sub.subCategoryItem.some(item => item.isDisp);
        });
      });
    },

    /**
     * 項目選択アイコン表示・非表示切替
     * @description バイタル・モニタ(グラフ)、患者イベント、施設イベントが＋アイコン表示対象
     * @param categoryNo    大項目番号
     * @param subCategoryNo 中項目番号
     */
    isSelectIcon(categoryNo, subCategoryNo) {
      return (
        this.vitalMonitorItemTargetSubCategoryNoList.includes(subCategoryNo) ||
        categoryNo === CATEGORY_NO.PAT_EVENT_CONTENT || 
        categoryNo === CATEGORY_NO.BBS_CONTENT
      )
    },

    /**
     * 小項目選択肢ポップオーバー表示
     * @description 小項目選択ポップオーバーを表示するとともに、大項目番号と中項目番号
     *  をもとに選択肢の情報を格納する
     * @param e ポップオーバーターゲット
     * @param categoryNo 大項目番号
     * @param subCategoryNo 中項目番号
     * @param subCategoryTitle 中項目名
     */
    showSelector(e, categoryNo, subCategoryNo, subCategoryTitle) {
      let parentSubCategoryNo = this.getParentSubCategoryNo(subCategoryNo);

      let temp = this.dispItemInfo
        .find((eleCategoryInfo) => {
          return categoryNo === eleCategoryInfo.categoryNo;
        })
        .categoryItem.find((eleSubCategoryInfo) => {
          return parentSubCategoryNo === eleSubCategoryInfo.subCategoryNo;
        });
      if (this.vitalMonitorSubCategoryNo2.includes(subCategoryNo)) {
        // バイタル・モニタグラフN-2
        temp = temp.vitalChild[0];
      } else if (this.vitalMonitorSubCategoryNo3.includes(subCategoryNo)) {
        // バイタル・モニタグラフN-3
        temp = temp.vitalChild[1];
      }

      // 大項目情報でループ
      this.dispItemInfo.forEach((eleCategory) => {
        // 大項目番号が一致する場合
        if (eleCategory.categoryNo === categoryNo) {
          // 中項目情報でループ
          eleCategory.categoryItem.forEach((eleSubCategory) => {
            let subCategory = null;
            if (eleSubCategory.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1) {
              // バイタル・モニタグラフ①-1～①-3入室～退室
              if (subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_2) {
                subCategory = eleSubCategory.vitalChild[0];
              } else if (subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_3) {
                subCategory = eleSubCategory.vitalChild[1];
              } else {
                subCategory = eleSubCategory;
              }
            } else if (eleSubCategory.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1) {
              // バイタル・モニタグラフ②-1～②-3入室～退室
              if (subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_2) {
                subCategory = eleSubCategory.vitalChild[0];
              } else if (subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_3) {
                subCategory = eleSubCategory.vitalChild[1];
              } else {
                subCategory = eleSubCategory;
              }
            } else if (eleSubCategory.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1) {
              // バイタル・モニタグラフ③-1～③-3入室～退室
              if (subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_2) {
                subCategory = eleSubCategory.vitalChild[0];
              } else if (subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_3) {
                subCategory = eleSubCategory.vitalChild[1];
              } else {
                subCategory = eleSubCategory;
              }
            } else if (eleSubCategory.subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1) {
              // バイタル・モニタグラフ④-1～④-3入室～退室
              if (subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_2) {
                subCategory = eleSubCategory.vitalChild[0];
              } else if (subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_3) {
                subCategory = eleSubCategory.vitalChild[1];
              } else {
                subCategory = eleSubCategory;
              }
            } else {
              subCategory = eleSubCategory;
            }
            // 中項目番号が一致するものを取得
            if (subCategory.subCategoryNo === subCategoryNo) {
              // 対象の中項目の現在表示中の小項目を格納
              this.selectedList = subCategory.subCategoryItem;
              // モニタグラフ設定を初期化
              this.selectedSetting.min.initValue = this.selectedList[0]
                ? this.selectedList[0].min
                : "";
              this.selectedSetting.min.editValue =
                this.selectedSetting.min.initValue;
              this.selectedSetting.max.editValue =
                this.selectedSetting.max.initValue;
            }
          });
        }
      });
      // ポップオーバー表示ターゲット情報格納
      this.popoverInfo.popoverTarget = e;
      // ポップオーバー表示位置情報格納
      this.popoverInfo.popoverDirection = "left";
      // ポップオーバータイトルを格納
      this.popoverInfo.titleLabel = subCategoryTitle;
      
      // 選択肢情報を格納
      if (this.isVitalMonitor(categoryNo, subCategoryNo)) {
        // バイタル・モニタグラフ
        for (let i = 0; i < this.selectVitalMonitorItemList.length; i++) {
          for (let j = 0; j < this.selectedList.length; j++) {
            if (
              this.selectVitalMonitorItemList[i].tableType ==
                this.selectedList[j].tableType &&
              this.selectVitalMonitorItemList[i].moniDataNo ==
                this.selectedList[j].itemNo
            ) {
              this.selectVitalMonitorItemList[i].lineColor =
                this.selectedList[j].itemColor;
              this.selectVitalMonitorItemList[i].pointType =
                this.selectedList[j].itemPoint;
            }
          }
        }
        // itemNoListの取得
        const selectedItemNoList = this.getSelectedItemNoList(false);
        // バイタル・モニタグラフ
        this.popoverInfo.selectInfoOptions = this.selectVitalMonitorItemList
          .map((m) => {
            if (
              m.isDisp === "1" ||
              selectedItemNoList.includes(m.moniDataNo)
            ) {
              return {
                // テーブル種別、バイタルモニタ区分、項目コードを"*"で結合した文字列をitemNoとする.
                itemNo: [m.tableType, m.vitalMonitorClass, m.moniDataNo].join(
                  "*"
                ),
                itemName: m.vitalMonitorItemName,
                itemColor: m.lineColor,
                itemPoint: m.pointType,
                isDisp: m.isDisp,
              };
            }
          })
          .filter(
            (item) =>
              item !== undefined &&
              item !== null &&
              Object.keys(item).length > 0
          );
          
      } else if (CATEGORY_NO.PAT_EVENT_CONTENT === categoryNo) {
        // 患者イベント
        // ポップオーバー選択肢生成
        this.buildPatEventOptions();
        
      } else if (CATEGORY_NO.BBS_CONTENT === categoryNo) {
        // 施設イベント
        // ポップオーバー選択肢生成
        this.buildBbsKindOptions(); 
      }
      
      // 現在選択中の情報を格納
      this.popoverInfo.selectedList = deepCopy(this.selectedList);
      
      if (this.isVitalMonitor(categoryNo, subCategoryNo)) {
        // バイタルモニタの場合には選択済リストを再設定する.
        // ※itemNoを変更する為
        
        // this.selectedList を直接操作してしまうとキャンセルボタンをクリックされた時に
        // 期待しない状態(itemCdに*で結合された文字列が設定)となる為.
        const tempSelectedList = deepCopy(this.selectedList);

        this.popoverInfo.selectedList = tempSelectedList.map((m) => {
          return {
            // テーブル種別、バイタルモニタ区分、項目コードを"*"で結合した文字列をitemNoとする.
            itemNo: [m.tableType, m.vitalMonitorClass, m.itemNo].join("*"),
            itemName: m.itemName,
            itemColor: m.itemColor,
            itemPoint: m.itemPoint,
          };
        });

      } else if (CATEGORY_NO.PAT_EVENT_CONTENT === categoryNo) {
        // 患者イベント
        let tempSelectedList = deepCopy(this.selectedList);
        this.popoverInfo.selectedList = tempSelectedList.map((m) => {
          if (m.isPatEventSub === 0) {
            return {
              itemNo:
                m.itemNo.toString().indexOf("*") > 0
                  ? m.itemNo
                  : "PAT_EVENT*" + m.itemNo,
              itemName: m.itemName,
              isPatEventSub: m.isPatEventSub,
            };
          } else {
            return {
              itemNo:
                m.itemNo.toString().indexOf("*") > 0
                  ? m.itemNo
                  : "PAT_EVENT_SUB*" + m.itemNo,
              itemName: m.itemName,
              isPatEventSub: m.isPatEventSub,
            };
          }
        });
        
      }

      // 対象となる項目の情報を格納
      this.popoverInfo.targetInfo = {
        categoryNo,
        subCategoryNo,
      };
      // ポップオーバーを表示
      this.popoverInfo.popoverVisible = true;
      this.popoverSearchQuery = null;

      let subCategoryInfo = this.dispItemInfo
        .find((eleCategoryInfo) => {
          return categoryNo === eleCategoryInfo.categoryNo;
        })
        .categoryItem.find((eleSubCategoryInfo) => {
          return parentSubCategoryNo === eleSubCategoryInfo.subCategoryNo;
        });
      let exam = null;
      if (this.vitalMonitorSubCategoryNo2.includes(subCategoryNo)) {
        // バイタル・モニタグラフN-2
        exam = subCategoryInfo.vitalChild[0];
      } else if (this.vitalMonitorSubCategoryNo3.includes(subCategoryNo)) {
        // バイタル・モニタグラフN-3
        exam = subCategoryInfo.vitalChild[1];
      } else { 
        // 上記以外（バイタル・モニタグラフN-1含む）
        exam = subCategoryInfo;
      }
      
      // グラフ上限値/下限値設定
      if (this.isVitalMonitor(categoryNo, subCategoryNo)) {
        exam.graphMax ??= "";
        exam.graphMin ??= "";
        this.graphMax = exam.graphMax;
        this.graphMin = exam.graphMin;
      } else {
        // バイタル・モニタグラフ以外はプロパティ削除
        delete exam.graphMax;
        delete exam.graphMin;
      }

    },
    /** 患者イベントポップオーバー選択肢生成 */
    buildPatEventOptions() {
      let categoryPat = [];
      this.mstPatEventCategory.forEach((cate) => {
        categoryPat.push(cate);
        this.mstPatEventSubCategoryPat.forEach((pat) => {
          if (cate.code === pat.categoryCd) {
            categoryPat.push(pat);
          }
        });
      });
      categoryPat.forEach((e) => {
        if (e.isPatEventSub === 0) {
          e.subCategoryName = e.name;
          e.subCategoryCd =
            e.code.toString().indexOf("*") > 0
              ? e.code
              : "PAT_EVENT*" + e.code;
        } else {
          e.subCategoryCd =
            e.subCategoryCd.toString().indexOf("*") > 0
              ? e.subCategoryCd
              : "PAT_EVENT_SUB*" + e.subCategoryCd;
        }
      });

      this.popoverInfo.selectInfoOptions = categoryPat.map((m) => {
        return {
          itemNo: m.subCategoryCd,
          itemName: m.subCategoryName,
          isPatEventSub: m.isPatEventSub,
        };
      });
    },
    /** 施設イベントポップオーバー選択肢生成 */
    buildBbsKindOptions() {
      this.popoverInfo.selectInfoOptions = this.mstBbsKind.map((m) => {
        return {
          itemNo: m.kindNo,
          itemName: m.kindName
        };
      });
    },
    /**
     * 選択情報を格納
     * @description
     *  小項目選択ポップオーバーで選択した情報を
     *  ポップオーバー内で保持する
     * @param cd 小項目番号
     */
    storageInfo(info, event) {
      const selectedList = this.popoverInfo.selectedList;
      const cd = info.itemNo;
      
      // 要素番号格納用
      let index = null;
      // 選択されたバイタル情報名格納用
      let itemName = null;
      // 選択肢から小項目番号の一致する項目名を取得
      this.popoverInfo.selectInfoOptions.forEach((vaitalInfo) => {
        itemName = vaitalInfo.itemNo === cd ? vaitalInfo.itemName : itemName;
      });
      // 選択したものが格納先にすでにあるのかをチェック
      selectedList.forEach((eleInfo, eleIndex) => {
        if (cd === eleInfo.itemNo) {
          index = eleIndex;
        }
      });
      // 格納先にない場合
      if (null === index) {
        // 選択情報を格納
        // 格納されている選択情報(左+右)が5つ以下の場合小項目情報を格納
        selectedList.push({
          isDisp: true,
          itemName,
          itemNo: cd,
          itemColor: info.itemColor,
          itemPoint: info.itemPoint,
          graph: info.graph,
          itemDate: info.itemDate,
          plans: info.plans,
          unit: info.unit,
          isPatEventSub: info.isPatEventSub
        });
      } else {
        // すでに格納されている選択情報ある場合削除
        selectedList.splice(index, 1);
      }
      // 選択可能な上限を制限する
      this.judgeMaxNum(selectedList);
    },

    /**
     * 最大選択数の判断
     * @description 最大選択数の判断
     * @param maxSelectedNum 選択可能な上限
     */
    judgeMaxNum(selectedList) {
      const { categoryNo, subCategoryNo } = this.popoverInfo.targetInfo;
      if (selectedList.length >= MAX_COLUMN && this.isVitalMonitor(categoryNo, subCategoryNo)) {
        selectedList.splice(MAX_COLUMN, 1);
      }
    },

    /**
     * 選択肢クラスの設定
     * @description 選択肢の項目を選択状態と未選択状態でクラスを分ける
     * @param cd 小項目番号
     */
    setListClass(cd) {
      const selectedList = this.popoverInfo.selectedList;
      const obj = {
        "selected-color": false,
        "dis-selected-color": false,
      };
      // 選択状態フラグを格納
      let isSelected = false;
      // 格納された選択肢情報をループ
      selectedList.forEach((eleInfo) => {
        // 格納された選択状態リストと対象のコードが一致した場合true
        isSelected = eleInfo.itemNo === cd ? true : isSelected;
      });
      // 選択中クラスを付与
      obj["selected-color"] = isSelected;
      // 未選択中クラスを付与
      obj["dis-selected-color"] = !isSelected;
      return obj;
    },

    /**
     * サブカテゴリ番号がバイタルモニタグラフか否かを返す.
     * ※サブカテゴリでの判定を行う場合、categoryNo は必ず[2]である事
     *
     * @param {Integer} categoryNo カテゴリ番号　※未使用
     * @param {Integer} subCategoryNo サブカテゴリ番号
     * @returns {Boolean} true : バイタルモニタグラフ、false : それ以外
     */
    isVitalMonitor(categoryNo, subCategoryNo) {
      return this.vitalMonitorItemTargetSubCategoryNoList.includes(subCategoryNo);
    },

    /**
     * ポップオーバーで選択した情報を格納する
     */
    saveChanges() {
      // 選択したバイタル情報をコピー
      this.selectedList = deepCopy(this.popoverInfo.selectedList);
      
      // 対象の中項目に選択した小項目を設定する
      this.setVitalInfoItem(
        this.popoverInfo.targetInfo.categoryNo,
        this.popoverInfo.targetInfo.subCategoryNo
      );
      
      // カテゴリがバイタルモニタ情報の場合
      // コードを分解する.
      if (
        this.isVitalMonitor(
          this.popoverInfo.targetInfo.categoryNo,
          this.popoverInfo.targetInfo.subCategoryNo
        )
      ) {
        let selectedVitalMonitorItemList = [];
        this.selectedList.forEach((item) => {
          if (item.itemNo.toString().indexOf("*") > 0) {
            let isAddMonitor = false;
            const splitItemCd = item.itemNo.split("*");
            item.tableType = Number(splitItemCd[0]);
            item.vitalMonitorClass = splitItemCd[1];
            item.itemNo = isNaN(splitItemCd[2])
              ? splitItemCd[2]
              : Number(splitItemCd[2]);
            item.isDisp = true;
            isAddMonitor =
              !isNaN(item.itemNo) && item.itemNo > 10000 ? true : false;
            if (
              isAddMonitor &&
              this.mstAddMonitorListDisp.includes(item.itemNo - 10000)
            ) {
              item.isDispflag = true;
            }
          } else {
            item.tableType = null;
            item.vitalMonitorClass = null;
            item.isDisp = true;
          }

          selectedVitalMonitorItemList.push(item);
        });
        this.selectedList = selectedVitalMonitorItemList;
      }
      
      // 患者イベント
      if (
        this.popoverInfo.targetInfo.categoryNo === CATEGORY_NO.PAT_EVENT_CONTENT
      ) {
        this.selectedList.forEach((e) => { 
          const temp = e.itemNo.split("*"); 
          e.itemNo = parseInt(temp[temp.length - 1]);
          e.isDisp = true; 
        });       
      }
  
      this.selectedSetting.min.initValue = "";
      this.selectedSetting.min.editValue = "";
      this.selectedSetting.max.initValue = "";
      this.selectedSetting.max.editValue = "";
      this.graphMax = "";
      this.graphMin = "";

      // ポップオーバーを閉じる
      this.popoverInfo.popoverVisible = false;
    },
    /**
     * 選択した項目を追加
     * @description 小項目選択ポップオーバーで選択した項目をレイアウトマスタに格納する
     * @param categoryNo 大項目番号
     * @param subCategoryNo 中項目番号
     */
    setVitalInfoItem(categoryNo, subCategoryNo) {
      let parentSubCategoryNo = this.getParentSubCategoryNo(subCategoryNo);

      // 小項目情報格納用
      const subCategoryItem = [];
      // 選択した小項目番号を格納(左+右)
      this.selectedList.forEach((eleInfo) => {
        subCategoryItem.push(eleInfo);
      });
       
      // 大項目情報でループ
      const categoryInfo = this.dispItemInfo.find((eleCategoryInfo) => {
        // 大項目番号が一致するものを取得
        return categoryNo === eleCategoryInfo.categoryNo;
      });
      // 中項目情報でループ
      const subCategoryInfo = categoryInfo.categoryItem.find(
        (eleSubCategoryInfo) => {
          // 中項目番号が一致するものを取得
          return parentSubCategoryNo === eleSubCategoryInfo.subCategoryNo;
        }
      );

      // ポップオーバーで選択した項目情報を格納
      if (this.vitalMonitorSubCategoryNo2.includes(subCategoryNo)) {
        // バイタル・モニタグラフN-2
        subCategoryInfo.vitalChild[0].subCategoryItem = subCategoryItem;
        subCategoryInfo.vitalChild[0].isDisp = 0 !== subCategoryItem.length;
      } else if (this.vitalMonitorSubCategoryNo3.includes(subCategoryNo)) {
        // バイタル・モニタグラフN-3
        subCategoryInfo.vitalChild[1].subCategoryItem = subCategoryItem;
        subCategoryInfo.vitalChild[1].isDisp = 0 !== subCategoryItem.length;
      } else {
        subCategoryInfo.subCategoryItem = subCategoryItem;
        subCategoryInfo.isDisp = 0 !== subCategoryItem.length;
      }
    },
    /**
     * @description ランダムスタイル
     */
    changeColorDetail(categoryNo, subCategoryNo) {
      let parentSubCategoryNo = this.getParentSubCategoryNo(subCategoryNo);

      for (let i = 0; i < this.dispItemInfo.length; i++) {
        if (categoryNo === this.dispItemInfo[i].categoryNo) {
          for (let j = 0; j < this.dispItemInfo[i].categoryItem.length; j++) {
            if (
              this.dispItemInfo[i].categoryItem[j].subCategoryNo ===
              parentSubCategoryNo
            ) {
              // バイタル・モニタグラフN-②入室～退室、バイタル・モニタグラフN-3入室～退室
              if (this.vitalMonitorSubCategoryNo2.includes(subCategoryNo) || this.vitalMonitorSubCategoryNo3.includes(subCategoryNo)) {
                for (
                  let l = 0;
                  l < this.dispItemInfo[i].categoryItem[j].vitalChild.length;
                  l++
                ) {
                  if (
                    this.dispItemInfo[i].categoryItem[j].vitalChild[l]
                      .subCategoryNo === subCategoryNo
                  ) {
                    for (
                      let m = 0;
                      m <
                      this.dispItemInfo[i].categoryItem[j].vitalChild[l]
                        .subCategoryItem.length;
                      m++
                    ) {
                      let color =
                        "#" +
                        Math.floor(Math.random() * 0xffffff)
                          .toString(16)
                          .padStart(6, "0");
                      this.dispItemInfo[i].categoryItem[j].vitalChild[
                        l
                      ].subCategoryItem[m].itemColor = color;
                      let pointNum = parseInt(Math.random() * 10 + 1);
                      this.dispItemInfo[i].categoryItem[j].vitalChild[
                        l
                      ].subCategoryItem[m].itemPoint =
                        REPORT_GRAPH.SELECT_ITEM_PLOT_TYPE[pointNum].value;
                    }
                  }
                }
              } else {
                for (
                  let k = 0;
                  k <
                  this.dispItemInfo[i].categoryItem[j].subCategoryItem.length;
                  k++
                ) {
                  let color =
                    "#" +
                    Math.floor(Math.random() * 0xffffff)
                      .toString(16)
                      .padStart(6, "0");
                  this.dispItemInfo[i].categoryItem[j].subCategoryItem[
                    k
                  ].itemColor = color;
                  let pointNum = parseInt(Math.random() * 10 + 1);
                  this.dispItemInfo[i].categoryItem[j].subCategoryItem[
                    k
                  ].itemPoint =
                    REPORT_GRAPH.SELECT_ITEM_PLOT_TYPE[pointNum].value;
                }
              }
            }
          }
        }
      }
      for (let i = 0; i < this.dispItemInfo.length; i++) {
        if (this.dispItemInfo[i].categoryNo === 1) {
          for (let j = 0; j < this.dispItemInfo[i].categoryItem.length; j++) {
            // バイタル・モニタグラフ①-①入室～退室
            if (this.dispItemInfo[i].categoryItem[j].subCategoryNo === SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1) {
              let temp = this.dispItemInfo[i].categoryItem[j].subCategoryName;
              this.dispItemInfo[i].categoryItem[j].subCategoryName = null;
              this.dispItemInfo[i].categoryItem[j].subCategoryName = temp;
            }
          }
        }
      }
    },
    /**
     * 検索機能
     */
    fuzzyQuery() {
      if (this.popoverSearchQuery == "" || this.popoverSearchQuery == null) {
        // 患者イベント
        if (this.popoverInfo.targetInfo.categoryNo === CATEGORY_NO.PAT_EVENT_CONTENT) {
          // ポップオーバー選択肢生成
          this.buildPatEventOptions();
        } else if (this.popoverInfo.targetInfo.categoryNo === CATEGORY_NO.BBS_CONTENT) {
          // 施設イベント
          // ポップオーバー選択肢生成
          this.buildBbsKindOptions();
        }
      } else {
        const content = new RegExp(this.popoverSearchQuery, "gi");
        this.popoverInfo.selectInfoOptions =
          this.popoverInfo.selectInfoOptions.filter((item) => {
            return item.itemName.search(content) > -1;
          });
      }
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // 確認ボタンの活性切替
    switchButton() {
      // 編集済表示内容の取得
      const editedDispItemInfoJSON = JSON.parse(this.editRecord.dispItemInfo); 
      // 画面表示情報 ≠ 初期表示内容の場合
      if (
        this.isEditedName ||
        this.editRecord.dispClass !== this.initDispClass ||
        !_.isEqual(editedDispItemInfoJSON, this.initDispItemInfoJSON)
      ) {
        // 確認ボタンの活性化
        EventBus.$emit("mstHolidayRegistered", false);
      } else {
        // 確認ボタンの非活性化
        EventBus.$emit("mstHolidayRegistered", true);
      }
    },

    /**
     * 最小の表示項目を表示するかどうかを制御します
     * @param categoryNo
     * @param subCategoryNo
     * @returns {boolean}
     */
    showGrandson(categoryNo, subCategoryNo) {
      switch (categoryNo) {
        case CATEGORY_NO.TREATMENT_CONTENT:
          // 治療情報：治療予定、バイタル・モニタグラフ①-1～④-3　入室～退室のみ表示
          return subCategoryNo === 1 || subCategoryNo === 5 || this.vitalMonitorItemTargetSubCategoryNoList.includes(subCategoryNo);

        case CATEGORY_NO.EXAM_CONTENT:
          // 検査：検査予定のみ表示
          return subCategoryNo === 2;
          
        case CATEGORY_NO.RAD_CONTENT:
        case CATEGORY_NO.PRESCRIPTION_CONTENT:
          // 一般撮影検査、処方
          return false;

        default:
          // 上記以外のカテゴリは常に表示
          return true;
      }      
    },
    closePopover() {
      this.graphMax = "";
      this.graphMin = "";
      this.popoverInfo.popoverVisible = false;
    },
    graphValueChange(event, flag, key) {
      // 限界値判定
      if (flag === 1) {
        let value = event.target.value;
        if (value == this.max && this.blurFlg) {
          this.graphMax = this.min;
          this.blurFlg = false;
        } else if (value == this.min && this.blurFlg) {
          this.graphMax = this.max;
          this.blurFlg = false;
        }
      } else if (flag === 2) {
        let value = event.target.value;
        if (value == this.max && this.blurFlg) {
          this.graphMin = this.min;
          this.blurFlg = false;
        } else if (value == this.min && this.blurFlg) {
          this.graphMin = this.max;
          this.blurFlg = false;
        }
      }
      this.focusFlg[key] = false;

      this.graphMax =
        this.graphMax != null && "" !== this.graphMax
          ? Number(this.graphMax).toFixed(2)
          : "";
      this.graphMin =
        this.graphMin != null && "" !== this.graphMin
          ? Number(this.graphMin).toFixed(2)
          : "";

      let parentSubCategoryNo = this.getParentSubCategoryNo(
        this.popoverInfo.targetInfo.subCategoryNo
      );

      const CategoryInfo = this.dispItemInfo.find((eleCategoryInfo) => {
        return (
          this.popoverInfo.targetInfo.categoryNo === eleCategoryInfo.categoryNo
        );
      });
      const temp = CategoryInfo.categoryItem.find((eleSubCategoryInfo) => {
        return parentSubCategoryNo === eleSubCategoryInfo.subCategoryNo;
      });

      if (flag === 1) {
        // バイタル・モニタグラフN-2
        if (this.vitalMonitorSubCategoryNo2.includes(this.popoverInfo.targetInfo.subCategoryNo)) {
          temp.vitalChild[0].graphMax = this.graphMax;
        // バイタル・モニタグラフN-3
        } else if (this.vitalMonitorSubCategoryNo3.includes(this.popoverInfo.targetInfo.subCategoryNo)) {
          temp.vitalChild[1].graphMax = this.graphMax;
        } else {
          temp.graphMax = this.graphMax;
        }
      } else {
        // バイタル・モニタグラフN-2
        if (this.vitalMonitorSubCategoryNo2.includes(this.popoverInfo.targetInfo.subCategoryNo)) {
          temp.vitalChild[0].graphMin = this.graphMin;
        // バイタル・モニタグラフN-3
        } else if (this.vitalMonitorSubCategoryNo3.includes(this.popoverInfo.targetInfo.subCategoryNo)) {
          temp.vitalChild[1].graphMin = this.graphMin;
        } else {
          temp.graphMin = this.graphMin;
        }
      }

    },
    
    /** popover選択肢の患者イベントのサブカテゴリ判定 */
    isPatEventSub(categoryNo, selectedInfo) {
      if (categoryNo === 5) {
        return selectedInfo.isPatEventSub === 1;
      } else {
        return false;
      }
    },
    /** popover選択肢をクリック可能かどうか */
    isSelectable(categoryNo, selectedInfo) {
      // 患者イベント以外は常に選択可
      if (categoryNo !== 5) return true;
    
      // 患者イベントの場合のみサブカテゴリ制御
      return this.isPatEventSub(categoryNo, selectedInfo);
    },    

    // 親サブカテゴリNoの取得
    getParentSubCategoryNo(subCategoryNo) {
      const parentMap = {
        [SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_2]: SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1,
        [SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_3]: SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1,
        [SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_2]: SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1,
        [SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_3]: SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1,
        [SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_2]: SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1,
        [SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_3]: SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1,
        [SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_2]: SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1,
        [SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_3]: SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1,
      };

      return parentMap[subCategoryNo] ?? subCategoryNo;
    },

    /**
     * itmNoListの取得
     * @param isComprehensive
     */
    getSelectedItemNoList(isComprehensive) {
      // 初期化処理
      let selectedItemNoList = [];
      // 選択済リストループ処理
      this.selectedList.forEach((item) => {
        // itemNoの取得
        const itemNo = isComprehensive
          ? String(item.moniNo)
          : String(item.itemNo);
        // itemNoの追加
        selectedItemNoList.push(itemNo);
      });
      // 戻り値
      return selectedItemNoList;
    },
  },
};
</script>

<style scoped>
.layout-item {
  border-bottom: 1px solid #999;
  transition: max-height 500ms;
  overflow: hidden;
  max-height: 99999px;
  min-height: 30px;
}

.layout-item-fallback,
.layout-item.layout-item-dragging {
  max-height: 35px;
}

.color-header {
  min-height: 30px;
}

ons-col.layout-item,
.color-header {
  border-left: 1px solid #999;
  border-right: 1px solid #999;
}

ons-col.layout-item {
  padding-left: 4px;
}

.color-header .layout-item {
  border: 0;
  padding-left: 0 !important;
}

.color-header .sub-category-handle-area {
  margin-top: 0 !important;
}

.checkbox-style {
  margin: 0px;
  vertical-align: middle;
}

.ghost {
  opacity: 0.5;
}

.drag {
  display: none;
}

.layout-name-area,
.disp-period,
.disp-item-name-area {
  padding-left: 8px;
  vertical-align: top;
}

.disp-item-no,
.k-textbox {
  width: 100%;
}

.disp-item-content-area {
  overflow-y: scroll;
  height: 100%;
}

.disp-item-area {
  height: 100%;
  width: 100%;
  border-collapse: collapse;
}

.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}

.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  border: 1px solid lightgray;
  text-align: left;
}

.disp-item-area tr:nth-child(3) td:nth-child(3) {
  height: 99%;
}

.category-handle {
  cursor: move;
  float: right;
  margin: 2px 5px;
}

.right-category-handle {
  margin-right: 5px;
}

.sub-category-handle-area {
  float: right;
  margin-top: 2px;
  margin-right: 5px;
}

.item-handle-icon {
  margin: 0 4px;
}

.popover-style >>> .popover__content {
  width: 500px;
  height: 100%;
  max-height: 90vh;
  padding: 25px;
}

.popover-style >>> .label-style {
  white-space: nowrap;
}

.selector-title {
  margin: 0;
}

.mult-selector {
  overflow-y: auto;
  max-height: 250px;
  min-height: 250px;
  border: solid 1px #bbbbbb;
}

.select-label-style {
  padding: 0px 2px 1px;
  white-space: nowrap;
  box-sizing: border-box;
}

.selected-color {
  background-color: #0076ff !important;
  color: white;
  width: max-content;
  min-width: 100%;
}

:disabled + .checkbox__checkmark {
  opacity: 100;
}

.dis-selected-color:hover {
  background-color: #dddddd;
}

.button-cancel {
  float: left;
}

.button-confirm {
  float: right;
}

.rdo-period {
  margin-right: 10px;
}

.graph-setting > div {
  margin-bottom: 5px;
}

.graph-setting:first-child {
  margin-right: 5px;
}

.graph-setting:nth-child(2) {
  margin-left: 5px;
}

.graph-setting >>> label {
  margin-right: 5px;
}

.flex-container {
  padding: 2px 5px;
  height: auto;
  align-items: flex-start;
  line-height: unset !important;
}

ons-col.color-header {
  background-image: unset !important;
}
.search-style {
  width: 100%;
}
.category-disabled {
  pointer-events: none;
}
.button {
  float: left;
}
.btn3-normal {
  font-size: 1em;
  line-height: 1.5;
}
</style>
