<template>
  <div class="main-area">
    <table style="min-width: 1050px; overflow-x: auto" class="disp-item-area">
      <tr>
        <td class="layout-name-area" height="30" width="150">レイアウト名</td>
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
          <label>表示期間</label>
        </td>
        <td>
          <v-ons-radio
            v-model="selectedPeriod"
            :input-id="'rdoPeriod0'"
            :value="'0'"
            modifier="round"
            @change="setDispPeriod($event.target.value)"
          />
          <label :for="'rdoPeriod0'" class="rdo-period">3日・7日・14日</label>
          <v-ons-radio
            v-model="selectedPeriod"
            :input-id="'rdoPeriod1'"
            :value="'1'"
            modifier="round"
            @change="setDispPeriod($event.target.value)"
          />
          <label :for="'rdoPeriod1'">12週・6ヶ月・1年・3年</label>
        </td>
      </tr>
      <tr>
        <td class="disp-item-name-area">表示項目</td>
        <td>
          <div class="disp-item-content-area">
            <!--            <draggable>-->
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
                <v-ons-col class="color-header flex-container" width="25%">
                  <label>
                    <v-ons-checkbox
                      v-model="category.isDisp"
                      class="checkbox-style"
                      @input="checkDispToggle('category', category.categoryNo)"
                    />
                    {{ category.categoryName }}
                    <div
                      v-if="
                        (category.categoryNo >= 2 &&
                          category.categoryNo <= 11) ||
                        (category.categoryNo >= 18 &&
                          category.categoryNo <= 19) ||
                        (category.categoryNo >= 1002 &&
                          category.categoryNo <= 1015) ||
                        (category.categoryNo >= 1020 &&
                          category.categoryNo <= 1021)
                      "
                    >
                      <button
                        class="btn3-normal"
                        @click="changeColor(category)"
                      >
                        ランダム
                      </button>
                    </div>
                  </label>
                  <v-ons-icon icon="fa-bars" class="category-handle" />
                </v-ons-col>
                <v-ons-col
                  v-if="category.categoryNo === treatmentItemCategoryNo"
                >
                  <draggable
                    v-model="category.categoryItem"
                    v-bind="{
                      ...dragOptions,
                      handle: '.sub-category-handle',
                    }"
                    @choose="choose($event,category.categoryNo)"
                    @end="finishTreatCondDragging()"
                  >
                    <v-ons-row
                      v-for="subCategory in treatCondSubCategory"
                      :key="subCategory.subCategoryNo"
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
                            v-model="subCategory.isDisp"
                            class="checkbox-style"
                            style="float: left; margin-top: 5px"
                            :disabled="
                              ((1 === subCategory.subCategoryNo ||
                                2 === subCategory.subCategoryNo) &&
                              isDisabledRequiredItem)  ||
                              treatDisabledConfirm(category, subCategory)
                            "
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
                            v-if="
                              (subCategory.subCategoryNo >= 58 &&
                                subCategory.subCategoryNo <= 61) ||
                              (subCategory.subCategoryNo >= 65 &&
                                subCategory.subCategoryNo <= 72)
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
                            v-if="
                              (subCategory.subCategoryNo >= 58 &&
                                subCategory.subCategoryNo <= 61) ||
                              (subCategory.subCategoryNo >= 65 &&
                                subCategory.subCategoryNo <= 72)
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
                                  subCategory.subCategoryNo
                                )
                              "
                              v-if="
                                (subCategory.subCategoryNo >= 58 &&
                                  subCategory.subCategoryNo <= 61) ||
                                (subCategory.subCategoryNo >= 65 &&
                                  subCategory.subCategoryNo <= 72)
                              "
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
                          @choose="choose($event,category.categoryNo)"
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
                            :key="`${subCategoryItem.tableType}${subCategoryItem.itemNo}`"
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
                              :disabled="
                                (1 === subCategory.subCategoryNo ||
                                  2 === subCategory.subCategoryNo) &&
                                isDisabledRequiredItem
                              "
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
                                <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start-->
                                {{
                                  subCategoryItem.isDispflag == true
                                    ? "【削除済み】"
                                    : ""
                                }}
                                <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end-->
                                {{ subCategoryItem.itemName }}
                              </div>
                              <div
                                style="width: 15%; display: inline-block"
                                v-if="
                                  (subCategory.subCategoryNo >= 58 &&
                                    subCategory.subCategoryNo <= 61) ||
                                  (subCategory.subCategoryNo >= 65 &&
                                    subCategory.subCategoryNo <= 72)
                                "
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
                                v-if="
                                  (subCategory.subCategoryNo >= 58 &&
                                    subCategory.subCategoryNo <= 61) ||
                                  (subCategory.subCategoryNo >= 65 &&
                                    subCategory.subCategoryNo <= 72)
                                "
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
                        :key="vitalChildItem.subCategoryNo"
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
                              :disabled="
                                ((vitalChildItem.subCategoryNo === 1 ||
                                  vitalChildItem.subCategoryNo === 2) &&
                                isDisabledRequiredItem) || 
                                treatDisabledConfirm(category, vitalChildItem)
                              "
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
                            @choose="choose($event,category.categoryNo)"
                            @end="isDraggingSubCategoryItem = false"
                          >
                            <v-ons-col
                              v-for="vitalChildSubCategoryItem in vitalChildItem.subCategoryItem"
                              :key="`${vitalChildSubCategoryItem.tableType}${vitalChildSubCategoryItem.itemNo}`"
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
                                :disabled="
                                  (1 === vitalChildItem.subCategoryNo ||
                                    2 === vitalChildItem.subCategoryNo) &&
                                  isDisabledRequiredItem
                                "
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
                                  v-if="
                                    (vitalChildItem.subCategoryNo >= 58 &&
                                      vitalChildItem.subCategoryNo <= 61) ||
                                    (vitalChildItem.subCategoryNo >= 65 &&
                                      vitalChildItem.subCategoryNo <= 72)
                                  "
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
                                  v-if="
                                    (vitalChildItem.subCategoryNo >= 58 &&
                                      vitalChildItem.subCategoryNo <= 61) ||
                                    (vitalChildItem.subCategoryNo >= 65 &&
                                      vitalChildItem.subCategoryNo <= 72)
                                  "
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
                <v-ons-col v-else>
                  <draggable
                    v-model="category.categoryItem"
                    v-bind="{
                      ...dragOptions,
                      handle: '.sub-category-handle',
                    }"
                    @choose="choose($event,category.categoryNo)"
                    @end="isDraggingSubCategory = false"
                  >
                    <v-ons-row
                      v-for="subCategory in category.categoryItem"
                      :key="subCategory.subCategoryNo"
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
                          :disabled="disabledConfirm(category, subCategory)"
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
                        <span
                          style="
                            width: 27%;
                            display: inline-block;
                            height: 30px;
                          "
                          v-if="
                            (category.categoryNo >= 2 &&
                              category.categoryNo <= 11) ||
                            (category.categoryNo >= 18 &&
                              category.categoryNo <= 19) ||
                            (category.categoryNo >= 1002 &&
                              category.categoryNo <= 1015) ||
                            (category.categoryNo >= 1020 &&
                              category.categoryNo <= 1021)
                          "
                        >
                          グラフの色
                        </span>
                        <span
                          style="
                            width: 20%;
                            display: inline-block;
                            height: 30px;
                          "
                          v-if="
                            (category.categoryNo >= 2 &&
                              category.categoryNo <= 11) ||
                            (category.categoryNo >= 18 &&
                              category.categoryNo <= 19) ||
                            (category.categoryNo >= 1002 &&
                              category.categoryNo <= 1011) ||
                            (category.categoryNo >= 1020 &&
                              category.categoryNo <= 1021)
                          "
                        >
                          グラフの形状
                        </span>

                        <span
                          style="width: 10%; display: inline-block"
                          v-if="
                            category.categoryNo >= 1012 &&
                            category.categoryNo <= 1015
                          "
                        >
                          集計期間
                        </span>

                        <span
                          v-if="
                            category.categoryNo === 1028 && medicationSupport
                          "
                        >
                          <kendo-dropdownlist
                            v-model="medicationSupportChoose"
                            :data-source="getmedicationSupportData()"
                            :data-text-field="'text'"
                            :data-value-field="'value'"
                            style="
                              width: auto;
                              min-width: 100px;
                              z-index: 1;
                              font-size: inherit;
                              text-align: center;
                            "
                            class="common-style-input"
                            @change="
                              syncMedicationSupport($event),
                                saveMedicationSupport()
                            "
                          />
                        </span>

                        <span
                          v-if="
                            category.categoryNo >= 1012 &&
                            category.categoryNo <= 1015 &&
                            subCategory.subCategoryItem.length > 0
                          "
                        >
                          <!-- add 鞠 5971 @select="summaryDateChange($event, subCategory)"-->
                          <kendo-dropdownlist
                            v-model="subCategory.summaryDate"
                            :data-source="getDate()"
                            :data-text-field="'text'"
                            :data-value-field="'value'"
                            style="
                              width: 100px;
                              z-index: 1;
                              font-size: 16px;
                              text-align: center;
                            "
                            class="common-style-input"
                            @select="summaryDateChange($event, subCategory)"
                          />
                        </span>
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
                            :key="`${subCategoryItem.tableType}${subCategoryItem.itemNo}`"
                            @mouseup="isDraggingSubCategoryItem = false"
                            @touchend="isDraggingSubCategoryItem = false"
                            class="layout-item"
                            v-for="subCategoryItem in subCategory.subCategoryItem"
                          >
                            <v-ons-checkbox
                              v-if="subCategory.component === 'drug-graph'"
                              v-model="subCategoryItem.isDisp"
                              class="checkbox-style"
                              :disabled="false"
                              @input="
                                checkDispToggle(
                                  'subCategoryItem',
                                  category.categoryNo,
                                  subCategory.subCategoryNo,
                                  subCategoryItem.itemNo
                                )
                              "
                            />
                            <v-ons-checkbox
                              v-else
                              v-model="subCategoryItem.isDisp"
                              class="checkbox-style"
                              :disabled="false"
                              @input="
                                checkDispToggle(
                                  'subCategoryItem',
                                  category.categoryNo,
                                  subCategory.subCategoryNo,
                                  subCategoryItem.itemNo
                                )
                              "
                            />
                            <span v-if="subCategory.component === 'drug-graph'">
                              <div style="width: 32%; display: inline-block">
                                <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start-->
                                <!--{{
                                    subCategoryItem.graph +
                                    " / " +
                                    subCategoryItem.itemName
                                  }}-->
                                {{ subCategoryItem.graph + " / " }}
                                {{
                                  subCategoryItem.isDispflag
                                    ? "【削除済み】"
                                    : ""
                                }}
                                {{ subCategoryItem.itemName }}
                                <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end-->
                              </div>
                              <div
                                style="width: 36%; display: inline-block"
                                v-if="
                                  category.categoryNo >= 1012 &&
                                  category.categoryNo <= 1015
                                "
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
                                style="width: 10%; display: inline-block"
                                v-if="
                                  category.categoryNo >= 1012 &&
                                  category.categoryNo <= 1015
                                "
                              >
                                <div v-if="subCategoryItem.graph === '処方'">
                                  日
                                </div>
                                <kendo-dropdownlist
                                  v-else
                                  v-model="subCategoryItem.itemDate"
                                  :data-source="getDate()"
                                  :data-text-field="'text'"
                                  :data-value-field="'value'"
                                  style="
                                    width: 100px;
                                    z-index: 1;
                                    font-size: 16px;
                                    text-align: center;
                                  "
                                  class="common-style-input"
                                />
                              </div>
                            </span>
                            <span
                              v-else-if="
                                subCategory.component === 'comprehensive'
                              "
                            >
                              <div style="width: 32%; display: inline-block">
                                <span
                                  v-if="subCategoryItem.graph !== undefined"
                                  >{{ subCategoryItem.graph + " / " }}</span
                                >
                                <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start-->
                                {{
                                  subCategoryItem.isDispflag
                                    ? "【削除済み】"
                                    : ""
                                }}
                                <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end-->
                                <span>{{ subCategoryItem.itemName }}</span>
                              </div>
                              <div
                                style="width: 26%; display: inline-block"
                                v-if="subCategoryItem.itemColor !== undefined"
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
                                style="width: 25%; display: inline-block"
                                v-if="subCategoryItem.itemPoint !== undefined"
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
                              <!-- add #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start -->
                              <div
                                style="
                                  position: relative;
                                  top: -7px;
                                  display: inline-block;
                                "
                                v-if="
                                  subCategoryItem.itemNo != 'prediction' &&
                                  subCategoryItem.itemNo != 'regression_line' &&
                                  subCategoryItem.itemDivision == 2 &&
                                  category.categoryNo >= 1024 &&
                                  category.categoryNo <= 1027
                                "
                              >
                                <v-ons-select
                                  v-model="subCategoryItem.itemExamClass"
                                >
                                  <option
                                    v-for="option in examOrderList"
                                    :key="option.examOrderCode"
                                    :value="option.examOrderCode"
                                  >
                                    {{ option.examOrderName }}
                                  </option>
                                </v-ons-select>
                              </div>
                              <!-- 治療条件情報表示場合 -->
                              <div
                                style="
                                  position: relative;
                                  top: -7px;
                                  display: inline-block;
                                "
                                v-if="
                                  subCategoryItem.itemDivision == 3 &&
                                  category.categoryNo >= 1024 &&
                                  category.categoryNo <= 1027"
                              >
                                <v-ons-select
                                  v-model="subCategory.treatmentStatus"
                                >
                                  <option
                                    v-for="option in treatmentStatusList"
                                    :key="option.cd"
                                    :value="option.cd"
                                  >
                                    {{ option.name }}
                                  </option>
                                </v-ons-select>
                              </div>
                              <!-- add #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end -->
                              <div
                                style="width: 10%; display: inline-block"
                                v-if="subCategoryItem.itemDate !== undefined"
                              >
                                <div v-if="subCategoryItem.graph === '処方'">
                                  日
                                </div>
                                <kendo-dropdownlist
                                  v-else
                                  v-model="subCategoryItem.itemDate"
                                  :data-source="getDate()"
                                  :data-text-field="'text'"
                                  :data-value-field="'value'"
                                  style="
                                    width: 100px;
                                    z-index: 1;
                                    font-size: inherit;
                                    text-align: center;
                                  "
                                  class="common-style-input"
                                />
                              </div>
                            </span>
                            <span v-else>
                              <div style="width: 32%; display: inline-block">
                                <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start-->
                                {{
                                  subCategoryItem.isDispflag
                                    ? "【削除済み】"
                                    : ""
                                }}
                                <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end-->
                                {{ subCategoryItem.itemName }}
                              </div>
                              <div
                                style="width: 26%; display: inline-block"
                                v-if="
                                  category.categoryNo === 1018 ||
                                  category.categoryNo === 1019 ||
                                  category.categoryNo === 1022
                                "
                              >
                                <v-ons-radio
                                  v-model="subCategoryItem.plans"
                                  modifier="round"
                                  :value="'予定'"
                                  :name="getCheckBox(subCategoryItem, 1)"
                                />
                                予定
                                <v-ons-radio
                                  v-model="subCategoryItem.plans"
                                  modifier="round"
                                  :value="'実績'"
                                  :name="getCheckBox(subCategoryItem, 1)"
                                />
                                実績
                              </div>
                              <!-- mod redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy start -->
                              <div
                                style="width: 26%; display: inline-block"
                                v-if="category.categoryNo === 1022"
                              >
                                <!-- mod redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy end -->
                                <v-ons-radio
                                  v-model="subCategoryItem.unit"
                                  modifier="round"
                                  :value="'指示単位'"
                                  :name="getCheckBox(subCategoryItem, 2)"
                                />
                                指示単位
                                <v-ons-radio
                                  v-model="subCategoryItem.unit"
                                  modifier="round"
                                  :value="'レセ単位'"
                                  :name="getCheckBox(subCategoryItem, 2)"
                                />
                                レセ単位
                              </div>
                              <div
                                style="width: 26%; display: inline-block"
                                v-if="
                                  (category.categoryNo >= 2 &&
                                    category.categoryNo <= 11) ||
                                  (category.categoryNo >= 18 &&
                                    category.categoryNo <= 19) ||
                                  (category.categoryNo >= 1002 &&
                                    category.categoryNo <= 1015) ||
                                  (category.categoryNo >= 1020 &&
                                    category.categoryNo <= 1021)
                                "
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
                                style="width: 25%; display: inline-block"
                                v-if="
                                  (category.categoryNo >= 2 &&
                                    category.categoryNo <= 11) ||
                                  (category.categoryNo >= 18 &&
                                    category.categoryNo <= 19) ||
                                  (category.categoryNo >= 1002 &&
                                    category.categoryNo <= 1015) ||
                                  (category.categoryNo >= 1020 &&
                                    category.categoryNo <= 1021)
                                "
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
                              <!-- add #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start -->
                              <div
                                style="
                                  position: relative;
                                  top: -7px;
                                  display: inline-block;
                                "
                                v-if="
                                  subCategoryItem.itemNo != 'prediction' &&
                                  subCategoryItem.itemNo != 'regression_line' &&
                                  ((category.categoryNo >= 1008 &&
                                    category.categoryNo <= 1011) ||
                                    (8 <= category.categoryNo &&
                                      category.categoryNo <= 11))
                                "
                              >
                                <v-ons-select
                                  v-model="subCategoryItem.itemExamClass"
                                >
                                  <option
                                    v-for="option in examOrderList"
                                    :key="option.examOrderCode"
                                    :value="option.examOrderCode"
                                  >
                                    {{ option.examOrderName }}
                                  </option>
                                </v-ons-select>
                              </div>
                              <!-- add #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end -->
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
              </v-ons-row>
            </draggable>
            <!--            </draggable>-->
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
          <span style="margin-left: 25px" v-if="isComplaintShow">
            <!-- mod 不具合 #6385 dou start-->
            <!-- mod #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy start -->
            <!-- <kendo-dropdownlist
            v-model="complaintTreatment"
            :data-source="getComplaint()"
            :data-text-field="'text'"
            :data-value-field="'value'"
            style="width: 8.5em; margin-left: 25px"
            class="common-style-input"
          /> -->
            <kendo-dropdownlist
              v-model="complaintTreatment"
              :data-source="getComplaint(popoverInfo.targetInfo.categoryNo)"
              :data-text-field="'text'"
              :data-value-field="'value'"
              style="width: 8.5em; margin-left: 25px"
              class="common-style-input"
            />
            <!-- mod #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy end -->
            <!-- mod 不具合 #6385 dou end-->
          </span>
        </h2>
        <hr />

        <v-ons-row>
          <div
            style="width: 100%"
            v-if="popUpJudgment2(popoverInfo.targetInfo.categoryNo)"
          >
            <!--種別名-->
            <v-ons-row
              style="height: auto; margin-bottom: 10px"
              class="div-style"
              v-if="popoverInfo.targetInfo.categoryNo !== 1019"
            >
              <v-ons-col width="9em">
                <label class="label-style">{{ categoryTitleName }}</label>
              </v-ons-col>
              <v-ons-col>
                <kendo-dropdownlist
                  v-model="popoverChooseData"
                  :data-source="
                    getDownListData(popoverInfo.targetInfo.categoryNo)
                  "
                  :data-text-field="'text'"
                  :data-value-field="'value'"
                  style="min-width: 200px; width: 100%"
                  class="common-style-input"
                />
              </v-ons-col>
            </v-ons-row>
            <!--フリーワード-->
            <v-ons-row
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
                  type="search"
                  placeholder="検索"
                  style="min-width: 200px"
                />
              </v-ons-col>
            </v-ons-row>
            <!--薬剤/医療材料/ダイアライザ-->
            <v-ons-row style="height: auto" class="div-style">
              <v-ons-col width="9em">
                <label class="label-style">{{ categoryDataName }}</label>
              </v-ons-col>
              <v-ons-col>
                <div class="mult-selector" style="min-width: 200px">
                  <!-- mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 start -->
                  <!-- <div
                  v-for="(selectedInfo, index) in popoverInfo.selectInfoOptions"
                  :key="index"
                  :class="setListClass(selectedInfo.itemNo)"
                  class="select-label-style"
                  @click="storageInfo(selectedInfo)"
                >
                  {{ selectedInfo.itemName }}
                </div> -->
                  <div
                    v-for="(
                      selectedInfo, index
                    ) in popoverInfo.selectInfoOptions"
                    :key="index"
                    :class="setListClass(selectedInfo.itemNo)"
                    class="select-label-style"
                    @click="storageInfo(selectedInfo, $event)"
                  >
                    <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start-->
                    {{ selectedInfo.isDisp === "0" ? "【削除済み】" : "" }}
                    <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end-->
                    {{ selectedInfo.itemName }}
                  </div>
                  <!-- mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 end -->
                </div>
              </v-ons-col>
            </v-ons-row>
          </div>

          <div
            style="width: 100%"
            v-if="popUpJudgment(popoverInfo.targetInfo.categoryNo)"
          >
            <!--グラフ縦軸 上限値-->
            <v-ons-row
              style="height: auto; margin-bottom: 10px"
              class="div-style"
            >
              <v-ons-col width="9em">
                <label class="label-style">グラフ縦軸 上限値</label>
              </v-ons-col>
              <v-ons-col>
                <keep-alive>
                  <component
                    :is="'custom-input-number-pro'"
                    class="search-style"
                    :step="0.01"
                    :value="graphMax"
                    :key="popoverInfo.targetInfo.categoryNo + '_' + popoverInfo.targetInfo.subCategoryNo"
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
              </v-ons-col>
            </v-ons-row>
            <!--グラフ縦軸 下限値-->
            <v-ons-row
              style="height: auto; margin-bottom: 10px"
              class="div-style"
            >
              <v-ons-col width="9em">
                <label class="label-style">グラフ縦軸 下限値</label>
              </v-ons-col>
              <v-ons-col>
                <keep-alive>
                  <component
                    :is="'custom-input-number-pro'"
                    class="search-style"
                    :step="0.01"
                    :value="graphMin"
                    :key="popoverInfo.targetInfo.categoryNo + '_' + popoverInfo.targetInfo.subCategoryNo"
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
              </v-ons-col>
            </v-ons-row>
            <!--対象要素-->
            <v-ons-row
              style="height: 30px; margin-bottom: 10px"
              class="div-style"
              v-if="
                popoverInfo.targetInfo.categoryNo >= 1024 &&
                popoverInfo.targetInfo.categoryNo <= 1027
              "
            >
              <v-ons-col width="9em">
                <label class="label-style">対象要素</label>
              </v-ons-col>
              <v-ons-col>
                <v-ons-select v-model="targetElement" style="width: 100%">
                  <option
                    v-for="data in targetElementData"
                    :key="data.value"
                    :value="data.value"
                  >
                    {{ data.text }}
                  </option>
                </v-ons-select>
              </v-ons-col>
            </v-ons-row>
            <!--検査状態-->
            <!-- mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start -->
            <v-ons-row
              style="height: auto"
              v-if="
                (medicatioSupport &&
                  popoverInfo.targetInfo.categoryNo >= 1008 &&
                  popoverInfo.targetInfo.categoryNo <= 1011) ||
                (popoverInfo.targetInfo.categoryNo >= 1024 &&
                  popoverInfo.targetInfo.categoryNo <= 1027 &&
                  targetElement === 'inspection')
              "
            >
              <!-- mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end -->
              <v-ons-col width="9em">
                <label class="label-style">検査状態</label>
              </v-ons-col>
              <v-ons-col>
                <div
                  style="
                    width: 100%;
                    min-width: 200px;
                    display: flex;
                    align-items: center;
                  "
                >
                  <v-ons-radio
                    modifier="round"
                    v-model="inspectionStatus"
                    :value="'結果'"
                    name="inspectionStatusFlag"
                    @click="radioCheckBox('inspectionStatus', 1)"
                  />
                  <label class="label-style" style="margin-right: 1em"
                    >検査結果</label
                  >
                  <v-ons-radio
                    modifier="round"
                    v-model="inspectionStatus"
                    :value="'投薬支援'"
                    name="inspectionStatusFlag"
                    @click="radioCheckBox('inspectionStatus', 2)"
                  />
                  <label class="label-style">投薬支援</label>
                </div>
              </v-ons-col>
            </v-ons-row>
            <!--治療状態-->
            <v-ons-row
              style="height: auto"
              v-if="
                medicatioSupport && targetElement === 'treatment_conditions'
              "
            >
              <v-ons-col width="9em">
                <label class="label-style">治療状態</label>
              </v-ons-col>
              <v-ons-col>
                <div
                  style="
                    width: 100%;
                    min-width: 200px;
                    display: flex;
                    align-items: center;
                  "
                >
                  <v-ons-radio
                    modifier="round"
                    v-model="treatmentStatus"
                    :value="'指示'"
                    name="inspectionStatusFlag"
                    @click="radioCheckBox('treatmentStatus', 1)"
                  />
                  <label class="label-style" style="margin-right: 1em"
                    >指示</label
                  >
                  <v-ons-radio
                    modifier="round"
                    v-model="treatmentStatus"
                    :value="'実績'"
                    name="inspectionStatusFlag"
                    @click="radioCheckBox('treatmentStatus', 2)"
                  />
                  <label class="label-style">実績</label>
                </div>
              </v-ons-col>
            </v-ons-row>
            <!--対象薬剤-->
            <v-ons-row
              style="height: auto"
              v-if="
                popoverInfo.targetInfo.categoryNo >= 1024 &&
                popoverInfo.targetInfo.categoryNo <= 1027 &&
                targetElement === 'administered_drug'
              "
            >
              <v-ons-col width="9em">
                <label class="label-style">対象薬剤</label>
              </v-ons-col>
              <v-ons-col>
                <div
                  style="
                    width: 100%;
                    min-width: 200px;
                    display: flex;
                    align-items: center;
                  "
                >
                  <v-ons-radio
                    modifier="round"
                    v-model="dosOrPre"
                    :value="'投薬'"
                    name="targetDrugFlag"
                  />
                  <label class="label-style" style="margin-right: 1em"
                    >投薬</label
                  >
                  <v-ons-radio
                    modifier="round"
                    v-model="dosOrPre"
                    :value="'処方'"
                    name="targetDrugFlag"
                  />
                  <label class="label-style">処方</label>
                </div>
              </v-ons-col>
            </v-ons-row>
            <!--薬剤状態-->
            <v-ons-row
              style="height: auto"
              v-if="
                popoverInfo.targetInfo.categoryNo >= 1024 &&
                popoverInfo.targetInfo.categoryNo <= 1027 &&
                targetElement === 'administered_drug'
              "
            >
              <v-ons-col width="9em">
                <label class="label-style">薬剤状態</label>
              </v-ons-col>
              <v-ons-col>
                <div
                  style="
                    width: 100%;
                    min-width: 200px;
                    display: flex;
                    align-items: center;
                  "
                >
                  <v-ons-radio
                    modifier="round"
                    v-model="drugStatus"
                    :value="'指示'"
                    name="drugStatusName"
                    @click="radioCheckBox('drugStatus', 1)"
                  />
                  <label class="label-style" style="margin-right: 1em"
                    >指示</label
                  >
                  <v-ons-radio
                    modifier="round"
                    v-model="drugStatus"
                    :value="'実績'"
                    name="drugStatusName"
                    @click="radioCheckBox('drugStatus', 2)"
                  />
                  <label class="label-style" style="margin-right: 1em"
                    >実績</label
                  >
                  <v-ons-radio
                    v-if="medicatioSupport"
                    modifier="round"
                    v-model="drugStatus"
                    :value="'投薬支援'"
                    name="drugStatusName"
                    @click="radioCheckBox('drugStatus', 3)"
                  />
                  <label class="label-style" v-if="medicatioSupport"
                    >投薬支援</label
                  >
                </div>
              </v-ons-col>
            </v-ons-row>
            <!--薬剤区分-->
            <v-ons-row
              style="height: auto; margin-bottom: 10px"
              class="div-style"
              v-if="
                popoverInfo.targetInfo.categoryNo >= 1024 &&
                popoverInfo.targetInfo.categoryNo <= 1027 &&
                targetElement === 'administered_drug'
              "
            >
              <v-ons-col width="9em">
                <label class="label-style">薬剤区分</label>
              </v-ons-col>
              <v-ons-col>
                <kendo-dropdownlist
                  :disabled="!investmentSupport"
                  v-model="drugDistinguish"
                  :data-source="getTargetDrugData()"
                  :data-text-field="'text'"
                  :data-value-field="'value'"
                  class="common-style-input"
                  :value="'0'"
                  @change="filterChange($event)"
                />
              </v-ons-col>
            </v-ons-row>
            <!--薬剤分類-->
            <v-ons-row
              style="height: auto; margin-bottom: 10px"
              class="div-style"
              v-if="
                popoverInfo.targetInfo.categoryNo >= 1024 &&
                popoverInfo.targetInfo.categoryNo <= 1027 &&
                targetElement === 'administered_drug'
              "
            >
              <v-ons-col width="9em">
                <label class="label-style">薬剤分類</label>
              </v-ons-col>
              <v-ons-col>
                <kendo-dropdownlist
                  :disabled="!investmentSupport || categoryFlg"
                  v-model="drugClassification"
                  :data-source="getDrugClassificationData()"
                  :data-text-field="'text'"
                  :data-value-field="'value'"
                  class="common-style-input"
                />
              </v-ons-col>
            </v-ons-row>
            <!--フリーワード-->
            <v-ons-row
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
            <!--項目名-->
            <v-ons-row style="height: auto" class="div-style">
              <v-ons-col width="9em">
                <label class="label-style">{{ titleName }}</label>
              </v-ons-col>
              <v-ons-col>
                <div class="mult-selector" style="min-width: 200px">
                  <!-- mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 start -->
                  <!-- <div
                  v-for="(selectedInfo, index) in popoverInfo.selectInfoOptions"
                  :key="index"
                  :class="setListClass(selectedInfo.itemNo)"
                  class="select-label-style"
                  @click="storageInfo2(selectedInfo)"
                >
                  {{ selectedInfo.itemName }}
                </div> -->
                  <div
                    v-for="(
                      selectedInfo, index
                    ) in popoverInfo.selectInfoOptions"
                    :key="index"
                    :class="setListClass(selectedInfo.itemNo)"
                    class="select-label-style"
                    @click="storageInfo2(selectedInfo, $event)"
                  >
                    <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start-->
                    {{ selectedInfo.isDisp === "0" ? "【削除済み】" : "" }}
                    <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end-->
                    {{ selectedInfo.itemName }}
                  </div>
                  <!-- mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 end -->
                </div>
              </v-ons-col>
            </v-ons-row>
          </div>

          <div
            style="width: 100%"
            v-if="
              !popUpJudgment(popoverInfo.targetInfo.categoryNo) &&
              !popUpJudgment2(popoverInfo.targetInfo.categoryNo)
            "
          >
            <v-ons-col class="graph-setting">
              <div
                v-if="
                  popoverInfo.targetInfo.categoryNo !== 15 &&
                  popoverInfo.targetInfo.categoryNo !== 16 &&
                  popoverInfo.targetInfo.categoryNo !== 1017 &&
                  popoverInfo.targetInfo.subCategoryNo !== 56
                "
              >
                グラフ縦線
              </div>
              <div
                v-if="
                  popoverInfo.targetInfo.categoryNo !== 15 &&
                  popoverInfo.targetInfo.categoryNo !== 16 &&
                  popoverInfo.targetInfo.categoryNo !== 1017 &&
                  popoverInfo.targetInfo.subCategoryNo !== 56
                "
              >
                <label>上限値</label>
                <keep-alive>
                  <component
                    :is="'custom-input-number-pro'"
                    class="search-style"
                    :step="0.01"
                    :value="graphMax"
                    :key="popoverInfo.targetInfo.categoryNo + '_' + popoverInfo.targetInfo.subCategoryNo"
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
                v-if="
                  popoverInfo.targetInfo.categoryNo !== 15 &&
                  popoverInfo.targetInfo.categoryNo !== 16 &&
                  popoverInfo.targetInfo.categoryNo !== 1017 &&
                  popoverInfo.targetInfo.subCategoryNo !== 56
                "
              >
                <label>下限値</label>
                <keep-alive>
                  <component
                    :is="'custom-input-number-pro'"
                    class="search-style"
                    :step="0.01"
                    :value="graphMin"
                    :key="popoverInfo.targetInfo.categoryNo + '_' + popoverInfo.targetInfo.subCategoryNo"
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
                v-if="popoverInfo.targetInfo.categoryNo === 16"
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
                <!-- mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 start -->
                <!-- <div
                v-for="(selectedInfo, index) in popoverInfo.selectInfoOptions"
                :key="index"
                :class="setListClass(selectedInfo.itemNo)"
                class="select-label-style"
                @click="storageInfo(selectedInfo)"
              >
                <label v-if="indentIsPatEventSub(popoverInfo.targetInfo.categoryNo, selectedInfo)">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label>
                {{ selectedInfo.itemName }}
              </div> -->
                <div
                  v-for="(selectedInfo, index) in popoverInfo.selectInfoOptions"
                  :key="index"
                  :class="setListClass(selectedInfo.itemNo)"
                  class="select-label-style"
                  @click="storageInfo(selectedInfo, $event)"
                >
                  <label
                    v-if="
                      indentIsPatEventSub(
                        popoverInfo.targetInfo.categoryNo,
                        selectedInfo
                      )
                    "
                    >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</label
                  >
                  <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start-->
                  {{ selectedInfo.isDisp === "0" ? "【削除済み】" : "" }}
                  <!--add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end-->
                  {{ selectedInfo.itemName }}
                </div>
                <!-- mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 end -->
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
    <!-- 薬剤選択ボタンポップオーバー -->
    <pop-over
      v-bind="popMedicineInfo"
      :target-position-element="popoverTargetElement()"
      @popover-return="selectedAllMedi($event)"
      @popover-close="closeMediPopover()"
    />
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import {
  mstPatViewerLayoutDefine,
  selectInfoOptions,
  advancedSettingDispItemList,
  CATEGORY_NO,
  SUB_CATEGORY_NO,
  MED_DATE,
  complaintTreatmentInformation,
} from "@/constants/mstPatViewerLayoutDefine";
import { deepCopy } from "@/functions/common/CommonFunctions";
import vuedraggable from "vuedraggable";
import MedicineSelector from "@/components/master-maintenance/mst-pat-viewer-layout/custom-selector/MedicineSelector";
import { ApiHelper } from "@/apis/AxiosHelper";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import PopoverMixin from "@/components/PopoverMixin";
import { REPORT_GRAPH } from "@/constants/mstTreatmentDefine.js";
import { sendRequestGetMstFacilityByCd } from "@/apis/facility";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import { EventBus } from "@/eventBus";
// add #10628 数値IF修正 linjunfeng start
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
// add #10628 数値IF修正 linjunfeng end
// 薬剤区分
const medi_cate = {
  group: {
    VALUE: "0",
    TEXT: "薬剤グループ",
  },
  normal: {
    VALUE: "1",
    TEXT: "通常薬剤",
  },
  //#10176:ポップアップのフリーワード検索の動作不正 Start
  adjustment: {
    VALUE: "11",
    TEXT: "調整薬剤",
  },
  //#10176:ポップアップのフリーワード検索の動作不正 End
  groupS: {
    VALUE: "2",
    TEXT: "薬剤グループ",
  },
  normalS: {
    VALUE: "3",
    TEXT: "通常薬剤",
  },
  prescription: {
    VALUE: "4",
    TEXT: "一般名処方",
  },
};
//#10176:ポップアップのフリーワード検索の動作不正 Start
const MEDICINE_MIX = "MEDICINE_MIX";
//#10176:ポップアップのフリーワード検索の動作不正 End
const MAX_COLUMN = 5;

export default {
  mixins: [PopoverMixin],
  components: {
    draggable: vuedraggable,
    "pop-over": MedicineSelector,
    // add #10628 数値IF修正 linjunfeng start
    "custom-input-number-pro": CustomInputNumberPro,
    // add #10628 数値IF修正 linjunfeng end
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
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/14 by liumx start
      /**
       * すべて検査項目
       */
      allMstExamItem: null,
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/14 by liumx end
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
       * 必須項目選択不可フラグ
       */
      isDisabledRequiredItem: false,
      /**
       * 必須項目自動設定情報
       * 「治療予定」、「治療方法」を変更した際に格納する
       */
      isAutoSetRequiredItem: [],
      /**
       * 薬剤選択ポップオーバーのパラメータ
       */
      popMedicineInfo: {
        // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
        graphMax: null,
        graphMin: null,
        // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
        popoverVisible: false,
        popoverDisplayDirection: "left",
        popoverTitleHeader: "薬剤",
        popoverFilter: [],
        popoverSelector: [],
        popoverContentLabel: "薬剤名",
        popoverContentDataset: [],
        popoverContentSelected: {},
        hasUnregisteredOption: false,
        targetInfo: {
          categoryNo: null,
          subCategoryNo: null,
        },
      },
      /**
       * 薬剤マスタ
       */
      mstMedicine: null,
      /**
       * 薬剤分類マスタ
       */
      mstMediClass: null,
      /**
       * 薬剤セットマスタ
       */
      mstMedicineSet: null,
      /**
       * 検査項目マスタ
       */
      mstExamItem: null,
      /**
       * 薬効換算マスタ
       */
      mstMedicineGroup: null,
      /**
       * 調製薬剤マスタ
       */
      mstMedicineMix: null,
      /**
       * 投薬支援マスタ
       */
      mstMedicineSupport: null,
      /**
       * 患者イベントサブカテゴリマスタ
       */
      mstPatEventSubCategory: null,
      /**
       * 患者イベント
       */
      mstPatEventSubCategoryPat: [],
      /**
       * 愁訴マスタ
       */
      mstComplaints: [],
      /**
       * 愁訴マスタ
       */
      mstPatEventCategory: [],
      /**
       * 透析量プログラム項目表示フラグ
       */
      isDispDialysisAmountProgram: false,
      /**
       * BV-UFC項目表示フラグ
       */
      isDispBvUfc: false,
      /**
       * 拡張設定表示項目一覧
       */
      advancedSettingDispItemList: advancedSettingDispItemList,
      /**
       * バイタル・モニタ項目の選択肢リスト
       */
      selectVitalMonitorItemList: [],
      /**
       * 治療方法項目のカテゴリ番号
       */
      treatmentItemCategoryNo: CATEGORY_NO.TREATMENT_CONTENT,
      /**
       * バイタル・モニタ項目の選択肢を表示するカテゴリ番号
       */
      vitalMonitorItemTargetCategoryNoList: [
        CATEGORY_NO.VITAL_MONITOR_GRAPH_24H_1,
        CATEGORY_NO.VITAL_MONITOR_GRAPH_24H_2,
        CATEGORY_NO.VITAL_MONITOR_GRAPH_24H_3,
        CATEGORY_NO.VITAL_MONITOR_GRAPH_24H_4,
        CATEGORY_NO.VITAL_MONITOR_GRAPH_COL_1,
        CATEGORY_NO.VITAL_MONITOR_GRAPH_COL_2,
        CATEGORY_NO.VITAL_MONITOR_GRAPH_COL_3,
        CATEGORY_NO.VITAL_MONITOR_GRAPH_COL_4,
        // CATEGORY_NO.VITAL_COMPREHENSIVE_COL_1,
        // CATEGORY_NO.VITAL_COMPREHENSIVE_COL_2,
        // CATEGORY_NO.VITAL_COMPREHENSIVE_COL_3,
        // CATEGORY_NO.VITAL_COMPREHENSIVE_COL_4,
      ],
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
      /**
       * 投与薬剤
       */
      drugFlag: 0,
      /**
       * フリーワード入力値
       */
      popoverSearchQuery: "",
      /**
       * 医療材料マスタ
       */
      mstEquipment: [],
      /**
       * 医療材料分類マスタ
       */
      mstEquipmentClass: [],
      /**
       * ダイアライザマスタ
       */
      mstDialyzer: [],
      /**
       * 検査状態
       */
      inspectionStatus: "結果",
      /**
       * 医療材料集計,薬剤集計,ダイアライザ集計の名前
       */
      categoryTitleName: "",
      /**
       * 医療材料集計,薬剤集計,ダイアライザ集計の名前を選択
       */
      categoryDataName: "",
      /**
       * 医療材料集計,薬剤集計,ダイアライザ集計のフィルター機能
       */
      popoverChooseData: null,
      /**
       * 対象要素
       */
      targetElement: "weight",
      /**
       * 対象薬剤
       */
      dosOrPre: "投薬",
      //#10176:ポップアップのフリーワード検索の動作不正 Start
      dosOrPreCd: "0",
      //#10176:ポップアップのフリーワード検索の動作不正 End
      /**
       * 薬剤状態
       */
      drugStatus: "指示",
      /**
       * 薬剤分類
       */
      drugClassification: "0",
      /**
       * 薬剤区分
       */
      drugDistinguish: "0",
      /**
       * 複合グラフの名前
       */
      titleName: "体重名",
      /**
       * 投薬支援
       */
      medicationSupport: false,
      /**
       * 治療状態
       */
      treatmentStatus: "指示",

      // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
      graphMax: null,
      graphMin: null,
      // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end

      medicationSupportChoose: null,

      investmentSupport: true,
      /**
       * 初めて複合グラフを開くかどうか
       */
      isFirstCompound: true,

      targetElementData: [
        { text: "体重", value: "weight" },
        { text: "検査", value: "inspection" },
        { text: "治療条件", value: "treatment_conditions" },
        { text: "薬剤", value: "administered_drug" },
        { text: "バイタル・モニタ", value: "vital_monitor" },
      ],
      /**
       * 愁訴処置情報
       */
      complaintTreatment: "1",
      /**
       * 処置マスタ
       */
      mstCompTreatment: [],

      isComplaintShow: false,

      //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
      categoryFlg: false,
      //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
      min: -99999.99,
      max: 99999.99,
      blurFlg: false,
      focusFlg: [false, false],
      initName: "",
      isEditedName: false,
      initDispPeriodClass: "",

      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
      /**
       * すべて検査項目
       */
      mstExamItemIsDisp: [],
      /**
       * すべて処置項目
       */
      mstTreatmentListDisp: [],
      /**
       * すべて愁訴項目
       */
      mstComplaintListDisp: [],
      /**
       * 医療材料集計
       */
      mstEquipmentListDisp: [],
      /**
       * 薬剤集計
       */
      mstMedicineListDisp: [],
      /**
       * 薬剤集計
       */
      mstMedicineGroupListDisp: [],
      /**
       * ダイアライザ集計
       */
      mstDialyzerListDisp: [],
      /**
       * 調製薬剤
       */
      mstMedicineMixListDisp: [],
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end

      /**
       * バイタル・モニタ項目追加マスタ
       */
      mstAddMonitor: [],
      /**
       * バイタル・モニタ
       */
      mstAddMonitorListDisp: [],
      examOrderList: [
        { examOrderCode: 3, examOrderName: "すべて" },
        { examOrderCode: 1, examOrderName: "透析前" },
        { examOrderCode: 2, examOrderName: "透析後" },
        { examOrderCode: 0, examOrderName: "その他" },
      ],
      treatmentStatusList: [{
        cd: '指示',
        name: '指示'
      }, {
        cd: '実績',
        name: '実績'
      }],
      /**
       * ドラッグイベント発生前の治療情報のデータ
       */
      preDragDispItemInfoTreatCond: null,
      /**
       * ドラッグ対象項目のドラッグイベント発生前のインデックス
       */
      treatCondPreDragIndex: -1,
      /**
       * 治療情報の項目(BV-UFC)のドラッグイベント発生前のインデックス
       */
      preBvUfcIndex: -1,
      /**
       * 治療情報の項目(透析量プログラム)のドラッグイベント発生前のインデックス
       */
      preDialysisAmountProgramIndex: -1,
      /**
       * 治療情報の項目のドラッグ処理中フラグ
       */
      isDraggingTreatCondSubCategory: false
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      editRecord: "getEditRecord",
      getFacilitySwitch: "getFacilitySwitch",
    }),
    ...mapGetters("user", ["getFacilityCd", "getAdvancedSettings"]),
    ...mapActions("mst-complaint", {
      getMstComplaint: "getMstComplaint",
      getMstCompTreatment: "getMstCompTreatment",
    }),
    ...mapGetters("user", ["getAdvancedSettings"]),
    medicatioSupport() {
      return this.medicationSupport;
    },
    selectedPeriod: {
      get() {
        return this.editRecord.dispPeriodClass
          ? this.editRecord.dispPeriodClass
          : "0";
      },
      set(value) {
        this.editRecord.dispPeriodClass = value;
      },
    },
    dispItemInfoTreatCond() {
      const treatCond = this.dispItemInfo.filter((item) => {
        return item.categoryNo === 1;
      });

      if (!treatCond || !treatCond[0]) {
        return [];
      }

      treatCond[0].categoryItem = treatCond[0].categoryItem.filter(
        (c) =>
          c.subCategoryNo !== 33 &&
          // add 5920 項目の削除 中項目 31 32 34 鞠 start
          c.subCategoryNo !== 31 &&
          c.subCategoryNo !== 32
        // add 5920 項目の削除 中項目 31 32 34 鞠 end
      );
      return treatCond;
    },
    // 拡張設定項目対象外／拡張設定項目対象で有効な状態のみ
    treatCondSubCategory() {
      let temp = this.dispItemInfoTreatCond[0].categoryItem.filter((item) => {
        return (
          this.advancedSettingDispItemList.indexOf(item.component) < 0 ||
          (this.isDispDialysisAmountProgram &&
            "diaysis-program" == item.component) ||
          (this.isDispBvUfc && "bv-ufc" == item.component)
        );
      });
      if (this.dispItemInfo[0].categoryItem.length > temp.length) {
        if (!this.isDispBvUfc) {
          this.dispItemInfo[0].categoryItem.forEach((item, index, arr) => {
            if (item.subCategoryNo === 15) {
              arr.splice(index, 1);
            }
          });
        }
        if (!this.isDispDialysisAmountProgram) {
          this.dispItemInfo[0].categoryItem.forEach((item, index, arr) => {
            if (item.subCategoryNo === 16) {
              arr.splice(index, 1);
            }
          });
        }
      }
      return temp;
    },
  },
  async created() {
    this.setLoadingScreenVisible(true);

    // 透析量プログラム項目の表示フラグ更新
    this.isDispDialysisAmountProgram =
      this.getAdvancedSettings.func_advcds.some(
        (setting) =>
          setting.func_advcd === ADVANCED_SETTINGS.DIALYSIS_AMOUNT_PROGRAM
      );
    // BV-UFC項目の表示フラグ更新
    this.isDispBvUfc = this.getAdvancedSettings.func_advcds.some(
      (setting) => setting.func_advcd === ADVANCED_SETTINGS.BV_UFC
    );

    // 施設マスタ->拡張機能->投薬支援 ON/OFF
    const responseFacility = await sendRequestGetMstFacilityByCd(
      this.getFacilitySwitch
    );
    let advanced = JSON.parse(responseFacility.data.advancedSettings);
    if (advanced !== null) {
      if (
        advanced.func_advcds.findIndex(
          (item) => item.func_advcd === ADVANCED_SETTINGS.MEDICATION_SUPPORT
        ) < 0
      ) {
        this.medicationSupport = false;
      } else {
        this.medicationSupport = true;
      }
    }

    /* add by chamaojia 2023-07-11 定数定義の前倒し  --start */
    const requestParam = {
      facilityCd: this.getFacilitySwitch,
    };
    /* add by chamaojia 2023-07-11 定数定義の前倒し  --start */
    // add redmine 6343 一般名処方の登録内容が全件表示されない 宋qy start
    // 一般名処方
    let [sysGenericMedicineData] = await Promise.all([
      ApiHelper.get("/mstInfo/sysGenericMedicine", requestParam),
    ]);
    this.sysGenericMedicine = sysGenericMedicineData.data;
    // add redmine 6343 一般名処方の登録内容が全件表示されない 宋qy end

    if (!this.getAdvancedSettings.func_advcds) {
      this.getAdvancedSettings.func_advcds = [];
    }
    /* del by chamaojia 2023-07-11 定数定義の前倒し  --start */
    // const requestParam = {
    //   facilityCd: this.getFacilitySwitch
    // };
    /* del by chamaojia 2023-07-11 定数定義の前倒し  --end */
    const [
      mstMedicine,
      mstMediClass,
      mstExamItem,
      mstMedicineSet,
      mstMedicineGroup,
      mstMedicineMix,
      mstPatEventSubCategory,
      mstEquipment,
      mstEquipmentClass,
      mstDialyzer,
      mstEventCategory,
      mstAddMonitor,
    ] = await Promise.all([
      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
      // ApiHelper.get("/mstInfo/mstMedicine", requestParam),
      ApiHelper.get(
        `/master_maintenance/mst_medicine/data/${this.getFacilitySwitch}`
      ),
      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      ApiHelper.get("/mstInfo/mstMedicineClass", requestParam),
      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/18 by liumx start
      // ApiHelper.get("/mstInfo/mstExamItem", requestParam),
      ApiHelper.get(
        `/master_maintenance/mst_exam_item/data/${this.getFacilitySwitch}`
      ),
      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/18 by liumx end
      ApiHelper.get("/mstInfo/mstMedicineSet", requestParam),

      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
      // ApiHelper.get("/mstInfo/mstMedicineGroup", requestParam),
      // ApiHelper.get("/mstInfo/mstMedicineMix", requestParam),
      ApiHelper.get(
        `/master_maintenance/mst_medicine_group/data/${this.getFacilitySwitch}`
      ),
      ApiHelper.get(
        `/master_maintenance/mst_medicine_mix/data/${this.getFacilitySwitch}`
      ),
      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      ApiHelper.get("/mstInfo/mstPatEventSubCategory", requestParam),
      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
      // ApiHelper.get("/mstInfo/mstEquipment", requestParam),
      ApiHelper.get(
        `/master_maintenance/mst_equipment/data/${this.getFacilitySwitch}`
      ),
      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      ApiHelper.get("/mstInfo/mstEquipmentClass", requestParam),
      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
      // ApiHelper.get("/mstInfo/mstDialyzer", requestParam),
      ApiHelper.get(
        `/master_maintenance/mst_dialyzer/data/${this.getFacilitySwitch}`
      ),
      // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      ApiHelper.get(
        `/master_maintenance/mst_pat_event_category/data/${this.getFacilitySwitch}`
      ),
      ApiHelper.get(
        `/master_maintenance/mst_add_monitor/data/${this.getFacilitySwitch}`
      ),
    ]);

    await ApiHelper.get(
      `/master_maintenance/mst_medicine_support/data/${this.getFacilitySwitch}`
    ).then((response) => {
      // 投薬支援マスタ
      // 【患者経過総合ビューアレイアウトマスタ】删除的投薬支援マスタ対象也被显示了 start zhao
      //   this.mstMedicineSupport = response.data.localDataSource.data.map((item) => {
      //     return {
      //       text: item.name,
      //       value: item.code,
      //     };
      //   });
      this.mstMedicineSupport = response.data.localDataSource.data
        .filter((item) => item.isDisp == "1")
        .map((item) => {
          return {
            text: item.name,
            value: item.code,
          };
        });
      // 【患者経過総合ビューアレイアウトマスタ】删除的投薬支援マスタ対象也被显示了 end zhao
    });
    // ダイアライザマスタ
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
    // this.mstDialyzer = mstDialyzer.data;
    const mstDialyzerFinal = mstDialyzer.data.localDataSource.data.map(
      ({ code, name, ...rest }) => {
        return {
          dialyzerCd: code,
          modelNumber: name,
          facilityCd: this.getFacilitySwitch,
          ...rest,
        };
      }
    );
    this.mstDialyzer = mstDialyzerFinal;
    this.mstDialyzer.forEach((item) => {
      if (item.isDisp === "0") {
        this.mstDialyzerListDisp.push(item.dialyzerCd);
      }
    });
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
    // 検査項目マスタ
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/18 by liumx start
    const mstExamItemFinal = mstExamItem.data.localDataSource.data.map(
      ({ code, name, graphLower, graphUpper, ...rest }) => {
        return {
          examItemCd: code,
          examItemName: name,
          facilityCd: this.getFacilitySwitch,
          graphLower:
            null === graphLower || "" === graphLower
              ? null
              : parseInt(graphLower),
          graphUpper:
            null === graphUpper || "" === graphUpper
              ? null
              : parseInt(graphUpper),
          ...rest,
        };
      }
    );
    this.mstExamItem = mstExamItemFinal;
    // this.mstExamItem = mstExamItem.data;
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/18 by liumx end
    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/18 by liumx start
    this.allMstExamItem = mstExamItemFinal;
    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/18 by liumx end
    // 薬剤マスタ
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
    // this.mstMedicine = mstMedicine.data;
    // 医療材料マスタ
    // this.mstEquipment = mstEquipment.data;

    // 薬剤マスタ
    const mstMedicineFinal = mstMedicine.data.localDataSource.data.map(
      ({ code, name, ...rest }) => {
        return {
          medicineCd: code,
          medicineName: name,
          facilityCd: this.getFacilitySwitch,
          ...rest,
        };
      }
    );
    this.mstMedicine = mstMedicineFinal;
    this.mstMedicine.forEach((item) => {
      if (item.isDisp === "0") {
        this.mstMedicineListDisp.push(item.medicineCd);
      }
    });
    // 検査項目マスタ
    this.allMstExamItem.forEach((item) => {
      if (item.isDisp === "0") {
        this.mstExamItemIsDisp.push(item.examItemCd);
      }
    });
    // 医療材料マスタ
    const mstEquipmentFinal = mstEquipment.data.localDataSource.data.map(
      ({ code, name, ...rest }) => {
        return {
          equipmentCd: code,
          equipmentName: name,
          facilityCd: this.getFacilitySwitch,
          ...rest,
        };
      }
    );
    this.mstEquipment = mstEquipmentFinal;
    this.mstEquipment.forEach((item) => {
      if (item.isDisp === "0") {
        this.mstEquipmentListDisp.push(item.equipmentCd);
      }
    });
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
    // 薬剤分類マスタ
    this.mstMediClass = mstMediClass.data;
    // 薬剤セットマスタ
    this.mstMedicineSet = mstMedicineSet.data;
    // 調製薬剤マスタ
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
    // this.mstMedicineMix = mstMedicineMix.data;
    // // 薬効換算マスタ
    // this.mstMedicineGroup = mstMedicineGroup.data;
    const mstMedicineMixFinal = mstMedicineMix.data.localDataSource.data.map(
      ({ code, name, ...rest }) => {
        return {
          medicineMixCd: code,
          medicineMixName: name,
          facilityCd: this.getFacilitySwitch,
          ...rest,
        };
      }
    );
    this.mstMedicineMix = mstMedicineMixFinal;
    this.mstMedicineMix.forEach((item) => {
      if (item.isDisp === "0") {
        this.mstMedicineMixListDisp.push(item.medicineMixCd + "");
      }
    });
    // 薬効換算マスタ
    const mstMedicineGroupFinal =
      mstMedicineGroup.data.localDataSource.data.map(
        ({ code, name, ...rest }) => {
          return {
            medicineGroupCd: code,
            medicineGroupName: name,
            facilityCd: this.getFacilitySwitch,
            ...rest,
          };
        }
      );
    this.mstMedicineGroup = mstMedicineGroupFinal;
    this.mstMedicineGroup.forEach((item) => {
      if (item.isDisp === "0") {
        this.mstMedicineGroupListDisp.push(item.medicineGroupCd + "");
      }
    });
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
    // 医療材料分類マスタ
    this.mstEquipmentClass = mstEquipmentClass.data;
    // 患者イベントサブカテゴリマスタ
    this.mstPatEventSubCategory = mstPatEventSubCategory.data;
    // 患者イベントカテゴリマスタ
    this.mstPatEventCategory =
      mstEventCategory.data.localDataSource.data.filter(
        (e) => e.isDisp === "1"
      );

    // 患者イベントカテゴリマスタと患者イベントサブカテゴリマスタを区別するデータ
    // 患者イベントサブカテゴリマスタのデータ isPatEventSub は 1 に設定します。
    mstPatEventSubCategory.data.forEach((e) => (e.isPatEventSub = 1));
    // 患者イベントカテゴリマスタのデータ isPatEventSub は 0 に設定します。
    this.mstPatEventCategory.forEach((e) => (e.isPatEventSub = 0));

    // 観察記録,患者イベント項目取得
    this.mstPatEventSubCategoryPat = mstPatEventSubCategory.data;
    this.initName = this.editRecord.name;
    this.initDispPeriodClass = this.selectedPeriod;
    let categoryPatTemp = [];
    this.mstPatEventCategory.forEach((cate) => {
      let len = this.mstPatEventSubCategoryPat.filter(
        (pat) => cate.code === pat.categoryCd
      );
      if (len.length > 0) {
        categoryPatTemp.push(cate);
      }
    });
    this.mstPatEventCategory = categoryPatTemp;

    let categoryPatSubTemp = [];
    this.mstPatEventSubCategoryPat.forEach((pat) => {
      let len = this.mstPatEventCategory.filter(
        (cate) => cate.code === pat.categoryCd
      );
      if (len.length > 0) {
        categoryPatSubTemp.push(pat);
      }
    });
    this.mstPatEventSubCategoryPat = categoryPatSubTemp;

    // バイタルモニタ項目取得
    const [selectVitalMonitorItemList] = await Promise.all([
      ApiHelper.get("/mstInfo/mstPatViewerLayout/monitorItem", {
        facilityCd: this.getFacilitySwitch,
        isAllDisp: "1",
      }),
    ]);
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
        lineColor: null,
        pointType: null,
        medDate: null,
      };
      //mod 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
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
      //mod 8574 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
    }

    // 処置マスタ取得
    const mstCompTreatmentList = await ApiHelper.get(
      `/complaint/mst-comp-treatment/data/${this.getFacilitySwitch}`
    );
    this.mstCompTreatment = mstCompTreatmentList.data;
    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
    this.mstCompTreatment.forEach((item) => {
      if (item.is_disp === "0") {
        this.mstTreatmentListDisp.push(item.comp_treatment_cd + "");
      }
    });
    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
    // 愁訴マスタ取得
    const response = await this.getMstComplaintByFacilityCd(
      this.getFacilitySwitch
    );
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
    // for (let i = 0; i < response.data.length; i++) {
    //   if (response.data[i].is_disp == "1") {
    //     this.mstComplaints.push(response.data[i]);
    //   }
    // }
    response.data.forEach((item) => {
      this.mstComplaints.push(item);
    });
    this.mstComplaints.forEach((item) => {
      if (item.is_disp === "0") {
        this.mstComplaintListDisp.push(item.complaint_cd + "");
      }
    });
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
    // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
    let dispInfo = JSON.parse(this.editRecord.dispItemInfo);

    // mod 短期画面ではloadingを表示します。 start
    // if (this.selectedPeriod === '0') {
    //   let complaint = dispInfo.find((eleCategoryInfo) => {
    //     return 1 === eleCategoryInfo.categoryNo;
    //   }).categoryItem.find(
    //     (eleSubCategoryInfo) => {
    //       return 56 === eleSubCategoryInfo.subCategoryNo;
    //     }
    //   ).subCategoryItem;
    //
    //   if (complaint.length > 0) {
    //     complaint.forEach((item) => {
    //       if (item.complaintClassify === "1") {
    //         item.itemNo = "Complaints*" + item.itemNo;
    //       }
    //       if (item.complaintClassify === "2") {
    //         item.itemNo = "CompTreatment*" + item.itemNo;
    //       }
    //     })
    //   }
    // }
    // mod 短期画面ではloadingを表示します。 end

    let cate = dispInfo.find((eleCategoryInfo) => {
      return 1028 === eleCategoryInfo.categoryNo;
    });
    if (cate) {
      this.medicationSupportChoose = parseInt(cate.medicineGroupCd);
    }
    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
    this.retrieveMstData();
    this.initdispItemInfo = deepCopy(this.dispItemInfo);
    // mod by jsy 2024-04-04 #10196 患者経過総合ビューアのレイアウト確認で表示期間が短期間で表示されるグラフの問題対応 --start /
    this.changeDispItem();
    // mod by jsy 2024-04-04 #10196 患者経過総合ビューアのレイアウト確認で表示期間が短期間で表示されるグラフの問題対応 --end /
    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
    this.setLoadingScreenVisible(false);
  },

  watch: {
    /**
     * @description 表示項目並び替えウォッチャー
     */
    dispItemInfo: {
      handler(newValue, oldValue) {
        //治療情報の項目がドラッグ処理中である場合
        if(this.isDraggingTreatCondSubCategory){
          let treatCondPreDragIndex = this.treatCondPreDragIndex;
          let dispItemTreatCondPreDragIndex = treatCondPreDragIndex;
          //BV-UFCが非表示、かつ、マスタ上にBV-UFCの項目が存在し、かつ、BV-UFCがドラッグ対象項目より上に位置している場合
          if(!this.isDispBvUfc && this.preBvUfcIndex >= 0 && dispItemTreatCondPreDragIndex >= this.preBvUfcIndex){
            dispItemTreatCondPreDragIndex++;
          }
          //透析量プログラムが非表示、かつ、マスタ上に透析量プログラムの項目が存在し、かつ、透析量プログラムがドラッグ対象項目より上に位置している場合
          if(!this.isDispDialysisAmountProgram && this.preDialysisAmountProgramIndex >= 0 && dispItemTreatCondPreDragIndex >= this.preDialysisAmountProgramIndex){
            dispItemTreatCondPreDragIndex++;
          }
          //ドラッグ対象項目のサブカテゴリNoの取得
          let dragTargetSubCategoryNo = this.preDragDispItemInfoTreatCond[0].categoryItem[treatCondPreDragIndex].subCategoryNo;
          let treatCondPostDragIndex = -1;
          //ドラッグ対象項目のドラッグイベント発生後のインデックスの取得
          this.dispItemInfoTreatCond[0].categoryItem.forEach((item, index) => {
            if (item.subCategoryNo === dragTargetSubCategoryNo) {
              treatCondPostDragIndex = index;
            }
          });
          //ドラッグ対象項目の移動量の取得
          let dragQuantity = treatCondPostDragIndex - treatCondPreDragIndex;
          //BV-UFCと透析量プログラムがどちらも非表示、かつ、マスタ上に2つの項目が存在し、かつ、ドラッグ対象項目(ドラッグイベント発生前)が2つの項目より上に位置しており、かつ、ドラッグ対象項目(ドラッグイベント発生後)が2つの項目より下に位置している場合
          if(!this.isDispBvUfc && this.preBvUfcIndex >= 0 && dispItemTreatCondPreDragIndex < this.preBvUfcIndex && treatCondPostDragIndex + 1 >= this.preBvUfcIndex
            && !this.isDispDialysisAmountProgram && this.preDialysisAmountProgramIndex >= 0 && dispItemTreatCondPreDragIndex < this.preDialysisAmountProgramIndex && treatCondPostDragIndex + 1 >= this.preDialysisAmountProgramIndex){
            treatCondPostDragIndex++;
          }
          let dispItemDragQuantity = dragQuantity;
          //BV-UFCが非表示、かつ、マスタ上にBV-UFCの項目が存在し、かつ、ドラッグ対象項目(ドラッグイベント発生前)がBV-UFCより上に位置しており、ドラッグ対象項目(ドラッグイベント発生後)がBV-UFCより下に位置している場合
          if(!this.isDispBvUfc && this.preBvUfcIndex >= 0 && dispItemTreatCondPreDragIndex < this.preBvUfcIndex && treatCondPostDragIndex >= this.preBvUfcIndex){
            dispItemDragQuantity++;
          //BV-UFCが非表示、かつ、マスタ上にBV-UFCの項目が存在し、かつ、ドラッグ対象項目(ドラッグイベント発生前)がBV-UFCより下に位置しており、ドラッグ対象項目(ドラッグイベント発生後)がBV-UFCより上に位置している場合
          } else if (!this.isDispBvUfc && this.preBvUfcIndex >= 0 && dispItemTreatCondPreDragIndex >= this.preBvUfcIndex && treatCondPostDragIndex < this.preBvUfcIndex){
            dispItemDragQuantity--;
          }
          //透析量プログラムが非表示、かつ、マスタ上に透析量プログラムの項目が存在し、かつ、ドラッグ対象項目(ドラッグイベント発生前)が透析量プログラムより上に位置しており、ドラッグ対象項目(ドラッグイベント発生後)が透析量プログラムより下に位置している場合
          if(!this.isDispDialysisAmountProgram && this.preDialysisAmountProgramIndex >= 0 && dispItemTreatCondPreDragIndex < this.preDialysisAmountProgramIndex && treatCondPostDragIndex >= this.preDialysisAmountProgramIndex){
            dispItemDragQuantity++;
          //透析量プログラムが非表示、かつ、マスタ上に透析量プログラムの項目が存在し、かつ、ドラッグ対象項目(ドラッグイベント発生前)が透析量プログラムより下に位置しており、ドラッグ対象項目(ドラッグイベント発生後)が透析量プログラムより上に位置している場合
          } else if (!this.isDispDialysisAmountProgram && this.preDialysisAmountProgramIndex >= 0 && dispItemTreatCondPreDragIndex >= this.preDialysisAmountProgramIndex && treatCondPostDragIndex < this.preDialysisAmountProgramIndex) {
            dispItemDragQuantity--;
          }
          //ドラッグ対象項目が不正、または、ドラッグ対象項目のドラッグ先の位置が不正の場合
          if(dispItemTreatCondPreDragIndex > treatCondPreDragIndex || dispItemDragQuantity !== dragQuantity){
            //ドラッグ対象項目のドラッグイベント発生後のインデックスの取得(ドラッグ対象項目のドラッグイベント発生前のインデックス + ドラッグ対象項目の移動量)
            let dispItemTreatCondPostDragIndex = dispItemTreatCondPreDragIndex + dispItemDragQuantity;
            //ドラッグ対象項目の削除・抽出
            const dragTargetElement = this.preDragDispItemInfoTreatCond[0].categoryItem.splice(dispItemTreatCondPreDragIndex, 1)[0];
            //ドラッグ対象項目のドラッグイベント発生後の位置への挿入
            this.preDragDispItemInfoTreatCond[0].categoryItem.splice(dispItemTreatCondPostDragIndex,0,dragTargetElement);
            //カテゴリNoが治療情報の要素のインデックスの取得
            const categoryIndex = this.dispItemInfo.findIndex(item => item.categoryNo === 1);
            //治療情報の各サブカテゴリのデータの更新
            this.dispItemInfo[categoryIndex].categoryItem = this.preDragDispItemInfoTreatCond[0].categoryItem;
          }
          //治療情報の項目のドラッグ処理中フラグの設定解除
          this.isDraggingTreatCondSubCategory = false;
        }
        if (this.drugFlag === 0) {
          for (let i = 0; i < newValue.length; i++) {
            if (newValue[i].categoryNo === 1) {
              for (let j = 0; j < newValue[i].categoryItem.length; j++) {
                if (newValue[i].categoryItem[j].subCategoryNo === 5) {
                  if (newValue[i].categoryItem[j].subCategoryItem[0].isDisp) {
                    newValue[i].categoryItem[j].subCategoryItem[1].isDisp =
                      !newValue[i].categoryItem[j].subCategoryItem[0].isDisp;
                  }
                  this.drugFlag++;
                }
              }
            }
          }
        }
        const convData = this.removeIsDispOption(newValue);
        this.setDispItemInfo(convData);
        // 表示・非表示切替
        this.switchingItemDisp();
        // 短期レイアウトの場合
        if (this.selectedPeriod === "0") {
          // 初期更新(DOM)の場合
          if (oldValue !== null && oldValue.length === 0) {
            // 終了
            return;
          } else {
            // 二次更新(DOM)の場合
            if (this.ignoreWatchDispItemInfo) {
              // 初期表示内容の取得
              this.initDispItemInfoJSON = convData;
              // 未処理(以降の初期表示内容は取得しない)
              this.ignoreWatchDispItemInfo = false;
            }
          }
        } else if (this.selectedPeriod === "1") {
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
     * 医療材料集計,薬剤集計,ダイアライザ集計のフィルター機能
     */
    popoverChooseData: {
      handler(data) {
        this.changePopoverDownListData(data);
      },
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
     * 複合グラフ 対象薬剤
     */
    dosOrPre: {
      handler(data) {
        if (this.medicationSupport) {
          this.isFirstCompound = false;
          this.showSelector(
            event,
            this.popoverInfo.targetInfo.categoryNo,
            this.popoverInfo.targetInfo.subCategoryNo,
            this.popoverInfo.titleLabel
          );
        } else {
          //#10176:ポップアップのフリーワード検索の動作不正 Start
          this.dosOrPreCd = this.targetdrugchkreskbn(data);
          //#10176:ポップアップのフリーワード検索の動作不正 End
        }
      },
    },

    /**
     * 複合グラフ 対象要素
     */
    targetElement: {
      handler(data) {
        //#10176:ポップアップのフリーワード検索の動作不正 Start
        this.categoryFlg = this.targetdrugchkrescategoryflg(this.dosOrPreCd);
        //#10176:ポップアップのフリーワード検索の動作不正 End
        this.changePopoverDownListData(data);
      },
    },

    /**
     * 複合グラフ 薬剤区分
     */
    drugDistinguish: {
      handler(data) {
        //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
        //#10176:ポップアップのフリーワード検索の動作不正 Start
        this.categoryFlg = this.targetdrugchkrescategoryflg(data);
        //#10176:ポップアップのフリーワード検索の動作不正 End
        this.drugClassification = "0";
        this.medicineShowData(data);
      },
    },

    /**
     * 複合グラフ 薬剤分類
     */
    drugClassification: {
      handler(data) {
        this.drugClassificationDropList(data);
      },
    },

    inspectionStatus: {
      handler() {
        this.isFirstCompound = false;
        this.showSelector(
          event,
          this.popoverInfo.targetInfo.categoryNo,
          this.popoverInfo.targetInfo.subCategoryNo,
          this.popoverInfo.titleLabel
        );
      },
    },

    drugStatus: {
      handler(data) {
        if (data !== "投薬支援") {
          this.investmentSupport = true;
          // this.popoverFilter[0].popoverFilterDataset[0].text = "薬剤グループ";
          // this.popoverFilter[1].popoverFilterDataset[0].text = "薬剤グループ";
        } else {
          this.investmentSupport = false;
          // this.popoverFilter[0].popoverFilterDataset[0].text = "すべて";
          // this.popoverFilter[1].popoverFilterDataset[0].text = "すべて";
        }

        this.isFirstCompound = false;
        this.showSelector(
          event,
          this.popoverInfo.targetInfo.categoryNo,
          this.popoverInfo.targetInfo.subCategoryNo,
          this.popoverInfo.titleLabel
        );
      },
    },

    complaintTreatment: {
      handler() {
        this.showSelector(
          event,
          this.popoverInfo.targetInfo.categoryNo,
          this.popoverInfo.targetInfo.subCategoryNo,
          this.popoverInfo.titleLabel
        );
      },
    },

    /**
     * 期間が選択された際に項目を入れ替える
     */
    selectedPeriod() {
      // レイアウトデータの取得
      this.changeDispItem();
    },
  },

  mounted() {
    this.$el.parentElement.style.height = "100%";
    // del #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
    // this.retrieveMstData();
    // del #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
    // 表示項目を初期値として格納する
    this.initdispItemInfo = deepCopy(this.dispItemInfo);
    // 期間表示クラスのデフォルト値を格納する
    if ("" === this.editRecord.dispPeriodClass) {
      this.setDispPeriod(this.selectedPeriod);
    }
    // 表示期間に対応するレイアウトデータの取得
    this.changeDispItem();
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
    //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
    this.$nextTick(() => {
      //#10176:ポップアップのフリーワード検索の動作不正 Start
      this.categoryFlg = this.targetdrugchkrescategoryflg(this.dosOrPreCd);
      //#10176:ポップアップのフリーワード検索の動作不正 End
    });
    //add 8574  患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
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
    /**
    * @description ドラッグ操作の開始時の処理
    */
    choose(event,categoryNo) {
      if (categoryNo === 1) {
        this.isDraggingSubCategory = false;
        this.isDraggingSubCategoryItem = false;
        //ドラッグイベント発生前の治療情報のデータの取得
        this.preDragDispItemInfoTreatCond = deepCopy(this.dispItemInfoTreatCond);
        //ドラッグ対象項目のドラッグイベント発生前のインデックスの取得
        this.treatCondPreDragIndex = event.oldDraggableIndex;
        let preBvUfcIndex = -1;
        let preDialysisAmountProgramIndex = -1;
        //ドラッグイベント発生前の各非表示項目のインデックスの取得
        this.preDragDispItemInfoTreatCond[0].categoryItem.forEach((item, index) => {
          //BV-UFCのインデックスの取得
          if (item.subCategoryNo === 15) {
            preBvUfcIndex = index;
          //透析量プログラムのインデックスの取得
          } else if (item.subCategoryNo === 16) {
            preDialysisAmountProgramIndex = index;
          }
        });
        //BV-UFCまたは透析量プログラムが非表示、かつ、マスタ上に該当項目が存在する場合
        if((!this.isDispBvUfc && preBvUfcIndex >= 0) || (!this.isDispDialysisAmountProgram && preDialysisAmountProgramIndex >= 0)){
          //BV-UFCのインデックスの設定
          this.preBvUfcIndex = preBvUfcIndex;
          //透析量プログラムのインデックスの設定
          this.preDialysisAmountProgramIndex = preDialysisAmountProgramIndex;
          //治療情報の項目のドラッグ処理中フラグの設定
          this.isDraggingTreatCondSubCategory = true;
        }
      } else {
        this.isDraggingSubCategory = true;
        this.isDraggingSubCategoryItem = true;
      }
    },
    /**
    * @description ドラッグ操作の完了時の処理(治療情報)
    */
    finishTreatCondDragging() {
      this.isDraggingSubCategory = false;
      //治療情報の項目のドラッグ処理中フラグの設定解除
      this.isDraggingTreatCondSubCategory = false;
    },
    getPlotType() {
      return REPORT_GRAPH.SELECT_ITEM_PLOT_TYPE;
    },
    getDate() {
      return MED_DATE;
    },
    getmedicationSupportData() {
      return this.mstMedicineSupport;
    },
    // mod #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy start
    // getComplaint() {
    //   return complaintTreatmentInformation;
    getComplaint(categoryNo) {
      let complaint = complaintTreatmentInformation;
      if (categoryNo === 1017) {
        complaint = complaint.filter((item) => {
          return item.value < 3;
        });
      }
      return complaint;
    },

    // #9593 投薬支援マスタの設定が保存できない Zhou.tao Start
    syncMedicationSupport(event) {
      // kendo-vue-dropdownList のバグ修正
      this.medicationSupportChoose = event.sender._old;
    },
    // #9593 投薬支援マスタの設定が保存できない Zhou.tao End

    // mod #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy end
    saveMedicationSupport() {
      this.dispItemInfo.find((eleCategoryInfo) => {
        return 1028 === eleCategoryInfo.categoryNo;
      }).medicineGroupCd = this.medicationSupportChoose;
    },
    /**
     * @description 集計期間ドロップダウン値設定
     * add 鞠 5971 集計期間一括変更
     */
    summaryDateChange(event, subCategory) {
      for (let i = 0; i < subCategory.subCategoryItem.length; i++) {
        subCategory.subCategoryItem[i].itemDate = event.dataItem.value;
      }
    },
    /**
     * @description レイアウトデータ取得
     */
    retrieveMstData() {
      if (
        this.getAdvancedSettings.func_advcds.findIndex(
          (item) => item.func_advcd === ADVANCED_SETTINGS.MEDICATION_SUPPORT
        ) < 0
      ) {
        for (let i = 0; i < mstPatViewerLayoutDefine.length; i++) {
          if (
            mstPatViewerLayoutDefine[i] !== undefined &&
            mstPatViewerLayoutDefine[i].categoryNo !== undefined &&
            mstPatViewerLayoutDefine[i].categoryNo === 1028
          ) {
            mstPatViewerLayoutDefine.splice(i, 1);
          }
        }
      }
      const temp = this.editRecord.dispItemInfo
        ? JSON.parse(this.editRecord.dispItemInfo)
        : mstPatViewerLayoutDefine;
      // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
      // let rtnTmp = this.insertIsDispOption(temp);
      let rtnTmp = this.insertIsDispOption(
        temp,
        !!this.editRecord.dispItemInfo && !this.editRecord.isAddRow
      );
      // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
      // 施設設定 - 拡張機能の加算情報が有効でない場合、加算項目を非表示にする
      if (
        this.getAdvancedSettings.func_advcds.findIndex(
          (item) => item.func_advcd === ADVANCED_SETTINGS.ADDITION_INFO
        ) < 0
      ) {
        for (let i = 0; i < rtnTmp.length; i++) {
          if (
            rtnTmp[i] !== undefined &&
            rtnTmp[i].categoryNo !== undefined &&
            rtnTmp[i].categoryNo === 1
          ) {
            let chkObj = rtnTmp[i].categoryItem;
            for (let ii = 0; ii < chkObj.length; ii++) {
              if (
                chkObj[ii] !== undefined &&
                chkObj[ii].subCategoryNo !== undefined &&
                chkObj[ii].subCategoryNo === 74
              ) {
                chkObj.splice(ii, 1);
              }
            }
          }
        }
      }
      // バイタル・モニタグラフ　入室～退室の親子化
      let convertRtnTmp = [];
      for (let i = 0; i < rtnTmp.length; i++) {
        if (rtnTmp[i].categoryNo === 1) {
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
                treateCategoryItemList[j].subCategoryNo === 58 ||
                treateCategoryItemList[j].subCategoryNo === 65 ||
                treateCategoryItemList[j].subCategoryNo === 66
              ) {
                treateCategoryItem = treateCategoryItemList.find(
                  (item) => item.subCategoryNo === 58
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === 65
                  )
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === 66
                  )
                );
                excludeSubCategoryNoList.push(58);
                excludeSubCategoryNoList.push(65);
                excludeSubCategoryNoList.push(66);
              } else if (
                treateCategoryItemList[j].subCategoryNo === 59 ||
                treateCategoryItemList[j].subCategoryNo === 67 ||
                treateCategoryItemList[j].subCategoryNo === 68
              ) {
                treateCategoryItem = treateCategoryItemList.find(
                  (item) => item.subCategoryNo === 59
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === 67
                  )
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === 68
                  )
                );
                excludeSubCategoryNoList.push(59);
                excludeSubCategoryNoList.push(67);
                excludeSubCategoryNoList.push(68);
              } else if (
                treateCategoryItemList[j].subCategoryNo === 60 ||
                treateCategoryItemList[j].subCategoryNo === 69 ||
                treateCategoryItemList[j].subCategoryNo === 70
              ) {
                treateCategoryItem = treateCategoryItemList.find(
                  (item) => item.subCategoryNo === 60
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === 69
                  )
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === 70
                  )
                );
                excludeSubCategoryNoList.push(60);
                excludeSubCategoryNoList.push(69);
                excludeSubCategoryNoList.push(70);
              } else if (
                treateCategoryItemList[j].subCategoryNo === 61 ||
                treateCategoryItemList[j].subCategoryNo === 71 ||
                treateCategoryItemList[j].subCategoryNo === 72
              ) {
                treateCategoryItem = treateCategoryItemList.find(
                  (item) => item.subCategoryNo === 61
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === 71
                  )
                );
                vitalChild.push(
                  treateCategoryItemList.find(
                    (item) => item.subCategoryNo === 72
                  )
                );
                excludeSubCategoryNoList.push(61);
                excludeSubCategoryNoList.push(71);
                excludeSubCategoryNoList.push(72);
              } else {
                treateCategoryItem = treateCategoryItemList[j];
                excludeSubCategoryNoList.push(
                  treateCategoryItemList[j].subCategoryNo
                );
              }
              if (treateCategoryItem.vitalChild === undefined) {
                if (
                  treateCategoryItem.subCategoryNo >= 58 &&
                  treateCategoryItem.subCategoryNo <= 61
                ) {
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

    // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s start
    /**
     * @description 極限値を取得
     * @param { Array } arr 項目番号
     */
    getMstExamItemLimit(arr) {
      let selectedListmin = [];
      let selectedListmax = [];
      arr.forEach((item) => {
        this.mstExamItem.forEach((vaitalInfo) => {
          if (item.itemNo === vaitalInfo.examItemCd) {
            if (
              vaitalInfo.graphLower !== undefined &&
              vaitalInfo.graphLower !== null
            ) {
              selectedListmin.push(vaitalInfo.graphLower);
            }
            if (
              vaitalInfo.graphUpper !== undefined &&
              vaitalInfo.graphUpper !== null
            ) {
              selectedListmax.push(vaitalInfo.graphUpper);
            }
          }
        });
      });
      let min = 0;
      let max = 0;
      if (selectedListmin.length > 0) {
        min = Math.min(...selectedListmin);
      }
      if (selectedListmax.length > 0) {
        max = Math.max(...selectedListmax);
      }
      return [min, max];
    },
    // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s end
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
     * @description 表示期間更新
     * @param { String } dispPeriodClass 0: 3～14日、1: 12週～3年
     */
    setDispPeriod(dispPeriodClass) {
      // 編集中マスタを更新
      this.setEditRecord({ ...this.editRecord, dispPeriodClass });
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
    // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
    // insertIsDispOption(data) {
    insertIsDispOption(data, hasSavedDispItemInfo = false) {
      // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
      // 患者経過総合ビューアレイアウトマスタの項目定義
      const src = deepCopy(mstPatViewerLayoutDefine);
      // 編集中マスタ
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
      data.forEach((item) => {
        // 処理対象 > 短期：治療情報 / バイタル・モニタグラフ(24h) / 検査結果グラフ
        // 処理対象 > 長期：愁訴処置 / 医療材料集計 / 薬剤集計 / ダイアライザ集計 / バイタル・モニタグラフ / 検査結果グラフ / 薬剤グラフ / 複合グラフ
        // 大項目
        if (
          item.component === "treatment-contents" ||
          item.component === "vital" ||
          item.component === "exam-result" ||
          item.component === "complaint" ||
          item.component === "medical" ||
          item.component === "drugAggregate" ||
          item.component === "dialyzer" ||
          item.component === "vital" ||
          item.component === "exam-result" ||
          item.component === "drug-graph" ||
          item.component === "comprehensive"
        ) {
          // 中項目
          item.categoryItem.forEach((catItem) => {
            if (catItem.component === "exam-result") {
              // ■検査結果グラフ
              catItem.subCategoryItem.forEach((subItem) => {
                if (this.mstExamItemIsDisp.includes(subItem.itemNo)) {
                  subItem.isDispflag = true;
                }
              });
            } else if (
              catItem.component === "drugAggregate" ||
              catItem.component === "drug-graph"
            ) {
              // ■薬剤集計分類 / 薬剤グラフ
              if (catItem.component === "drugAggregate") {
                // ・薬剤集計分類・・・通常薬剤 / 調製薬剤
                catItem.subCategoryItem.forEach((subItem) => {
                  var itemName = subItem.itemNo + "";
                  if (itemName.includes("MEDICINE_MIX")) {
                    // 調製薬剤
                    var itemNo = itemName.replace("MEDICINE_MIX", "");
                    if (this.mstMedicineMixListDisp.includes(itemNo)) {
                      subItem.isDispflag = true;
                    }
                  } else {
                    // 通常薬剤
                    if (this.mstMedicineListDisp.includes(subItem.itemNo)) {
                      subItem.isDispflag = true;
                    }
                  }
                });
              } else {
                // ・薬剤グラフ・・・通常薬剤 / 調製薬剤 / 薬剤グループ
                catItem.subCategoryItem.forEach((subItem) => {
                  var itemName = subItem.itemNo + "";
                  if (itemName.includes("MEDICINE_MIX")) {
                    // 調製薬剤
                    var itemNo = itemName.replace("MEDICINE_MIX", "");
                    if (this.mstMedicineMixListDisp.includes(itemNo)) {
                      subItem.isDispflag = true;
                    }
                  } else if (itemName.includes("MEDICINE_GROUP")) {
                    // 薬剤グループ
                    var itemNo = itemName.replace("MEDICINE_GROUP", "");
                    if (this.mstMedicineGroupListDisp.includes(itemNo)) {
                      subItem.isDispflag = true;
                    }
                  } else {
                    // 通常薬剤
                    if (this.mstMedicineListDisp.includes(subItem.itemNo)) {
                      subItem.isDispflag = true;
                    }
                  }
                });
              }
            } else if (catItem.component === "medical") {
              // ■医療材料集計
              catItem.subCategoryItem.forEach((subItem) => {
                if (this.mstEquipmentListDisp.includes(subItem.itemNo)) {
                  subItem.isDispflag = true;
                }
              });
            } else if (catItem.component === "dialyzer") {
              // ■ダイアライザ集計
              catItem.subCategoryItem.forEach((subItem) => {
                if (this.mstDialyzerListDisp.includes(subItem.itemNo)) {
                  subItem.isDispflag = true;
                }
              });
            } else if (
              catItem.component === "rst-info" &&
              catItem.subCategoryNo === 56
            ) {
              // ■治療情報 > 愁訴処置情報(処置・愁訴)
              catItem.subCategoryItem.forEach((subItem) => {
                // 愁訴処置情報(処置)
                if (this.mstTreatmentListDisp.includes(subItem.itemNo)) {
                  subItem.isDispflag = true;
                }
                // 愁訴処置情報(愁訴)
                if (this.mstComplaintListDisp.includes(subItem.itemNo)) {
                  subItem.isDispflag = true;
                }
              });
            } else if (catItem.component === "complaint") {
              // ■愁訴処置(処置・愁訴)
              catItem.subCategoryItem.forEach((subItem) => {
                var itemName = subItem.itemNo + "";
                // 愁訴処置(処置)
                var itemNo_1 = itemName.replace("CompTreatment*", "");
                if (this.mstTreatmentListDisp.includes(itemNo_1)) {
                  subItem.isDispflag = true;
                }
                // 愁訴処置(愁訴)
                var itemNo_2 = itemName.replace("Complaints*", "");
                if (this.mstComplaintListDisp.includes(itemNo_2)) {
                  subItem.isDispflag = true;
                }
              });
            } else if (catItem.component === "vital") {
              // ■バイタル・モニタグラフ(入室～退室) / バイタル・モニタグラフ(24h) / バイタル・モニタグラフ
              catItem.subCategoryItem.forEach((subItem) => {
                var isAddMonitor = subItem.itemNo > 10000 ? true : false;
                if (
                  isAddMonitor &&
                  this.mstAddMonitorListDisp.includes(subItem.itemNo - 10000)
                ) {
                  subItem.isDispflag = true;
                }
              });
            } else if (catItem.component === "comprehensive") {
              // ■複合グラフ
              catItem.subCategoryItem.forEach((subItem) => {
                // 種別判別
                if (subItem.itemDivision === 2) {
                  // ・検査結果(itemDivision："2")
                  if (this.mstExamItemIsDisp.includes(subItem.itemNo)) {
                    subItem.isDispflag = true;
                  }
                } else if (subItem.itemDivision === 4) {
                  // ・投与薬剤(itemDivision："4")
                  var itemName = subItem.itemNo + "";
                  if (itemName.includes("MEDICINE_MIX")) {
                    // 調製薬剤
                    var itemNo = itemName.replace("MEDICINE_MIX", "");
                    if (this.mstMedicineMixListDisp.includes(itemNo)) {
                      subItem.isDispflag = true;
                    }
                  } else if (itemName.includes("MEDICINE_GROUP")) {
                    // 薬剤グループ
                    var itemNo = itemName.replace("MEDICINE_GROUP", "");
                    if (this.mstMedicineGroupListDisp.includes(itemNo)) {
                      subItem.isDispflag = true;
                    }
                  } else {
                    // 通常薬剤
                    if (this.mstMedicineListDisp.includes(subItem.itemNo)) {
                      subItem.isDispflag = true;
                    }
                  }
                } else if (subItem.itemDivision === 5) {
                  // ・バイタル・モニタ(itemDivision："5")
                  var isAddMonitor = subItem.moniNo > 10000 ? true : false;
                  if (
                    isAddMonitor &&
                    this.mstAddMonitorListDisp.includes(subItem.moniNo - 10000)
                  ) {
                    subItem.isDispflag = true;
                  }
                }
              });
            }
          });
        }
      });
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
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
              // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
              if (destSubCategory.isDisp === undefined) {
                if (
                  srcCategory.categoryNo === 1 &&
                  ((58 <= destSubCategory.subCategoryNo &&
                    destSubCategory.subCategoryNo <= 61) ||
                    (65 <= destSubCategory.subCategoryNo &&
                      destSubCategory.subCategoryNo <= 72))
                ) {
                  destSubCategory.isDisp = hasSavedDispItemInfo;
                } else {
                  destSubCategory.isDisp = true;
                }
              }
              if (
                srcCategory.categoryNo === 1 &&
                58 <= destSubCategory.subCategoryNo &&
                destSubCategory.subCategoryNo <= 61
              ) {
                (destSubCategory.vitalChild || []).forEach((vitalChildItem) => {
                  if (vitalChildItem.isDisp === undefined) {
                    vitalChildItem.isDisp = hasSavedDispItemInfo;
                  }
                  (vitalChildItem.subCategoryItem || []).forEach((item) => {
                    if (item.isDisp === undefined) {
                      item.isDisp = hasSavedDispItemInfo;
                    }
                  });
                });
              }
              // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
              // 治療情報の場合
              if (1 === srcCategory.categoryNo) {
                // 小項目番号を格納
                const cateNo = destSubCategory.subCategoryNo;
                // バイタル情報の場合、レイアウトマスタ情報に定義がなくても非表示にされない
                if (
                  (cateNo >= 58 && 61 >= cateNo) ||
                  (65 <= cateNo && cateNo <= 72) ||
                  cateNo === 56
                ) {
                  srcSubCategory.subCategoryItem =
                    destSubCategory.subCategoryItem;
                }
              } else if (
                (2 <= srcCategory.categoryNo && srcCategory.categoryNo <= 19) ||
                (1002 <= srcCategory.categoryNo &&
                  srcCategory.categoryNo <= 1027) // 1012 -> 1015: 投与薬剤グラフ と 処方薬剤グラフ
              ) {
                srcSubCategory.subCategoryItem =
                  destSubCategory.subCategoryItem;
              }
              if (
                srcCategory.categoryNo === 1 &&
                srcSubCategory.subCategoryNo === 56
              ) {
                srcSubCategory.subCategoryItem.forEach((srcItem) => {
                  const destItem = destSubCategory.subCategoryItem.find(
                    (itemOther) => {
                      return (
                        itemOther.itemNo === srcItem.itemNo &&
                        itemOther.complaintClassify ===
                          srcItem.complaintClassify
                      );
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
              } else if (
                srcCategory.categoryNo === 15 ||
                srcCategory.categoryNo === 16
              ) {
                srcSubCategory.subCategoryItem.forEach((srcItem) => {
                  const destItem = destSubCategory.subCategoryItem.find(
                    (itemOther) => {
                      return (
                        itemOther.itemNo === srcItem.itemNo &&
                        itemOther.isPatEventSub === srcItem.isPatEventSub
                      );
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
                        // mod 10739 by shiyw 20250307 start
                        //return itemOther.itemNo === srcItem.itemNo;
                        return (
                          itemOther.itemNo ===
                          (srcItem.itemNo ?? srcItem.itemInfo.itemNo)
                        );
                        // mod 10739 by shiyw 20250307 end
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
     * @description 内部処理用表示フラグを保存データから削除
     * @param { Array } data 編集レイアウト
     */
    removeIsDispOption(data) {
      let res = deepCopy(data);

      // 非表示とした項目を配列から削除
      res = res.filter((category) => {
        category.categoryItem = category.categoryItem.filter((subCategory) => {
          if (
            subCategory.subCategoryNo >= 58 &&
            subCategory.subCategoryNo <= 61
          ) {
            subCategory.subCategoryItem = subCategory.subCategoryItem.filter(
              (item) => {
                return item.isDisp;
              }
            );
            return true;
          } else {
            subCategory.subCategoryItem = subCategory.subCategoryItem.filter(
              (item) => {
                return item.isDisp;
              }
            );
            return subCategory.isDisp;
          }
        });
        return category.isDisp;
      });

      // 「バイタル・モニタグラフ 入室～退室①～④」の(不要)キーを削除
      res.forEach((category) => {
        if (category.categoryNo === 1) {
          category.categoryItem.forEach((subCategory) => {
            if (
              subCategory.subCategoryNo === 58 ||
              subCategory.subCategoryNo === 59 ||
              subCategory.subCategoryNo === 60 ||
              subCategory.subCategoryNo === 61
            ) {
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
        }
      });

      // 「isDisp」のキーを削除
      res.forEach((category) => {
        category.categoryItem.forEach((subCategory) => {
          if (
            subCategory.subCategoryNo < 58 ||
            subCategory.subCategoryNo > 61
          ) {
            subCategory.subCategoryItem.forEach((item) => {
              delete item.isDisp;
            });
            delete subCategory.isDisp;
          }
        });
        delete category.isDisp;
      });

      // 「治療情報」表示配列の再作成(isDisp=falseの削除)
      if (res.length > 0) {
        let convertRes = [];
        for (let i = 0; i < res.length; i++) {
          if (res[i].categoryNo === 1) {
            let convertTreateCategoryItem = [];
            let treateCategoryItemList = res[i].categoryItem;
            for (let j = 0; j < treateCategoryItemList.length; j++) {
              if (
                treateCategoryItemList[j].subCategoryNo >= 58 &&
                treateCategoryItemList[j].subCategoryNo <= 61 &&
                treateCategoryItemList[j].vitalChild !== undefined
              ) {
                let vitalChild = [];
                for (
                  let k = 0;
                  k < treateCategoryItemList[j].vitalChild.length;
                  k++
                ) {
                  let subCategoryItem = [];
                  for (
                    let m = 0;
                    m <
                    treateCategoryItemList[j].vitalChild[k].subCategoryItem
                      .length;
                    m++
                  ) {
                    if (
                      treateCategoryItemList[j].vitalChild[k].subCategoryItem[m]
                        .isDisp
                    ) {
                      subCategoryItem.push(
                        treateCategoryItemList[j].vitalChild[k].subCategoryItem[
                          m
                        ]
                      );
                    }
                  }
                  treateCategoryItemList[j].vitalChild[k].subCategoryItem =
                    subCategoryItem;
                  vitalChild.push(treateCategoryItemList[j].vitalChild[k]);
                }
                treateCategoryItemList[j].vitalChild = vitalChild;
              }
              convertTreateCategoryItem.push(treateCategoryItemList[j]);
            }
            res[i].categoryItem = convertTreateCategoryItem;
          }
          convertRes.push(res[i]);
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
      const categoryNo = path[0];
      const subCategoryNo = path[1];
      const itemNo = path[2];

      // 必須項目自動設定情報を初期化
      this.isAutoSetRequiredItem = new Array();
      // 「治療情報」項目でかつ、「治療予定」もしくは「治療方法」が変更された場合
      if (1 === categoryNo && (1 === subCategoryNo || 2 === subCategoryNo)) {
        // 必須自動設定番号を格納
        this.isAutoSetRequiredItem.push(subCategoryNo);
      }

      let parentSubCategoryNo = this.getParentSubCategoryNo(subCategoryNo);

      const category =
        categoryNo &&
        this.dispItemInfo.find((item) => {
          return item.categoryNo === categoryNo;
        });

      let subCategory =
        parentSubCategoryNo &&
        category.categoryItem.find((item) => {
          return item.subCategoryNo === parentSubCategoryNo;
        });

      let subCategoryItem = null;
      if (
        subCategoryNo === 65 ||
        subCategoryNo === 67 ||
        subCategoryNo === 69 ||
        subCategoryNo === 71
      ) {
        subCategoryItem =
          itemNo &&
          subCategory.vitalChild[0].subCategoryItem.find((item) => {
            return item.itemNo === itemNo;
          });
      } else if (
        subCategoryNo === 66 ||
        subCategoryNo === 68 ||
        subCategoryNo === 70 ||
        subCategoryNo === 72
      ) {
        subCategoryItem =
          itemNo &&
          subCategory.vitalChild[1].subCategoryItem.find((item) => {
            return item.itemNo === itemNo;
          });
      } else {
        subCategoryItem =
          itemNo &&
          subCategory.subCategoryItem.find((item) => {
            return item.itemNo === itemNo;
          });
      }

      switch (type) {
        case "category":
          category.categoryItem.forEach((item) => {
            item.subCategoryItem.forEach((i) => {
              i.isDisp = !category.isDisp;
            });
            // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
            if (item.subCategoryNo >= 58 && item.subCategoryNo <= 61) {
              if(item.subCategoryItem.length > 0) {
                item.isDisp = !category.isDisp;
              }
              item.vitalChild.forEach((vitalChildItem) => {
                if(vitalChildItem.subCategoryItem.length > 0) {
                  vitalChildItem.isDisp = !category.isDisp;
                  vitalChildItem.subCategoryItem.forEach((subCategoryItem) => {
                    subCategoryItem.isDisp = !category.isDisp;
                  });
                }
              });
            } else {
              item.isDisp = !category.isDisp;
            }
            // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
          });
          break;
        case "subCategory":
          if (
            subCategoryNo === 65 ||
            subCategoryNo === 67 ||
            subCategoryNo === 69 ||
            subCategoryNo === 71
          ) {
            subCategory.vitalChild[0].subCategoryItem.forEach(
              (item) => (item.isDisp = !subCategory.vitalChild[0].isDisp)
            );
            category.isDisp =
              !subCategory.vitalChild[0].isDisp || category.isDisp;
          } else if (
            subCategoryNo === 66 ||
            subCategoryNo === 68 ||
            subCategoryNo === 70 ||
            subCategoryNo === 72
          ) {
            subCategory.vitalChild[1].subCategoryItem.forEach(
              (item) => (item.isDisp = !subCategory.vitalChild[1].isDisp)
            );
            category.isDisp =
              !subCategory.vitalChild[1].isDisp || category.isDisp;
          } else {
            subCategory.subCategoryItem.forEach(
              (item) => (item.isDisp = !subCategory.isDisp)
            );
            category.isDisp = !subCategory.isDisp || category.isDisp;
          }
          // add 6852 項目のON／OFFに伴う制御の不正 周安寧 start
          const flg = category.isDisp;
          let schedule = category.categoryItem.find((item) => {
            return item.subCategoryNo === 1;
          });
          schedule.isDisp = flg;
          let treatment = category.categoryItem.find((item) => {
            return item.subCategoryNo === 2;
          });
          treatment.isDisp = flg;
          // add 6852 項目のON／OFFに伴う制御の不正 周安寧 end
          break;
        case "subCategoryItem":
          if (
            subCategoryNo === 65 ||
            subCategoryNo === 67 ||
            subCategoryNo === 69 ||
            subCategoryNo === 71
          ) {
            category.isDisp = !subCategoryItem.isDisp || category.isDisp;
            // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
            let childsubCategory = subCategory.vitalChild[0];
            let isDisp = childsubCategory.subCategoryItem.some(el => el.isDisp && el.itemNo != subCategoryItem.itemNo) || !subCategoryItem.isDisp;
            childsubCategory.isDisp = isDisp;
            if(!isDisp) {
              subCategoryItem.isDisp = false;
            } else {
              subCategoryItem.isDisp = true;
            }
            // subCategory.vitalChild[0].isDisp =
            //   !subCategoryItem.isDisp || category.isDisp;
            // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
          } else if (
            subCategoryNo === 66 ||
            subCategoryNo === 68 ||
            subCategoryNo === 70 ||
            subCategoryNo === 72
          ) {
            category.isDisp = !subCategoryItem.isDisp || category.isDisp;
            // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
            let childsubCategory = subCategory.vitalChild[1];
            let isDisp = childsubCategory.subCategoryItem.some(el => el.isDisp && el.itemNo != subCategoryItem.itemNo) || !subCategoryItem.isDisp;
            childsubCategory.isDisp = isDisp;
            if(!isDisp) {
              subCategoryItem.isDisp = false;
            } else {
              subCategoryItem.isDisp = true;
            }
            // subCategory.vitalChild[1].isDisp =
            //   !subCategoryItem.isDisp || category.isDisp;
            // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
          } else {
            category.isDisp = !subCategoryItem.isDisp || category.isDisp;
            // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
            let isDisp = subCategory.subCategoryItem.some(el => el.isDisp && el.itemNo != subCategoryItem.itemNo) || !subCategoryItem.isDisp;
            subCategory.isDisp = isDisp;
            if(!isDisp) {
              subCategoryItem.isDisp = false;
            } else {
              subCategoryItem.isDisp = true;
            }
            // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
          }
          break;
        default:
          break;
      }

      if (1012 <= categoryNo && categoryNo <= 1015) {
        // 複合グラフ
        let temp;
        if (type === "category") {
          subCategory = category.categoryItem.find((item) => {
            return item.subCategoryNo === 1;
          });
          temp = subCategory.isDisp;
        } else {
          temp = !subCategory.isDisp;
        }
        if (temp === true && subCategory.subCategoryItem.length > MAX_COLUMN) {
          for (
            let k = MAX_COLUMN;
            k < subCategory.subCategoryItem.length;
            k++
          ) {
            subCategory.subCategoryItem[k].isDisp = false;
          }
        }
      }

      // 「治療情報」項目が変更された場合、「投与薬剤」の小項目選択を制御
      if (1 === categoryNo) {
        // 大項目が変更された場合、「投与薬剤」の1番目の小項目を選択する
        if (type === "category") {
          const subCategoryMedi = category.categoryItem.find((item) => {
            return item.subCategoryNo === 5;
          });
          subCategoryMedi.subCategoryItem[0].isDisp = !category.isDisp;
          subCategoryMedi.subCategoryItem[1].isDisp = false;
        }
        // 中項目が変更された場合、「投与薬剤」の1番目の小項目を選択する
        else if (type === "subCategory" && subCategoryNo === 5) {
          subCategory.subCategoryItem[0].isDisp = !subCategory.isDisp;
          subCategory.subCategoryItem[1].isDisp = false;
        }
        // add 6852 項目のON／OFFに伴う制御の不正 周安寧 start
        else if (
          type === "subCategory" &&
          (subCategoryNo === 1 || subCategoryNo === 2)
        ) {
          const flg = category.isDisp;
          let schedule = category.categoryItem.find((item) => {
            return item.subCategoryNo === 1;
          });
          schedule.isDisp = flg;
          let treatment = category.categoryItem.find((item) => {
            return item.subCategoryNo === 2;
          });
          treatment.isDisp = flg;
        }
        // add 6852 項目のON／OFFに伴う制御の不正 周安寧 end
        // 小項目が変更された場合、選択された項目のみ選択する(複数選択不可)
        else if (type === "subCategoryItem" && subCategoryNo === 5) {
          if (!subCategory.isDisp) {
            subCategory.subCategoryItem[1].isDisp =
              !subCategory.subCategoryItem[0].isDisp;
          } else {
            // mod 6852 項目のON／OFFに伴う制御の不正 周安寧 start
            if (path[2] == 1 && subCategory.subCategoryItem[0].isDisp == true) {
              subCategory.subCategoryItem[0].isDisp = false;
              subCategory.subCategoryItem[1].isDisp = false;
            } else if (
              path[2] == 1 &&
              subCategory.subCategoryItem[0].isDisp == false
            ) {
              subCategory.subCategoryItem[0].isDisp = true;
              subCategory.subCategoryItem[1].isDisp = false;
            } else if (
              path[2] == 2 &&
              subCategory.subCategoryItem[1].isDisp == true
            ) {
              subCategory.subCategoryItem[0].isDisp = false;
              subCategory.subCategoryItem[1].isDisp = false;
            } else if (
              path[2] == 2 &&
              subCategory.subCategoryItem[1].isDisp == false
            ) {
              subCategory.subCategoryItem[0].isDisp = false;
              subCategory.subCategoryItem[1].isDisp = true;
            }
            if (
              subCategory.subCategoryItem[0].isDisp ||
              subCategory.subCategoryItem[1].isDisp
            ) {
              subCategory.isDisp = true;
            } else {
              subCategory.isDisp = false;
            }
            // mod 6852 項目のON／OFFに伴う制御の不正 周安寧 end
          }
        }
      }
      // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s start
      if (
        //検査結果
        (8 <= categoryNo && categoryNo <= 11) ||
        (1008 <= categoryNo && categoryNo <= 1011)
      ) {
        if (type == "subCategoryItem") {
          let selectedListmin = [];
          let selectedListmax = [];
          subCategory.subCategoryItem.forEach((item) => {
            if (
              (item.itemNo != itemNo && item.isDisp) ||
              (item.itemNo == itemNo && !item.isDisp)
            )
              this.mstExamItem.forEach((vaitalInfo) => {
                if (item.itemNo === vaitalInfo.examItemCd) {
                  if (
                    vaitalInfo.graphLower != undefined &&
                    vaitalInfo.graphLower != null
                  ) {
                    selectedListmin.push(vaitalInfo.graphLower);
                  }
                  if (
                    vaitalInfo.graphUpper != undefined &&
                    vaitalInfo.graphUpper != null
                  ) {
                    selectedListmax.push(vaitalInfo.graphUpper);
                  }
                }
              });
          });
          let min = 0;
          let max = 0;
          if (selectedListmin.length > 0) {
            min = Math.min(...selectedListmin);
          }
          if (selectedListmax.length > 0) {
            max = Math.max(...selectedListmax);
          }
          subCategory.min = min;
          subCategory.max = max;
        } else if (type == "subCategory") {
          if (!subCategory.isDisp) {
            const limit = this.getMstExamItemLimit(subCategory.subCategoryItem);
            subCategory.min = limit[0];
            subCategory.max = limit[1];
          } else {
            subCategory.min = 0;
            subCategory.max = 0;
          }
        } else if (type == "category") {
          if (!category.isDisp) {
            category.categoryItem.forEach((subCategory) => {
              const limit = this.getMstExamItemLimit(
                subCategory.subCategoryItem
              );
              subCategory.min = limit[0];
              subCategory.max = limit[1];
            });
          } else {
            category.categoryItem.forEach((subCategory) => {
              subCategory.min = 0;
              subCategory.max = 0;
            });
          }
        }
      }
      // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s end
    },

    /**
     * 期間ごとの表示項目に変更する
     * @param 期間を選択した際に表示項目を入れ替える
     */
    changeDispItem() {
      // 初期表示項目リストが1つも格納されていない場合処理終了
      if (this.initdispItemInfo.length === 0) {
        return;
      }
      this.dispItemInfo = this.initdispItemInfo.filter((item) => {
        if (this.selectedPeriod === "0") {
          // 3日・7日・14日選択時はカテゴリNo.1000以下の項目を表示
          return item.categoryNo <= 1000;
        } else if (this.selectedPeriod === "1") {
          // 12週・6ヶ月・1年・3年選択時はカテゴリNo.1001以上の項目を表示
          return item.categoryNo > 1000;
        }
      });
    },

    /**
     * 項目の表示非表示切替
     * @description
     *  小項目が1つも表示状態でない場合、それが属する中項目を非表示に切り替える
     *  中項目が1つも表示状態でない場合、それが属する大項目を非表示に切り替える
     *  「治療情報」の項目のうち、表示するものが1つでもある場合、「治療予定」、「治療方法」を表示にする
     */
    switchingItemDisp() {
      // 大項目情報でループ
      this.dispItemInfo.forEach((categoryInfo) => {
        // 大項目表示・非表示切替格納用
        let categoryDisp = false;
        // 中項目情報でループ
        categoryInfo.categoryItem.forEach((subCategoryInfo) => {
          // 中項目表示・非表示切替格納用
          let subCategoryDisp = false;
          if (
            (categoryInfo.categoryNo === 1 &&
              // subCategoryInfo.subCategoryNo !== 5 &&
              subCategoryInfo.subCategoryNo !== 4 &&
              subCategoryInfo.subCategoryNo !== 3) ||
            categoryInfo.categoryNo === 12 ||
            categoryInfo.categoryNo === 13 ||
            categoryInfo.categoryNo === 14 ||
            categoryInfo.categoryNo === 17 ||
            categoryInfo.categoryNo === 1016 ||
            categoryInfo.categoryNo === 1017 ||
            categoryInfo.categoryNo === 1018 ||
            categoryInfo.categoryNo === 1019 ||
            categoryInfo.categoryNo === 1022
          ) {
            subCategoryDisp = subCategoryInfo.isDisp;
            // add #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
            if(subCategoryInfo.subCategoryNo == 58 || subCategoryInfo.subCategoryNo == 59 
              || subCategoryInfo.subCategoryNo == 60 || subCategoryInfo.subCategoryNo == 61) {
                subCategoryInfo.vitalChild.forEach((vitalChild) => {
                  if(vitalChild.isDisp) {
                    categoryDisp = true;
                  }
                });
            }
            // add #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
          } else {
            // 小項目情報でループ
            subCategoryInfo.subCategoryItem.forEach((item) => {
              // 中項目表示・非表示切替を設定
              subCategoryDisp = item.isDisp ? item.isDisp : subCategoryDisp;
            });
          }
          // 中項目表示・非表示を切替
          subCategoryInfo.isDisp = subCategoryDisp;
          // 大項目表示・非表示切替を設定
          categoryDisp = subCategoryDisp ? subCategoryDisp : categoryDisp;
        });
        // 大項目表示・非表示切替を格納
        categoryInfo.isDisp = categoryDisp;

        // 「治療情報」項目の場合以下の処理を実行
        if (1 === categoryInfo.categoryNo) {
          // 「治療予定」「治療方法」表示フラグ
          let isDisp = false;
          // 必須項目操作不可フラグ
          // mod 6852 項目のON／OFFに伴う制御の不正 周安寧 start
          if (categoryInfo.isDisp) {
            this.isDisabledRequiredItem = true;
          } else {
            this.isDisabledRequiredItem = false;
          }
          //this.isDisabledRequiredItem = false;
          // mod 6852 項目のON／OFFに伴う制御の不正 周安寧 end
          isDisp = categoryInfo.isDisp;
          categoryInfo.categoryItem.forEach((subCategoryInfo) => {
            const subNo = subCategoryInfo.subCategoryNo;
            // 「治療予定」、「治療方法」の表示フラグを格納する
            if (1 === subNo || 2 === subNo) {
              // 自動設定しないサブカテゴリ番号を取得
              const disSetNo =
                1 === this.isAutoSetRequiredItem.length
                  ? this.isAutoSetRequiredItem[0]
                  : 0;
              // どちらかの項目もしくは、両方の項目を自動設定する
              if (subNo !== disSetNo) {
                // add #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
                subCategoryInfo.isDisp = isDisp;
                // add #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
                subCategoryInfo.subCategoryItem.forEach((item) => {
                  item.isDisp = isDisp;
                });
              }
            }
          });
          categoryInfo.categoryItem.forEach((subCategoryInfo) => {
            const subNo = subCategoryInfo.subCategoryNo;
            if (1 !== subNo && 2 !== subNo) {
              subCategoryInfo.subCategoryItem.forEach((item) => {
                if (item.isDisp) {
                  this.isDisabledRequiredItem = true;
                  let temp = this.dispItemInfo.find((eleCategoryInfo) => {
                    return 1 === eleCategoryInfo.categoryNo;
                  });

                  if (temp.isDisp) {
                    this.dispItemInfo
                      .find((eleCategoryInfo) => {
                        return 1 === eleCategoryInfo.categoryNo;
                      })
                      .categoryItem.find((eleSubCategoryInfo) => {
                        return 1 === eleSubCategoryInfo.subCategoryNo;
                      }).isDisp = true;
                    this.dispItemInfo
                      .find((eleCategoryInfo) => {
                        return 1 === eleCategoryInfo.categoryNo;
                      })
                      .categoryItem.find((eleSubCategoryInfo) => {
                        return 2 === eleSubCategoryInfo.subCategoryNo;
                      }).isDisp = true;
                  }
                }
              });
            }
          });
        }
      });
    },

    /**
     * 項目選択アイコン表示・非表示切替
     * @description バイタル・モニタ(グラフ)がアイコン表示対象
     * @param categoryNo    大項目番号
     * @param subCategoryNo 中項目番号
     */
    isSelectIcon(categoryNo, subCategoryNo) {
      // 項目追加・削除アイコン表示フラグ
      let isDispIcon = false;
      // 大項目が治療情報の場合
      if (1 === categoryNo) {
        // 中項目がバイタル情報の場合
        if (
          (subCategoryNo >= 58 && 61 >= subCategoryNo) ||
          subCategoryNo === 56 ||
          (65 <= subCategoryNo && subCategoryNo <= 72)
        ) {
          isDispIcon = true;
        }
        // 大項目がバイタル情報の場合
      } else if (
        (2 <= categoryNo && categoryNo <= 11) ||
        (15 <= categoryNo && categoryNo <= 16) ||
        (18 <= categoryNo && categoryNo <= 19) ||
        (1020 <= categoryNo && categoryNo <= 1022) ||
        (1002 <= categoryNo && categoryNo <= 1015) || // 1012 -> 1015: 投与薬剤グラフ と 処方薬剤グラフ
        1017 === categoryNo ||
        1018 === categoryNo ||
        1019 === categoryNo ||
        (1024 <= categoryNo && categoryNo <= 1027)
      ) {
        isDispIcon = true;
      }
      return isDispIcon;
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
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/14 by liumx start
      // 検査結果グラフ ,複合グラフの状況
      // 検査結果グラフ,(8 <= categoryNo && categoryNo <= 11),(1008 <= categoryNo && categoryNo <= 1011)
      // 複合グラフの状況 (1024 <= categoryNo && categoryNo <= 1027)
      if (
        (8 <= categoryNo && categoryNo <= 11) ||
        (1008 <= categoryNo && categoryNo <= 1011) ||
        (1024 <= categoryNo && categoryNo <= 1027)
      ) {
        // 選択したデータを取得
        let temp = this.dispItemInfo
          .find((eleCategoryInfo) => {
            return categoryNo === eleCategoryInfo.categoryNo;
          })
          .categoryItem.find((eleSubCategoryInfo) => {
            return subCategoryNo === eleSubCategoryInfo.subCategoryNo;
          });
        // 選択した検査結果グラフID
        let selectedIds = [];
        temp.subCategoryItem.forEach((item) => {
          selectedIds.push(item.itemNo);
        });
        // フルデータを巡回,削除なし、および選択された削除を返す
        this.mstExamItem = this.allMstExamItem.filter((item) => {
          if (item.isDisp === "1" || selectedIds.includes(item.examItemCd)) {
            return item;
          }
        });
      }
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 2023/09/14 by liumx end
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
      if (categoryNo == 1 && subCategoryNo == 56) {
        // 選択したデータを取得
        let temp = this.dispItemInfo
          .find((eleCategoryInfo) => {
            return categoryNo === eleCategoryInfo.categoryNo;
          })
          .categoryItem.find((eleSubCategoryInfo) => {
            return subCategoryNo === eleSubCategoryInfo.subCategoryNo;
          });
        // 選択した検査結果グラフID
        let selectedCoIds = [];
        temp.subCategoryItem.forEach((item) => {
          selectedCoIds.push(item.itemNo);
        });
        // フルデータを巡回,削除なし、および選択された削除を返す
        this.mstComplaints = this.mstComplaints.filter((item) => {
          if (
            item.is_disp === "1" ||
            selectedCoIds.includes(item.complaint_cd + "")
          ) {
            return item;
          }
        });
        this.mstCompTreatment = this.mstCompTreatment.filter((item) => {
          if (
            item.is_disp === "1" ||
            selectedCoIds.includes(item.comp_treatment_cd + "")
          ) {
            return item;
          }
        });
      }
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      let parentSubCategoryNo = this.getParentSubCategoryNo(subCategoryNo);
      if (1012 <= categoryNo && categoryNo <= 1015) {
        let temp = this.dispItemInfo
          .find((eleCategoryInfo) => {
            return categoryNo === eleCategoryInfo.categoryNo;
          })
          .categoryItem.find((eleSubCategoryInfo) => {
            return subCategoryNo === eleSubCategoryInfo.subCategoryNo;
          });
        if (temp.drugStatus !== undefined && temp.drugStatus !== null) {
          this.popMedicineInfo.drugStatus = temp.drugStatus;
        } else {
          this.popMedicineInfo.drugStatus = "指示";
        }
        // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
        // this.popMedicineInfo.graphMin = (temp.graphMin !== undefined && temp.graphMin !== null ) ? temp.graphMin : 0;
        // this.popMedicineInfo.graphMax = (temp.graphMax !== undefined && temp.graphMax !== null ) ? temp.graphMax : 0;
        this.popMedicineInfo.graphMin = (temp.graphMin !== undefined && temp.graphMin !== null ) ? temp.graphMin : '';
        this.popMedicineInfo.graphMax = (temp.graphMax !== undefined && temp.graphMax !== null ) ? temp.graphMax : '';
        // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
        this.popMedicineInfo.targetInfo = {
          categoryNo,
          subCategoryNo,
        };
        this.setMediPopover(categoryNo, subCategoryNo);
        return;
      }

      // if (1024 <= categoryNo && categoryNo <= 1027) {
      let temp = this.dispItemInfo
        .find((eleCategoryInfo) => {
          return categoryNo === eleCategoryInfo.categoryNo;
        })
        .categoryItem.find((eleSubCategoryInfo) => {
          return parentSubCategoryNo === eleSubCategoryInfo.subCategoryNo;
        });
      if (
        subCategoryNo === 65 ||
        subCategoryNo === 67 ||
        subCategoryNo === 69 ||
        subCategoryNo === 71
      ) {
        temp = temp.vitalChild[0];
      } else if (
        subCategoryNo === 66 ||
        subCategoryNo === 68 ||
        subCategoryNo === 70 ||
        subCategoryNo === 72
      ) {
        temp = temp.vitalChild[1];
      } else {
        temp = temp;
      }
      if (temp.drugStatus !== undefined) {
        this.drugStatus = temp.drugStatus;
      } else {
        this.drugStatus = "指示";
      }
      // }
      // 大項目情報でループ
      this.dispItemInfo.forEach((eleCategory) => {
        // 大項目番号が一致する場合
        if (eleCategory.categoryNo === categoryNo) {
          // 中項目情報でループ
          eleCategory.categoryItem.forEach((eleSubCategory) => {
            let subCategory = null;
            if (eleSubCategory.subCategoryNo === 58) {
              if (subCategoryNo === 65) {
                subCategory = eleSubCategory.vitalChild[0];
              } else if (subCategoryNo === 66) {
                subCategory = eleSubCategory.vitalChild[1];
              } else {
                subCategory = eleSubCategory;
              }
            } else if (eleSubCategory.subCategoryNo === 59) {
              if (subCategoryNo === 67) {
                subCategory = eleSubCategory.vitalChild[0];
              } else if (subCategoryNo === 68) {
                subCategory = eleSubCategory.vitalChild[1];
              } else {
                subCategory = eleSubCategory;
              }
            } else if (eleSubCategory.subCategoryNo === 60) {
              if (subCategoryNo === 69) {
                subCategory = eleSubCategory.vitalChild[0];
              } else if (subCategoryNo === 70) {
                subCategory = eleSubCategory.vitalChild[1];
              } else {
                subCategory = eleSubCategory;
              }
            } else if (eleSubCategory.subCategoryNo === 61) {
              if (subCategoryNo === 71) {
                subCategory = eleSubCategory.vitalChild[0];
              } else if (subCategoryNo === 72) {
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
                : // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                  // : 0;
                  "";
              // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
              // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s start
              if (
                //検査結果
                (8 <= categoryNo && categoryNo <= 11) ||
                (1008 <= categoryNo && categoryNo <= 1011)
              ) {
                this.selectedSetting.min.initValue = subCategory.min
                  ? subCategory.min
                  : // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                    // : 0;
                    "";
                // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
                this.selectedSetting.max.initValue = subCategory.max
                  ? subCategory.max
                  : // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
                    // : 0;
                    "";
                // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
              }
              // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s end
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
      if (
        //検査結果
        1008 <= categoryNo &&
        categoryNo <= 1011
      ) {
        this.titleName = "検査項目名";
        this.popoverInfo.selectInfoOptions = this.getCheckItem();
      } else if (
        //検査結果
        8 <= categoryNo &&
        categoryNo <= 11
      ) {
        this.popoverInfo.selectInfoOptions = this.mstExamItem.map((rec) => {
          return {
            itemNo: rec.examItemCd,
            itemName: rec.examItemName,
            //mod 内部5988 【結合仕様書作成】患者経過総合ビューア グラフ 張 start
            // itemColor: null,
            // itemPoint: null,
            itemColor: "#000000",
            itemPoint: "triangle",
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            isDisp: rec.isDisp,
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
          };
        });
      } else if (this.isVitalMonitor(categoryNo, subCategoryNo)) {
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
        if (
          (categoryNo >= 2 && categoryNo <= 5) ||
          (categoryNo >= 8 && categoryNo <= 11) ||
          (categoryNo >= 1008 && categoryNo <= 1011) ||
          (categoryNo >= 1002 && categoryNo <= 1005) ||
          (categoryNo >= 1012 && categoryNo <= 1015)
        ) {
          this.titleName = "モニタデータ項目名";
          // itemNoListの取得
          const selectedItemNoList = this.getSelectedItemNoList(false);
          // バイタル・モニタグラフ ①～④
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
                  itemColor: "#000000",
                  itemPoint: "triangle",
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
          /* #9312 ADD START */
          this.popoverInfo.selectInfoOptions.unshift(
            ...deepCopy(selectInfoOptions.vitalInfoPlus)
          );
          /* #9312 ADD END*/
        } else {
          // itemNoListの取得
          const selectedItemNoList = this.getSelectedItemNoList(false);
          // バイタル・モニタグラフ 24h
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
                  itemColor: "#000000",
                  itemPoint: "triangle",
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
        }
      } else if (16 === categoryNo) {
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
        //患者イベントを
        this.popoverInfo.selectInfoOptions = categoryPat.map((m) => {
          return {
            itemNo: m.subCategoryCd,
            itemName: m.subCategoryName,
            isPatEventSub: m.isPatEventSub,
          };
        });
      } else if (1017 === categoryNo) {
        // 愁訴処置
        // mod #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy start
        // this.popoverInfo.selectInfoOptions = this.mstComplaints.map((m) => {
        //   return {
        //     itemNo: m.complaint_cd,
        //     itemName: m.complaint_name,
        //   };
        // });
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
        var selectIds = [];
        temp.subCategoryItem.forEach((item) => {
          selectIds.push(item.itemNo);
        });
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        if (this.complaintTreatment === "1") {
          this.popoverInfo.selectInfoOptions = this.mstComplaints
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (
                m.is_disp === "1" ||
                selectIds.includes("Complaints*" + m.complaint_cd)
              ) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: "Complaints*" + m.complaint_cd,
                  itemName: m.complaint_name,
                  complaintClassify: "1",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.is_disp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                //});
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
          // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        } else if (this.complaintTreatment === "2") {
          this.popoverInfo.selectInfoOptions = this.mstCompTreatment
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (
                m.is_disp === "1" ||
                selectIds.includes("CompTreatment*" + m.comp_treatment_cd)
              ) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: "CompTreatment*" + m.comp_treatment_cd,
                  itemName: m.treatment,
                  complaintClassify: "2",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.is_disp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                //});
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
          // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        }
        // mod #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy end
      } else if (1018 === categoryNo) {
        // 医療材料集計
        this.categoryTitleName = "医療材料分類";
        this.categoryDataName = "医療材料名";
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
        var selectedIds = [];
        temp.subCategoryItem.forEach((item) => {
          selectedIds.push(item.itemNo);
        });
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        this.popoverInfo.selectInfoOptions = this.mstEquipment
          .map((m) => {
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            if (m.isDisp === "1" || selectedIds.includes(m.equipmentCd)) {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              return {
                itemNo: m.equipmentCd,
                itemName: m.equipmentName,
                plans: "予定",
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                isDisp: m.isDisp,
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              };
              // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              // })
            }
          })
          .filter(
            (item) =>
              item !== undefined &&
              item !== null &&
              Object.keys(item).length > 0
          );
        // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      } else if (1019 === categoryNo) {
        // ダイアライザ集計
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
        var selectedIds = [];
        temp.subCategoryItem.forEach((item) => {
          selectedIds.push(item.itemNo);
        });
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        this.categoryTitleName = "";
        this.categoryDataName = "ダイアライザ名";
        this.popoverInfo.selectInfoOptions = this.mstDialyzer
          .map((m) => {
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            if (m.isDisp === "1" || selectedIds.includes(m.dialyzerCd)) {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              return {
                itemNo: m.dialyzerCd,
                itemName: m.modelNumber,
                plans: "予定",
                // del redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy start
                // unit: "指示単位"
                // del redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy end
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                isDisp: m.isDisp,
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              };
              // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              // })
            }
          })
          .filter(
            (item) =>
              item !== undefined &&
              item !== null &&
              Object.keys(item).length > 0
          );
        // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      } else if (1022 === categoryNo) {
        // 薬剤集計
        this.categoryTitleName = "薬剤分類";
        this.categoryDataName = "薬剤名";
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
        var selectedIds = [];
        temp.subCategoryItem.forEach((item) => {
          selectedIds.push(item.itemNo);
        });
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        this.popoverInfo.selectInfoOptions = this.mstMedicine
          .map((m) => {
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            if (m.isDisp === "1" || selectedIds.includes(m.medicineCd)) {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              return {
                itemNo: m.medicineCd,
                itemName: m.medicineName,
                plans: "予定",
                unit: "指示単位",
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                isDisp: m.isDisp,
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              };
              // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              // })
            }
          })
          .filter(
            (item) =>
              item !== undefined &&
              item !== null &&
              Object.keys(item).length > 0
          );
        // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      } else if (categoryNo === 1 && subCategoryNo === 56) {
        if (this.complaintTreatment === "1") {
          this.popoverInfo.selectInfoOptions = this.mstComplaints.map((m) => {
            return {
              itemNo: "Complaints*" + m.complaint_cd,
              itemName: m.complaint_name,
              complaintClassify: "1",
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              isDisp: m.is_disp,
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
            };
          });
        } else if (this.complaintTreatment === "2") {
          this.popoverInfo.selectInfoOptions = this.mstCompTreatment.map(
            (m) => {
              return {
                itemNo: "CompTreatment*" + m.comp_treatment_cd,
                itemName: m.treatment,
                complaintClassify: "2",
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                isDisp: m.is_disp,
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              };
            }
          );
        } else if (this.complaintTreatment === "3") {
          this.popoverInfo.selectInfoOptions =
            selectInfoOptions.electroCardiogram;
        } else if (this.complaintTreatment === "4") {
          this.popoverInfo.selectInfoOptions = selectInfoOptions.acidInhalation;
        }
      } else if (
        categoryNo === 1 &&
        subCategoryNo >= 65 &&
        subCategoryNo <= 72
      ) {
        // itemNoListの取得
        const selectedItemNoList = this.getSelectedItemNoList(false);
        // バイタル・モニタグラフ 入室～退室
        this.popoverInfo.selectInfoOptions = this.selectVitalMonitorItemList
          .map((m) => {
            if (m.isDisp === "1" || selectedItemNoList.includes(m.moniDataNo)) {
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
      } else {
        if (categoryNo >= 1024 && categoryNo <= 1027) {
          if (this.isFirstCompound) {
            this.targetElement = "weight";
          }

          if (
            this.targetElement === "inspection" &&
            this.inspectionStatus === "投薬支援"
          ) {
            this.popoverInfo.selectInfoOptions =
              selectInfoOptions["inspectionResultSupport"];
          } else if (
            this.targetElement === "inspection" &&
            this.inspectionStatus === "結果"
          ) {
            this.changePopoverDownListData("inspection");
          } else if (
            this.targetElement === "administered_drug" &&
            this.drugStatus === "投薬支援"
          ) {
            let temp = deepCopy(selectInfoOptions.drugDosingSupport);
            //#10176:ポップアップのフリーワード検索の動作不正 Start
            let ResKbn = this.targetdrugchkreskbn(this.dosOrPre);
            if (ResKbn === "0") {
              //#10176:ポップアップのフリーワード検索の動作不正 End
              temp[0].itemNo = temp[0].itemNo.concat("1");
              temp[0].graph = "投薬";
            } else {
              temp[0].itemNo = temp[0].itemNo.concat("2");
              temp[0].graph = "処方";
            }
            this.popoverInfo.selectInfoOptions = temp;
          } else if (
            this.targetElement === "administered_drug" &&
            (this.drugStatus === "指示" || this.drugStatus === "実績")
          ) {
            //#10176:ポップアップのフリーワード検索の動作不正 Start
            let distinguish = this.targetdrugchkreskbn(this.dosOrPre);
            this.drugDistinguish = "0";
            //#10176:ポップアップのフリーワード検索の動作不正 End
            this.medicineShowData(distinguish);
          } else {
            this.targetElement = "weight";
            this.inspectionStatus = "結果";
            this.popoverInfo.selectInfoOptions =
              selectInfoOptions[this.getCategoryClass(categoryNo)];
          }
        } else {
          this.popoverInfo.selectInfoOptions =
            selectInfoOptions[this.getCategoryClass(categoryNo)];
        }
      }
      // 現在選択中のバイタル情報を格納
      this.popoverInfo.selectedList = deepCopy(this.selectedList);

      // バイタルモニタの場合には選択済リストを再設定する.
      // ※itemNoを変更する為
      if (this.isVitalMonitor(categoryNo, subCategoryNo)) {
        // this.selectedList を直接操作してしまうとキャンセルボタンをクリックされた時に
        // 期待しない状態(itemCdに*で結合された文字列が設定)となる為.
        const tempSelectedList = deepCopy(this.selectedList);
        if (
          (categoryNo >= 2 && categoryNo <= 5) ||
          (categoryNo >= 8 && categoryNo <= 11) ||
          (categoryNo >= 1008 && categoryNo <= 1011) ||
          (categoryNo >= 1002 && categoryNo <= 1005) ||
          (categoryNo >= 1012 && categoryNo <= 1015) ||
          (categoryNo === 1 && subCategoryNo >= 65 && subCategoryNo <= 72) ||
          (categoryNo === 1 && subCategoryNo >= 58 && subCategoryNo <= 61) //グラフ色とグラフ型-保存の条件 add 鞠
        ) {
          this.popoverInfo.selectedList = tempSelectedList.map((m) => {
            return {
              // テーブル種別、バイタルモニタ区分、項目コードを"*"で結合した文字列をitemNoとする.
              itemNo: [m.tableType, m.vitalMonitorClass, m.itemNo].join("*"),
              itemName: m.itemName,
              itemColor: m.itemColor,
              itemPoint: m.itemPoint,
            };
          });
        } else {
          this.popoverInfo.selectedList = tempSelectedList.map((m) => {
            return {
              // テーブル種別、バイタルモニタ区分、項目コードを"*"で結合した文字列をitemNoとする.
              itemNo: [m.tableType, m.vitalMonitorClass, m.itemNo].join("*"),
              itemName: m.itemName,
              itemColor: m.itemColor,
              itemPoint: m.itemPoint,
            };
          });
        }
      } else {
        if (categoryNo === 1 && subCategoryNo === 56) {
          let tempSelectedList = deepCopy(this.selectedList);
          this.popoverInfo.selectedList = tempSelectedList.map((m) => {
            if (m.complaintClassify === "1") {
              return {
                itemNo:
                  m.itemNo.toString().indexOf("*") > 0
                    ? m.itemNo
                    : "Complaints*" + m.itemNo,
                itemName: m.itemName,
                complaintClassify: m.complaintClassify,
              };
            } else if (m.complaintClassify === "2") {
              return {
                itemNo:
                  m.itemNo.toString().indexOf("*") > 0
                    ? m.itemNo
                    : "CompTreatment*" + m.itemNo,
                itemName: m.itemName,
                complaintClassify: m.complaintClassify,
              };
            }
            return {
              itemNo: m.itemNo,
              itemName: m.itemName,
              complaintClassify: m.complaintClassify,
            };
          });
          console.log(
            "this.popoverInfo.selectedList",
            this.popoverInfo.selectedList
          );
        } else if (categoryNo === 15 || categoryNo === 16) {
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
      if (
        subCategoryNo === 65 ||
        subCategoryNo === 67 ||
        subCategoryNo === 69 ||
        subCategoryNo === 71
      ) {
        exam = subCategoryInfo.vitalChild[0];
      } else if (
        subCategoryNo === 66 ||
        subCategoryNo === 68 ||
        subCategoryNo === 70 ||
        subCategoryNo === 72
      ) {
        exam = subCategoryInfo.vitalChild[1];
      } else {
        exam = subCategoryInfo;
      }
      if (exam.drugStatus === undefined) {
        exam.drugStatus = "指示";
      } else {
        this.drugStatus = exam.drugStatus;
      }
      if (exam.treatmentStatus === undefined) {
        exam.treatmentStatus = "指示";
      } else {
        this.treatmentStatus = exam.treatmentStatus;
      }
      if (exam.inspectionStatus === undefined) {
        exam.inspectionStatus = "結果";
      } else {
        this.inspectionStatus = exam.inspectionStatus;
      }
      // mod 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s start
      /*if (exam.graphMax === undefined) {
        exam.graphMax = 0
      } else {
        this.graphMax = exam.graphMax;
      }
      if (exam.graphMin === undefined) {
        exam.graphMin = 0
      } else {
        this.graphMin = exam.graphMin;
      }*/
      if (
        //検査結果
        (8 <= categoryNo && categoryNo <= 11) ||
        (1008 <= categoryNo && categoryNo <= 1011)
      ) {
        this.graphMin = this.selectedSetting.min.initValue;
        this.graphMax = this.selectedSetting.max.initValue;
      } else {
        // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
        if (exam.graphMax === undefined) {
          exam.graphMax = null;
        } else {
          this.graphMax = exam.graphMax;
        }
        if (exam.graphMin === undefined) {
          exam.graphMin = null;
        } else {
          this.graphMin = exam.graphMin;
        }
        // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
      }
      // mod 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s end

      this.isFirstCompound = true;

      if (categoryNo >= 1008 && categoryNo <= 1011) {
        let flag = 1;
        if (this.inspectionStatus === "結果") {
          flag = 1;
        } else if (this.inspectionStatus === "投薬支援") {
          flag = 0;
        }
        this.popoverInfo.selectInfoOptions =
          this.popoverInfo.selectInfoOptions.filter(
            (item) => item.isMasterData === flag
          );
      }

      // mod #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy start
      // this.isComplaintShow = categoryNo === 1 && subCategoryNo === 56;
      this.isComplaintShow =
        categoryNo === 1017 || (categoryNo === 1 && subCategoryNo === 56);
      // mod #9321 患者経過総合ビューアの長期間表示で、治療記録集計と愁訴処置がデータ表示しない。 zy end
    },

    /**
     * カテゴリコードに該当するカテゴリ区分を取得する.
     * 1 : "treatCondInfo"
     * 6 ~ 7、1006 ~ 1007 : "weightInfo"
     * 上記以外 : undefined
     *
     * @param {Integer} カテゴリコード
     * @returns {String} カテゴリ区分
     */
    getCategoryClass(categoryCd) {
      let categoryClass;
      if (categoryCd === 1) {
        categoryClass = "treatCondInfo";
      } else if (
        (6 <= categoryCd && categoryCd <= 7) ||
        18 === categoryCd ||
        categoryCd === 19 ||
        (1020 <= categoryCd && categoryCd <= 1022) ||
        (1006 <= categoryCd && categoryCd <= 1007) ||
        (1024 <= categoryCd && categoryCd <= 1027)
      ) {
        this.titleName = "体重名";
        categoryClass = "weightInfo";
      }
      return categoryClass;
    },

    /**
     * 選択情報を格納
     * @description
     *  小項目選択ポップオーバーで選択した情報を
     *  ポップオーバー内で保持する
     * @param cd 小項目番号
     */
    // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 start
    // storageInfo(info) {
    storageInfo(info, event) {
      // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 end
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
          complaintClassify: info.complaintClassify,
          isPatEventSub: info.isPatEventSub,
          // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
          ...(8 <= this.popoverInfo.targetInfo.categoryNo &&
          this.popoverInfo.targetInfo.categoryNo <= 11 &&
          this.inspectionStatus === "結果"
            ? { itemExamClass: 3 }
            : {}),
          // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end
        });
      } else {
        // すでに格納されている選択情報ある場合削除
        selectedList.splice(index, 1);
      }
      //選択可能な上限を
      this.judgeMaxNum(selectedList);

      // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s start
      // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 start
      // if (
      //   //検査結果
      //   (8 <= this.popoverInfo.targetInfo.categoryNo && this.popoverInfo.targetInfo.categoryNo <= 11) ||
      //   (1008 <= this.popoverInfo.targetInfo.categoryNo && this.popoverInfo.targetInfo.categoryNo <= 1011)
      // ) {
      if (
        //検査結果
        (8 <= this.popoverInfo.targetInfo.categoryNo &&
          this.popoverInfo.targetInfo.categoryNo <= 11) ||
        (1008 <= this.popoverInfo.targetInfo.categoryNo &&
          this.popoverInfo.targetInfo.categoryNo <= 1011) ||
        (this.popoverInfo.targetInfo.categoryNo >= 1024 &&
          this.popoverInfo.targetInfo.categoryNo <= 1027)
      ) {
        // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 end
        const limit = this.getMstExamItemLimit(selectedList);
        this.selectedSetting.min.initValue = limit[0];
        this.selectedSetting.min.editValue = limit[0];
        this.selectedSetting.max.initValue = limit[1];
        this.selectedSetting.max.editValue = limit[1];
        this.graphMin = this.selectedSetting.min.initValue;
        this.graphMax = this.selectedSetting.max.initValue;
        // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 start
        // this.graphValueChange(1);
        // this.graphValueChange(2);
        this.graphValueChange(event, 1, 0);
        this.graphValueChange(event, 2, 1);
        // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 end
      }
      // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s end
    },

    /**
     * 選択情報を格納
     * @description
     *  小項目選択ポップオーバーで選択した情報を
     *  ポップオーバー内で保持する
     * @param cd 小項目番号
     */
    // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 start
    // storageInfo2(info) {
    storageInfo2(info, event) {
      // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 end
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
        if (cd.toString().indexOf("*") > 0) {
          const splitItemCd = info.itemNo.split("*");
          selectedList.push({
            isDisp: true,
            itemName,
            tableType: Number(splitItemCd[0]),
            vitalMonitorClass: splitItemCd[1],
            moniNo: isNaN(splitItemCd[2])
              ? splitItemCd[2]
              : Number(splitItemCd[2]),
            itemNo: cd,
            itemColor: info.itemColor,
            itemPoint: info.itemPoint,
            graph: info.graph,
            itemDate: info.itemDate,
            plans: info.plans,
            unit: info.unit,
            itemDivision: this.getTargetElementNumber(),
          });
        } else {
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
            itemDivision: this.getTargetElementNumber(),
            // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 start
            ...(((this.popoverInfo.targetInfo.categoryNo >= 1008 &&
              this.popoverInfo.targetInfo.categoryNo <= 1011) ||
              (this.popoverInfo.targetInfo.categoryNo >= 1024 &&
                this.popoverInfo.targetInfo.categoryNo <= 1027 &&
                this.getTargetElementNumber() == 2)) &&
            this.inspectionStatus === "結果"
              ? { itemExamClass: 3 }
              : {}),
            // mod #10174【因島】患者経過総合ビューアの長期間表示にて検査項目に対して区分の選択肢がない 関 end
          });
        }
      } else {
        // すでに格納されている選択情報ある場合削除
        selectedList.splice(index, 1);
      }
      if (
        this.popoverInfo.targetInfo.categoryNo < 1024 ||
        this.popoverInfo.targetInfo.categoryNo > 1027
      ) {
        for (let item of selectedList) {
          delete item.itemDivision;
        }
      }
      //選択可能な上限を
      this.judgeMaxNum(selectedList);

      // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s start
      // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 start
      // if (
      //   //検査結果
      //   (8 <= this.popoverInfo.targetInfo.categoryNo && this.popoverInfo.targetInfo.categoryNo <= 11) ||
      //   (1008 <= this.popoverInfo.targetInfo.categoryNo && this.popoverInfo.targetInfo.categoryNo <= 1011)
      // ) {
      if (
        //検査結果
        (8 <= this.popoverInfo.targetInfo.categoryNo &&
          this.popoverInfo.targetInfo.categoryNo <= 11) ||
        (1008 <= this.popoverInfo.targetInfo.categoryNo &&
          this.popoverInfo.targetInfo.categoryNo <= 1011) ||
        (this.popoverInfo.targetInfo.categoryNo >= 1024 &&
          this.popoverInfo.targetInfo.categoryNo <= 1027)
      ) {
        // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 end
        const limit = this.getMstExamItemLimit(selectedList);
        this.selectedSetting.min.initValue = limit[0];
        this.selectedSetting.min.editValue = limit[0];
        this.selectedSetting.max.initValue = limit[1];
        this.selectedSetting.max.editValue = limit[1];
        this.graphMin = this.selectedSetting.min.initValue;
        this.graphMax = this.selectedSetting.max.initValue;
        // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 start
        // this.graphValueChange(1);
        // this.graphValueChange(2);
        this.graphValueChange(event, 1, 0);
        this.graphValueChange(event, 2, 1);
        // mod 9570 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフレンジ設定が不正 関 end
      }
      // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s end
      // popupでは行を選択してデータを追加します。行を選択して追加しません。
      // if ((1008 <= this.popoverInfo.targetInfo.categoryNo && this.popoverInfo.targetInfo.categoryNo <= 1011) ||
      //   (1024 <= this.popoverInfo.targetInfo.categoryNo && this.popoverInfo.targetInfo.categoryNo <= 1027) ) {
      //   this.saveChangesSec();
      // }
    },

    /**
     * 最大選択数の判断
     * @description 最大選択数の判断
     * @param maxSelectedNum 選択可能な上限
     */
    judgeMaxNum(selectedList) {
      let categoryNo = this.popoverInfo.targetInfo.categoryNo;
      let subCategoryNo = this.popoverInfo.targetInfo.subCategoryNo;
      if (
        selectedList.length >= 5 &&
        ((categoryNo >= 2 && categoryNo <= 7) ||
          categoryNo === 18 ||
          categoryNo === 19 ||
          categoryNo === 1020 ||
          categoryNo === 1021 ||
          (categoryNo >= 1002 && categoryNo <= 1007) ||
          (categoryNo === 1 && subCategoryNo === 56) ||
          (categoryNo === 1 && subCategoryNo >= 58 && subCategoryNo <= 61) ||
          (categoryNo === 1 && subCategoryNo >= 65 && subCategoryNo <= 72) ||
          (categoryNo >= 1024 && categoryNo <= 1027))
      ) {
        selectedList.splice(5, 1);
      } else if (
        selectedList.length > 4 &&
        (15 === categoryNo || categoryNo === 16)
      ) {
        // selectedList.splice(4, 1);
      } else if (
        categoryNo === 1018 ||
        categoryNo === 1019 ||
        categoryNo === 1022
      ) {
        selectedList.splice(10, 1);
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
     * ※サブカテゴリでの判定を行う場合、categoryNo は必ず[1]である事
     *
     * @param {Integer} categoryNo カテゴリ番号
     * @param {Integer} subCategoryNo サブカテゴリ番号
     * @returns {Boolean} true : バイタルモニタグラフ、false : それ以外
     */
    isVitalMonitor(categoryNo, subCategoryNo) {
      return (
        this.vitalMonitorItemTargetCategoryNoList.includes(categoryNo) ||
        (CATEGORY_NO.TREATMENT_CONTENT === categoryNo &&
          this.vitalMonitorItemTargetSubCategoryNoList.includes(subCategoryNo))
      );
    },

    /**
     * ポップオーバーで選択した情報を格納する
     */
    saveChanges() {
      //del 9564 ljx start
      // if (
      //   (this.popoverInfo.targetInfo.categoryNo >= 2 && this.popoverInfo.targetInfo.categoryNo <= 5) ||
      //   (this.popoverInfo.targetInfo.categoryNo >= 8 && this.popoverInfo.targetInfo.categoryNo <= 11) ||
      //   (this.popoverInfo.targetInfo.categoryNo >= 1008 && this.popoverInfo.targetInfo.categoryNo <= 1011) ||
      //   (this.popoverInfo.targetInfo.categoryNo >= 1002 && this.popoverInfo.targetInfo.categoryNo <= 1005) ||
      //   (this.popoverInfo.targetInfo.categoryNo >= 1012 && this.popoverInfo.targetInfo.categoryNo <= 1015)
      // ) {
      //   this.popoverInfo.selectedList.forEach((ele) => {
      //     this.popoverInfo.selectInfoOptions.forEach((ele2) => {
      //       if (ele.itemNo == ele2.itemNo) {
      //         ele.itemName = ele2.itemName;
      //         ele.itemColor = ele2.itemColor;
      //         ele.itemPoint = ele2.itemPoint;
      //       }
      //     });
      //   });
      // }
      //del 9564 ljx end
      // 選択したバイタル情報を格納する
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

      if (
        this.popoverInfo.targetInfo.categoryNo === 1 &&
        this.popoverInfo.targetInfo.subCategoryNo === 56
      ) {
        for (let i = 0; i < this.selectedList.length; i++) {
          if (
            this.selectedList[i].complaintClassify === "1" ||
            this.selectedList[i].complaintClassify === "2"
          ) {
            const temp = this.selectedList[i].itemNo.split("*");
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            var itNo = temp[temp.length - 1];
            var dispFlay = "";
            if (this.mstTreatmentListDisp.includes(itNo)) {
              dispFlay = true;
            }
            if (this.mstComplaintListDisp.includes(itNo)) {
              dispFlay = true;
            }
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
            this.selectedList[i].itemNo = temp[temp.length - 1];
            this.selectedList[i].isDisp = true;
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            this.selectedList[i].isDispflag = dispFlay;
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
          }
        }
      }
      if (
        this.popoverInfo.targetInfo.categoryNo === 15 ||
        this.popoverInfo.targetInfo.categoryNo === 16
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
      // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
      this.graphMax = null;
      this.graphMin = null;
      // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end

      // ポップオーバーを閉じる
      this.popoverInfo.popoverVisible = false;
    },

    /**
     * ポップオーバーで選択した情報を格納する
     */
    saveChangesSec() {
      //del 9564 患者経過総合ビューアレイアウトマスタ詳細にてグラフレンジを変更するとグラフ色とグラフ形状が勝手に変わる 吉 start
      // if (
      //   (this.popoverInfo.targetInfo.categoryNo >= 2 && this.popoverInfo.targetInfo.categoryNo <= 5) ||
      //   (this.popoverInfo.targetInfo.categoryNo >= 8 && this.popoverInfo.targetInfo.categoryNo <= 11) ||
      //   (this.popoverInfo.targetInfo.categoryNo >= 1008 && this.popoverInfo.targetInfo.categoryNo <= 1011) ||
      //   (this.popoverInfo.targetInfo.categoryNo >= 1002 && this.popoverInfo.targetInfo.categoryNo <= 1005) ||
      //   (this.popoverInfo.targetInfo.categoryNo >= 1012 && this.popoverInfo.targetInfo.categoryNo <= 1015)
      // ) {
      //   this.popoverInfo.selectedList.forEach((ele) => {
      //     this.popoverInfo.selectInfoOptions.forEach((ele2) => {
      //       if (ele.itemNo == ele2.itemNo) {
      //         ele.itemName = ele2.itemName;
      //         ele.itemColor = ele2.itemColor;
      //         ele.itemPoint = ele2.itemPoint;
      //       }
      //     });
      //   });
      // }
      //del 9564 患者経過総合ビューアレイアウトマスタ詳細にてグラフレンジを変更するとグラフ色とグラフ形状が勝手に変わる 吉 end
      // 選択したバイタル情報を格納する
      // del キャンセルボタンを押すと、選択した血圧低下などの小項目が愁訴情報の下に表示されます。林峻峰 start
      // this.selectedList = deepCopy(this.popoverInfo.selectedList);
      // del キャンセルボタンを押すと、選択した血圧低下などの小項目が愁訴情報の下に表示されます。林峻峰 end
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
            const splitItemCd = item.itemNo.split("*");
            item.tableType = Number(splitItemCd[0]);
            item.vitalMonitorClass = splitItemCd[1];
            item.itemNo = isNaN(splitItemCd[2])
              ? splitItemCd[2]
              : Number(splitItemCd[2]);
            item.isDisp = true;
          } else {
            item.tableType = null;
            item.vitalMonitorClass = null;
            item.isDisp = true;
          }

          selectedVitalMonitorItemList.push(item);
        });
        this.selectedList = selectedVitalMonitorItemList;
      }
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
      if (categoryNo === 1 && subCategoryNo === 56) {
        for (let i = 0; i < subCategoryItem.length; i++) {
          if (
            subCategoryItem[i].complaintClassify === "3" ||
            subCategoryItem[i].complaintClassify === "4"
          ) {
            subCategoryItem[i].isDisp = true;
          }
        }
      }
      // ポップオーバーで選択した項目情報を格納
      if (
        subCategoryNo === 65 ||
        subCategoryNo === 67 ||
        subCategoryNo === 69 ||
        subCategoryNo === 71
      ) {
        subCategoryInfo.vitalChild[0].subCategoryItem = subCategoryItem;
        subCategoryInfo.vitalChild[0].isDisp = 0 !== subCategoryItem.length;
      } else if (
        subCategoryNo === 66 ||
        subCategoryNo === 68 ||
        subCategoryNo === 70 ||
        subCategoryNo === 72
      ) {
        subCategoryInfo.vitalChild[1].subCategoryItem = subCategoryItem;
        subCategoryInfo.vitalChild[1].isDisp = 0 !== subCategoryItem.length;
      } else {
        subCategoryInfo.subCategoryItem = subCategoryItem;
        subCategoryInfo.isDisp = 0 !== subCategoryItem.length;
      }
      // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s start
      // if (
      //   //検査結果
      //   (8 <= categoryNo && categoryNo <= 11) ||
      //   (1008 <= categoryNo && categoryNo <= 1011)
      // ) {
      //   subCategoryInfo.min = this.selectedSetting.min.editValue;
      //   subCategoryInfo.max = this.selectedSetting.max.editValue;
      // }
      // add 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s end
    },
    /**
     * @description 薬剤選択ボタン押下時のポップオーバー表示位置を取得
     * @param ポップオーバー表示位置
     */
    popoverTargetElement() {
      //ポップオーバーの表示位置を取得(薬剤選択ボタン押下時はそのボタンの位置、それ以外はnull)
      const targetInfo = this.popMedicineInfo.targetInfo;
      const refName = targetInfo.categoryNo + "_" + targetInfo.subCategoryNo;
      const position =
        targetInfo.categoryNo === null ? null : this.$refs[refName][0];
      return position;
    },
    setMediPopover(categoryNo, subCategoryNo) {
      let mediData = [];

      for (const medi of this.dispItemInfo) {
        if (medi.categoryNo == categoryNo) {
          for (const item of medi.categoryItem) {
            if (item.subCategoryNo == subCategoryNo) {
              if (item.subCategoryItem.length > 0) {
                mediData = item.subCategoryItem;
              }
            }
          }
        }
      }

      let mediClassList = [];

      if (this.mstMediClass !== undefined) {
        // 薬剤分類
        mediClassList = this.mstMediClass.map((item) => {
          return {
            text: item.className,
            value: item.classCd,
          };
        });
      }

      mediClassList.unshift({ text: "すべて", value: 0 });

      this.popMedicineInfo.popoverSelector = [
        {
          popoverSelectorLabel: "グラフ",
          popoverSelectorDataset: [
            { text: "投与薬剤", value: "投与" },
            { text: "処方薬剤", value: "処方" },
          ],
        },
      ];

      this.popMedicineInfo.popoverFilter = [
        {
          popoverFilterLabel: "薬剤区分",
          popoverFilterDataset: [
            { text: medi_cate.group.TEXT, value: medi_cate.group.VALUE },
            { text: medi_cate.normal.TEXT, value: medi_cate.normal.VALUE },
            //#10176:ポップアップのフリーワード検索の動作不正 Start
            {
              text: medi_cate.adjustment.TEXT,
              value: medi_cate.adjustment.VALUE,
            },
            //#10176:ポップアップのフリーワード検索の動作不正 End
          ],
        },
        {
          popoverFilterLabel: "薬剤分類",
          popoverFilterDataset: mediClassList,
        },
      ];
      // 薬剤名一覧を作成
      const mediList = this.mstMedicine.map((item) => {
        let flag = this.findDiff(item.medicineCd, mediData);
        return {
          value: item.medicineCd,
          fnValue: {
            薬剤区分: medi_cate.normal.VALUE,
            薬剤分類: item.classCd,
          },
          text: item.medicineName,
          category: medi_cate.normal.VALUE,
          setInfo: null,
          isDisp: flag,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
          isDispflag: item.isDisp,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
          // itemColor: null,
          // itemDate: null,
          itemColor: "#000000",
          itemPoint: "triangle",
        };
      });
      // 薬効換算マスタ
      const mediGroupList = this.mstMedicineGroup.map((item) => {
        let flag = this.findDiff(
          "MEDICINE_GROUP".concat(item.medicineGroupCd),
          mediData
        );
        return {
          value: "MEDICINE_GROUP".concat(item.medicineGroupCd),
          fnValue: {
            薬剤区分: medi_cate.group.VALUE,
            薬剤分類: "",
          },
          text: item.medicineGroupName,
          category: medi_cate.group.VALUE,
          setInfo: item.regMedicineInfo,
          isDisp: flag,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
          isDispflag: item.isDisp,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
          // itemColor: null,
          // itemDate: null,
          itemColor: "#000000",
          itemPoint: "triangle",
        };
      });
      // 調製薬剤マスタ
      const mediMixList = this.mstMedicineMix.map((item) => {
        //#10176:ポップアップのフリーワード検索の動作不正 Start
        let flag = this.findDiff(
          MEDICINE_MIX.concat(item.medicineMixCd),
          mediData
        );
        //#10176:ポップアップのフリーワード検索の動作不正 End
        return {
          //#10176:ポップアップのフリーワード検索の動作不正 Start
          value: MEDICINE_MIX.concat(item.medicineMixCd),
          //#10176:ポップアップのフリーワード検索の動作不正 End
          fnValue: {
            薬剤区分: medi_cate.normal.VALUE,
            薬剤分類: item.classCd,
          },
          text: item.medicineMixName,
          category: medi_cate.normal.VALUE,
          setInfo: null,
          isDisp: flag,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
          isDispflag: item.isDisp,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
          // itemColor: null,
          // itemDate: null,
          itemColor: "#000000",
          itemPoint: "triangle",
        };
      });
      // 薬効換算マスタ
      const mediGroupListS = this.mstMedicineGroup.map((item) => {
        let flag = this.findDiff(
          "MEDICINE_GROUPS".concat(item.medicineGroupCd),
          mediData
        );
        return {
          value: "MEDICINE_GROUPS".concat(item.medicineGroupCd),
          fnValue: {
            薬剤区分: medi_cate.groupS.VALUE,
            薬剤分類: "",
          },
          text: item.medicineGroupName,
          category: medi_cate.groupS.VALUE,
          setInfo: item.regMedicineInfo,
          isDisp: flag,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
          isDispflag: item.isDisp,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
          // itemColor: null,
          // itemDate: null,
          itemColor: "#000000",
          itemPoint: "triangle",
        };
      });
      // 薬剤マスタ
      const mediListS = this.mstMedicine.map((item) => {
        let flag = this.findDiff("MEDICINE".concat(item.medicineCd), mediData);
        return {
          value: "MEDICINE".concat(item.medicineCd),
          fnValue: {
            薬剤区分: medi_cate.normalS.VALUE,
            薬剤分類: item.classCd,
          },
          text: item.medicineName,
          category: medi_cate.normalS.VALUE,
          setInfo: null,
          isDisp: flag,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
          isDispflag: item.isDisp,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
          // itemColor: null,
          // itemDate: null,
          itemColor: "#000000",
          itemPoint: "triangle",
        };
      });

      let plunge = selectInfoOptions.drugDosingSupport.map((item) => {
        let temp = item.itemNo.concat("1");
        let flag = this.findDiff(temp, mediData);
        return {
          value: temp,
          fnValue: {
            薬剤区分: "0",
            薬剤分類: null,
          },
          text: item.itemName,
          category: "0",
          setInfo: null,
          isDisp: flag,
          // itemColor: null,
          // itemDate: null,
          itemColor: "#000000",
          itemPoint: "triangle",
        };
      });

      let fufang = selectInfoOptions.drugDosingSupport.map((item) => {
        let temp = item.itemNo.concat("2");
        let flag = this.findDiff(temp, mediData);
        return {
          value: temp,
          fnValue: {
            薬剤区分: "4",
            薬剤分類: null,
          },
          text: item.itemName,
          category: "4",
          setInfo: null,
          isDisp: flag,
          // itemColor: null,
          // itemDate: null,
          itemColor: "#000000",
          itemPoint: "triangle",
        };
      });

      // 一般名処方
      const sysGenericMedicine = this.sysGenericMedicine.map((item) => {
        let flag = this.findDiff("MEDICINE" + item.genericCd, mediData);
        return {
          value: "MEDICINE" + item.genericCd,
          fnValue: {
            薬剤区分: medi_cate.prescription.VALUE,
            薬剤分類: item.classCd,
          },
          text: item.genericName,
          category: medi_cate.prescription.VALUE,
          setInfo: null,
          isDisp: flag,
          //#10176:ポップアップのフリーワード検索の動作不正 Start
          //修正漏れ対応(#9574)
          isDispflag: item.isDisp,
          //#10176:ポップアップのフリーワード検索の動作不正 End
          // itemColor: null,
          // itemDate: null,
          itemColor: "#000000",
          // itemPoint: "triangle"
        };
      });

      let totalList = mediList.concat(mediGroupList);
      totalList = totalList.concat(mediMixList);
      totalList = totalList.concat(mediListS);
      totalList = totalList.concat(sysGenericMedicine);
      totalList = totalList.concat(mediGroupListS);
      totalList = totalList.concat(plunge);
      totalList = totalList.concat(fufang);

      let temp = this.dispItemInfo
        .find((eleCategoryInfo) => {
          return categoryNo === eleCategoryInfo.categoryNo;
        })
        .categoryItem.find((eleSubCategoryInfo) => {
          return subCategoryNo === eleSubCategoryInfo.subCategoryNo;
        }).subCategoryItem;

      for (let i = 0; i < temp.length; i++) {
        for (let j = 0; j < totalList.length; j++) {
          if (temp[i].itemNo === totalList[j].value) {
            totalList[j].itemColor = temp[i].itemColor;
            totalList[j].itemDate = temp[i].itemDate;
          }
        }
      }
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
      totalList.sort((a, b) => b.isDispflag - a.isDispflag);
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      this.popMedicineInfo.popoverContentDataset = totalList;

      this.popMedicineInfo.popoverVisible = true;
    },
    /**
     * @description ポップオーバー内、Okボタン押下時の処理
     * @param ポップオーバー内で選択した薬剤情報
     */
    selectedAllMedi(events) {
      const subCategoryItem = [];
      const targetInfo = this.popMedicineInfo.targetInfo;
      const categoryInfo = this.dispItemInfo.find((eleCategoryInfo) => {
        return targetInfo.categoryNo === eleCategoryInfo.categoryNo;
      });
      const subCategoryInfo = categoryInfo.categoryItem.find(
        (eleSubCategoryInfo) => {
          return targetInfo.subCategoryNo === eleSubCategoryInfo.subCategoryNo;
        }
      );
      for (const event of events) {
        this.selectedMedi(
          event,
          subCategoryItem,
          targetInfo,
          categoryInfo,
          subCategoryInfo
        );
      }
      let temp = events.length > 0 ? events[0].drugStatusS : null;

      // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
      // let minTemp = events.length > 0 ? parseInt(events[0].min) : 0;
      // let maxTemp = events.length > 0 ? parseInt(events[0].max) : 0;
      let minTemp = events.length > 0 ? events[0].min : "";
      let maxTemp = events.length > 0 ? events[0].max : "";
      // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end

      this.dispItemInfo
        .find((eleCategoryInfo) => {
          return targetInfo.categoryNo === eleCategoryInfo.categoryNo;
        })
        .categoryItem.find((eleSubCategoryInfo) => {
          return targetInfo.subCategoryNo === eleSubCategoryInfo.subCategoryNo;
        }).drugStatus = temp;

      this.dispItemInfo
        .find((eleCategoryInfo) => {
          return targetInfo.categoryNo === eleCategoryInfo.categoryNo;
        })
        .categoryItem.find((eleSubCategoryInfo) => {
          return targetInfo.subCategoryNo === eleSubCategoryInfo.subCategoryNo;
        }).graphMin = minTemp;

      this.dispItemInfo
        .find((eleCategoryInfo) => {
          return targetInfo.categoryNo === eleCategoryInfo.categoryNo;
        })
        .categoryItem.find((eleSubCategoryInfo) => {
          return targetInfo.subCategoryNo === eleSubCategoryInfo.subCategoryNo;
        }).graphMax = maxTemp;
    },
    /**
     * @description ポップオーバー内、Okボタン押下時の処理
     * @param ポップオーバー内で選択した薬剤情報
     */
    selectedMedi(
      event,
      subCategoryItem,
      targetInfo,
      categoryInfo,
      subCategoryInfo
    ) {
      const funcAdd = (itemIndex, data) => {
        if (itemIndex < 0) {
          let isDisp = false;
          const itemDisp = subCategoryInfo.subCategoryItem.filter((k) => {
            return k.isDisp === true;
          });
          if (itemDisp.length < MAX_COLUMN) {
            isDisp = true;
          }
          subCategoryInfo.subCategoryItem.push({
            isDisp: isDisp,
            itemName: data.text,
            itemColor: data.itemColor,
            itemDate: data.itemDate != null ? data.itemDate : "day",
            itemNo: data.value,
            graph: event.selector.グラフ,
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            isDispflag: event.isDispflag == 0 ? true : false,
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
          });
        } else {
          subCategoryInfo.subCategoryItem[itemIndex].graph =
            event.selector.グラフ;
        }
      };

      if (
        event.category == medi_cate.normal.VALUE ||
        //#10176:ポップアップのフリーワード検索の動作不正 Start
        event.category == medi_cate.adjustment.VALUE ||
        //#10176:ポップアップのフリーワード検索の動作不正 End
        event.category == medi_cate.group.VALUE ||
        event.category == medi_cate.groupS.VALUE ||
        event.category == medi_cate.normalS.VALUE ||
        event.category == medi_cate.prescription.VALUE
      ) {
        const itemIndex = subCategoryInfo.subCategoryItem.findIndex((rec) => {
          return rec.itemNo === event.value;
        });
        funcAdd(itemIndex, {
          text: event.text,
          value: event.value,
          itemColor: event.itemColor,
          itemDate: event.itemDate != null ? event.itemDate : "none",
        });
      }

      subCategoryInfo.isDisp = 0 === subCategoryItem.length ? false : true;

      this.popMedicineInfo.targetInfo = {
        categoryNo: null,
        subCategoryNo: null,
      };
    },
    /**
     * @description ポップオーバー内、キャンセルボタン押下時の処理
     */
    closeMediPopover() {
      this.popMedicineInfo.popoverVisible = false;
    },
    findDiff(itemNo, mdiDate) {
      for (const item of mdiDate) {
        if (itemNo == item.itemNo) {
          return true;
        }
      }
      return false;
    },
    /**
     * @description ランダムスタイル
     */
    changeColor(category) {
      for (let i = 0; i < this.dispItemInfo.length; i++) {
        if (category.categoryNo === this.dispItemInfo[i].categoryNo) {
          for (let j = 0; j < this.dispItemInfo[i].categoryItem.length; j++) {
            for (
              let k = 0;
              k < this.dispItemInfo[i].categoryItem[j].subCategoryItem.length;
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
              ].itemPoint = REPORT_GRAPH.SELECT_ITEM_PLOT_TYPE[pointNum].value;
            }
          }
        }
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
              if (subCategoryNo >= 65 && subCategoryNo <= 72) {
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
            if (this.dispItemInfo[i].categoryItem[j].subCategoryNo === 58) {
              let temp = this.dispItemInfo[i].categoryItem[j].subCategoryName;
              this.dispItemInfo[i].categoryItem[j].subCategoryName = null;
              this.dispItemInfo[i].categoryItem[j].subCategoryName = temp;
            }
          }
        }
      }
    },

    /**
     * バイタル・モニタグラフ/体重グラフ/検査結果グラフ
     * @param categoryNo
     * @returns {boolean|boolean}
     */
    popUpJudgment(categoryNo) {
      let flag =
        (categoryNo >= 1002 && categoryNo <= 1011) ||
        (categoryNo >= 1020 && categoryNo <= 1021) ||
        (categoryNo >= 1024 && categoryNo <= 1027);
      return flag;
    },

    /**
     * 医療材料集計/薬剤集計/ダイアライザ集計
     * @param categoryNo
     * @returns {boolean}
     */
    popUpJudgment2(categoryNo) {
      let flag =
        categoryNo === 1018 || categoryNo === 1019 || categoryNo === 1022;
      return flag;
    },

    /**
     * さまざまな選択に応じて、エイリアス取得の種類
     * @param categoryNo
     * @returns {[{text: string, value: number}, {text: string, value: number}]}
     */
    getDownListData(categoryNo) {
      let temp = [
        {
          value: 0,
          text: "",
        },
        {
          value: -1,
          text: "未分類",
        },
      ];
      if (categoryNo === 1018) {
        for (let i = 0; i < this.mstEquipmentClass.length; i++) {
          temp.push({
            value: this.mstEquipmentClass[i].classCd,
            text: this.mstEquipmentClass[i].className,
          });
        }
      } else if (categoryNo === 1022) {
        for (let i = 0; i < this.mstMediClass.length; i++) {
          temp.push({
            value: this.mstMediClass[i].classCd,
            text: this.mstMediClass[i].className,
          });
        }
      }
      return temp;
    },

    /**
     * ドロップダウンリストに表示されるデータを変更します
     * @param classCd
     */
    changePopoverDownListData(classCd) {
      if (this.popoverInfo.targetInfo.categoryNo === 1018) {
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
        var temp = this.dispItemInfo
          .find((eleCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.categoryNo ===
              eleCategoryInfo.categoryNo
            );
          })
          .categoryItem.find((eleSubCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.subCategoryNo ===
              eleSubCategoryInfo.subCategoryNo
            );
          });
        var selectedIds = [];
        temp.subCategoryItem.forEach((item) => {
          selectedIds.push(item.itemNo);
        });
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        // 医療材料集計
        if (classCd != 0 && classCd != null) {
          this.popoverInfo.selectInfoOptions = this.mstEquipment
            .filter((data) => data.classCd == classCd)
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (m.isDisp === "1" || selectedIds.includes(m.equipmentCd)) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: m.equipmentCd,
                  itemName: m.equipmentName,
                  plans: "予定",
                  // del redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy start
                  // unit: "指示単位"
                  // del redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy end
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                // })
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
          // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        } else {
          this.popoverInfo.selectInfoOptions = this.mstEquipment
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (m.isDisp === "1" || selectedIds.includes(m.equipmentCd)) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: m.equipmentCd,
                  itemName: m.equipmentName,
                  plans: "予定",
                  // del redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy start
                  // unit: "指示単位"
                  // del redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy end
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                // })
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
          // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        }
      } else if (this.popoverInfo.targetInfo.categoryNo === 1019) {
        // ダイアライザ集計
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
        var temp = this.dispItemInfo
          .find((eleCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.categoryNo ===
              eleCategoryInfo.categoryNo
            );
          })
          .categoryItem.find((eleSubCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.subCategoryNo ===
              eleSubCategoryInfo.subCategoryNo
            );
          });
        var selectedIds = [];
        temp.subCategoryItem.forEach((item) => {
          selectedIds.push(item.itemNo);
        });
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        this.popoverInfo.selectInfoOptions = this.mstDialyzer
          .map((m) => {
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            if (m.isDisp === "1" || selectedIds.includes(m.dialyzerCd)) {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              return {
                itemNo: m.dialyzerCd,
                itemName: m.modelNumber,
                plans: "予定",
                // del redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy start
                // unit: "指示単位"
                // del redmine 5968 長期間表示＞医療材料集計、ダイアライザ集計の設定項目不正 宋qy end
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                isDisp: m.isDisp,
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              };
              // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              // })
            }
          })
          .filter(
            (item) =>
              item !== undefined &&
              item !== null &&
              Object.keys(item).length > 0
          );
        // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      } else if (this.popoverInfo.targetInfo.categoryNo === 1022) {
        // 薬剤集計
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
        var temp = this.dispItemInfo
          .find((eleCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.categoryNo ===
              eleCategoryInfo.categoryNo
            );
          })
          .categoryItem.find((eleSubCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.subCategoryNo ===
              eleSubCategoryInfo.subCategoryNo
            );
          });
        var selectedIds = [];
        temp.subCategoryItem.forEach((item) => {
          selectedIds.push(item.itemNo);
        });
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        if (classCd != 0 && classCd != null) {
          this.popoverInfo.selectInfoOptions = this.mstMedicine
            .filter((data) => data.classCd == classCd)
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (m.isDisp === "1" || selectedIds.includes(m.medicineCd)) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: m.medicineCd,
                  itemName: m.medicineName,
                  plans: "予定",
                  unit: "指示単位",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                // })
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
          // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        } else {
          this.popoverInfo.selectInfoOptions = this.mstMedicine
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (m.isDisp === "1" || selectedIds.includes(m.medicineCd)) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: m.medicineCd,
                  itemName: m.medicineName,
                  plans: "予定",
                  unit: "指示単位",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                // })
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
          // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        }
      } else if (classCd === "weight") {
        this.titleName = "体重名";
        // 体重
        this.popoverInfo.selectInfoOptions =
          selectInfoOptions[this.getCategoryClass(6)];
      } else if (classCd === "inspection") {
        this.titleName = "検査項目名";
        // 検査
        this.popoverInfo.selectInfoOptions = this.mstExamItem.map((rec) => {
          return {
            itemNo: rec.examItemCd,
            itemName: rec.examItemName,
            // itemColor: null,
            // itemPoint: null,
            itemColor: "#000000",
            itemPoint: "triangle",
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            isDisp: rec.isDisp,
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
          };
        });
      } else if (classCd === "treatment_conditions") {
        this.titleName = "治療条件";
        // 治療条件
        this.popoverInfo.selectInfoOptions =
          selectInfoOptions["treatmentConditions"];
      } else if (classCd === "administered_drug") {
        this.titleName = "薬剤名";
        // 投与薬剤
        this.medicineShowData(this.drugDistinguish);
      } else if (classCd === "vital_monitor") {
        this.titleName = "モニタデータ項目名";
        // itemNoListの取得
        const selectedItemNoList = this.getSelectedItemNoList(true);
        // 複合グラフ バイタル・モニタグラフ切替
        this.popoverInfo.selectInfoOptions = this.selectVitalMonitorItemList
          .map((m) => {
            if (m.isDisp === "1" || selectedItemNoList.includes(m.moniDataNo)) {
              return {
                // テーブル種別、バイタルモニタ区分、項目コードを"*"で結合した文字列をitemNoとする.
                itemNo: [m.tableType, m.vitalMonitorClass, m.moniDataNo].join(
                  "*"
                ),
                itemName: m.vitalMonitorItemName,
                itemColor: "#000000",
                itemPoint: "triangle",
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
        /* #9312 ADD START */
        this.popoverInfo.selectInfoOptions.unshift(
          ...deepCopy(selectInfoOptions.vitalInfoPlus)
        );
        /* #9312 ADD END*/
      }
    },

    /**
     * 検索機能
     */
    fuzzyQuery() {
      if (this.popoverSearchQuery == "" || this.popoverSearchQuery == null) {
        if (
          this.popoverInfo.targetInfo.categoryNo >= 1024 &&
          this.popoverInfo.targetInfo.categoryNo <= 1027
        ) {
          this.changePopoverDownListData(this.targetElement);
        } else if (
          (this.popoverInfo.targetInfo.categoryNo >= 1002 &&
            this.popoverInfo.targetInfo.categoryNo <= 1011) ||
          (this.popoverInfo.targetInfo.categoryNo >= 1020 &&
            this.popoverInfo.targetInfo.categoryNo <= 1021)
        ) {
          if (
            this.popoverInfo.targetInfo.categoryNo >= 1002 &&
            this.popoverInfo.targetInfo.categoryNo <= 1005
          ) {
            this.changePopoverDownListData("vital_monitor");
          }
          if (
            (this.popoverInfo.targetInfo.categoryNo >= 1006 &&
              this.popoverInfo.targetInfo.categoryNo <= 1007) ||
            (this.popoverInfo.targetInfo.categoryNo >= 1020 &&
              this.popoverInfo.targetInfo.categoryNo <= 1021)
          ) {
            this.changePopoverDownListData("weight");
          }
          if (
            this.popoverInfo.targetInfo.categoryNo >= 1008 &&
            this.popoverInfo.targetInfo.categoryNo <= 1011
          ) {
            this.changePopoverDownListData("inspection");
          }
          this.changePopoverDownListData(this.popoverChooseData);
        } else {
          this.changePopoverDownListData(this.popoverChooseData);
        }

        if (this.popoverInfo.targetInfo.categoryNo === 16) {
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
          //患者イベントを
          this.popoverInfo.selectInfoOptions = categoryPat.map((m) => {
            return {
              itemNo: m.subCategoryCd,
              itemName: m.subCategoryName,
              isPatEventSub: m.isPatEventSub,
            };
          });
        }
      } else {
        const content = new RegExp(this.popoverSearchQuery, "gi");
        this.popoverInfo.selectInfoOptions =
          this.popoverInfo.selectInfoOptions.filter((item) => {
            return item.itemName.search(content) > -1;
          });
      }
    },
    /**
     * ラジオボタンの名前を設定します
     * @param obj
     * @param last
     * @returns {*}
     */
    getCheckBox(obj, last) {
      return obj.itemNo + obj.itemName + last;
    },
    getTargetElementNumber() {
      switch (this.targetElement) {
        case "weight":
          return 1;
        case "inspection":
          return 2;
        case "treatment_conditions":
          return 3;
        case "administered_drug":
          return 4;
        case "vital_monitor":
          return 5;
      }
    },
    /**
     * 薬剤区分のデータ
     */
    getTargetDrugData() {
      //#10176:ポップアップのフリーワード検索の動作不正 Start
      let ResKbn = this.targetdrugchkreskbn(this.dosOrPre);
      if (ResKbn === "0") {
        //#10176:ポップアップのフリーワード検索の動作不正 End
        return [
          { text: "薬剤グループ", value: "0" },
          { text: "通常薬剤", value: "1" },
          //#10176:ポップアップのフリーワード検索の動作不正 Start
          { text: "調整薬剤", value: "11" },
          //#10176:ポップアップのフリーワード検索の動作不正 End
        ];
        //#10176:ポップアップのフリーワード検索の動作不正 Start
      } else if (ResKbn === "2") {
        //#10176:ポップアップのフリーワード検索の動作不正 End
        return [
          //#10176:ポップアップのフリーワード検索の動作不正 Start
          { text: "薬剤グループ", value: "0" },
          //#10176:ポップアップのフリーワード検索の動作不正 End
          { text: "通常薬剤", value: "3" },
          { text: "一般名処方", value: "4" },
        ];
      }
    },

    /**
     * 薬剤分類のデータ
     * @returns {[{text: string, value: string}]}
     */
    getDrugClassificationData() {
      let classification = [{ text: "すべて", value: "0" }];
      for (let i = 0; i < this.mstMediClass.length; i++) {
        classification.push({
          text: this.mstMediClass[i].className,
          value: this.mstMediClass[i].classCd,
        });
      }
      return classification;
    },

    /**
     * 薬剤区分は薬剤分類のデータに応じて変化します
     * @param distinguish
     */
    medicineShowData(distinguish) {
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
      var temp = this.dispItemInfo
        .find((eleCategoryInfo) => {
          return (
            this.popoverInfo.targetInfo.categoryNo ===
            eleCategoryInfo.categoryNo
          );
        })
        .categoryItem.find((eleSubCategoryInfo) => {
          return (
            this.popoverInfo.targetInfo.subCategoryNo ===
            eleSubCategoryInfo.subCategoryNo
          );
        });
      var selectedIds = [];
      temp.subCategoryItem.forEach((item) => {
        selectedIds.push(item.itemNo);
      });
      // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      if (distinguish === "0") {
        // 投薬/薬剤グループ
        this.popoverInfo.selectInfoOptions = this.mstMedicineGroup
          .map((m) => {
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            if (
              m.isDisp === "1" ||
              selectedIds.includes("MEDICINE_GROUP".concat(m.medicineGroupCd))
            ) {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              return {
                itemNo: "MEDICINE_GROUP".concat(m.medicineGroupCd),
                itemName: m.medicineGroupName,
                itemDate: "day",
                itemColor: null,
                graph: "投薬",
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                isDisp: m.isDisp,
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              };
              // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              //});
            }
          })
          .filter(
            (item) =>
              item !== undefined &&
              item !== null &&
              Object.keys(item).length > 0
          );
        // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        //#10176:ポップアップのフリーワード検索の動作不正 Start
      } else if (distinguish === "1") {
        //#10176:ポップアップのフリーワード検索の動作不正 End
        // 投薬/通常薬剤
        //#10176:ポップアップのフリーワード検索の動作不正 Start
        let temp1;
        if (this.drugClassification != "0") {
          temp1 = this.mstMedicine
            .filter((data) => data.classCd == this.drugClassification)
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (m.isDisp === "1" || selectedIds.includes(m.medicineCd)) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: m.medicineCd,
                  itemName: m.medicineName,
                  itemDate: "day",
                  itemColor: null,
                  graph: "投薬",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                //});
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
        } else {
          temp1 = this.mstMedicine
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (m.isDisp === "1" || selectedIds.includes(m.medicineCd)) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: m.medicineCd,
                  itemName: m.medicineName,
                  itemDate: "day",
                  itemColor: null,
                  graph: "投薬",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                //});
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
        }
        // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end

        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
        temp1.sort((a, b) => b.isDisp - a.isDisp);
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        this.popoverInfo.selectInfoOptions = temp1;
      } else if (distinguish === medi_cate.adjustment.VALUE) {
        // 投薬/調整薬剤
        let temp1;
        if (this.drugClassification != "0") {
          temp1 = this.mstMedicineMix
            .filter((data) => data.classCd == this.drugClassification)
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (
                m.isDisp === "1" ||
                selectedIds.includes("MEDICINE_MIX".concat(m.medicineMixCd))
              ) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: "MEDICINE_MIX".concat(m.medicineMixCd),
                  itemName: m.medicineMixName,
                  itemDate: "day",
                  itemColor: null,
                  graph: "投薬",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                //});
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
        } else {
          temp1 = this.mstMedicineMix
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (
                m.isDisp === "1" ||
                selectedIds.includes("MEDICINE_MIX".concat(m.medicineMixCd))
              ) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: "MEDICINE_MIX".concat(m.medicineMixCd),
                  itemName: m.medicineMixName,
                  itemDate: "day",
                  itemColor: null,
                  graph: "投薬",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                //});
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
        }
        //#10176:ポップアップのフリーワード検索の動作不正 End
        // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
        temp1.sort((a, b) => b.isDisp - a.isDisp);
        // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        this.popoverInfo.selectInfoOptions = temp1;
      } else if (distinguish === "2") {
        // 処方/薬剤グループ
        this.popoverInfo.selectInfoOptions = this.mstMedicineGroup
          .map((m) => {
            // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
            if (
              m.isDisp === "1" ||
              selectedIds.includes("MEDICINE_GROUPS".concat(m.medicineGroupCd))
            ) {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              return {
                itemNo: "MEDICINE_GROUPS".concat(m.medicineGroupCd),
                itemName: m.medicineGroupName,
                itemDate: "day",
                itemColor: null,
                graph: "処方",
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                isDisp: m.isDisp,
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
              };
              // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              //});
            }
          })
          .filter(
            (item) =>
              item !== undefined &&
              item !== null &&
              Object.keys(item).length > 0
          );
        // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
      } else if (distinguish === "3") {
        //#10176:ポップアップのフリーワード検索の動作不正 Start
        // 処方/通常薬剤
        if (this.drugClassification != "0") {
          this.popoverInfo.selectInfoOptions = this.mstMedicine
            .filter((data) => data.classCd == this.drugClassification)
            .map((m) => {
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (
                m.isDisp === "1" ||
                selectedIds.includes("MEDICINE".concat(m.medicineCd))
              ) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: "MEDICINE".concat(m.medicineCd),
                  itemName: m.medicineName,
                  itemDate: "day",
                  itemColor: null,
                  graph: "処方",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                //});
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
          // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        } else {
          this.popoverInfo.selectInfoOptions = this.mstMedicine
            .map((m) => {
              //#10176:ポップアップのフリーワード検索の動作不正 End
              // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
              if (
                m.isDisp === "1" ||
                selectedIds.includes("MEDICINE".concat(m.medicineCd))
              ) {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                return {
                  itemNo: "MEDICINE".concat(m.medicineCd),
                  itemName: m.medicineName,
                  itemDate: "day",
                  itemColor: null,
                  graph: "処方",
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                  isDisp: m.isDisp,
                  // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                };
                // mod #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                //});
              }
            })
            .filter(
              (item) =>
                item !== undefined &&
                item !== null &&
                Object.keys(item).length > 0
            );
        }
      } else if (distinguish === "4") {
        // 処方/一般名処方
        this.popoverInfo.selectInfoOptions = this.sysGenericMedicine.map(
          (item) => {
            // mod「薬味区分」「一般名の場所」の選択、薬味名か表示されている薬味グループのリストデータ 関　start
            // let flag = this.findDiff("SYS_GENERIC_MEDICINE".concat(item.genericCd), mediData)
            // return {
            //   value: "SYS_GENERIC_MEDICINE".concat(item.genericCd),
            //   fnValue: {
            //     薬剤区分: medi_cate.prescription.VALUE,
            //     薬剤分類: item.classCd,
            //   },
            //   text: item.genericName,
            //   category: medi_cate.prescription.VALUE,
            //   setInfo: null,
            //   isDisp: flag,
            //   // itemColor: null,
            //   // itemDate: null,
            //   itemColor: "#000000",
            //   itemPoint: "triangle"
            return {
              itemNo: "MEDICINE" + item.genericCd,
              itemName: item.genericName,
              itemDate: "day",
              itemColor: "#000000",
              graph: "処方",
              // itemPoint: "triangle"
            };
            // mod「薬味区分」「一般名の場所」の選択、薬味名か表示されている薬味グループのリストデータ 関  end
          }
        );
      }
    },

    /**
     * 薬剤区分のデータ
     * @param classCd
     */
    drugClassificationDropList(classCd) {
      if (classCd === "0") {
        this.medicineShowData(this.drugDistinguish);
      } else {
        this.filterDrugClassificationDropList(classCd);
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
        this.editRecord.dispPeriodClass !== this.initDispPeriodClass ||
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
     * フィルタ医薬品分類ドロップリスト
     */
    filterDrugClassificationDropList(classCd) {
      if (this.drugDistinguish === "0") {
        // 投薬/薬剤グループ
        this.popoverInfo.selectInfoOptions = [];
      } else if (this.drugDistinguish === "1") {
        // 投薬/通常薬剤
        this.popoverInfo.selectInfoOptions = this.mstMedicine
          .filter((data) => data.classCd == classCd)
          .map((m) => {
            return {
              itemNo: m.medicineCd,
              itemName: m.medicineName,
            };
          });
        //#10176:ポップアップのフリーワード検索の動作不正 Start
      } else if (this.drugDistinguish === medi_cate.adjustment.VALUE) {
        // 投薬/調整薬剤
        this.popoverInfo.selectInfoOptions = this.mstMedicineMix
          .filter((data) => data.classCd == classCd)
          .map((m) => {
            return {
              itemNo: MEDICINE_MIX.concat(m.medicineMixCd),
              itemName: m.medicineMixName,
            };
          });
        //#10176:ポップアップのフリーワード検索の動作不正 End
      } else if (this.drugDistinguish === "2") {
        // 処方/薬剤グループ
        this.popoverInfo.selectInfoOptions = [];
      } else if (this.drugDistinguish === "3") {
        // 処方/通常薬剤
        this.popoverInfo.selectInfoOptions = this.mstMedicine
          .filter((data) => data.classCd == classCd)
          .map((m) => {
            return {
              itemNo: m.medicineCd,
              itemName: m.medicineName,
            };
          });
      } else if (this.drugDistinguish === "4") {
        // 処方/一般名処方
        this.popoverInfo.selectInfoOptions = [];
      }
    },

    /**
     * ラジオボタンの値のバインド
     * @param str
     * @param num
     */
    radioCheckBox(str, num) {
      let temp = "";
      if (str === "inspectionStatus") {
        if (num === 1) {
          temp = "結果";
        } else {
          temp = "投薬支援";
        }
        this.dispItemInfo
          .find((eleCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.categoryNo ===
              eleCategoryInfo.categoryNo
            );
          })
          .categoryItem.find((eleSubCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.subCategoryNo ===
              eleSubCategoryInfo.subCategoryNo
            );
          }).inspectionStatus = temp;
      } else if (str === "treatmentStatus") {
        if (num === 1) {
          temp = "指示";
        } else {
          temp = "実績";
        }
        this.dispItemInfo
          .find((eleCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.categoryNo ===
              eleCategoryInfo.categoryNo
            );
          })
          .categoryItem.find((eleSubCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.subCategoryNo ===
              eleSubCategoryInfo.subCategoryNo
            );
          }).treatmentStatus = temp;
      } else if (str === "drugStatus") {
        if (num === 1) {
          temp = "指示";
        } else if (num === 2) {
          temp = "実績";
        } else {
          temp = "投薬支援";
        }
        this.dispItemInfo
          .find((eleCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.categoryNo ===
              eleCategoryInfo.categoryNo
            );
          })
          .categoryItem.find((eleSubCategoryInfo) => {
            return (
              this.popoverInfo.targetInfo.subCategoryNo ===
              eleSubCategoryInfo.subCategoryNo
            );
          }).drugStatus = temp;
      }
    },

    /**
     * 最小の表示項目を表示するかどうかを制御します
     * @param categoryNo
     * @param subCategoryNo
     * @returns {boolean}
     */
    showGrandson(categoryNo, subCategoryNo) {
      if (categoryNo === 1) {
        if (
          subCategoryNo === 3 ||
          subCategoryNo === 4 ||
          subCategoryNo === 5 ||
          subCategoryNo === 56 ||
          (subCategoryNo >= 58 && subCategoryNo <= 61) ||
          (subCategoryNo >= 65 && subCategoryNo <= 72)
        ) {
          return true;
        } else {
          return false;
        }
      } else if (
        categoryNo === 12 ||
        categoryNo === 13 ||
        categoryNo === 14 ||
        categoryNo === 17 ||
        categoryNo === 1016 ||
        categoryNo === 1028
      ) {
        return false;
      } else {
        return true;
      }
    },
    closePopover() {
      // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
      this.graphMax = null;
      this.graphMin = null;
      // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
      this.popoverInfo.popoverVisible = false;
    },
    inputNumber(e, flag) {
      // 数値範囲内かどうかの確認
      if (flag === 1) {
        if (this.min !== undefined && this.max !== undefined) {
          if (e.target.value > this.max) {
            this.graphMax = this.min;
            this.blurFlg = true;
          } else if (e.target.value < this.min) {
            this.graphMax = this.max;
            this.blurFlg = true;
          } else {
            this.blurFlg = false;
          }
        }
      } else if (flag === 2) {
        if (this.min !== undefined && this.max !== undefined) {
          if (e.target.value > this.max) {
            this.graphMin = this.min;
            this.blurFlg = true;
          } else if (e.target.value < this.min) {
            this.graphMin = this.max;
            this.blurFlg = true;
          } else {
            this.blurFlg = false;
          }
        }
      }
    },
    stopScrollFun(e, flag, key) {
      if (!this.focusFlg[key]) {
        return;
      }
      let delta =
        (e.wheelDelta && (e.wheelDelta > 0 ? 1 : -1)) ||
        (e.detail && (e.wheelDelta > 0 ? -1 : 1));
      console.log(e.wheelDelta);
      if (!e.target.value) {
        e.target.value = 0;
      }
      let value = parseFloat(e.target.value);
      const parameterStep = 0.01;
      if (delta > 0) {
        // 滑ります
        value += parameterStep;
      } else {
        // 下がります
        value -= parameterStep;
      }
      // 数値範囲内かどうかの確認
      if (flag === 1) {
        if (value > this.max) {
          value = this.min;
        }
        if (value < this.min) {
          value = this.max;
        }
        this.graphMax = value.toFixed(2);
      } else if (flag === 2) {
        if (value > this.max) {
          value = this.min;
        }
        if (value < this.min) {
          value = this.max;
        }
        this.graphMin = value.toFixed(2);
      }
    },
    handleFocus(key) {
      this.focusFlg[key] = true;
    },
    graphValueChange(event, flag, key) {
      // 限界値判定
      if (flag === 1) {
        // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
        //let value = event.target.value;
        let value = event.target?event.target.value:event;
        // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
        if (value == this.max && this.blurFlg) {
          this.graphMax = this.min;
          this.blurFlg = false;
        } else if (value == this.min && this.blurFlg) {
          this.graphMax = this.max;
          this.blurFlg = false;
        }
      } else if (flag === 2) {
        // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
        // let value = event.target.value;
        let value = event.target?event.target.value:event;
        // mod #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
        if (value == this.max && this.blurFlg) {
          this.graphMin = this.min;
          this.blurFlg = false;
        } else if (value == this.min && this.blurFlg) {
          this.graphMin = this.max;
          this.blurFlg = false;
        }
      }
      this.focusFlg[key] = false;
      // add 12031 患者経過総合ビューアのグラフオートレンジ zkm start
      this.graphMax =
        this.graphMax != null && "" !== this.graphMax
          ? Number(this.graphMax).toFixed(2)
          : "";
      this.graphMin =
        this.graphMin != null && "" !== this.graphMin
          ? Number(this.graphMin).toFixed(2)
          : "";
      // add 12031 患者経過総合ビューアのグラフオートレンジ zkm end
      let parentSubCategoryNo = this.getParentSubCategoryNo(
        this.popoverInfo.targetInfo.subCategoryNo
      );

      // mod 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s start
      // let temp = this.dispItemInfo.find((eleCategoryInfo) => {
      //   return this.popoverInfo.targetInfo.categoryNo === eleCategoryInfo.categoryNo;
      // }).categoryItem.find(
      //   (eleSubCategoryInfo) => {
      //     return this.popoverInfo.targetInfo.subCategoryNo === eleSubCategoryInfo.subCategoryNo;
      //   }
      // )
      const CategoryInfo = this.dispItemInfo.find((eleCategoryInfo) => {
        return (
          this.popoverInfo.targetInfo.categoryNo === eleCategoryInfo.categoryNo
        );
      });
      const temp = CategoryInfo.categoryItem.find((eleSubCategoryInfo) => {
        return parentSubCategoryNo === eleSubCategoryInfo.subCategoryNo;
      });
      // if (flag === 1) {
      //   temp.graphMax = this.graphMax
      // } else {
      //   temp.graphMin = this.graphMin
      // }
      if (
        //検査結果
        (8 <= CategoryInfo.categoryNo && CategoryInfo.categoryNo <= 11) ||
        (1008 <= CategoryInfo.categoryNo && CategoryInfo.categoryNo <= 1011)
      ) {
        if (flag === 1) {
          // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // temp.max = Number(this.graphMax)
          temp.max = this.graphMax;
          // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
        } else {
          // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm start
          // temp.min = Number(this.graphMin)
          temp.min = this.graphMin;
          // mod 12031 患者経過総合ビューアのグラフオートレンジ zkm end
        }
      } else {
        if (flag === 1) {
          if (
            this.popoverInfo.targetInfo.subCategoryNo === 65 ||
            this.popoverInfo.targetInfo.subCategoryNo === 67 ||
            this.popoverInfo.targetInfo.subCategoryNo === 69 ||
            this.popoverInfo.targetInfo.subCategoryNo === 71
          ) {
            temp.vitalChild[0].graphMax = this.graphMax;
          } else if (
            this.popoverInfo.targetInfo.subCategoryNo === 66 ||
            this.popoverInfo.targetInfo.subCategoryNo === 68 ||
            this.popoverInfo.targetInfo.subCategoryNo === 70 ||
            this.popoverInfo.targetInfo.subCategoryNo === 72
          ) {
            temp.vitalChild[1].graphMax = this.graphMax;
          } else {
            temp.graphMax = this.graphMax;
          }
        } else {
          if (
            this.popoverInfo.targetInfo.subCategoryNo === 65 ||
            this.popoverInfo.targetInfo.subCategoryNo === 67 ||
            this.popoverInfo.targetInfo.subCategoryNo === 69 ||
            this.popoverInfo.targetInfo.subCategoryNo === 71
          ) {
            temp.vitalChild[0].graphMin = this.graphMin;
          } else if (
            this.popoverInfo.targetInfo.subCategoryNo === 66 ||
            this.popoverInfo.targetInfo.subCategoryNo === 68 ||
            this.popoverInfo.targetInfo.subCategoryNo === 70 ||
            this.popoverInfo.targetInfo.subCategoryNo === 72
          ) {
            temp.vitalChild[1].graphMin = this.graphMin;
          } else {
            temp.graphMin = this.graphMin;
          }
        }
      }
      // mod 患者経過総合ビューアレイアウトマスタ 7・検査結果グラフのグラフ上下限 孔s end
    },
    // add #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang start
    treatDisabledConfirm(category, subCategory) {
      if(category.categoryNo == 1) {
        if((subCategory.subCategoryNo >= 58 && subCategory.subCategoryNo <= 61) 
        || (subCategory.subCategoryNo >= 65 && subCategory.subCategoryNo <= 72)) {
              if(subCategory.subCategoryItem.length == 0) {
                return true;
              }
           }
      }
      return false;
    },
    // add #9524 患者経過総合ビューアレイアウトマスタのグラフ項目の保存について fang end
    disabledConfirm(category, subCategory) {
      if (
        (category.categoryNo >= 1017 && category.categoryNo <= 1019) ||
        category.categoryNo === 1022
      ) {
        if (subCategory.subCategoryItem.length > 0) {
          return false;
        }
      }
      if (
        category.categoryItem.length > 1 &&
        subCategory.subCategoryItem.length > 0
      ) {
        return false;
      }
      return true;
    },

    getCheckItem() {
      let tempList = this.mstExamItem.map((rec) => {
        return {
          itemNo: rec.examItemCd,
          itemName: rec.examItemName,
          itemColor: "#000000",
          itemPoint: "triangle",
          // itemColor: null,
          // itemPoint: null,
          //mod 内部5988 【結合仕様書作成】患者経過総合ビューア グラフ 張 end
          isMasterData: 1,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
          isDisp: rec.isDisp,
          // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
        };
      });
      tempList = tempList.concat(selectInfoOptions.inspectionResultSupport);
      return tempList;
    },

    indentIsPatEventSub(categoryNo, selectedInfo) {
      if (categoryNo === 15 || categoryNo === 16) {
        return selectedInfo.isPatEventSub === 1;
      } else {
        return false;
      }
    },

    // 親サブカテゴリNoの取得
    getParentSubCategoryNo(subCategoryNo) {
      if (subCategoryNo === 65 || subCategoryNo === 66) {
        return 58;
      } else if (subCategoryNo === 67 || subCategoryNo === 68) {
        return 59;
      } else if (subCategoryNo === 69 || subCategoryNo === 70) {
        return 60;
      } else if (subCategoryNo === 71 || subCategoryNo === 72) {
        return 61;
      } else {
        return subCategoryNo;
      }
    },

    /**
     * @description 抽出条件の選択項目が変わる時のコールバック
     */
    filterChange(e) {
      //#10176:ポップアップのフリーワード検索の動作不正 Start
      let ResKbn = this.targetdrugchkreskbn(this.dosOrPre);
      //薬剤区分選択値取得
      if (ResKbn === "0") {
        const class_lists = document.getElementsByClassName("k-input");
        let Drug_classification_selsin = "";
        for (let i = 0; i < class_lists.length; i++) {
          if (
            String(class_lists[i].innerHTML).includes(
              medi_cate.group.TEXT.trim()
            )
          )
            Drug_classification_selsin = medi_cate.group.VALUE;
          if (
            String(class_lists[i].innerHTML).includes(
              medi_cate.normal.TEXT.trim()
            )
          )
            Drug_classification_selsin = medi_cate.normal.VALUE;
          if (
            String(class_lists[i].innerHTML).includes(
              medi_cate.adjustment.TEXT.trim()
            )
          )
            Drug_classification_selsin = medi_cate.adjustment.VALUE;
        }
        if (Drug_classification_selsin === medi_cate.group.VALUE) {
          this.drugDistinguish = medi_cate.group.VALUE;
          this.medicineShowData(medi_cate.group.VALUE);
        } else if (Drug_classification_selsin === medi_cate.normal.VALUE) {
          this.drugDistinguish = medi_cate.normal.VALUE;
          this.medicineShowData(medi_cate.normal.VALUE);
        } else if (Drug_classification_selsin === medi_cate.adjustment.VALUE) {
          this.drugDistinguish = medi_cate.adjustment.VALUE;
          this.medicineShowData(medi_cate.adjustment.VALUE);
        }
      } else if (ResKbn === "2") {
        const class_lists = document.getElementsByClassName("k-input");
        let Drug_classification_selsin = "";
        for (let i = 0; i < class_lists.length; i++) {
          if (
            String(class_lists[i].innerHTML).includes(
              medi_cate.groupS.TEXT.trim()
            )
          )
            Drug_classification_selsin = medi_cate.groupS.VALUE;
          if (
            String(class_lists[i].innerHTML).includes(
              medi_cate.normalS.TEXT.trim()
            )
          )
            Drug_classification_selsin = medi_cate.normalS.VALUE;
          if (
            String(class_lists[i].innerHTML).includes(
              medi_cate.prescription.TEXT.trim()
            )
          )
            Drug_classification_selsin = medi_cate.prescription.VALUE;
        }
        if (Drug_classification_selsin === medi_cate.groupS.VALUE) {
          this.drugDistinguish = medi_cate.group.VALUE;
          this.medicineShowData(medi_cate.groupS.VALUE);
        }
        if (Drug_classification_selsin === medi_cate.normalS.VALUE) {
          this.drugDistinguish = medi_cate.normalS.VALUE;
          this.medicineShowData(medi_cate.normalS.VALUE);
        }
        if (Drug_classification_selsin === medi_cate.prescription.VALUE) {
          this.drugDistinguish = medi_cate.prescription.VALUE;
          this.medicineShowData(medi_cate.prescription.VALUE);
        }
      }
      //#10176:ポップアップのフリーワード検索の動作不正 End
    },
    //#10176:ポップアップのフリーワード検索の動作不正 Start
    /**
     * 対象薬剤判定 戻り値 投薬:"0" 処方：“2” 例外:Null
     * @param data
     */
    targetdrugchkreskbn(data) {
      if (data === "投薬") return "0";
      else if (data === "処方") return "2";
      return "";
    },

    /**
     * 薬剤分類活性化判定 戻り値 :true　:false
     * @param data
     */
    targetdrugchkrescategoryflg(data) {
      if (data === "0" || data === "2" || data === "4") return true;
      else return false;
    },
    //#10176:ポップアップのフリーワード検索の動作不正 End

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
  height: 97%;
  width: 100%;
  border-collapse: collapse;
}

/* .disp-item-area tr {
  height: 30px;
} */

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
  height: 100%;
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
</style>
