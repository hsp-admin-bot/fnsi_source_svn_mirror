/**
* 患者の処方ページ
*/
<template>
  <div class="content">
    <div class="submenu-container">
      <v-ons-row>
        <!-- mod no 3889 画面のデザイン不正 張 start -->
        <!-- <v-ons-col width="100%" class="color-header pre-header"> -->
        <v-ons-col width="100%" class="color-header">
          <!-- mod no 3889 画面のデザイン不正 張 end -->
          <!--mod FNSI-改修内容 「処方箋」を「処方」に変更 dou start-->
          <!-- <label style="color:white">処方箋</label> -->
          <!--mod FNSI-改修内容「処方箋」を「処方」に変更 dou end-->
          <!--add FNSI-NO514 新規登録時に処方カードの名前を「処方 新規作成」とする 劉全航 start -->
          <label style="color:white">{{this.title}}</label>
          <!--add FNSI-NO514 新規登録時に処方カードの名前を「処方 新規作成」とする 劉全航 end -->
          <!--add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou start-->
          <label style="color:white; margin-left:9.9em" v-if="sharedFlag">{{ getFacilityName }}</label>
          <!--add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou end-->
        </v-ons-col>
      </v-ons-row>
      <div class="scroll">
        <v-ons-row class="condition-row">
          <v-ons-col width="15%" vertical-align="center">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-radio -->
            <!--     value="1" -->
            <!--     input-id="outside-hospital" -->
            <!--     v-model="inputModel.checkHos" -->
            <!--     modifier="round" -->
            <!--     class="popover-content-radio radio-button radio-button--round" -->
            <!--     :disabled="inputModel.issued" -->
            <!-- ></v-ons-radio> -->
            <v-ons-radio
                value="1"
                input-id="outside-hospital"
                v-model="inputModel.checkHos"
                modifier="round"
                class="popover-content-radio radio-button radio-button--round"
              :disabled="inputModel.issued || !getItemAuthorized('PatPrescription', 'default_authority') || isOtherFacility(inputModel.facilityCd)"
            ></v-ons-radio>
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <label for="outside-hospital" :class="['label-title', isEdited('checkHos')]" @click="!inputModel.issued ? inputModel.checkHos = '1' : ''">院外</label>
          </v-ons-col>
          <v-ons-col width="15%" vertical-align="center">
            <!-- mod #10359 編集権限の動作不正 dengshen start -->
            <!-- <v-ons-radio -->
            <!--     value="2" -->
            <!--     input-id="hospital" -->
            <!--     v-model="inputModel.checkHos" -->
            <!--     modifier="round" -->
            <!--     class="popover-content-radio radio-button radio-button--round" -->
            <!--     :disabled="inputModel.issued" -->
            <!-- ></v-ons-radio> -->
            <v-ons-radio
                value="2"
                input-id="hospital"
                v-model="inputModel.checkHos"
                modifier="round"
                class="popover-content-radio radio-button radio-button--round"
              :disabled="inputModel.issued || !getItemAuthorized('PatPrescription', 'default_authority') || isOtherFacility(inputModel.facilityCd)"
            ></v-ons-radio>
            <!-- mod #10359 編集権限の動作不正 dengshen end -->
            <label for="hospital" :class="['label-title', isEdited('checkHos')]" @click="!inputModel.issued ? inputModel.checkHos = '2' : ''">院内</label>
          </v-ons-col>
        </v-ons-row>
        <div class="condition-container">
          <div class="condition-row">
            <div class="col-1">
              <div class="condition-title input-header">
                <label class="label-title">交付日</label>
              </div>
              <div width="42%" vertical-align="center" class="condition-input">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <date-input -->
                <!--   v-model="inputModel.startDate" -->
                <!--   class="input unstyled-date" -->
                <!--   :classes="'input-area ntss-input-date ntss-custom-input date-input-required date-input-focus ' +isEdited('startDate')" -->
                <!--   :disabled="inputModel.issued" -->
                <!--   max="2099-12-31" -->
                <!--   isRequired -->
                <!-- /> -->
                <date-input
                  v-model="inputModel.startDate"
                  class="input unstyled-date"
                  :classes="'input-area ntss-input-date ntss-custom-input date-input-required date-input-focus ' +isEdited('startDate')"
                  :disabled="inputModel.issued || !getItemAuthorized('PatPrescription', 'default_authority') || isOtherFacility(inputModel.facilityCd)"
                  max="2099-12-31"
                  isRequired
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <div class="calendar">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <common-calendar v-model="inputModel.startDate" :disabled="inputModel.issued" /> -->
      <common-calendar v-model="inputModel.startDate" :disabled="inputModel.issued || !getItemAuthorized('PatPrescription', 'default_authority') || isOtherFacility(inputModel.facilityCd)" />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </div>
              </div>
            </div>
            <div class="col-2">
              <div class="condition-title input-header">
                <label class="label-title">使用期間</label>
              </div>
              <div width="42%" vertical-align="center" class="condition-input">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <date-input -->
                <!--   v-model="inputModel.endDate" -->
                <!--   class="input unstyled-date" -->
                <!--   :classes="'input-area ntss-input-date ntss-custom-input date-input-required date-input-focus ' +isEdited('endDate')" -->
                <!--   :disabled="inputModel.issued" -->
                <!--   max="2099-12-31" -->
                <!--   isRequired -->
                <!-- /> -->
                <date-input
                  v-model="inputModel.endDate"
                  class="input unstyled-date"
                  :classes="'input-area ntss-input-date ntss-custom-input date-input-required date-input-focus ' +isEdited('endDate')"
                  :disabled="inputModel.issued || !getItemAuthorized('PatPrescription', 'default_authority') || isOtherFacility(inputModel.facilityCd)"
                  max="2099-12-31"
                  isRequired
                />
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                <div class="calendar">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <common-calendar v-model="inputModel.endDate" :disabled="inputModel.issued" /> -->
      <common-calendar v-model="inputModel.endDate" :disabled="inputModel.issued || !getItemAuthorized('PatPrescription', 'default_authority') || isOtherFacility(inputModel.facilityCd)" />
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                </div>
              </div>
            </div>
          </div>
          <div class="condition-row">
            <div class="col-1">
              <div class="condition-title input-header">
                <label class="label-title">保険</label>
              </div>
              <div class="condition-input">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <v-ons-select -->
                <!--     id="insurance" -->
                <!--     class="custom-dropdownlist" -->
                <!--     v-model="selectInsurance" -->
                <!--     :disabled="inputModel.issued" -->
                <!--     @change="isDoctorEmpty('insurance')" -->
                <!-- > -->
                <v-ons-select
                    id="insurance"
                    :class="['custom-dropdownlist', isEdited('insurance')]"
                    v-model="selectInsurance"
                    :disabled="inputModel.issued || !getItemAuthorized('PatPrescription', 'default_authority') || isOtherFacility(inputModel.facilityCd)"
                  @change="isDoctorEmpty('insurance')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <template v-for="item in listPatInsurance">
                    <option :key="item.insuranceCd" :value="item.insuranceCd">{{ item.insuName }}</option>
                  </template>
                </v-ons-select>
                <!-- <kendo-dropdownlist
                  id="insurance"
                  class="custom-dropdownlist"
                  v-model="selectInsurance"
                  :data-source="listPatInsurance"
                  :data-text-field="'insuName'"
                  :data-value-field="'insuranceCd'"
                  :disabled="isIssued"
                  @change="isDoctorEmpty('insurance')"
                  @open="onOpenInsuranceDouble"
                >
                </kendo-dropdownlist> -->
              </div>
            </div>
            <div class="col-2">
              <div class="condition-title input-header">
                <label class="label-title">保険医</label>
              </div>
              <div class="condition-input">
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <v-ons-select -->
                <!--     id="insuranceDoctor" -->
                <!--     class="custom-dropdownlist" -->
                <!--     v-model="selectDoctor" -->
                <!--     :disabled="inputModel.issued" -->
                <!--     @change="isDoctorEmpty('insuranceDoctor')" -->
                <!-- > -->
                <v-ons-select
                    id="insuranceDoctor"
                    :class="['custom-dropdownlist', isEdited('insuranceDoctor')]"
                    v-model="selectDoctor"
                  :disabled="inputModel.issued || !getItemAuthorized('PatPrescription', 'default_authority') || isOtherFacility(inputModel.facilityCd)"
                    @change="isDoctorEmpty('insuranceDoctor')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <template v-for="item in listDoctor">
                    <option :key="item.user_id" :value="item.user_id">{{ item.fullName }}</option>
                  </template>
                </v-ons-select>
                <!-- <kendo-dropdownlist
                  id="insuranceDoctor"
                  class="custom-dropdownlist"
                  :class="doctorClassCtrl.classObject"
                  v-model="selectDoctor"
                  :data-source="listDoctor"
                  :data-text-field="'fullName'"
                  :data-value-field="'user_id'"
                  :disabled="isIssued"
                  @change="isDoctorEmpty('insuranceDoctor')"
                  @open="onOpenInsurance"
                >
                </kendo-dropdownlist> -->
              </div>
            </div>
          </div>
        </div>
        <!-- 処方エリア -->
        <v-ons-row class="condition-row custom-border-top">
          <!-- ヘッダ -->
          <v-ons-row>
            <v-ons-col class="custom-btn-area">
              <v-ons-row class="custom-button-figure">
                <v-ons-col class="row-buttons">
                    <label class="label-title"><b>処方</b></label>
                  <v-ons-col></v-ons-col>
                </v-ons-col>
                <v-ons-col style="width: 4.2em;">
                  <v-ons-button
                    ref="prescriptionSetBtn"
                    class="btn3-normal common-style-select-button"
                    @click="createPopoverDataPrescriptionSet($refs.prescriptionSetBtn, getFacilityCd, -1)"
                    :disabled="isOtherFacility(inputModel.facilityCd)"
                  >処方ｾｯﾄ</v-ons-button>
                </v-ons-col>
                <pop-over
                  v-bind="popoverDataPrescriptionSet"
                  :target-position-element="popoverPrescriptionTarget"
                  @popover-close="closePopoverPrescriptionSet"
                  @popover-return="(data) => {
                    comfirmShowing = true;
                    comfirmUpdatePrescriptionSet(data);
                  }"
                />
              </v-ons-row>
            </v-ons-col>
            <v-ons-col class="custom-input-area">
              <v-ons-row class="custom-element-input-area" style="max-width: 2.5em;"><label class="label-title">後発<br/>不可</label></v-ons-row>
              <v-ons-row class="custom-element-input-area" style="max-width: 2.5em;"><label class="label-title">患者<br/>希望</label></v-ons-row>
              <v-ons-row class="custom-element-input-area"><label class="label-title">薬剤・用法</label></v-ons-row>
              <v-ons-row class="custom-element-input-area" style="max-width: 5em;"><label class="label-title">数量</label></v-ons-row>
              <v-ons-row class="custom-element-input-area" style="max-width: 7em;"><label class="label-title">単位</label></v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- 明細行 -->
          <draggable
              v-model="dataList"
              handle=".dragg"
              v-bind="dragOptions"
              style="width:100%"
              class="draggable-area"
              @start="onDragStart"
              @end="onDragEnd"
              @change="refacterDataList"
              :move="onMove"
              :disabled="!getItemAuthorized('PatPrescription', 'default_authority') || isOtherFacility(inputModel.facilityCd)"
          >
            <v-ons-row
                v-for="(item, index) in getEditRecord"
                :key="`${item.uniqueId}-${index}`"
                class="prescription-detail-row"
                :class="{
                  'sortable-chosen': isDraggItem(index),
                  'sortable-related': isGhost(index) && !isDraggItem(index),
                  'ghost': isGhost(index),
                  'master-edited-row': !getIsEdit || (index !== 0 && item.isNew)
                }"
            >
              <!-- NOTE: 処方列（各ボタン：削除・並び替え・追加のエリア） -->
              <v-ons-col class="custom-btn-area">
                <v-ons-row class="custom-button-figure">
                  <v-ons-col class="row-buttons">
                    <!-- Rp1の場合はボタン非表示 -->
                    <span class="row-buttons-span" :style="{ display: (item.dataButtonNo === 1 && item.index === 0) ? 'none' : '' }">
                      <ons-toolbar-button
                        class="close-btn manual-close-btn"
                        style="line-height: 1.875em";
                        :disabled="
                          inputModel.issued ||
                          !getItemAuthorized(
                            'PatPrescription',
                            'default_authority'
                          ) ||
                          isOtherFacility(inputModel.facilityCd)
                        "
                        @click="deleteCols(index)"
                      >
                        <ons-icon icon="fa-times"></ons-icon>
                      </ons-toolbar-button>
                      <ons-toolbar-button
                        class="close-btn manual-close-btn"
                        :class="{ 'moved-row': isMoved(item.uniqueId) }"
                        :disabled="
                          inputModel.issued ||
                          !getItemAuthorized(
                            'PatPrescription',
                            'default_authority'
                          )||
                          isOtherFacility(inputModel.facilityCd)
                        "
                      >
                        <ons-icon icon="fa-sort" class="dragg"></ons-icon>
                      </ons-toolbar-button>
                    </span>
                    <v-ons-col>
                      <v-ons-button
                        class="btn3-normal common-style-select-button"
                        :disabled="
                          inputModel.issued ||
                          !getItemAuthorized(
                            'PatPrescription',
                            'default_authority'
                          )||
                          isOtherFacility(inputModel.facilityCd)
                        "
                        :style="{ display: (item.dataButtonNo === 1 && item.index === 0) ? 'none' : '' }"
                        @click="showPopoverToChange($event,item.dataButtonName,index)"
                      >{{ item.dataButtonName }}
                      </v-ons-button>
                    </v-ons-col>
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
              <!-- NOTE: 薬剤・用法、数量、単位列 -->
              <v-ons-col class="custom-input-area">
                <v-ons-row
                  class="custom-element-input-area"
                  v-for="(itemChild, i) in item.buttonItems"
                  :style="{ width: itemChild.itemWidth, maxWidth: itemChild.itemMaxWidth, minWidth: itemChild.itemMinWidth }"
                  :key="`${item.index}-${itemChild.itemName}-${item.dataButtonNo}`"
                  :class="{
                    'rx-drug-f1-wrap': item.dataButtonNo === 2 && itemChild.itemName === 'F1',
                    'rx-drug-f2-wrap': item.dataButtonNo === 2 && itemChild.itemName === 'F2'
                  }"
                >
                  <v-ons-col
                    class="custom-checkbox custom-element-input-area-inner"
                    v-if="itemChild.itemName == 'check-box1' && itemChild.type == 'checkBox' && itemChild.hidden == false"
                  >
                    <v-ons-checkbox
                      v-model="itemChild.itemValue"
                      :disabled="
                        inputModel.issued ||
                        !getItemAuthorized(
                          'PatPrescription',
                          'default_authority'
                        ) ||
                        isOtherFacility(inputModel.facilityCd)
                      "
                    >
                    </v-ons-checkbox>
                  </v-ons-col>
                  <v-ons-col
                    class="custom-checkbox custom-element-input-area-inner"
                    v-if="itemChild.itemName == 'check-box2' && itemChild.type == 'checkBox' && itemChild.hidden == false"
                  >
                    <v-ons-checkbox
                      v-model="itemChild.itemValue"
                      :disabled="
                        inputModel.issued ||
                        !getItemAuthorized(
                          'PatPrescription',
                          'default_authority'
                        ) ||
                        isOtherFacility(inputModel.facilityCd)
                      "
                    >
                    </v-ons-checkbox>
                  </v-ons-col>
                  <v-ons-col class="custom-element-input-area-inner" v-else-if="itemChild.type == 'text' && itemChild.hidden == false">
                    <v-ons-input
                      type="text"
                      class="input disabled-input"
                      :class="isEditedDataList(item, itemChild.itemName, 'ons')" 
                      style="width: 100%"
                      :disabled="
                        (itemChild.disabled ? true : false) ||
                        inputModel.issued ||
                        !getItemAuthorized(
                          'PatPrescription',
                          'default_authority'
                        ) ||
                        isOtherFacility(inputModel.facilityCd)
                      "
                      v-model="itemChild.itemValue"
                    ></v-ons-input>
                  </v-ons-col>
                  <v-ons-col class="col-rp custom-element-input-area-inner" v-else-if="itemChild.type == 'text-readonly' && itemChild.hidden == false">
                    <ons-toolbar-button class="toolbar-button-rp">
                      <ons-icon icon="fa-sort" class="dragg dragg-rp"></ons-icon>
                    </ons-toolbar-button>
                    <v-ons-input
                      type="text"
                      class="input rp-input disabled-input"
                      :disabled="
                        (itemChild.disabled ? true : false) ||
                        inputModel.issued ||
                        !getItemAuthorized(
                          'PatPrescription',
                          'default_authority'
                        ) ||
                        isOtherFacility(inputModel.facilityCd)
                      "
                      :value="'Rp' + itemChild.itemValue"
                    ></v-ons-input>
                  </v-ons-col>
                  <v-ons-col v-else-if="itemChild.type == 'button' && itemChild.hidden == false" class="custom-element-input-area-inner">
                    <v-ons-button
                      class="btn3-normal common-style-select-button"
                      :disabled="
                        inputModel.issued ||
                        !getItemAuthorized(
                          'PatPrescription',
                          'default_authority'
                        ) ||
                        isOtherFacility(inputModel.facilityCd)
                      "
                      @click="showModal(index)"
                    >選択</v-ons-button>
                  </v-ons-col>
                  <v-ons-col
                    v-else-if="itemChild.type == 'dataList' && itemChild.hidden == false && itemChild.itemName == 'F6' && item.dataButtonNo != 2"
                    class="datalist custom-element-input-area-inner"
                  >
                    <v-ons-select
                      :id="`myDropdown${index}-list`"
                      v-model="itemChild.itemValue"
                      data-non-authorize="true"
                      style="width:-webkit-fill-available;"
                      :disabled="
                        inputModel.issued ||
                        !getItemAuthorized(
                          'PatPrescription',
                          'default_authority'
                        ) ||
                        isOtherFacility(inputModel.facilityCd)
                      "
                      @change="onOpen(index)"
                      :class="isEditedDataList(item, itemChild.itemName, 'ons')">
                      <template v-for="item in timeList">
                        <option :key="item" :value="item">{{ item }}</option>
                      </template>
                    </v-ons-select>
                  </v-ons-col>
                  <v-ons-col
                    v-else-if="itemChild.type == 'dataList' && itemChild.hidden == false && itemChild.listClass != null"
                    class="datalist position-input custom-element-input-area-inner"
                  >
                    <div class="position-relative" style="width:-webkit-fill-available;">
                      <input
                        :id="'input-' + index + '-' + i"
                        type="text"
                        autocomplete="off"
                        v-model="itemChild.itemValue"
                        style="width:-webkit-fill-available;"
                        :class="[!itemChild.showSelectFlagdouble ? '' : 'select-inputcolor', isEditedDataList(item, itemChild.itemName)]"
                        :disabled="
                          inputModel.issued ||
                          !getItemAuthorized(
                            'PatPrescription',
                            'default_authority'
                          ) ||
                        isOtherFacility(inputModel.facilityCd)
                        "
                        @focus="changeListInput(index, i, 'focus')"
                        @blur="listBlur(itemChild.itemValue, index, i)"
                        @input="inputChange(itemChild.itemValue, listDetailMedicine(itemChild.listClass))">
                      <span
                        class="k-icon down-arrow"
                        id="myInput"
                        @mousedown="
                          (getItemAuthorized('PatPrescription', 'default_authority') && !inputModel.issued) ? (
                            changeListInput(index, i, 'mousedown'),
                            itemChild.showSelectFlag = (itemChild.showSelectFlag ? false : true)
                          ) : ''
                        "
                      ></span>
                    </div>
                    <ul class="form-ul" style="width:-webkit-fill-available;" v-if="itemChild.showSelectFlag">
                      <li
                        id="myElement"
                        v-for="(item, idx) in arrFlag ? arr : listDetailMedicine(itemChild.listClass)"
                        :key="idx"
                        :class="[itemChild.itemValue == item && colorFlag ? 'bacground-highlight' : 'bacground-color', !itemChild.showSelectFlagdouble ? 'colora' : 'colorb']"
                        v-show="!emptyFlag"
                        @mousedown="itemChild.itemValue = item; itemChild.showSelectFlag = (itemChild.showSelectFlag ? false : true)"
                        @mouseover="mouseover"
                      >{{ item }}</li>
                      <div class="empty-style" v-show="emptyFlag">NO DATA FOUND</div>
                    </ul>
                  </v-ons-col>
                  <v-ons-col
                    v-else-if="itemChild.type == 'dataList' && itemChild.hidden == false"
                    class="datalist custom-element-input-area-inner"
                  >
                    <v-ons-select
                        :id="`myDropdown${index}-list`"
                        v-model="itemChild.itemValue"
                        data-non-authorize="true"
                        style="width:-webkit-fill-available;"
                        :disabled="
                        inputModel.issued ||
                        !getItemAuthorized(
                          'PatPrescription',
                          'default_authority'
                        ) ||
                        isOtherFacility(inputModel.facilityCd)
                      "
                        :class="isEditedDataList(item, itemChild.itemName, 'ons')"
                        @change="onOpen(index)"
                    >
                      <template v-for="item in getUnit(itemChild.dataList)">
                        <option :key="item" :value="item">{{ item }}</option>
                      </template>
                    </v-ons-select>
                  </v-ons-col>
                  <v-ons-col v-else-if="itemChild.type == 'number' && itemChild.hidden == false" style="display:flex; justify-content: center; align-items: center; margin-left: 5px;">
                    <v-ons-input
                      :id="'number-' + index + '-' + i"
                      type="number"
                      class="input number-input"
                      :class="isEditedDataList(item, itemChild.itemName, 'ons')"
                      style="width:100%"
                      :step="unitStep(itemChild.unitDecimalPoint)"
                      :disabled="
                        (itemChild.disabled ? true : false) ||
                        inputModel.issued ||
                        !getItemAuthorized(
                          'PatPrescription',
                          'default_authority'
                        ) ||
                        isOtherFacility(inputModel.facilityCd)
                      "
                      v-model="itemChild.itemValue"
                      @change="changeValuePoint(itemChild.unitDecimalPoint,index, i, $event)"
                      @mousewheel.prevent="stopScrollFun(index, i, $event)"
                      @blur="formatValue(index, i, $event)"
                      @focus="handleFocus(i)"
                    ></v-ons-input>
                  </v-ons-col>
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
          </draggable>
          <!-- 余白行 -->
          <v-ons-row>
            <v-ons-col class="custom-btn-area">
              <v-ons-row class="custom-button-figure">
                <v-ons-col class="row-buttons">
                    <span class="row-buttons-span"></span>
                  <v-ons-col>
                    <v-ons-button
                      class="btn3-normal common-style-select-button"
                      :disabled="
                        inputModel.issued ||
                        !getItemAuthorized(
                          'PatPrescription',
                          'default_authority'
                        ) ||
                        isOtherFacility(inputModel.facilityCd)
                      "
                      @click="showPopoverToAdd($event)"
                    >追加</v-ons-button>
                    <v-ons-popover
                      cancelable
                      :visible.sync="popoverVisible"
                      :target="popoverTarget"
                      :direction="popoverDirection"
                      :cover-target="false"
                      :class="[fontSizeSet, 'grid']"
                      @preshow="popoverPreShow"
                      @postshow="popoverPostShow"
                      @posthide="popoverPosthide"
                    >
                      <div v-for="(item, index) in listButton" :key="index" class="grid-item">
                        <v-ons-button class="button btn3-normal" style="width:100%;" @click="onClickButton(item, popoverTarget, getFacilityCd)">{{ item }}</v-ons-button>
                      </div>
                    </v-ons-popover>
                  </v-ons-col>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col vertical-align="center" class="custom-input-area">
              <v-ons-row class="custom-element-input-area" style="max-width: 5em;"></v-ons-row>
              <v-ons-row style="display: flex;justify-content: center;align-items: center;width: 100%;margin-left:5px;">
                <v-ons-input
                  type="text"
                  id="add"
                  class="input add-btn disabled-input"
                  style="width:100%;"
                  value="────────以下余白─────────"
                  disabled
                />
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
          <!-- リフィル行 -->
          <v-ons-row>
            <v-ons-col class="custom-btn-area">
              <v-ons-row class="custom-button-figure">
                <v-ons-col class="row-buttons">
                    <span class="row-buttons-span"></span>
                  <v-ons-col></v-ons-col>
                </v-ons-col>
              </v-ons-row>
            </v-ons-col>
            <v-ons-col vertical-align="center" class="custom-input-area">
              <v-ons-row class="custom-element-input-area" style="max-width: 5em;"></v-ons-row>
              <v-ons-row class="refill-inline">
                <label :class="['label-title', 'refill-label', isEdited('isRefill')]" @click="!inputModel.issued ? (inputModel.isRefill = !inputModel.isRefill) : ''">
                  リフィル可
                </label>
                <v-ons-checkbox
                  v-model="inputModel.isRefill"
                  class="refill-checkbox"
                  :disabled="
                    inputModel.issued ||
                    !getItemAuthorized('PatPrescription', 'default_authority') ||
                    isOtherFacility(inputModel.facilityCd)
                  "
                ></v-ons-checkbox>
                <label class="refill-paren">（</label>
                <v-ons-input
                  id="refillNum"
                  type="number"
                  :class="['input', 'number-input', 'refill-number', isEdited('refillNum')]"
                  min="1"
                  max="3"
                  :disabled="
                    inputModel.issued ||
                    !getItemAuthorized('PatPrescription', 'default_authority') ||
                    isOtherFacility(inputModel.facilityCd)
                  "
                  v-model="inputModel.refillNum"
                  @mousewheel.prevent="onRefillWheel"
                  @blur="onRefillBlur"
                  @focus="onRefillFocus"
                >
                </v-ons-input>
                <label class="refill-unit">回</label>
                <label class="refill-paren">）</label>
              </v-ons-row>
            </v-ons-col>
          </v-ons-row>
        </v-ons-row>

        <div>
          <v-ons-row class="custom-condition-row">
            <v-ons-col width="10%" vertical-align="center">
              <label class="label-title">
                <b>備考</b>
              </label>
            </v-ons-col>
            <v-ons-col width="20%" vertical-align="center">
              <label class="label-title">調剤時の残薬確認時の対応</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-checkbox :disabled="inputModel.issued" v-model="inputModel.isDoubt"></v-ons-checkbox> -->
              <v-ons-checkbox
                v-model="inputModel.isDoubt"
                :disabled="
                  inputModel.issued ||
                  !getItemAuthorized('PatPrescription', 'default_authority') ||
                    isOtherFacility(inputModel.facilityCd)
                "
              ></v-ons-checkbox>
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <label :class="['label-title', isEdited('isDoubt')]" @click="!inputModel.issued ? inputModel.isDoubt = !inputModel.isDoubt : ''">保険医療機関へ疑義照会の上で調剤</label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="custom-condition-row">
            <v-ons-col width="30%" vertical-align="center" />
            <v-ons-col vertical-align="center">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-checkbox :disabled="inputModel.issued" v-model="inputModel.isInformation"></v-ons-checkbox> -->
              <v-ons-checkbox
                v-model="inputModel.isInformation"
                :disabled="
                  inputModel.issued ||
                  !getItemAuthorized('PatPrescription', 'default_authority') ||
                    isOtherFacility(inputModel.facilityCd)
                "
              ></v-ons-checkbox>
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <label :class="['label-title', isEdited('isInformation')]" @click="!inputModel.issued ? inputModel.isInformation = !inputModel.isInformation : ''">保険医療機関へ情報提供</label>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="custom-condition-row">
            <v-ons-col width="10%" vertical-align="center" />
            <v-ons-col width="80%" vertical-align="center">
              <div style="display: flex">
                <div style="margin-right: 15px">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <v-ons-checkbox :disabled="inputModel.issued" v-model="inputModel.isElderly"></v-ons-checkbox> -->
                  <v-ons-checkbox
                    v-model="inputModel.isElderly"
                    :disabled="
                      inputModel.issued ||
                      !getItemAuthorized('PatPrescription', 'default_authority') ||
                      isOtherFacility(inputModel.facilityCd)
                    "
                  ></v-ons-checkbox>
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <label :class="['label-title', isEdited('isElderly')]" @click="!inputModel.issued ? inputModel.isElderly = !inputModel.isElderly : ''">高一</label>
                </div>
                <div style="margin-right: 15px">
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <v-ons-checkbox :disabled="inputModel.issued" v-model="inputModel.isElderly7"></v-ons-checkbox> -->
                  <v-ons-checkbox
                    v-model="inputModel.isElderly7"
                    :disabled="
                      inputModel.issued ||
                      !getItemAuthorized('PatPrescription', 'default_authority') ||
                      isOtherFacility(inputModel.facilityCd)
                    "
                  ></v-ons-checkbox>
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <label :class="['label-title', isEdited('isElderly7')]" @click="!inputModel.issued ? inputModel.isElderly7 = !inputModel.isElderly7 : ''">高７</label>
                </div>
                <div>
                  <!-- mod #10359 編集権限の動作不正 dengshen start -->
                  <!-- <v-ons-checkbox :disabled="inputModel.issued" v-model="inputModel.isChild"></v-ons-checkbox> -->
                  <v-ons-checkbox
                    v-model="inputModel.isChild"
                    :disabled="
                      inputModel.issued ||
                      !getItemAuthorized('PatPrescription', 'default_authority') ||
                      isOtherFacility(inputModel.facilityCd)
                    "
                  ></v-ons-checkbox>
                  <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <label :class="['label-title', isEdited('isChild')]" @click="!inputModel.issued ? inputModel.isChild = !inputModel.isChild : ''">６歳未満</label>
                </div>
              </div>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="custom-condition-row">
            <v-ons-col width="10%" vertical-align="center" />
            <v-ons-col vertical-align="center">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <v-ons-checkbox :disabled="inputModel.issued" v-model="inputModel.isAnesthesia"></v-ons-checkbox> -->
              <v-ons-checkbox
                v-model="inputModel.isAnesthesia"
                :disabled="
                  inputModel.issued ||
                  !getItemAuthorized('PatPrescription', 'default_authority') ||
                  isOtherFacility(inputModel.facilityCd)
                "
              ></v-ons-checkbox>
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
              <!-- <label class="label-title" @click="inputModel.isAnesthesia = !inputModel.isAnesthesia">麻酔薬含む</label> -->
              <!--mod FutreNetWeb+SI課題管理-NO.4494 劉全航 start-->
              <label :class="['label-title', isEdited('isAnesthesia')]" @click="!inputModel.issued ? inputModel.isAnesthesia = !inputModel.isAnesthesia : ''">麻薬含む</label>
              <!--mod FutreNetWeb+SI課題管理-NO.4494 劉全航 end-->
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="condition-row">
            <v-ons-col width="10%" vertical-align="center">
              <label class="label-title">ﾌﾘｰｺﾒﾝﾄ</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <!-- mod #10359 編集権限の動作不正 dengshen start -->
              <!-- <com-textarea -->
              <!--     :content="inputModel.remarksFree" -->
              <!--     idTextarea="com-textarea-remark-free" -->
              <!--     cssClass="com-textarea textarea-custom-text-font textarea-resize-vertical" -->
              <!--     @set-content-data="setContentData" -->
              <!--     :disabled="inputModel.issued" -->
              <!-- /> -->
              <com-textarea
                  :content="inputModel.remarksFree"
                  idTextarea="com-textarea-remark-free"
                  :cssClass="['com-textarea', 'textarea-custom-text-font', 'textarea-resize-vertical', isEdited('remarksFree')]"
                  @set-content-data="setContentData"
                :disabled="
                  inputModel.issued ||
                  !getItemAuthorized('PatPrescription', 'default_authority') ||
                  isOtherFacility(inputModel.facilityCd)
                "
              />
              <!-- mod #10359 編集権限の動作不正 dengshen end -->
            </v-ons-col>
          </v-ons-row>
        </div>
        <!-- mod FNSI-処方削除ボタンのアクションが不正 劉全航 start -->
        <!-- <div> -->
        <!-- <v-ons-row v-if="canDelete" class="condition-row" style="border-top: 1px solid"> -->
        <!-- <v-ons-col width="10%" vertical-align="center" style="padding: 10px 0 0 5px"> -->
        <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 start-->
        <!-- <v-ons-button class="button registration-btn footer-btn" @click="deleteOrder">削除</v-ons-button> -->
        <!-- <v-ons-button class="btn4-alert" @click="deleteOrder">削除</v-ons-button> -->
        <!--mod 画面部品デザイン定義 ボタンスタイル 劉全航 end-->
        <!-- </v-ons-col> -->
        <!-- </v-ons-row> -->
        <!-- </div> -->
        <!-- mod FNSI-処方削除ボタンのアクションが不正 劉全航 end -->
      </div>
    </div>
    <div id="prescription-footer" class="btn-area nowrap-block footer custom-footer">
      <div>
        <v-ons-button v-if="!getIsEdit" class="common-style-cancel-button btn2-cancel" @click="cancel()">キャンセル</v-ons-button>
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button v-if="getIsEdit && canDelete" class="btn4-alert common-style-cancel-button" @click="deleteOrder">削除</v-ons-button> -->
        <!-- mod #10359_NG対応 編集権限の動作不正 dengshen start -->
        <!-- <v-ons-button -->
        <!--   v-if="getIsEdit && getItemAuthorized('PatPrescription', 'item_delete_btn')" -->
        <!--   class="btn4-alert common-style-cancel-button" -->
        <!--   @click="deleteOrder">削除</v-ons-button> -->
        <v-ons-button
          v-if="getIsEdit"
          :style="{
            opacity:
              !getItemAuthorized('PatPrescription', 'item_delete_btn') ||
              isOtherFacility(inputModel.facilityCd)
                ? 0.6
                : 1
          }"
          class="btn4-alert common-style-cancel-button"
          @click="deleteOrder"
          :disabled="isOtherFacility(inputModel.facilityCd)"
          >削除</v-ons-button
        >
        <!-- mod #10359_NG対応 編集権限の動作不正 dengshen end -->
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <v-ons-button
            v-if="getOrdPrescriptionNo > 0"
            class="btn3-normal"
            @click="copyAndCreate()"
            style="margin-left: 0.5em;width: 9.375em"
            :disabled="isEditDisabled || isOtherFacility(inputModel.facilityCd)"
        >コピーして新規登録</v-ons-button>
      </div>
      <div class="custom-registration-btn-area nowrap-block">
        <div class="custom-checkbox">
          <!-- mod #10359 編集権限の動作不正 dengshen start -->
          <!--<v-ons-checkbox v-model="inputModel.issued"></v-ons-checkbox> -->
          <v-ons-checkbox
            v-model="inputModel.issued"
            :disabled="
              !getItemAuthorized('PatPrescription', 'default_authority') ||
              isOtherFacility(inputModel.facilityCd)
            "
          ></v-ons-checkbox>
          <!-- mod #10359 編集権限の動作不正 dengshen end -->
          <label :class="['label-title', isEdited('issued')]" @click="!inputModel.issued ? inputModel.issued = !inputModel.issued : ''">交付済み</label>
        </div>
        <!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc start-->
        <v-ons-button class="btn1-execute common-style-ok-button" @click="register" v-if="!sharedFlag" :disabled="isEditDisabled || !this.isChanged">保存</v-ons-button>
        <v-ons-button class="btn1-execute common-style-ok-button" @click="register" :disabled="getOtherFacilityFlag || isEditDisabled || !this.isChanged" v-if="sharedFlag">保存</v-ons-button>
        <!--        mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc end-->
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import moment from "moment";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import vuedraggable from "vuedraggable";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { EventBus } from "@/eventBus.js";
// mod #10359 編集権限の動作不正 dengshen start
// import { deepCopy } from "@/functions/common/CommonFunctions";
import { deepCopy, getAuthorized } from "@/functions/common/CommonFunctions";
// mod #10359 編集権限の動作不正 dengshen end
import { isEqual } from 'lodash';
import PopoverMixin from "@/components/PopoverMixin";
import PatPrescriptionMixin from "./PatPrescriptionMixin";
import CommonTextArea from "@/components/common/CommonTextArea";
// add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou start
import { ApiHelper } from "../../apis/AxiosHelper";
// add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou end
//mod 横展開管理台帳_日機装FNSI NO.1 劉全航 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//mod 横展開管理台帳_日機装FNSI NO.1 劉全航 end
import MasterSelector from "@/components/common/master-selector/MasterSelector";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import { makeRequiredClassConrtoller } from "@/functions/for-componet/ClassControlFunctions.js";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import DateInput from "@/components/common/DateInput.vue";
import IndUserSelectMixin from "@/components/common/IndUserSelectMixin";
import { sendRequestFindRecordListByFacilityCd } from "@/apis/master-maintenance";
import { confirmIsOkByKey } from "@/functions/common/OnsenFunctions";
import { 
  TABOO_CLASS_PREFIX,
  ALLERGY_CLASS_PREFIX,
  TABOO_ALLERGY_CLASS_PREFIX
} from "@/constants/patPrescriptionConstants";

const toDateInputValue = (dateString) => !dateString ? "" : moment(dateString).format("YYYY-MM-DD");

export default {
  mixins: [PopoverMixin, IndUserSelectMixin, PatPrescriptionMixin],
  name: "PatPrescriptionDetailComponent",
  props: ["propsIsHideMainList"],
  components: {
    "common-calendar": commonCalender,
    "draggable": vuedraggable,
    "com-textarea": CommonTextArea,
    "date-input": DateInput,
    "pop-over": MasterSelector,
  },
  data() {
    return {
      isEditDisabled: false,
      // add FNSI-改修内容 基本は他施設の場合には、画面項目編集不可 dou start
      facilityName: "",
      sharedFlag: false,
      // add FNSI-改修内容 基本は他施設の場合には、画面項目編集不可 dou end
      contentsAreaHeight: 200,
      inputModel: {
        startDate: "",
        endDate: "",
        checkHos: "1",
        isChild: false,
        isDoubt: false,
        isInformation: false,
        isElderly: false,
        isElderly7: false,
        isAnesthesia: false,
        doctor: "",
        patInsurance: 0,
        issued: false,
        remarksFree: "",
        isRefill: false,
        refillNum: NaN,
      },
      getIndexRow: -1,
      listDoctor: [],
      patInsurance: {
        data: [
          {
            insuName: "",
            insuranceCd: "0&",
            isDel: 0,
            isSelected: null
          }
        ]
      },
      listPatInsurance: [],
      newOrder: [],
      selectDoctor: null,
      selectInsurance: null,
      doctorResponse: null,
      //add FNSI-NO514 新規登録時に処方カードの名前を「処方 新規作成」とする 劉全航 start
      title: "処方",
      //add FNSI-NO514 新規登録時に処方カードの名前を「処方 新規作成」とする 劉全航 end
      //add 横展開管理台帳_日機装FNSI NO.1 劉全航 start
      errorDateMessage: DIALOG_MESSAGES["99999995"].message,
      //add 横展開管理台帳_日機装FNSI NO.1 劉全航 end
      //add 横展開管理台帳_日機装FNSI NO.15 劉全航 start
      originalDoctor: null,
      originalInsurance: null,
      //add 横展開管理台帳_日機装FNSI NO.15 劉全航 end
      startDateClassCtrl: makeRequiredClassConrtoller(true),
      endDateClassCtrl: makeRequiredClassConrtoller(true),
      doctorClassCtrl: makeRequiredClassConrtoller(false),
      //add FNSI-横展開管理台帳_日機装FNSI NO.3786 劉全航 start
      patInsuranceList: [],
      //add FNSI-横展開管理台帳_日機装FNSI NO.3786 劉全航 end
      expiredString: "【期限切れ】",
      focusRefill: false, // リフィル欄にフォーカス中かどうか
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou start
      getUserId: "getUserId",
      // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou end
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("pat-prescription", [
      // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou start
      "getOtherFacilityFlag",
      "getFacilityName",
      // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou end
      "getViewMode",
      "getIsEdit",
      "getIsChanged",
      "getEditRecord",
      "getOriginalEditRecord",
      "getListTakeMedicine",
      "getListPatInsurance",
      "getInputModal",
      "getPrescriptionDetail",
      "getOrdPrescriptionNo",
      "getIndexRowHistory",
    ]),
    ...mapGetters("user", ["getFacilityCd", "getUserAuthorityCds"]),
    ...mapGetters("pat-info", ["selectedPatId", "selectedPatName"
      //add FNSI-横展開管理台帳_日機装FNSI NO.3786 劉全航 start
      ,"getPatBirthday"
      //add FNSI-横展開管理台帳_日機装FNSI NO.3786 劉全航 end
    ]),

    rp1Width(){
      var dom = document.getElementsByClassName("custom-input-area");
      let width = dom.style.width;
      return `width:${width};`;
    },
    /**
     * 編集されたか否か
     */
    isChanged() {
      // 新規登録の場合は常に編集状態
      return !this.getIsEdit || (this.getIsEdit && this.getIsChanged);
    },
  },
  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("pat-prescription", [
      "setViewMode",
      "setIsEdit",
      "setIsInputModalChanged",
      "setInputModal",
      "setEditRecord",
      "setOriginalEditRecord",
      "setIndexRow",
      "setTakeMedicine",
      "sendRequestSavePrescription",
      "sendRequestGetPatInsurance",
      "setOrdPrescriptionNo",
      "sendRequestDeleteOrderPrescription",
      "sendRequestGetInsuInfoByCd",
      // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou start
      "sendRequestGetFacilityNameByCd",
      // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou end
      //add 横展開管理台帳_日機装FNSI NO.15 劉全航 start
      "setIsDoctorChanged",
      //add 横展開管理台帳_日機装FNSI NO.15 劉全航 end
      "setPrescriptionEditRecord",
    ]),
    ...mapActions("multi-modal", ["showPatPrescriptionSelectDrug"]),
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
    // 予実リストへの変更通知
    ...mapActions("indication-result", ["setResultUpdate"]),
    // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    
    /**
     * 吹き出しで処方セット選択時、
     * 薬剤に選択患者の禁忌・アレルギーが含まれている場合はアラート表示
     */
    async comfirmUpdatePrescriptionSet(data) {
      const prescriptionSetData = this.prescriptionSetData
        .find(item => item.code === data.value);
    
      if (!prescriptionSetData) {
        this.comfirmShowing = false;
        return;
      }
    
      const prescriptionSetJson = JSON.parse(prescriptionSetData.setInfo);
    
      // 禁忌アレルギー判定用データ作成
      const tabooMasterList = await this.buildTabooAllergyMasterList();
      // 処方セット内に禁忌があるか判定
      const hasTabooAllergy =
        this.applyTabooPrefixToPrescription(
          prescriptionSetJson,
          tabooMasterList
        );
    
      // 禁忌がある場合は確認ダイアログ
      if (hasTabooAllergy) {
        const isOk = await confirmIsOkByKey(13000115);
        if (!isOk) {
          this.comfirmShowing = false;
          return;
        }
      }
    
      // 更新処理（共通）
      await this.updateInputPrescriptionSet(prescriptionSetJson, true, this.getFacilityCd);
      this.comfirmShowing = false;
      this.closePopoverPrescriptionSet();
    },
    /** 禁忌アレルギー判定用のマスタ生成 */
    async buildTabooAllergyMasterList() {  
      // 禁忌アレルギーマスタ、選択患者の患者情報取得
      // 他で更新されているケースを考慮して処方セット選択のタイミングで最新データを取得
      const [mstTabooAllergyRes, patMainRes] = await Promise.all([
        sendRequestFindRecordListByFacilityCd(
          "mst_taboo_allergy",
          this.getFacilityCd
        ),
        ApiHelper.post("/patInfo/getPatMainByIdList", {
          patIdList: [this.selectedPatId]
        }),
      ]);
      // 禁忌アレルギーマスタ
      const mstTabooAllergyData = mstTabooAllergyRes.data.localDataSource.data;
      // 選択患者の禁忌アレルギー情報
      const tabooInfo = patMainRes.data?.length > 0 ? patMainRes.data[0].taboo_allergy_info : [];
      const tabooList = tabooInfo ? JSON.parse(tabooInfo) : [];
      if (!tabooList.length) return [];
      
      return mstTabooAllergyData.flatMap(detail => {
    
        const matched = tabooList.filter(item => item.taboo_allergy_cd == detail.code);
        if (!matched.length) return [];
    
        return matched.map(item => ({
          ...detail,
          tabooAllergyClass: item.taboo_allergy_class
        }));
      });
    },
    /** 禁忌アレルギー接頭辞取得 */
    applyTabooPrefixToPrescription(prescriptionSetJson, tabooMasterList) {
    
      let hasTabooAllergy = false;
      for (const item of prescriptionSetJson) {
        // 薬剤以外は処理スキップ
        if (item.type !== 1) continue;
    
        const prefix =
          this.getTabooAllergyPrefix(
            item.medicine_cd,
            item.medicine_type,
            tabooMasterList
          );
        if (!prefix) continue;
    
        hasTabooAllergy = true;
    
        if (item.R) item.R = prefix + item.R;
        if (item.F1) item.F1 = prefix + item.F1;
      }
    
      return hasTabooAllergy;
    },
    /**
     * 禁忌・アレルギー prefix を返す
     * @param {String|Number} cd
     * @param {Number} medicineType
     * @param {Array} mstTabooAllergy
     * @returns {String}
     */
    getTabooAllergyPrefix(cd, medicineType, mstTabooAllergy = []) {
    
      if (!mstTabooAllergy.length) return "";
    
      const classCd = medicineType === 1 ? "1" : "6";
    
      let hasTaboo = false;
      let hasAllergy = false;
    
      for (const item of mstTabooAllergy) {
    
        if (!item.detailInfo) continue;
    
        const detailList = JSON.parse(item.detailInfo);
    
        const matched = detailList.some(
          el => el.cd == cd && el.classCd == classCd
        );
    
        if (!matched) continue;
    
        if (item.tabooAllergyClass == "1") hasTaboo = true;
        if (item.tabooAllergyClass == "2") hasAllergy = true;
    
        // 両方見つかったら終了
        if (hasTaboo && hasAllergy) break;
      }
    
      if (hasTaboo && hasAllergy) return TABOO_ALLERGY_CLASS_PREFIX;
      if (hasTaboo) return TABOO_CLASS_PREFIX;
      if (hasAllergy) return ALLERGY_CLASS_PREFIX;
    
      return "";
    },
    // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 start
    getAuthority() {
      const pEdit = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PRESCRIPTION_PEDIT);
      const edit = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PRESCRIPTION_EDIT);
      this.isEditDisabled = (pEdit == false && edit == false) || !this.selectedPatId;
    },
    // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 end

    // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou start
    async getShared(){
      await ApiHelper.get(
          `/pat_event/getPublicFlag/` + this.getUserId
      ).then(res => {
        if(res.data.msg == 1) {
          this.sharedFlag = true;
        } else {
          this.sharedFlag = false;
        }
      }).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('PatPrescriptionDetailComponent.vue', 'getShared', error);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        throw error;
      })
    },
    // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou end

    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const wh = this.windowHeight;
      const hc = Array.prototype.slice
          .call(document.getElementsByClassName("header"))
          .shift();
      const hh = hc ? hc.clientHeight : 0;

      const preHeader = Array.prototype.slice
          .call(document.getElementsByClassName("color-header"))
          .shift();
      const preHeaderHeight = preHeader ? preHeader.clientHeight : 0;
      const footerMenu = document.getElementById("footer-menu").scrollHeight;
      let preFooter = document.getElementById("prescription-footer")
          .scrollHeight;
      this.contentsAreaHeight =
          wh - hh - preHeaderHeight - footerMenu - preFooter + 15;
    },

    //キャンセルボタンエベント
    async cancel() {
      // upd #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc start
      const cancelled = await this.$parent?.confirmAllowDiscardChanges();
      if (cancelled) {
        this.$emit('openPatPrescription');
      }
      // upd #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc end
    },

    //コンポーネントをクリア
    clearComponent() {
      (this.inputModel = {
        startDate: "",
        endDate: "",
        checkHos: "1",
        isChild: false,
        isDoubt: false,
        isInformation: false,
        isElderly: false,
        isElderly7: false,
        isAnesthesia: false,
        doctor: "",
        patInsurance: "",
        issued: false,
        remarksFree: "",
        isRefill: false,
        refillNum: NaN,
      }),
          this.setViewMode(false);
      this.setIsEdit(false);
    },

    //薬剤選択IFを表示する
    async showModal(index) {
      this.setIndexRow(index);
      await this.showPatPrescriptionSelectDrug();
    },

    async validateBeforeRegister() {
      // エラースタイルのクリア
      this.startDateClassCtrl.setInvalid(false);
      this.endDateClassCtrl.setInvalid(false);
      this.doctorClassCtrl.setInvalid(false);

      // 必須項目チェック
      let requiredError = false;
      if (this.inputModel.startDate === "") {
        this.startDateClassCtrl.setInvalid(true);
        requiredError = true;
      }
      if (this.inputModel.endDate === "") {
        this.endDateClassCtrl.setInvalid(true);
        requiredError = true;
      }
      // del #10359 編集権限の動作不正 dengshen start
      // if (!this.isSelectInsuranceEmpty && this.isSelectDoctorEmpty) {
      //   this.doctorClassCtrl.setInvalid(true);
      //   requiredError = true;
      // }
      // del #10359 編集権限の動作不正 dengshen end
      if (requiredError) {
        await this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "必須項目未入力",
          // message: DIALOG_MESSAGES["99999994"]
          title: DIALOG_MESSAGES["99999994"].title,
          message: DIALOG_MESSAGES["99999994"].message
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return false;
      }

      // 整合性チェック
      if (this.inputModel.startDate > this.inputModel.endDate) {
        this.endDateClassCtrl.setInvalid(true);
        await this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "エラー",
          title: DIALOG_MESSAGES["10500001"].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: DIALOG_MESSAGES["10500001"].message
        });
        return false;
      }

      return true;
    },
    //処方箋を登録
    async register() {
      if (await this.validateBeforeRegister()) {
        let ordPrescription = {
          ordPrescriptionNo: this.getOrdPrescriptionNo,
          facilityCd: this.getFacilityCd,
          patId: this.selectedPatId,
          prescriptionType: this.inputModel.checkHos,
          issueDate: this.inputModel.startDate ?  moment(this.inputModel.startDate, "YYYY-MM-DD").format(
              "YYYY/MM/DD") : null ,
          issueState: this.inputModel.issued == true ? "1" : "0",
          expirationDate: this.inputModel.endDate ? moment(this.inputModel.endDate, "YYYY-MM-DD").format(
              "YYYY/MM/DD") : null,
          prescriptionDetail: JSON.stringify(this.convertData(true)),
          isDisp: "1",
          isDel: "0"
        };

        const insuranceData = this.selectInsurance.split('&');
        const insuranceDataNameArr = insuranceData.concat();
        insuranceDataNameArr.shift();
        const insuranceDataName = insuranceDataNameArr.join('');

        let ordPersonalPrescription = {
          facilityCd: this.getFacilityCd,
          patId: this.selectedPatId,
          insuranceCd: this.selectInsurance === "0&" ? null : insuranceData[0],
          insuranceName: this.selectInsurance === "0&" ? null : insuranceDataName,
          insuDrId: this.selectDoctor,
          isDoubt: this.inputModel.isDoubt == true ? "1" : "0",
          isInformation: this.inputModel.isInformation == true ? "1" : "0",
          isElderly: this.inputModel.isElderly == true ? "1" : "0",
          isElderly7: this.inputModel.isElderly7 == true ? "1" : "0",
          isChild: this.inputModel.isChild == true ? "1" : "0",
          isAnesthesia: this.inputModel.isAnesthesia == true ? "1" : "0",
          remarksFree: this.inputModel.remarksFree,
          isDisp: "1",
          isDel: "0",
          isRefill: this.inputModel.isRefill == true ? "1" : "0",
          refillNum: this.inputModel.refillNum,
        };
        let data = {
          ordPrescription,
          ordPersonalPrescription
        };
        let isTabooAllergy = false;
        this.getEditRecord.forEach(record => {
          if(record.dataButtonNo === 2) {
            let drugName = record.buttonItems[2].itemValue;
            if(drugName.includes(TABOO_CLASS_PREFIX) ||
                drugName.includes(ALLERGY_CLASS_PREFIX) ||
                drugName.includes(TABOO_ALLERGY_CLASS_PREFIX)) {
              isTabooAllergy = true;
            }
          }
        });
        let cancelled = false;
        if (isTabooAllergy) {
          await this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "警告",
            title: DIALOG_MESSAGES[13000112].title,
            // message: "禁忌・アレルギーの医薬品が含まれています。保存してよろしいですか?",
            message: messageFormat(DIALOG_MESSAGES[13000112].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: async answer => {
              if (answer === 0) {
                cancelled = true;
              }
            }
          });
        }
        if (!cancelled) {
          // 共通ローダー:表示開始
          //FutreNetWeb+SI課題管理 no.5517 劉全航 start
          this.setLoadingScreenMessage("保存中・・・");
          //FutreNetWeb+SI課題管理 no.5517 劉全航 end
          this.setLoadingScreenVisible(true);
          try {
            let response = await this.sendRequestSavePrescription(data);
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            if (response.status == 200) {
              const savedOrdPrescriptionNo = (this.getOrdPrescriptionNo !== 0)
                  ? this.getOrdPrescriptionNo
                  : response.data && response.data.ordPrescription && response.data.ordPrescription.ordPrescriptionNo ? response.data.ordPrescription.ordPrescriptionNo : -1;
              EventBus.$emit("search", savedOrdPrescriptionNo);
            }
          } catch (error) {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('PatPrescriptionDetailComponent.vue', 'register', "システムエラーが発生しました。");
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "保存失敗した",
              // message: "システムエラーが発生しました。"
              title: DIALOG_MESSAGES['00200153'].title,
              message: messageFormat(DIALOG_MESSAGES['00200153'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            this.setLoadingScreenVisible(false);
          }
        }
      }
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      // 予実リストの更新
      this.setResultUpdate(new Date());
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
    },

    // 処方箋を削除
    async deleteOrder() {
      // add #10359_NG対応 編集権限の動作不正 dengshen start
      if (!this.getItemAuthorized('PatPrescription', 'item_delete_btn')) {
        this.$ons.notification.alert({
          // title: "権限エラー",
          // message: functionName+"を操作する権限がありません。管理者に確認してください。"
          title: DIALOG_MESSAGES[12000315].title,
          message: messageFormat(DIALOG_MESSAGES[12000315].message, "処方箋削除")
        });
        return;
      }
      // add #10359_NG対応 編集権限の動作不正 dengshen end
      let deleteFlg = false;
      let dialogDispFlg = false;
      await this.$ons.notification.confirm({
        modifier: "warn",
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "処方削除警告",
        title: DIALOG_MESSAGES[13000113].title,
        // message: "処方を削除します。<br>削除すると二度と元に戻せません。削除してもよろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000113].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer == 1) {
            deleteFlg = true;
            dialogDispFlg = true;
          }
        }
      });
      if (dialogDispFlg) {
        await this.$ons.notification.confirm({
          modifier: "warn",
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "処方削除最終確認",
          title: DIALOG_MESSAGES[13000114].title,
          // message: "処方を削除します。本当によろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000114].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 0) {
              deleteFlg = false;
            }
          }
        });
      }
      if (!deleteFlg) {
        // キャンセルされた場合は処理を中断
        return;
      }
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.sendRequestDeleteOrderPrescription(
          this.getOrdPrescriptionNo
      ).then(() => {
        this.setViewMode(false);
        this.setIsEdit(false);
        EventBus.$emit("search", -1);
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // 予実リストの更新
        this.setResultUpdate(new Date());
      });
    },

    // デフォルト日付を取得
    getDate(){
      let today = new Date();
      this.inputModel.startDate = moment().format("YYYY-MM-DD")
      let date = new Date(today);
      date.setDate(date.getDate() + 3);
      let endDate = date.getFullYear() +
          "/" +
          (date.getMonth() + 1) +
          "/" +
          date.getDate();
      this.inputModel.endDate = moment(endDate).format("YYYY-MM-DD")
    },

    // 処方の備考値を取得
    async getPatIssueDefault(){
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      if(this.listPatInsurance.length != 0){
        // 保険の初期選択
        const patIns = this.listPatInsurance.find(
            pat => pat.isSelected == "1"
        );
        if (patIns) {
          // 主保険に設定された保険が存在する場合
          // 主保険を選択する
          this.inputModel.patInsurance = patIns.insuranceCd;
        } else if (this.listPatInsurance.length > 1) {
          // 主保険が設定されていないが空行以外の保険の選択肢は存在する場合
          // 1つ目の保険を選択する
          this.inputModel.patInsurance = this.listPatInsurance[1].insuranceCd;
        } else {
          // 空行以外の保険の選択肢がない場合
          // 空行を選択する
          this.inputModel.patInsurance = this.listPatInsurance[0].insuranceCd;
        }

        const insuranceData = this.inputModel.patInsurance.split('&');
        let response = await this.sendRequestGetInsuInfoByCd(
          insuranceData[0]
        );
        this.inputModel.isElderly = response.data.kkiClass == 1 ? true : false;
        this.inputModel.isElderly7 = response.data.kkiClass == 2 ? true : false;
        this.inputModel.isChild = response.data.undSix == 0 ? false : true;
        this.selectInsurance = this.inputModel.patInsurance;
        //add 横展開管理台帳_日機装FNSI NO.15 劉全航 start
        this.originalInsurance = this.selectInsurance;
        //add 横展開管理台帳_日機装FNSI NO.15 劉全航 end
      }
      // 共通ローダー：表示終了
      this.setLoadingScreenVisible(false);
    },

    applyInputModelWatcher() {
      this.$watch('inputModel', () => {
        let inputModelConvert = deepCopy(this.inputModel);
        /* modify by chamaojia 2022-11-18 [6876] nullが空の文字列に変更され、データの整合性が保証されます  --start */
        inputModelConvert.startDate = this.inputModel.startDate == "" ? "" : moment(this.inputModel.startDate, "YYYY-MM-DD").format(
            "YYYY/MM/DD"
        );
        inputModelConvert.endDate = this.inputModel.endDate == "" ? "" : moment(this.inputModel.endDate, "YYYY-MM-DD").format(
            "YYYY/MM/DD"
        );
        /* modify by chamaojia 2022-11-18 [6876] nullが空の文字列に変更され、データの整合性が保証されます  --end */
        this.setIsInputModalChanged(!isEqual(inputModelConvert, this.getInputModal));
      }, { deep: true, immediate: true});
      this.$nextTick(() => {
        const element = document.getElementById("com-textarea-remark-free");
        this.resizeTextarea(element);
      });
    },
    isDoctorEmpty(){
      //add 横展開管理台帳_日機装FNSI NO.15 劉全航 start
      if((this.originalDoctor != this.selectDoctor) || (this.originalInsurance != this.selectInsurance)){
        this.setIsDoctorChanged(true);
      }else{
        this.setIsDoctorChanged(false);
      }
      //add 横展開管理台帳_日機装FNSI NO.15 劉全航 end
      //add FNSI-横展開管理台帳_日機装FNSI NO.3786 劉全航 start
      if(this.originalInsurance !== this.selectInsurance){
        //mod FNSI-7151 処方画面への遷移、ボタン押下等の操作を行うとTypeErrorが発生する 劉全航 start
        let patInsuranceInfo;
        patInsuranceInfo = this.patInsuranceList.find(o => o.insuranceCd === this.selectInsurance);
        if(patInsuranceInfo != null && patInsuranceInfo.insuClass === 0){
          //mod FNSI-7151 処方画面への遷移、ボタン押下等の操作を行うとTypeErrorが発生する 劉全航 end
          this.inputModel.isChild = patInsuranceInfo.undSix === "1";
          if(patInsuranceInfo.kkiClass === "1"){
            this.inputModel.isElderly = true;
            this.inputModel.isElderly7 = false;
          }else if(patInsuranceInfo.kkiClass === "2"){
            this.inputModel.isElderly = false;
            this.inputModel.isElderly7 = true;
          }else{
            this.inputModel.isElderly = false;
            this.inputModel.isElderly7 = false;
          }
        }
      }
      //add FNSI-横展開管理台帳_日機装FNSI NO.3786 劉全航 end
    },
    setContentData(newValue) {
      this.inputModel.remarksFree = newValue;
    },

    resizeTextarea(el) {
      el.style.height = `${el.scrollHeight + 5}px`;
    },

    copyAndCreate() {
      EventBus.$emit("cancel");
      this.inputModel.issued = false;
      // 変更前データも更新
      this.updateInputModal();
      this.getDate();
      this.setOrdPrescriptionNo(0);
      this.setIsEdit(false);
      // add #11406 処方の「コピーして新規登録」を行うと保険情報がNULLになることがある 房 start
      let mainInsuranceName = undefined;
      if(this.getListPatInsurance && this.getListPatInsurance.data) {
        let selectedInsurance = this.getListPatInsurance.data.find(el => el && el.isSelected === "1");
        if(selectedInsurance) {
          // 主保険情報がある場合
          mainInsuranceName = selectedInsurance.insuranceCd + "&" + selectedInsurance.insuName;
        }
        // 処方の保険情報がある場合
        if(this.getInputModal.patInsurance) {
          let tempInsuranceCd = this.getInputModal.patInsurance.split("&")[0];
          let selectedInsurance = this.getListPatInsurance.data.find(el => el && el.insuranceCd == tempInsuranceCd);
          if(!selectedInsurance) {
            // 保険情報もう削除した場合、選択肢中に除く
            this.listPatInsurance.pop(this.listPatInsurance.length - 1);
          }
        }
        // 上記以外
        if(!selectedInsurance) {
          if(!mainInsuranceName && this.getListPatInsurance.data.length > 0) {
            mainInsuranceName = this.getListPatInsurance.data[0].insuranceCd + "&" + this.getListPatInsurance.data[0].insuName;
          }
        }
        if(mainInsuranceName){
          this.selectInsurance = mainInsuranceName;
        } else {
          this.selectInsurance = "0&";
        }
        // 保存ボタンは活性化になる
        this.setOriginalEditRecord({});
      }
      // add #11406 処方の「コピーして新規登録」を行うと保険情報がNULLになることがある 房 end
      //mod FNSI-NO514 新規登録時に処方カードの名前を「処方 新規作成」とする 劉全航 start
      this.title = `処方 新規作成`;
      //mod FNSI-NO514 新規登録時に処方カードの名前を「処方 新規作成」とする 劉全航 end
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 start
      // 予実リストの更新
      this.setResultUpdate(new Date());
      // add FNSI-No.342 患者イベント、検査結果、検査予定、一般撮影検査予定、処方の表示、機能遷移に対応 李 end
    },
    // 患者切り替え、更新の動作不正  6553  shan  start
    // refresh(){
    //   this.cancel();
    // },
    // 患者切り替え、更新の動作不正  6553  shan  end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc start
    async refresh() {
      if(await this.$parent?.confirmAllowDiscardChanges()) {
        await this.init();
        await this.$parent?.init();
      }
    },
    async init() {
      // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 start
      this.getAuthority()
      // add #6570-処方の編集権限がない時の制限が、他の画面と異なる 徐博 end
      
      // 共通ローダー:表示開始
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      
      // add FNSI-修正 マスタ削除の対応 劉全航 start
      // 薬剤マスタ(削除済みを含む)を取得
      const [ medicineRes, genericMedicineRes ] = await Promise.all([
        ApiHelper.get("/mstInfo/mstMedicineIncludeDeleted", { facilityCd: this.getFacilityCd }),
        ApiHelper.get("/mstInfo/sysGenericMedicineIncludeDeleted"),
        this.setTakeMedicine(this.getFacilityCd)
      ]);
      
      this.mstMedicine = medicineRes.data;
      this.sysGenericMedicine = genericMedicineRes.data;
      
      // 用法・用語マスタを取得
      this.listTakeMedicine = this.getListTakeMedicine;

      // add FNSI-修正 マスタ削除の対応 劉全航 end
      // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou start
      this.getShared();
      // add FNSI-改修内容 カテゴリ選択の上に施設名を表示する dou end

      //保険一覧を取得
      let data = {
        patId: this.selectedPatId,
        facilityCd: this.getFacilityCd,
        ordPrescriptionNo: 0
      };
      await this.sendRequestGetPatInsurance(data);

      const listPatInsuranceMod = this.getListPatInsurance.data.map(data =>
        ({
          insuName: data.insuName,
          insuranceCd: data.insuranceCd + "&" + data.insuName,
          isDel: data.isDel,
          isSelected: data.isSelected
        })
      );

      const insuranceData = this.getInputModal.patInsurance.split('&');
      const insuranceDataNameArr = insuranceData.concat();
      insuranceDataNameArr.shift();
      const insuranceDataName = insuranceDataNameArr.join('');

      let listPatInsuranceSelected = [];
      if(insuranceData.length > 1){
        const isAddPatInsuranceSelected =  listPatInsuranceMod.filter(e => e.insuranceCd === this.getInputModal.patInsurance).length === 0;
        if(isAddPatInsuranceSelected && this.getInputModal.patInsurance != "0&"){
          listPatInsuranceSelected = [
            ({
              insuName: insuranceData[1],
              insuranceCd: insuranceData[0] + "&" + insuranceDataName,
              isDel: "0",
              isSelected: "0"
            })
          ];
        }
      }


      this.listPatInsurance = [ ...this.patInsurance.data, ...listPatInsuranceMod, ...listPatInsuranceSelected].filter(e => e !== null);
      //医師一覧を取得
      this.getIndUserList(AUTHORITY_CODES.PRESCRIPTION_EDIT, AUTHORITY_CODES.PRESCRIPTION_PEDIT, this.getInputModal.facilityCd)
          .then(response => {
            this.listDoctor = response.doctorList;
            this.$nextTick(() => {
              this.selectDoctor = this.getOrdPrescriptionNo
                  ? this.getInputModal.doctor
                  : response.iniSelectId;
              //add 横展開管理台帳_日機装FNSI NO.15 劉全航 start
              this.originalDoctor = this.selectDoctor;
              //add 横展開管理台帳_日機装FNSI NO.15 劉全航 end
              if (!this.listDoctor.some(e => e.user_id === this.selectDoctor)) {
                this.selectDoctor = null;
              }
            });
          });
      this.setIsDoctorChanged(false);

      if (!this.getIsEdit) {
        await this.getDataList();
        await this.refacterDataList();
        //デフォルト日付
        this.getDate();
        await Promise.all([
          // 備考のデフォルト値を取得
          this.getPatIssueDefault()
        ]);
        //mod FNSI-NO514 新規登録時に処方カードの名前を「処方 新規作成」とする 劉全航 start
        this.title = `処方 新規作成`;
        //mod FNSI-NO514 新規登録時に処方カードの名前を「処方 新規作成」とする 劉全航 end
      } else {
        this.inputModel = {
          startDate: toDateInputValue(this.getInputModal.startDate),
          endDate: toDateInputValue(this.getInputModal.endDate),
          checkHos: this.getInputModal.checkHos,
          isChild: this.getInputModal.isChild,
          isDoubt: this.getInputModal.isDoubt,
          isInformation: this.getInputModal.isInformation,
          isElderly: this.getInputModal.isElderly,
          isElderly7: this.getInputModal.isElderly7,
          isAnesthesia: this.getInputModal.isAnesthesia,
          doctor: this.getInputModal.doctor,
          patInsurance: this.getInputModal.patInsurance,
          issued: this.getInputModal.issued,
          remarksFree: this.getInputModal.remarksFree,
          isRefill: this.getInputModal.isRefill, 
          refillNum: this.getInputModal.refillNum,
	  // add #12462 患者情報共有 Ji start
          facilityCd: this.getInputModal.facilityCd,
	  // add #12462 患者情報共有 Ji end
        };
        this.changeFormatData(1, true);
        await this.refacterDataList();
        this.selectInsurance = this.getInputModal.patInsurance ?
            this.getInputModal.patInsurance.toString() : this.getInputModal.patInsurance;
        //add FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 start
        this.originalInsurance = this.selectInsurance;
        //add FNSI-横展開管理台帳_日機装FNSI NO.15 劉全航 end
      }
      if(!this.$parent.newLogin){
        this.setOriginalEditRecord(deepCopy(this.dataList));
      }

      this.applyInputModelWatcher();
      // 共通ローダー：表示終了
      this.setLoadingScreenVisible(false);
      this.blockUnecessaryDigit();
      //add FNSI-横展開管理台帳_日機装FNSI NO.3786 劉全航 start
      if(!this.getIsEdit){
        let resPatInsurance = await ApiHelper.get(`/patInfo/getPatInsuById/${this.selectedPatId}`);
        if(resPatInsurance.data.length > 0){
          let mainInsurance = null;
          mainInsurance = resPatInsurance.data.find(obj=>obj.is_selected === "1");
          if(mainInsurance !== null
              //add FNSI-7151 処方画面への遷移、ボタン押下等の操作を行うとTypeErrorが発生する 劉全航 start
              && mainInsurance != undefined
              //add FNSI-7151 処方画面への遷移、ボタン押下等の操作を行うとTypeErrorが発生する 劉全航 end
          ) {
            let insuInfo = JSON.parse(mainInsurance.insu_info);
            let undSix = insuInfo.und_six;
            let kkiClass = insuInfo.kki_class;
            if(undSix === '1'){
              this.inputModel.isChild = true;
            }
            if(kkiClass === '1'){
              this.inputModel.isElderly = true;
            }
            if(kkiClass === '2'){
              this.inputModel.isElderly7 = true;
            }
          }
          if(resPatInsurance.data.length > 1){
            for(let obj of resPatInsurance.data){
              let info = JSON.parse(obj.insu_info);
              let insurance = {
                "insuranceCd" : obj.insurance_cd.toString(),
                "insuClass" : obj.insu_class,
                "undSix" : info.und_six,
                "kkiClass" : info.kki_class
              };
              this.patInsuranceList.push(insurance);
            }
          }
        }else{
          let birthYear = moment(this.getPatBirthday).year();
          let year = moment().year() - birthYear;
          if(year> 6){
            this.inputModel.isChild = false;
          }
        }
      }
      //add FNSI-横展開管理台帳_日機装FNSI NO.3786 劉全航 end
      this.getInitRecord = deepCopy(this.getEditRecord)
      // 変更前データ更新
      this.updateInputModal();
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc end
    /**
     * 処方エリア 編集未保存スタイルを適用
     * @param {String} item 行オブジェクト
     * @param {String} itemName 項目名
     * @param {String} elementType onsen ui の場合は"ons"が設定される
     */
    isEditedDataList(item, itemName, elementType) {
      
      if (this.getIsEdit && Object.keys(this.getOriginalEditRecord).length === 0) return;
      
      // リスト各項目の値取得 関数
      const getItemValue = (records, uniqueId, dataButtonNo, itemName) => {
        const record = records.find(item => item.uniqueId === uniqueId && item.dataButtonNo === dataButtonNo);
        const buttonItem = record?.buttonItems?.find(button => button.itemName === itemName);
        // itemValueCd（薬剤）が存在する場合はitemValueCdを返す
        const value = buttonItem?.itemValueCd !== undefined ? buttonItem.itemValueCd : buttonItem?.itemValue;
        // itemValueCd、itemValueがundefinedの場合は追加行のため"isNew"を返す
        return value !== undefined ? value : "";
      };

      // this.getOriginalEditRecord: 編集前、this.getEditRecord: 編集後
      let beforeVal = this.getIsEdit ? getItemValue(this.getOriginalEditRecord, item.uniqueId, item.dataButtonNo, itemName) : ""; // 新規作成の場合は""
      let afterVal = getItemValue(this.getEditRecord, item.uniqueId, item.dataButtonNo, itemName);
      
      // 変更があればクラスを適用
      const className = elementType === "ons" ? "ons-element-edited" : "custom-element-edited";
      return beforeVal !== afterVal ? className : "";
    },
    /**
     * 処方エリア以外 編集未保存スタイルを適用
     * - 新規登録押下後に展開される内容は編集未保存状態とする
     * @param {*} dateField 項目名
     */
    isEdited(dateField) {
      const classMap = {
        checkHos: "radio-edited",               // 院外/院内
        startDate: "date-input-edited",         // 交付日
        endDate: "date-input-edited",           // 使用期間
        insurance: "custom-select-edited",      // 保険
        insuranceDoctor: "custom-select-edited",// 保険医
        isDoubt: "checkbox-edited",             // 保険医療機関へ疑義照会の上で調剤
        isInformation: "checkbox-edited",       // 保険医療機関へ情報提供
        isElderly: "checkbox-edited",           // 高一
        isElderly7: "checkbox-edited",          // 高7
        isChild: "checkbox-edited",             // 6歳未満
        isAnesthesia: "checkbox-edited",        // 麻薬含む
        remarksFree: "textarea-edited",         // ﾌﾘｰｺﾒﾝﾄ
        issued: "checkbox-edited",              // 交付済み
        isRefill: "checkbox-edited",            // リフィル可
        refillNum: "ons-element-edited",        // リフィル回数
      };
      // this.getInputModal: 編集前、this.inputModel: 編集後
      let beforeVal = this.getInputModal[dateField] === "" ? null : this.getInputModal[dateField];
      let afterVal = this.inputModel[dateField] === "" ? null : this.inputModel[dateField];
      
      // 日付項目で値が設定されている場合は"YYYY/MM/DD"形式に変換して判定する
      if (dateField.includes("Date")) {
        beforeVal = beforeVal ? moment(beforeVal, "YYYY-MM-DD").format("YYYY/MM/DD") : null;
        afterVal = afterVal ? moment(afterVal, "YYYY-MM-DD").format("YYYY/MM/DD") : null;
      }
      if (dateField === "insurance") {
        beforeVal = this.getIsEdit ? this.originalInsurance : "0&"; // 新規作成の場合はリストの空行に設定
        afterVal = this.selectInsurance;
      }
      if (dateField === "insuranceDoctor") {
        beforeVal = this.getIsEdit ? this.originalDoctor : undefined; // 新規作成の場合はリストの空行に設定
        afterVal = this.selectDoctor;
      }
      // 新規作成の場合は変更前を初期値に設定
      // ** コピーから新規作成押下でも編集未保存スタイルを適用するため **
      if (!this.getIsEdit) {
        // 備考の各チェックボックス
        if (dateField.includes("is")) {
          beforeVal = false;
        }
        // 備考のフリーコメント
        if (dateField === "remarksFree") {
          beforeVal = null;
        }
      }
      
      // 新規作成の場合は編集未保存スタイル
      if (!this.getIsEdit && ["Date", "checkHos"].some(keyword => dateField.includes(keyword))) {
        return classMap[dateField];
      }
      
      // 変更があればクラスを適用
      return beforeVal !== afterVal ? classMap[dateField] : "";
    },
    /**
     * 変更前データ更新
     */
    updateInputModal() {
      let inputModelConvert = deepCopy(this.inputModel);
      inputModelConvert.startDate = this.inputModel.startDate == "" ? null : moment(this.inputModel.startDate, "YYYY-MM-DD").format(
          "YYYY/MM/DD"
      );
      inputModelConvert.endDate = this.inputModel.endDate == "" ? null : moment(this.inputModel.endDate, "YYYY-MM-DD").format(
          "YYYY/MM/DD"
      );
      this.setInputModal(inputModelConvert);
    },
    /* リフィル回数のフォーカス制御 */
    onRefillFocus() {
      this.focusRefill = true;
    },
    /* リフィル回数のフォーカスアウト */
    onRefillBlur() {
      if (this.inputModel.refillNum === '' || this.inputModel.refillNum == null) {
        this.inputModel.refillNum = '';
        this.focusRefill = false;
        return;
      }

      const v = Number(this.inputModel.refillNum);
      // NOTE: min: 1, max: 3
      this.inputModel.refillNum = Number.isNaN(v) ? '' : Math.min(3, Math.max(1, v));
      this.focusRefill = false;
    },
    /* リフィル回数の入力制御処理 */
    clampRefillOnInput() {
      const raw = String(this.inputModel.refillNum ?? '').replace(/[^\d]/g, '');
      if (raw === '') {
        this.inputModel.refillNum = '';
        return;
      }
      const v = Number(raw);
      // NOTE: min: 1, max: 3
      this.inputModel.refillNum = Math.min(3, Math.max(1, v));
    },
    /* リフィル回数のホイール増減処理 */
    onRefillWheel(e) {
      // 権限制御・発行済みは無効
      if (this.inputModel.issued || !this.getItemAuthorized('PatPrescription', 'default_authority')) return;
      // フォーカス時のみ有効（既存ポリシー踏襲）
      if (!this.focusRefill) return;
      // wheelDelta/Y 統合（上スクロールで+1、下スクロールで-1）
      const delta = (e.wheelDelta || -e.deltaY || 0) > 0 ? 1 : -1;
      let v = Number(this.inputModel.refillNum);
      if (Number.isNaN(v)) v = 0;
      v += delta;
      // NOTE: min: 1, max: 3
      this.inputModel.refillNum = Math.min(3, Math.max(1, v));
    },
    // add #12462 患者情報共有 Ji start
    isOtherFacility(facilityCd){
      if (!facilityCd) return false
      return facilityCd !== this.getFacilityCd
    }
    // add #12462 患者情報共有 Ji end
  },

  watch: {
    "inputModel.startDate"() {
      // 入力値が変更されたらエラースタイルをクリアする
      this.startDateClassCtrl.setInvalid(false);
    },
    "inputModel.endDate"() {
      // 入力値が変更されたらエラースタイルをクリアする
      this.endDateClassCtrl.setInvalid(false);
    },
    // del #10359 編集権限の動作不正 dengshen start
    // selectInsurance() {
    //   // 入力値が変更されたら保険医の必須設定を更新する
    //   if (this.isSelectInsuranceEmpty || !this.doctorClassCtrl.classObject["input-style-invalid"]) {
    //     // 保険が未選択か、保険医がエラースタイル中でない場合は更新する
    //     // （保険が未選択になった場合は保険医のエラースタイルはクリアする）
    //     this.doctorClassCtrl.setRequired(!this.isSelectInsuranceEmpty);
    //   }
    // },
    // del #10359 編集権限の動作不正 dengshen start
    selectDoctor() {
      // 入力値が変更されたらエラースタイルをクリアする
      this.doctorClassCtrl.setInvalid(false);
    },
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    }
  },
  async created() {
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc start
    await this.init();
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_処方 20231124 ztc end
  },
  mounted() {
    document.addEventListener('mousedown', this.handleMousedown)
    this.clearStateEdit();
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  },
  beforeDestroy() {
    this.startDateClassCtrl.destroy();
    this.endDateClassCtrl.destroy();
    this.doctorClassCtrl.destroy();
    document.removeEventListener("mousedown", this.handleMousedown);
    
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  destroyed() {
    this.setViewMode(false);
    this.setIsEdit(false);
  },
  updated(){
    this.blockUnecessaryDigit();
  }
};
</script>
<style>
/* #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。訾浩 start */
.k-dropdown-wrap .k-input {
  padding: 3px 0.1em !important;
}
.k-list .k-item {
  padding: 3px 0.1em !important;
}
.k-list .k-item:hover,
.k-list .k-item.k-state-hover {
  background-color: #0090ff;
  color: #fff;
}
/* 処方セット選択 吹き出し */
.popover__content hr {
  width: 100%;
}
.popover__content ons-row {
  height: auto;
}
/* #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。訾浩 end */
</style>
<style scoped>
@media print {
  .content {
    height: auto !important;
    margin-left: 0 !important;
    min-width: unset !important;
    transform: scale(0.96);
    transform-origin: top;
  }
}
ons-row {
  width: 100%;
  height: auto;
}
.submenu-container {
  display: flex;
  flex-direction: column;
  /* mod FutreNetWeb+SI課題管理 no.5048 劉全航 start */
  /* height: 89%; */
  height: 94%;
  /* mod FutreNetWeb+SI課題管理 no.5048 劉全航 end */
}
.select {
  vertical-align: middle;
  /* border: unset;
  border-width: 2px;
  border-style: inset;
  border-image-repeat: inset;
  border-color: unset;
  border-radius: 5px; */
}
.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.nowrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}
.btn-area {
  display: flex;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
  flex-basis: 80%;
}
.pre-header {
  padding: 6px 10px;
  color: white;
  background-color: #333;
  height: 3.0em;
  box-shadow: 0 2px 2px 0 rgba(255,255,255,.2) inset,0 2px 20px 0 rgba(255,255,255,.5) inset,0 -2px 2px 0 rgba(0,0,0,.1);
}
.input {
  vertical-align: middle;
  background-color: white;
}
.input >>> .text-input {
  height: 2em;
  line-height: 2em;
}
.input >>> .text-input:disabled {
  opacity: 1;
}
.scroll {
  overflow-y: auto;
  border-bottom: 1px solid rgb(138,138,138);
  padding: 5px;
}
ons-input#add >>> input {
  text-align: center;
}
ons-popover >>> div {
  display: flex;
  flex-wrap: wrap;
  padding: 5px;
}
.grid-item {
  flex-grow: 1;
  min-width: 45%;
}
.footer {
  width: 100%;
  display: inline-flex;
  /* mod FutreNetWeb+SI課題管理 no.5457 劉全航 start */
  /* padding: 10px 0px; */
  /* mod FutreNetWeb+SI課題管理 no.5457 劉全航 start */
}
label {
  color: var(--ntss-base-color);
}
.rp-input >>> input {
  background-color: #ddd;
}
.add-btn >>> input {
  background-color: #ddd;
}
.select-style {
  width: 100%;
}
.select-style >>> .select-input {
  height: 2em;
  line-height: 2em;
}
.select-style >>> .select-input:disabled{
  opacity: 0.5;
  border: 1px solid rgb(204, 204, 204);
  background-color: white;
}
.select-input {
  height: 100%;
  width: 100%;
}
.unstyled-date {
  width: 95%;
  float: left;
  -webkit-appearance: none;
}
.unstyled-date >>> .text-input::-webkit-calendar-picker-indicator {
  -webkit-appearance: none;
  display: none;
}
.condition-row {
  width: 100%;
  float: left;
}
.col-1 {
  width: 50%;
  float: left;
}
.col-2 {
  width: 50%;
  float: left;
}
.col-1 > .condition-title {
  width: 5em;
}
.col-2 > .condition-title {
  width: 6.5em;
}
.col-rp {
  display: flex;
  align-items: center;
}
.condition-title {
  width: 12%;
  margin-right: 1%;
  text-align: right;
  vertical-align: center;
  float: left;
  padding: 5px 0;
}
.condition-input {
  /*mod FutreNetWeb+SI課題管理 NO.4456 劉全航 start */
  /* width: 80%; */
  width: 70%;
  /*mod FutreNetWeb+SI課題管理 NO.4456 劉全航 end */
  float: left;
  vertical-align: "center";
  display: flex;
}
.calendar {
  display: flex;
}
.calendar >>> button {
  height: 100%;
}
.input-header{
  box-sizing: border-box;
}
.condition-container {
  width: 100%;
  float: left;
  border-bottom: 1px solid rgb(138,138,138);
}
.footer-btn {
  padding: 0 1em;
}
.disabled-input >>> .text-input:disabled {
  opacity: 1;
  border: 0.5px solid rgb(169,169,169);
}
.rp-input {
  flex: 1;
  min-width: 0;
}
/* mod FutreNetWeb+SI課題管理 NO.3882 劉全航 start */
/* .button {
  height: 2em;
} */
@media screen and (max-width: 1024px) {
  .btn3-normal {
    width: 4.0em;
  }
}
/* mod FutreNetWeb+SI課題管理 NO.3882 劉全航 end */
.datalist >>> input::-webkit-calendar-picker-indicator {
  display: none;
}
.datalist >>> input {
  background-color: #F7F7F7
}
.datalist {
  /* height: 3em; */
  display: flex;
  justify-content: center;
  align-items: center;
}
.number-input >>> input{
  /* border: 1px solid rgb(204,204,204); */
  background-color: #F7F7F7;
}
.content{
  min-width: 50em;
  border: 1px solid rgb(138,138,138);
  margin-left: 10px;
  overflow: auto;
  height: 98%;
}
.row-buttons {
  width: 15%;
  display: flex;
}
.toolbar-button {
  padding: 5px 13%;
}

.toolbar-button-rp {
  padding: 5px;
  margin-right: 3px;
}
.toolbar-button--material {
  margin: 0 7% !important;
  padding: 0 !important;
}
.custom-btn-flex {
  flex: 1;
}
.row-buttons-span {
  width: 4em;
  text-align: center;
}
@media screen and (max-width: 1200px) {
  .label-title {
    line-height: 1.5em;
  }
  .col-1 {
    width: 50%;
    float: left;
  }
  .condition-title {
    width: 100%;
    text-align: left;
    vertical-align: center;
    float: left;
  }
  .col-1 > .condition-title {
    width: 100%;
  }
  .col-2 > .condition-title {
    width: 100%;
  }
  .condition-input {
    float: left;
    vertical-align: "center";
  }
  .condition-container {
    width: 100%;
    float: left;
  }
}
@media screen and (max-width: 1440px) and (min-width: 1200px) {
  .label-title {
    line-height: 1.5em;
  }
  .condition-container {
    width: 100%;
    float: left;
  }
  .condition-input {
    width: 75%;
  }
  .col-1 > .condition-title {
    width: 5em;
  }
  .col-2 > .condition-title {
    width: 6em;
  }
}
.custom-button-figure ons-col{
  display: flex;
  /* justify-content: space-between; */
  justify-content: center;
  align-items: center;
}
.custom-btn-area {
  max-width: 8em;
  display: flex;
  justify-content: center;
  align-items: center;
}
.custom-input-area {
  height: 3.0rem;
  display: flex;
  justify-content: flex-start;
}
.custom-flex-10 {
  flex: 0 0 10%;
}
.custom-text-center {
  text-align: center;
  display: flex;
  align-items: center;
  justify-content: center;
}
div >>> .com-textarea {
  width: 97%;
  height: 100px;
  font-family: inherit;
  resize: vertical;
}
.custom-element-input-area {
  display: flex;
  /* mod FutreNetWeb+SI課題管理-NO.4915 劉全航 start */
  align-items: center;
  justify-content: center;
  /* mod FutreNetWeb+SI課題管理-NO.4915 劉全航 end */
}
.custom-element-input-area-inner {
  margin-left: 5px;
}
.custom-condition-row {
  margin-bottom: 4px;
}
.custom-border-top {
  border-bottom: 1px solid rgb(138,138,138);
}
.condition-input >>> .custom-dropdownlist {
  width: 100%;
}
.copy-button {
  margin-left: 5px;
  padding: 0.2em 0.5em 0 0.5em;
  line-height: 2em;
}
.align-unique-row {
  margin: 5px 0;
}
.custom-registration-btn-area {
  flex-shrink: 0;
  column-gap: 1em;
  align-self: center;
}
.custom-checkbox {
  display: flex;
  align-items: center;
  justify-content: center;
}
.custom-save-btn {
  padding: 10px 20px;
}
.custom-footer {
  display: flex;
  align-items: center;
  /* mod FutreNetWeb+SI課題管理 no.5457 劉全航 start */
  height: fit-content;
  margin-top: 5px;
  /* mod FutreNetWeb+SI課題管理 no.5457 劉全航 end */
  padding: unset;
}
/* #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。 訾浩 start */
::v-deep .k-button {
  background: #fff;
  border: none;
  box-shadow: none;
}
.form-ul {
  list-style: none;
  padding: 0;
  margin: 0;
  position: absolute;
  top: 35px;
  width: 200px;
  z-index: 100;
  border: 1px solid #bababa;
  overflow: auto;
  min-height: 30px;
  max-height: 200px;
  background: #fff;
  text-align: left;
}
li {
  padding: 0;
  padding-left: 2px;
  cursor: pointer;
  text-align: left;
  min-height: 22px;
}
.position-input {
  position: relative;
}
.empty-style {
  text-align: center;
  line-height: 100px;
}
.bacground-color:hover {
  background: #0090ff;
  color: white;
}
/* #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。 start */
.bacground-highlight {
  background: #0090ff;
}
.down-arrow {
  position: absolute;
  top: 50%;
  right: 2px;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-left: 6px solid transparent;
  border-right: 6px solid transparent;
  border-top: 6px solid #757575;
  /* color: #ccc;
  position: absolute;
  right: 8px;
  top: 23%;
  font-size: 3px; */
}
.position-relative {
  position: relative;
}
.colora {
  color: black;
}
.colorb {
  color: #55953B;
}
.select-inputcolor {
  border: 2px solid#55953B;
  color: #55953B;
  font-weight: bold;
}
/* #8575 処方の各種入力ボックスが、キーボード入力＋検索つきプルダウンでなくなっている。 訾浩 end */
/* ドラッグしている要素のghost */
.ghost {
  opacity: 0.5;
}
.moved-row {
  background-color: #ccffcc;
}
.custom-element-edited {
  color: green;
  border: 2px green solid !important;
}

/* 明細行：ボタン列 + 入力列 */
.prescription-detail-row {
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
  width: 100%;
}
/* 左：処方列（削除/並び替え/追加ボタンのエリア）を固定幅に */
.prescription-detail-row > .custom-btn-area {
  flex: 0 0 8em;
  max-width: 8em;
}
/* 右：薬剤・用法、数量、単位列は残り幅を全部使う */
.prescription-detail-row > .custom-input-area {
  flex: 1 1 auto;
  min-width: 0;
}

/* NOTE: 区分「薬剤のF1/F2」用「ons-row width:100%」対応 */
.rx-drug-f1-wrap,
.rx-drug-f2-wrap {
  width: auto !important;
  flex-basis: 0 !important;
  min-width: 0;
}
.rx-drug-f1-wrap { flex: 2 1 0 !important; }
.rx-drug-f2-wrap { flex: 1 1 0 !important; }
/* リフィル関連の調整 */
.refill-inline {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  width: 22em;
  margin-left: 5px;
}
.refill-label {
  width: 5em;
  text-align: left;
}
.refill-checkbox {
  flex: 0 0 auto;
}
.refill-paren,
.refill-unit {
  width: 1em;
  text-align: center;
}
.refill-number {
  flex: 0 0 auto;
  width: 3em;
}
/* アラートダイアログを前面に表示するため吹き出し表示位置調整 */
.popover-style >>> .popover-mask,
.popover-style >>> .popover {
  z-index: 10000 !important;
}
</style>
