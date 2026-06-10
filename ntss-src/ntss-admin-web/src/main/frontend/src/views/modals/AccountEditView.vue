/**
 * アカウント編集Page
 */
<template>
  <modal-base @onClose="cancel">
    <div slot="body" class="account-edit" v-bind:class="[this.isAndroid || this.isIOS ? 'scroll-adjust' : '']">
      <div class="account-edit-input">
        <div style="text-align:left;">
          <p class="required">*必須</p>
        </div>
        <div class="panel">
          <table class="table-userInfo">
            <tbody account-edit-tbody>
              <tr>
                <td class="title">
                  <!-- FNSI-修正 4497 対応 xiebzh add start -->
                  <!--<label>ユーザーID*：</label>-->
                  <label>ユーザーID*:</label>
                  <!-- FNSI-修正 4497 対応 xiebzh add end -->
                </td>
                <td valign="bottom" colspan="10">
                  <div class="flex-container">
                    <div class="userId">
                      <v-ons-input
                        input-id="dispUserId"
                        type="text"
                        float
                        v-model="inputModel.dispUserId"
                        v-on:blur="validate('dispUserId')"
                      />
                    </div>
                    <div>
                      <v-ons-button
                        class="button registration-btn button-select"
                        @click="createCard"
                        :disabled="isChanged"
                        v-show="isCardDeviceConnected"
                      >カード作成</v-ons-button>
                    </div>
                  </div>
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="checkDispUserId.isDuplication || checkDispUserId.isNull || checkDispUserId.isInvalid || checkDispUserId.isOver"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p v-if="checkDispUserId.isNull">ユーザーIDは入力必須項目です。</p>
                  <p
                    v-if="!checkDispUserId.isNull && checkDispUserId.isOver"
                  >ユーザーIDは12文字以内で入力してください。</p>
                  <p
                    v-if="!checkDispUserId.isNull && checkDispUserId.isInvalid"
                  >ユーザーIDの入力形式に誤りがあります。</p>
                  <p
                    v-if="!checkDispUserId.isNull && !checkDispUserId.isOver && !checkDispUserId.isInvalid && checkDispUserId.isDuplication"
                  >
                    既にそのIDは使われています。
                    <br />別のIDを入力してください。
                  </p>
                </td>
              </tr>
              <tr>
                <td>
                  現在の
                  <!-- FNSI-修正 4497 対応 xiebzh add start -->
                  <!--<br />パスワード：-->
                  <br />パスワード:
                  <!-- FNSI-修正 4497 対応 xiebzh add end -->
                </td>
                <td valign="bottom" colspan="10">
                  <div class="password-wrapper">
                    <v-ons-input
                      type="password"
                      v-model="inputModel.userPasswordCurrent"
                      @blur="checkMatchCurrentPassword"
                      model-event="change"
                      input-id="current-password"
                      data-vv-as="現在のパスワード"
                      name="current-password"
                    />
                    <v-ons-icon icon="fa-eye" size="18px" class="password-eyeicon" @click="clickEyeIcon($event)"/>
                  </div>
                  <p
                    v-show="inputModel.userPasswordCurrent && !isCorrectCurrentPassword"
                    class="error-message"
                  >現在のパスワードが一致しません。</p>
                </td>
              </tr>
              <tr>
                <td>
                  <!-- FNSI-修正 4497 対応 xiebzh add start -->
                  <!--<label>パスワード：</label>-->
                  <label>パスワード:</label>
                  <!-- FNSI-修正 4497 対応 xiebzh add end -->
                </td>
                <td valign="bottom" colspan="10">
                  <div class="password-wrapper">
                    <v-ons-input
                      type="password"
                      float
                      v-model="inputModel.userPassword"
                      model-event="change"
                      input-id="password"
                      name="password"
                      ref="password"
                      autocomplete="new-password"
                    />
                    <v-ons-icon icon="fa-eye" size="18px" class="password-eyeicon" @click="clickEyeIcon($event)"/>
                  </div>
                  <p
                    v-show="errors.has('password')"
                    class="error-message"
                  >{{ errors.first('password') }}</p>
                </td>
              </tr>
              <tr>
                <td>
                  (確認)
                  <!-- FNSI-修正 4497 対応 xiebzh add start -->
                  <!--<br />パスワード：-->
                  <br />パスワード:
                  <!-- FNSI-修正 4497 対応 xiebzh add end -->
                </td>
                <td valign="bottom" colspan="10">
                  <div class="password-wrapper">
                    <v-ons-input
                      type="password"
                      v-model="inputModel.userPasswordConfirm"
                      model-event="change"
                      input-id="confirm-password"
                      data-vv-as="確認パスワード"
                      name="confirm-password"
                      v-validate="!inputModel.userPassword ? '' : 'required|confirmed:password'"
                    />
                    <v-ons-icon icon="fa-eye" size="18px" class="password-eyeicon" @click="clickEyeIcon($event)"/>
                  </div>
                  <p
                    v-show="errors.has('confirm-password')"
                    class="error-message"
                  >{{ errors.first('confirm-password') }}</p>
                </td>
              </tr>
              <tr v-if="!remsOnly">
                <td>氏名ﾌﾘｶﾞﾅ:</td>
                <td colspan="5">
                  <custom-simple-textarea-b
                    id="userLastNameKana"
                    v-model="inputModel.userLastNameKana"
                    v-on:blur="validate('lastNameKana')"
                    placeholder="セイ"
                    class="account-edit-textarea"
                  />
                </td>
                <td colspan="5">
                  <custom-simple-textarea-b
                    id="userFirstNameKana"
                    v-model="inputModel.userFirstNameKana"
                    v-on:blur="validate('firstNameKana')"
                    placeholder="メイ"
                    class="account-edit-textarea"
                  />
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="!remsOnly && (checkLastNameKana.isInvalid || checkFirstNameKana.isInvalid || checkLastNameKana.isOver || checkFirstNameKana.isOver)"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p
                    v-if="checkLastNameKana.isInvalid || checkFirstNameKana.isInvalid"
                  >氏名ﾌﾘｶﾞﾅはカタカナで入力してください。</p>
                  <p v-if="checkLastNameKana.isOver">氏名ﾌﾘｶﾞﾅ(姓)は40文字以内で入力してください。</p>
                  <p v-if="checkFirstNameKana.isOver">氏名ﾌﾘｶﾞﾅ(名)は40文字以内で入力してください。</p>
                </td>
              </tr>
              <tr>
                <td>氏名*:</td>
                <td colspan="5">
                  <custom-simple-textarea-b
                    id="userLastName"
                    v-model="inputModel.userLastName"
                    v-on:blur="validate('lastName')"
                    placeholder="姓"
                    class="account-edit-textarea"
                  />
                </td>
                <td colspan="5">
                  <custom-simple-textarea-b
                    id="userFirstName"
                    v-model="inputModel.userFirstName"
                    v-on:blur="validate('firstName')"
                    placeholder="名"
                    class="account-edit-textarea"
                  />
                </td>
              </tr>
              <!-- mod FNSI-「氏名」の「\」チェック 鄧シン start -->
              <!-- <tr
                class="error-message"
                v-if="checkLastName.isNull || checkFirstName.isNull || checkLastName.isOver || checkFirstName.isOver"
              > -->
              <tr
                class="error-message"
                v-if="checkLastName.isNull || checkFirstName.isNull || checkLastName.isOver || checkFirstName.isOver || checkLastName.isInvalid || checkFirstName.isInvalid"
              >
              <!-- mod FNSI-「氏名」の「\」チェック 鄧シン end -->
                <td class="title"></td>
                <td colspan="10">
                  <p v-if="checkLastName.isNull || checkFirstName.isNull">氏名は入力必須項目です。</p>
                  <p
                    v-if="!checkLastName.isNull && !checkFirstName.isNull && checkLastName.isOver"
                  >氏名(姓)は20文字以内で入力してください。</p>
                  <p
                    v-if="!checkLastName.isNull && !checkFirstName.isNull && checkFirstName.isOver"
                  >氏名(名)は20文字以内で入力してください。</p>
                  <!-- add FNSI-「氏名」の「\」チェック 鄧シン start -->
                  <p v-if="checkLastName.isInvalid">氏名(姓)の入力形式に誤りがあります。</p>
                  <p v-if="checkFirstName.isInvalid">氏名(名)の入力形式に誤りがあります。</p>
                  <!-- add FNSI-「氏名」の「\」チェック 鄧シン end -->
                </td>
              </tr>
              <tr v-if="!remsOnly">
                <td>氏名英字:</td>
                <td colspan="5">
                  <custom-simple-textarea-b
                    id="userLastNameAlpha"
                    v-model="inputModel.userLastNameAlpha"
                    v-on:blur="validate('lastNameAlpha')"
                    placeholder="last name"
                    class="account-edit-textarea"
                  />
                </td>
                <td colspan="5">
                  <custom-simple-textarea-b
                    id="userFirstNameAlpha"
                    v-model="inputModel.userFirstNameAlpha"
                    v-on:blur="validate('firstNameAlpha')"
                    placeholder="first name"
                    class="account-edit-textarea"
                  />
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="!remsOnly && (checkLastNameAlpha.isInvalid || checkFirstNameAlpha.isInvalid || checkLastNameAlpha.isOver || checkFirstNameAlpha.isOver)"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p
                    v-if="checkLastNameAlpha.isInvalid || checkFirstNameAlpha.isInvalid"
                  >氏名英字は英字で入力してください。</p>
                  <p v-if="checkLastNameAlpha.isOver">氏名英字(姓)は40文字以内で入力してください。</p>
                  <p v-if="checkFirstNameAlpha.isOver">氏名英字(名)は40文字以内で入力してください。</p>
                </td>
              </tr>
              <tr>
                <td>
                  メール
                  <br />アドレス1:
                </td>
                <td valign="bottom" colspan="10">
                  <v-ons-input
                    :class="getFaQuestionClass1"
                    type="email"
                    float
                    v-model="inputModel.userEmailAddress1"
                    v-on:blur="validate('mailAddress1')"
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add start -->
                  <v-ons-input
                    :class="getFaQuestionClass2"
                    type="email"
                    float
                    value="******"
                    disabled
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add end -->
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="checkMailAddress1.isInvalid || checkMailAddress1.isOver"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p v-if="checkMailAddress1.isInvalid">メールアドレス1の入力形式に誤りがあります。</p>
                  <p v-if="checkMailAddress1.isOver">メールアドレス1は256文字以内で入力してください。</p>
                </td>
              </tr>
              <tr>
                <td>
                  メール
                  <br />アドレス2:
                </td>
                <td valign="bottom" colspan="10">
                  <v-ons-input
                    :class="getFaQuestionClass1"
                    type="email"
                    float
                    v-model="inputModel.userEmailAddress2"
                    v-on:blur="validate('mailAddress2')"
                  />

                  <!-- FNSI-修正 3849 対応 xiebzh add start -->
                  <v-ons-input
                    :class="getFaQuestionClass2"
                    type="email"
                    float
                    value="******"
                    disabled
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add end -->
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="checkMailAddress2.isInvalid || checkMailAddress2.isOver"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p v-if="checkMailAddress2.isInvalid">メールアドレス2の入力形式に誤りがあります。</p>
                  <p v-if="checkMailAddress2.isOver">メールアドレス2は256文字以内で入力してください。</p>
                </td>
              </tr>

              <tr v-if="!remsOnly">
                <td>内線TEL:</td>
                <td colspan="10">
                  <v-ons-input
                    type="tel"
                    float
                    v-model="inputModel.extensionNo"
                    v-on:blur="validate('extensionNo')"
                  />
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="!remsOnly && (checkExtensionNo.isInvalid || checkExtensionNo.isOver)"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p v-if="checkExtensionNo.isInvalid">内線TELの入力形式に誤りがあります。</p>
                  <p v-if="checkExtensionNo.isOver">内線TELは25文字以内で入力してください。</p>
                </td>
              </tr>
              <tr v-if="!remsOnly">
                <td>自宅TEL:</td>
                <td colspan="10">
                  <v-ons-input
                    type="tel"
                    float
                    :class="getFaQuestionClass1"
                    v-model="inputModel.homeNo"
                    v-on:blur="validate('homeNo')"
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add start -->
                  <v-ons-input
                    type="tel"
                    float
                    :class="getFaQuestionClass2"
                    value="******"
                    disabled
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add end -->
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="!remsOnly && (checkHomeNo.isInvalid || checkHomeNo.isOver)"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p v-if="checkHomeNo.isInvalid">自宅TELの入力形式に誤りがあります。</p>
                  <p v-if="checkHomeNo.isOver">自宅TELは25文字以内で入力してください。</p>
                </td>
              </tr>
              <tr v-if="!remsOnly">
                <td>携帯TEL:</td>
                <td colspan="10">
                  <v-ons-input
                    type="tel"
                    float
                    :class="getFaQuestionClass1"
                    v-model="inputModel.mobilePhoneNo"
                    v-on:blur="validate('mobilePhoneNo')"
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add start -->
                  <v-ons-input
                    type="tel"
                    float
                    :class="getFaQuestionClass2"
                    value="******"
                    disabled
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add end -->
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="!remsOnly && (checkMobilePhoneNo.isInvalid || checkMobilePhoneNo.isOver)"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p v-if="checkMobilePhoneNo.isInvalid">携帯TELの入力形式に誤りがあります。</p>
                  <p v-if="checkMobilePhoneNo.isOver">携帯TELは25文字以内で入力してください。</p>
                </td>
              </tr>
              <tr v-if="!remsOnly">
                <td>FAX:</td>
                <td colspan="10">
                  <v-ons-input
                    type="tel"
                    float
                    :class="getFaQuestionClass1"
                    v-model="inputModel.faxNo"
                    v-on:blur="validate('faxNo')"
                  />

                  <!-- FNSI-修正 3849 対応 xiebzh add start -->
                  <v-ons-input
                    type="tel"
                    float
                    :class="getFaQuestionClass2"
                    value="******"
                    disabled
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add end -->
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="!remsOnly && (checkFaxNo.isInvalid || checkFaxNo.isOver)"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p v-if="checkFaxNo.isInvalid">FAXの入力形式に誤りがあります。</p>
                  <p v-if="checkFaxNo.isOver">FAXは25文字以内で入力してください。</p>
                </td>
              </tr>
              <tr v-if="!remsOnly">
                <td>
                  郵便番号
                  <br />(ﾊｲﾌﾝなし):
                </td>
                <td colspan="4">
                  <!-- 見た目をその他入力欄と合わせる為のタグ -->
                  <!-- mod FNSI-画面の「郵便番号」を表示する 鄧シン start -->
                  <!-- <v-ons-input
                    ref="user_zip_cd"
                    :value="inputModel.zipcd.initValue"
                    :validators="[]"
                    type="tel"
                    style="border: unset;"
                    maxlength="7"
                    form-name="郵便番号"
                    @blur="chkZipcd(inputModel.zipcd.editValue)"
                  /> -->
                  <!-- mod FNSI-画面の「郵便番号」を表示する 関 start -->
                  <!-- <v-ons-input
                    ref="user_zip_cd"
                    v-model="inputModel.zipcd.initValue"
                    :validators="[]"
                    type="tel"
                    style="border: unset;"
                    maxlength="7"
                    form-name="郵便番号"
                    @blur="chkZipcd(inputModel.zipcd.initValue)"
                  /> -->
                  <v-ons-input
                    ref="user_zip_cd"
                    v-model="inputModel.zipcd"
                    :validators="[]"
                    type="tel"
                    style="border: unset;"
                    :class="getFaQuestionClass1"
                    maxlength="7"
                    form-name="郵便番号"
                    @blur="chkZipcd(inputModel.zipcd)"
                  />

                  <!-- FNSI-修正 3849 対応 xiebzh add start -->
                  <v-ons-input
                    type="tel"
                    style="border: unset;"
                    :class="getFaQuestionClass2"
                    value="******"
                    disabled
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add end -->
                  <!-- mod FNSI-画面の「郵便番号」を表示する 関 end -->
                  <!-- mod FNSI-画面の「郵便番号」を表示する 鄧シン end -->
                </td>
                <!--mod #3838 じょはく start-->
                <!--mod # 5547 <td align="center" v-if="this.getStateUserAccountInfo.infoDispToAdmin === '1'">-->
                <td align="center">
                  <v-ons-button
                    class="btn3-normal common-style-select-button button-select"
                    @click="showAddressSearchModal(setAddressValues); mapVisible = true;"
                    :disabled="!remsOnly && (checkZipcd3.isInvalid || checkZipcd4.isInvalid || checkZipcd3.isOver || checkZipcd4.isOver)"
                  >
                    住所検索
                  </v-ons-button>

                </td>
                <!--mod #3838 じょはく end-->
              </tr>
              <tr
                class="error-message"
                v-if="!remsOnly && (checkZipcd3.isInvalid || checkZipcd4.isInvalid || checkZipcd3.isOver || checkZipcd4.isOver)"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p>郵便番号の入力形式に誤りがあります。</p>
                </td>
              </tr>
              <tr v-if="false">
                <td>
                  自宅住所
                  <br />(ふりがな):
                </td>
                <td colspan="10">
                  <v-ons-input
                    type="text"
                    float
                    v-model="inputModel.addressKana"
                    v-on:blur="validate('addressKana')"
                  />
                </td>
              </tr>
              <!-- mod FNSI-「自宅住所(ふりがな)」の「\」チェック 鄧シン start -->
              <!-- <tr
                class="error-message"
                v-if="!remsOnly && checkAddressKana.isOver"
              > -->
              <tr
                class="error-message"
                v-if="!remsOnly && (checkAddressKana.isOver || checkAddressKana.isInvalid)"
              >
                <td class="title"></td>
                <td colspan="10">
                  <!-- <p>自宅住所(ふりがな)は512文字以内で入力してください。</p> -->
                  <p v-if="checkAddressKana.isOver">自宅住所(ふりがな)は512文字以内で入力してください。</p>
                  <p v-if="checkAddressKana.isInvalid">自宅住所(ふりがな)の入力形式に誤りがあります。</p>
                </td>
              </tr>
              <!-- mod FNSI-「自宅住所(ふりがな)」の「\」チェック 鄧シン end -->
              <tr v-if="!remsOnly">
                <td>
                  自宅住所
                  <br />(漢字):
                </td>
                <td colspan="10">
                  <custom-simple-textarea-b
                    :class="getFaQuestionClass1"
                    v-model="inputModel.address"
                    v-on:blur="validate('address')"
                    class="account-edit-textarea"
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add start -->
                  <v-ons-input
                    type="text"
                    float
                    :class="getFaQuestionClass2"
                    value="******"
                    disabled
                  />
                  <!-- FNSI-修正 3849 対応 xiebzh add end -->
                </td>
              </tr>
              <!-- add FNSI-「自宅住所(漢字)」のエラーメッセージ表示位置を修正する 鄧シン start -->
              <!-- mod FNSI-「自宅住所(漢字)」の「\」チェック 鄧シン start -->
              <!-- <tr class="error-message" v-if="!remsOnly && checkAddress.isOver"> -->
              <tr class="error-message" v-if="!remsOnly && (checkAddress.isOver || checkAddress.isInvalid)">
                <td class="title"></td>
                <td colspan="10">
                  <!-- <p>自宅住所(漢字)は512文字以内で入力してください。</p> -->
                  <p v-if="checkAddress.isOver">自宅住所(漢字)は512文字以内で入力してください。</p>
                  <p v-if="checkAddress.isInvalid">自宅住所(漢字)の入力形式に誤りがあります。</p>
                </td>
              </tr>
              <!-- mod FNSI-「自宅住所(漢字)」の「\」チェック 鄧シン end -->
              <!-- add FNSI-「自宅住所(漢字)」のエラーメッセージ表示位置を修正する 鄧シン end -->
              <!-- mod 5331 麻酔施用者免許書番号の表示位置不正 解 start -->
              <tr v-if="isDoctor">
                <td>
                  <!-- mod 4494アカウント編集画面、処方画面の誤字 張 start -->
                  <!-- <label>麻酔施用者
                    <br/>免許証番号：</label> -->
                  <label>麻薬施用者
                    <!-- FNSI-修正 4497 対応 xiebzh add start -->
                    <!--<br/>免許証番号：</label>-->
                    <br/>免許証番号:</label>
                  <!-- FNSI-修正 4497 対応 xiebzh add end -->
                  <!-- mod アカウント編集画面、処方画面の誤字 張 end -->
                </td>
                <td valign="bottom" colspan="10">
                  <v-ons-input
                    type="text"
                    float
                    v-model="inputModel.anesthesiologistLicenseNo"
                  />
                </td>
              </tr>
              <!-- mod 5331 麻酔施用者免許書番号の表示位置不正 解 end -->
              <tr v-if="!remsOnly">
                <td>
                  連携コード1
                </td>
                <td colspan="10">
                  <v-ons-input
                    type="tel"
                    float
                    v-model="inputModel.inHospitalCd_1"
                    v-on:blur="validate('inHospitalCd_1')"
                  />
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="!remsOnly && checkInHospitalCd_1.isOver"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p>連携コード1は20文字以内で入力してください。</p>
                </td>
              </tr>
              <tr v-if="!remsOnly">
                <td>
                  連携コード2
                </td>
                <td colspan="10">
                  <v-ons-input
                    type="tel"
                    float
                    v-model="inputModel.inHospitalCd_2"
                    v-on:blur="validate('inHospitalCd_2')"
                  />
                </td>
              </tr>
              <tr
                class="error-message"
                v-if="!remsOnly && checkInHospitalCd_2.isOver"
              >
                <td class="title"></td>
                <td colspan="10">
                  <p>連携コード2は20文字以内で入力してください。</p>
                </td>
              </tr>
              <tr v-if="!remsOnly">
                <td>
                  管理者への
                  <br />表示許可:
                  <span class="faQuestion">
                  <v-ons-icon
                    icon="fa-question-circle"
                    @click="showPopOver($event, 'チェックボックスをONにすると、管理者アカウントのみが閲覧できるマスタにて、メールアドレスや電話番号、住所が表示されます。\nチェックボックスをOFFにすると、マスキングされ管理者アカウントでも参照できなくなります。\n内線電話番号はこの設定に関係なく参照することができます。')"
                  ></v-ons-icon>
                  </span>
                </td>
                <td align="left">
                  <v-ons-checkbox
                    v-model="inputModel.infoDispToAdmin"
                  >
                  </v-ons-checkbox>
                </td>
              </tr>
              <!-- del FNSI-「自宅住所(漢字)」のエラーメッセージ表示位置を修正する 鄧シン start -->
              <!-- <tr class="error-message" v-if="!remsOnly && checkAddress.isOver">
                <td class="title"></td>
                <td colspan="10">
                  <p>自宅住所(漢字)は512文字以内で入力してください。</p>
                </td>
              </tr> -->
              <!-- del FNSI-「自宅住所(漢字)」のエラーメッセージ表示位置を修正する 鄧シン end -->
              <tr v-if="!DISABLE_FOR_MARCH_8_RELEASE">
                <td>職種:</td>
                <td colspan="10">
                  <v-ons-select input-id="occupations" class="selectbox" placeholder="業種">
                    <option value="01">職種１</option>
                    <option value="02">職種２</option>
                    <option value="03">職種３</option>
                  </v-ons-select>
                </td>
              </tr>
            </tbody>
          </table>
          <v-ons-list modifier="inset" v-if="!remsOnly">
            <v-ons-list-header>編集権限(編集不可)</v-ons-list-header>
            <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
              <table>
                <thead>
                  <tr>
                    <th>代行編集可</th>
                    <th>編集可</th>
                    <th>機能名</th>
                  </tr>
                </thead>
                <tbody v-for="(editAuthItm,$index) in editAuthList" :key="$index">
                  <tr>
                    <td align="center">
                      <v-ons-checkbox
                        v-if="editAuthItm.isDispProxy === true"
                        :input-id="'checkboxProxy-' + $index"
                        :value="editAuthItm.codeProxy"
                        v-model="checkedAuthority"
                        @change="onChangeAuthority"
                      ></v-ons-checkbox>
                    </td>
                    <td align="center">
                      <v-ons-checkbox
                        :input-id="'checkbox-' + $index"
                        :value="editAuthItm.code"
                        v-model="checkedAuthority"
                        @change="onChangeAuthority"
                      ></v-ons-checkbox>
                    </td>
                    <td>
                      <label>{{ editAuthItm.label }}</label>
                      <v-ons-icon
                        icon="fa-question-circle"
                        @click="showPopOver($event, editAuthItm.txtHelp)"
                      ></v-ons-icon>
                    </td>
                  </tr>
                </tbody>
              </table>
            </v-ons-list-item>
            <v-ons-list-header>削除権限(編集不可)</v-ons-list-header>
            <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
              <table>
                <thead>
                  <tr>
                    <th>編集可</th>
                    <th>機能名</th>
                  </tr>
                </thead>
                <tbody v-for="(delAuthItm,$index) in deleteAuthList" :key="$index">
                  <tr>
                    <td align="center">
                      <v-ons-checkbox
                        :input-id="'checkboxDel-' + $index"
                        :value="delAuthItm.code"
                        v-model="checkedAuthority"
                        @change="onChangeAuthority"
                      ></v-ons-checkbox>
                    </td>
                    <td>
                      <label>{{ delAuthItm.label }}</label>
                      <v-ons-icon
                        icon="fa-question-circle"
                        @click="showPopOver($event, delAuthItm.txtHelp)"
                      ></v-ons-icon>
                    </td>
                  </tr>
                </tbody>
              </table>
            </v-ons-list-item>
            <!-- add #12462 患者共有権限 関 start -->
            <template v-if="isPatientSharedAuthorized">
              <v-ons-list-header>患者共有権限</v-ons-list-header>
              <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
                <table>
                  <thead>
                    <tr>
                      <th>閲覧可</th>
                      <th>機能名</th>
                    </tr>
                  </thead>
                  <tbody v-for="(psAuthItm,$index) in patientSharedAuthorityList" :key="$index">
                    <tr>
                      <td align="center">
                        <v-ons-checkbox
                          :input-id="'pscheckbox-' + $index"
                          :value="psAuthItm.code"
                          v-model="checkedAuthority"
                          @change="onChangeAuthority"
                        >
                        </v-ons-checkbox>
                      </td>
                      <td>
                        <label>{{ psAuthItm.label }}</label>
                        <v-ons-icon icon="fa-question-circle" @click="showPopOver($event, psAuthItm.txtHelp)"></v-ons-icon>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </v-ons-list-item>
            </template>
            <!-- add #12462 患者共有権限 関 end -->
          </v-ons-list>
          <v-ons-list modifier="inset" v-if="this.checkValueSignIn()">
            <div>
              <v-ons-list-header > 2要素認証登録</v-ons-list-header>
                <!-- 設定状態の表示と秘密鍵作成・更新ボタン -->
                <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
                  <div class="mfa-container">
                    <div class="mfa-message">
                      {{ statusMessage }}
                    </div>
                    <v-ons-button
                      class="btn3-normal mfa-button button-select"
                      @click="EnableQRcode"
                      v-show="!this.isRegistedQrCode"
                    >
                      {{ registerButtonMessage }}
                    </v-ons-button>
                    <v-ons-button
                      class="btn4-alert mfa-button"
                      @click="deleteKey"
                      v-show="this.isRegistedQrCode"
                    >
                      2要素認証解除
                    </v-ons-button>
                  </div>
                </v-ons-list-item>
                <!-- QRコード-->
                <v-ons-list-item class="ntss-theme-screen" modifier="nodivider" v-bind:class="[this.isMadeQrCode ? 'QRcodeActive' : 'QRcodeInactive']">
                  <div id="bgQRcode">
                      <img :src="this.QRcodeImg" >
                  </div>
                </v-ons-list-item>
                <!-- 秘密鍵表示と登録ボタン -->
                <table class="ntss-theme-screen" v-bind:class="[this.isMadeQrCode ? 'QRcodeActive' : 'QRcodeInactive']">
                  <tbody>
                    <!-- 秘密鍵表示 -->
                    <tr style="word-break: break-all;">
                      <td
                        valign="bottom"
                        colspan="2"
                        style="padding-right: 7px;"
                      >
                        <label>秘密鍵: {{ inputSecretKey }}</label>
                      </td>
                    </tr>
                    <!-- 認証コード入力(スマホ) -->
                    <tr v-if="this.isAndroid || this.isIOS" v-bind:class="[this.isRegistedQrCode ? 'ButtonInactive' : 'ButtonActive']">
                      <td colspan="2">
                        <v-ons-input
                          type="text"
                          float
                          v-model="oneTimePassword"
                          width="2em"
                        />
                      </td>
                    </tr>
                    <!-- 認証コード入力(PC) + 登録ボタン(スマホ/PC) -->
                    <tr v-bind:class="[this.isRegistedQrCode ? 'ButtonInactive' : 'ButtonActive']">
                      <td v-if="!this.isAndroid && !this.isIOS" >
                        <v-ons-input
                          type="text"
                          float
                          v-model="oneTimePassword"
                          width="2em"
                        />
                        <!-- v-on:blur="validate('address')" isRegistedQrCode font-adjust-xl-->
                      </td>
                      <td v-bind:class="[this.getFontSize === 3 ? 'font-adjust-xl' : '']">
                        <v-ons-button
                          class="btn1-execute btn-save"
                          style="padding: 0px 5px;"
                          @click="updateSecretKey"
                          v-bind:disabled="oneTimePassword === ''"
                        >
                            認証コードチェック・設定保存
                        </v-ons-button>
                      </td>
                    </tr>
                  </tbody>
                </table>
            </div>
          </v-ons-list>
          <v-ons-list modifier="inset">
            <!--20260108 add 施舍admin start-->
            <div>
              <v-ons-list-header>
                <span>施設</span>
                <span v-if="inputModel.canLoginFacilities&&inputModel.canLoginFacilities.length&&inputModel.canLoginFacilities.length!=0">（{{ inputModel.canLoginFacilities.length }}）</span>
              </v-ons-list-header>
              <v-ons-list-item class="ntss-theme-screen" modifier="nodivider">
                <div class="topBtnView">
                  <div v-if="isOpenAddFlag == false">
                    <v-ons-button
                    
                    class="nik-btn btn3-normal addBtn"
                    @click="clickChangeAddView()"
                  >追加</v-ons-button>
                  </div>
                  <div v-else>
                    <v-ons-button
                      class="btn2-cancel cancelBtn"
                      @click="clickChangeAddView()"
                    >キャンセル</v-ons-button>
                    <v-ons-button
                      class="btn1-execute addBtn"
                      :disabled="isNeedSecondFlag==true||isCanVerify||isRequest"
                      @click="verifyFN()"
                    >確認</v-ons-button>
                  </div>
                </div>
                <!--add -->
                <div class="addFacilitiesView">
                  <div v-if="isOpenAddFlag == true">
                    <div  v-for="(item, index) in showAddFrom"
                      :key="index">
                      <table class="card-table">
                        <button
                          v-show="false"
                          class="button-delete ntss-btn-outset"
                          @click="deleteThatFacilitie(index)"
                        >
                          <v-ons-icon icon="fa-trash"/>
                        </button>
                        <br />
                        <tr>
                          <td class="item-title">ハッシュ値</td>
                          <td colspan="2" class="item-data">
                            <v-ons-input :disabled="isNeedSecondFlag" maxlength="300" type='text' v-model.trim='item.facilityHash'  float></v-ons-input>
                            <!-- mod #10359 編集権限の動作不正 dengshen end -->
                          </td>
                        </tr>
                        <tr>
                          <td class="item-title">ユーザーID</td>
                          <td colspan="2" class="item-data">
                            <v-ons-input :disabled="isNeedSecondFlag" maxlength="50" type='text' v-model.trim='item.username'  float></v-ons-input>
                            <!-- mod #10359 編集権限の動作不正 dengshen end -->
                          </td>
                        </tr>
                        <tr>
                          <td class="item-title">パスワード</td>
                          <td colspan="2" class="item-data">
                            <div class="password-wrapper">
                                <v-ons-input  input-id='passwd' maxlength="30" :disabled="isNeedSecondFlag" type='password' v-model.trim='item.password' ref='passwd' @keyup.enter='signIn' float></v-ons-input>
                                <v-ons-icon icon="fa-eye" size="18px" class="password-eyeicon" @click="clickEyeIcon($event)"/>
                              </div>
                            <!-- mod #10359 編集権限の動作不正 dengshen end -->
                          </td>
                        </tr>
                      </table> 
                      <!---isNeedSecondFlag-->
                      <div class="secondView" v-if="isNeedSecondFlag">
                        <v-ons-row>
                          <v-ons-col>
                            <div>
                              <label>2要素認証</label>
                              <hr/>
                            </div>
                          </v-ons-col>
                        </v-ons-row>
                        <v-ons-row>
                          <v-ons-col>
                            <div class="secondText">
                              <label>ワンタイムパスワードを入力してください。</label><br>
                              <v-ons-input max-length="30" type='text' input-id="otp" v-model="secondOtpKey" ref='otp' float autofocus autocapitalize="off" @keyup.enter='secondVerifyFN'></v-ons-input>
                            </div>
                          </v-ons-col>
                        </v-ons-row>
                        <v-ons-row>
                          <v-ons-col>
                            <div class="opBtnView">
                              <v-ons-button class="btn2-cancel  opyCancelBtn" @click='closeSecondOtpFN'>CLOSE</v-ons-button>
                              <v-ons-button class="btn1-execute secondVerifyBtn" :disabled='secondOtpKey.length==0?true:false' ref='checkOtpButton' @click='secondVerifyFN'>送信</v-ons-button>
                              <!-- <v-ons-button class="btn2-cancel"  @click='backToLogin'>キャンセル</v-ons-button> -->
                            </div>
                          </v-ons-col>
                        </v-ons-row>
                      </div>
                      <div class="borderView" v-if="index + 1!=showAddFrom.length||showAddFrom.length==1"></div>
                    </div>
                    
                  </div>
                </div>
                <!--all list-->
                <div class="showAllFacilitiesView">
                  <div class="nothaveList" v-if="inputModel.canLoginFacilities&&inputModel.canLoginFacilities.length == 0">データなし</div>
                  <div v-for="(item, index) in inputModel.canLoginFacilities"
                    class="facilitiesListView"
                    :key="index">
                    <p class="facilitiesListText">
                      <v-ons-button
                      v-if="item.massage!=null&&item.optAuth==true"
                        class="btn4-alert mfa-button"
                        @click="openListAdd(item)"
                      >
                        2要素認証
                      </v-ons-button>
                      <span>{{index + 1}} . </span>
                      <span>{{ item.facilityName }}</span>
                      <span v-if="item.facilityName"> • </span>
                      <span>{{ item.username }}</span>
                    </p>
                    <button
                        v-show="true"
                        class="button-delete ntss-btn-outset"
                        @click="deleteThatFacilitie(index)"
                      >
                        <v-ons-icon icon="fa-trash"/>
                    </button>
                    <!--list 2要素認証-->
                    <div v-if="item.isOpenAgainAdd&&item.isOpenAgainAdd==true" class="facilitiesListOpenAddView">
                      <v-ons-row>
                          <v-ons-col>
                            <div>
                              <label>2要素認証</label>
                              <hr/>
                            </div>
                          </v-ons-col>
                        </v-ons-row>
                        <v-ons-row>
                          <v-ons-col>
                            <div class="secondText">
                              <label>ワンタイムパスワードを入力してください。</label><br>
                              <v-ons-input max-length="30"  type='text' input-id="otp" v-model="secondAgainOtpKey" ref='otp' float autofocus autocapitalize="off" @keyup.enter='againSecondVerifyFN(item)'></v-ons-input>
                            </div>
                          </v-ons-col>
                        </v-ons-row>
                        <v-ons-row>
                          <v-ons-col>
                            <div class="opBtnView">
                              <v-ons-button class="btn2-cancel  opyCancelBtn" @click='againSecondClose(item)'>CLOSE</v-ons-button>
                              <v-ons-button class="btn1-execute secondVerifyBtn" :disabled='secondAgainOtpKey.length==0?true:false' ref='checkOtpButton' @click='againSecondVerifyFN(item)'>送信</v-ons-button>
                              <!-- <v-ons-button class="btn2-cancel"  @click='backToLogin'>キャンセル</v-ons-button> -->
                            </div>
                          </v-ons-col>
                        </v-ons-row>
                    </div>
                    <!--border-->
                    <div class="borderView1" v-if="index + 1!=inputModel.canLoginFacilities.length"></div>
                  </div>
                </div>
              </v-ons-list-item >
            </div>
            <!--20260108 add 施舍admin end-->
          </v-ons-list>


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
            <p class="popover-message" id="popOverMessage">テスト</p>
          </v-ons-popover>
        </div>
      </div>
    </div>
    <div slot="footer" class="flex-container">
      <div class="denial-btn-area" style="background:none">
        <v-ons-button class="button btn2-cancel denial-btn btn-cancel" @click="cancel">キャンセル</v-ons-button>
      </div>
      <div class="registration-btn-area" style="background:none">
        <!-- onclick="" は iOS で blurイベントを発火させる為 -->
        <!--20260115 liyanze-z facilitiesChange-->
        <v-ons-button
          v-if="facilitiesChange == false"
          class="button btn1-execute registration-btn btn-save"
          onclick=""
          @click="registration"
          :disabled="isValidationError || !isChanged || !isPasswordComplete"
        >保存</v-ons-button>
        <v-ons-button
          v-else
          class="button btn1-execute registration-btn btn-save"
          onclick=""
          @click="registration"
          :disabled="!facilitiesChange"
        >保存</v-ons-button>
      </div>
    </div>
  </modal-base>
</template>

<script>
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { EventBus } from "@/eventBus.js";
import { mapActions, mapGetters } from "vuex";
// mod #12462 患者情報共有 関 start
import {
  editAuthorityList,
  deleteAuthorityList,
  patientSharedAuthorityList
} from "@/constants/authorityList";
import { FUNC_SHARING_PATIENT_INFORMATION } from "@/constants/function-code.js";
// mod #12462 患者情報共有 関 end
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import { sendRequestCheckMatchCurrentPassword, sendRequestIsAvailablePassword } from "@/apis/User";
// liyanze-z add 施舍 api
import { getInfoRetrieve,getInfoOPT } from "@/apis/facilities-can-login.js";
import { PASSWORD_POLICY, NUM_OF_PASSWORD, pwdLvLow, pwdLvNormal, pwdLvHigh } from "@/constants/facilitySetting";
import { SYS_USE_TYPE } from "@/constants/sysUseConstants";
import PopoverMixin from "@/components/PopoverMixin";
import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
// add 2020-09-25 FNSI-4200ポートを使用している 孫 start
import { ApiHelper } from "@/apis/AxiosHelper";
// add 2020-09-25 FNSI-4200ポートを使用している 孫 end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
import {changeShowPassword} from "@/functions/common/CommonFunctions";

// add 2020-09-25 FNSI-4200ポートを使用している 孫 start
const uriGetCardAppPort = `/card_state/get_card_app_ports`;
// add 2020-09-25 FNSI-4200ポートを使用している 孫 end
export default {
  name: "accountEdit",
  mixins: [MultiModalMixin, PopoverMixin],
  components: {
    "modal-base": ModalBase,
    "custom-simple-textarea-b": CustomSimpleTextareaTypeB
  },
  data() {
    return {
      // 入力項目
      inputModel: {},
      // 正規表現
      regExp: {
        // 半角英数記号
        half: /^[a-zA-Z0-9&%$#@_-]+$/,
        // 数字、ハイフン
        numericAndHyphen: /^[0-9０-９-ー]+$/,
        // 数字
        numeric: /^[0-9]+$/,
        // 半角英数字
        halfAlphanumeric: /^[0-9a-zA-Z]+$/,
        // カタカナ
        katakana: /^[ァ-ンｧ-ﾝﾞﾟ]+$/,
        // 英字
        alpha: /^[a-zａ-ｚA-ZＡ-Ｚ-]+$/,
        // メールアドレス
        mailAddress: /^[A-Za-z0-9]{1}[A-Za-z0-9_.-]*@{1}[A-Za-z0-9_.-]{1,}\.[A-Za-z0-9]{1,}$/,
        // add 「自宅住所(漢字)」と「自宅住所(ふりがな)」の「\」チェック 鄧シン start
        // 不正な文字「\」
        errorChar: /['\\']/
        // add 「自宅住所(漢字)」と「自宅住所(ふりがな)」の「\」チェック 鄧シン end
      },
      // 3/8リリース向け非表示対応
      // TODO:#2855 で以下のフィールドの参照箇所を全て削除すること
      DISABLE_FOR_MARCH_8_RELEASE: true,
      // 権限項目
      editAuthList: editAuthorityList,
      deleteAuthList: deleteAuthorityList,
      // add #12462 患者共有権限 関 start
      patientSharedAuthorityList: patientSharedAuthorityList,
      // add #12462 患者共有権限 関 end
      checkedAuthority: [],
      // 吹き出し関連制御
      userMenuPopoverVisible: false,
      userMenuPopoverTarget: null,
      userMenuPopoverDirection: "right up",
      isMadeQrCode: false,
      QRcodeImg : "",
      inputSecretKey : "",
      isDoctor : false,
      isCardDeviceConnected: false,
      socketInterval: null,
      oneTimePassword: "",
      isAndroid: false,
      isIOS: false,
      fontSize: "",
      isCorrectCurrentPassword: false,
      //OTP値
      otp: "",
      /*** 
       * 施舍 list
      */
      copyData:{},
      facilitiesList:[],
      facilitiesChange:false,
      isOpenAddFlag:false,
      isCanVerify:true,
      //add form
      addForm:{
        facilityHash:'',
        //facilityName:'',
        username:'',
        password:'',
      },
      showAddFrom:[],
      isRequest:false,
      //2要素認証
      isNeedSecondFlag:false,
      secondOtpKey:'',
      secondAgainOtpKey:'',
      secretKey:'',
    };
  },
  computed: {
    // mod #12462 患者情報共有 関 start
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "getValidationResults",
      "getFontSize"
    ]),
    // mod #12462 患者情報共有 関 end
    ...mapGetters("facility", ["isUseFunction"]),
    ...mapGetters("master-maintenance", ["getFacilitySwitch"]),
    ...mapGetters("mst-facility-setting", { getValueSignIn: "getValueSignIn" }),
    ...mapGetters("mst-user", { getUserOTP: "getUserOTP" }),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      systemUseSetting: "getSystemUseSetting"
    }),
    ...mapGetters("websocket-card", [
      "getSocketIsConnected",
      "getSocketMessages",
      "getCardDeviceStatus"
    ]),

    /**
     * 利用形態がReMSのみの場合trueを返す.
     */
    remsOnly() {
      return this.systemUseSetting === SYS_USE_TYPE.REMS_ONLY;
    },
    // mod #12462 患者情報共有 関 start
    isPatientSharedAuthorized() {
      return this.isUseFunction(FUNC_SHARING_PATIENT_INFORMATION);
    },
    // mod #12462 患者情報共有 関 end
    // ----- バリデーション結果確認 -----
    checkDispUserId() {
      return this.getValidationResults.dispUserId;
    },
    // TODO パスワード入力可能になったらバリデーション結果確認を追加する
    checkLastNameKana() {
      return this.getValidationResults.lastNameKana;
    },
    checkFirstNameKana() {
      return this.getValidationResults.firstNameKana;
    },
    checkLastName() {
      return this.getValidationResults.lastName;
    },
    checkFirstName() {
      return this.getValidationResults.firstName;
    },
    checkLastNameAlpha() {
      return this.getValidationResults.lastNameAlpha;
    },
    checkFirstNameAlpha() {
      return this.getValidationResults.firstNameAlpha;
    },
    checkMailAddress1() {
      return this.getValidationResults.mailAddress1;
    },
    checkMailAddress2() {
      return this.getValidationResults.mailAddress2;
    },
    checkExtensionNo() {
      return this.getValidationResults.extensionNo;
    },
    checkHomeNo() {
      return this.getValidationResults.homeNo;
    },
    checkMobilePhoneNo() {
      return this.getValidationResults.mobilePhoneNo;
    },
    checkFaxNo() {
      return this.getValidationResults.faxNo;
    },
    checkZipcd3() {
      return this.getValidationResults.zipcd3;
    },
    checkZipcd4() {
      return this.getValidationResults.zipcd4;
    },
    checkAddress() {
      return this.getValidationResults.address;
    },
    checkAddressKana() {
      return this.getValidationResults.addressKana;
    },
    checkInHospitalCd_1() {
      return this.getValidationResults.inHospitalCd_1;
    },
    checkInHospitalCd_2() {
      return this.getValidationResults.inHospitalCd_2;
    },
    /**
     * バリデーションエラーがあるかどうか
     * @return バリデーションエラーの場合、true
     */
    isValidationError() {
      let isError = false;
      const validationResults = this.getValidationResults;
      Object.keys(validationResults).forEach(key => {
        const validationResult = validationResults[key];
        Object.keys(validationResult).forEach(resultKey => {
          if (validationResult[resultKey]) {
            isError = true;
          }
        }, validationResult);
      }, validationResults);
      // エラーがなければ、falseが返る
      return isError || this.$validator.errors.items.length !== 0;
    },
    /**
     * ユーザ情報取得.
     * @return stateに登録されたユーザ情報
     */
    userAccountInfo() {
      return this.getStateUserAccountInfo;
    },
    /**
     * 変更があるかどうかを返す.
     */
    isChanged() {
      const storeModel = this.getStateUserAccountInfo;
      const inputModel = this.inputModel;

      // inputModelとStore.userAccountInfoを比較する
      const result = Object.keys(this.inputModel)
        // パスワード確認、ダイアログ用のzipcdは対象外
        //liyanze-z &&key!=='canLoginFacilities'  このフィールドは精度に影響するからです。
        .filter(key => key !== "userPasswordConfirm" && key !== "zipcd"&&key!=='canLoginFacilities')
        .find(key => {
          let userAccountInfoValue;
          if (key === "infoDispToAdmin") {
            userAccountInfoValue = storeModel[key] === "1" ? true : false;
          } else {
            userAccountInfoValue = storeModel[key];
          }
          const inputModelValue = inputModel[key];
          // 編集前後がnullまたは空文字以外の場合のみ比較処理
          if (userAccountInfoValue || inputModelValue) {
            return userAccountInfoValue !== inputModelValue;
          }
        });
      return result ? true : false;
    },
    /**
     * パスワード入力済みの場合、パスワード関連の入力欄設定済み
     * ・パスワード未入力 -> true
     * ・パスワード入力済み、確認パスワード未入力、現在パスワード未入力 -> false
     * ・パスワード入力済み、確認パスワード入力済み、現在パスワード未入力 -> false
     * ・パスワード入力済み、確認パスワード入力済み、現在パスワード入力済み -> isCorrectCurrentPasswordがtrueならtrue
     */
    isPasswordComplete() {

      if (!this.inputModel.userPassword) {
        // パスワード未入力の場合、設定済みかどうかの確認はしない
        return true;
      }
      return this.inputModel.userPassword && this.inputModel.userPasswordConfirm && this.inputModel.userPasswordCurrent && this.isCorrectCurrentPassword;
    },
    /**
     * 住所選択ダイアログに渡す値.
     */
    setAddressValues() {
      return {
        postalCode: this.inputModel.zipcd,
        address: this.inputModel.address
      }
    },
    //バリューサインインを取得
    valueSignIn(){
      return this.getValueSignIn;
    },
    //ユーザーOTPの取得
    userOTP(){
      return this.getUserOTP;
    },
    statusMessage() {
      return this.isRegistedQrCode ? "状態：設定済み 2要素認証有効" : "状態：未設定";
    },
    // 秘密鍵作成・更新ボタンのメッセージ内容
    registerButtonMessage() {
      return this.isMadeQrCode ? "秘密鍵更新" : "秘密鍵作成";
    },
    // 秘密鍵設定済みフラグ
    isRegistedQrCode() {
      return this.getStateUserAccountInfo.isSetQrCode === 1;
    },

    // FNSI-修正 3849 対応 xiebzh add start
    getFaQuestionClass1() {
      if (this.getStateUserAccountInfo.infoDispToAdmin === '1') {
        return 'faQuestionActive';
      } else {
        // mod redmine 5547に対応
        // return 'faQuestionInactive';
        return 'faQuestionActive';
        // mod redmine 5547に対応
      }
    },
    getFaQuestionClass2() {
      if (this.getStateUserAccountInfo.infoDispToAdmin === '1') {
        return 'faQuestionInactive';
      } else {
        // mod redmine 5547に対応
        // return 'faQuestionActive';
        return 'faQuestionInactive';
        // mod redmine 5547に対応
      }
    }
    // FNSI-修正 3849 対応 xiebzh add end
  },
  methods: {
    ...mapActions("account-edit", [
      "setIsNull",
      "setIsInvalid",
      "setIsOver",
      "setIsInconsistent",
      "checkDuplication",
      "registUserAccount",
      "getUserAccountInfo",
      "resetValidationResults",
      "clearCard",
      "setCard"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    // 住所選択
    ...mapActions("multi-sub-modal", [
      "showAddressSearchModal"
    ]),
    ...mapActions("indication", {
      checkFacilitySetting: "checkFacilitySetting"
    }),
    ...mapActions("mst-facility-setting", ["sendRequestGetValueSignInByFacilityCd"]),
    ...mapActions("mst-user",["sendRequestCreateMstUserOTP",
                              "sendRequestUpdateSecretKey",
                              "sendRequestUpdateIsSetQrCode",
                              "sendRequestDeleteSecretKey",
                              "sendRequestCheckOtp"]),
    ...mapActions("pat-prescription", ["getDoctorsAtFacility"]),
    // mod FNSI-4200ポートを使用している 孫 start
    //...mapActions("websocket-card", ["connect", "sendSocketMessage", "close", "clearSocketMessage"]),
    ...mapActions("websocket-card", ["init", "connect", "sendSocketMessage", "close", "clearSocketMessage"]),
    // mod FNSI-4200ポートを使用している 孫 end
    /**
     * 処理：入力された現在のパスワードをチェック
     */
    async checkMatchCurrentPassword() {
      if (!this.inputModel.userPasswordCurrent) {
        return;
      }
      const params = {
        userId: this.userAccountInfo.userId,
        CurrentPassword: this.inputModel.userPasswordCurrent
      }
      sendRequestCheckMatchCurrentPassword(params)
        .then(response => {
          this.isCorrectCurrentPassword = response.data;
        });
    },
    // 入力した新しいパスワードが使用可能かチェック
    async checkIsAvailablePassword(userId, newPassword, facilityCd) {
      if(newPassword == null){
          return true;
      }
      const params = {
        userId: userId,
        newPassword: newPassword,
        facilityCd: facilityCd
      };

      const response = await sendRequestIsAvailablePassword(params)

      if (response.data === false) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "無効なパスワード",
          // message: "パスワード再利用禁止です！"
          title: DIALOG_MESSAGES['00200124'].title,
          message: messageFormat(DIALOG_MESSAGES['00200124'].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        return false;
      }

      return true;
    },
    //施設のパスワードを確認する
    checkFacilityPassword(facilityValue, lengthPassword, password, currentPassword) {
      var par,messagePopup, checkLengthError = false;
      if(password == null){
          return true;
      }

      messagePopup = password === currentPassword ? "現在のパスワードと異なるパスワード<br>" : "";

      if(lengthPassword == 16){
          messagePopup = messagePopup + lengthPassword + "文字"
      }else{
          messagePopup = messagePopup + lengthPassword + "文字以上16文字以下"
      }

      if(password.length < lengthPassword){
          checkLengthError = true;
      }
      switch (facilityValue) {
        case 1:
          if (checkLengthError || password.length > 16) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "無効なパスワード",
              title: DIALOG_MESSAGES["00300010"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: messagePopup
            });
            return false;
          }
          break;
        case 2:
          par = new RegExp(pwdLvLow)
          if(par.test(password) == false || checkLengthError){
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "無効なパスワード",
              title: DIALOG_MESSAGES["00300010"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: messagePopup+".<br>英字と数字を含む"
            });
            return false;
          }
          break;
        case 3:
          par = new RegExp(pwdLvNormal)
          if (par.test(password) == false || checkLengthError) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "無効なパスワード",
              title: DIALOG_MESSAGES["00300010"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: messagePopup+".<br>次の4つのカテゴリのうち3つから文字を使う<br>-英大文字(AからZ)<br>-英小文字(aからz)<br>-10進数の数字(0から9)<br>-記号(!、$、#、% など)"
            });
            return false;
          }
          break;
        case 4:
          par = new RegExp(pwdLvHigh)
          if (par.test(password) == false || checkLengthError) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "無効なパスワード",
              title: DIALOG_MESSAGES["00300010"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: messagePopup+".<br>次の4種類の文字を使う。<br>-英大文字(AからZ)<br>-英小文字(aからz)<br>-10進数の数字(0から9)<br>-記号(!、$、#、% など)"
            });
            return false;
          }
          break;
      }
      return true;
    },
    /**
     * バリデーションチェック.
     */
    validate(itemName) {
      // 項目ごとにチェックする内容を振り分ける
      switch (itemName) {
        // ユーザーID
        case "dispUserId": {
          const dispUserId = this.inputModel.dispUserId;
          // 必須チェック
          this.setIsNull({
            itemName: "dispUserId",
            result: !dispUserId
          });
          // 型チェック-半角英数記号
          this.setIsInvalid({
            itemName: "dispUserId",
            result: !this.regExp.half.test(dispUserId)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "dispUserId",
            result: dispUserId.length > 12
          });
          // 重複チェック
          this.checkDuplicationDispUserId(dispUserId).catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
            getErrorMessage('AccountEditView.vue','validate',error);
            //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
            if (error.response.status === 400) {
              // TODO APIで400とすべきところも200で返しているため、ここにはこない。
            }
          });
          break;
        }
        // 氏名カナ_姓
        case "lastNameKana": {
          const lastNameKana = this.inputModel.userLastNameKana;
          // 型チェック-カタカナ
          this.setIsInvalid({
            itemName: "lastNameKana",
            result: lastNameKana && !this.regExp.katakana.test(lastNameKana)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "lastNameKana",
            result: lastNameKana && lastNameKana.length > 40
          });
          break;
        }
        // 氏名カナ_名
        case "firstNameKana": {
          const firstNameKana = this.inputModel.userFirstNameKana;
          // 型チェック-カタカナ
          this.setIsInvalid({
            itemName: "firstNameKana",
            result: firstNameKana && !this.regExp.katakana.test(firstNameKana)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "firstNameKana",
            result: firstNameKana && firstNameKana.length > 40
          });
          break;
        }
        // 氏名_姓
        case "lastName": {
          const lastName = this.inputModel.userLastName;
          // 必須チェック
          this.setIsNull({
            itemName: "lastName",
            result: !lastName
          });
          // add 「氏名_姓」の「\」チェック 鄧シン start
          if (this.regExp.errorChar.test(lastName)) {
            this.setIsInvalid({
              itemName: "lastName",
              result: true
            });
          }else{
            this.setIsInvalid({
              itemName: "lastName",
              result: false
            });
          }
          // add 「氏名_姓」の「\」チェック 鄧シン end
          // 文字数チェック
          this.setIsOver({
            itemName: "lastName",
            result: lastName.length > 20
          });
          break;
        }
        // 氏名_名
        case "firstName": {
          const firstName = this.inputModel.userFirstName;
          // 必須チェック
          this.setIsNull({
            itemName: "firstName",
            result: !firstName
          });
          // add 「氏名_名」の「\」チェック 鄧シン start
          if (this.regExp.errorChar.test(firstName)) {
            this.setIsInvalid({
              itemName: "firstName",
              result: true
            });
          }else{
            this.setIsInvalid({
              itemName: "firstName",
              result: false
            });
          }
          // add 「氏名_名」の「\」チェック 鄧シン end
          // 文字数チェック
          this.setIsOver({
            itemName: "firstName",
            result: firstName.length > 20
          });
          break;
        }
        // 氏名英字_姓
        case "lastNameAlpha": {
          const lastNameAlpha = this.inputModel.userLastNameAlpha;
          // 型チェック
          this.setIsInvalid({
            itemName: "lastNameAlpha",
            result: lastNameAlpha && !this.regExp.alpha.test(lastNameAlpha)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "lastNameAlpha",
            result: lastNameAlpha && lastNameAlpha.length > 40
          });
          break;
        }
        // 氏名英字_名
        case "firstNameAlpha": {
          const firstNameAlpha = this.inputModel.userFirstNameAlpha;
          // 型チェック
          this.setIsInvalid({
            itemName: "firstNameAlpha",
            result: firstNameAlpha && !this.regExp.alpha.test(firstNameAlpha)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "firstNameAlpha",
            result: firstNameAlpha && firstNameAlpha.length > 40
          });
          break;
        }
        // メールアドレス1
        case "mailAddress1": {
          const mailAddress1 = this.inputModel.userEmailAddress1;
          // 型チェック
          this.setIsInvalid({
            itemName: "mailAddress1",
            result: mailAddress1 && !this.regExp.mailAddress.test(mailAddress1)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "mailAddress1",
            result: mailAddress1 && mailAddress1.length > 256
          });
          break;
        }
        // メールアドレス2
        case "mailAddress2": {
          const mailAddress2 = this.inputModel.userEmailAddress2;
          if (mailAddress2 === null || mailAddress2 === "") {
            this.setIsInvalid({
              itemName: "mailAddress2",
              result: false
            });
            this.setIsOver({
              itemName: "mailAddress2",
              result: false
            });
            break;
          }
          // 型チェック
          this.setIsInvalid({
            itemName: "mailAddress2",
            result: !this.regExp.mailAddress.test(mailAddress2)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "mailAddress2",
            result: mailAddress2.length > 256
          });
          break;
        }
        // 内線番号
        case "extensionNo": {
          const extensionNo = this.inputModel.extensionNo;
          if (extensionNo === null || extensionNo === "") {
            this.setIsInvalid({
              itemName: "extensionNo",
              result: false
            });
            this.setIsOver({
              itemName: "extensionNo",
              result: false
            });
            break;
          }
          // 型チェック
          this.setIsInvalid({
            itemName: "extensionNo",
            result: !this.regExp.numericAndHyphen.test(extensionNo)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "extensionNo",
            result: extensionNo.length > 25
          });
          break;
        }
        // 自宅番号
        case "homeNo": {
          const homeNo = this.inputModel.homeNo;
          if (homeNo === null || homeNo === "") {
            this.setIsInvalid({
              itemName: "homeNo",
              result: false
            });
            this.setIsOver({
              itemName: "homeNo",
              result: false
            });
            break;
          }
          // 型チェック
          this.setIsInvalid({
            itemName: "homeNo",
            result: !this.regExp.numericAndHyphen.test(homeNo)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "homeNo",
            result: homeNo.length > 25
          });
          break;
        }
        // 携帯番号
        case "mobilePhoneNo": {
          const mobilePhoneNo = this.inputModel.mobilePhoneNo;
          if (mobilePhoneNo === null || mobilePhoneNo === "") {
            this.setIsInvalid({
              itemName: "mobilePhoneNo",
              result: false
            });
            this.setIsOver({
              itemName: "mobilePhoneNo",
              result: false
            });
            break;
          }
          // 型チェック
          this.setIsInvalid({
            itemName: "mobilePhoneNo",
            result: !this.regExp.numericAndHyphen.test(mobilePhoneNo)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "mobilePhoneNo",
            result: mobilePhoneNo.length > 25
          });
          break;
        }
        // FAX
        case "faxNo": {
          const faxNo = this.inputModel.faxNo;
          if (faxNo === null || faxNo === "") {
            this.setIsInvalid({
              itemName: "faxNo",
              result: false
            });
            this.setIsOver({
              itemName: "faxNo",
              result: false
            });
            break;
          }
          // 型チェック
          this.setIsInvalid({
            itemName: "faxNo",
            result: !this.regExp.numericAndHyphen.test(faxNo)
          });
          // 文字数チェック
          this.setIsOver({
            itemName: "faxNo",
            result: faxNo.length > 25
          });
          break;
        }
        // 郵便暗号
        case "zipcd3": {
          const zipcd3 = this.inputModel.zipcd3;
          if (zipcd3 === null || zipcd3 === "") {
            this.setIsInvalid({
              itemName: "zipcd3",
              result: false
            });
            this.setIsOver({
              itemName: "zipcd3",
              result: false
            });
            break;
          }
          // 型チェック
          // 半角数字以外 or 0より小さい時、エラー
          let isInvalidZipcd3 = false;
          if (!this.regExp.numeric.test(zipcd3) || Number(zipcd3) < 0) {
            isInvalidZipcd3 = true;
          }
          this.setIsInvalid({
            itemName: "zipcd3",
            result: isInvalidZipcd3
          });
          // 文字数チェック(3文字以外はエラー)
          this.setIsOver({
            itemName: "zipcd3",
            result: zipcd3.length !== 3
          });
          break;
        }
        case "zipcd4": {
          const zipcd3 = this.inputModel.zipcd3;
          const zipcd4 = this.inputModel.zipcd4;
          if ((zipcd3 === null || zipcd3 === "") && (zipcd4 === null || zipcd4 === "")) {
            this.setIsInvalid({
              itemName: "zipcd4",
              result: false
            });
            this.setIsOver({
              itemName: "zipcd4",
              result: false
            });
            break;
          }
          // 型チェック
          // 半角数字以外 or 0より小さい時、エラー
          let isInvalidZipcd4 = false;
          if (!this.regExp.numeric.test(zipcd4) || Number(zipcd4) < 0) {
            isInvalidZipcd4 = true;
          }
          this.setIsInvalid({
            itemName: "zipcd4",
            result: isInvalidZipcd4
          });
          // 文字数チェック(4文字以外はエラー)
          this.setIsOver({
            itemName: "zipcd4",
            result: zipcd4.length !== 4
          });
          break;
        }
        // 住所
        case "address": {
          const address = this.inputModel.address;
          if (address === null || address === "") {
            this.setIsInvalid({
              itemName: "address",
              result: false
            });
            this.setIsOver({
              itemName: "address",
              result: false
            });
            break;
          }
          // add 「自宅住所(漢字)」の「\」チェック 鄧シン start
          if (this.regExp.errorChar.test(address)) {
            this.setIsInvalid({
              itemName: "address",
              result: true
            });
          }else{
            this.setIsInvalid({
              itemName: "address",
              result: false
            });
          }
          // add 「自宅住所(漢字)」の「\」チェック 鄧シン end
          // 文字数チェック
          this.setIsOver({
            itemName: "address",
            result: address.length > 512
          });
          break;
        }
        // 住所かな
        case "addressKana": {
          const addressKana = this.inputModel.addressKana;
          if (addressKana === null || addressKana === "") {
            this.setIsInvalid({
              itemName: "addressKana",
              result: false
            });
            this.setIsOver({
              itemName: "addressKana",
              result: false
            });
            break;
          }
          // add 「自宅住所(ふりがな)」の「\」チェック 鄧シン start
          if (this.regExp.errorChar.test(addressKana)) {
            this.setIsInvalid({
              itemName: "addressKana",
              result: true
            });
          }else{
            this.setIsInvalid({
              itemName: "addressKana",
              result: false
            });
          }
          // add 自宅住所(ふりがな)」の「\」チェック 鄧シン end
          // 文字数チェック
          this.setIsOver({
            itemName: "addressKana",
            result: addressKana.length > 512
          });
          break;
        }
        // 連携コード1
        case "inHospitalCd_1": {
          const inHospitalCd_1 = this.inputModel.inHospitalCd_1;
          if (inHospitalCd_1 === null || inHospitalCd_1 === "") {
            this.setIsInvalid({
              itemName: "inHospitalCd_1",
              result: false
            });
            this.setIsOver({
              itemName: "inHospitalCd_1",
              result: false
            });
            break;
          }
          // 文字数チェック
          this.setIsOver({
            itemName: "inHospitalCd_1",
            result: inHospitalCd_1.length > 20
          });
          break;
        }
        // 連携コード2
        case "inHospitalCd_2": {
          const inHospitalCd_2 = this.inputModel.inHospitalCd_2;
          if (inHospitalCd_2 === null || inHospitalCd_2 === "") {
            this.setIsInvalid({
              itemName: "inHospitalCd_2",
              result: false
            });
            this.setIsOver({
              itemName: "inHospitalCd_2",
              result: false
            });
            break;
          }
          // 文字数チェック
          this.setIsOver({
            itemName: "inHospitalCd_2",
            result: inHospitalCd_2.length > 20
          });
          break;
        }
        default:
          break;
      }
    },
    /**
     * ユーザーIDの重複チェック.
     */
    checkDuplicationDispUserId(val) {
      if (!val) {
        return Promise.resolve();
      }
      const userInfo = {
        userId: this.getStateUserAccountInfo.userId,
        dispUserId: val
      };
      return this.checkDuplication(userInfo);
    },
    /**
     * カード作成ボタン押下イベント処理.
     */
    async createCard() {
      // TODO 保存する内容は未確定
      const card = {
        type: "1",
        id: this.getStateUserAccountInfo.userId,
        name:
          this.getStateUserAccountInfo.userLastName +
          " " +
          this.getStateUserAccountInfo.userFirstName
      };
      this.setCard(card);
      if (this.getSocketIsConnected) {
        this.setLoadingScreenVisible(true);
        this.sendSocketMessage(
          `WRITE_STAFF_CARD-${this.facilityCd}-${card.id}`
        );
      } else {
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "保存失敗",
          // message: "カードの書き込みに失敗しました。"
          title: DIALOG_MESSAGES["00200103"].title,
          message: messageFormat(DIALOG_MESSAGES["00200103"].message)
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
      }
    },

    //ポリシーのパスワードを取得する
    async getPolicyPassword() {
      const pwdPolicyRes = await getMstFacilitySettingValue(this.facilityCd, PASSWORD_POLICY);
      const pwdPolicy = pwdPolicyRes.data;

      return pwdPolicy;
    },

    //パスワードの長さを取得する
    async getLengthPassword() {
      const pwdLengthRes = await getMstFacilitySettingValue(this.facilityCd, NUM_OF_PASSWORD);
      const pwdLength = pwdLengthRes.data;

      return pwdLength;
    },
    /**
     * 処理：入力された情報でアカウント情報登録(更新)
     */
    async registration() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // TODO：blurイベントでのチェック処理が、入力後にそのまま保存ボタンが押下された場合に間に合わないことがある為、暫定対応
      await new Promise(resolve => setTimeout(resolve, 1000));
      if (
        this.isValidationError
      ) {
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      //パスワードを認証する
      var policyPassword = await this.getPolicyPassword();
      var lengthPassword = await this.getLengthPassword();
      if (await this.checkFacilityPassword(policyPassword, lengthPassword, this.inputModel.userPassword, this.inputModel.userPasswordCurrent) == false) {
        this.setLoadingScreenVisible(false);
        return;
      }

      // パスワード利用可能チェック
      if (await this.checkIsAvailablePassword(this.userAccountInfo.userId, this.inputModel.userPassword, this.userAccountInfo.facilityCd) === false) {
        this.setLoadingScreenVisible(false);
        return;
      }

      let newSendData = {
        userId: this.inputModel.userId,
        dispUserId: this.inputModel.dispUserId,
        userPassword: this.inputModel.userPassword,
        userLastName: this.inputModel.userLastName,
        userFirstName: this.inputModel.userFirstName,
        userLastNameKana: this.inputModel.userLastNameKana,
        userFirstNameKana: this.inputModel.userFirstNameKana,
        userLastNameAlpha: this.inputModel.userLastNameAlpha,
        userFirstNameAlpha: this.inputModel.userFirstNameAlpha,
        userEmailAddress1: this.inputModel.userEmailAddress1,
        userEmailAddress2: this.inputModel.userEmailAddress2,
        extensionNo: this.inputModel.extensionNo,
        homeNo: this.inputModel.homeNo,
        mobilePhoneNo: this.inputModel.mobilePhoneNo,
        faxNo: this.inputModel.faxNo,
        zipcd3: this.inputModel.zipcd3,
        zipcd4: this.inputModel.zipcd4,
        address: this.inputModel.address,
        addressKana: this.inputModel.addressKana,
        jobCd: this.inputModel.jobCd,
        anesthesiologistLicenseNo : this.inputModel.anesthesiologistLicenseNo,
        inHospitalCd_1: this.inputModel.inHospitalCd_1,
        inHospitalCd_2: this.inputModel.inHospitalCd_2,
        facilityCd: this.inputModel.facilityCd,
        infoDispToAdmin: this.inputModel.infoDispToAdmin ? "1" : "0",
      }
      newSendData.canLoginFacilitiesList = this.inputModel.canLoginFacilities
      // 更新処理
      await this.registUserAccount(newSendData)
        .then(() => {
          (async () => {
            // アカウント情報の再読み込み
            await this.getUserAccountInfo();
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
            // 成功なので、アラート表示
            await this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "登録成功",
              // message: "アカウント情報が</br>正常に設定されました。"
              title: DIALOG_MESSAGES[12000289].title,
              message: messageFormat(DIALOG_MESSAGES[12000289].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            // 画面を閉じる
            this.hideModal();
          })();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('AccountEditView.vue','registration',error);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          if (error.response.status === 400) {
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
            // 失敗なので、アラート表示
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "登録失敗",
              // message: "登録処理に失敗しました。"
              title: DIALOG_MESSAGES[12000290].title,
              message: messageFormat(DIALOG_MESSAGES[12000290].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    /**
     * キャンセル処理
     */
    cancel() {
      // 変更がある場合はメッセージを表示
      if (this.isChanged) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: answer => {
            if (answer == 1) {
              //OK
              this.hideModal();
            }
          }
        });
      } else {
        this.hideModal();
      }
    },

    /***
     * 20260108 liyanze-z add  about facilities
    */
    //show or hidden  add 施舍
    clickChangeAddView(){
      //false - hidden
      if(this.isOpenAddFlag){
        this.showAddFrom = [];
        this.addForm = {
          facilityHash:'',
          //facilityName:'',
          username:'',
          password:'',
        };
        //2要素認証  hidden
        this.closeSecondOtpFN()
      }else{
        this.showAddFrom.push(this.addForm)
      }
      this.isOpenAddFlag = !this.isOpenAddFlag;
    },
    //!=null
    allFieldsNotEmpty(arr) {
      return arr.every(obj =>
        Object.values(obj).every(
          value => value !== null && value !== undefined && value !== ''&& value !== ' '
        )
      );
    },
    //!=""
    hasMultipleSpaces(obj) {
      return Object.values(obj).some(v =>
        typeof v === 'string' && /\s{2,}/.test(v)
      );
    },
    //ishave
    eachAllRetrieve(obj){
      let tArr = this.inputModel.canLoginFacilities;
      let exists = tArr.some(item =>
        item.facilityHash === obj.facilityHash && item.username === obj.username
      )
      return exists
    },
    //認証 newadd
    async verifyFN(){
      
      let tObj = this.showAddFrom[0];
      //!=""
      let isMoreSpace = this.hasMultipleSpaces(tObj);
      if(isMoreSpace){
        //message
        this.spacesErrorAlert()
        return
      }
      
      //already
      let isHaveFlag = false;
      isHaveFlag = this.eachAllRetrieve(tObj);
      if(isHaveFlag){
        this.$ons.notification.alert({
          title: '',
          message: messageFormat('現在施設はすでに登録されております')
        });
        return
      }
      /**
       * 3つの状況
       * 認証合格 add
       * 
       * 認証に失敗しました again
       * 
       * 2要素
       * 
       */
      this.isRequest = true;
      let sendData = {
        userId:tObj.username,
        password:tObj.password,
        facilityCd:tObj.facilityHash,
      }
      await getInfoRetrieve(sendData).then(res => {
        let tRes = res.data;
        let msgText = '';
        let flagSuccess = false;
        //true-認証合格 false-認証に失敗
        if(tRes&&tRes.succeed == true){
          //null-- ok
          if(tRes.secretKey == null){
            msgText = tRes.errMsg?tRes.errMsg:'アカウント情報が正常に認証されました'
            flagSuccess = true;
            let tName = tRes.facilityName
            //add 
            this.addAlreadyVerfyOK("0",tName)
          }else{
            //get key
            this.secretKey = tRes.secretKey
            //show 2要素
            this.isNeedSecondFlag = true;
            if(tRes.errMsg){
              msgText = tRes.errMsg
              // msgText = tRes.errMsg?tRes.errMsg:"ユーザー[" + tObj.username +"]の2要素認証情報が変更されました。再認証して下さい。"
            }else{
              this.isRequest = false;
              return
            }
          }
        }else{
          msgText = tRes.errMsg?tRes.errMsg:'認証に失敗しました。認証情報を確認して下さい。'
        }
        //message
        this.$ons.notification.alert({
          title: flagSuccess?'認証成功':'認証エラー',
          message: messageFormat(msgText)
        });
        this.isRequest = false;
      }).catch(err =>{
        console.log(err)
        this.isRequest = false;
        this.$ons.notification.alert({
          title: '認証エラー',
          message: messageFormat('認証に失敗しました。認証情報を確認して下さい。')
        });
      })
      
    },
    //2要素 click
    async secondVerifyFN(){
      //!=""
      let tObj = {sendKey:this.secondOtpKey}
      let isMoreSpace = this.hasMultipleSpaces(tObj);
      if(isMoreSpace){
        //message
        this.spacesErrorAlert()
        return
      }
      /**
       * 2つの状況
       * 
       * 認証合格 add
       * 
       * 認証に失敗しました again
       * 
       */

      let sendData = {
        opt:this.secondOtpKey,
        secretKey:this.secretKey,
        facilityHash:this.showAddFrom[0].facilityHash
      }
      let msgText = '';
      let flagSuccess = false;
      await getInfoOPT(sendData).then(res => {
        let tRes = res.data;
        if(tRes.optSuccess&&tRes.optSuccess == true){
          flagSuccess = true;
          msgText = '2要素認証が完了しました'
          let tName = tRes.facilityName
          this.addAlreadyVerfyOK("1",tName)
          this.closeSecondOtpFN();
        }else{
          msgText = '2要素認証に失敗しました'
        }
        //message
        this.$ons.notification.alert({
          title: flagSuccess?'認証成功':'認証エラー',
          message: messageFormat(msgText)
        });
        
      }).catch(err => {
        this.$ons.notification.alert({
          title: '認証エラー',
          message: messageFormat('認証に失敗しました。認証情報を確認して下さい。')
        });
      })
    },
    //2要素 key hidden
    closeSecondOtpFN(){
      this.isNeedSecondFlag = false;
      this.secondOtpKey = '';
      this.secretKey = '';
    },
    //2要素 again
    async againSecondVerifyFN(item){
      //!=""
      let tObj = {sendKey:this.secondAgainOtpKey}
      let isMoreSpace = this.hasMultipleSpaces(tObj);
      if(isMoreSpace){
        //message
        this.spacesErrorAlert()
        return
      }

      let sendData = {
        opt:this.secondAgainOtpKey,
        secretKey:item.secretKey,
        facilityHash:item.facilityHash
      }
      let msgText = '';
      let flagSuccess = false;
      await getInfoOPT(sendData).then(res => {
        let tRes = res.data;
        if(tRes.optSuccess&&tRes.optSuccess == true){
          flagSuccess = true;
          msgText = '2要素認証が完了しました'
          //change status 
          item.optStatus = 1;
          
          //hidden
          item.optAuth = false;
          item.isOpenAgainAdd = false;
          this.secondAgainOtpKey  = '';
          

          //変更!
          this.facilitiesListChange();
        }else{
          msgText = '2要素認証に失敗しました'
        }
        //message
        this.$ons.notification.alert({
          title: flagSuccess?'認証成功':'認証エラー',
          message: messageFormat(msgText)
        });
        
      }).catch(err => {
        this.$ons.notification.alert({
          title: '認証エラー',
          message: messageFormat('認証に失敗しました。認証情報を確認して下さい。')
        });
      })

      // console.log(item)
      // this.secondVerifyFN = '';
    },
    againSecondClose(item){
      item.isOpenAgainAdd = false;
      this.$forceUpdate()
    },
    //spaces ==""
    spacesErrorAlert(){
      this.$ons.notification.alert({
        title: '',
        message: messageFormat('非標準')
      });
    },
    //add list
    addAlreadyVerfyOK(type,name){
      let tObj = this.showAddFrom[0];
      //変更 status = 0
      tObj.optStatus = type;

      //施しの名称
      if(name)tObj.facilityName = name;
      
      //消除パスワード
      delete tObj['password'];
      //unshift
      this.inputModel.canLoginFacilities.unshift(tObj);

      //变更?
      this.facilitiesListChange();
      //success hidden
      this.clickChangeAddView()

    },
    //消除選択済み
    deleteThatFacilitie(index){
       this.$ons.notification.confirm({
        // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
        // // title: "サインアウト",
        // title: DIALOG_MESSAGES[13000001].title,
        // // message: "サインアウトします。<br>よろしいですか？",
        // message: messageFormat(DIALOG_MESSAGES[13000001].message),
        title: '削除確認',
        message: '施設情報を削除しますが、よろしいでしょうか？',
        callback: answer => {
            if (answer == 1) {
              this.inputModel.canLoginFacilities.splice(index, 1);
              //削除後の変更
              this.facilitiesListChange()
            }
        }
       })
    },
    /***liyanze-z  変更 ? */
    facilitiesListChange(){
      let dataA = this.copyData;
      let dataB = this.inputModel;
      /**
       * true 変更  
       * false 変更なし 
       */
      let tFlag = false;  
      if(dataA.canLoginFacilities&&dataB.canLoginFacilities){
        function deepEqual(a, b) {
          return JSON.stringify(a) === JSON.stringify(b);
        }
        if(dataA.canLoginFacilities,length==dataB.canLoginFacilities,length){
          tFlag = !deepEqual(dataA.canLoginFacilities,dataB.canLoginFacilities)
        }else{
          tFlag =  true
        }
      }
      this.facilitiesChange = tFlag
    },
    //2要素 again
    openListAdd(item){
      //消除
      this.secondAgainOtpKey = '';
      //inputModel.canLoginFacilities
      for (let z = 0; z < this.inputModel.canLoginFacilities.length; z++) {
        this.inputModel.canLoginFacilities[z].isOpenAgainAdd = false
      }
      item.isOpenAgainAdd = true;
      this.$forceUpdate()
    },


    /**
     * 吹き出し表示処理
     */
    showPopOver(event, message) {
      var pop = document.getElementById("popOverMessage");
      pop.innerText = message;
      this.userMenuPopoverTarget = event;
      this.userMenuPopoverVisible = true;
    },
    /**
     * 権限のチェックボックスを押下した際の処理をｷｬﾝｾﾙする
     */
    onChangeAuthority(e) {
      e.target.checked = !e.target.checked;
    },
    /**
     * zipcd を zipcd3、zipcd4に展開してバリデーションする
     */
    chkZipcd(zipcd) {
      if (zipcd !== null && zipcd.length >= 4) {
        this.inputModel.zipcd3 = zipcd.substr(0, 3);
        this.inputModel.zipcd4 = zipcd.substr(3);
      } else {
        this.inputModel.zipcd3 = zipcd;
        this.inputModel.zipcd4 = "";
      }
      this.validate("zipcd3");
      this.validate("zipcd4");
    },
    //QRコードを有効にする
    async EnableQRcode(){
      this.setLoadingScreenVisible(true);
      let dispUserId = this.getStateUserAccountInfo.dispUserId;

      let facilityValue = this.getStateUserAccountInfo.facilityCd
      const data = {
        dispUserId : dispUserId,
        facilityCd : facilityValue
      }
      // memo MstUserStore: ユーザーOTPの生成
      await this.sendRequestCreateMstUserOTP(data)

      // memo this.userOTP は MstuserStore.getUserOTP を返す
      this.inputSecretKey = this.userOTP.secretKey;
      this.QRcodeImg =  "data:image/jpeg;base64," + this.userOTP.Qrcode;
      this.isMadeQrCode = true;
      this.setLoadingScreenVisible(false);
      //  add #6449 アカウント情報で、2要素認証未登録の状態で秘密鍵作成ボタンを押下した際、画面最下部へとスクロールさせる 付 start
      this.$nextTick(() => {
        this.$children[0].scrollToBottom()
      })
      //  add #6449 アカウント情報で、2要素認証未登録の状態で秘密鍵作成ボタンを押下した際、画面最下部へとスクロールさせる 付 end
    },
    //値サインインを確認
    checkValueSignIn(){
      if(this.valueSignIn&&this.valueSignIn != 0){
        return true;
      }else{
        return false;
      }
    },
    //秘密鍵を更新する
    async updateSecretKey(){
      // 処理しないパターン
      if (
        this.oneTimePassword === "" ||                    // 認証コード未入力
        !this.isMadeQrCode ||                             // 画面上で秘密鍵生成前
        this.isRegistedQrCode                             // 秘密鍵登録済
      ) {
        return;
      }

       this.setLoadingScreenVisible(true);
      let userId = this.getStateUserAccountInfo.userId
      const checkdata = {
        secretKey : this.inputSecretKey,
        otp : this.oneTimePassword
      }
      const response = await this.sendRequestCheckOtp(checkdata);
      // 認証コードチェック失敗
      if (response !== 0) {
        this.setLoadingScreenVisible(false);
        EventBus.$emit("refresh");
        this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "認証エラー",
            // message: "認証コードに誤りがあります。設定を見直し、新しい認証コードで登録してください。"
            title: DIALOG_MESSAGES[12000283].title,
            message: messageFormat(DIALOG_MESSAGES[12000283].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        return;
      }
      const data = {
        userId : userId,
        secretKey : this.inputSecretKey
      }
      await this.sendRequestUpdateSecretKey(data)
      .then(async ()=>{
        await this.getUserAccountInfo();
        const user = {
          userId : this.getStateUserAccountInfo.userId,
          isSetQrCode : 1
        }
        await this.sendRequestUpdateIsSetQrCode(user);

        // 登録後の再読み込みとワンタイムパスワードのクリア
        await this.getUserAccountInfo();
        this.oneTimePassword = "";

        this.setLoadingScreenVisible(false);
        EventBus.$emit("refresh");
        this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "2要素認証を有効にしました。"
            title: DIALOG_MESSAGES[12000284].title,
            message: messageFormat(DIALOG_MESSAGES[12000284].message)
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
      })
    },
    //秘密鍵を削除する
    async deleteKey(){
      const userId = this.getStateUserAccountInfo.userId;
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "!!注意!!",
        title: DIALOG_MESSAGES[13000158].title,
        // message: "秘密鍵を削除すると二度と戻すことはできません。削除しますか？",
        message: messageFormat(DIALOG_MESSAGES[13000158].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            const user = {
                userId,
                isSetQrCode : 0
            }
            await this.sendRequestUpdateIsSetQrCode(user);
            const response = await this.sendRequestDeleteSecretKey(userId);
            if(this.valueSignIn === 2){
                let dispUserId = this.getStateUserAccountInfo.dispUserId;
                let facilityValue = this.getStateUserAccountInfo.facilityCd
                const data1 = {
                  dispUserId : dispUserId,
                  facilityCd : facilityValue
                }
                await this.sendRequestCreateMstUserOTP(data1)
                const data2 = {
                  userId : userId,
                  secretKey : this.userOTP.secretKey
                }
                await this.sendRequestUpdateSecretKey(data2)
            }
            // 登録に成功している場合、再読み込みとセットした内容のクリア
            if (response === 0) {
              await this.getUserAccountInfo();
              this.QRcodeImg =  "";
              this.inputSecretKey = "";
              this.oneTimePassword = "";
              this.isMadeQrCode = false;
            }
          }
        }
      });
    },
    reconnectSocket() {
      const param = this;
      this.socketInterval = setInterval(function() {
        param.connect();
        clearInterval(this.socketInterval);
      }, 10000);
    },
    /**
     * パスワード表示非表示切り替え
     * @param {object} event イベント
     */
    clickEyeIcon(event){
      changeShowPassword(event);
    }
  },
  async created() {
    // 端末判別
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.isAndroid = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.isIOS = true;
    }

    // mod FNSI-4200ポートを使用している 孫 start
    //if (!this.getSocketIsConnected) {
    //  this.connect();
    if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
      // card appのwebsokcet以外場合、接続したサービスを閉じました
      if (this.getSocketIsConnected) {
        this.close();
        await SleepNSeconds(100);
      }

      // 遅延のミリ秒(millisecond)
      let delayMillisecond = 1000;

      // localStorageのportを利用する
      let defaultPort = localStorage.getItem("CARD_APP_PORT");
      // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 start
      if(!/^\d+$/.test(defaultPort)){
        localStorage.removeItem("CARD_APP_PORT");
        defaultPort = null;
      }
      // add 9511 FNSiカードアプリが一方のブラウザとしかつながらない。　吉 end
      if (null !== defaultPort) {
        // localStorageがあり場合、接続を実施する
        this.init({ port: defaultPort, facilityCd: "" });
        this.connect();

        // Nミリ秒を待つ
        await SleepNSeconds(delayMillisecond);
      }

      // 接続確認実施
      // APP接続しません、または、カードリーダーが無し
      if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
        // 「カードアプリポート管理」からportを取得する
        let facilityCd = this.facilityCd;
        let cardPorts = await ApiHelper.get(`${uriGetCardAppPort}/${facilityCd}`).catch(() => {
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('AccountEditView.vue','created','カードアプリポート管理から、ポートを取得しません');
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
          throw new Error("カードアプリポート管理から、ポートを取得しません。");
        });

        // portsをループする
        let portList = new Array();
        if (cardPorts.data.toString().indexOf(",") == -1) {
           portList[0] = cardPorts.data.toString();
        } else {
           portList = cardPorts.data.toString().split(",");
        }
        for(let i = 0; i < portList.length; i++) {
          // APP接続しません、または、カードリーダーが無し
          if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
            // card appのwebsokcet以外場合、接続したサービスを閉じました
            if (this.getSocketIsConnected) {
              this.close();
              await SleepNSeconds(100);
            }

            // 接続を実施する
            this.init({ port: portList[i], facilityCd: "" });
            this.connect();

            // Nミリ秒を待つ
            await SleepNSeconds(delayMillisecond);
          }
        }
      }
      // mod FNSI-4200ポートを使用している 孫 end
    } else {
      this.isCardDeviceConnected = this.getCardDeviceStatus
    }
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    await this.getUserAccountInfo();
    // liyanze-z add
    this.copyData = JSON.parse(JSON.stringify(this.getStateUserAccountInfo))
    // inputModelにstateの値をコピー
    this.inputModel = {
      userId: this.getStateUserAccountInfo.userId,
      dispUserId: this.getStateUserAccountInfo.dispUserId,
      userType: this.getStateUserAccountInfo.userType,
      administrator: this.getStateUserAccountInfo.administrator,
      canLoginFacilities: this.getStateUserAccountInfo.canLoginFacilities,
      facilityCd: this.getStateUserAccountInfo.facilityCd,
      userLastName: this.getStateUserAccountInfo.userLastName,
      userFirstName: this.getStateUserAccountInfo.userFirstName,
      userLastNameKana: this.getStateUserAccountInfo.userLastNameKana,
      userFirstNameKana: this.getStateUserAccountInfo.userFirstNameKana,
      userLastNameAlpha: this.getStateUserAccountInfo.userLastNameAlpha,
      userFirstNameAlpha: this.getStateUserAccountInfo.userFirstNameAlpha,
      userEmailAddress1: this.getStateUserAccountInfo.userEmailAddress1,
      userEmailAddress2: this.getStateUserAccountInfo.userEmailAddress2,
      extensionNo: this.getStateUserAccountInfo.extensionNo,
      homeNo: this.getStateUserAccountInfo.homeNo,
      mobilePhoneNo: this.getStateUserAccountInfo.mobilePhoneNo,
      faxNo: this.getStateUserAccountInfo.faxNo,
      zipcd:
      (this.getStateUserAccountInfo.zipcd3 !== null ? this.getStateUserAccountInfo.zipcd3 : "") +
      (this.getStateUserAccountInfo.zipcd4 !== null ? this.getStateUserAccountInfo.zipcd4 : ""),
      zipcd3: this.getStateUserAccountInfo.zipcd3,
      zipcd4: this.getStateUserAccountInfo.zipcd4,
      address: this.getStateUserAccountInfo.address,
      addressKana: this.getStateUserAccountInfo.addressKana,
      jobCd: this.getStateUserAccountInfo.jobCd,
      anesthesiologistLicenseNo : this.getStateUserAccountInfo.anesthesiologistLicenseNo,
      inHospitalCd_1: this.getStateUserAccountInfo.inHospitalCd_1,
      inHospitalCd_2: this.getStateUserAccountInfo.inHospitalCd_2,
      infoDispToAdmin: this.getStateUserAccountInfo.infoDispToAdmin  === "1" ? true : false
    };
    //liyanze-z add key
    for (let z = 0; z < this.inputModel.canLoginFacilities.length; z++) {
      this.inputModel.canLoginFacilities[z].isOpenAgainAdd = false
    }

    this.resetValidationResults();

    this.checkedAuthority = this.getStateUserAccountInfo.userSettings.authorized_authorities;

    // 日機装株式会社以外は表示しません
    if(this.facilityCd != "nkknkk"){
      this.editAuthList = this.editAuthList.filter(item => item.label !== "祝日設定")
    }

    // カード情報クリア
    this.clearCard();

    let listDoctor = await this.getDoctorsAtFacility(this.facilityCd);
    const user = listDoctor.data.find(doctor => doctor.user_id == this.getStateUserAccountInfo.userId);
      if (user) {
        this.isDoctor = true
      }
      // add 性能改善メモリ不足 shan start
      // EventBus.$off("selectPatInfoAddress")
      // add 性能改善メモリ不足 shan end
    // 住所検索受取(都度モーダルごと破棄される為、EventBus.$offは不要)
    EventBus.$on("selectPatInfoAddress", event => {
      if (!this.mapVisible) return;
      // zipcdの取得とバリデーション
      this.inputModel.zipcd = event.zipCd;
      this.chkZipcd(event.zipCd);
      // add FNSI-画面の「郵便番号」を表示する 鄧シン start
      // del FNSI-画面の「郵便番号」を表示する 関 start
      // this.inputModel.zipcd.initValue = event.zipCd;
      // del FNSI-画面の「郵便番号」を表示する 関 end
      // add FNSI-画面の「郵便番号」を表示する 鄧シン end
      // 住所の取得とバリデーション
      this.inputModel.address = event.address;
      this.validate("address");
      this.mapVisible = false;
    });
    //値の取得ログイン
    this.sendRequestGetValueSignInByFacilityCd(this.getStateUserAccountInfo.facilityCd);
    //  del #6449 アカウント情報で、2要素認証未登録の状態で秘密鍵作成ボタンを押下した際、画面最下部へとスクロールさせる dou start
    //  add #6449 アカウント情報で、2要素認証未登録の状態で秘密鍵作成ボタンを押下した際、画面最下部へとスクロールさせる 付 start
    // this.$nextTick(() => {
    //   if (!this.getStateUserAccountInfo.isSetQrCode) {
    //     this.$children[0].scrollToBottom()
    //   }
    // })
    //  add #6449 アカウント情報で、2要素認証未登録の状態で秘密鍵作成ボタンを押下した際、画面最下部へとスクロールさせる 付 end
    //  del #6449 アカウント情報で、2要素認証未登録の状態で秘密鍵作成ボタンを押下した際、画面最下部へとスクロールさせる dou end
    // add FNSI-4200ポートを使用している 孫 start
    function SleepNSeconds(num) {
        return new Promise((resolve) => {
            setTimeout(() => {
              resolve(1*num);
            }, num);
        } );
    }
    // add FNSI-4200ポートを使用している 孫 end
  },
  mounted() {
    // パスワード入力時にパスワード(確認)のバリデーションが通るようにするため
    this.$validator.validateAll().catch((error) => {
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
      getErrorMessage('AccountEditView.vue','mounted',error);
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
    });
  },
  beforeDestroy() {
    EventBus.$off("selectPatInfoAddress")
    clearInterval(this.socketInterval);
  },
  watch: {
    getSocketIsConnected(value) {
      this.isCardDeviceConnected = false;
      if (!value === true) {
        // 再接続
        this.reconnectSocket();
      } else {
        clearInterval(this.socketInterval);
      }
    },
    getSocketMessages(value) {
      if (value == null) return;
      const splitMsg = value.split("\t");
      if (splitMsg.length > 1) {
        if (splitMsg[0] == "CARD_CLIENT") {
          switch (splitMsg[1]) {
            case "CARD_WRITE_STATUS":
              this.setLoadingScreenVisible(false);
              if (JSON.parse(splitMsg[2].toLowerCase()) == true) {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存成功",
                  // message: "カード情報が</br>保存されました。"
                  title: DIALOG_MESSAGES[12000291].title,
                  message: messageFormat(DIALOG_MESSAGES[12000291].message)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              } else {
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "保存失敗",
                  // message: "カードの書き込みに失敗しました。"
                  title: DIALOG_MESSAGES["00200103"].title,
                  message: messageFormat(DIALOG_MESSAGES['00200103'].message)
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                });
              }
              this.clearSocketMessage();
              break;
          }
        }
      }
    },
    getCardDeviceStatus(value) {
      this.isCardDeviceConnected = value;
    },
    hasApiError() {
      this.alert();
    },
    showAddFrom: {
      handler(newVal) {
        if(newVal.length==0){
          this.isCanVerify = true
        }else{
          let  isHasEmptyName = this.allFieldsNotEmpty(newVal)
          isHasEmptyName?this.isCanVerify=false:this.isCanVerify=true
        }
      },
      deep: true
    }
  }
};
</script>

<style scoped>
select {
  border: 0;
  padding: 0;
  border: solid 1px #ccc;
  margin: 0;
  width: 100%;
  -webkit-border-radius: 5px;
  -moz-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  -moz-border-radius: 5px;
  -webkit-box-shadow: inset 0 0 4px rgba(0, 0, 0, 0.2);
  border-radius: 3px;
  box-shadow: inner 0 0 4px rgba(0, 0, 0, 0.2);
}
/* add FNSI-画面デザイン一覧画面対応 江 start */
.button-select{
  background-color: #4291B9!important;
  color: #ffffff!important;
  border-bottom: solid 3px #4974a0!important;
  background-image: none!important;
}
.button-select[disabled]{
  background-color: #dddddd!important;
  color: #C1C1C1!important;
  background-image: none!important;
}
.btn-save{
  background-color: #1a71cc!important;
  color: #ffffff!important;
  background-image: none!important;
}
.btn-save[disabled]{
  background-color: #dddddd!important;
  color: #C1C1C1!important;
  background-image: none!important;
}
.btn-cancel{
  background-color: #656a73!important;
  color: #ffffff!important;
  background-image: none!important;
}
/* add FNSI-画面デザイン一覧画面対応 江 end */
.h1 {
  margin: 0;
}
p {
  margin: 0;
}
.required {
  margin: 0px 0px 15px 0px;
}
.table-userInfo {
  width: 100%;
  table-layout: fixed;
  border-collapse: separate;
  border-spacing: 5px 10px;
  margin: -30px 0px 0px 0px;
}
.title {
  width: 7em;
}
/**
   * 切替ボタン.
   */
.btn-switch {
  display: inline;
  text-align: left;
}
/* セレクトボックスのスタイル定義 */
.selectbox {
  height: 2em;
}
.userId {
  width: 100%;
  margin-right: 5px;
}
/* 横スクロールの禁止とiPhone(文字サイズ特大)のスクロール有効化 */
.scroll-adjust {
    overflow-x: hidden;
    overflow-y: scroll;
}

/* 2要素認証のメッセージ表示、ボタン */
.mfa-container {
  display: flex;
  align-items: center;
}
.mfa-message {
  width: fit-content;
  margin: 10px;
}
.mfa-button {
  width: fit-content;
}
.font-adjust-xl {
  font-size: 0.9em;
}
#bgQRcode{
  width: 250px;
  height: 200px;
  border: 1px solid red;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}
.QRcodeInactive{
  display: none;
}
.QRcodeActive{
  display: block;
}
.ButtonInactive{
  display: none;
}
.ButtonActive{
  display: block;
}
.list-header {
  font-size: unset;
  display: flex;
  align-items: center;
}
.popover-message {
  margin: 10px;
}

/* FNSI-修正 3849 対応 xiebzh add start */
.faQuestionInactive{
  display: none;
}
.faQuestionActive{
  display: block;
}
/* FNSI-修正 3849 対応 xiebzh add end */

.account-edit-textarea {
  width: 100%;
  background-color: #F7F7F7;
}

/* ntss.css の .custom-textarea:disabled と競合する為、個別定義 */
td textarea:focus {
  border-style: inset;
  border-color: unset;
}

/*** 20260105 施舍 定義 liyanze-z  start*/
.facilitiesNav{
  position: relative;
}
.facilitiesNav >>> .card-header-button-area{
  position: absolute;
  right:0;
  top:0;
}
.facilitiesNav >>> .card-header-button{
  margin-left:12px;
}

.facilitiesNav >>> .btn-text{
  color:#ffffff;
  margin-left:12px;
  position: relative;
  top:-8px;
  left:-5px;
}

.topBtnView{
  width:100%;
  text-align: right;
  box-sizing: border-box;
}
.cancelBtn,.addBtn{
  width:6em;
  height:30px;
}
.cancelBtn{
  margin-right:16px;
}
.addFacilitiesView{
  width:100%;
  overflow: hidden;
}
.showAllFacilitiesView{
  width:100%;
  overflow: hidden;
  margin-top:20px;
}
.facilitiesListView{
  width:100%;
  min-height:50px;
  position: relative;
  box-sizing: border-box;
  padding-left:16px;
}
.facilitiesListOpenAddView{
  padding-bottom:10px;
}
.facilitiesListView > .facilitiesListText{
  line-height: 50px;
}
.facilitiesListOpenAddView > ons-row{
  width:calc(100% - 60px)!important;
}
.nothaveList{
  text-align: center;
}
.mon-table-head-one{
  padding: var(--list-header-padding);
  color: #ffffff;
  background-color: var(--ntss-list-header-background-color);
  background-image: -webkit-linear-gradient(rgba(255, 255, 255, .3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, .1) 100%);
  background-image: linear-gradient(rgba(255, 255, 255, .3) 0%, transparent 50%, transparent 50%, rgba(0, 0, 0, .1) 100%);
  box-shadow: 0 2px 2px 0 rgba(255, 255, 255, .2) inset, 0 2px 20px 0 rgba(255, 255, 255, .5) inset, 0 -2px 2px 0 rgba(0, 0, 0, .1);
}

.card-table {
    width: 98%;
    /* border: 1px solid; */
    border-color: #555555;
    border-top-width: thin;
    margin: 0px 1% 0px 1%;
    -webkit-box-sizing: border-box;
    box-sizing: border-box;
    position: relative;
    box-sizing: border-box;
    padding-right:30px;
}

.borderView{
  width:98%;
  height:1px;
  background:#999999;
  box-sizing: border-box;
  margin:10px auto;
}
.borderView1{
  width:100%;
  height:1px;
  background:#999999;
  box-sizing: border-box;
}
.button-delete{
    position: absolute;
    top: 0;
    right: 0;
    height: 100%;
    z-index: 1;
}

.opBtnView{
  display: flex;
  -webkit-box-pack: justify;
  -ms-flex-pack: justify;
  justify-content: flex-end;
  -ms-flex-wrap: wrap;
  flex-wrap: wrap;
}
.opyCancelBtn{
  width:6em;
  margin-top:12px;
  color: #ffffff !important;
  background-color: var(--btn2-cancel-color);
  background-image: linear-gradient(var(--btn2-cancel-color), var(--btn2-cancel-color)) !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
  margin-right:16px;
}

.secondVerifyBtn{
  margin-top:12px;
  width:6em;
}
.secondText{
  margin-top:12px;
}
button:not([class^='pika']), label.toggle, .k-button, .btn-ntss-custom {
    border-radius: 3px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
}
.ntss-btn-outset {
    border-style: outset;
    border-image-repeat: stretch;
    border-color: unset;
}
.item-title{
    width: 16%;
}

.secondView{
  box-sizing: border-box;
  padding-left:18px;
  padding-right:48px;
  margin-top:12px;
}

/*** 20260105  施舍 定義 liyanze-z  end*/


@media print {
  /** 住所検索印刷時は親を消す */
  .modal-mask:has(+ .modal-mask .modal-contents-custom) {
    display: none;
  }
}
</style>
