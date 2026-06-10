<template>
  <!-- モーダルの中身はモーダルと一緒に描画しないとCSSが正常に適用されないのでv-if -->
  <modal-base @onClose="closeModal">
    <div id="visible-area-detailed-search" slot="body" class="visible-area">
      <table class="search-area">
        <tr class="detailed-search-data">
          <table>
            <tr>
              <td class="d-flex align-items-center flex-wrap">
                ｶｽﾀﾑ検索選択
                <v-ons-select
                  v-model="selectingQueryIndex"
                  @change="selectQuery()"
                >
                  <option :value="null"></option>
                  <option
                    v-for="(el, index) in patSearchDetails"
                    :key="`クエリ${index}`"
                    :value="index"
                  >
                    {{ el.queryName }}
                  </option>
                </v-ons-select>
                <v-ons-button
                  :disabled="selectingQueryIndex === null"
                  :class="[
                    'common-style-ok-button btn1-execute separate-item-header',
                    isWidthMobile ? 'width-button-header' : '',
                  ]"
                  @click="updateQuery()"
                >
                  更新
                </v-ons-button>
                <v-ons-button
                  :disabled="selectingQueryIndex === null"
                  style="margin-right: 5px"
                  :class="[
                    'common-style-ok-button btn1-execute separate-item-header',
                    isWidthMobile ? 'width-button-header' : '',
                  ]"
                  @click="deleteQuery()"
                >
                  削除
                </v-ons-button>
              </td>
            </tr>
            <tr class="query-area">
              ｶｽﾀﾑ検索名<v-ons-input type="text" v-model="queryName" />
              <v-ons-button
                :disabled="queryName === ''"
                :class="[
                  'common-style-ok-button btn1-execute separate-item-header',
                  isWidthMobile ? 'width-button-header' : '',
                ]"
                @click="addQuery()"
              >
                追加
              </v-ons-button>
            </tr>
            <tr class="search-data">
              <table class="search-treat-area">
                <tr class="treat-area-title">
                  <th class="search-treat-title color-header" colspan="2">
                    患者情報
                  </th>
                </tr>
                <tr class="td_box">
                  <td class="td_left">患者ID</td>
                  <td class="td_right">
                    <v-ons-input v-model="searchQuery.hospPatId" type="text" />
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">患者名・カナ</td>
                  <td class="td_right">
                    <v-ons-input v-model="searchQuery.patName" type="text" />
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">カナ頭文字(行)</td>
                  <td class="td_right flex_class">
                    <label
                      class="labelRMargin"
                      v-for="initialChar in nameInitialChars"
                      :key="initialChar.value"
                    >
                      <v-ons-checkbox
                        v-model="searchQuery.nameInitialList"
                        :value="initialChar.value"
                      >
                      </v-ons-checkbox>
                      {{ initialChar.displayValue }}
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">性別</td>
                  <td class="td_right flex_class">
                    <label
                      v-for="(itemData, itemIndex) in checkArray"
                      :key="itemIndex"
                      class="labelRMargin"
                    >
                      <v-ons-checkbox
                        v-model="searchQuery.patSex"
                        :value="itemIndex"
                      >
                      </v-ons-checkbox>
                      {{ itemData }}
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">年齢</td>
                  <td class="td_right">
                    <v-ons-input
                      v-model="ageLower"
                      type="text"
                      class="age-input"
                      maxlength="3"
                    />
                    歳 ～
                    <v-ons-input
                      v-model="ageUpper"
                      type="text"
                      class="age-input"
                      maxlength="3"
                    />
                    歳
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">血液型(ABO)</td>
                  <td class="td_right flex_class">
                    <label
                      class="labelRMargin"
                      v-for="bloodTypeABO in bloodTypesABO"
                      :key="`ABO${bloodTypeABO.value}`"
                    >
                      <v-ons-checkbox
                        v-model="searchQuery.bloodTypeAboList"
                        :value="bloodTypeABO.value"
                      >
                      </v-ons-checkbox>
                      {{ bloodTypeABO.displayValue }}
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">血液型(Rh)</td>
                  <td class="td_right flex_class">
                    <label
                      class="labelRMargin"
                      v-for="bloodTypeRh in bloodTypesRh"
                      :key="`Rh${bloodTypeRh.value}`"
                    >
                      <v-ons-checkbox
                        v-model="searchQuery.bloodTypeRhList"
                        :value="bloodTypeRh.value"
                      >
                      </v-ons-checkbox>
                      {{ bloodTypeRh.displayValue }}
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">血液型(亜型)</td>
                  <td class="td_right flex_class">
                    <label
                      class="labelRMargin"
                      v-for="bloodTypeSerovar in bloodTypesSerovar"
                      :key="`亜型${bloodTypeSerovar.value}`"
                    >
                      <v-ons-checkbox
                        v-model="searchQuery.bloodTypeSerovarList"
                        :value="bloodTypeSerovar.value"
                      >
                      </v-ons-checkbox>
                      {{ bloodTypeSerovar.displayValue }}
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">血糖検査</td>
                  <td class="td_right flex_class">
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="blood-suger-exam"
                        value=""
                        v-model="searchQuery.isBloodSugerExam"
                      ></v-ons-radio>
                      指定しない
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="blood-suger-exam"
                        value="1"
                        v-model="searchQuery.isBloodSugerExam"
                      ></v-ons-radio
                      >あり
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="blood-suger-exam"
                        value="0"
                        v-model="searchQuery.isBloodSugerExam"
                      ></v-ons-radio
                      >なし
                    </label>
                  </td>
                </tr>
                <tr class="td_box" v-show="canUsedSetting('A01')">
                  <td class="td_left">保険当月未確認</td>
                  <td class="td_right flex_class">
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="insurance-check-date"
                        value=""
                        v-model="searchQuery.insurance_check_date"
                      ></v-ons-radio>
                      指定しない
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="insurance-check-date"
                        value="1"
                        v-model="searchQuery.insurance_check_date"
                      ></v-ons-radio
                      >あり
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="insurance-check-date"
                        value="0"
                        v-model="searchQuery.insurance_check_date"
                      ></v-ons-radio
                      >なし
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">インプラント</td>
                  <td class="td_right flex_class">
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="implant"
                        value=""
                        v-model="searchQuery.isImplant"
                      ></v-ons-radio>
                      指定しない
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="implant"
                        value="1"
                        v-model="searchQuery.isImplant"
                      ></v-ons-radio
                      >あり
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="implant"
                        value="0"
                        v-model="searchQuery.isImplant"
                      ></v-ons-radio
                      >なし
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">透析困難</td>
                  <td class="td_right flex_class">
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="isDialDiff"
                        value=""
                        v-model="searchQuery.isDialDiff"
                      ></v-ons-radio>
                      指定しない
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="isDialDiff"
                        value="1"
                        v-model="searchQuery.isDialDiff"
                      ></v-ons-radio
                      >あり
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="isDialDiff"
                        value="0"
                        v-model="searchQuery.isDialDiff"
                      ></v-ons-radio
                      >なし
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">透析歴</td>
                  <td class="td_right">
                    <!-- mod #11047 数値IF修正 張玲 start -->
                    <!-- <v-ons-input
                      v-model="searchQuery.dialHstLower.year"
                      type="number"
                      class="age-input"
                      min="0"
                      max="99"
                    /> -->
                    <custom-input-number-pro
                      class="age-input"
                      :class="blurFlg ? 'age-input-blur':''"
                      :value="searchQuery.dialHstLower.year"
                      @blur="blurFlg = true"
                      :step="1"
                      :min="0"
                      :max="99"
                      @handlerInput="(val)=>{searchQuery.dialHstLower.year = val}"
                    />
                    <!-- mod #11047 数値IF修正 張玲 end -->
                    年
                    <!-- mod #11047 数値IF修正 張玲 start -->
                    <!-- <v-ons-input
                      v-model="searchQuery.dialHstLower.month"
                      type="number"
                      class="age-input"
                      min="0"
                      max="11"
                    /> -->
                    <custom-input-number-pro
                      class="age-input"
                      :class="blurFlg ? 'age-input-blur':''"
                      :value="searchQuery.dialHstLower.month"
                      @blur="blurFlg = true"
                      :step="1"
                      :min="0"
                      :max="11"
                      @handlerInput="(val)=>{searchQuery.dialHstLower.month = val}"
                    />
                    <!-- mod #11047 数値IF修正 張玲 end -->
                    ヶ月 ～
                    <!-- mod #11047 数値IF修正 張玲 start -->
                    <!-- <v-ons-input
                      v-model="searchQuery.dialHstUpper.year"
                      type="number"
                      class="age-input"
                      min="0"
                      max="99"
                    /> -->
                    <custom-input-number-pro
                      class="age-input"
                      :class="blurFlg ? 'age-input-blur':''"
                      :value="searchQuery.dialHstUpper.year"
                      @blur="blurFlg = true"
                      :step="1"
                      :min="0"
                      :max="99"
                      @handlerInput="(val)=>{searchQuery.dialHstUpper.year = val}"
                    />
                    <!-- mod #11047 数値IF修正 張玲 end -->
                    年
                    <!-- mod #11047 数値IF修正 張玲 start -->
                    <!-- <v-ons-input
                      v-model="searchQuery.dialHstUpper.month"
                      type="number"
                      class="age-input"
                      min="0"
                      max="11"
                    /> -->
                    <custom-input-number-pro
                      class="age-input"
                      :class="blurFlg ? 'age-input-blur':''"
                      :value="searchQuery.dialHstUpper.month"
                      @blur="blurFlg = true"
                      :step="1"
                      :min="0"
                      :max="11"
                      @handlerInput="(val)=>{searchQuery.dialHstUpper.month = val}"
                    />
                    <!-- mod #11047 数値IF修正 張玲 end -->
                    ヶ月
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">自施設通信透析回数</td>
                  <td class="td_right">
                    <!-- mod #11047 数値IF修正 張玲 start -->
                    <!-- <v-ons-input
                      v-model.number="searchQuery.dialysisCountLower"
                      type="number"
                      class="age-input"
                      maxlength="3"
                      min="0"
                    /> -->
                    <custom-input-number-pro
                      class="age-input"
                      :class="blurFlg ? 'age-input-blur':''"
                      :value="searchQuery.dialysisCountLower"
                      @blur="blurFlg = true"
                      :step="1"
                      :min="0"
                      :max="99999"
                      @handlerInput="(val)=>{searchQuery.dialysisCountLower = val}"
                    />
                    <!-- mod #11047 数値IF修正 張玲 end -->
                    ～
                    <!-- mod #11047 数値IF修正 張玲 start -->
                    <!-- <v-ons-input
                      v-model.number="searchQuery.dialysisCountUpper"
                      type="number"
                      class="age-input"
                      maxlength="3"
                      min="0"
                    /> -->
                    <custom-input-number-pro
                      class="age-input"
                      :class="blurFlg ? 'age-input-blur':''"
                      :value="searchQuery.dialysisCountUpper"
                      @blur="blurFlg = true"
                      :step="1"
                      :min="0"
                      :max="99999"
                      @handlerInput="(val)=>{searchQuery.dialysisCountUpper = val}"
                    />
                    <!-- mod #11047 数値IF修正 張玲 end -->
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">自施設通信特殊浄化回数</td>
                  <td class="td_right">
                    <!-- mod #11047 数値IF修正 張玲 start -->
                    <!-- <v-ons-input
                      v-model.number="searchQuery.purificationCountLower"
                      type="number"
                      class="age-input"
                      maxlength="3"
                      min="0"
                    /> -->
                    <custom-input-number-pro
                      class="age-input"
                      :class="blurFlg ? 'age-input-blur':''"
                      :value="searchQuery.purificationCountLower"
                      @blur="blurFlg = true"
                      :step="1"
                      :min="0"
                      :max="99999"
                      @handlerInput="(val)=>{searchQuery.purificationCountLower = val}"
                    />
                    <!-- mod #11047 数値IF修正 張玲 end -->
                    ～
                    <!-- mod #11047 数値IF修正 張玲 start -->
                    <!-- <v-ons-input
                      v-model.number="searchQuery.purificationCountUpper"
                      type="number"
                      class="age-input"
                      maxlength="3"
                      min="0"
                    /> -->
                    <custom-input-number-pro
                      class="age-input"
                      :class="blurFlg ? 'age-input-blur':''"
                      :value="searchQuery.purificationCountUpper"
                      @blur="blurFlg = true"
                      :step="1"
                      :min="0"
                      :max="99999"
                      @handlerInput="(val)=>{searchQuery.purificationCountUpper = val}"
                    />
                    <!-- mod #11047 数値IF修正 張玲 end -->
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">入外区分</td>
                  <td class="td_right flex_class">
                    <label
                      class="labelRMargin"
                      v-for="inOutClass in inOutClasses"
                      :key="`入外区分${inOutClass.value}`"
                    >
                      <v-ons-checkbox
                        v-model="searchQuery.inOutClassList"
                        :value="inOutClass.value"
                      >
                      </v-ons-checkbox>
                      {{ inOutClass.displayValue }}
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">糖尿病患者</td>
                  <td class="td_right flex_class">
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="diabetes"
                        value="0"
                        v-model="searchQuery.isDiabetes"
                      ></v-ons-radio>
                      非糖尿病患者
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="diabetes"
                        value="1"
                        v-model="searchQuery.isDiabetes"
                      ></v-ons-radio>
                      糖尿病患者
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">在院状態</td>
                  <td class="td_right">
                    <div class="flex_class">
                      <label
                        class="labelRMargin"
                        v-for="inOutState in inOutStates.slice(
                          0,
                          Number(inOutStates.length / 2)
                        )"
                        :key="`在院状態${inOutState.value}`"
                      >
                        <v-ons-checkbox
                          v-model="searchQuery.inOutStateList"
                          :value="inOutState.value"
                        >
                        </v-ons-checkbox>
                        {{ inOutState.displayValue }}
                      </label>
                    </div>
                    <div class="flex_class">
                      <label
                        class="labelRMargin"
                        v-for="inOutState in inOutStates.slice(
                          Number(inOutStates.length / 2)
                        )"
                        :key="`在院状態${inOutState.value}`"
                      >
                        <v-ons-checkbox
                          v-model="searchQuery.inOutStateList"
                          :value="inOutState.value"
                        >
                        </v-ons-checkbox
                        >{{ inOutState.displayValue }}
                      </label>
                    </div>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">車いす利用</td>
                  <td class="td_right flex_class">
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name=""
                        value=""
                        v-model="searchQuery.isWheelChair"
                      ></v-ons-radio
                      >指定しない
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name=""
                        value="1"
                        v-model="searchQuery.isWheelChair"
                      ></v-ons-radio
                      >使用
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name=""
                        value="0"
                        v-model="searchQuery.isWheelChair"
                      ></v-ons-radio
                      >未使用
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">搬送区分</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      :value="searchQuery.transportName"
                      disabled
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectTransport"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverTabooTransport()"
                    >
                      選択
                    </v-ons-button>
                    <mst-popover
                      v-bind="popoverDataTabooTransport"
                      :target-position-element="$refs.btnSelectTransport"
                      @popover-return="
                        setTabooTransport($event.value, $event.text)
                      "
                      @popover-close="closePopover(popoverDataTabooTransport)"
                    />
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">重症度</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      :value="searchQuery.severityName"
                      disabled
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectSeverity"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverTabooSeverity()"
                    >
                      選択
                    </v-ons-button>
                    <mst-popover
                      v-bind="popoverDataTabooSeverity"
                      :target-position-element="$refs.btnSelectSeverity"
                      @popover-return="
                        setTabooSeverity($event.value, $event.text)
                      "
                      @popover-close="closePopover(popoverDataTabooSeverity)"
                    />
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">主治医</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      :value="searchQuery.staffNameDoctor"
                      disabled
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectDoctor"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverStaff('Doctor')"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">主病</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      :value="searchQuery.primary_disease_name"
                      disabled
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectPrimaryDisease"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverPrimaryDisease"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">担当</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      :value="searchQuery.staffNameCharge"
                      disabled
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectCharge"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverStaff('Charge')"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">穿刺</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      :value="searchQuery.staffNamePuncture"
                      disabled
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectPuncture"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverStaff('Puncture')"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">禁忌</td>
                  <td class="td_right">
                    <v-ons-input
                      v-if="searchQuery.tabooCd === null"
                      type="text"
                      v-model="searchQuery.tabooContent"
                      disabled
                      class="input rp-input disabled-input my-input"
                    />
                    <v-ons-input
                      v-if="searchQuery.tabooCd !== null"
                      type="text"
                      v-model="searchQuery.tabooContent"
                      disabled
                      class="input rp-input disabled-input my-input"
                    />
                    <v-ons-button
                      ref="btnSelectTaboo"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverTabooAllergy('Taboo')"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">アレルギー</td>
                  <td class="td_right">
                    <v-ons-input
                      v-if="searchQuery.allergyCd === null"
                      type="text"
                      v-model="searchQuery.allergyContent"
                      disabled
                      class="input rp-input disabled-input my-input"
                    />
                    <v-ons-input
                      v-if="searchQuery.allergyCd !== null"
                      type="text"
                      v-model="searchQuery.allergyContent"
                      disabled
                      class="input rp-input disabled-input my-input"
                    />
                    <v-ons-button
                      ref="btnSelectAllergy"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverTabooAllergy('Allergy')"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">診療科</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      v-model="searchQuery.courseName"
                      :disabled="true"
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectCourse"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverCourse('Course')"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">透析実施科</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      v-model="searchQuery.dialCourseName"
                      :disabled="true"
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectDialCourse"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverDialCourse('DialCourse')"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">病棟</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      v-model="searchQuery.wardName"
                      :disabled="true"
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectWard"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverWard('Ward')"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">透析導入原疾患</td>
                  <td class="td_right">
                    <label
                      @click="setClosePopup()"
                      style="width: 500px !important"
                      class="treatment-select custom-treatment-select"
                    >
                    <!-- modify #9482 start -->
                    <!-- <kendo-multiselect
                        style="width: 500px !important"
                        v-model="searchQuery.dialysis_underlying_disease_List"
                        :data-source="mstDisease"
                        data-text-field="diseaseName"
                        data-value-field="diseaseCd"
                      /> -->
                      <kendo-datasource
                        ref="diseaseDatasource"
                        :data="mstDisease"
                      ></kendo-datasource>
                      <kendo-multiselect
                        style="width: 500px !important;"
                        v-model="searchQuery.dialysis_underlying_disease_List"
                        :data-source-ref="'diseaseDatasource'"
                        data-text-field="nm"
                        data-value-field="cd"
                        :virtual-value-mapper="diseaseValueMapperFunc"
                      />
                      <!-- modify #9482 end -->
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">感染症</td>
                  <td class="td_right flex_class">
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="is-infect"
                        value=""
                        v-model="searchQuery.isInfect"
                      ></v-ons-radio
                      >指定しない
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="is-infect"
                        value="1"
                        v-model="searchQuery.isInfect"
                      ></v-ons-radio
                      >あり
                    </label>
                    <label class="labelRMargin">
                      <v-ons-radio
                        modifier="round"
                        name="is-infect"
                        value="0"
                        v-model="searchQuery.isInfect"
                      ></v-ons-radio
                      >なし
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">既往歴</td>
                  <td class="td_right">・転帰</td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right">
                    <div class="flex_class">
                      <label
                        class="labelRMargin"
                        v-for="outCome in outComeClasses.slice(
                          0,
                          Number(outComeClasses.length / 2)
                        )"
                        :key="`転帰${outCome.class}`"
                      >
                        <v-ons-checkbox
                          v-model="searchQuery.outComeList"
                          :value="outCome.class"
                        >
                        </v-ons-checkbox>
                        {{ outCome.name }}
                      </label>
                    </div>
                    <div class="flex_class">
                      <label
                        class="labelRMargin"
                        v-for="outCome in outComeClasses.slice(
                          Number(outComeClasses.length / 2)
                        )"
                        :key="`転帰${outCome.class}`"
                      >
                        <v-ons-checkbox
                          v-model="searchQuery.outComeList"
                          :value="outCome.class"
                        >
                        </v-ons-checkbox
                        >{{ outCome.name }}
                      </label>
                    </div>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right">・病名</td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      :value="searchQuery.diseaseName"
                      disabled
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectDisease"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverDisease"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box" v-show="isShowPatGroup">
                  <td class="td_left">患者グループ</td>
                  <td class="td_right patient_box">
                    <div
                      style="
                        width: 500px !important;
                        float: left;
                        margin-right: 1em;
                      "
                    >
                      <kendo-multiselect
                        v-model="searchQuery.patGroups"
                        :data-source="patGroups"
                        data-text-field="patGroupName"
                        data-value-field="patGroupCd"
                      />
                    </div>
                    <div style="display: inline-block">
                      <label class="radio vertical-align-center">
                        <v-ons-radio
                          modifier="round"
                          name="queryPatGroupsMethod"
                          value="1"
                          v-model="searchQuery.patGroupsMethod"
                        ></v-ons-radio>
                        <span class="label">含む</span>
                      </label>
                      <label
                        class="radio vertical-align-center"
                        style="margin-left: 6px"
                      >
                        <v-ons-radio
                          modifier="round"
                          name="queryPatGroupsMethod"
                          value="2"
                          v-model="searchQuery.patGroupsMethod"
                        ></v-ons-radio>
                        <span class="label">一致する</span>
                      </label>
                    </div>
                  </td>
                </tr>
                <tr v-show="isShowPatGroup" class="td_box">
                  <td class="td_left">連絡先氏名</td>
                  <td class="td_right">
                    <v-ons-row>
                      <v-ons-input
                        type="text"
                        v-model="searchQuery.lastName"
                        placeholder="姓"
                      />
                      <v-ons-input
                        type="text"
                        style="margin-left: 5px"
                        v-model="searchQuery.firstName"
                        placeholder="名"
                      />
                    </v-ons-row>
                  </td>
                </tr>
                <tr v-show="isShowPatGroup" class="td_box">
                  <td class="td_left">連絡フリガナ</td>
                  <td class="td_right">
                    <v-ons-row>
                      <v-ons-input
                        type="text"
                        v-model="searchQuery.lastNameKana"
                        placeholder="セイ"
                      />
                      <v-ons-input
                        type="text"
                        style="margin-left: 5px"
                        v-model="searchQuery.firstNameKana"
                        placeholder="メイ"
                      />
                    </v-ons-row>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">続柄</td>
                  <td class="td_right">
                    <v-ons-input
                      v-if="searchQuery.relationCd === null"
                      type="text"
                      v-model="searchQuery.relationName"
                    />
                    <v-ons-input
                      v-if="searchQuery.relationCd !== null"
                      type="text"
                      v-model="searchQuery.relationName"
                      disabled
                      class="input rp-input disabled-input"
                    />
                    <v-ons-button
                      ref="btnSelectRelationship"
                      class="common-style-select-button leftbtn"
                      @click="showPopoverRelationship"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">連絡先(業者)会社名</td>
                  <td class="td_right">
                    <v-ons-input
                      type="text"
                      v-model="searchQuery.companyName"
                    />
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">連絡先(業者)担当者名</td>
                  <td class="td_right">
                    <v-ons-row>
                      <v-ons-input
                        type="text"
                        v-model="searchQuery.workerLastName"
                        placeholder="姓"
                      />
                      <v-ons-input
                        type="text"
                        style="margin-left: 5px"
                        v-model="searchQuery.workerFirstName"
                        placeholder="名"
                      />
                    </v-ons-row>
                  </td>
                </tr>
                <tr class="td_box" v-if="isAdditionShow">
                  <td class="td_left">加算・管理料</td>
                  <td class="td_right patient_box">
                    <div style="margin-right: 1em;">
                      <v-ons-input
                        type="text"
                        :value="searchQuery.additionName"
                        disabled
                        class="input rp-input disabled-input"
                      />
                      <v-ons-button
                        ref="btnSelectAddtion"
                        class="common-style-select-button leftbtn"
                        @click="showPopoverAddition()"
                      >
                        選択
                      </v-ons-button>
                    </div>
                    <div>
                      <label>
                        <v-ons-radio
                          modifier="round"
                          name="addition-search-condition"
                          value="true"
                          v-model="searchQuery.additionSearchCondition"
                        >
                        </v-ons-radio
                        >あり
                      </label>
                      <label>
                        <v-ons-radio
                          modifier="round"
                          name="addition-search-condition"
                          value="false"
                          v-model="searchQuery.additionSearchCondition"
                        >
                        </v-ons-radio
                        >なし
                      </label>
                    </div>
                    <mst-popover
                      v-bind="popoverDataAddition"
                      :target-position-element="$refs.btnSelectAddtion"
                      @popover-return="setAddition($event.value, $event.text)"
                      @popover-close="closePopover(popoverDataAddition)"
                    />
                  </td>
                </tr>
              </table>

              <table class="search-treat-area">
                <tr class="treat-area-title">
                  <th class="search-treat-title color-header" colspan="2">
                    治療予定
                  </th>
                </tr>
                <tr class="td_box">
                  <td class="td_left">治療方法</td>
                  <td class="td_right1">
                    <label
                      @click="setClosePopup()"
                      class="treatment-select custom-treatment-select"
                    >
                      <kendo-multiselect
                        v-model="searchQuery.treatmentCdList"
                        :data-source="mstTreatmentInfo"
                        data-text-field="treatmentName"
                        data-value-field="treatmentCd"
                      />
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">ダイアライザ</td>
                  <td class="td_right1">
                    <label
                      @click="setClosePopup()"
                      class="treatment-select custom-treatment-select"
                    >
                      <kendo-multiselect
                        v-model="searchQuery.dialyzerCdList"
                        :data-source="mstDialyzer"
                        data-text-field="modelNumber"
                        data-value-field="dialyzerCd"
                      />
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">透析予定</td>
                  <td class="td_right">・透析予定期間</td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right">
                    <label>
                      <v-ons-radio
                        value="specifiedPeriod"
                        v-model="searchQuery.dialysisDateArgs"
                        modifier="round"
                        name="ScheduledDialysis"
                        @click="dialysisDate"
                      ></v-ons-radio
                      >指定期間
                      <date-input
                        :classes="'ntss-input-date custom-ntss-input-date dialysisStartDate'"
                        v-model="searchQuery.dialysisStartDate"
                        @keyup="showDialysisStartDateMsg(0)"
                        @blur="getDialysisStartDateMsg(0)"
                        @handleClearInput="searchQuery.dialysisStartDate = null"
                      />
                      <common-calendar
                        v-model="searchQuery.dialysisStartDate"
                        class="calender dialysisStartDate-comment"
                      />
                      <span
                        class="error-message"
                        v-if="showDialysisStartDate"
                        >{{ this.msgDiaLog }}</span
                      >
                      ～
                      <date-input
                        :classes="'ntss-input-date custom-ntss-input-date dialysisEndDate'"
                        v-model="searchQuery.dialysisEndDate"
                        @keyup="showDialysisEndDateMsg(0)"
                        @blur="getDialysisEndDateMsg(0)"
                        @handleClearInput="searchQuery.dialysisEndDate = null"
                      />
                      <common-calendar
                        v-model="searchQuery.dialysisEndDate"
                        class="calender dialysisEndDate-comment"
                      />
                      <span class="error-message" v-if="showDialysisEndDate">{{
                        this.msgDiaLog
                      }}</span>
                    </label>
                    <br />
                    <div class="flex_class">
                      <label
                        class="labelRMargin"
                        v-for="param in dialysis"
                        :key="param.args"
                      >
                        <v-ons-radio
                          :value="param.args"
                          v-model="searchQuery.dialysisDateArgs"
                          modifier="round"
                          name="ScheduledDialysis"
                          @click="dialysisDate(param.args)"
                        ></v-ons-radio>
                        {{ param.text }}
                      </label>
                    </div>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right">・クール</td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right1">
                    <label
                      @click="setClosePopup()"
                      class="treatment-select custom-treatment-select"
                    >
                      <kendo-multiselect
                        v-model="searchQuery.kurCdList"
                        :data-source="mstKur"
                        data-text-field="kurName"
                        data-value-field="kurCd"
                      />
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right">・ベッドグループ・透析室</td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right1">
                    <label
                      @click="setClosePopup()"
                      class="treatment-select custom-treatment-select"
                    >
                      <kendo-multiselect
                        v-model="searchQuery.bedGroupCdList"
                        :data-source="mstRoomBedGroup"
                        data-text-field="roomBedGroupName"
                        data-value-field="roomBedGroupCd"
                      />
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right">・曜日</td>
                </tr>
                <tr class="td_box">
                  <td class="td_left"></td>
                  <td class="td_right1">
                    <v-ons-row>
                      <v-ons-col>
                        <div
                          v-for="(week, index) in indWeeks"
                          :key="`曜日${index}`"
                        >
                          <input
                            v-model="searchQuery.treatDayOfWeekList"
                            class="week-checkbox"
                            type="checkbox"
                            :value="week.value"
                            :checked="week.done"
                            :id="'dtWeekCheck-' + index"
                            style="display: none"
                            @change="changeValue(week, $event.target.checked)"
                          />
                          <label
                            :for="'dtWeekCheck-' + index"
                            onclick="null"
                            style="cursor: pointer"
                            class="week-button"
                            >{{ week.text }}</label
                          >
                        </div>
                      </v-ons-col>
                    </v-ons-row>
                  </td>
                </tr>
                <tr v-for="i in 5" :key="`透析条件${i}`" class="td_box">
                  <td class="td_left">{{ i === 1 ? "透析条件" : "" }}</td>
                  <td class="td_right class_td">
                    <v-ons-select
                      class="ntss-separate-dosing"
                      v-model="searchQuery.selectingDialCondId[i]"
                      @change="initDialysisCondition(i)"
                    >
                      <option :value="null"></option>
                      <option
                        v-for="item in DIAL_COND_ITEMS"
                        :key="`透析条件種別${item.id}`"
                        :value="item.id"
                      >
                        {{ item.name }}
                      </option>
                    </v-ons-select>
                    <!-- リスト選択 -->
                    <div
                      class="class_td"
                      v-if="
                        selectingDialCondType(i) === DIAL_COND_TYPE.LIST_SELECT
                      "
                    >
                      <v-ons-input
                        type="text"
                        contenteditable="true"
                        :value="
                          selectedListNames(
                            searchQuery.dialysisConditionList[i]
                              .selectedItemList
                          )
                        "
                        disabled
                        class="input rp-input disabled-input my-input"
                      />
                      <v-ons-button
                        :ref="`dialysisConditionSelector${i}`"
                        class="common-style-select-button leftbtn"
                        @click="listSelectDialCond(i)"
                      >
                        選択
                      </v-ons-button>
                    </div>
                    <!-- 範囲値選択 -->
                    <div
                      v-if="
                        selectingDialCondType(i) === DIAL_COND_TYPE.RANGE_VALUE
                      "
                    >
                      <label>
                        <v-ons-radio
                          modifier="round"
                          :name="`dialCondRangeRadio${i}`"
                          :value="COMPARISON_TYPE.INEQUALITY"
                          v-model="
                            searchQuery.dialysisConditionList[i].comparisonType
                          "
                          @change="initRangeValue(i)"
                        ></v-ons-radio>
                        範囲
                      </label>
                      <label>
                        <v-ons-radio
                          modifier="round"
                          :name="`dialCondRangeRadio${i}`"
                          :value="COMPARISON_TYPE.EQUALITY"
                          v-model="
                            searchQuery.dialysisConditionList[i].comparisonType
                          "
                          @change="initEqualValue(i)"
                        ></v-ons-radio>
                        一致
                      </label>
                      <div
                        class="agreement_box"
                        v-if="
                          searchQuery.dialysisConditionList[i].comparisonType ==
                          COMPARISON_TYPE.EQUALITY
                        "
                      >
                        <!-- 値一致指定 -->
                        {{ selectingDialCondName(i) }} ＝
                        <v-ons-input
                          type="text"
                          v-model="
                            searchQuery.dialysisConditionList[i].value1String
                          "
                        />
                      </div>
                      <div v-else class="agreement_box align-items-center">
                        <!-- 値範囲指定 -->
                        <div
                          style="
                            display: flex;
                            flex-wrap: nowrap;
                            margin-right: 0.5em;
                          "
                        >
                          <v-ons-input
                            type="text"
                            v-model="
                              searchQuery.dialysisConditionList[i].value1String
                            "
                          />
                          <v-ons-select
                            v-model="
                              searchQuery.dialysisConditionList[i]
                                .inequalitySign1
                            "
                          >
                            <option :value="INEQUALITY_SIGN.LESS_OR_EQUAL">
                              &le;
                            </option>
                            <option :value="INEQUALITY_SIGN.LESS">&lt;</option>
                          </v-ons-select>
                        </div>
                        <div class="flex_class" style="align-items: center">
                          <label style="margin-right: 0.5em">{{
                            selectingDialCondName(i)
                          }}</label>
                          <div style="display: flex; flex-wrap: nowrap">
                            <v-ons-select
                              v-model="
                                searchQuery.dialysisConditionList[i]
                                  .inequalitySign2
                              "
                            >
                              <option :value="INEQUALITY_SIGN.LESS_OR_EQUAL">
                                &le;
                              </option>
                              <option :value="INEQUALITY_SIGN.LESS">
                                &lt;
                              </option>
                            </v-ons-select>
                            <v-ons-input
                              type="text"
                              v-model="
                                searchQuery.dialysisConditionList[i]
                                  .value2String
                              "
                            />
                          </div>
                        </div>
                      </div>
                    </div>
                    <!-- ラジオボタン選択 -->
                    <div
                      v-else-if="
                        selectingDialCondType(i) === DIAL_COND_TYPE.RADIO
                      "
                    >
                      <label>
                        <v-ons-radio
                          modifier="round"
                          :name="`dialCondRadio${i}`"
                          :value="dialCondRadio(1, i).value"
                          v-model="searchQuery.dialysisConditionList[i].value"
                        >
                        </v-ons-radio>
                        {{ dialCondRadio(1, i).label }}
                      </label>
                      <label>
                        <v-ons-radio
                          modifier="round"
                          :name="`dialCondRadio${i}`"
                          :value="dialCondRadio(2, i).value"
                          v-model="searchQuery.dialysisConditionList[i].value"
                        >
                        </v-ons-radio>
                        {{ dialCondRadio(2, i).label }}
                      </label>
                    </div>
                    <!-- 時間選択 -->
                    <div
                      v-else-if="
                        selectingDialCondType(i) === DIAL_COND_TYPE.TIME
                      "
                    >
                      <label class="custom-input-time">
                        <custom-input-time-pro
                          v-model="searchQuery.dialysisConditionList[i].lowerTime"
                        />
                        ～
                        <custom-input-time-pro
                          v-model="searchQuery.dialysisConditionList[i].upperTime"
                        />
                      </label>
                    </div>
                  </td>
                </tr>
                <tr v-for="i in 5" :key="`投薬指示${i}`" class="td_box">
                  <td class="td_left">{{ i === 1 ? "投薬指示" : "" }}</td>
                  <td class="td_right class_td">
                    <v-ons-select
                      class="ntss-separate-dosing"
                      v-model="searchQuery.medicationSelectorClass[i]"
                      @change="initMedication(i)"
                    >
                      <option :value="null"></option>
                      <option
                        v-for="mst in mstMedicineClass"
                        :key="`薬剤分類${mst.classCd}`"
                        :value="mst.classCd"
                      >
                        {{ mst.className }}
                      </option>
                      <option :value="0">未分類</option>
                    </v-ons-select>
                    <v-ons-input
                      type="text"
                      contenteditable="true"
                      :value="selectedListNames(searchQuery.medicationList[i])"
                      disabled
                      class="input rp-input disabled-input my-input"
                    />
                    <v-ons-button
                      :ref="`medicationSelector${i}`"
                      class="common-style-select-button leftbtn"
                      :disabled="
                        searchQuery.medicationSelectorClass[i] === null
                      "
                      @click="listSelectMedication(i)"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr v-for="i in 5" :key="`医材指示${i}`" class="td_box">
                  <td class="td_left">{{ i === 1 ? "医材指示" : "" }}</td>
                  <td class="td_right class_td">
                    <v-ons-select
                      class="ntss-separate-medical"
                      v-model="searchQuery.equipmentSelectorClass[i]"
                      @change="initEquipment(i)"
                    >
                      <option :value="null"></option>
                      <option
                        v-for="mst in mstEquipmentClass"
                        :key="`医材分類${mst.classCd}`"
                        :value="mst.classCd"
                      >
                        {{ mst.className }}
                      </option>
                      <option :value="0">未分類</option>
                    </v-ons-select>
                    <v-ons-input
                      type="text"
                      contenteditable="true"
                      :value="selectedListNames(searchQuery.equipmentList[i])"
                      disabled
                      class="input rp-input disabled-input my-input"
                    />
                    <v-ons-button
                      :ref="`equipmentSelector${i}`"
                      class="common-style-select-button leftbtn"
                      :disabled="searchQuery.equipmentSelectorClass[i] === null"
                      @click="listSelectEquipment(i)"
                    >
                      選択
                    </v-ons-button>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">指示コメント</td>
                  <td class="td_right1">
                    <label>
                      <v-ons-radio
                        modifier="round"
                        name="ind-comment"
                        value="3"
                        v-model="searchQuery.indCommentList[0]"
                      ></v-ons-radio
                      >前方一致
                    </label>
                    <label>
                      <v-ons-radio
                        modifier="round"
                        name="ind-comment"
                        value="2"
                        v-model="searchQuery.indCommentList[0]"
                      ></v-ons-radio
                      >部分一致
                    </label>
                    <div class="custom-com-textarea">
                      <com-textarea
                        class="custom-area-style"
                        :content="searchQuery.indCommentList[1]"
                        idTextarea="com-textarea-detail1"
                        cssClass="textarea-custom-text-font textarea-resize-vertical"
                        @set-content-data="setContentData($event, 1)"
                      ></com-textarea>
                      <com-textarea
                        class="custom-area-style"
                        :content="searchQuery.indCommentList[2]"
                        idTextarea="com-textarea-detail2"
                        cssClass="textarea-custom-text-font textarea-resize-vertical"
                        @set-content-data="setContentData($event, 2)"
                      ></com-textarea>
                      <com-textarea
                        class="custom-area-style"
                        :content="searchQuery.indCommentList[3]"
                        cssClass="textarea-custom-text-font textarea-resize-vertical"
                        idTextarea="com-textarea-detail3"
                        @set-content-data="setContentData($event, 3)"
                      ></com-textarea>
                    </div>
                  </td>
                </tr>
              </table>
              <table class="search-treat-area">
                <tr class="treat-area-title">
                  <th class="search-treat-title color-header" colspan="2">
                    検査予定
                  </th>
                </tr>
                <tr class="td_box">
                  <td class="td_left">検査セット</td>
                  <td class="td_right1">
                    <label
                      @click="setClosePopup()"
                      class="treatment-select custom-treatment-select"
                    >
                      <kendo-multiselect
                        v-model="searchQuery.examSetCdList"
                        :data-source="mstExamSetInfo"
                        data-text-field="examSetName"
                        data-value-field="examSetCd"
                      />
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">曜日</td>
                  <td class="td_right">
                    <v-ons-row>
                      <v-ons-col>
                        <div
                          v-for="(week, index) in indWeeks"
                          :key="`曜日${index}`"
                        >
                          <input
                            v-model="searchQuery.exam_week"
                            class="week-checkbox"
                            type="checkbox"
                            :value="week.value"
                            :checked="week.done"
                            :id="'dtWeekCheck2-' + index"
                            style="display: none"
                            @change="
                              changeValueForExemWeek(
                                week,
                                $event.target.checked,
                                'exam_week'
                              )
                            "
                          />
                          <label
                            :for="'dtWeekCheck2-' + index"
                            onclick="null"
                            style="cursor: pointer"
                            class="week-button"
                            >{{ week.text }}</label
                          >
                        </div>
                      </v-ons-col>
                    </v-ons-row>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">タイミング</td>
                  <td class="td_right">
                    <label>
                      <v-ons-radio
                        modifier="round"
                        name="reg_order_class"
                        value="1"
                        v-model="searchQuery.reg_order_class"
                      ></v-ons-radio
                      >透析前
                    </label>
                    <label>
                      <v-ons-radio
                        modifier="round"
                        name="reg_order_class"
                        value="2"
                        v-model="searchQuery.reg_order_class"
                      ></v-ons-radio
                      >透析後
                    </label>
                    <label>
                      <v-ons-radio
                        modifier="round"
                        name="reg_order_class"
                        value="0"
                        v-model="searchQuery.reg_order_class"
                      ></v-ons-radio
                      >その他
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">指示期間</td>
                  <td class="td_right">
                    <label>
                      <date-input style="float: left"
                        :classes="'ntss-input-date custom-ntss-input-date exam_pattern_start_date'"
                        max='2099-12-31'
                        v-model='searchQuery.exam_pattern_start_date'
                        @keyup="showDialysisStartDateMsg(1)"
                        @blur="getDialysisStartDateMsg(1)"
                        @handleClearInput="searchQuery.exam_pattern_start_date = null"
                      />
                      <common-calendar
                        style="float: left"
                        class="calender exam_pattern_start_date-comment"
                        v-model="searchQuery.exam_pattern_start_date"
                      />
                      <span
                        class="error-message"
                        style="float: left; margin-top: 6px"
                        v-if="showExamPatternStartDate"
                        >{{ this.msgDiaLog }}</span
                      >
                      <div
                        style="float: left"
                        v-if="searchQuery.exam_pattern !== 1"
                      >
                        <label style="float: left">&nbsp; ～ &nbsp;</label>
                       <date-input style="float: left"
                         :classes="'ntss-input-date custom-ntss-input-date exam_pattern_end_date'"
                         max='2099-12-31'
                         v-model='searchQuery.exam_pattern_end_date'
                         @keyup="showDialysisEndDateMsg(1)"
                         @blur="showDialysisEndDateMsg(1)"
                         @handleClearInput="searchQuery.exam_pattern_end_date = null"
                        />
                        <common-calendar
                          style="float: left"
                          class="calender exam_pattern_end_date-comment"
                          v-model="searchQuery.exam_pattern_end_date"
                        />
                        <span
                          class="error-message"
                          style="float: left; margin-top: 6px"
                          v-if="showExamPatternEndDate"
                          >{{ this.msgDiaLog }}</span
                        >
                      </div>
                    </label>
                  </td>
                </tr>
              </table>
              <table class="search-treat-area">
                <tr class="treat-area-title">
                  <th class="search-treat-title color-header" colspan="2">
                    一般撮影検査予定
                  </th>
                </tr>
                <tr class="td_box">
                  <td class="td_left">曜日</td>
                  <td class="td_right">
                    <v-ons-row>
                      <v-ons-col>
                        <div
                          v-for="(week, index) in indWeeks"
                          :key="`曜日${index}`"
                        >
                          <input
                            v-model="searchQuery.radPattern_exam_week"
                            class="week-checkbox"
                            type="checkbox"
                            :value="week.value"
                            :checked="week.done"
                            :id="'dtWeekCheck3-' + index"
                            style="display: none"
                            @change="
                              changeValueForExemWeek(
                                week,
                                $event.target.checked,
                                'radPattern_exam_week'
                              )
                            "
                          />
                          <label
                            :for="'dtWeekCheck3-' + index"
                            onclick="null"
                            style="cursor: pointer"
                            class="week-button"
                            >{{ week.text }}</label
                          >
                        </div>
                      </v-ons-col>
                    </v-ons-row>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">指示期間</td>
                  <td class="td_right">
                    <label>
                      <date-input
                        style="float: left"
                        :classes="'ntss-input-date custom-ntss-input-date radPattern_exam_pattern_start_date'"
                        @keyup="showDialysisStartDateMsg(2)"
                        @blur="getDialysisStartDateMsg(2)"
                        max='2099-12-31'
                        v-model='searchQuery.radPattern_exam_pattern_start_date'
                        @handleClearInput="searchQuery.radPattern_exam_pattern_start_date = null"
                      />
                      <common-calendar
                        style="float: left"
                        class="
                          calender
                          radPattern_exam_pattern_start_date-comment
                        "
                        v-model="searchQuery.radPattern_exam_pattern_start_date"
                      />
                      <span
                        class="error-message"
                        style="float: left; margin-top: 6px"
                        v-if="radPatternExamPatternStartDate"
                        >{{ this.msgDiaLog }}</span
                      >
                      <div
                        style="float: left"
                        v-if="searchQuery.radPattern_exam_pattern !== 1"
                      >
                        <label style="float: left">&nbsp; ～ &nbsp;</label>
                        <date-input style="float: left"
                          :classes="'ntss-input-date custom-ntss-input-date radPattern_exam_pattern_end_date'"
                          @keyup="showDialysisEndDateMsg(2)"
                          @blur="getDialysisEndDateMsg(2)"
                          max='2099-12-31' v-model='searchQuery.radPattern_exam_pattern_end_date'
                          @handleClearInput="searchQuery.radPattern_exam_pattern_end_date = null"
                        />
                        <common-calendar
                          style="float: left"
                          class="
                            calender
                            radPattern_exam_pattern_end_date-comment
                          "
                          v-model="searchQuery.radPattern_exam_pattern_end_date"
                        />
                        <span
                          class="error-message"
                          style="float: left; margin-top: 6px"
                          v-if="radPatternExamPatternEndDate"
                          >{{ this.msgDiaLog }}</span
                        >
                      </div>
                    </label>
                  </td>
                </tr>
              </table>
              <table class="search-treat-area">
                <tr class="treat-area-title">
                  <th class="search-treat-title color-header" colspan="2">
                    患者イベント
                  </th>
                </tr>
                <tr class="td_box">
                  <td class="td_left">カテゴリ</td>
                  <td class="td_right1">
                    <label @click="setClosePopup()">
                      <kendo-multiselect
                        v-model="searchQuery.categoryList"
                        :data-source="category"
                        data-text-field="categoryName"
                        data-value-field="categoryCd"
                      />
                    </label>
                  </td>
                </tr>
                <tr class="td_box">
                  <td class="td_left">イベント日</td>
                  <td class="td_right">
                    <date-input
                      :classes="'ntss-input-date custom-ntss-input-date eventStartDate'"
                      @keyup="showDialysisStartDateMsg(3)" @blur="getDialysisStartDateMsg(3)"
                      v-model="searchQuery.eventStartDate"
                      @handleClearInput="searchQuery.eventStartDate = null"
                    />
                    <common-calendar
                      v-model="searchQuery.eventStartDate"
                      class="calender eventStartDate-comment"
                    />
                    <span class="error-message" v-if="showeventStartDate">{{
                      this.msgDiaLog
                    }}</span>
                    ～
                    <date-input
                      :classes="'ntss-input-date custom-ntss-input-date eventEndDate'"
                      @keyup="showDialysisEndDateMsg(3)" @blur="getDialysisEndDateMsg(3)"
                      v-model="searchQuery.eventEndDate"
                      @handleClearInput="searchQuery.eventEndDate = null"
                    />
                    <common-calendar
                      v-model="searchQuery.eventEndDate"
                      class="calender eventEndDate-comment"
                    />
                    <span class="error-message" v-if="showeventEndDate">{{
                      this.msgDiaLog
                    }}</span>
                  </td>
                </tr>
              </table>
            </tr>
          </table>
        </tr>
      </table>

      <!-- スタッフ選択ポップオーバー -->
      <mst-popover
        v-bind="popoverDataStaff"
        :target-position-element="targetElementStaff"
        @popover-return="setStaff($event.value, $event.text)"
        @popover-close="closePopover(popoverDataStaff)"
      />
      <!-- 禁忌・アレルギー選択ポップオーバー -->
      <mst-popover
        v-bind="popoverDataTabooAllergy"
        :target-position-element="targetElementTabooAllergy"
        @popover-return="setTabooAllergy($event.value, $event.text)"
        @popover-close="closePopover(popoverDataTabooAllergy)"
      />
      <!-- 診療科選択ポップオーバー -->
      <mst-popover
        v-bind="popoverDataCourse"
        :target-position-element="targetElementCourse"
        @popover-return="setCourse($event.value, $event.text)"
        @popover-close="closePopover(popoverDataCourse)"
      />
      <!-- 透析実施科選択ポップオーバー -->
      <mst-popover
        v-bind="popoverDataDialysisCourse"
        :target-position-element="targetElementDialCourse"
        @popover-return="setDialysisCourse($event.value, $event.text)"
        @popover-close="closePopover(popoverDataDialysisCourse)"
      />
      <!-- 病棟選択ポップオーバー -->
      <mst-popover
        v-bind="popoverDataWard"
        :target-position-element="targetElementWard"
        @popover-return="setWard($event.value, $event.text)"
        @popover-close="closePopover(popoverDataWard)"
      />
      <!-- 病名選択ポップオーバー -->
      <!-- #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start -->
      <!-- <mst-popover
        v-bind="popoverDataDisease"
        :target-position-element="$refs.btnSelectDisease"
        @popover-return="setDisease($event.value, $event.text)"
        @popover-close="closePopover(popoverDataDisease)"
      /> -->
      <pop-over-disea
        v-bind="popoverDataDisease"
        :target-position-element="$refs.btnSelectDisease"
        @popver-search-condition="setDiseaPopoverSearchCondition"
        @popover-return="setDisease($event.value, $event.text)"
        @popover-close="closePopover(popoverDataDisease)"
      />
      <!-- #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end -->
      <!-- add 主病選択ポップオーバー  周ウェイ博-->
      <!-- #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start -->
      <!-- <mst-popover
        v-bind="popoverDataPrimaryDisease"
        :target-position-element="$refs.btnSelectPrimaryDisease"
        @popover-return="setPrimaryDisease($event.value, $event.text)"
        @popover-close="closePopover(popoverDataPrimaryDisease)"
      /> -->
      <pop-over-disea
        v-bind="popoverDataPrimaryDisease"
        :target-position-element="$refs.btnSelectPrimaryDisease"
        @popver-search-condition="setPopoverSearchCondition"
        @popover-return="setPrimaryDisease($event.value, $event.text)"
        @popover-close="closePopover(popoverDataPrimaryDisease)"
      />
      <!-- #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end -->
      <!-- 続柄選択ポップオーバー   -->
      <mst-popover
        v-bind="popoverDataRelationship"
        :target-position-element="$refs.btnSelectRelationship"
        @popover-return="setRelationship($event.value, $event.text)"
        @popover-close="closePopover(popoverDataRelationship)"
      />
      <!-- 透析条件選択 -->
      <list-selector
        :key="componentKey('透析条件')"
        :visible.sync="isDialCondSelectorVisible"
        v-bind="dialCondSelectorData"
        :target="
          selectorTarget('dialysisConditionSelector', selectingDialCondIndex)
        "
        @commit="commitDialCondListSelect($event)"
      />
      <!-- 投薬指示選択 -->
      <list-selector
        :key="componentKey('投薬')"
        :visible.sync="isMedicationSelectorVisible"
        v-bind="medicationSelectorData"
        :target="selectorTarget('medicationSelector', selectingMedicationIndex)"
        @commit="commitMedication($event)"
      />
      <!-- 医材指示選択 -->
      <list-selector
        :key="componentKey('医材')"
        :visible.sync="isEquipmentSelectorVisible"
        v-bind="equipmentSelectorData"
        :target="selectorTarget('equipmentSelector', selectingEquipmentIndex)"
        @commit="commitEquipment($event)"
      />
      <message-dialog
        v-if="messageDialogInfo.isDialogVisible"
        :visible.sync="messageDialogInfo.isDialogVisible"
        :message-cd="messageDialogInfo.messageCd"
        :type="messageDialogInfo.type"
      />
    </div>

    <div id="button-area-detailed-search" slot="footer" class="button-area">
      <div style="margin-bottom: 5px">
        <v-ons-button
          class="common-style-cancel-button btn2-cancel widthClass"
          style="margin-right: 5px"
          @click="closeModal()"
        >
          <span class="fontMagin">閉じる</span>
        </v-ons-button>
        <v-ons-button
          class="common-style-cancel-button btn2-cancel widthClass"
          style="margin-right: 5px"
          @click="clearConditon()"
        >
          <span class="fontMagin">条件クリア</span>
        </v-ons-button>
        <v-ons-button
          class="common-style-cancel-button btn2-cancel widthClass"
          @click="clearPatList()"
        >
          <span class="fontMagin">患者一覧クリア</span>
        </v-ons-button>
      </div>
      <div>
        <v-ons-button
          style="margin-right: 5px"
          :disabled="
            showDialysisStartDate ||
            showDialysisEndDate ||
            showExamPatternEndDate ||
            showExamPatternStartDate ||
            radPatternExamPatternStartDate ||
            radPatternExamPatternEndDate ||
            showeventStartDate ||
            showeventEndDate
          "
          class="common-style-ok-button btn3-normal widthClass"
          @click="searchAllPat()"
        >
          <span class="fontMagin">全患者検索</span>
        </v-ons-button>
        <v-ons-button
          class="common-style-ok-button btn3-normal widthClass"
          style="margin-right: 5px"
          :disabled="
            showDialysisStartDate ||
            showDialysisEndDate ||
            showExamPatternEndDate ||
            showExamPatternStartDate ||
            radPatternExamPatternStartDate ||
            radPatternExamPatternEndDate ||
            showeventStartDate ||
            showeventEndDate
          "
          @click="searchPatPatGroup()"
        >
          <span class="fontMagin">検索</span>
        </v-ons-button>
        <v-ons-button
          class="common-style-ok-button btn3-normal widthClass"
          :disabled="
            showDialysisStartDate ||
            showDialysisEndDate ||
            showExamPatternEndDate ||
            showExamPatternStartDate ||
            radPatternExamPatternStartDate ||
            radPatternExamPatternEndDate ||
            showeventStartDate ||
            showeventEndDate
          "
          @click="additionalSearchPat()"
          v-throttle
        >
          <span class="fontMagin">追加検索</span>
        </v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
// ライブラリ
import $$ from "jquery";
import _ from "underscore";
import moment from "moment";
import { mapActions, mapGetters, mapMutations } from "vuex";
// コンポーネント
import mstPopover from "@/components/common/master-selector/MasterSelector.vue";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import listSelector from "@/components/common/list-selector/ListSelector.vue";
// 共通関数
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { course, dialyzer, disease, equipment, equipmentClass, medicine, medicineClass, medicineMix, roomBedGroup, tabooAllergy, treatment, va, ward } from "@/functions/mst/MstGetters.js";
import {
  closePopover,
  createPopoverData,
  createPopoverDataAddition,
  createPopoverDataSeverity,
  createPopoverDataTransport,
  showPopover,
} from "@/functions/PopoverFunctions";
import {
  createClassData,
  createItemListData,
} from "@/functions/for-componet/ListSelector.js";
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { EventBus } from "@/eventBus.js";
import { deduplicateObjectsGroup } from "@/functions/common/CommonFunctions.js";
import {
  COMPARISON_TYPE,
  DIAL_COND_ID,
  DIAL_COND_ITEMS,
  DIAL_COND_RADIO_DEFINITION,
  DIAL_COND_TYPE,
  DiaysisConditionListSelect,
  DiaysisConditionRadio,
  DiaysisConditionRangeValue,
  DiaysisConditionTime,
  EQUIPMENT_TYPE,
  INEQUALITY_SIGN,
  MEDICINE_TYPE,
  SearchQuery,
} from "./SearchDefinitions.js";

import { FUNC_PAT_GROUP } from "@/constants/function-code";
import CommonTextArea from "@/components/common/CommonTextArea";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start
import DiseaMasterSelector from "@/components/common/master-selector/DiseaMasterSelector.vue"
// #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end
import DateInput from "@/components/common/DateInput.vue";
// add #11047 数値IF修正 張玲 start
import CustomInputNumberPro from '@/components/common/custom-form-tags/CustomInputNumberPro'
// add #11047 数値IF修正 張玲 end
import CustomInputTimePro from "@/components/common/custom-form-tags/CustomInputTimePro";

const importedFunctions = { showPopover, closePopover };

class CheckTypeValue {
  constructor(value, displayValue) {
    this.value = value;
    this.displayValue = displayValue;
  }
}

export default {
  components: {
    "list-selector": listSelector,
    "mst-popover": mstPopover,
    "common-calendar": commonCalender,
    "com-textarea": CommonTextArea,
    ModalBase,
    "message-dialog": messageDialog,
    // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng start
    "pop-over-disea": DiseaMasterSelector,
    // #9482 患者情報画面/新規患者登録の表示が遅い。linjunfeng end
    DateInput,
    // add #11047 数値IF修正 張玲 start
    "custom-input-number-pro":CustomInputNumberPro,
    // add #11047 数値IF修正 張玲 end
    "custom-input-time-pro": CustomInputTimePro
  },

  mixins: [MultiModalMixin],

  data() {
    return {
      showDialogVisible: false,
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: null,
        stringParams: [],
      },
      checkArray: ["不明", "男性", "女性"],
      // 検索中フラグ
      isSearching: false,

      // カナ頭文字
      nameInitialChars: [
        new CheckTypeValue("ァ-オ|ヴ", "ア"),
        new CheckTypeValue("カ-ゴ", "カ"),
        new CheckTypeValue("サ-ゾ", "サ"),
        new CheckTypeValue("タ-ド", "タ"),
        new CheckTypeValue("ナ-ノ", "ナ"),
        new CheckTypeValue("ハ-ポ", "ハ"),
        new CheckTypeValue("マ-モ", "マ"),
        new CheckTypeValue("ャ-ヨ", "ヤ"),
        new CheckTypeValue("ラ-ロ", "ラ"),
        new CheckTypeValue("ヮ-ン", "ワ"),
      ],

      // 血液型ABO
      bloodTypesABO: [
        new CheckTypeValue(0, "不明"),
        new CheckTypeValue(1, "A"),
        new CheckTypeValue(2, "B"),
        new CheckTypeValue(3, "O"),
        new CheckTypeValue(4, "AB"),
      ],

      // 血液型Rh
      bloodTypesRh: [
        new CheckTypeValue(0, "不明"),
        new CheckTypeValue(1, "Rh+"),
        new CheckTypeValue(2, "Rh-"),
      ],

      // 血液型亜型
      bloodTypesSerovar: [
        new CheckTypeValue(0, "不明"),
        new CheckTypeValue(11, "A1"),
        new CheckTypeValue(12, "Aint"),
        new CheckTypeValue(13, "A2"),
        new CheckTypeValue(14, "A3"),
        new CheckTypeValue(15, "Ax"),
        new CheckTypeValue(16, "Am"),
        new CheckTypeValue(17, "Ael"),
        new CheckTypeValue(18, "Aend"),
        new CheckTypeValue(21, "B1"),
        new CheckTypeValue(22, "Bint"),
        new CheckTypeValue(23, "B2"),
        new CheckTypeValue(24, "B3"),
        new CheckTypeValue(25, "Bx"),
        new CheckTypeValue(26, "Bm"),
        new CheckTypeValue(27, "Bel"),
        new CheckTypeValue(28, "Bend"),
        new CheckTypeValue(31, "Oh"),
        new CheckTypeValue(32, "Ah"),
        new CheckTypeValue(33, "Bh"),
        new CheckTypeValue(34, "Om"),
      ],
      /* ドロップダウンボックスを表示するかどうか */
      isSelectedDialysis: false,
      itemSelectorData: null,
      /* 担当者 */
      // マスタデータ
      mstStaff: null,
      // ポップオーバー用データ
      popoverDataStaff: {},
      // どの担当者ポップオーバーを表示しているかを表す文字列
      showingPopoverStaffClass: "",

      /* 禁忌・アレルギー */
      // マスタデータ
      mstTabooAllergy: null,
      // ポップオーバー用データ
      popoverDataTabooAllergy: {},
      // 禁忌・アレルギーどちらのポップオーバーを表示しているかを表す文字列
      showingPopoverTabooAllergy: "",
      popoverDataTabooSeverity: {},
      popoverDataTabooTransport: {},
      popoverDataAddition: {},
      //診療科
      popoverDataCourse: {},
      mstCourse: null,
      showingPopoverCourse: "",
      //透析実施科
      popoverDataDialysisCourse: {},
      showingPopoverDialysisCourse: "",
      //病棟
      popoverDataWard: {},
      mstWard: null,
      showingPopoverWard: "",
      popoverDataRelationship: {},

      /* 既往歴用 */
      popoverDataDisease: {},
      popoverDataPrimaryDisease: {},
      mstDisease: null,

      /* 透析予定用 */
      mstKur: null,
      mstRoomBedGroup: null,
      mstTreatmentInfo: null,
      mstExamSetInfo: null,

      // 入外区分定義
      inOutClasses: [
        {
          value: "0",
          displayValue: "外来",
        },
        {
          value: "1",
          displayValue: "入院",
        },
        {
          value: "2",
          displayValue: "死亡",
        },
        {
          value: "3",
          displayValue: "－",
        },
      ],

      // 在院状態定義
      inOutStates: [
        {
          value: "0",
          displayValue: "在院",
        },
        {
          value: "1",
          displayValue: "導入予定",
        },
        {
          value: "2",
          displayValue: "転入予定",
        },
        {
          value: "103",
          displayValue: "転出予定",
        },
        {
          value: "3",
          displayValue: "転出",
        },
        {
          value: "7",
          displayValue: "離脱",
        },
        {
          value: "8",
          displayValue: "移植",
        },
        {
          value: "9",
          displayValue: "一時転出",
        },
        {
          value: "10",
          displayValue: "不明",
        },
        {
          value: "11",
          displayValue: "死亡",
        },
      ],
      diabetes: [
        { value: "0", text: "非糖尿病患者" },
        { value: "1", text: "糖尿病患者" },
      ],
      dialysis: [
        { args: "today", text: "本日" },
        { args: "yesterday", text: "昨日" },
        { args: "tomorrow", text: "明日" },
        { args: "thisWeek", text: "今週" },
        { args: "lastWeek", text: "先週" },
        { args: "nextWeek", text: "来週" },
        { args: "thisMonth", text: "今月" },
        { args: "lastMonth", text: "先月" },
        { args: "nextMonth", text: "来月" },
      ],
      // 転帰区分定義
      outComeClasses: [
        { class: "1", name: "治療中" },
        { class: "2", name: "診断のみ" },
        { class: "3", name: "治癒" },
        { class: "4", name: "軽快" },
        { class: "5", name: "寛解" },
        { class: "6", name: "不変" },
        { class: "7", name: "増悪" },
        { class: "8", name: "中止" },
        { class: "9", name: "転医" },
        { class: "10", name: "死亡" },
      ],
      indWeeks: [
        {
          text: "全",
          done: false,
          value: 0,
        },
        {
          text: "月",
          done: false,
          value: 1,
        },
        {
          text: "火",
          done: false,
          value: 2,
        },
        {
          text: "水",
          done: false,
          value: 3,
        },
        {
          text: "木",
          done: false,
          value: 4,
        },
        {
          text: "金",
          done: false,
          value: 5,
        },
        {
          text: "土",
          done: false,
          value: 6,
        },
        {
          text: "日",
          done: false,
          value: 7,
        },
      ],

      /* 透析条件用 */
      // マスタ
      mstDialyzer: null,
      mstDialyzerClass: null,
      mstVa: null,

      // 分類コードと分類区分のペア
      medicineClassTypePair: {},
      equipmentClassTypePair: {},

      // 透析条件リスト選択表示フラグ
      isDialCondSelectorVisible: false,
      // 透析条件リスト選択用データ
      dialCondSelectorData: null,
      // 透析条件リスト選択の表示起点特定用インデックス
      selectingDialCondIndex: null,
      // templateでも使いたい定数
      DIAL_COND_ITEMS,
      DIAL_COND_TYPE,
      COMPARISON_TYPE,
      INEQUALITY_SIGN,

      /******************
        投薬指示用
       ******************/

      mstMedicine: null,
      mstMedicineMix: null,
      mstMedicineClass: null,
      isMedicationSelectorVisible: false,
      selectingMedicationIndex: null,
      medicationSelectorData: null,
      /********************
            拡張設定
       *******************/
      insurance: false,

      /******************
        医材指示用
       ******************/
      mstEquipment: null,
      mstEquipmentClass: null,
      isEquipmentSelectorVisible: false,
      selectingEquipmentIndex: null,
      equipmentSelectorData: null,
      /**続柄 */
      relationshipData: null,
      DiaysisSelectorData: null,
      queryName: "",
      selectingQueryIndex: null,
      selectingQuery: {
        queryId: null,
        queryName: "",
        query: new SearchQuery(),
      },
      isDialDiff: null,
      severity: [],
      transport: [],
      category: [],
      mstAdditionList: [],
      isAdditionShow: false,
      additionSettingCode: "",
      advancedSettings: [],
      patGroups: [],
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showDialysisStartDate: false,
      showDialysisEndDate: false,
      showExamPatternStartDate: false,
      showExamPatternEndDate: false,
      radPatternExamPatternStartDate: false,
      radPatternExamPatternEndDate: false,
      showeventStartDate: false,
      showeventEndDate: false,
      // add #11047 数値IF修正【最優先】 張玲 start
      blurFlg : false,
      // add #11047 数値IF修正【最優先】 張玲 end

    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("user", { AdvancedSettings: "getAdvancedSettings" }),
    ...mapGetters("facility", ["useFunction"]),
    // mod 11872 利用者指定IFのデフォルト選択状態 zrx liyanze start  患者詳細検索
    ...mapGetters("account-edit", ["getStateUserAccountInfo",]),
    // mod 11872 利用者指定IFのデフォルト選択状態 zrx liyanze end  患者詳細検索
    ...mapGetters("window-size", {
      windowWidth: "getWindowWidth",
    }),
    // mod 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 start
    // ...mapGetters("pat-info", ["patSearchDetails"]),
    ...mapGetters("pat-info", ["patSearchDetails","getPatGroupEditSortCondition","getPatGroupEditAddSearchedPatInfo"]),
    // mod 9266 患者情報を編集して保存すると患者検索の並び順が変化する 関 end
    /**
     * @description 編集中のクエリ
     */
    searchQuery() {
      return this.selectingQuery.query;
    },

    /**
     * @description 年齢下限
     */
    ageLower: {
      get() {
        return this.searchQuery.ageLower;
      },
      set(inputAge) {
        this.searchQuery.ageLower = this.stringToNumber(inputAge);
      },
    },

    /**
     * @description 年齢上限
     */
    ageUpper: {
      get() {
        return this.searchQuery.ageUpper;
      },
      set(inputAge) {
        this.searchQuery.ageUpper = this.stringToNumber(inputAge);
      },
    },

    /**
     * @description 主治医選択用医師リスト
     */
    staffListDoctor() {
      return this.mstStaff.filter((staff) => staff.job_cd === "1");
    },

    /**
     * @description 担当者選択ポップオーバーの表示起点要素
     */
    targetElementStaff() {
      return this.$refs[`btnSelect${this.showingPopoverStaffClass}`];
    },

    /**
     * @description 禁忌・アレルギー選択ポップオーバーの表示起点要素
     */
    targetElementTabooAllergy() {
      return this.$refs[`btnSelect${this.showingPopoverTabooAllergy}`];
    },
    /**
     * @description 診療科選択ポップオーバーの表示起点要素
     */
    targetElementCourse() {
      return this.$refs[`btnSelect${this.showingPopoverCourse}`];
    },
    /**
     * @description 透析実施科選択ポップオーバーの表示起点要素
     */
    targetElementDialCourse() {
      return this.$refs[`btnSelect${this.showingPopoverDialysisCourse}`];
    },
    /**
     * @description 病棟選択ポップオーバーの表示起点要素
     */
    targetElementWard() {
      return this.$refs[`btnSelect${this.showingPopoverWard}`];
    },

    isShowPatGroup() {
      return this.useFunction.includes(FUNC_PAT_GROUP);
    },
    isWidthMobile() {
      if (this.windowWidth > 576) {
        return false;
      }
      return true;
    },
  },

  watch: {
    windowWidth() {
      this.setAreaHeight();
    },
    "searchQuery.dialysisStartDate": {
      handler: function () {
        if (
          document.getElementsByClassName("dialysisStartDate")[0]
            .validationMessage !== ""
        ) {
          this.showDialysisStartDate = !(
            document.getElementsByClassName("dialysisStartDate")[0].value ===
              "" &&
            document.getElementsByClassName("dialysisStartDate-comment")[0]
              .value !== ""
          );
        } else {
          this.showDialysisStartDate = false;
        }
      },
    },
    "searchQuery.dialysisEndDate": {
      handler: function () {
        if (
          document.getElementsByClassName("dialysisEndDate")[0]
            .validationMessage !== ""
        ) {
          this.showDialysisEndDate = !(
            document.getElementsByClassName("dialysisEndDate")[0].value ===
              "" &&
            document.getElementsByClassName("dialysisEndDate-comment")[0]
              .value !== ""
          );
        } else {
          this.showDialysisEndDate = false;
        }
      },
    },
    "searchQuery.exam_pattern_start_date": {
      handler: function () {
        if (
          document.getElementsByClassName("exam_pattern_start_date")[0]
            .validationMessage !== ""
        ) {
          this.showExamPatternStartDate = !(
            document.getElementsByClassName("exam_pattern_start_date")[0]
              .value === "" &&
            document.getElementsByClassName(
              "exam_pattern_start_date-comment"
            )[0].value !== ""
          );
        } else {
          this.showExamPatternStartDate = false;
        }
      },
    },
    "searchQuery.exam_pattern_end_date": {
      handler: function () {
        if (
          document.getElementsByClassName("exam_pattern_end_date")[0]
            .validationMessage !== ""
        ) {
          this.showExamPatternEndDate = !(
            document.getElementsByClassName("exam_pattern_end_date")[0]
              .value === "" &&
            document.getElementsByClassName("exam_pattern_end_date-comment")[0]
              .value !== ""
          );
        } else {
          this.showExamPatternEndDate = false;
        }
      },
    },
    "searchQuery.radPattern_exam_pattern_start_date": {
      handler: function () {
        if (
          document.getElementsByClassName(
            "radPattern_exam_pattern_start_date"
          )[0].validationMessage !== ""
        ) {
          this.radPatternExamPatternStartDate = !(
            document.getElementsByClassName(
              "radPattern_exam_pattern_start_date"
            )[0].value === "" &&
            document.getElementsByClassName(
              "radPattern_exam_pattern_start_date-comment"
            )[0].value !== ""
          );
        } else {
          this.radPatternExamPatternStartDate = false;
        }
      },
    },
    "searchQuery.radPattern_exam_pattern_end_date": {
      handler: function () {
        if (
          document.getElementsByClassName("radPattern_exam_pattern_end_date")[0]
            .validationMessage !== ""
        ) {
          this.radPatternExamPatternEndDate = !(
            document.getElementsByClassName(
              "radPattern_exam_pattern_end_date"
            )[0].value === "" &&
            document.getElementsByClassName(
              "radPattern_exam_pattern_end_date-comment"
            )[0].value !== ""
          );
        } else {
          this.radPatternExamPatternEndDate = false;
        }
      },
    },
    "searchQuery.eventStartDate": {
      handler: function () {
        if (
          document.getElementsByClassName("eventStartDate")[0]
            .validationMessage !== ""
        ) {
          this.showeventStartDate = !(
            document.getElementsByClassName("eventStartDate")[0].value === "" &&
            document.getElementsByClassName("eventStartDate-comment")[0]
              .value !== ""
          );
        } else {
          this.showeventStartDate = false;
        }
      },
    },
    "searchQuery.eventEndDate": {
      handler: function () {
        if (
          document.getElementsByClassName("eventEndDate")[0]
            .validationMessage !== ""
        ) {
          this.showeventEndDate = !(
            document.getElementsByClassName("eventEndDate")[0].value === "" &&
            document.getElementsByClassName("eventEndDate-comment")[0].value !==
              ""
          );
        } else {
          this.showeventEndDate = false;
        }
      },
    },
  },

  async created() {
    let resKur, resUser, resPatSearchDetails;
    let patGroups;
    [
      this.mstTreatmentInfo,
      this.mstDialyzer,
      this.mstDisease,
      this.mstEquipment,
      this.mstEquipmentClass,
      resKur,
      this.mstMedicine,
      this.mstMedicineMix,
      this.mstMedicineClass,
      this.mstRoomBedGroup,
      this.mstTabooAllergy,
      this.severity,
      this.transport,
      this.mstAdditionList,
      this.mstCourse,
      this.mstWard,
      resUser,
      this.mstVa,
      patGroups,
      resPatSearchDetails,
      this.relationshipData,
      this.mstExamSetInfo,
    ] = await Promise.all([
      treatment(this.facilityCd),
      dialyzer(this.facilityCd),
      disease(this.facilityCd),
      equipment(this.facilityCd),
      equipmentClass(this.facilityCd),
      ApiHelper.get("/mstInfo/mstKur", {
        facility_cd: this.facilityCd,
        is_del: "0",
      }),
      medicine(this.facilityCd),
      medicineMix(this.facilityCd),
      medicineClass(this.facilityCd),
      roomBedGroup(this.facilityCd),
      tabooAllergy(this.facilityCd),
      ApiHelper.get("/mstInfo/mstSeverity", { facilityCd: this.facilityCd }),
      ApiHelper.get("/mstInfo/mstTransport", { facilityCd: this.facilityCd }),
      ApiHelper.get("/mstInfo/mstAddition", { facilityCd: this.facilityCd }),
      course(this.facilityCd),
      ward(this.facilityCd),
      ApiHelper.get(`/mstInfo/mstPersonalUser`, {
        facility_cd: this.facilityCd,
      }),

      va(this.facilityCd),
      ApiHelper.get("/pat_group", { facility_cd: this.facilityCd }),
      ApiHelper.get("/pat_search_detail"),
      ApiHelper.get("/master_maintenance/mst_relationship/data"),
      ApiHelper.get("/mstInfo/mstExamSet", { facilityCd: this.facilityCd }),
    ]).catch((error) => {
      getErrorMessage("DetailedSearch2.vue", "created", error);
      throw error;
    });

    ApiHelper.get("/pat_event/mst-category-list").then((response) => {
      this.category = response.data;
    });

    // 薬剤分類コードと分類区分をペアリング
    for (const mediClass of this.mstMedicineClass) {
      this.medicineClassTypePair[mediClass.classCd] = mediClass.classType;
    }

    // 医材分類コードと分類区分をペアリング
    for (const equipClass of this.mstEquipmentClass) {
      this.equipmentClassTypePair[equipClass.classCd] = equipClass.classType;
    }
    this.mstKur = resKur.data;
    this.mstStaff = resUser.data;
    // 詳細患者検索をリセットする
    this.setPatSearchDetails([]);
    resPatSearchDetails.data.forEach((detail) => {
      this.addPatSearchDetail({
        queryId: detail.searchCd,
        queryName: detail.searchName,
        query: JSON.parse(detail.searchCondition),
      });
    });
    // ポップオーバーデータ作成
    this.popoverDataStaff = createPopoverData(
      "スタッフ",
      null,
      null,
      "スタッフ名",
      this.mstStaff,
      "userId",
      "userLastName",
      null,
      "userFirstName"
    );

    this.popoverDataTabooAllergy = createPopoverData(
      "禁忌・アレルギー",
      null,
      null,
      "禁忌・アレルギー名",
      this.mstTabooAllergy,
      "tabooAllergyCd",
      "content",
      null
    );
    this.popoverDataCourse = createPopoverData(
      "診療科",
      null,
      null,
      "診療科名",
      this.mstCourse,
      "courseCd",
      "courseName",
      null
    );
    this.popoverDataDialysisCourse = createPopoverData(
      "透析実施科",
      null,
      null,
      "透析実施科名",
      this.mstCourse,
      "courseCd",
      "courseName",
      null
    );
    this.popoverDataWard = createPopoverData(
      "病棟",
      null,
      null,
      "病棟名",
      this.mstWard,
      "wardCd",
      "wardName",
      null
    );
    this.popoverDataPrimaryDisease = createPopoverData(
      "病名",
      null,
      null,
      "病名",
      this.mstDisease,
      // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start
      // "diseaseCd",
      // "diseaseName",
      "cd",
      "nm",
      // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end
      null
    );
    this.popoverDataTabooSeverity = createPopoverDataSeverity(
      "重症度",
      null,
      null,
      "重症度名",
      this.severity,
      null
    );
    this.popoverDataTabooTransport = createPopoverDataTransport(
      "搬送",
      null,
      null,
      "搬送",
      this.transport,
      null
    );

    this.popoverDataDisease = createPopoverData(
      "病名",
      null,
      null,
      "病名",
      this.mstDisease,
      // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  start
      // "diseaseCd",
      // "diseaseName",
      "cd",
      "nm",
      // mod 9482 患者情報画面/新規患者登録の表示が遅い。 関  end
      null
    );
    this.popoverDataRelationship = createPopoverData(
      "続柄",
      null,
      null,
      "続柄",
      this.relationshipData.data.localDataSource.data,
      "code",
      "name",
      null
    );
    this.popoverDataAddition = createPopoverDataAddition(
      "加算・管理料",
      null,
      null,
      "加算・管理料",
      this.mstAdditionList,
      null
    );
    this.patGroups = patGroups.data.patGroupInfo;
    EventBus.$emit("detailedSearchUserSearchQuery", this.patSearchDetails);
    this.AdvancedSettings.func_advcds.forEach((a) =>
      this.advancedSettings.push(a.func_advcd)
    );
    this.additionSettingCode = ADVANCED_SETTINGS.ADDITION_INFO;
    if (this.advancedSettings.includes(this.additionSettingCode)) {
      this.isAdditionShow = true;
    }
  },

  mounted() {
    // 要素の高さ調整
    this.setAreaHeight();
  },

  methods: {
    ...mapActions("multi-modal", ["showDetailedSearchModal"]),
    ...mapActions("pat-info", ["clearSearchedPatList","sortPatList", "clearSearchedPatListGroup"]),
    ...mapActions("pat-info", ["clearSearchedPatList","sortPatList"]),
    ...mapMutations("pat-info", [
      "addSearchedPatListPatGroup",
      "setPatSearchDetails",
      "addPatSearchDetail",
      "updatePatSearchDetail",
      "deletePatSearchDetail",
      "setPatGroupEditAddSearchedPatInfo",
      "updateUnSelectedPatList"
    ]),
    ...mapActions("loading-screen", ["startLoadingScreen", "finishLoadingScreen"]),
    ...importedFunctions,
    setPopoverSearchCondition (searchCondition) {
      this.popoverDataPrimaryDisease.popoverSearchQuery = searchCondition;
    },
    setDiseaPopoverSearchCondition (searchCondition) {
      this.popoverDataDisease.popoverSearchQuery = searchCondition;
    },
    diseaseValueMapperFunc (options) {
      const indexArr = [];
      this.mstDisease.forEach((item, index) => {
        if (options.value.includes(item.cd)) {
          indexArr.push(index);
        }
      });
      options.success(indexArr);
    },
    canUsedSetting(param) {
      try {
        let SettingsList = this.AdvancedSettings.func_advcds;
        for (let index = 0; index < SettingsList.length; index++) {
          if (SettingsList[index].func_advcd == param) return true;
        }
        return false;
      } catch (e) {
        getErrorMessage("DetailedSearch2.vue", "canUsedSetting", e);
        console.log(e);
      }
    },
    showPopoverDialysis() {
      this.isSelectedDialysis = true;
      this.popoverDataDialysis.popoverContentSelected.value =
        this.DIAL_COND_ITEMS;
      showPopover(this.popoverDataDialysis);
    },
    dialysisDate(day) {
      let nowDate = new Date();
      /* 1 :本日  2:昨日  3:明日 4:今週  5:先週
         6:来週  7:今月  8:先月  9:来月 */
      let time = nowDate.getTime();
      let week = nowDate.getDay();
      let Spacetime = "";
      let start = "";
      let end = "";
      switch (day) {
        case "today":
          start =
            nowDate.getFullYear() +
            "-" +
            (nowDate.getMonth() + 1) +
            "-" +
            nowDate.getDate();
          end =
            nowDate.getFullYear() +
            "-" +
            (nowDate.getMonth() + 1) +
            "-" +
            nowDate.getDate();
          break;
        case "yesterday":
          Spacetime = new Date(time - 24 * 60 * 60 * 1000);
          end = start =
            Spacetime.getFullYear() +
            "-" +
            (Spacetime.getMonth() + 1) +
            "-" +
            Spacetime.getDate();
          break;
        case "tomorrow":
          Spacetime = new Date(time + 24 * 60 * 60 * 1000);
          start = end =
            Spacetime.getFullYear() +
            "-" +
            (Spacetime.getMonth() + 1) +
            "-" +
            Spacetime.getDate();
          break;
        case "thisWeek":
          Spacetime = new Date(time - 24 * 60 * 60 * 1000 * (week - 1));
          start =
            Spacetime.getFullYear() +
            "-" +
            (Spacetime.getMonth() + 1) +
            "-" +
            Spacetime.getDate();
          Spacetime = new Date(time + 24 * 60 * 60 * 1000 * (7 - week));
          end =
            Spacetime.getFullYear() +
            "-" +
            (Spacetime.getMonth() + 1) +
            "-" +
            Spacetime.getDate();
          break;
        case "lastWeek":
          Spacetime = new Date(nowDate.getTime() - 24 * 60 * 60 * 1000 * week);
          end =
            Spacetime.getFullYear() +
            "-" +
            (Spacetime.getMonth() + 1) +
            "-" +
            Spacetime.getDate();
          Spacetime = new Date(
            nowDate.getTime() - 24 * 60 * 60 * 1000 * (week + 6)
          );
          start =
            Spacetime.getFullYear() +
            "-" +
            (Spacetime.getMonth() + 1) +
            "-" +
            Spacetime.getDate();
          break;
        case "nextWeek":
          Spacetime = new Date(
            nowDate.getTime() + 24 * 60 * 60 * 1000 * (8 - week)
          );
          start =
            Spacetime.getFullYear() +
            "-" +
            (Spacetime.getMonth() + 1) +
            "-" +
            Spacetime.getDate();
          Spacetime = new Date(
            nowDate.getTime() + 24 * 60 * 60 * 1000 * (14 - week)
          );
          end =
            Spacetime.getFullYear() +
            "-" +
            (Spacetime.getMonth() + 1) +
            "-" +
            Spacetime.getDate();
          break;
        case "thisMonth":
          start = nowDate.getFullYear() + "-" + (nowDate.getMonth() + 1) + "-1";
          end =
            nowDate.getFullYear() +
            "-" +
            (nowDate.getMonth() + 1) +
            "-" +
            new Date(
              nowDate.getFullYear(),
              nowDate.getMonth() + 1,
              0
            ).getDate();
          break;
        case "lastMonth":
          if (nowDate.getMonth() == 0) {
            end =
              nowDate.getFullYear() -
              1 +
              "-12-" +
              new Date(nowDate.getFullYear() - 1, 12, 0).getDate();
            start = nowDate.getFullYear() - 1 + "-12-1";
          } else {
            start = nowDate.getFullYear() + "-" + nowDate.getMonth() + "-1";
            end =
              nowDate.getFullYear() +
              "-" +
              nowDate.getMonth() +
              "-" +
              new Date(nowDate.getFullYear(), nowDate.getMonth(), 0).getDate();
          }
          break;
        case "nextMonth":
          if (nowDate.getMonth() == 11) {
            start = nowDate.getFullYear() + 1 + "-1-1";
            end =
              nowDate.getFullYear() +
              1 +
              "-1-" +
              new Date(nowDate.getFullYear() + 1, 1, 0).getDate();
          } else {
            start =
              nowDate.getFullYear() + "-" + (nowDate.getMonth() + 2) + "-1";
            end =
              nowDate.getFullYear() +
              "-" +
              (nowDate.getMonth() + 2) +
              "-" +
              new Date(
                nowDate.getFullYear(),
                nowDate.getMonth() + 2,
                0
              ).getDate();
          }
          break;
      }
      this.searchQuery.dialysisStartDate = start;
      this.searchQuery.dialysisEndDate = end;
    },
    //add 現在の年月日を取得する 周ウェイ博 end
    /**
     * @description 文字列→数値変換
     */
    stringToNumber(str) {
      if (str === "") {
        return null;
      } else {
        const num = Number(str);
        if (Number.isNaN(num)) {
          return null;
        } else {
          return num;
        }
      }
    },

    /**
     * @description 選択した透析条件項目に応じて対応する検索条件オブジェクトを設定する
     */
    initDialysisCondition(index) {
      // 選択中の透析条件項目ID
      const dialCondId = this.searchQuery.selectingDialCondId[index];
      if (dialCondId === null) {
        // 未指定
        this.searchQuery.dialysisConditionList[index] = null;
        return;
      }
      // 選択中の透析条件選択タイプ
      const dialCondType = this.selectingDialCondType(index);

      let dialCondObj = null;
      if (this.selectingDialCondType(index) === DIAL_COND_TYPE.LIST_SELECT) {
        // リスト選択
        dialCondObj = new DiaysisConditionListSelect(dialCondId, dialCondType);
      } else if (
        this.selectingDialCondType(index) === DIAL_COND_TYPE.RANGE_VALUE
      ) {
        // 範囲値
        dialCondObj = new DiaysisConditionRangeValue(dialCondId, dialCondType);
      } else if (this.selectingDialCondType(index) === DIAL_COND_TYPE.RADIO) {
        // ラジオボタン
        dialCondObj = new DiaysisConditionRadio(dialCondId, dialCondType);
      } else if (this.selectingDialCondType(index) === DIAL_COND_TYPE.TIME) {
        // 時間
        dialCondObj = new DiaysisConditionTime(dialCondId, dialCondType);
      }
      this.searchQuery.dialysisConditionList[index] = dialCondObj;
    },

    /**
     * @description 透析条件プルダウンで選択されている項目オブジェクト
     */
    selectingDialCondItem(index) {
      const dialCondItem = DIAL_COND_ITEMS.find(
        (item) => item.id === this.searchQuery.selectingDialCondId[index]
      );
      return dialCondItem === undefined ? null : dialCondItem;
    },

    /**
     * @description 透析条件プルダウンで選択されている項目の名称
     */
    selectingDialCondName(index) {
      const dialCondItem = this.selectingDialCondItem(index);
      return dialCondItem === null ? null : dialCondItem.name;
    },

    /**
     * @description 透析条件プルダウンで選択されている項目の条件設定形式
     */
    selectingDialCondType(index) {
      const dialCondItem = this.selectingDialCondItem(index);
      return dialCondItem === null ? null : dialCondItem.selectorType;
    },

    /**
     * @description 透析条件選択処理
     */
    listSelectDialCond(index) {
      this.isDialCondSelectorVisible = true;
      // ポップオーバー起点用に何番目の投薬指示を選択したか保持
      this.selectingDialCondIndex = index;
      this.dialCondSelectorData = this.createDialCondSelectorData(index);
    },
    /**
     * @description 透析条件リスト選択用データ作成
     */
    createDialCondSelectorData(index) {
      const title = this.selectingDialCondItem(index).name;
      let itemList;
      let class1 = null;
      const class2 = null;
      // 既に選択済みならデフォルト選択リストを設定
      const defaultSelection = _.isEmpty(
        this.searchQuery.dialysisConditionList[index]
      )
        ? []
        : this.searchQuery.selectingDialCondId[index] ===
          DIAL_COND_ID.ANTICOAGULANT
        ? this.searchQuery.dialysisConditionList[index].selectedItemList.map(
            (item) => ({
              cd: item.cd,
              cdType: item.cdType,
            })
          )
        : this.searchQuery.dialysisConditionList[index].selectedItemList.map(
            (item) => item.cd
          );

      // 透析条件の種類に応じてデータ作成
      switch (this.searchQuery.selectingDialCondId[index]) {
        case DIAL_COND_ID.VA: {
          itemList = createItemListData(
            this.mstVa,
            "vaCd",
            "vaName",
            "vaDirect"
          );
          class1 = createClassData(
            [
              { vaDirect: "0", direction: "両方" },
              { vaDirect: "1", direction: "左" },
              { vaDirect: "2", direction: "右" },
              { vaDirect: "3", direction: "なし" },
              { vaDirect: "-", direction: "不明" },
            ],
            "vaDirect",
            "direction",
            "VA方向"
          );
          break;
        }

        case DIAL_COND_ID.DIALYEZER: {
          itemList = createItemListData(
            this.mstDialyzer,
            "dialyzerCd",
            "modelNumber",
            "maker"
          );

          // マスタ内に存在するメーカ名からフィルタ用のメーカリストを作成
          const allMakerList = this.mstDialyzer
            .map((dialyzer) => {
              return {
                makerCd: dialyzer.maker,
                makerName: dialyzer.maker,
              };
            })
            .filter((maker) => maker.makerCd);
          // 重複排除
          const makerList = deduplicateObjectsGroup(
            allMakerList,
            "makerCd",
            "makerName"
          );

          class1 = createClassData(
            makerList,
            "makerCd",
            "makerName",
            "メーカ名"
          );
          break;
        }

        case DIAL_COND_ID.ADSORPTIONCOLUMN: {
          itemList = this.createDialCondEquipmentSelectorData([
            EQUIPMENT_TYPE.ADSORPTIONCOLUMN,
          ]);
          break;
        }

        case DIAL_COND_ID.FILM1:
        case DIAL_COND_ID.FILM2: {
          itemList = this.createDialCondEquipmentSelectorData([
            EQUIPMENT_TYPE.ADSORBER,
            EQUIPMENT_TYPE.SEPARATOR,
          ]);
          const filmClass = this.mstEquipmentClass.filter(
            (equipClass) =>
              equipClass.classType === EQUIPMENT_TYPE.ADSORBER ||
              equipClass.classType === EQUIPMENT_TYPE.SEPARATOR
          );
          class1 = createClassData(
            filmClass,
            "classCd",
            "className",
            "吸着器/分離器"
          );

          break;
        }

        case DIAL_COND_ID.NEEDLE_A:
        case DIAL_COND_ID.NEEDLE_V: {
          itemList = this.createDialCondEquipmentSelectorData([
            EQUIPMENT_TYPE.NEEDLE_NOT_SN,
          ]);
          break;
        }

        case DIAL_COND_ID.NEEDLE_SN: {
          itemList = this.createDialCondEquipmentSelectorData([
            EQUIPMENT_TYPE.NEEDLE_SN,
          ]);
          break;
        }

        case DIAL_COND_ID.BLOODCIRCUIT: {
          itemList = this.createDialCondEquipmentSelectorData([
            EQUIPMENT_TYPE.BLOODCIRCUIT,
          ]);
          break;
        }

        case DIAL_COND_ID.ANTICOAGULANT: {
          itemList = this.createDialCondMedicineSelectorData(
            MEDICINE_TYPE.ANTICOAGULANT
          );
          break;
        }

        case DIAL_COND_ID.DIALYSISFLUID: {
          itemList = this.createDialCondMedicineSelectorData(
            MEDICINE_TYPE.DIALYSISFLUID
          );
          break;
        }

        case DIAL_COND_ID.REPLENISHER: {
          itemList = this.createDialCondMedicineSelectorData(
            MEDICINE_TYPE.REPLENISHER
          );
          break;
        }
      }

      return { title, itemList, class1, class2, defaultSelection };
    },

    /**
     * @description 透析条件[抗凝固剤/透析液/補液]リスト選択用データ作成
     * @summary 薬剤の分類区分(分類コードではない)でマスタをフィルタリングする
     */
    createDialCondMedicineSelectorData(medicineType) {
      const filteredFunc = (mst) =>
        mst.filter((medicine) => {
          // 薬剤の分類コードから分類区分を特定
          const mstMediType = this.medicineClassTypePair[medicine.classCd];
          // 指定分類区分なら返す
          return mstMediType === medicineType;
        });
      const filteredMedicine = filteredFunc(this.mstMedicine);
      const medicineList = createItemListData(
        filteredMedicine,
        "medicineCd",
        "medicineName"
      );

      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
      //if (medicineType === MEDICINE_TYPE.ANTICOAGULANT) {
      if (medicineType == MEDICINE_TYPE.ANTICOAGULANT) {
      // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
        const filteredMedicineMix = filteredFunc(this.mstMedicineMix);
        const medicineMixList = createItemListData(
          filteredMedicineMix,
          "medicineMixCd",
          "medicineMixName",
          "",
          "",
          "2"
        );
        const itemList = [...medicineList, ...medicineMixList];
        return itemList;
      }
      return medicineList;
    },

    /**
     * @description 透析条件[吸着カラム/1次膜/2次膜]リスト選択用データ作成
     * @summary 医材の分類区分(分類コードではない)でマスタをフィルタリングする
     */
    createDialCondEquipmentSelectorData(equipmentTypes) {
      const filteredEquip = this.mstEquipment.filter((mst) => {
        // 医材の分類コードから分類区分を特定
        const mstEquipType = this.equipmentClassTypePair[mst.classCd];
        // 指定分類区分なら返す
        return equipmentTypes.includes(mstEquipType);
      });
      return createItemListData(
        filteredEquip,
        "equipmentCd",
        "equipmentName",
        "classCd"
      );
    },

    /**
     * @description 透析条件選択確定
     */
    commitDialCondListSelect(selectedList) {
      // 選択されたコードと名称を格納
      this.searchQuery.dialysisConditionList[
        this.selectingDialCondIndex
      ].selectedItemList = selectedList;
    },

    /**
     * @description 透析条件値範囲初期化
     */
    initRangeValue(index) {
      this.searchQuery.dialysisConditionList[index].value1String = "";
      this.searchQuery.dialysisConditionList[index].value2String = "";
      // 不等号を「≦」に
      this.searchQuery.dialysisConditionList[index].inequalitySign1 =
        INEQUALITY_SIGN.LESS_OR_EQUAL;
      this.searchQuery.dialysisConditionList[index].inequalitySign2 =
        INEQUALITY_SIGN.LESS_OR_EQUAL;
    },

    /**
     * @description 透析条件値一致初期化
     */
    initEqualValue(index) {
      this.searchQuery.dialysisConditionList[index].value1String = "";
      this.searchQuery.dialysisConditionList[index].value2String = "";
      // 不等号をクリア
      this.searchQuery.dialysisConditionList[index].inequalitySign1 = null;
      this.searchQuery.dialysisConditionList[index].inequalitySign2 = null;
    },

    /**
     * @description ラジオボタン選択形式の透析条件項目の定義を返す
     */
    dialCondRadio(radioNum, index) {
      return DIAL_COND_RADIO_DEFINITION[
        this.searchQuery.selectingDialCondId[index]
      ][radioNum];
    },

    /**
     * @description 投薬指示条件初期化
     */
    initMedication(index) {
      this.searchQuery.medicationList[index] = [];
    },

    /**
     * @description 医材指示条件初期化
     */
    initEquipment(index) {
      this.searchQuery.equipmentList[index] = [];
    },

    /**
     * @description 投薬指示選択処理
     */
    listSelectMedication(index) {
      this.isMedicationSelectorVisible = true;
      // ポップオーバー起点用に何番目の投薬指示を選択したか保持
      this.selectingMedicationIndex = index;
      this.medicationSelectorData = this.createMedicationSelectorData(index);
    },

    /**
     * @description 医材指示選択処理
     */
    listSelectEquipment(index) {
      this.isEquipmentSelectorVisible = true;
      // ポップオーバー起点用に何番目の投薬指示を選択したか保持
      this.selectingEquipmentIndex = index;
      this.equipmentSelectorData = this.createEquipmentSelectorData(index);
    },

    /**
     * @description 投薬指示選択用データ作成
     */
    createMedicationSelectorData(index) {
      // 選択した薬剤区分でマスタをフィルタリング
      const medicineClass = this.searchQuery.medicationSelectorClass[index];
      const filteredFunc = (mst) =>
        mst.filter((medicine) => {
          if (medicineClass === 0) {
            return medicine.classCd === -1;
          } else {
            return medicine.classCd === medicineClass;
          }
        });
      const filteredMedicine = filteredFunc(this.mstMedicine);
      const filteredMedicineMix = filteredFunc(this.mstMedicineMix);

      const medicineList = createItemListData(
        filteredMedicine,
        "medicineCd",
        "medicineName"
      );
      const medicineMixList = createItemListData(
        filteredMedicineMix,
        "medicineMixCd",
        "medicineMixName",
        "",
        "",
        "2"
      );
      const itemList = [...medicineList, ...medicineMixList];

      return {
        itemList,
        defaultSelection: this.searchQuery.medicationList[index].map(
          (item) => ({
            cd: item.cd,
            cdType: item.cdType,
          })
        ),
      };
    },

    /**
     * @description 医材指示選択用データ作成
     */
    createEquipmentSelectorData(index) {
      // 選択した医材区分でマスタをフィルタリング
      const equipmentClass = this.searchQuery.equipmentSelectorClass[index];
      const filteredEquipment = this.mstEquipment.filter((equipment) => {
        if (equipmentClass === 0) {
          return equipment.classCd === -1;
        } else {
          return equipment.classCd === equipmentClass;
        }
      });
      const itemList = createItemListData(
        filteredEquipment,
        "equipmentCd",
        "equipmentName"
      );
      return {
        itemList,
        defaultSelection: this.searchQuery.equipmentList[index].map(
          (item) => item.cd
        ),
      };
    },

    /**
     * @description 投薬指示選択確定
     */
    commitMedication(selectedList) {
      this.searchQuery.medicationList[this.selectingMedicationIndex] =
        selectedList;
    },

    /**
     * @description 医材指示選択確定
     */
    commitEquipment(selectedList) {
      this.searchQuery.equipmentList[this.selectingEquipmentIndex] =
        selectedList;
    },

    /**
     * @description リスト選択項目名称一覧
     */
    selectedListNames(selectedList) {
      return selectedList.map((item) => item.name).join(",");
    },

    /**
     * @description リスト選択表示起点
     */
    selectorTarget(refName, index) {
      return index === null ? null : this.$refs[`${refName}${index}`][0];
    },

    /**
     * @description クエリ選択
     */
    selectQuery() {
      let queryId, queryName, query;
      if (this.selectingQueryIndex === null) {
        // 未指定
        queryId = null;
        queryName = "";
        query = new SearchQuery();
      } else {
        queryId = this.patSearchDetails[this.selectingQueryIndex].queryId;
        queryName = this.patSearchDetails[this.selectingQueryIndex].queryName;
        query = new SearchQuery(
          this.patSearchDetails[this.selectingQueryIndex].query
        );
      }
      this.selectingQuery = { queryId, queryName, query };
    },

    /**
     * @description 既存クエリ更新
     */
    updateQuery() {
      const queryObj = {
        queryId: this.selectingQuery.queryId,
        queryName: this.selectingQuery.queryName,
        query: new SearchQuery(this.searchQuery),
      };
      // TODO: クエリ更新API実装待ち
      ApiHelper.put("/pat_search_detail/", {
        searchCd: queryObj.queryId,
        searchName: queryObj.queryName,
        searchCondition: JSON.stringify(queryObj.query),
      }).then((response) => {
        const data = Number(response.data);
        if (data === 1) {
          // サイドバーが保持しているクエリも同じ内容で更新
          this.updatePatSearchDetail(queryObj);
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "更新しました。"
            title: DIALOG_MESSAGES['00100017'].title,
            message: messageFormat(DIALOG_MESSAGES['00100017'].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
      });
    },

    /**
     * @description 既存クエリ削除
     */
    deleteQuery() {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "削除確認",
        title: DIALOG_MESSAGES[13000006].title,
        // message: "削除すると二度と元に戻せません。削除してもよろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000006].message),
         // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        buttonLabel: ["キャンセル", "OK"],
        callback: async (ok) => {
          if (ok === 1) {
            ApiHelper.put(
              "/pat_search_detail/" + this.selectingQuery.queryId
            ).then((response) => {
              const data = Number(response.data);
              if (data === 1) {
                this.deletePatSearchDetail(this.selectingQuery.queryId);
                this.selectingQueryIndex = null;
                this.selectQuery();
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "削除完了",
                  // message: "削除しました。"
                  title: DIALOG_MESSAGES['00100018'].title,
                  message: messageFormat(DIALOG_MESSAGES['00100018'].message)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              }
            });
          }
        },
      });
    },

    /**
     * @description 新規クエリ追加
     */
    addQuery() {
      const queryObj = {
        queryId: null,
        queryName: this.queryName,
        query: new SearchQuery(this.searchQuery),
      };
      // TODO: クエリ保存API実装待ち
      ApiHelper.post("/pat_search_detail", {
        searchName: queryObj.queryName,
        searchCondition: JSON.stringify(queryObj.query),
      })
        .then((response) => {
          const newQueryId = Number(response.data);
          if (newQueryId > 0) {
            queryObj.queryId = newQueryId;
            this.addPatSearchDetail(queryObj);
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "追加完了",
              // message: "追加しました。"
              title: DIALOG_MESSAGES['00100019'].title,
              message: messageFormat(DIALOG_MESSAGES['00100019'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          } else {
            this.messageDialogInfo.messageCd = "00700018";
            this.messageDialogInfo.type = "1";
            this.messageDialogInfo.isDialogVisible = true;
          }
        })
        .catch(() => {
          getErrorMessage(
            "DetailedSearch2.vue",
            "addQuery",
            "クエリ保存API実装待ち"
          );
          throw new Error("クエリ保存API実装待ち");
        });
    },

    /**
     * @description コンポーネントを再利用させないためのkey属性値(現在日時+文字列)
     * @summary コンポーネントの再利用によって選択項目やフィルタに設定した値が残ったままになるのを防ぐ
     * @param {String} str 任意の文字列 ※コンポーネントごとに変えること
     * @returns {String} YYYYMMDDHHmmssSSS
     */
    componentKey(str) {
      return `${moment().format("YYYYMMDDHHmmssSSS")}${str}`;
    },

    /**
     * @description スタッフ選択ポップオーバー表示
     */
    async showPopoverStaff(staffClass) {
      // if (staffClass === "Doctor") {
      //   this.popoverDataStaff.popoverContentSelected.value =
      //     this.searchQuery.staffCdDoctor;
      // } else if (staffClass === "Charge") {
      //   this.popoverDataStaff.popoverContentSelected.value =
      //     this.searchQuery.staffCdCharge;
      // } else {
      //   this.popoverDataStaff.popoverContentSelected.value =
      //     this.searchQuery.staffCdPucture;
      // }

      //#11872 liyanze-z add flag is used userID  
      let isUsedUserInfoID = false;
      if (staffClass === "Doctor") {
        this.popoverDataStaff.popoverContentSelected.value =
          this.searchQuery.staffCdDoctor ? this.searchQuery.staffCdDoctor : this.getStateUserAccountInfo.userId;
          //liyanze-z add flag
          if(!this.searchQuery.staffCdDoctor) isUsedUserInfoID = true;
      } else if (staffClass === "Charge") {
        this.popoverDataStaff.popoverContentSelected.value =
          this.searchQuery.staffCdCharge ? this.searchQuery.staffCdCharge : this.getStateUserAccountInfo.userId;
          //liyanze-z add flag
          if(!this.searchQuery.staffCdCharge) isUsedUserInfoID = true;
      } else {
        this.popoverDataStaff.popoverContentSelected.value =
          this.searchQuery.staffCdPucture ? this.searchQuery.staffCdPucture : this.getStateUserAccountInfo.userId;
          //liyanze-z add flag
          if(!this.searchQuery.staffCdPucture) isUsedUserInfoID = true;
      }

      // mod 11872 利用者指定IFのデフォルト選択状態 liyanze-z add  ログインID  start 
      this.popoverDataStaff.isUsedUserInfoID = isUsedUserInfoID;
      // mod 11872 利用者指定IFのデフォルト選択状態 liyanze-z add  ログインID  end 

      this.showingPopoverStaffClass = staffClass;
      this.showPopover(this.popoverDataStaff);
    },

    /**
     * @description 禁忌・アレルギー選択ポップオーバー表示
     */
    showPopoverTabooAllergy(tabooAllergyString) {
      if (tabooAllergyString === "Taboo") {
        this.popoverDataTabooAllergy.popoverContentSelected.value =
          this.searchQuery.tabooCd;
      } else {
        this.popoverDataTabooAllergy.popoverContentSelected.value =
          this.searchQuery.allergyCd;
      }
      this.showingPopoverTabooAllergy = tabooAllergyString;
      this.showPopover(this.popoverDataTabooAllergy);
    },
    /**
     * @description 診療科選択ポップオーバー表示
     */
    showPopoverCourse(courseString) {
      if (courseString === "Course") {
        this.popoverDataCourse.popoverContentSelected.value =
          this.searchQuery.courseCd;
      }
      this.showingPopoverCourse = courseString;
      this.showPopover(this.popoverDataCourse);
    },
    /**
     * @description 透析実施科選択ポップオーバー表示
     */
    showPopoverDialCourse(DialysisCourseString) {
      if (DialysisCourseString === "DialCourse") {
        this.popoverDataDialysisCourse.popoverContentSelected.value =
          this.searchQuery.dialCourseCd;
      }
      this.showingPopoverDialysisCourse = DialysisCourseString;
      this.showPopover(this.popoverDataDialysisCourse);
    },
    /**
     * @description 病棟選択ポップオーバー表示
     */
    showPopoverWard(WardString) {
      if (WardString === "Ward") {
        this.popoverDataWard.popoverContentSelected.value =
          this.searchQuery.wardCd;
      }
      this.showingPopoverWard = WardString;
      this.showPopover(this.popoverDataWard);
    },
    showPopoverPrimaryDisease() {
      this.popoverDataPrimaryDisease.popoverContentSelected.value =
        this.searchQuery.primary_disease_cd;
      showPopover(this.popoverDataPrimaryDisease);
    },
    showPopoverDisease() {
      this.popoverDataDisease.popoverContentSelected.value =
        this.searchQuery.diseaseCd;
      showPopover(this.popoverDataDisease);
    },
    showPopoverTabooSeverity() {
      this.popoverDataTabooSeverity.popoverContentSelected.value =
        this.searchQuery.severityCd;
      this.showPopover(this.popoverDataTabooSeverity);
    },
    showPopoverTabooTransport() {
      this.popoverDataTabooTransport.popoverContentSelected.value =
        this.searchQuery.transportCd;
      this.showPopover(this.popoverDataTabooTransport);
    },
    /**
     * @description 続柄選択ポップオーバー表示
     */
    showPopoverRelationship() {
      this.popoverDataRelationship.popoverContentSelected.value =
        this.searchQuery.relationCd;
      this.showPopover(this.popoverDataRelationship);
    },
    /**
     * @description スタッフ条件セット
     * @params {Number} cd ユーザマスタコード
     * @params {String} name ユーザマスタ名称
     */
    setStaff(cd, name) {
      if (this.showingPopoverStaffClass === "Doctor") {
        // 主治医で選択された場合
        this.searchQuery.staffCdDoctor = cd;
        this.searchQuery.staffNameDoctor = name;
      } else if (this.showingPopoverStaffClass === "Charge") {
        // 担当で選択された場合
        this.searchQuery.staffCdCharge = cd;
        this.searchQuery.staffNameCharge = name;
      } else {
        // 穿刺で選択された場合
        this.searchQuery.staffCdPucture = cd;
        this.searchQuery.staffNamePuncture = name;
      }
    },
    showPopoverAddition() {
      this.popoverDataAddition.popoverContentSelected.value =
        this.searchQuery.additionCd;
      this.showPopover(this.popoverDataAddition);
    },

    /**
     * @description 禁忌・アレルギー条件セット
     * @summary 禁忌・アレルギー選択ポップオーバーで指定されたコードと名称をどちらか一方にセットする
     * @params {Number} cd 禁忌・アレルギーマスタコード
     * @params {String} name 禁忌・アレルギーマスタ名称
     */
    setTabooAllergy(cd, name) {
      if (this.showingPopoverTabooAllergy === "Taboo") {
        // 禁忌で選択された場合
        this.searchQuery.tabooCd = cd;
        this.searchQuery.tabooContent = name;
      } else {
        // アレルギーで選択された場合
        this.searchQuery.allergyCd = cd;
        this.searchQuery.allergyContent = name;
      }
    },
    setCourse(cd, name) {
      if (this.showingPopoverCourse === "Course") {
        // 診療科禁忌で選択された場合
        this.searchQuery.mainCourseCd = cd;
        this.searchQuery.courseName = name;
      }
    },
    setDialysisCourse(cd, name) {
      if (this.showingPopoverDialysisCourse === "DialCourse") {
        // 透析実施科で選択された場合
        this.searchQuery.dialysisCourseCd = cd;
        this.searchQuery.dialCourseName = name;
      }
    },
    setWard(cd, name) {
      if (this.showingPopoverWard === "Ward") {
        // 病棟で選択された場合
        this.searchQuery.wardCd = cd;
        this.searchQuery.wardName = name;
      }
    },
    setTabooSeverity(cd, name) {
      this.searchQuery.severityCd = cd;
      this.searchQuery.severityName = name;
    },
    setTabooTransport(cd, name) {
      this.searchQuery.transportCd = cd;
      this.searchQuery.transportName = name;
    },
    setAddition(cd, name) {
      this.searchQuery.additionCd = cd;
      this.searchQuery.additionName = name;
    },

    /**
     * @description 病名条件セット
     * @params {Number} cd 病名マスタコード
     * @params {String} name 病名マスタ名称
     */
    setDisease(cd, name) {
      this.searchQuery.diseaseCd = cd;
      this.searchQuery.diseaseName = name;
    },
    setPrimaryDisease(cd, name) {
      this.searchQuery.primary_disease_cd = cd;
      this.searchQuery.primary_disease_name = name;
    },
    setRelationship(cd, name) {
      this.searchQuery.relationCd = cd;
      this.searchQuery.relationName = name;
    },
    /**
     * @description 患者追加検索
     */
    async additionalSearchPat() {
      this.logEventFun();
      const conditions = this.searchQuery.createCondition([this.facilityCd]);
      this.search(conditions, false, false).catch((error) => {
        getErrorMessage("DetailedSearch2.vue", "additionalSearchPat", error);
        throw error;
      });
    },

    /**
     * @description 患者検索
     */
    async searchPatPatGroup() {
      this.logEventFun();
      // add #9578 start
      this.updateUnSelectedPatList([]);
      // add #9578 end
      const conditions = this.searchQuery.createCondition([this.facilityCd]);

      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
      // this.search(conditions, true, true).catch((error) => {
      await this.search(conditions, true, true).catch((error) => {
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
        getErrorMessage("DetailedSearch2.vue", "searchPat", error);
        throw error;
      });
      // delete start 馬 #9578
      // EventBus.$emit("patlistsort");
      // delete end 馬 #9578
    },

    /**
     * @description 全患者検索
     */
    async searchAllPat() {
      const conditions = new SearchQuery().createCondition([this.facilityCd]);
      //add 10389 患者グループ預かりBUG gjn start
      this.search(conditions, true, true).catch((error) => {
        //add 10389 患者グループ預かりBUG gjn end
        getErrorMessage("DetailedSearch2.vue", "searchAllPat", error);
        throw error;
      });
    },

    /**
     * @description 追加検索実行
     */
    async search(conditions, isClearSearchPatList, isHideModal) {
      this.startLoadingScreen("患者検索中");
      this.isSearching = true;
      //add 10389 患者グループ既存BUG gjn start
      if (isClearSearchPatList) {
        // 患者一覧クリア
        this.clearSearchedPatListGroup();
      }
      //add 10389 患者グループ既存BUG gjn end
      // 詳細検索API実行
      const uri = "/patInfo/getDetailedSearchResult";
      const response = await ApiHelper.post(uri, conditions).catch(() => {
        getErrorMessage(
          "DetailedSearch2.vue",
          "search",
          "[DetailedSearch2.vue]search(): 検索失敗"
        );
        this.isSearching = false;
        throw new Error("[DetailedSearch2.vue]search(): 検索失敗");
      });
      const searchedPatList = response.data;
      if (searchedPatList.length === 0) {
        // 検索結果0件
        this.isSearching = false;
        // 検索モーダルを閉じる
        this.hideModal();
        this.finishLoadingScreen();
        return;
      }
      // modify #9578 start
      this.setPatGroupEditAddSearchedPatInfo(searchedPatList);
      if (this.getPatGroupEditSortCondition?.length) {
        if (null !== this.getPatGroupEditSortCondition[0].key) {
          await this.sortPatList(this.getPatGroupEditSortCondition);
        }
      }

      // 患者リストに追加
      this.finishLoadingScreen();
      this.addSearchedPatListPatGroup(this.getPatGroupEditAddSearchedPatInfo);
      this.setPatGroupEditAddSearchedPatInfo([]);
      // modify #9578 end

      this.isSearching = false;

      if (isHideModal) {
        // 検索モーダルを閉じる
        this.hideModal();
      }
    },

    /**
     * @description 患者一覧クリア
     */
    async clearPatList() {
      this.clearSearchedPatListGroup();
    },

    /**
     * @description 検索条件初期化
     */
    clearConditon() {
      // クエリ初期化
      this.searchQuery.dialysisStartDate = moment().format("YYYY-MM-DD");
      this.searchQuery.dialysisEndDate = moment().format("YYYY-MM-DD");
      this.searchQuery.exam_pattern_start_date = moment().format("YYYY-MM-DD");
      this.searchQuery.exam_pattern_end_date = moment().format("YYYY-MM-DD");
      this.searchQuery.radPattern_exam_pattern_start_date =
        moment().format("YYYY-MM-DD");
      this.searchQuery.radPattern_exam_pattern_end_date =
        moment().format("YYYY-MM-DD");
      this.searchQuery.eventStartDate = moment().format("YYYY-MM-DD");
      this.searchQuery.eventEndDate = moment().format("YYYY-MM-DD");
      this.$nextTick(() => {
        this.selectingQuery.query = new SearchQuery();
      });
      // 曜日セレクタ初期化
      this.indWeeks.forEach((item) => {
        item.done = false;
      });
    },

    /**
     * @description 画面を閉じる
     */
    closeModal() {
      this.isSearching = false;
      this.hideModal();
    },
    changeValueForExemWeek(week, value, arg) {
      let isDoneAll = true;
      let params = [];
      if (arg == "radPattern_exam_week") {
        params = this.searchQuery.radPattern_exam_week;
      }
      if (arg == "exam_week") {
        params = this.searchQuery.exam_week;
      }
      week.done = value;
      // [全]が押されたら動作
      if (week.value === 0) {
        // 全ての曜日を格納するために空にする
        if (week.done) {
          params = [];
        }
        // 全ての曜日を[全]と同じにBoolean値へ
        this.indWeeks.forEach((item) => {
          if (item.value !== 0) {
            item.done = week.done;
          }
          // 全ての曜日を格納
          if (week.done) {
            params.push(item.value);
          } else if (!week.done && params.includes(item.value)) {
            // 全ての曜日を配列から削除
            params = _.without(params, item.value);
          }
        });
      } else {
        this.indWeeks.forEach((item) => {
          if (item.value !== 0 && !item.done) {
            isDoneAll = false;
          }
        });
        this.indWeeks[0].done = isDoneAll;
        if (this.indWeeks[0].done) {
          params.push(this.indWeeks[0].value);
        } else {
          params = _.without(params, this.indWeeks[0].value);
        }
      }
      if (arg == "radPattern_exam_week") {
        this.searchQuery.radPattern_exam_week = params;
      }
      if (arg == "exam_week") {
        this.searchQuery.exam_week = params;
      }
    },
    changeValue(week, value) {
      let isDoneAll = true;

      week.done = value;
      // [全]が押されたら動作
      if (week.value === 0) {
        // 全ての曜日を格納するために空にする
        if (week.done) {
          this.searchQuery.treatDayOfWeekList = [];
        }
        // 全ての曜日を[全]と同じにBoolean値へ
        this.indWeeks.forEach((item) => {
          if (item.value !== 0) {
            item.done = week.done;
          }
          // 全ての曜日を格納
          if (week.done) {
            this.searchQuery.treatDayOfWeekList.push(item.value);
          } else if (
            !week.done &&
            this.searchQuery.treatDayOfWeekList.includes(item.value)
          ) {
            // 全ての曜日を配列から削除
            this.searchQuery.treatDayOfWeekList = _.without(
              this.searchQuery.treatDayOfWeekList,
              item.value
            );
          }
        });
      } else {
        this.indWeeks.forEach((item) => {
          if (item.value !== 0 && !item.done) {
            isDoneAll = false;
          }
        });
        this.indWeeks[0].done = isDoneAll;
        if (this.indWeeks[0].done) {
          this.searchQuery.treatDayOfWeekList.push(this.indWeeks[0].value);
        } else {
          this.searchQuery.treatDayOfWeekList = _.without(
            this.searchQuery.treatDayOfWeekList,
            this.indWeeks[0].value
          );
        }
      }
    },
    /**
     * @description スクロール時にマルチセレクトを閉じる
     */
    setClosePopup() {
      // TODO: 一時的に保留:スクロール毎に動作しているがpopupが閉じたら関数を終了させるか検討
      $$(".search-data").scroll(() => {
        $$(document).find("[data-role=popup]").kendoPopup("close");
      });
    },

    /**
     * @description 各エリアの高さを再設定する
     */
    setAreaHeight() {
      const body = document.getElementById(
        "visible-area-detailed-search"
      ).parentElement;
      const footer = document.getElementById("button-area-detailed-search")
        .parentElement.parentElement;
      body.style.height = `calc(100% - ${footer.offsetHeight}px - 50px)`;
    },
    setContentData(newValue, index) {
      this.searchQuery.indCommentList[index] = newValue;
    },
    showDialysisStartDateMsg(msg) {
      if (msg == 0) {
        this.showDialysisStartDate =
          document.getElementsByClassName("dialysisStartDate")[0]
            .validationMessage !== "";
      }
      if (msg == 1) {
        this.showExamPatternStartDate =
          document.getElementsByClassName("exam_pattern_start_date")[0]
            .validationMessage !== "";
      }
      if (msg == 2) {
        this.radPatternExamPatternStartDate =
          document.getElementsByClassName(
            "radPattern_exam_pattern_start_date"
          )[0].validationMessage !== "";
      }
      if (msg == 3) {
        this.showeventStartDate =
          document.getElementsByClassName("eventStartDate")[0]
            .validationMessage !== "";
      }
    },

    getDialysisStartDateMsg(msg) {
      if (msg == 0) {
        this.showDialysisStartDate =
          document.getElementsByClassName("dialysisStartDate")[0]
            .validationMessage !== "";
      }
      if (msg == 1) {
        this.showExamPatternStartDate =
          document.getElementsByClassName("exam_pattern_start_date")[0]
            .validationMessage !== "";
      }
      if (msg == 2) {
        this.radPatternExamPatternStartDate =
          document.getElementsByClassName(
            "radPattern_exam_pattern_start_date"
          )[0].validationMessage !== "";
      }
      if (msg == 3) {
        this.showeventStartDate =
          document.getElementsByClassName("eventStartDate")[0]
            .validationMessage !== "";
      }
    },

    showDialysisEndDateMsg(msg) {
      if (msg == 0) {
        this.showDialysisEndDate =
          document.getElementsByClassName("dialysisEndDate")[0]
            .validationMessage !== "";
      }
      if (msg == 1) {
        this.showExamPatternEndDate =
          document.getElementsByClassName("exam_pattern_end_date")[0]
            .validationMessage !== "";
      }
      if (msg == 2) {
        this.radPatternExamPatternEndDate =
          document.getElementsByClassName("radPattern_exam_pattern_end_date")[0]
            .validationMessage !== "";
      }
      if (msg == 3) {
        this.showeventEndDate =
          document.getElementsByClassName("eventEndDate")[0]
            .validationMessage !== "";
      }
    },

    getDialysisEndDateMsg(msg) {
      if (msg == 0) {
        this.showDialysisEndDate =
          document.getElementsByClassName("dialysisEndDate")[0]
            .validationMessage !== "";
      }
      if (msg == 1) {
        this.showExamPatternEndDate =
          document.getElementsByClassName("exam_pattern_end_date")[0]
            .validationMessage !== "";
      }
      if (msg == 2) {
        this.radPatternExamPatternEndDate =
          document.getElementsByClassName("radPattern_exam_pattern_end_date")[0]
            .validationMessage !== "";
      }
      if (msg == 3) {
        this.showeventEndDate =
          document.getElementsByClassName("eventEndDate")[0]
            .validationMessage !== "";
      }
    },
    logEventFun() {
      var conditionMessage = "";

      var elements = document
        .getElementById("visible-area-detailed-search")
        .getElementsByTagName("*");
      var elementIdx;
      for (elementIdx in elements) {
        var item = elements[elementIdx];
        if (item && item.style && item.style.display === "none") {
          continue;
        }
        switch (item.tagName) {
          case "ONS-INPUT":
            if (item && item.value != "") {
              conditionMessage += item.value + "、";
            }
            break;
          case "SELECT":
            var selectValue = "";
            for (var sIdx = 0; sIdx < item.options.length; sIdx++) {
              if (item.options[sIdx].selected) {
                selectValue += "" + item.options[sIdx].text;
              }
            }
            if (selectValue != "") conditionMessage += selectValue + "、";
            break;
          case "LABEL":
            var forValue = item.getAttribute("for");
            if (forValue) {
              var checkValue = document.getElementById(forValue);
              if (checkValue && checkValue.checked) {
                conditionMessage += item.innerText + "、";
              }
            }
            if (
              item.parentNode.lastChild.innerText == "選択" &&
              null != item.textContent &&
              "" != item.textContent
            ) {
              conditionMessage += item.textContent + "、";
            }
            break;
          case "LI":
            if (null != item.innerText && "" != item.innerText) {
              conditionMessage += item.innerText + "、";
            }
            break;
          case "ONS-RADIO":
            var rObj = item.getElementsByTagName("input")[0];
            var parentObj = item.parentNode;
            if (rObj && rObj.checked && parentObj) {
              conditionMessage += parentObj.innerText + "、";
            }
            break;
          case "ONS-CHECKBOX":
            if (item.type === "checkbox" && item.checked) {
              var checkVal = item.nextSibling.nodeValue;
              checkVal = checkVal.replace(/\s+/g, "");
              conditionMessage += checkVal + "、";
            }
            break;
          case "INPUT":
            if (item.type === "checkbox" && item.checked) {
              var rowObj = item.closest("ONS-ROW");
              if (rowObj) {
                var colRow = rowObj.getElementsByTagName("ons-col")[0];
                var labelObj = colRow.getElementsByTagName("label")[0];
                if (labelObj) {
                  conditionMessage += labelObj.innerText + "、";
                }
              }
              break;
            }
            if (item.type == "time") {
              if (null != item.value && "" != item.value) {
                conditionMessage += item.value + "、";
              }
            }
            if (item.type != "text" && item.type != "date") {
              break;
            }
            if (item.parentNode.tagName != "ONS-INPUT") {
              if (item.value != "") conditionMessage += item.value + "、";
            }
            break;
          default:
            break;
        }
      }
      if (conditionMessage != "") {
        if (conditionMessage.charAt(conditionMessage.length - 1) === "、") {
          conditionMessage = conditionMessage.substr(
            0,
            conditionMessage.length - 1
          );
        }

        var msg = "患者検索が[" + conditionMessage + "]で検索しました。";
        let paramObj = { message: msg, functionName: "患者検索" };
        ApiHelper.put("/logs/event/conditionlog", paramObj).catch((error) => {
          getErrorMessage("DetailedSearch2.vue", "logEventFun", error);
        });
      }
    },
  },
};
</script>

<style scoped>
.search-data {
  height: 600px;
}

.item-area {
  width: 30%;
}

.search-pat-info-area,
.search-treat-area,
.search-check-area,
.button-area {
  margin: 4px;
}

.button-area >>> .button {
  width: fit-content;
}

.search-button {
  height: 35px;
}

.out-come-area,
.blood-serovar-area {
  display: flex;
  flex-wrap: wrap;
}
.out-come-area label,
.blood-serovar-area label {
  margin-right: 4px;
}
.search-area {
  font-size: 1em;
}

.query-area {
  border-bottom: 1px solid;
}

.footer-area {
  border-top: 1px solid;
}
.visible-area {
  vertical-align: middle;
  text-align: center;
}

.search-area {
  position: relative;
  display: inline-block;
  text-align: left;
  white-space: initial;
  width: 100%;
}

.search-area >>> .select-input {
  font-size: 1em;
  line-height: 1em;
}

.search-area table {
  width: calc(100% - 4px);
}

.search-area tr th {
  text-align: left;
  font-weight: unset;
}

.searching-toast {
  text-align: center;
}

.button-area {
  display: flex;
  justify-content: space-between;
  padding: 10px 10px 5px 10px;
}

.week-button {
  padding: 5px 10px;
  float: left;
  border: solid;
  border-color: #c0c0c0;
  border-width: 1px;
}

/* その他 */
.search-title,
.query-area,
.detailed-search-data,
.search-data,
.detailede-search-title,
.search-pat-info-area,
.pat-info-title,
.search-pat-info-title,
.search-treat-area,
.search-check-area,
.treat-area-title,
.check-area-title,
.search-treat-title,
.search-check-title,
.footer-area {
  display: block;
}

input[type="text"] {
  display: inline-block;
  box-sizing: border-box;
}

label {
  user-select: none;
}

.search-title {
  border-bottom: none;
}

.search-pat-info-area,
.search-check-area,
.search-treat-area {
  border: 1px solid;
}
.week-checkbox:checked + label {
  background-color: #9acd32;
  color: #050505;
}
.age-input {
  vertical-align: middle;
  /*mod #11047 数値IF修正【最優先】 張玲 start*/
  /* width: 50px; */
  width: 5em;
  /*mod #11047 数値IF修正【最優先】 張玲 end*/
}
/*add #11047 数値IF修正【最優先】 張玲 start*/
.age-input-blur >>> input{
  border: 2px solid !important;
  border-style: inset !important;
}
/*add #11047 数値IF修正【最優先】 張玲 end*/
.pat-groups .method {
  height: 2em;
  display: flex;
  justify-content: flex-end;
  align-items: flex-end;
  padding-top: 5px;
}
.pat-groups .method label:first-child {
  margin-right: 1em;
}
.ntss-vertical-top {
  vertical-align: top;
}
.ntss-separate-dosing {
  width: 218px;
  margin-right: 1em;
}

.ntss-separate-medical {
  width: 218px;
  margin-right: 1em;
}

.custom-area-style {
  width: 100%;
  box-sizing: border-box;
}

.separate-item-header {
  margin: 0 0 5px 5px;
}

.width-button-header {
  width: 95px;
}
div >>> .modal-header .toolbar {
  background-color: var(--ntss-header-background-color);
}

div >>> .modal-header .toolbar__title.toolbar__left {
  color: var(--ntss-header-color) !important;
}

div >>> .modal-search,
div >>> .modal-body,
div >>> .modal-footer,
div >>> .modal-footer .bottom-bar {
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
.treatment-select >>> .k-multiselect-wrap {
  max-height: 78px;
  overflow-y: auto;
}
@media screen and (max-width: 750px) {
  .button-area {
    display: block;
    padding: 0;
    overflow-x: auto;
  }
}

.custom-ntss-input-date {
  font-size: inherit;
}

.custom-treatment-select >>> .k-widget,
.custom-treatment-select >>> .k-button,
.custom-input-time input,
.custom-pat-groups >>> .k-widget,
.custom-pat-groups >>> .k-button {
  font-size: unset;
}

.custom-com-textarea >>> textarea {
  font-size: inherit;
  font-family: inherit;
}
.LeftTd {
  width: 300px;
}

.RightTd {
  width: 600px;
}
.patgroups-multiselect {
  width: 12.3rem;
}
.rad-date-input {
  width: 5rem;
}
.rp-input >>> input {
  background-color: #ddd;
}

.disabled-input >>> .text-input:disabled {
  opacity: 1;
}
.input {
  vertical-align: middle;
  background-color: white;
}
.input >>> .text-input {
  width: 19em;
  height: 2em;
  line-height: 2em;
}
.input >>> .text-input:disabled {
  opacity: 1;
}
.leftbtn {
  margin-left: 5px;
}
.labelRMargin {
  margin-right: 0.7em;
  white-space: nowrap;
  display: flex;
  align-items: center;
  flex-wrap: nowrap;
  min-height: 28px;
  height: 1.7em;
}
.checkBoxMargin {
  margin-right: 0px;
}
.widthClass {
  min-width: 90px !important;
}
.fontMagin {
  margin: 5px !important;
}
.patient_box {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
.class_td {
  display: flex;
  align-items: center;
}
.agreement_box {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
}
.td_box {
  display: flex;
}
.td_left {
  width: 20%;
}
.td_right {
  width: 80%;
}
.td_right1 {
  width: 65%;
}
.flex_class {
  display: flex;
  flex-wrap: wrap;
}
.my-input {
  width: 19em !important;
}
::v-deep .text-input:disabled {
  width: 19em !important;
}
</style>
