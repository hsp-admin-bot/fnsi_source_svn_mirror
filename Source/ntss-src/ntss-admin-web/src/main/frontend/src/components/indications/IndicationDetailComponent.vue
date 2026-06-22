<template>
  <div id="indication-detail" class="main-content-area d-flex flex-column">
    <!-- Grid -->
    <div class="grid flex-1" v-if="layout">
      <div>
        <div class="horizontal d-flex">
          <div class="header"></div>
          <div class="header" :class="getStyle(ordDetail.treatDate)">{{ formattedTreatDate }}</div>
          <div class="header">指示者</div>
          <div class="header">入力者</div>
        </div>

        <div class="vertical-wrapper d-flex flex-column">
          <div
            class="vertical d-flex"
            v-for="subCategory in layout"
            :key="subCategory.subCategoryNo"
          >
            <div v-if="subCategory.subCategoryNo == 2" :class="['sub-category d-flex flex-1', {'content-change': isContentChangeWithUnit(subCategory.itemInfo, subCategory.subCategoryNo)}]">
              <div class="header d-flex align-items-center">
                {{ subCategory.subCategoryName }}
              </div>
              <div class="text value flex-1 d-flex align-items-center">
                <span v-if="isContentChangeWithUnit(subCategory.itemInfo, subCategory.subCategoryNo)">
                    {{ getLeftTreatMethod(subCategory.subCategoryNo) }}&nbsp;&rarr;&nbsp;
                </span>
                {{ getTreatMethod(subCategory) }}
              </div>
              <div class="text instructor flex-1">
                {{ subCategory.itemInfo.data.instructor }}
              </div>
              <div class="text updater flex-1">
                {{ subCategory.itemInfo.data.updater }}
              </div>
            </div>

            <div v-if="subCategory.subCategoryNo != 2 && subCategory.subCategoryItem.length > 0" class="sub-category multiple d-flex flex-1">
              <div class="header">{{ subCategory.subCategoryName }}</div>
              <div class="flex-1 d-flex flex-column">
                <div :key="subCategory.subCategoryNo != 6 ? item.itemNo : item.itemCd" v-for="item in subCategory.subCategoryItem" :class="['sub-category-item flex-1 d-flex', {'content-change': isContentChangeWithUnit(item.itemInfo, subCategory.subCategoryNo)}]" >
                  <div class="sub-header d-flex align-items-center">
                    {{ item.itemInfo.itemName }}
                  </div>
                  <div :class="checkIsDisable(item.itemInfo, subCategory.subCategoryNo) ? 'text value flex-1 d-flex is-disabled hide-text align-items-center' : 'text value flex-1 d-flex align-items-center'">
                    <span v-if="isContentChangeWithUnit(item.itemInfo, subCategory.subCategoryNo)">
                      <span v-if="item.itemInfo.status === undefined">
                        {{ getLeftItemValue(item.itemInfo, subCategory.subCategoryNo) }}&nbsp;&rarr;&nbsp;
                      </span>
                    </span>
                    {{ getItemValue(item.itemInfo, subCategory.subCategoryNo) }}
                    <span v-if="item.itemInfo.status === 2">&nbsp;&rarr;&nbsp;(中止)</span>
                  </div>
                  <div :class="checkIsDisable(item.itemInfo, subCategory.subCategoryNo) ? 'text instructor flex-1 is-disabled' : 'text instructor flex-1'">
                    {{ item.itemInfo.data.instructor }}
                  </div>
                  <div :class="checkIsDisable(item.itemInfo, subCategory.subCategoryNo) ? 'text updater flex-1 is-disabled' : 'text updater flex-1'">
                    {{ item.itemInfo.data.updater }}
                  </div>
                </div>
              </div>
            </div>

            <div v-if="subCategory.subCategoryNo != 2 && subCategory.subCategoryItem.length == 0" :class="['sub-category d-flex flex-1']">
              <div class="header d-flex align-items-center">
                {{ subCategory.subCategoryName }}
              </div>
              <div class="text value flex-1 d-flex align-items-center">
              </div>
              <div class="text instructor flex-1">
              </div>
              <div class="text updater flex-1">
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- / Grid -->

    <!-- Checker -->
    <div class="checkers d-flex" v-if="layout">
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <div class="d-flex flex-column" v-show="isShowChecker1" @click="openUserTreatmentList(SELECTED_CHECKBOX.CHECKBOX1)"> -->
      <div
        class="d-flex flex-column"
        v-show="isShowChecker1"
        @click="getItemAuthorized('IndicationList', 'default_authority') && openUserTreatmentList(SELECTED_CHECKBOX.CHECKBOX1)"
      >
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <div @click="toggleCheckbox1" :class="[{ 'isDisabled': isDisabled || isDisabledCheckbox1 }, 'd-flex align-items-center']"> -->
        <div
          @click="getItemAuthorized('IndicationList', 'default_authority') && toggleCheckbox1"
          :class="[{ 'isDisabled': isDisabled || isDisabledCheckbox1 }, 'd-flex align-items-center']"
        >
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!--          mod 障害票一覧_指示受け・指示承認 修正 chen start-->
          <!--          <v-ons-checkbox-->
          <!--            input-id="checkbox1"-->
          <!--            :disable="true"-->
          <!--            v-model="isCheckbox1HasValue"-->
          <!--          />-->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-checkbox -->
          <!--   input-id="checkbox1" -->
          <!--   class="checkbox" -->
          <!--   v-model="isCheckbox1HasValue" -->
          <!-- /> -->
          <v-ons-checkbox
            input-id="checkbox1"
            class="checkbox"
            v-model="isCheckbox1HasValue"
            @change="onChangeCheckbox1($event)"
            :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!--          mod 障害票一覧_指示受け・指示承認 修正 chen end-->
          <label
            for="checkbox1"
            :class="{'selected-item' : (!isApproving && isDirtyChecked1) || (isApproving && isDirtyApproved1)}"
          >{{ checker1 }}</label>
        </div>

        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <kendo-dropdownlist -->
        <!--   :data-source="userTreatmentList1" -->
        <!--   :disabled="isDisabled || isDisabledDropdown" -->
        <!--   v-model="selectedStaffCd1" -->
        <!--   data-text-field="userFullName" -->
        <!--   data-value-field="userId" -->
        <!--   @change="onChangeStaff1($event)" -->
        <!--   @close="closeUserTreatmentList(SELECTED_CHECKBOX.CHECKBOX1)" -->
        <!--   :class="{'selected-item' : (!isApproving && isDirtyChecked1) || (isApproving && isDirtyApproved1)}" -->
        <!-- /> -->
        <kendo-dropdownlist
          :data-source="userTreatmentList1"
          :disabled="isDisabled || isDisabledDropdown || !getItemAuthorized('IndicationList', 'default_authority')"
          v-model="selectedStaffCd1"
          data-text-field="userFullName"
          data-value-field="userId"
          @change="onChangeStaff1($event)"
          @close="closeUserTreatmentList(SELECTED_CHECKBOX.CHECKBOX1)"
          :class="{'selected-item' : (!isApproving && isDirtyChecked1) || (isApproving && isDirtyApproved1)}"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </div>

      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <div class="d-flex flex-column" v-show="isShowChecker2" @click="openUserTreatmentList(SELECTED_CHECKBOX.CHECKBOX2)"> -->
      <div
        class="d-flex flex-column"
        v-show="isShowChecker2"
        @click="getItemAuthorized('IndicationList', 'default_authority') && openUserTreatmentList(SELECTED_CHECKBOX.CHECKBOX2)">
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <div @click="toggleCheckbox2" :class="[{ 'isDisabled': isDisabled || isDisabledCheckbox2}, 'd-flex align-items-center']"> -->
        <div
          @click="getItemAuthorized('IndicationList', 'default_authority') && toggleCheckbox2"
          :class="[{ 'isDisabled': isDisabled || isDisabledCheckbox2}, 'd-flex align-items-center']"
        >
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!--          mod 障害票一覧_指示受け・指示承認 修正 chen start-->
          <!--          <v-ons-checkbox-->
          <!--            input-id="checkbox2"-->
          <!--            :disable="true"-->
          <!--            v-model="isCheckbox2HasValue"-->
          <!--          />-->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-checkbox-->
          <!--   input-id="checkbox2"-->
          <!--   class="checkbox"-->
          <!--   v-model="isCheckbox2HasValue"-->
          <!-- />-->
          <v-ons-checkbox
            input-id="checkbox2"
            class="checkbox"
            v-model="isCheckbox2HasValue"
            @change="onChangeCheckbox2($event)"
            :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
          />
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <!--          mod 障害票一覧_指示受け・指示承認 修正 chen end-->
          <label
            for="checkbox2"
            :class="{'selected-item' : (!isApproving && isDirtyChecked2) || (isApproving && isDirtyApproved2)}"
          >{{ checker2 }}</label>
        </div>

        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <kendo-dropdownlist -->
        <!--   :data-source="userTreatmentList2" -->
        <!--   :disabled="isDisabled || isDisabledDropdown" -->
        <!--   v-model="selectedStaffCd2" -->
        <!--   data-text-field="userFullName" -->
        <!--   data-value-field="userId" -->
        <!--   @change="onChangeStaff2($event)" -->
        <!--   @close="closeUserTreatmentList(SELECTED_CHECKBOX.CHECKBOX2)" -->
        <!--   :class="{'selected-item' : (!isApproving && isDirtyChecked2) || (isApproving && isDirtyApproved2)}" -->
        <!-- /> -->
        <kendo-dropdownlist
          :data-source="userTreatmentList2"
          :disabled="isDisabled || isDisabledDropdown || !getItemAuthorized('IndicationList', 'default_authority')"
          v-model="selectedStaffCd2"
          data-text-field="userFullName"
          data-value-field="userId"
          @change="onChangeStaff2($event)"
          @close="closeUserTreatmentList(SELECTED_CHECKBOX.CHECKBOX2)"
          :class="{'selected-item' : (!isApproving && isDirtyChecked2) || (isApproving && isDirtyApproved2)}"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
      </div>
    </div>
    <!-- / Checker -->

    <!-- Loading -->
    <v-ons-modal :visible="isLoading">
      <p class="loading-modal">
        {{ loadingMessage }}
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
    <!-- / Loading -->

    <!-- Indication Details -->
    <div
      class="indication-detail-filter d-flex mb-2 mt-2"
      style="flex-wrap: wrap; justify-content: space-between;"
      v-if="isModeIndicationDetails"
    >
      <div class="d-flex checkbox-group" style="flex-wrap: wrap; align-items: center;">
        <div>
          <span style="white-space: nowrap;" class="base-color"
          >未チェックのみ表示</span
          >
        </div>
        <div class="radio_line">
          <div class="d-flex align-items-center" v-if="isReceive" v-show="columnStatus.isShowChecker1">
            <!--            mod    FNSI-権限 陳 start-->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-checkbox -->
            <!--   input-id="check-receive1" -->
            <!--   @change="onChangeFilter()" -->
            <!--   v-model="indicationsUncheckedValue.receiver1" -->
            <!--   :disabled="!hasIndReceiveAuthority" -->
            <!-- /> -->
            <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-checkbox -->
            <!--   input-id="check-receive1" -->
            <!--   @change="onChangeFilter()" -->
            <!--   v-model="indicationsUncheckedValue.receiver1" -->
            <!--   :disabled="!getItemAuthorized('IndicationList', 'default_authority')" -->
            <!-- /> -->
            <v-ons-checkbox
              input-id="check-receive1"
              @change="onChangeFilter()"
              v-model="indicationsUncheckedValue.receiver1"
            />
            <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!--          <v-ons-checkbox-->
            <!--            input-id="check-receive1"-->
            <!--            @change="onChangeFilter()"-->
            <!--            v-model="indicationsUncheckedValue.receiver1"-->
            <!--          />-->
            <!--            mod    FNSI-権限 陳 end-->
            <label for="check-receive1" id="testId" style="white-space: nowrap;">指示受け1</label>
          </div>

          <div class="d-flex align-items-center radio_line_2" v-if="isReceive" v-show="columnStatus.isShowChecker2">
            <!--            mod    FNSI-権限 陳 start-->
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-checkbox -->
            <!--   input-id="check-receive2" -->
            <!--   @change="onChangeFilter()" -->
            <!--   v-model="indicationsUncheckedValue.receiver2" -->
            <!--   :disabled="!hasIndReceiveAuthority" -->
            <!-- /> -->
            <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-checkbox -->
            <!--   input-id="check-receive2" -->
            <!--   @change="onChangeFilter()" -->
            <!--   v-model="indicationsUncheckedValue.receiver2" -->
            <!--   :disabled="!getItemAuthorized('IndicationList', 'default_authority')" -->
            <!-- /> -->
            <v-ons-checkbox
              input-id="check-receive2"
              @change="onChangeFilter()"
              v-model="indicationsUncheckedValue.receiver2"
            />
            <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!--          <v-ons-checkbox-->
            <!--          input-id="check-receive2"-->
            <!--          @change="onChangeFilter()"-->
            <!--          v-model="indicationsUncheckedValue.receiver2"-->
            <!--        />-->
            <!--            mod    FNSI-権限 陳 end-->
            <label for="check-receive2" style="white-space: nowrap;">指示受け2</label>
          </div>
        </div>

        <div class="d-flex align-items-center" v-if="!isReceive" v-show="columnStatus.isShowApprover1">
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-checkbox -->
          <!--   input-id="check-approver-1" -->
          <!--   @change="onChangeFilter()" -->
          <!--   v-model="indicationsUncheckedValue.approver1" -->
          <!-- /> -->
          <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-checkbox -->
          <!--   input-id="check-approver-1" -->
          <!--   @change="onChangeFilter()" -->
          <!--   v-model="indicationsUncheckedValue.approver1" -->
          <!--   :disabled="!getItemAuthorized('IndicationList', 'default_authority')" -->
          <!-- /> -->
          <v-ons-checkbox
            input-id="check-approver-1"
            @change="onChangeFilter()"
            v-model="indicationsUncheckedValue.approver1"
          />
          <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <label for="check-approver-1">指示承認1</label>
        </div>

        <div class="d-flex align-items-center" v-if="!isReceive" v-show="columnStatus.isShowApprover2">
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-checkbox -->
          <!--   input-id="check-approver-2" -->
          <!--   @change="onChangeFilter()" -->
          <!--   v-model="indicationsUncheckedValue.approver2" -->
          <!-- /> -->
          <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-checkbox -->
          <!--   input-id="check-approver-2" -->
          <!--   @change="onChangeFilter()" -->
          <!--   v-model="indicationsUncheckedValue.approver2" -->
          <!--   :disabled="!getItemAuthorized('IndicationList', 'default_authority')" -->
          <!-- /> -->
          <v-ons-checkbox
            input-id="check-approver-2"
            @change="onChangeFilter()"
            v-model="indicationsUncheckedValue.approver2"
          />
          <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <label for="check-approver-2">指示承認2</label>
        </div>
      </div>
      <div class="d-flex button-group">
        <div class="d-flex" style="align-items: center;" v-show="columnStatus.isShowChecker1">
          <span v-if="isReceive" class="radio_all_2 base-color receiver-title" style="white-space: nowrap;"
          >指示受け1</span>
          <!--            mod    FNSI-権限 陳 start-->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   v-if="isReceive" -->
          <!--   class="icon btn1-execute" -->
          <!--   style="margin-right: 0.5em;" -->
          <!--   @click="clickSelectAll(INDICATIONTYPE.RECEIVER1)" -->
          <!--   :disabled="!hasIndReceiveAuthority" -->
          <!-- > -->
          <v-ons-button
            v-if="isReceive"
            class="icon btn1-execute"
            style="margin-right: 0.5em;"
            @click="clickSelectAll(INDICATIONTYPE.RECEIVER1)"
            :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!--            <v-ons-button-->
            <!--              v-if="isReceive"-->
            <!--              class="mr-3 icon"-->
            <!--              @click="clickSelectAll(INDICATIONTYPE.RECEIVER1)"-->
            <!--            >-->
            <!--            mod    FNSI-権限 陳 end-->
            ALL <img :src="okIcon" alt="ok icon" />
          </v-ons-button>
        </div>
        <div class="d-flex" style="align-items: center;" v-show="columnStatus.isShowChecker2">
          <span v-if="isReceive" class="radio_all_2 base-color receiver-title" style="white-space: nowrap;"
          >指示受け2</span
          >
          <!--            mod    FNSI-権限 陳 start-->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   v-if="isReceive" -->
          <!--   class="icon btn1-execute" -->
          <!--   @click="clickSelectAll(INDICATIONTYPE.RECEIVER2)" -->
          <!--   :disabled="!hasIndReceiveAuthority" -->
          <!-- > -->
          <v-ons-button
            v-if="isReceive"
            class="icon btn1-execute"
            @click="clickSelectAll(INDICATIONTYPE.RECEIVER2)"
            :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!--            <v-ons-button-->
            <!--              v-if="isReceive"-->
            <!--              class="mr-3 icon"-->
            <!--              @click="clickSelectAll(INDICATIONTYPE.RECEIVER2)"-->
            <!--            >-->
            <!--            mod    FNSI-権限 陳 end-->
            ALL <img :src="okIcon" alt="ok icon" />
          </v-ons-button>
        </div>
        <div class="d-flex" v-show="columnStatus.isShowApprover1">
          <span
            v-if="isShowBtnOK && !isReceive"
            class="mr-3 base-color receiver-title"
            style="line-height: 36px"
          >指示承認1</span
          >
          <!--            mod    FNSI-権限 陳 start-->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   v-if="isShowBtnOK && !isReceive" -->
          <!--   class="mr-3 icon btn1-execute" -->
          <!--   @click="clickSelectAll(INDICATIONTYPE.APPROVER1)" -->
          <!--   :disabled="!hasIndReceiveAuthority" -->
          <!-- > -->
          <v-ons-button
            v-if="isShowBtnOK && !isReceive"
            class="mr-3 icon btn1-execute"
            @click="clickSelectAll(INDICATIONTYPE.APPROVER1)"
            :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!--            <v-ons-button-->
            <!--              v-if="isShowBtnOK && !isReceive"-->
            <!--              class="mr-3 icon"-->
            <!--              @click="clickSelectAll(INDICATIONTYPE.APPROVER1)"-->
            <!--            >-->
            <!--            mod    FNSI-権限 陳 end-->
            ALL <img :src="okIcon" alt="ok icon" />
          </v-ons-button>
        </div>
        <div class="d-flex" v-show="columnStatus.isShowApprover2">
          <span
            v-if="isShowBtnOK && !isReceive"
            class="mr-3 base-color receiver-title"
            style="line-height: 36px"
          >指示承認2</span
          >
          <!--            mod    FNSI-権限 陳 start-->
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!-- <v-ons-button -->
          <!--   v-if="isShowBtnOK && !isReceive" -->
          <!--   class="mr-3 icon btn1-execute" -->
          <!--   @click="clickSelectAll(INDICATIONTYPE.APPROVER2)" -->
          <!--   :disabled="!hasIndReceiveAuthority" -->
          <!-- > -->
          <v-ons-button
            v-if="isShowBtnOK && !isReceive"
            class="mr-3 icon btn1-execute"
            @click="clickSelectAll(INDICATIONTYPE.APPROVER2)"
            :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
          >
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <!--            <v-ons-button-->
            <!--              v-if="isShowBtnOK && !isReceive"-->
            <!--              class="mr-3 icon"-->
            <!--              @click="clickSelectAll(INDICATIONTYPE.APPROVER2)"-->
            <!--            >-->
            <!--            mod    FNSI-権限 陳 end-->
            ALL <img :src="okIcon" alt="ok icon" />
          </v-ons-button>
        </div>
      </div>
    </div>
    <LocalizationProvider :language="japanese ? 'es-JP' : 'en-EN'">
      <IntlProvider :locale="japanese ? 'jp' : 'en'">
        <Grid
          ref="grid"
          v-if="isModeIndicationDetails"
          :cell-render="cellTemplate"
          :dataItemKey="'refreshKey' + refreshKey"
          :style="{ height: gridHeightValue + 'px' }"
          :data-items="gridData"
          :all-grouped-items="allGroupedData"
          :unique-field="'_id'"
          :sortable="sortable"
          :sort="gridSort"
          :groupable="true"
          :take="gridPageSize"
          :skip="gridSkip"
          :group="gridGroup"
          :resizable="true"
          :reorderable="true"
          :expand-field="'expanded'"
          :columns="displayColumns"
          :row-height="45"
          :scrollable="'virtual'"
          :total="totalCnt"
          :collapsedGroups="collapsedGroups"
          @datastatechange="onDataStateChange"
          @groupchange="groupchange"
          @sortchange="sortChangeHandler"
          @columnreorder="columnReorder"
        >
          <template #groupHeader="{ props }">
            <td v-if="props.field !== undefined && props.rowType !== 'groupHeader'" :class="props.className">
              <div class="omit-content"
                          @mouseenter="handleMouseEnter($event, props.dataItem, props.columnIndex, props.columnsCount)"
                          @mouseleave="handleMouseLeave(props.dataItem, props.columnIndex)">
                <b>{{ getNestedValue(props.field, props.dataItem) }}</b>
              </div>
              <div 
                :style="toolTipStyle"
                class="omit-tip"
                v-if="props.dataItem._id === tipShow.id && props.columnIndex === tipShow.columnIndex"
              >
                {{ getNestedValue(props.field, props.dataItem) }}
              </div>
            </td>
            <td
              v-else-if="(props.columnIndex === undefined ||
                          props.level === undefined ||
                          props.columnIndex < props.level ||
                          props.columnsCount === undefined ||
                          props.rowType !== 'groupHeader' ||
                          props.dataItem[props.field] === undefined) && props.columnIndex < props.level"
              key="'g' + columnIndex"
              class="k-table-td"
            ></td>
            <td
              v-else-if="props.columnIndex <= props.level"
              key="g-colspan"
              :role="'gridcell'"
              :colSpan="props.columnsCount - props.columnIndex"
              class="k-table-td k-group-cell"
              style="left: 0px; right: 0px"
            >
              <p class="k-reset">
                <a
                  href="#"
                  tabIndex="-1"
                  @click.prevent="clickHandler(props)"
                >
                  <SvgIcon v-if="props.expanded" :icon="caretAltDownIcon" />
                  <SvgIcon v-if="!props.expanded" :icon="caretAltRightIcon" />
                </a>
                {{ columnsMap[props.dataItem.field] }}: {{ props.dataItem[props.field] }}
              </p>
            </td>
          </template>
          <template #editTemplate="{ props }">
            <td v-if="props.field !== undefined && props.rowType !== 'groupHeader'" :class="props.dataItem[props.field.replace('Name', 'IsEdited')] ? 'grid-edited-cell' : ''">
              <div v-if="!(props.dataItem._id === staffEdit.id && props.columnIndex === staffEdit.columnIndex)" :key="editRefreshKey" class="indication-detail-type">
                <div style="width: 120px;" @click="triggerToEdit(props.dataItem, props.columnIndex)">
                  <div style="width: 120px;">
                    {{ props.dataItem[props.field] ? props.dataItem[props.field] : '未登録' }}
                  </div>
                </div>
                <div style="width: 60px;">
                  <button v-if="hasIndReceiveAuthority" class="button btn1-execute" @click="onClickUpdateDetails(props.dataItem, props.field, undefined, undefined)" :disabled="!getItemAuthorized('IndicationList', 'default_authority')">
                    <img :src="okIcon" class="ok-icon" alt="ok icon" />
                  </button>
                </div>
              </div>
              <div v-else class="select-box">
                <kendo-dropdownlist
                  ref="dropList"
                  :data-source="mstPersonalUser"
                  :auto-select-first-on-empty="false"
                  v-model="props.dataItem[props.field.replace(/Name$/, '')]"
                  data-text-field="userFullName"
                  data-value-field="userId"
                  @close="closeDropdown"
                  @select="userSelect($event, props.dataItem, props.field)"
                />
              </div> 
            </td>
          </template>
        </Grid>
      </IntlProvider>
    </LocalizationProvider>
    <!-- Actions -->
    <div class="actions d-flex" style="justify-content: space-between;">
      <v-ons-button v-show="!isPrint" class="btn2-cancel common-style-cancel-button" @click="cancel"
      >キャンセル</v-ons-button>
      <!-- mod 画面部品デザイン定義 修正 chen start -->
      <v-ons-button
        class="btn3-normal common-style-select-button"
        @click="showIndHistoryModal"
        v-if="layout"
      >{{btnHistoryText}}</v-ons-button
      >
      <!-- <v-ons-button -->
      <!--   class="history" -->
      <!--   @click="showIndHistoryModal" -->
      <!--   v-if="layout" -->
      <!--   >{{btnHistoryText}}</v-ons-button -->
      <!-- > -->
      <!-- mod 画面部品デザイン定義 修正 chen end -->
      <!--            mod    FNSI-権限 陳 start-->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <v-ons-button v-show="!isPrint" class="btn1-execute common-style-ok-button" @click="save" :disabled="isDirty || !hasIndReceiveAuthority">保存</v-ons-button> -->
      <v-ons-button
        v-show="!isPrint"
        class="btn1-execute common-style-ok-button"
        @click="save"
        :disabled="isDirty || !getItemAuthorized('IndicationList', 'default_authority')"
      >保存</v-ons-button>
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!--      <v-ons-button class="save" @click="save" :disabled="isDirty">保存</v-ons-button>-->
      <!--            mod    FNSI-権限 陳 end-->
    </div>
    <!-- / Actions -->
  </div>
</template>

<script>
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  import dayjs from "@/compat/date/dayjs";
  import _ from "@/compat/collections/lodash";
  import Indication from "@/apis/indication";

  import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
  import {EventBus} from "@/compat/vue/event-bus.js";
  // mod #10359 編集権限の動作不正 dengshen start
  // import { deepCopy } from "@/functions/common/CommonFunctions";
  import { deepCopy, getAuthorized, getHolidayStyle } from "@/functions/common/CommonFunctions.js";
  // mod #10359 編集権限の動作不正 dengshen end
  // add  FNSI-権限 陳 start
  import {AUTHORITY_CODES} from "@/constants/userAuthority";
  import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
  import {createJournal} from "@/apis/journal";
  // add  FNSI-権限 陳 end
  //FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  import {sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue} from "@/apis/facility-setting";
  //FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
  import store from "@/stores";
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
  // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
  import { messageFormat } from '@/functions/common/MessageFormat';
  import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
  import BigNumber from "@/compat/number/bignumber";
  import okImg from "../../assets/ok.png";
  import { getScopedElementsByClassName, getScopedElementById, getScopedUserAgent, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";
  import { process } from '@progress/kendo-data-query';
  import { Grid } from "@progress/kendo-vue-grid";
  import { LocalizationProvider, IntlProvider, loadMessages } from '@progress/kendo-vue-intl';
  import { SvgIcon } from '@progress/kendo-vue-common';
  import { caretAltDownIcon, caretAltRightIcon } from '@progress/kendo-svg-icons';
  import PrintMixin from "@/components/PrintMixin";
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
  // del #11004 連携イベント発生部分不正 piao start
  // import { sendRequestGetCoopIniSchModifySendClass } from "@/apis/treatment-record";
  // del #11004 連携イベント発生部分不正 piao end
  // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
  const esMessages = {
    grid: {
        groupPanelEmpty: '列名をここにドラッグしてください',
        noRecords: ''
    },
  };

  loadMessages(esMessages, 'es-JP');
  export default {
// mod  FNSI-権限 陳 start
    mixins: [MasterMaintenanceMixin, ComponentGuardMixin, PrintMixin],
    // mixins: [MasterMaintenanceMixin],
// mod  FNSI-権限 陳 end
    name: "IndicationDetailComponent",
    components: {
      Grid,
      LocalizationProvider,
      IntlProvider,
      SvgIcon
    },
    data() {
      return {
// add FNSI redmain_3937 指示受け・指示承認で画面印刷を行うとレイアウトが崩れる dou start
        isPrint: false,
// add FNSI redmain_3937 指示受け・指示承認で画面印刷を行うとレイアウトが崩れる dou end
        okIcon: okImg,
// add  FNSI-権限 陳 start
        hasIndReceiveAuthority: false,
        // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
        treatDate: "",
        // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
// add  FNSI-権限 陳 end
// add 7570 ind_dial連携で送信する項目情報部  赵 start
        // ordNoInit: null,
// add 7570 ind_dial連携で送信する項目情報部  赵 start
        layout: null,
        ordDetail: null,
        patIndApprove: null,
        patPersonal: null,
        checkedData: {},
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
        // selectedStaffCd1: "",
        // selectedStaffCd2: "",
        selectedStaffCd1: '0',
        selectedStaffCd2: '0',
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
        selectedStaffCd1Old: "",
        selectedStaffCd2Old: "",
        isLoading: false,
        loadingMessage: "",
        indicationsUncheckedValue: {},
        dataSources: {},
        editDataSources: [],
        gridHeight: 0,
        initDataSources: [],
// add FNSI redmain_3947 「未チェックのみ表示」の欄にチェックを入れると未保存の内容が表示から消える dou start
        chgDataSources: [],
// add FNSI redmain_3947 「未チェックのみ表示」の欄にチェックを入れると未保存の内容が表示から消える dou end
        gridIndicationColumns: [],
        isIndicationDetailsGridReady: false,
        INDICATIONTYPE: {
          RECEIVER1: "receiver1",
          RECEIVER2: "receiver2",
          APPROVER1: "approver1",
          APPROVER2: "approver2"
        },
        INDICATIONTYPEVALUE: {
          RECEIVER1: 1,
          RECEIVER2: 2,
          APPROVER1: 3,
          APPROVER2: 4
        },
        RECEIVE: "receive",
        groupableMessageEmpty: "列名をここにドラッグしてください",
        SIGN_TYPE: {
          REMOVE: "0",
          SETTING: "1"
        },
        FACILITY_INS_APPTYPE: {
          ONLY_DOCTOR_OPERATION: "1",
          DOCTOR_LIST: "2",
          ALL_USER: "3",
        },
        SELECTED_CHECKBOX: {
          CHECKBOX1: 1,
          CHECKBOX2: 2
        },
        mstUserTreatmentList1: [],
        mstUserTreatmentList2: [],
        isOpenDropdown1: false,
        isOpenDropdown2: false,
        delayObjIosResize: null,
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
        initIsCheckbox1HasValue: false,
        initIsCheckbox2HasValue: false,
        initSelectedStaffCd1: '',
        initSelectedStaffCd2: '',
        ignoreWatchSelectedPatId: false,
        skipRoute: false,
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
        // del #11004 連携イベント発生部分不正 piao start
        // objModSendClass: "",
        // del #11004 連携イベント発生部分不正 piao end
        // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
        // add #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start
        initDataSourcesMap: {},
        // add #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end
        gridGroup: [{ field: 'logTarget' }],
        gridSort: [],
        gridPageSize: 20,
        gridSkip: 0,
        totalCnt: 0,
        allGroupedData: null,
        collapsedItems: [],
        refreshKey: 0,
        editRefreshKey: 0,
        japanese: true,
        gridData: [],
        gridDataRaw: [],
        displayGridData: [],
        sortable: {
          mode: 'multiple'
        },
        displayColumns: [],
        cellTemplate: 'groupHeader',
        collapsedGroups: [[]],
        displayIndex: 0,
        gridSortedList: [],
        tipShow: {
          id: '',
          columnIndex: -1
        },
        staffEdit: {
          id: '',
          columnIndex: -1
        },
        toolTipStyle: {},
        columnsMap: new Map(),
        scrollQuerySelector: ".k-virtual-scrollable-wrap",
        addClassTargetQuerySelector: [".k-auto-scrollable table"],
      };
    },
    computed: {
      ...mapGetters("indication", [
        // #9791 子パンくずリスト押下で画面更新しているが、最新のデータを取得していない。 linjunfeng start
        "sortedIndications",
        // #9791 子パンくずリスト押下で画面更新しているが、最新のデータを取得していない。 linjunfeng end
        "isTreatmentUnit",
        "mstTreatment",
        "mstKur",
        "mstPersonalUser",
        "sortedIndicationsList",
        "selectedIndIndex",
        "userId",
        "isDoctor",
        "indicationsUnchecked",
        "doctorsAtFacility",
        "treatmentIndications",
        "columnStatus",
        "indContent",
        "defaultDoctor",
        "facilityInsApp"
      ]),
      ...mapGetters("user", { facilityCd: "getFacilityCd" }),
      ...mapGetters("pat-info", ["selectedPat", "selectedPatId", "inSelectPatAtPatHeaderCreated"]),
      ...mapGetters("treatment-record/common", ["getOrdNoForSideBarRecord"]),
      // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
      ...mapGetters("account-edit", ["getUserId", "getUserName", "getDefaultSetting", {getFontSize: "getFontSize"}]),
      ...mapGetters("pat-info", ["selectedPat"]),
      // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
      checker1() {
        return this.isApproving ? "指示承認者1" : "指示受け者1";
      },
      isShowChecker1() {
        return this.isApproving ? this.columnStatus.isShowApprover1 : this.columnStatus.isShowChecker1;
      },
      checker2() {
        return this.isApproving ? "指示承認者2" : "指示受け者2";
      },
      isShowChecker2() {
        return this.isApproving ? this.columnStatus.isShowApprover2 : this.columnStatus.isShowChecker2;
      },
      isCheckbox1HasValue: {
        get() {
          return !!this.selectedStaffCd1 && this.selectedStaffCd1 !== "0";
        },
        set() {
        }
      },
      isCheckbox2HasValue: {
        get() {
        return !!this.selectedStaffCd2 && this.selectedStaffCd2 !== "0";
        },
        set() {
        }
      },
      isApproving() {
        return this.$route.name === "indication-approve-detail";
      },
      isReceive() {
        return this.$route.params.method === this.RECEIVE ? true : false;
      },
      isModeIndicationDetails() {
        return this.$route.params.patId ? true : false;
      },
      shouldRenderIndicationDetailsGrid() {
        return this.isModeIndicationDetails && this.isIndicationDetailsGridReady;
      },
      gridHeightValue() {
        return this.gridHeight - 10;
      },
      receiverDataSources() {
        const list = [];
        this.mstPersonalUser?.forEach(user => {
          const item = {
            value: user.userId,
            text: user.userFullName
          };
          list.push(item);
        });
        return list;
      },
      docterDataSources() {
        const list = [];
        this.doctorsAtFacility?.forEach(user => {
          const item = {
            value: user.userId,
            text: user.userFullName
          };
          list.push(item);
        });
        return list;
      },
      btnHistoryText() {
        const text = this.isApproving ? "指示承認履歴" : "指示受け履歴";
        return text;
      },
      isDirty() {
        if (!this.isModeIndicationDetails) {
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
          // return (this.isDirtyApproved1 || this.isDirtyApproved2 || this.isDirtyChecked1 || this.isDirtyChecked2) ? false : true;
          return !(this.initIsCheckbox1HasValue != this.isCheckbox1HasValue || this.initIsCheckbox2HasValue != this.isCheckbox2HasValue ||
              this.initSelectedStaffCd1 != this.selectedStaffCd1 || this.initSelectedStaffCd2 != this.selectedStaffCd2)
        }
        const changedCount = this.statisChangedElem();
        return ((!this.isShowBtnOK && this.isApproving) || !changedCount > 0);
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
      },
      userTreatmentList1() {
        return this.mstUserTreatmentList1;
      },
      userTreatmentList2() {
        return this.mstUserTreatmentList2;
      },
      isShowBtnOK() {
        return (
          this.isDoctor ||
          this.facilityInsApp === this.FACILITY_INS_APPTYPE.ALL_USER ||
          (this.facilityInsApp === this.FACILITY_INS_APPTYPE.DOCTOR_LIST &&
            !this.isDoctor));
      },
      isDisabled() {
        return (
          this.isApproving &&
          !this.isDoctor &&
          this.facilityInsApp === this.FACILITY_INS_APPTYPE.ONLY_DOCTOR_OPERATION);
      },
      isDisabledCheckbox1() {
        return (
          this.isApproving &&
          !this.isDoctor &&
          this.facilityInsApp === this.FACILITY_INS_APPTYPE.ONLY_DOCTOR_OPERATION);
      },
      isDisabledCheckbox2() {
        return (
          this.isApproving &&
          !this.isDoctor &&
          this.facilityInsApp === this.FACILITY_INS_APPTYPE.ONLY_DOCTOR_OPERATION);
      },
      isDisabledDropdown() {
        return (
          this.isApproving &&
          !this.isDoctor &&
          this.facilityInsApp === this.FACILITY_INS_APPTYPE.ONLY_DOCTOR_OPERATION);
      },
      // mod FNSI-7570 劉全航 start
      rstDialysisState(){
        if(this.getOrdNoForSideBarRecord){
          let indication = this.treatmentIndications.find( o => o.ord_no == this.getOrdNoForSideBarRecord);
          return indication.rst_dialysis_state;
        }
      },
      indKurCd(){
        if(this.getOrdNoForSideBarRecord){
          let indication = this.treatmentIndications.find( o => o.ord_no == this.getOrdNoForSideBarRecord);
          return indication.ind_kur_cd;
        }
      },
      // mod FNSI-7570 劉全航 end
      formattedTreatDate(){
        const date = dayjs(this.ordDetail.treatDate, "YYYYMMDD");
        return date.format("YYYY/MM/DD(dd)");   
      },
      isDirtyChecked1() {
        // 指示受け者1(初期値)と指示受け者1(現在値)の値を比較して、チェックボックス又はプルダウンの値に差がある場合trueを返却
        return this.initIsCheckbox1HasValue != this.isCheckbox1HasValue || this.initSelectedStaffCd1 != this.selectedStaffCd1;
      },
      isDirtyChecked2() {
        // 指示受け者2(初期値)と指示受け者2(現在値)の値を比較して、チェックボックス又はプルダウンの値に差がある場合trueを返却
        return this.initIsCheckbox2HasValue != this.isCheckbox2HasValue || this.initSelectedStaffCd2 != this.selectedStaffCd2;
      },
      isDirtyApproved1() {
        // 指示承認者1(初期値)と指示承認者1(現在値)の値を比較して、チェックボックス又はプルダウンの値に差がある場合trueを返却
        return this.initIsCheckbox1HasValue != this.isCheckbox1HasValue || this.initSelectedStaffCd1 != this.selectedStaffCd1;
      },
      isDirtyApproved2() {
        // 指示承認者2(初期値)と指示承認者2(現在値)の値を比較して、チェックボックス又はプルダウンの値に差がある場合trueを返却
        return this.initIsCheckbox2HasValue != this.isCheckbox2HasValue || this.initSelectedStaffCd2 != this.selectedStaffCd2;
      },
      caretAltDownIcon() {
        return caretAltDownIcon;
      },
      caretAltRightIcon() {
        return caretAltRightIcon;
      },
    },
    watch: {
      async $route() {
        this.layout = null;
        this.ordDetail = null;
        this.patIndApprove = null;
        this.patPersonal = null;
        this.checkedData = {};
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
        // this.selectedStaffCd1 = "";
        // this.selectedStaffCd2 = "";
        this.selectedStaffCd1 = '0';
        this.selectedStaffCd2 = '0';
        this.isIndicationDetailsGridReady = false;
        // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end

        if (this.isTreatmentUnit) {
          await this.getIndicationDetail();
          this.convertIndData();
        } else {
          await this.getIndicationDetails();
          this.setIndicationDetailsColumn();
          await this.renderIndicationDetailsGrid();
        }
      },
      getFontSize() {
        // 初期表示時に処理が実施された場合、レイアウトが崩れる為、判定を追加
        if (!(this.dataSources !== null && typeof(this.dataSources) === 'object' && this.dataSources.constructor === Object)) {
          const ownerWindow = getScopedWindow(this.$el) || window;
          const ua = getScopedUserAgent(this.$el);
          if (ua.match(/iPhone|iPad/)) {
            // モバイル環境ではサイズ変更が適用されるまで時間がかかる為の対応
            ownerWindow.setTimeout(() => {
              this.onResize();
            }, 500);
          } else {
            this.onResize();
          }
        }
      },
      indicationsUnchecked: {
        handler() {
          if (!this.shouldRenderIndicationDetailsGrid) return;
          this.sortedIndicationDetails();
        },
        deep: true
      },
      async selectedPatId() {
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
        if (this.ignoreWatchSelectedPatId) return;
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
        const method = this.getCurrentDetailMethod();
        const patId = this.getCurrentDetailPatId();
        const selectedPatId = this.selectedPatId;
        let _id = null;
        if (this.isSelectingCurrentPatAtPatHeaderCreated()) return;
        // indication screen
        if (!this.isTreatmentUnit) {
          if (selectedPatId !== null && String(selectedPatId) !== String(patId)) {
            this.sortedIndicationsList?.forEach(item => {
              if (String(item.patId) === String(selectedPatId)) {
                _id = item._id;
              }
            });
            // replace new patient id
            if (_id !== null) {
              // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
              if (await this.confirmContentChanged()) {
                await this.$router.replace({
              // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
                  name: `indication-${method}-details`,
                  params: {
                    patId: selectedPatId,
                    _id: _id,
                    method: method
                  }
                });
              // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
              } else {
                this.ignoreWatchSelectedPatId = true;
                await this.setSelectedPatHeader(patId);
                this.ignoreWatchSelectedPatId = false;
              }
              // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
            }
          }
        } else {
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
          const currentOrdNo = this.$route.params.ordNo;
          if (this.getOrdNoForSideBarRecord !== currentOrdNo && await this.confirmContentChanged()) {
            await this.$router.replace({
          // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
              name: `indication-${method}-detail`,
              params: {
                ordNo: this.getOrdNoForSideBarRecord,
                method: method
              }
            });
          // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
          } else {
            this.ignoreWatchSelectedPatId = true;
            await this.setSelectedPatHeader(this.ordDetail.patId);
            await this.setOrdNoForSideBarRecord(currentOrdNo);
            this.ignoreWatchSelectedPatId = false;
            await this.getPatPersonal(this.ordDetail.patId)
          }
          // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
        }
      },
      gridGroup: {
        handler() {
          this.collapsedItems = [];
          this.allGroupedData = process(this.displayGridData, {
            group: this.gridGroup,
            sort: this.gridSort
          });
          this.gridSortedList = this.expandedArr(this.allGroupedData.data);
        }
      },
      gridSort: {
        handler() {
          this.allGroupedData = process(this.displayGridData, {
            group: this.gridGroup,
            sort: this.gridSort
          });
          this.gridSortedList = this.expandedArr(this.allGroupedData.data);
        }
      },
    },
    methods: {
      ...mapActions("mst-holiday", [
        "fetchHolidays",
        "clearHolidays"
      ]),
      /** 画面印刷の処理 */
      handleBeforePrint() {
        if (!this.isModeIndicationDetails) return;

        const wrap = (this.$el || document).querySelector(".k-virtual-scrollable-wrap");
        if (!wrap) return;

        const scrollTop = wrap.scrollTop;
        const height = wrap.clientHeight || wrap.offsetHeight;
        wrap.style.overflow = "visible";
        wrap.style.clipPath = `inset(${scrollTop}px 0 0 0)`;
        wrap.style.marginTop = `-${scrollTop}px`;
        wrap.style.height = `${height}px`;
      },
      handleAfterPrint() {
        if (!this.isModeIndicationDetails) return;

        const wrap = (this.$el || document).querySelector(".k-virtual-scrollable-wrap");
        if (!wrap) return;

        wrap.style.overflow = "";
        wrap.style.clipPath = "";
        wrap.style.marginTop = "";
        wrap.style.height = "";
      },
      userSelect(e, item, indicationType) {
        this.onClickUpdateDetails(item, indicationType, e.dataItem.userId, e.dataItem.userFullName);
      },
      closeDropdown() {
        this.staffEdit = {
          id: '',
          columnIndex: -1
        }
        this.editRefreshKey++;
      },
      triggerToEdit(dataItem, columnIndex) {
        if(!this.hasIndReceiveAuthority) {
          // 編集不可
          return;
        }
        if(dataItem._id) {
          this.staffEdit = {
            id: dataItem._id,
            columnIndex: columnIndex
          };
          // Vue3 compat: kendo-dropdownlist は KendoDropDownList.open() で開く（旧 .k-dropdown クリックは効かない）
          this.$nextTick(() => {
            const dropListRef = this.$refs.dropList;
            const dropList = Array.isArray(dropListRef)
              ? dropListRef[dropListRef.length - 1]
              : dropListRef;
            if (dropList?.open) {
              dropList.open();
              return;
            }
            const selectBox = this.$el?.querySelector?.(".select-box");
            const legacyTrigger = selectBox?.querySelector?.(
              ".k-dropdown .k-select, .k-dropdownlist .k-input-button, .k-input-button"
            );
            legacyTrigger?.click?.();
          });
        }
      },
      clearTipShow() {
        this.tipShow = {
          id: '',
          columnIndex: -1
        };
        this.toolTipStyle = {};
      },
      isTipShowCell(dataItem, columnIndex) {
        return (
          dataItem?._id != null &&
          String(this.tipShow.id) === String(dataItem._id) &&
          this.tipShow.columnIndex === columnIndex
        );
      },
      handleMouseEnter(event, dataItem, columnIndex, columnsCount) {
        const element = event.currentTarget;
        if (!dataItem?._id || !element) {
          return;
        }
        if (element.scrollWidth <= element.clientWidth) {
          if (this.isTipShowCell(dataItem, columnIndex)) {
            this.clearTipShow();
          }
          return;
        }
        this.tipShow = {
          id: dataItem._id,
          columnIndex: columnIndex
        };
        const cellId = dataItem._id;
        const cellColumnIndex = columnIndex;
        this.$nextTick(() => {
          if (
            String(this.tipShow.id) !== String(cellId) ||
            this.tipShow.columnIndex !== cellColumnIndex
          ) {
            return;
          }
          const tooltip = this.$el?.querySelector('.omit-tip');
          if (!tooltip) {
            return;
          }
          const tooltipRect = tooltip.getBoundingClientRect();
          const leftWidth = (tooltipRect.width * -1) + 'px';
          const firstId = this.gridSortedList?.[0]?._id ?? '';
          if (String(dataItem._id) === String(firstId)) {
            if (columnIndex === columnsCount - 1) {
              this.toolTipStyle = {
                'margin-left': leftWidth
              };
            } else {
              this.toolTipStyle = {};
            }
          } else if (columnIndex === columnsCount - 1) {
            this.toolTipStyle = {
              'margin-top': '-60px',
              'margin-left': leftWidth
            };
          } else {
            this.toolTipStyle = {
              'margin-top': '-60px'
            };
          }
        });
      },
      handleMouseLeave(dataItem, columnIndex) {
        if (this.isTipShowCell(dataItem, columnIndex)) {
          this.clearTipShow();
        }
      },
      getNestedValue(fieldName, dataItem) {
        const path = fieldName.split('.');
        let data = dataItem;
        path?.forEach((p) => {
            data = data ? data[p] : undefined;
        });
        return data;
      },
      clickHandler(props) {
        props.dataItem.expanded = props.dataItem.expanded === undefined ? false : !props.dataItem.expanded;
        this.handleExpandedItems(props.dataItem.field, props.dataItem.value, props.dataItem.items, props.dataItem.expanded);
        this.initGridData(this.allGroupedData.data);
        this.refreshExpanded(this.allGroupedData.data);
        props.value = props.dataItem.expanded;
        props.expanded = props.dataItem.expanded;
        // this.collapsedGroups = this.$refs.grid.updateGroupCollapsed(props);
        this.processGridData(1);
        // ここで refreshKey++ すると :dataItemKey が全行一括で変わり Grid が実質フル再マウントする。
        // 展開/畳みは processGridData + collapsedGroups で足りるため付けない。
      },
      columnReorder(options) {
        this.displayColumns = options.columns;
        this.refreshKey++;
      },
      sortChangeHandler(e) {
        this.gridSort = e.sort;
        this.processGridData(0);
      },
      onDataStateChange(event) {
        this.gridGroup = event.data.group || [];
        this.gridSort = event.data.sort || [];
        this.gridSkip = event.data.skip || 0;
        this.processGridData(0);
      },
      computedDisplaySize(items, totalCnt) {
        if(items) {
          for(let i = 0; i < items.length; i++) {
            const detailInfo = items[i];
            if (!detailInfo.items) {
              totalCnt++;
            } else if(!detailInfo.items[0].items) {
              totalCnt = totalCnt + detailInfo.items.length;
            } else if(detailInfo.expanded !== false) {
              totalCnt = this.computedDisplaySize(detailInfo.items, totalCnt);
            } else {
              totalCnt = totalCnt + 1;
            }
          }
        }
        return totalCnt;
      },
      handleGroupData(skip, to) {
        const keyMap = new Map();
        this.displayIndex = 0;
        this.handleGroupDataDetails(this.allGroupedData.data, keyMap, '');
        return this.queryGroupDataResult(this.allGroupedData.data, keyMap, skip, to);
      },
      queryGroupDataResult(items, keyMap, skip, to) {
        if(!items || items.length === 0) {
          return -1;
        }
        let endIndex = skip + to - 1;
        if(endIndex >= keyMap.size) {
          endIndex = keyMap.size - 1;
        }
        const lastItem = keyMap.get(endIndex);
        const tempArr = lastItem.split('-');
        let tempItems = items;
        let uniqueId = '';
        for(let i = 0; i < tempArr.length; i++) {
          const tempKey = tempArr[i] + '';
          if(tempItems[tempKey].items) {
            tempItems = tempItems[tempKey].items;
          } else {
            uniqueId = tempItems[tempKey]._id;
          }
        }
        if(uniqueId === '') {
          let subItem = tempItems[0];
          while(subItem.items) {
            subItem = subItem.items[0];
          }
          uniqueId = subItem._id;
        }
        if(uniqueId) {
          return this.gridSortedList.findIndex(el => el._id === uniqueId)
        }
        return -1;
      },
      initGridData(items) {
        if(items) {
          for(let i = 0; i < items.length; i++) {
            if(items[i].items) {
              items[i].expanded = true;
              this.initGridData(items[i].items);
            }
          }
        }
      },
      expandedArr(items) {
        let tempArr = [];
        for(let i = 0; i < items.length; i++) {
          if(items[i].items && !items[i].items[0].items) {
            tempArr = tempArr.concat(items[i].items);
          } else {
            if(items[i].items) {
              const resultArr = this.expandedArr(items[i].items);
              tempArr = tempArr.concat(resultArr);
            }
          }
        }
        return tempArr;
      },
      handleGroupDataDetails(items, keyMap, keyValue) {
        for(let i = 0; i < items.length; i++) {
          const saveValue = keyValue !== '' ? keyValue + '-' + i : '' + i;
          const detailInfo = items[i];
          if(detailInfo.items) {
            if(detailInfo.expanded === false) {
              keyMap.set(this.displayIndex, saveValue);
              this.displayIndex++;
            } else {
              this.handleGroupDataDetails(detailInfo.items, keyMap, saveValue);
            }
          } else {
            keyMap.set(this.displayIndex, saveValue);
            this.displayIndex++;
          }
        }
      },
      processGridData(expandFlag) {
        if(expandFlag !== 1) {
          this.refreshExpanded(this.allGroupedData.data);
        }
        // 分组 + 仮想スクロール時、Kendo Grid は virtualPageChange で pagechange を出さず
        // 内部 _virtualSkipRef のみ更新するため、親の gridSkip が動かず skip/take 切片が常に先頭のままになる。
        // kendo-data-query の process に skip/take を渡さないと全件のグループ木が返り、Grid 側の仮想化でスクロールできる。
        const hasGroup =
          Array.isArray(this.gridGroup) && this.gridGroup.length > 0;
        let result;
        if (hasGroup) {
          this.gridSkip = 0;
          result = process(this.displayGridData, {
            group: this.gridGroup,
            sort: this.gridSort
          });
        } else {
          let tempTake = this.handleGroupData(this.gridSkip, this.gridPageSize);
          if (tempTake !== -1) {
            tempTake = tempTake - this.gridSkip + 1;
          } else {
            tempTake = this.gridPageSize;
          }
          result = process(this.displayGridData, {
            group: this.gridGroup,
            sort: this.gridSort,
            skip: this.gridSkip,
            take: tempTake
          });
        }
        this.gridData = result.data;
        this.totalCnt = result.total;

        this.refreshExpanded(this.gridData);
      },
      refreshExpanded(handleExpandGrid) {
        if(this.collapsedItems) {
          for(let i = 0; i < this.collapsedItems.length; i++) {
            const handleItem = this.collapsedItems[i];
            if(handleItem) {
              let indexItem = null;
              for(let subIndex = 0; subIndex < handleItem.length; subIndex++) {
                const itemInfo = handleItem[subIndex];
                if(subIndex === 0) {
                  indexItem = this.handleRefreshExpandedDetail(itemInfo, handleExpandGrid);
                } else if(indexItem) {
                  indexItem = this.handleRefreshExpandedDetail(itemInfo, indexItem.items);
                }
                if(indexItem && subIndex === handleItem.length - 1) {
                  indexItem.expanded = false;
                }
                if(!indexItem) {
                  break;
                }
              }
            }
          }
        }
      },
      handleRefreshExpandedDetail(itemInfo, items) {
        let index = items.findIndex(el => el.field === itemInfo.field && el.value === itemInfo.value);
        if(index === -1) {
          return null;
        } else {
          return items[index];
        }
      },
      handleExpandedItems(field, value, items, flag) {
        const item = this.findFirstItem(items);
        const handleIndex = this.gridGroup.findIndex(el => el.field === field);
        const preFields = this.gridGroup.slice(0, handleIndex);
        let saveFields = [];
        if(preFields) {
          preFields?.forEach(el => {
            saveFields.push({
              field: el.field,
              value: item[el.field]
            });
          });
        }
        saveFields.push({
          field: field,
          value: value
        });
        if(!flag) {
          // 畳む
          this.collapsedItems.push(saveFields);
        } else {
          let tmepCollapsedItems = []; 
          let index = this.collapsedItems?.forEach(el => {
            if(el.length === saveFields.length) {
              let isEqual = true;
              for(let i = 0; i < el.length; i++) {
                if(el[i].value !== saveFields[i].value) {
                  isEqual = false;
                  break;
                }
              }
              if(!isEqual) {
                tmepCollapsedItems.push(el);
              }
            } else {
              tmepCollapsedItems.push(el);
            }
          });
          this.collapsedItems = tmepCollapsedItems;
        }
      },
      findFirstItem(items) {
        if(items[0].hasOwnProperty('items')) {
          return this.findFirstItem(items[0].items);
        } else {
          return items[0];
        }
      },
      groupchange(event) {
        let isExistFlag = false;
        const stringSet = new Set();
        event.group?.forEach(el => {
          if(!stringSet.has(el.field)) {
            stringSet.add(el.field);
          } else {
            isExistFlag = true;
          }
        })
        if(!isExistFlag) {
          this.gridGroup = event.group;
          this.processGridData(0);
        }
        this.collapsedGroups = Array.from({ length: this.gridGroup.length }, () => []);
      },
      // add #10359 編集権限の動作不正 dengshen start
      getItemAuthorized(pageCd, itemCd) {
        return getAuthorized(pageCd, itemCd);
      },
      // add #10359 編集権限の動作不正 dengshen end

      getCurrentDetailMethod() {
        const paramsMethod = this.$route.params?.method;
        if (paramsMethod) {
          return paramsMethod;
        }
        const routeName = String(this.$route.name || "");
        if (routeName.includes("approve")) {
          return this.APPROVE;
        }
        if (routeName.includes("receive")) {
          return this.RECEIVE;
        }
        const routePath = String(this.$route.path || "");
        if (routePath.includes("/detail/approve/")) {
          return this.APPROVE;
        }
        if (routePath.includes("/detail/receive/")) {
          return this.RECEIVE;
        }
        return "";
      },
      getCurrentDetailPatId() {
        if (this.$route.params?.patId != null) {
          return this.$route.params.patId;
        }
        return null;
      },
      isSelectingCurrentPatAtPatHeaderCreated() {
        if (!this.inSelectPatAtPatHeaderCreated || this.selectedPatId == null) {
          return false;
        }
        const currentPatId = this.getCurrentDetailPatId();
        return currentPatId != null && String(this.selectedPatId) === String(currentPatId);
      },
      hasIndicationDetailIds(paramsId) {
        if (Array.isArray(paramsId)) {
          return paramsId.length > 0;
        }
        return paramsId !== null && paramsId !== undefined && paramsId !== "";
      },
      resolveIndicationDetailIds() {
        let paramsId = this.$route.params._id;
        const routePatId = this.$route.params.patId;
        const sortedIndicationsDetailInfo = this.sortedIndications.find(item => String(item.patId) === String(routePatId));
        if (sortedIndicationsDetailInfo) {
          paramsId = sortedIndicationsDetailInfo._id;
        }
        return paramsId;
      },

      async renderIndicationDetailsGrid() {
        this.isIndicationDetailsGridReady = true;
        await this.$nextTick();
        await this.sortedIndicationDetails();
      },

      //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
      getTreatMethod(subCategory) {
        let prefix = subCategory.itemInfo.data.value.prefix !== null ? subCategory.itemInfo.data.value.prefix : "";
        let dispVal = subCategory.itemInfo.data.value.dispVal !== null ? subCategory.itemInfo.data.value.dispVal : "未登録";
        return prefix + dispVal;
      },
      getLeftTreatMethod(subCategoryNo) {
        let value = this.checkedData[`${subCategoryNo}0`]?.data.value;
        let prefix = value.prefix !== null ? value.prefix : "";
        let dispVal = value.dispVal !== null ? value.dispVal : "未登録";
        return prefix + dispVal;
      },
      //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

      //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
      getItemValue(item, subCategoryNo) {
        if ((item.itemNo === 20 && item.data.value.dispVal === "-1" && item.data.value.unit === "L")
          || (item.itemNo === 24 && item.data.value.dispVal === "-1" && item.data.value.unit === "L/h")) {
          return "濾過率から算出";
        } else {
          let prefix = item.data.value.prefix ? item.data.value.prefix : "";
          let dispVal = item.data.value.dispVal ? item.data.value.dispVal : "未登録";
          let unit = item.data.value.unit ? item.data.value.unit : "";
          if (4 === subCategoryNo && [2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 19, 25].includes(item.itemNo)) {
            unit = "";
          }
          let leftIsDisable = this.checkedData[`${subCategoryNo}${item.itemNo}`]?.data.isDisable || false;
          let rightIsDisable = item.data.isDisable || false;
          // let res = unit ? `${prefix}${dispVal} ${unit}` : `${prefix}${dispVal}`;
          let res = unit && "DWと同じ" !== dispVal ? `${prefix}${dispVal} ${unit}` : `${prefix}${dispVal}`;
          if (res === '未登録' && !leftIsDisable && rightIsDisable) {
            res = '(未登録)';
          }
          return res;
        }
      },
      getLeftItemValue(itemInfo, subCategoryNo) {
        let subCategoryItems = this.checkedData[`${subCategoryNo}${itemInfo.itemNo}`];
        if (subCategoryItems == null) {
          return '(新規)';
        }
        let value = subCategoryItems.data.value;
        const rstDialysisState = this.ordDetail.rstDialysisState;
        if (value == null) {
          return '(新規)';
        }
        let prefix = value.prefix ? value.prefix : "";
        let dispVal = value.dispVal;
        let unit = value.unit ? " " + value.unit : "";

        if ((itemInfo.itemNo === 20 && dispVal === "-1" && value.unit === "L")
          || (itemInfo.itemNo === 24 && dispVal === "-1" && value.unit === "L/h")) {
          return "濾過率から算出";
        }

        let val = `${prefix}${dispVal}`;
        let res;
        // if (rstDialysisState === "0") {
          if (val && val === '未登録') {
            res = val;
          } else {
            if (4 === subCategoryNo && [2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 19, 25].includes(itemInfo.itemNo)) {
              res = val ? val : '(新規)';
            } else {
              res = val ? val + `${unit && "DWと同じ" !== dispVal ? " " + unit : ""}` : '(新規)';
            }
          }
        // } else {
        //   res = val ? val : '(新規)';
        // }

        let leftIsDisable = this.checkedData[`${subCategoryNo}${itemInfo.itemNo}`]?.data.isDisable || false;
        let rightIsDisable = itemInfo.data.isDisable || false;
        if (res === '未登録' && leftIsDisable && !rightIsDisable) {
          res = '(未登録)';
        }

        return res;
      },
      //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
      // 共通ローダー設定
      // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start
      // ...mapActions("loading-screen", {
      //   setLoadingScreenVisible: "setLoadingScreenVisible",
      //   setLoadingScreenMessage: "setLoadingScreenMessage",
      //   resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
      // }),
      ...mapActions("loading-screen", [
        "startLoadingScreen",
        "finishLoadingScreen",
      ]),
      // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end
      ...mapActions("treatment-record/common", {
        setOrdNoForSideBarRecord: "setOrdNoForSideBarRecord"
      }),
      // #9791 子パンくずリスト押下で画面更新しているが、最新のデータを取得していない。 linjunfeng start
      ...mapActions("indication", [
        "getIndications",
      ]),
      // #9791 子パンくずリスト押下で画面更新しているが、最新のデータを取得していない。 linjunfeng end
      //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
      requestrReportParams(param) {
        // 機能コード判定
        // del #9558機能帳票でパラメータが正しく渡されていない 杜天成 start
        // if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // del #9558機能帳票でパラメータが正しく渡されていない 杜天成 end
        // add #11256 機能帳票の印刷情報対応① limingzhe start
        let dateTodate = dayjs(Date.now()).format('YYYYMMDD');
        if(this._data.treatDate != null && this._data.treatDate != ''){
          dateTodate = dayjs(this._data.treatDate).format('YYYYMMDD');
        }else if(this.treatmentIndications[0] != undefined){
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない 高 start
          // if(this.initDataSources[0].logDate != null && this.initDataSources[0].logDate != "") dateTodate = dayjs(this.initDataSources[0].logDate).format('YYYYMMDD');
          if(this.initDataSources[0].logDate != null && this.initDataSources[0].logDate != "") dateTodate = dayjs(this.initDataSources[0].logDate.substring(0,8)).format('YYYYMMDD');
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない 高 end
          else if(this.initDataSources[0].treatmentStartDate != null && this.initDataSources[0].treatmentStartDate != "") dateTodate = dayjs(this.initDataSources[0].treatmentStartDate).format('YYYYMMDD');
        }
        // add #11256 機能帳票の印刷情報対応① limingzhe end
          const param1 = {
            patId: this.selectedPatId,
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
            //patIds: this.searchedPatList != null ? this.searchedPatList.map(({ pat_id }) => pat_id) :[],
            facilityCd: this.facilityCd,
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
            //dialysisDate: dateTodate,
            // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
            functionCd:'02801',
// mod #9558 fromDate、toDate が当日ではなく治療日が使われている 杜 start
            //date:null != this.ordDetail ? dayjs(this.ordDetail.treatDate).format('YYYY/MM/DD') : dayjs(Date.now()).format('YYYY/MM/DD'),
            //fromDate:null != this.ordDetail ? dayjs(this.ordDetail.treatDate).format('YYYY/MM/DD')  : dayjs(Date.now()).format('YYYY/MM/DD'),
            //toDate: null != this.ordDetail ? dayjs(this.ordDetail.treatDate).format('YYYY/MM/DD') : dayjs(Date.now()).format('YYYY/MM/DD'),
            // mod #11256 機能帳票の印刷情報対応① limingzhe start
            //date: this._data.treatDate == '' ? dayjs(this.initDataSources[0].treatmentStartDate).format('YYYY/MM/DD') : dayjs(this._data.treatDate).format('YYYY/MM/DD'),
            date: dateTodate,
            // mod #11256 機能帳票の印刷情報対応① limingzhe end
            fromDate: dayjs(Date.now()).format('YYYY/MM/DD'),
            toDate: dayjs(Date.now()).add(1, 'months').format('YYYY/MM/DD'),
// mod #9558 fromDate、toDate が当日ではなく治療日が使われている 杜 end
          };
          EventBus.$emit("sendReportParams", param1);
        // }
      },
//add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
// add  FNSI-権限 陳 start
      // 權限を取得する
      getIndReceiveAuthority() {
        return this.hasAuthorityByCd(AUTHORITY_CODES.IND_RECEIVE_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.IND_RECEIVE_EDIT);
      },
// add  FNSI-権限 陳 end
      ...mapActions("bread-crumb", ["resetTitle"]),
      ...mapActions("indication", [
        "getPatPersonal", "setIndicationsUnchecked", "setIndContent"
      ]),
      ...mapActions("multi-modal", ["showIndicationsHistoryModal"]),
      async getIndicationDetail() {
        try {
          this.startLoading("指示情報を取得しています");
          const ordNo = this.$route.params.ordNo;
          const [[ordDetail, patIndApprove]] = await Promise.all([Indication.getIndicationDetail(ordNo)]);
          //#10407:変更なしでも画面を表示させる Start
          if (patIndApprove != undefined && patIndApprove != null) {
            //#10407:変更なしでも画面を表示させる End
            // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
            this.treatDate = ordDetail.treatDate;
            // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end

            const selectedStaffCd1 = this.isApproving
              ? patIndApprove.approve_user1_cd
              : patIndApprove.check_user1_cd;
            // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
            //this.selectedStaffCd1 = selectedStaffCd1 ? selectedStaffCd1 + "" : null;
            this.selectedStaffCd1 = selectedStaffCd1 ? selectedStaffCd1 + "" : '0';
            // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
            this.selectedStaffCd1Old = this.selectedStaffCd1;

            const selectedStaffCd2 = this.isApproving
              ? patIndApprove.approve_user2_cd
              : patIndApprove.check_user2_cd;
            // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
            //this.selectedStaffCd2 = selectedStaffCd2 ? selectedStaffCd2 + "" : null;
            this.selectedStaffCd2 = selectedStaffCd2 ? selectedStaffCd2 + "" : '0';
            // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
            this.selectedStaffCd2Old = this.selectedStaffCd2;

            ordDetail.indCondInfo = JSON.parse(ordDetail.indCondInfo);
            ordDetail.indMediInfo = JSON.parse(ordDetail.indMediInfo);
            ordDetail.indEquipInfo = JSON.parse(ordDetail.indEquipInfo);
            ordDetail.indIndCommentInfo = JSON.parse(ordDetail.indIndCommentInfo);
            ordDetail.indScheduleUserInfo = JSON.parse(
              ordDetail.indScheduleUserInfo);
            this.ordDetail = ordDetail;

            patIndApprove.check_content = this.parsePatIndApproveContent(patIndApprove.check_content);
            patIndApprove.approve_content = this.parsePatIndApproveContent(patIndApprove.approve_content);
            this.patIndApprove = patIndApprove;

            await this.getPatPersonal(this.ordDetail.patId);
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
            await this.initDataValue();
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
            //#10407:変更なしでも画面を表示させる Start
          }
          //#10407:変更なしでも画面を表示させる End
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('IndicationDetailComponent.vue', 'getIndicationDetail', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          this.internalServerError(error);
        }

        this.stopLoading();
      },
      async convertIndData() {
        if (!this.ordDetail) {
          return;
        }

        this.startLoading("レイアウトを表示しています。");
        await this.setIndContent({ordDetail: this.ordDetail});
        this.layout = this.indContent;
        if (this.patIndApprove) {
          const contentKey = this.isApproving ? 'approve_content' : 'check_content';
          this.mergeCancelledData(contentKey);
          this.convertCheckedData(contentKey);
        }
        this.stopLoading();
      },
      parsePatIndApproveContent(rawContent) {
        if (rawContent == null || rawContent === '') {
          return [];
        }
        try {
          const parsed = typeof rawContent === 'string' ? JSON.parse(rawContent) : rawContent;
          return Array.isArray(parsed) ? parsed : [];
        } catch {
          return [];
        }
      },
      getPatIndApproveContentList(content) {
        if (!this.patIndApprove) {
          return null;
        }
        const contentList = this.patIndApprove[content];
        return Array.isArray(contentList) ? contentList : null;
      },
      convertCheckedData(content) {
        const contentList = this.getPatIndApproveContentList(content);
        if (!contentList?.length) {
          return;
        }
        contentList?.forEach(
          ({itemInfo, subCategoryItem, subCategoryNo}) => {
            if (subCategoryNo === 2) {
              this.checkedData[`${subCategoryNo}0`] = itemInfo;
            } else if (subCategoryNo === 6) {
              subCategoryItem?.forEach((e) => {
                e.itemInfo.itemNo = e.itemInfo.itemCd;
                this.checkedData[`${subCategoryNo}${e.itemInfo.itemCd}`] = e.itemInfo;
              });
            } else {
              subCategoryItem?.forEach((e) => {
                let itemNo = e.itemInfo.itemNo;
                this.checkedData[`${subCategoryNo}${itemNo}`] = e.itemInfo;
              });
            }
          });
      },
      mergeCancelledData(content) {
        const contentList = this.getPatIndApproveContentList(content);
        if (!contentList?.length || !Array.isArray(this.layout)) {
          return;
        }
        // 中止した投与薬剤/医療材料/指示コメントをlayoutにマージする
        // this.patIndApprove: pat_ind_approve(指示受け承認情報) -> 中止前のデータ
        // this.layout       : ord_main(治療情報)                -> 中止後のデータ（画面表示内容）
        this.layout?.forEach((subCategory) => {
          if ([5, 6, 7].includes(subCategory.subCategoryNo)) {
            const currentSubCategory = contentList.filter(item => item.subCategoryNo === subCategory.subCategoryNo) || [];
            const itemNoSet = new Set((subCategory.subCategoryItem ?? []).map(item => item.itemInfo.itemNo));//O(n) → O(1)
            const cancelledItems = currentSubCategory[0]?.subCategoryItem;
            if (cancelledItems?.length > 0) {
              cancelledItems?.forEach((e) => {
                const itemIdx = 6 === subCategory.subCategoryNo ? e.itemInfo.itemCd : e.itemInfo.itemNo;
                if (!itemNoSet.has(itemIdx)) {
                  if (!Array.isArray(subCategory.subCategoryItem)) {
                    subCategory.subCategoryItem = [];
                  }
                  subCategory.subCategoryItem.push({
                    itemInfo: {
                      itemName: e.itemInfo.itemName,
                      itemNo: 6 === subCategory.subCategoryNo ? e.itemInfo.itemCd : e.itemInfo.itemNo * -1,
                      itemCd: e.itemInfo.itemCd,
                      itemType: e.itemInfo.itemType,
                      status: 2,  // 中止 ※治療状況リスト・マップ > 指示変更内容の実装と合わせる
                      data: {...e.itemInfo.data}
                    }
                  });
                }
              });
            }
          }
        })
      },
      async cancel() {
        this.$router.push({ name: "indication" });
      },
      async save() {
        //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
        // add 11763 指示受け・指示承認画面（指示単位）の動作不正① zkm start
        if (this.isTreatmentUnit) {
          // add 11763 指示受け・指示承認画面（指示単位）の動作不正① zkm end
          let rstDialysisState = this.ordDetail.rstDialysisState;
          // 医療材料
          this.layout?.forEach(item => {
            if (6 === item.subCategoryNo) {
              item.subCategoryItem?.forEach(subCategory => {
                subCategory.itemInfo.itemNo = null;
              })
            }
          });
          if (rstDialysisState === "0") {
            this.layout?.forEach((item) => {
              if (2 === item.subCategoryNo) {
                item.itemInfo.data.value.unit = null;
                item.itemInfo.data.value.prefix = null;
                item.itemInfo.data.value.dispVal = null;
              }
              // スケジュール
              else if (3 === item.subCategoryNo) {
                item.subCategoryItem?.forEach(subCategory => {
                  // 1: クール
                  // 3: ベッド
                  if ([1,3].includes(subCategory.itemInfo.itemNo)) {
                    subCategory.itemInfo.data.value.unit = null;
                    subCategory.itemInfo.data.value.prefix = null;
                    subCategory.itemInfo.data.value.dispVal = null === subCategory.itemInfo.itemCd || 0 === subCategory.itemInfo.itemCd ? "未登録" : null;
                  }
                })
              }
              // 治療条件
              else if (4 === item.subCategoryNo) {
                item.subCategoryItem?.forEach(subCategory => {
                  subCategory.itemInfo.data.value.unit = null;
                  // 2:  VA
                  // 5:  ダイアライザ
                  // 6:  吸着カラム
                  // 7:  1次膜
                  // 8:  2次膜
                  // 9:  穿刺針(A針)
                  // 10: 穿刺針(V針)
                  // 11: 穿刺針(SN)
                  // 13: 血液回路
                  // 15: 透析液
                  // 19: 補液
                  // 25: 抗凝固剤
                  if ([2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 19, 25].includes(subCategory.itemInfo.itemNo)) {
                    subCategory.itemInfo.data.value.dispVal = null === subCategory.itemInfo.itemCd ? "未登録" : null;
                    subCategory.itemInfo.data.value.prefix = null;
                  }
                })
              }
              // 投与薬剤、医療材料
              else if ([5, 6].includes(item.subCategoryNo)) {
                item.subCategoryItem?.forEach(subCategory => {
                  subCategory.itemInfo.data.value.unit = null;
                  subCategory.itemInfo.data.value.prefix = null;
                })
              }
            });
          }
          // add 11763 指示受け・指示承認画面（指示単位）の動作不正① zkm start
        }
        // add 11763 指示受け・指示承認画面（指示単位）の動作不正① zkm end
        //add #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

        //add 吉 start
        let flag = null;
        //add 吉 end
        if (this.layout) {
          this.startLoading(
            this.isApproving ? "承認しています。" : "指示を確認しています。");

          // layoutにmergeCancelledData()でマージした投与薬剤/医療材料/指示コメントの中止データを取り除く
          this.layout?.forEach((subCategory) => {
            if ([5, 6, 7].includes(subCategory.subCategoryNo)) {
              subCategory.subCategoryItem = (subCategory.subCategoryItem ?? []).filter((item) => {
                return item.itemInfo.status !== 2;
              });
            }
          });

          try {
            const ordNo = this.$route.params.ordNo;
            let approveKind = [];
            let approveAftId = [];
            let signType = [];
            //add 吉 start
            flag = this.isApproving;
            //add 吉 end
            if (this.isApproving) {
              await Indication.approve(ordNo, {
                approver1Id: +this.selectedStaffCd1 || null,
                approver2Id: +this.selectedStaffCd2 || null,
                approveContent: JSON.stringify(this.layout)
              });
              if (this.isDirtyApproved1) {
                this.saveHistoryIndication(
                  this.isCheckbox1HasValue ,
                  approveKind,
                  this.INDICATIONTYPEVALUE.APPROVER1,
                  approveAftId,
                  this.selectedStaffCd1,
                  signType ,)
              }
              if (this.isDirtyApproved2) {
                this.saveHistoryIndication(
                  this.isCheckbox2HasValue ,
                  approveKind,
                  this.INDICATIONTYPEVALUE.APPROVER2,
                  approveAftId,
                  this.selectedStaffCd2,
                  signType ,)
              }

            } else {
              await Indication.check(ordNo, {
                checker1Id: +this.selectedStaffCd1 || null,
                checker2Id: +this.selectedStaffCd2 || null,
                checkContent: JSON.stringify(this.layout)
              });
              if (this.isDirtyChecked1) {
                this.saveHistoryIndication(
                  this.isCheckbox1HasValue ,
                  approveKind,
                  this.INDICATIONTYPEVALUE.RECEIVER1,
                  approveAftId,
                  this.selectedStaffCd1,
                  signType ,)
              }
              if (this.isDirtyChecked2) {
                this.saveHistoryIndication(
                  this.isCheckbox2HasValue ,
                  approveKind,
                  this.INDICATIONTYPEVALUE.RECEIVER2,
                  approveAftId,
                  this.selectedStaffCd2,
                  signType ,)
              }
            }
            await this.insertIndApproveHistory(
              [ordNo],
              this.userId,
              approveKind,
              approveAftId,
              signType);
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
            this.skipRoute = true;
            // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
            this.$router.push({
              name: "indication"
            });
          } catch (error) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('IndicationDetailComponent.vue', 'save', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.internalServerError(error);
          }
          this.stopLoading();
        } else {
          //add 吉 start
          flag = !this.isReceive;
          //add 吉 end
          this.startLoading(
            this.isReceive ? "指示を確認しています。" : "承認しています。");
          // mod #10413 指示受け画面にて特定の操作を実施するとコンソールエラーが出て保存することができない linjunfeng start
          // await Indication.updIndHistoryDetail(this.editDataSources);
          let editNewData = [];
          this.editDataSources?.forEach((item)=>{
            // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start
            // const initDataSources = this.chgDataSources.find(ele => ele._id == item._id);
            const initDataSources = this.initDataSources.find(ele => ele._id == item._id);
            // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end
            if (initDataSources[this.getIndicationValue(item.indicationType)] != item.userId) {
              editNewData.push(item)
            }
          })
          await Indication.updIndHistoryDetail(editNewData);
          // mod #10413 指示受け画面にて特定の操作を実施するとコンソールエラーが出て保存することができない linjunfeng end
          this.stopLoading();
          // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
          this.skipRoute = true;
          // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
          this.$router.push({ name: "indication" });
        }
        // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
        //mod 吉 start
        // this.callCreateJournal();
        this.callCreateJournal(flag);
        //mod 吉 end
        // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
      },

      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      // del #11004 連携イベント発生部分不正 piao start
      // /**
      //  * @description MODIFY_SEND_CLASS取得
      //  */
      // async getSchModifySendClass() {
      //   let retVal = 0;
      //   const prmFacilityCd = this.facilityCd;
      //   this.objModSendClass = await sendRequestGetCoopIniSchModifySendClass(prmFacilityCd);
      //
      //   try {
      //     const response = this.objModSendClass;
      //     retVal = response.data;
      //   } catch (error) {
      //     retVal = 0;
      //   }
      //   return retVal;
      // },
      // del #11004 連携イベント発生部分不正 piao end
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end

      async callCreateJournal(flag) {
        let userid = this.getUserId;
        if(null == this.editDataSources || this.editDataSources.length == 0){//治疗单位
          let ope_cd = "";
          if (!flag) {
            if((this.selectedStaffCd1Old === null && this.selectedStaffCd2Old === '0') && (this.selectedStaffCd1 >0 || this.selectedStaffCd2 >0)){
              ope_cd = "028001";
            } else if((this.selectedStaffCd1Old !== this.selectedStaffCd1 || this.selectedStaffCd2Old !== this.selectedStaffCd2) && ((this.selectedStaffCd1 !== "0" && this.selectedStaffCd1 !== null) || (this.selectedStaffCd2 !== "0" && this.selectedStaffCd2 !== null))){
              ope_cd = "028002";
            } else if((this.selectedStaffCd1Old !== null || this.selectedStaffCd2Old !== '0') && ((this.selectedStaffCd1 === "0"  || this.selectedStaffCd1 === null) && (this.selectedStaffCd2 === "0"  || this.selectedStaffCd2 === null))){
              ope_cd = "028003";
            }
          }
          if (ope_cd !== ""
            && parseInt(this.rstDialysisState) < 6
            && this.indKurCd != 0) {
            // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
            // del #11004 連携イベント発生部分不正 piao start
            // let modSendClass = await this.getSchModifySendClass();
            // del #11004 連携イベント発生部分不正 piao end
            let crudTmp = "U";
            // del #11004 連携イベント発生部分不正 piao start
            // if ( modSendClass == 2) {
            //   const params = {
            //     ope_cd: ope_cd,
            //     crud: "D",
            //     pat_id: this.selectedPat.pat_personal_main.pat_id,
            //     facility_cd: this.facilityCd,
            //     hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
            //     ord_no:this.ordDetail.ordNo,
            //     base_date: this.ordDetail.treatDate,
            //     user_id: userid
            //   };
            //   createJournal(params);
            //   crudTmp = "C";
            // }
            // del #11004 連携イベント発生部分不正 piao end
            // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
            const params = {
              ope_cd: ope_cd,
              // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
              crud: crudTmp,
              // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
              pat_id: this.selectedPat.pat_personal_main.pat_id,
              facility_cd: this.facilityCd,
              hosp_pat_id: this.selectedPat.pat_personal_main.hosp_pat_id,
              ord_no:this.ordDetail.ordNo,
              base_date: this.ordDetail.treatDate,
              user_id: userid
            };
            createJournal(params);
          }
        }
      },
      // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end

      toggleCheckbox1() {
        if (this.isDisabled || this.isDisabledCheckbox1) {
          return;
        }

        this.isCheckbox1HasValue
          ? (this.selectedStaffCd1 = "0")
          : this.selectedUserStaff(this.SELECTED_CHECKBOX.CHECKBOX1);
      },
      toggleCheckbox2() {
        if (this.isDisabled || this.isDisabledCheckbox2) {
          return;
        }

        this.isCheckbox2HasValue
          ? (this.selectedStaffCd2 = "0")
          : this.selectedUserStaff(this.SELECTED_CHECKBOX.CHECKBOX2);
      },
      checkIsDisable(itemInfo, subCategoryNo) {
        if(Object.keys(this.checkedData).length > 0) {
          let leftIsDisable = this.checkedData[`${subCategoryNo}${itemInfo.itemNo}`]?.data.isDisable || false;
          let rightIsDisable = itemInfo.data.isDisable || false;
          return rightIsDisable === leftIsDisable && rightIsDisable && leftIsDisable;
        }else {
          return itemInfo.data.isDisable || false;
        }
      },
      isContentChangeWithUnit(itemInfo, subCategoryNo = 0) {
        if(itemInfo == null){
          return true;
        }
        if(Object.keys(this.checkedData).length === 0) {
          return false;
        }
        let itemNo = itemInfo.itemNo;
        if(subCategoryNo == 2) { // 治療方法
          itemNo = 0;
        }
        // if (this.checkedData[`${subCategoryNo}${itemNo}`] === null || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined) return false;
        if (this.checkedData[`${subCategoryNo}${itemNo}`] === null || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined) return true;
        if (2 === itemInfo.status) {
          return true;
        }

        const dialysisState = this.ordDetail.rstDialysisState;
        const checkedDataItemInfo = this.checkedData[`${subCategoryNo}${itemNo}`];
        const checkedData = checkedDataItemInfo.data.value;

        let itemCdChk = checkedDataItemInfo.itemCd;
        let prefixChk = checkedData.prefix ? checkedData.prefix : "";
        let dispValChk = checkedData.dispVal;
        dispValChk = this.isNumber(dispValChk)?BigNumber(dispValChk).toFixed():dispValChk;
        let unitChk = checkedData.unit ? " " + checkedData.unit : "";

        let itemCd = itemInfo.itemCd;
        let prefix = itemInfo.data.value.prefix ? itemInfo.data.value.prefix : "";
        let dispVal = itemInfo.data.value.dispVal;
        dispVal = this.isNumber(dispVal)?BigNumber(dispVal).toFixed():dispVal;
        let unit = itemInfo.data.value.unit ? " " + itemInfo.data.value.unit : "";

        if(subCategoryNo == 2) { // 治療方法
          if (dialysisState == "0") {
            return (itemCdChk != itemCd);
          } else {
            return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit)
          }
        } else if (subCategoryNo == 3) { // スケジュール
          // 1: クール
          // 3: ベッド
          if ([1,3].includes(itemNo)) {
            if (dialysisState == "0") {
              return (itemCdChk != itemCd);
            } else {
              return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit)
            }
          }
          // 2: 治療開始時刻
          if ([2].includes(itemNo)) {
            return (prefixChk + dispValChk != prefix + dispVal);
          }
        } else if (subCategoryNo == 4) { // 治療条件
          //no key → have key ： leftIsDisable && !rightIsDisable && prefixChk + dispValChk + unitChk === val       true
          //have key → no key ： !leftIsDisable && rightIsDisable && prefixChk + dispValChk + unitChk === val       true
          //have key → have key ： 正常比较
          //no key → no key ： false 灰色
          let leftIsDisable = checkedDataItemInfo.data.isDisable || false;
          let rightIsDisable = itemInfo?.data.isDisable || false;
          if ((leftIsDisable && !rightIsDisable) || (!leftIsDisable && rightIsDisable)) {
            return true;
          }
          // 2:  VA
          // 5:  ダイアライザ
          // 6:  吸着カラム
          // 7:  1次膜
          // 8:  2次膜
          // 9:  穿刺針(A針)
          // 10: 穿刺針(V針)
          // 11: 穿刺針(SN)
          // 13: 血液回路
          // 15: 透析液
          // 19: 補液
          // 25: 抗凝固剤
          if ([2,5,6,7,8,9,10,11,13,15,19,25].includes(itemNo)) {
            if (dialysisState === "0") {
              return (itemCdChk !== itemCd);
            } else {
              return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit)
            }
          }
          // -1:  dw
          // 1:  治療時間
          // 3:  目標体重
          // 4:  除水量制限
          // 12: シングルニードル使用
          // 14: 血流量
          // 16: 透析液流量
          // 17: 透析液使用数
          // 18: 透析液温度
          // 20: 補液量
          // 21: 補液選択
          // 22: 補液使用数
          // 23: 補液温度
          // 24: 補液速度
          // 26: 抗凝固剤ワンショット量
          // 27: 抗凝固剤持続速度
          // 28: 抗凝固剤持続総量
          // 29: IP使用選択
          // 30: IPスタート
          // 31: IPワンショット量
          // 32: IP速度
          // 33: IP速度最大値
          // 34: IPワンショットスタート
          // 35: IP電源自動切り
          // 36: IP電源自動切り時間
          // 37: IP電源OKモニタ切り
          // 38: IP電源OKモニタ切り時間
          if ([-1,1,3,4,12,14,16,17,18,20,21,22,23,24,26,27,28,29,30,31,32,33,34,35,36,37,38].includes(itemNo)) {
            if (dialysisState === "0") {
              return (dispValChk !== dispVal);
            } else {
              return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit)
            }
          }
        } else if ([5, 6].includes(subCategoryNo)) { // 投与薬剤, 医療材料
          if (itemNo !== 0 && !_.isEmpty(this.checkedData) &&                   // チェック済み状態
              (this.checkedData[`${subCategoryNo}0`] === ""                         // 新規登録
                  || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined)) {  // 追加
            return true;
          }
          if (itemCdChk !== itemCd) {
            return false;
          }
          if (dialysisState === "0") {
            return (prefixChk + dispValChk) !== (prefix + dispVal);
          } else {
            return (prefixChk + dispValChk + unitChk) !== (prefix + dispVal + unit);
          }
        } else if (subCategoryNo === 7) { // 指示コメント
          if (itemNo !== 0 && !_.isEmpty(this.checkedData) &&                   // チェック済み状態
            (this.checkedData[`${subCategoryNo}0`] === ""                         // 新規登録
              || this.checkedData[`${subCategoryNo}${itemNo}`] === undefined)) {  // 追加
            return true;
          }
          return (dispValChk !== dispVal);
        }
      },
      //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end

      isNumber(value) {
        const regex = /^-?\d+(\.\d+)?$/;
        return regex.test(value);
      },
      //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
      startLoading(message) {
        // mod bug #4320 修正 chen start
        // this.isLoading = true;
        // this.loadingMessage = message;

        // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start
        // this.resetLoadingScreenVisibleCount();
        // this.setLoadingScreenMessage(message);
        // this.setLoadingScreenVisible(true);
        this.startLoadingScreen(message);
        // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end
        // mod bug #4320 修正 chen end
      },
      stopLoading() {
        // mod bug #4320 修正 chen start
        // this.isLoading = false;
        // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start
        // this.setLoadingScreenVisible(false);
        this.finishLoadingScreen();
        // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end
        // mod bug #4320 修正 chen end
      },
      internalServerError(error) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // this.$ons.notification.alert("システムエラーが発生しました。", {
        //   title: "エラー",
        //   callback: () => {
        //     this.$router.push({ name: "signin" });
        //   }
        // });
        this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
          title: DIALOG_MESSAGES['00200002'].title,
          callback: () => {
            this.$router.push({ name: "signin" });
          }
        });
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      },
      // mod #9791 未チェックのみ表示が保持されている fang start
      async getIndicationDetails(isLoading = true) {
        // mod bug #4624 修正 chen start
        if (isLoading) {
          this.startLoading("指示情報を取得しています");
        }
        // mod #9791 未チェックのみ表示が保持されている fang end
        try {
        // #9791 子パンくずリスト押下で画面更新しているが、最新のデータを取得していない。 linjufeng start
        // let res = await Indication.searchDetail(params._id);
        let paramsId = this.resolveIndicationDetailIds();
        if (!this.hasIndicationDetailIds(paramsId)) {
          await this.getIndications();
          paramsId = this.resolveIndicationDetailIds();
        }
        if (!this.hasIndicationDetailIds(paramsId)) {
          throw new Error(`[IndicationDetailComponent.vue]getIndicationDetails(): indication detail ids not found. patId=${this.$route.params.patId}`);
        }
        let res = await Indication.searchDetail(paramsId);
        if (!Array.isArray(res)) {
          res = [];
        }
        // #9791 子パンくずリスト押下で画面更新しているが、最新のデータを取得していない。 linjufeng end
        // mod 7570 ind_dial連携で送信する項目情報部  赵 start
        // this.ordNoInit=res[0].ordNo;
        // mod 7570 ind_dial連携で送信する項目情報部  赵 end
        const typeRes = await getMstFacilitySettingValue(
          this.facilityCd,
          "1022");
        let resTmp = [];
        if (typeRes.data === 0) {
          res?.forEach(pat => {
            if (pat.logTarget === "ベッド" || pat.logTarget === "クール") {
              if (pat.logClass === "新規") {
                resTmp.push(pat);
              }
            } else {
              resTmp.push(pat);
            }
          });
          res = resTmp;
        }
        // mod bug #4624 修正 chen end
        res?.forEach(pat => {
          pat.logDateFormat =
            pat.logDate.substr(0, 4) +
            "/" +
            pat.logDate.substr(4, 2) +
            "/" +
            pat.logDate.substr(6, 2);
          pat.logTimeFormat =
            pat.logDate.substr(8, 2) +
            ":" +
            pat.logDate.substr(10, 2) +
            ":" +
            pat.logDate.substr(12, 2);

          // #10704 Mod Start
          if (pat.treatmentStartDate) {
            if (pat.treatmentStartDate.length === 8) {

              pat.treatmentStartDate =
                pat.treatmentStartDate.substr(0, 4) +
                "/" +
                pat.treatmentStartDate.substr(4, 2) +
                "/" +
                pat.treatmentStartDate.substr(6, 2);
            } else {
              pat.treatmentStartDate = pat.treatmentStartDate.substring(0, 10);
            }
          }

          if (pat.treatmentEndDate) {
            if (pat.treatmentEndDate.length === 8) {
              pat.treatmentEndDate = pat.treatmentEndDate.length < 8 ? "" :
                pat.treatmentEndDate.substr(0, 4) +
                "/" +
                pat.treatmentEndDate.substr(4, 2) +
                "/" +
                pat.treatmentEndDate.substr(6, 2);
            } else {
              pat.treatmentEndDate = pat.treatmentEndDate.substring(0, 10);
            }
          }
          // #10704 Mod End

          if (!pat.receiver1) {
            pat.receiver1 = 0;
          }
          if (!pat.receiver2) {
            pat.receiver2 = 0;
          }
          if (!pat.approver1) {
            pat.approver1 = 0;
          }
          if (!pat.approver2) {
            pat.approver2 = 0;
          }
          if (!pat.approver2) {
            pat.approver2 = 0;
          }
          if (!pat.treatmentCourse) {
            pat.treatmentCourse = "未登録";
          }
          /* #8333 HTMLの<BR>がそのまま内容欄に表示されている sichengbo start */
          if (pat.logContent) {
            if (pat.logContent.includes("<br>")) {
              pat.logContent = pat.logContent.replace(/<br>/g, '\n');
            }
          }
          /* #8333 HTMLの<BR>がそのまま内容欄に表示されている sichengbo end */
        });
        this.gridDataRaw = res.map(item => ({
          ...item,
          inEdit: true,
          receiver1IsEdited: false,
          receiver2IsEdited: false,
          approver1IsEdited: false,
          approver2IsEdited: false,
          selected: false
        }));
        this.initGridDataRaw();
        this.sortedIndicationDetails();
        // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start
        // this.initDataSources = res;
        this.initDataSources = deepCopy(res);
        this.initDataSources?.forEach((item)=>{
          this.initDataSourcesMap[item._id] = item;
        });
        // #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end
        this.chgDataSources = deepCopy(res);
        // add FNSI redmain_3947 「未チェックのみ表示」の欄にチェックを入れると未保存の内容が表示から消える dou end
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
        await this.initDataValue();
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
        } finally {
          this.stopLoading();
        }
      },
      initGridDataRaw() {
        if(this.gridDataRaw) {
          this.gridDataRaw?.forEach(el => {
            for(let i = 0; i < this.mstPersonalUser.length; i++) {
              let userInfo = this.mstPersonalUser[i];
              if(userInfo.userId == el.receiver1) {
                el.receiver1Name = userInfo.userFullName;
              }
              if(userInfo.userId == el.receiver2) {
                el.receiver2Name = userInfo.userFullName;
              }
              if(userInfo.userId == el.approver1) {
                el.approver1Name = userInfo.userFullName;
              }
              if(userInfo.userId == el.approver2) {
                el.approver2Name = userInfo.userFullName;
              }
              if(i === this.mstPersonalUser.length - 1) {
                if(!el.receiver1Name) {
                  el.receiver1Name = '未登録';
                }
                if(!el.receiver2Name) {
                  el.receiver2Name = '未登録';
                }
                if(!el.approver1Name) {
                  el.approver1Name = '未登録';
                }
                if(!el.approver2Name) {
                  el.approver2Name = '未登録';
                }
              }
            }
          });
        }
      },
      onChangeFilter() {
        this.setIndicationsUnchecked(this.indicationsUncheckedValue);
      },

      initIndicationsUncheckedValue() {
        this.indicationsUncheckedValue = { ...this.indicationsUnchecked };
      },
      getIndicationType(fieldName) {
        switch (fieldName) {
          case this.INDICATIONTYPE.RECEIVER1:
            return this.INDICATIONTYPEVALUE.RECEIVER1;
          case this.INDICATIONTYPE.RECEIVER2:
            return this.INDICATIONTYPEVALUE.RECEIVER2;
          case this.INDICATIONTYPE.APPROVER1:
            return this.INDICATIONTYPEVALUE.APPROVER1;
          case this.INDICATIONTYPE.APPROVER2:
            return this.INDICATIONTYPEVALUE.APPROVER2;
          default:
            break;
        }
      },
      // add #10413 指示受け画面にて特定の操作を実施するとコンソールエラーが出て保存することができない linjunfeng start
      getIndicationValue(type) {
        switch (type) {
          case this.INDICATIONTYPEVALUE.RECEIVER1:
            return this.INDICATIONTYPE.RECEIVER1;
          case this.INDICATIONTYPEVALUE.RECEIVER2:
            return this.INDICATIONTYPE.RECEIVER2;
          case this.INDICATIONTYPEVALUE.APPROVER1:
            return this.INDICATIONTYPE.APPROVER1;
          case this.INDICATIONTYPEVALUE.APPROVER2:
            return this.INDICATIONTYPE.APPROVER2;
          default:
            break;
        }
      },
      // add #10413 指示受け画面にて特定の操作を実施するとコンソールエラーが出て保存することができない linjunfeng end
      async onClickUpdateDetails(item, indicationType, staffCd, fullName) {
        indicationType = indicationType.replace('Name', '');
        await this.updateDataSources(item._id, indicationType, staffCd, fullName);
        this.processGridData(0);
        this.editRefreshKey++;
      },
      handleGridUpdate(items, _id, fieldName, staffCd, fullName) {
        if(items[0].items) {
          for(let i = 0; i < items.length; i++) {
            this.handleGridUpdate(items[i].items, _id, fieldName, staffCd, fullName);
          }
        } else {
          for(let i = 0; i < items.length; i++) {
            let isEditFlag = false;
            const pat = items[i];
            
            if (pat._id === _id) {
              // 個別処理
              isEditFlag = true;
            } else if(!_id) {
              // 一括処理
              isEditFlag = true;
            }
            if(isEditFlag) {
              const initItem = this.initDataSourcesMap[pat._id];
              let initFieldValue = null;
              if(initItem) {
                initFieldValue = initItem[fieldName];
              }
              pat[fieldName] = staffCd;
              let nameField = fieldName + "Name";
              let editField = fieldName + "IsEdited";
              pat[editField] = false;
              if(!fullName || fullName === '未登録') {
                pat[nameField] = '未登録';
              } else if(fullName !== '未登録') {
                pat[nameField] = fullName;
                // 編集カラー
                if(initFieldValue != staffCd) {
                  pat[editField] = true;
                }
              }
              const param = {
                indicationType: this.getIndicationType(fieldName),
                userId: pat[fieldName],
                _id: pat._id
              };
              const editData = this.editDataSources.find(eds => eds._id === pat._id
                  && eds.indicationType === this.getIndicationType(fieldName));
              if (editData) {
                this.editDataSources.splice(this.editDataSources.indexOf(editData), 1);
              }
              this.editDataSources.push(param);
            }
          }
        }
      },
      async updateDataSources(_id, fieldName, staffCd, fullName) {
        // スタッフリスト取得
        const ret = this.getIndicationStaffList(fieldName);
        const dataSource = ret.dataSource;
        // スタッフリストから設定すべきCD取得
        if(!staffCd) {
          const staffInfo = this.getStaffCd(dataSource, ret.retFieldName);
          staffCd = staffInfo.staffCd;
          fullName = staffInfo.fullName;
        }
        this.handleGridUpdate(this.displayGridData, _id, fieldName, staffCd, fullName);
      },
      onResize() {
        // 印刷中はスキップ
        if (this.isPrint) return;

        const headObj = getScopedElementsByClassName("indication-detail-filter", this.$el || this);
        let hHeight = 0;
        if (headObj.length > 0) {
          hHeight = headObj[0].offsetHeight;
        }
        const footerObj = getScopedElementsByClassName("actions d-flex", this.$el || this);
        let fHeight = 0;
        if (footerObj.length > 0) {
          fHeight = footerObj[0].offsetHeight;
        }
        let hosei = 1.0;
        switch (this.getFontSize) {
          case "0":
            hosei = 0.8;
            break;
          case "2":
            hosei = 1.1;
            break;
          case "3":
            hosei = 1.5;
            break;
        }
        const mainObj = getScopedElementById("main-id", this.$el || this);
        const mainHeight = mainObj ? mainObj.offsetHeight : 0;
        this.gridHeight = mainHeight - fHeight - hHeight - (20 * hosei);
      },

      async clickSelectAll(fieldName) {
        this.startLoading(
          this.isReceive ? "指示を確認しています。" : "承認しています。"
        );
        // スタッフリスト取得
        const ret = this.getIndicationStaffList(fieldName);
        const dataSource = ret.dataSource;
        // スタッフリストから設定すべきCD取得
        const staffInfo = this.getStaffCd(dataSource, ret.retFieldName);
        const staffCd = staffInfo.staffCd;
        const fullName = staffInfo.fullName;
        this.handleGridUpdate(this.gridDataRaw, null, fieldName, staffCd, fullName);
        this.processGridData(0);
        this.stopLoading();
      },
      setIndicationDetailsColumn() {
        this.gridIndicationColumns = [
          {
            field: "receiver1Name",
            title: "指示受け1",
            cell: "editTemplate",
            values: this.checkerValues,
            hidden: !this.isReceive,
            groupable: true,
            width: 200,
            minResizableWidth: '200',
            editable: () => this.hasIndReceiveAuthority
          },
          {
            field: "receiver2Name",
            title: "指示受け2",
            cell: "editTemplate",
            values: this.checkerValues,
            hidden: !this.isReceive,
            groupable: true,
            width: 200,
            minResizableWidth: '200',
            editable: () => this.hasIndReceiveAuthority
          },
          {
            field: "approver1Name",
            title: "指示承認1",
            cell: "editTemplate",
            values: this.doctorValues,
            hidden: !this.isReceive,
            groupable: true,
            width: 200,
            minResizableWidth: '200',
            editable: () => this.isShowBtnOK && this.hasIndReceiveAuthority
          },
          {
            field: "approver2Name",
            title: "指示承認2",
            cell: "editTemplate",
            values: this.doctorValues,
            hidden: !this.isReceive,
            groupable: true,
            width: 200,
            minResizableWidth: '200',
            editable: () => this.isShowBtnOK && this.hasIndReceiveAuthority
          },
          {
            field: "logTarget",
            title: "対象",
            width: 300,
            minResizableWidth: '100',
            groupable: true,
            editable: () => false,
            template: (e) => {
              let name = e && e.logTarget ? e.logTarget : "";
              return `${name}`
            }
          },
          {
            field: "logContent",
            title: "内容",
            width: 300,
            minResizableWidth: '100',
            groupable: true,
            editable: () => false,
            template: (e) => {
              let name = e && e.logContent ? e.logContent : "";
              return `${name}`
            }
          },
          {
            field: "logDateFormat",
            title: "発行日",
            groupable: true,
            editable: () => false,
            width: 120
          },
          {
            field: "logTimeFormat",
            title: "時刻",
            groupable: true,
            editable: () => false,
            width: 96,
            minResizableWidth: '100',
          },
          {
            field: "treatmentStartDate",
            title: "開始日",
            groupable: true,
            editable: () => false,
            width: 120
          },
          {
            field: "treatmentEndDate",
            title: "終了日",
            groupable: true,
            editable: () => false,
            width: 120,
            minResizableWidth: '100',
          },
          {
            field: "createdBy",
            title: "指示者",
            width: 144,
            minResizableWidth: '100',
            groupable: true,
            editable: () => false
          },
          {
            field: "updatedBy",
            title: "入力者",
            width: 144,
            minResizableWidth: '100',
            groupable: true,
            editable: () => false
          },
          {
            field: "logClass",
            title: "操作区分",
            width: 120,
            minResizableWidth: '100',
            groupable: true,
            editable: () => false
          },
          {
            field: "treatmentWeekday",
            title: "曜日",
            minResizableWidth: '100',
            groupable: true,
            editable: () => false,
            width: 100,
            template: (e) => {
              let name = e && e.treatmentWeekday ? e.treatmentWeekday : "";
              return `${name}`
            }
          },
          {
            field: "treatmentMethod",
            title: "治療方法",
            width: 150,
            minResizableWidth: '100',
            groupable: true,
            editable: () => false,
            template: (e) => {
              let name = e && e.treatmentMethod ? e.treatmentMethod : "";
              return `${name}`
            }
          },
          {
            field: "treatmentCourse",
            title: "クール",
            width: 96,
            minResizableWidth: '100',
            groupable: true,
            editable: () => false
          }
        ];
        this.initDisplayColumns();
      },
      initDisplayColumns() {
        this.displayColumns = [];
        this.gridIndicationColumns?.forEach(column => {
          const field = column.field;
          const colDef = {
            field: field,
            title: column.title,
            width: column.width + 'px',
            groupable: column.groupable !== false,
            editable: false,
            cell: column.cell,
            minResizableWidth: column.minResizableWidth
          };
          if(column.field === 'receiver1Name') {
            if(this.isReceive && this.columnStatus.isShowChecker1) {
              this.displayColumns.push(colDef);
            }
          } else if(column.field === 'receiver2Name') {
            if(this.isReceive && this.columnStatus.isShowChecker2) {
              this.displayColumns.push(colDef);
            }
          } else if(column.field === 'approver1Name') {
            if(!this.isReceive && this.columnStatus.isShowApprover1) {
              this.displayColumns.push(colDef);
            }
          } else if(column.field === 'approver2Name') {
            if(!this.isReceive && this.columnStatus.isShowApprover2) {
              this.displayColumns.push(colDef);
            }
          } else {
            this.displayColumns.push(colDef);
          }
        });
        this.columnsMap = Object.fromEntries(
          this.displayColumns.map(col => [col.field, col.title])
        );
      },
      async sortedIndicationDetails() {
        this.startLoading("指示情報を取得しています");
        this.indicationsUncheckedValue = this.indicationsUnchecked;
        const receiver1 = this.indicationsUncheckedValue.receiver1;
        const receiver2 = this.indicationsUncheckedValue.receiver2;
        const approver1 = this.indicationsUncheckedValue.approver1;
        const approver2 = this.indicationsUncheckedValue.approver2;
        let chgDataSourcesMap = {};
        this.gridDataRaw?.forEach((item) => {
          chgDataSourcesMap[item._id] = item;
        })
        this.gridDataRaw?.forEach(item => {
          let chgDataSource = chgDataSourcesMap[item._id];
          chgDataSource.receiver1 = item.receiver1;
          chgDataSource.receiver2 = item.receiver2;
          chgDataSource.approver1 = item.approver1;
          chgDataSource.approver2 = item.approver2;
        });
        let result = this.gridDataRaw;
        if (receiver1 && !receiver2) {
          result = this.gridDataRaw.filter(
            pat => pat.receiver1 == 0
          );
        } else if (receiver1 && receiver2) {
          result = this.gridDataRaw.filter(
            pat => pat.receiver1 == 0 && pat.receiver2 == 0
          );
        } else if (!receiver1 && receiver2) {
          result = this.gridDataRaw.filter(
            pat => pat.receiver2 == 0
          );
        }

        if (approver1 && !approver2) {
          result = this.gridDataRaw.filter(
            pat => pat.approver1 == 0
          );
        } else if (approver1 && approver2) {
          result = this.gridDataRaw.filter(
            pat => pat.approver1 == 0 && pat.approver2 == 0
          );
        } else if (!approver1 && approver2) {
          result = this.gridDataRaw.filter(
            pat => pat.approver2 == 0
          );
        }
        this.displayGridData = result;
        this.allGroupedData = process(this.displayGridData, {
          group: this.gridGroup,
          sort: this.gridSort
        });
        this.gridSortedList = this.expandedArr(this.allGroupedData.data);
        this.processGridData(0);
        this.stopLoading();
      },
      async insertIndApproveHistory(ordNo, userId,  approveKind, approveAftId, signType){
        await Indication.insertPatIndApproveHistory({
          ordNo: ordNo,
          userId : userId,
          approveKind: approveKind,
          approveAftId: approveAftId,
          signType: signType
        });
      },
      saveHistoryIndication(checkBoxValue, approveKind, approveKindValue , approveAftId, selectedStaffValue, signType) {
        approveKind.push(approveKindValue)
        if (checkBoxValue) {
          approveAftId.push(+selectedStaffValue);
          signType.push(this.SIGN_TYPE.SETTING)
        } else {
          approveAftId.push(0);
          signType.push(this.SIGN_TYPE.REMOVE);
        }
      },
      // add #9311 v-model発効します 張博 start
      onChangeStaff1(event) {
        this.selectedStaffCd1 = event.sender._old;
      },
      onChangeStaff2(event) {
        this.selectedStaffCd2 = event.sender._old;
      },
      // add #9311 v-model発効します 張博 end
      /**
       * 優先順位順に選択するスタッフCDを取得
       */
      getStaffCd(lst, fieldName) {
        // 各ID取得
        const docId = this.defaultDoctor;
        const usrId = this.getUserId;

        // アカウントIDの要素がある場合優先して選択
        for (let i = 0; i < lst.length; i += 1) {
          const r = lst[i];
          if (r[fieldName] === usrId) {
            return {
              staffCd: r[fieldName],
              fullName: r['userFullName']
            };
          }
        }
        // デフォルト医師IDの要素がある場合カウントIDの次に優先して選択
        for (let i = 0; i < lst.length; i += 1) {
          const r = lst[i];
          if (r[fieldName] === docId) {
            return {
              staffCd: r[fieldName],
              fullName: r['userFullName']
            };
          }
        }
        // アカウントIDもデフォルト医師IDの要素もない場合は"未登録の次の要素を選択
        if (lst.length >= 2) {
          return {
            staffCd: lst[1][fieldName],
            fullName: lst[1]['userFullName']
          };
        } else {
          return {
            staffCd: 0,
            fullName: null
          };
        }
      },
      /**
       * チェックボックスの設定状況に応じて
       * リストのスタッフを自動選択
       */
      selectStaffByCheckBox1(bln) {
        if (bln) {
          this.selectedStaffCd1 = this.getStaffCd(this.userTreatmentList1, "userId").staffCd;
        } else {
          this.selectedStaffCd1 = "0";
        }
      },
      selectStaffByCheckBox2(bln) {
        if (bln) {
          this.selectedStaffCd2 = this.getStaffCd(this.userTreatmentList2, "userId").staffCd;
        } else {
          this.selectedStaffCd2 = "0";
        }
      },
      /**
       * チェックボックスの変更時
       */
      onChangeCheckbox1(event) {
        this.selectStaffByCheckBox1(event.target.checked);
      },
      onChangeCheckbox2(event) {
        this.selectStaffByCheckBox2(event.target.checked);
      },
      showIndHistoryModal() {
        const title = this.isApproving ? "指示承認履歴" : "指示受け履歴";
        this.showIndicationsHistoryModal(title);
      },
      selectedUserStaff(checkbox) {
        if (this.isApproving && this.facilityInsApp === this.FACILITY_INS_APPTYPE.DOCTOR_LIST && !this.isDoctor) {
          checkbox === this.SELECTED_CHECKBOX.CHECKBOX1
            ? this.selectedStaffCd1 = this.defaultDoctor
            : this.selectedStaffCd2 = this.defaultDoctor;
        } else {
          checkbox === this.SELECTED_CHECKBOX.CHECKBOX1
            ? this.selectedStaffCd1 = this.userId
            : this.selectedStaffCd2 = this.userId;
        }
      },

      /**
       * スタッフリスト取得
       */
      getIndicationStaffList(fieldName) {
        const indicationType = this.getIndicationType(fieldName);
        let dataSource = [];
        let retFieldName = '';

        if (
          indicationType === this.INDICATIONTYPEVALUE.RECEIVER1 ||
          indicationType === this.INDICATIONTYPEVALUE.RECEIVER2 ||
          this.facilityInsApp === this.FACILITY_INS_APPTYPE.ALL_USER) {
          dataSource = this.mstPersonalUser;
          retFieldName = "userId";
        } else {
          dataSource = this.doctorsAtFacility;
          retFieldName = "user_id";
        }
        return {
                dataSource,
                retFieldName
              };
      },
      openUserTreatmentList(checkbox) {
        if (this.isDisabled || this.isDisabledDropdown) {
          return;
        }

        if (this.isApproving
          && this.facilityInsApp
          != this.FACILITY_INS_APPTYPE.ALL_USER) {
          if (!this.isOpenDropdown1 || !this.isOpenDropdown2) {
            checkbox === this.SELECTED_CHECKBOX.CHECKBOX1
              ? this.isOpenDropdown1 = true
              : this.isOpenDropdown2 = true;

            if (this.isOpenDropdown1) {
              this.mstUserTreatmentList1 = this.doctorsAtFacility;
            }

            if (this.isOpenDropdown2) {
              this.mstUserTreatmentList2 = this.doctorsAtFacility;
            }
          }
        } else {
          this.mstUserTreatmentList1 = this.mstPersonalUser;
          this.mstUserTreatmentList2 = this.mstPersonalUser;
        }
      },
      closeUserTreatmentList(checkbox) {
        if (this.isApproving
          && this.facilityInsApp
          != this.FACILITY_INS_APPTYPE.ALL_USER
          && (this.isOpenDropdown1 || this.isOpenDropdown2)) {
          let isExist = true;
          if (checkbox === this.SELECTED_CHECKBOX.CHECKBOX1) {
            isExist = this.mstUserTreatmentList1.some((item)=> {
              return +item.userId === +this.selectedStaffCd1;
            });
          } else {
            isExist = this.mstUserTreatmentList2.some((item)=> {
              return +item.userId === +this.selectedStaffCd2;
            });
          }
          if (!isExist) {
            if (checkbox === this.SELECTED_CHECKBOX.CHECKBOX1) {
              this.selectedStaffCd1 = "0";
            } else {
              this.selectedStaffCd2 = "0";
            }
          }
        }
      },
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
      async confirmContentChanged() {
        let cancelled = false;
        if (!this.isDirty) {
          await this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000004].title,
            message: DIALOG_MESSAGES[13000004].message,
            callback: answer => {
              if (answer === 0) {
                cancelled = true;
              }
            }
          });
        }
        return !cancelled;
      },
      initDataValue(){
        if (!this.isModeIndicationDetails) {
          this.initIsCheckbox1HasValue = JSON.parse(JSON.stringify(this.isCheckbox1HasValue));
          this.initIsCheckbox2HasValue = JSON.parse(JSON.stringify(this.isCheckbox2HasValue));
          this.initSelectedStaffCd1 = JSON.parse(JSON.stringify(this.selectedStaffCd1));
          this.initSelectedStaffCd2 = JSON.parse(JSON.stringify(this.selectedStaffCd2));
        } else {
          this.editDataSources = [];
        }
      },
      async refresh() {
        // #9791 子パンくずリスト押下で画面更新しているが、最新のデータを取得していない。 linjunfeng start
        if (await this.confirmContentChanged()) {
          // this.isTreatmentUnit ? await this.getIndicationDetail() : await this.getIndicationDetails()
          if (this.isTreatmentUnit) {
            await this.getIndicationDetail()
            this.convertIndData();
          } else {
            // add #9791 未チェックのみ表示が保持されている fang start
            this.startLoading("指示情報を取得しています");
            // add #9791 未チェックのみ表示が保持されている fang end
            this.setIndicationsUnchecked({
              receive1: false,
              receive2: false,
              approver1: false,
              approver2: false
            });
            await this.getIndications()
            // mod #9791 未チェックのみ表示が保持されている fang start
            await this.getIndicationDetails(false)
            // mod #9791 未チェックのみ表示が保持されている fang end
          }
        }
        // #9791 子パンくずリスト押下で画面更新しているが、最新のデータを取得していない。 linjunfeng end
      },
      statisChangedElem(){
        let changedCount = 0;
        this.editDataSources?.forEach(elem => {
          let matchedObjects = this.initDataSources.filter(initData => initData._id === elem._id);
          if(matchedObjects.length > 0){
            if(elem.indicationType === this.INDICATIONTYPEVALUE.RECEIVER1){
              if(matchedObjects[0]?.receiver1 != elem.userId){
                changedCount++;
              }
            }else if(elem.indicationType === this.INDICATIONTYPEVALUE.RECEIVER2){
              if(matchedObjects[0]?.receiver2 != elem.userId){
                changedCount++;
              }
            }else if(elem.indicationType === this.INDICATIONTYPEVALUE.APPROVER1){
              if(matchedObjects[0]?.approver1 != elem.userId){
                changedCount++;
              }
            }else if(elem.indicationType === this.INDICATIONTYPEVALUE.APPROVER2){
              if(matchedObjects[0]?.approver2 != elem.userId){
                changedCount++;
              }
            }
          }
        })
        return changedCount;
      },
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
      /**
       * 休日のスタイル取得
       */
      getStyle(date) {
        return getHolidayStyle(date);
      }
    },
    async created() {
// add  FNSI-権限 陳 start
      // mod #10359 編集権限の動作不正 dengshen start
      // this.hasIndReceiveAuthority = this.getIndReceiveAuthority();
      this.hasIndReceiveAuthority = this.getItemAuthorized('IndicationList', 'default_authority');
      // mod #10359 編集権限の動作不正 dengshen end
// add  FNSI-権限 陳 end
      //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
      EventBus.$off("requestReportParams", this.requestrReportParams);
      EventBus.$on("requestReportParams", this.requestrReportParams);
      //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end

      if (this.isTreatmentUnit === null) {
        return;
      }
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      if(this.selectedPatId == null){
        store.dispatch("report/getMstReport", {funcCd: "02804",printFlag: null});
      }else{
        store.dispatch("report/getMstReport", {funcCd: "02804",printFlag: 1});
      }
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
      
      // 休日マスタの休日を取得
      await this.fetchHolidays(this.facilityCd);
      
      if (this.$route.params.ordNo) {
        await this.getIndicationDetail();
        this.initIndicationsUncheckedValue();
        this.convertIndData();
        this.mstUserTreatmentList1 = this.mstPersonalUser;
        this.mstUserTreatmentList2 = this.mstPersonalUser;
      }

      if (this.$route.params.patId) {
        await this.getIndicationDetails();
        this.setIndicationDetailsColumn();
        await this.renderIndicationDetailsGrid();
      }
      this.$nextTick(async () => {
        // mod bug #4407 修正 chen start
        // add #9791 未チェックのみ表示が保持されている linjunfeng start
        // mod 10022 特定の操作でシステムエラーとなる 関 start
        // this.setIndicationsUnchecked({
        //     receive1: false,
        //     receive2: false,
        //     approver1: false,
        //     approver2: false
        //   });
        if (!this.isTreatmentUnit) {
          this.setIndicationsUnchecked({
            receive1: false,
            receive2: false,
            approver1: false,
            approver2: false
          });
        }
        // mod 10022 特定の操作でシステムエラーとなる 関 end
        // add #9791 未チェックのみ表示が保持されている linjunfeng end
        if (this.$route.params.patId) {
          // this.onResize();
          this.initIndicationsUncheckedValue();
        }
        this.onResize();
        // mod bug #4407 修正 chen end
        // モバイル端末の場合、サイズの適用が遅い為対応を追加する
        const ownerWindow = getScopedWindow(this.$el) || window;
        const ua = getScopedUserAgent(this.$el);
        if (ua.match(/iPhone|iPad/)) {
          this.delayObjIosResize = ownerWindow.setInterval(() => {
            const headObj = getScopedElementsByClassName("indication-detail-filter", this.$el || this);
            let hHeight = 0;
            if (headObj.length > 0) {
              hHeight = headObj[0].offsetHeight;
            }
            if (hHeight > 0) {
              this.onResize();
              ownerWindow.clearInterval(this.delayObjIosResize);
            }
          }, 200);
        }
      });
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
      EventBus.$off("refresh", this.refresh);
      EventBus.$on("refresh", this.refresh);
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
    },
    mounted() {
      this.$nextTick(async () => {
        const scopedWindow = getScopedWindow(this.$el) || window;
        scopedWindow.addEventListener("resize", this.onResize);
        scopedWindow.addEventListener("beforeprint", this.handleBeforePrint);
        scopedWindow.addEventListener("afterprint", this.handleAfterPrint);
      });
    },
    beforeUnmount() {
      this.clearHolidays(); // storeの休日マスタをクリア
      //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
      EventBus.$off("requestReportParams", this.requestrReportParams);
      //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
      const scopedWindow = getScopedWindow(this.$el) || window;
      scopedWindow.removeEventListener("resize", this.onResize);
      scopedWindow.removeEventListener("beforeprint", this.handleBeforePrint);
      scopedWindow.removeEventListener("afterprint", this.handleAfterPrint);
      // add 10022 特定の操作でシステムエラーとなる 関  start
      EventBus.$off("goBack", this.goBack);
      // add 10022 特定の操作でシステムエラーとなる 関  end
      // add 画面パフォーマンス対応 chen start
      this.isPrint = null;
      this.okIcon = null;
      this.hasIndReceiveAuthority = null;
      this.treatDate = null;
      this.layout = null;
      this.ordDetail = null;
      this.patIndApprove = null;
      this.patPersonal = null;
      this.checkedData = null;
      this.selectedStaffCd1 = null;
      this.selectedStaffCd2 = null;
      this.selectedStaffCd1Old = null;
      this.selectedStaffCd2Old = null;
      this.isLoading = null;
      this.loadingMessage = null;
      this.indicationsUncheckedValue = null;
      this.dataSources = null;
      this.editDataSources = null;
      this.gridHeight = null;
      this.initDataSources = null;
      this.chgDataSources = null;
      this.gridIndicationColumns = null;
      this.isIndicationDetailsGridReady = null;
      this.INDICATIONTYPE = null;
      this.INDICATIONTYPEVALUE = null;
      this.RECEIVE = null;
      this.groupableMessageEmpty = null;
      this.SIGN_TYPE = null;
      this.FACILITY_INS_APPTYPE = null;
      this.SELECTED_CHECKBOX = null;
      this.mstUserTreatmentList1 = null;
      this.mstUserTreatmentList2 = null;
      this.isOpenDropdown1 = null;
      this.isOpenDropdown2 = null;
      // add 画面パフォーマンス対応 chen end
      if (!this.delayObjIosResize) {
        (getScopedWindow(this.$el) || window).clearInterval(this.delayObjIosResize);
      }
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc start
      EventBus.$off("refresh", this.refresh);
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_指示承認 20231123 ztc end
    },
  };
</script>

<style>
@media print {
  /** tableレイアウト崩れ回避 */
  body:has(#indication-detail) #main-id {
    display: inline-block;
    vertical-align: top;
  }
}
</style>

<style scoped>
  /* #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start */
  :deep(.k-widget .k-icon.k-i-expand),
  :deep(.k-widget .k-icon.k-i-collapse) {
    display: none;
  }
  /* #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end */
  .main-content-area :deep(:disabled + .checkbox__checkmark) {
    opacity: 1;
  }
  .main-content-area :deep(.k-dropdown .k-dropdown-wrap:not(.k-state-disabled)) {
    background-color: #fff;
  }

  .main-content-area :deep(.k-dropdown .k-picker:not(.k-disabled)),
  .main-content-area :deep(.k-dropdown.k-picker:not(.k-disabled)) {
    background-color: #fff;
  }
  .loading-modal {
    font-size: 2.4em;
  }
  .grid {
    overflow: auto;
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen start*/
    /*border: 1px solid var(--ntss-border-color);*/
    border: 1px solid var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen end*/
    border-left: none;
  }
  .grid .horizontal {
    min-width: 700px;
    position: sticky;
    top: 0;
    z-index: 4;
  }
  .grid .vertical-wrapper {
    min-width: 700px;
  }
  .grid .header,
  .grid .sub-header {
    padding: 0.1em 0.2em;
    color: var(--ntss-header-color);
    background-color: var(--ntss-header-background-color);
    word-break: break-all;
  }
  .grid .horizontal > .header {
    display: flex;
    align-items: center;
    justify-content: center;
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen start*/
    /*border-left: 1px solid var(--ntss-border-color);*/
    border-left: 1px solid var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen end*/
  }
  .grid .horizontal > .header:first-child {
    min-width: 10em;
    max-width: 10em;
    border-left: none;
  }
  .grid .horizontal > .header:nth-child(2) {
    min-width: 200px;
  }
  .grid .horizontal > .header:nth-child(3),
  .grid .horizontal > .header:nth-child(4) {
    max-width: 250px;
  }
  .grid .vertical {
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen start*/
    /*border-top: 1px solid var(--ntss-border-color);*/
    border-top: 1px solid var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen end*/
  }
  .grid .sub-category:not(.multiple) > .header {
    min-width: 10em;
    max-width: 10em;
  }
  .grid .sub-category.multiple > .header {
    display: flex;
    align-items: center;
    min-width: 2.35294em;
    max-width: 2.35294em;
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen start*/
    /*border-right: 1px solid var(--ntss-border-color);*/
    border-right: 1px solid var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen end*/
    padding-top: 0.3em;
    padding-bottom: 0.3em;
    writing-mode: vertical-rl;
    word-break: keep-all;
  }
  .grid .sub-category.multiple .sub-header {
    min-width: 7.65705em;
    max-width: 7.65705em;
  }
  .grid .sub-category .text {
    padding: 5px;
  }
  .grid .sub-category:not(.multiple) > .text {
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen start*/
    /*border-left: 1px solid var(--ntss-border-color);*/
    border-left: 1px solid var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen end*/
  }
  .grid .sub-category:not(.multiple) > .text:last-child {
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen start*/
    /*border-right: 1px solid var(--ntss-border-color);*/
    border-right: 1px solid var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen end*/
  }
  .grid .sub-category:not(.multiple).content-change > .text {
    background-color: orange;
  }
  .grid .sub-category .sub-category-item {
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen start*/
    /*border-bottom: 1px solid var(--ntss-border-color);*/
    border-bottom: 1px solid var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen end*/
  }
  .grid .sub-category .sub-category-item:last-child {
    border-bottom: none;
  }
  .grid .sub-category .sub-category-item > .text {
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen start*/
    /*border-left: 1px solid var(--ntss-border-color);*/
    border-left: 1px solid var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen end*/
  }
  .grid .sub-category .sub-category-item > .text:last-child {
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen start*/
    /*border-right: 1px solid var(--ntss-border-color);*/
    border-right: 1px solid var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3871 修正 chen end*/
  }
  .grid .sub-category .sub-category-item.content-change > .text {
    background-color: orange;
  }
  .grid .sub-category > .text.value,
  .grid .sub-category.multiple .sub-category-item > .text.value {
    min-width: 200px;
  }
  .grid .sub-category > .text.instructor,
  .grid .sub-category.multiple .sub-category-item > .text.instructor,
  .grid .sub-category > .text.updater,
  .grid .sub-category.multiple .sub-category-item > .text.updater {
    max-width: 250px;
  }
  .checkers {
    margin-top: 0.5em;
  }
  .checkers > div:first-child {
    margin-right: 1em;
  }
  .checkers ons-checkbox {
    margin-right: 0.2em;
  }
  ons-button.nik-btn {
    padding-right: 1.5em;
  }
  .actions {
    margin-top: 0.5em;
  }
  .actions > ons-button {
    margin-right: 0.4em;
  }
  .actions > ons-button:last-child {
    margin-right: 0;
  }
  .actions > ons-button.cancel {
    background-color: #add8e6;
  }
  .actions > ons-button.history,
  .actions > ons-button.save {
    background-color: var(--ntss-btn-ok-background-color);
  }
  .actions > ons-button.history {
    min-width: 180px;
    max-width: fit-content;
  }
  .actions > ons-button.cancel {
    min-width: 130px;
    max-width: fit-content;
  }
  .actions > ons-button.save {
    min-width: 80px;
    max-width: fit-content;
  }
  ons-button .ok-icon {
    width: 1.5em;
    position: absolute;
    top: 5px;
    right: 0;
  }
  .right {
    text-align: right;
  }
  .btn-middle.btn-ind-history {
    background-image: linear-gradient(rgb(185, 200, 207) 0%,#3D82A5 50%,#3D82A5 50%,#377B9E 100%);
    width: auto;
    padding-left: 1em;
    padding-right: 1em;
  }
  .grid .text {
    color: var(--ntss-base-color);
  }
  ons-checkbox ~ label {
    color: var(--ntss-base-color);
  }
  .checkbox-group > * {
    margin-right: 1em;
  }
  .checkbox-group ons-checkbox {
    margin-right: 5px;
  }
  .mb-2 {
    margin-bottom: 0.5em;
  }
  .mt-2 {
    margin-top: 0.5em;
  }
  .mt-3 {
    margin-top: 1em;
  }
  .mr-3 {
    margin-right: 1em;
  }
  .mr-2 {
    margin-right: 0.5em;
  }
  .base-color {
    color: var(--ntss-base-color);
  }
  .main-content-area :deep(.k-grid) {
    background-color: var(--main-background-color);
  }
  .main-content-area :deep(.k-grid tr) {
    height: 2em !important;
    border-color: var(--master-maintenance-kgrid-border-color);
    color: var(--master-maintenance-kgrid-body-color);
    background-color: var(--master-maintenance-kgrid-item-background-color);
  }
  .main-content-area :deep(.k-grid:not(:has(tr.k-grouping-row)) tr.k-table-alt-row) {
    background-color: var(--ntss-list-content-2nd-background-color);
  }
  .main-content-area :deep(.k-grid a) {
    color: var(--master-maintenance-kgrid-item-color);
  }
   
  /* add 指示受け・指示承認不具合対応 陳 start */
  .main-content-area :deep(.k-grouping-row a) {
    color: var(--master-maintenance-kgrid-item-a-color);
  }
  .main-content-area :deep(.k-grid div.k-grouping-header) {
    color: var(--master-maintenance-kgrid-item-a-color);
    background-color: var(--master-maintenance-kgrid-item-background-color);
  }
  .main-content-area :deep(.k-grid td.k-group-cell) {
    text-overflow: clip;
    color: var(--master-maintenance-kgrid-item-a-color);
    background-color: var(--master-maintenance-kgrid-item-background-color);
  }
  .main-content-area :deep(.k-grid tr.k-state-selected>td) {
    color: var(--master-maintenance-kgrid-body-color);
    background-color: rgba(0,123,255,0.25);
  }

.main-content-area :deep(.k-grid .k-table-row.k-selected>.k-table-td),
.main-content-area :deep(.k-grid .k-table-row.k-state-selected>.k-table-td) {
    color: var(--master-maintenance-kgrid-body-color);
    background-color: rgba(0,123,255,0.25);
  }
   
  /* add 指示受け・指示承認不具合対応 陳 end */
  .main-content-area :deep(.k-grid tr:hover) {
    background-color: var(--master-maintenance-kgrid-item-hover-background-color);
    color: var(--master-maintenance-kgrid-body-color);
  }
  .main-content-area :deep(.k-grid th) {
    color: #fff;
    background-color: var(--master-maintenance-kgrid-header-background-color);
  }

.main-content-area :deep(.k-grid .k-table-th) {
    color: #fff;
    background-color: var(--master-maintenance-kgrid-header-background-color);
  }
  .main-content-area :deep(.k-grid th a) {
    color: #fff;
  }

.main-content-area :deep(.k-grid .k-table-th .k-link),
.main-content-area :deep(.k-grid .k-column-title) {
    color: #fff;
  }
  .main-content-area :deep(.k-grid td) {
    border-width: 0 0 1px 1px !important;
    vertical-align: middle !important;
    /*mod FutreNetWeb+SI課題管理 3944 修正 chen start*/
    /*border-color: var(--master-maintenance-kgrid-border-color);*/
    border-color: var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3944 修正 chen end*/
    /* del #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start */
    /* 文字サイズを変更した後に指示受け（指示承認）画面を開くと、レイアウトが崩れる  6483  shan  start */
    /* word-break: break-word; */
    /* 文字サイズを変更した後に指示受け（指示承認）画面を開くと、レイアウトが崩れる  6483  shan  end */
    /* #8333 HTMLの<BR>がそのまま内容欄に表示されている sichengbo start */
    /* white-space: pre-wrap ! important; */
    /* #8333 HTMLの<BR>がそのまま内容欄に表示されている sichengbo end */
    /* del #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end */
  }

.main-content-area :deep(.k-grid .k-table-td) {
    border-width: 0 0 1px 1px !important;
    vertical-align: middle !important;
    /*mod FutreNetWeb+SI課題管理 3944 修正 chen start*/
    /*border-color: var(--master-maintenance-kgrid-border-color);*/
    border-color: var(--main-content-area-border-color);
    /*mod FutreNetWeb+SI課題管理 3944 修正 chen end*/
    /* del #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng start */
    /* 文字サイズを変更した後に指示受け（指示承認）画面を開くと、レイアウトが崩れる  6483  shan  start */
    /* word-break: break-word; */
    /* 文字サイズを変更した後に指示受け（指示承認）画面を開くと、レイアウトが崩れる  6483  shan  end */
    /* #8333 HTMLの<BR>がそのまま内容欄に表示されている sichengbo start */
    /* white-space: pre-wrap ! important; */
    /* #8333 HTMLの<BR>がそのまま内容欄に表示されている sichengbo end */
    /* del #10410 指示単位の指示受け・指示承認から指示受けor指示承認へ画面が開かない linjunfeng end */
  }
  .main-content-area :deep(.k-grid table) {
    border-right: 1px solid #fafafa;
  }
  label.selected-item {
    color: green;
  }
  .main-content-area :deep(.selected-item .k-input) {
    font-weight: bold;
  }
  .receiver-title {
    min-width: fit-content;
  }
  .icon {
    display: flex;
    align-items: center;
    height: calc(1.5em + 10px);
    padding: 5px;
    background-color: #0076ff;
    border-radius: 4px;
    line-height: 20px;
    min-width: 4em;
  }
  .icon :deep(img) {
    width: 1.5em;
  }
  .isDisabled {
    pointer-events: none;
    opacity: 0.6;
  }
  /* add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou start */
  .is-disabled {
    background-color: #aaaaaa !important;
  }
  .hide-text {
    color: #aaaaaa !important;
  }
  /* add FNSI-改修内容 治療単位の治療方法マスタの有効項目に応じた表示 dou end */
  /*add 障害票一覧_指示受け指示承認 修正 chen start*/
  .main-font .header {
    font-size: 1em;
  }
  /*add 障害票一覧_指示受け指示承認 修正 chen end*/
  /*add bug #5040 修正 shan start*/
  .radio_line{
    display: flex;
    align-items: center;
    margin-right: 1em;
  }
  .radio_line_2{
    margin-left: 0.5em;
  }
  .radio_all_2{
    margin-right: 0.2em;
  }
  /*add bug #5040 修正 shan end*/
  :deep(.k-grid-content),
  :deep(.k-grid-content-locked) {
    touch-action: manipulation !important;
    -webkit-overflow-scrolling: touch !important;
  }
  :deep(.k-chip-list) {
    display: flex !important;
    padding: 0.375rem 0.375rem;
    border-width: 0.5px 0.5px 0.5px 0.5px;
    border-style: solid;
    border-color: #e4e7eb;
  }

  .main-content-area :deep(.k-chip) {
    border-color: #e4e7eb;
    color: #212529;
    background-color: #e4e7eb;
    margin-right: 0.375rem;
    border-radius: 0.25rem;
    padding: 0.375rem;
  }

  :deep(.k-grid-container b) {
    font-weight: normal;
  }
  .omit-tip {
    position: fixed;
    z-index: 9999;
    max-width: 300px;
    padding: 8px 12px;
    background: rgba(0, 0, 0, 0.85);
    color: white;
    border-radius: 4px;
    font-size: 12px;
    line-height: 1.5;
    word-break: break-all;
    white-space: normal;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
  }
  .omit-content{
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .indication-detail-type {
    width: 100%;
    background: none;
    border-right: none !important;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
  }
  .indication-detail-type .button {
    padding: 5px;
    float: right;
    height: 2.2em;
  }
  .ok-icon {
    width: 1.5em;
  }

  :deep(.k-grid-norecords-template) {
    display: none;
  }

  :deep(.k-grid-table-wrap td) {
    border-style: solid !important;
  }
  :deep(.k-grid .k-column-resizer) {
    height: 100% !important;
  }
  :deep(.k-grid .k-column-resizer::before) {
    background-color: transparent !important;
  }
@media print {
  /* Grid全体 */
  #indication-details-id :deep(.k-grid) {
    width: 100vw !important;
  }
  /* ヘッダ */
  #indication-details-id :deep(.k-grid-header) {
    padding-right: 0 !important;
  }
  #indication-details-id :deep(.k-grid-header-wrap) {
    overflow: hidden !important;
  }
  /* ボディ */
  #indication-details-id :deep(.k-grid-content) {
    padding-right: 0 !important;
  }
  /* Virtual Scroll */
  /** スクロール位置右端 */
  #indication-details-id :deep(.k-virtual-scrollable-wrap:has(table.scroll-rightmost)) {
    overflow-y: visible !important;
    overflow-x: visible !important;
    height: auto !important;
    display: flex;
    justify-content: flex-end;
  }
  /** スクロール位置右端以外 */
  #indication-details-id :deep(.k-virtual-scrollable-wrap:not(:has(table.scroll-rightmost))) {
    overflow-y: visible !important;
    overflow-x: hidden !important;
    height: auto !important;
  }
  /* 仮想高さ領域 */
  #indication-details-id :deep(.k-height-container),
  #indication-details-id :deep(.k-scrollbar),
  #indication-details-id :deep(.k-scrollbar-vertical) {
    display: none !important;
  }
  /* table */
  #indication-details-id :deep(table) {
    table-layout: fixed !important;
  }
  /* col */
  #indication-details-id :deep(col) {
    min-width: 0 !important;
  }
  /* セル */
  #indication-details-id :deep(th),
  #indication-details-id :deep(td) {
    white-space: nowrap !important;
    overflow: hidden !important;
    text-overflow: ellipsis !important;
  }

  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  #indication-details-id :deep(.k-grid-header:has(table.scroll-rightmost)) {
    position: absolute;
    right: -2.5px;
    z-index: 1;
  }
  #indication-details-id :deep(.k-grid-header-wrap table.scroll-rightmost) {
    position: static;
  }
  #indication-details-id :deep(.k-virtual-scrollable-wrap table.scroll-rightmost) {
    position: relative;
  }

  /* ボタン非表示 */
  .actions {
    display: none !important;
  }
}
</style>
