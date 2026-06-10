<template>
    <div>
        <div class="popover-label">
            <div class="pat-info-card">
                <div class="card-header color-header">
                    <label class="card-name">施設切替</label>
                </div>
            </div>
            <div class="showFacilities">
                <div v-for="(item,index) in facilitiesList " :key="index" class="facilitiesListBox" :class="item.showButton == false?'facilitiesNeedHover':''">
                    <div class="tooltipDiv">{{ item.massage }}</div>
                    <div
                        :ref="'list' + index"
                        class="leftText"
                        :class="item.showButton == false?'listNot':''"
                        :data-list-index="index"
                        @click="facilitiesListClick(item)">
                        <p>
                            <span>{{ item.facilityName + ' • ' + item.username }}</span>
                            <span class="warningSpan" v-if="item.showButton== false"> ！</span>
                        </p>
                    </div>
                </div>
                <div class="notHave" v-if="facilitiesList.length==0&&isRequest==false">
                    データなし
                </div>
            </div>
        </div>
    </div>
</template>
<script>

import { mapActions, mapGetters, mapMutations } from "vuex";
import { getRouterName, getInitialRouterName,getNameA } from "@/router/routing-helper";
import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
import {
  createCalendarContentsForMasterLayout,
  createCalendarContentsForCalendar,
  getCalendarLayoutData,
  getFacilityCalendarMasterLayout,
  getPatList,
  formattedDate,
  getDateRangeForSearchCondition
} from "@/components/facility-calendar/Functions.js";

import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { PATIENT_SEARCH } from "@/constants/defaultSettingConstants";

import { getCanLoginFacilities } from "@/apis/facilities-can-login.js";

import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";
import { DATE_CHOICES,RAD_REQUEST } from "@/constants/defaultSettingConstants";

import {
  sendRequestRegistSignin,
} from "@/apis/User";

// add 2020-09-25 FNSI-4200ポートを使用している 孫 start
const uriGetCardAppPort = `/card_state/get_card_app_ports`;

import { ApiHelper } from "@/apis/AxiosHelper";
import { webPushSubscribe, saveNotificationList } from "@/functions/WebPushFunctions";
import PatGroup from "@/apis/pat-group";
import moment from "moment";
import { deepCopy } from "@/functions/common/CommonFunctions";

import { createTerminalUniqueString } from "@/functions/SigninFunction";

import { SESSION_STORAGE_KEY, SESSION_STORAGE_VALUE } from "@/constants/sessionStorageConstants";


/* テーマ定義 */
const THEME_WHITE = 0;


export default{
    data(){
        return{
            //list
            facilitiesList:[],
            nowFacilityHash:'',
            isRequest:false,
            //证明
            proof:null,
            //当前点击的参数
            checkItem:{},
            // ベッドグループマスタ
            mstBedGroup: null,
            // 患者グループマスタ
            patGroups: null,
            // アラート表示中
            isAlerting: false,
            // FNSI-修正 4082対応 xiebzh add start
            isDifferentFacailityFlg: false,
            // FNSI-修正 4082対応 xiebzh add end
            isCardDeviceConnected: false,
            socketInterval:null,
            createOTPData: null,
            hasAuthError: false,
            //ログインの成功を確認する
            isLoginSuccess: false,
            //QRコード画像を確認
            hasQRCodeImg : false,
        }
    },
    created(){
        //获取设备列表
        this.getFacilitiesList();
    },
    computed:{
        ...mapGetters("account-edit", ["getStateUserAccountInfo", "getFontSize", "getInitialFunction","getDefaultSetting"]),
        ...mapGetters("app", ["hasApiError", "getKey"]),
        ...mapGetters("notification", ["getIsRegisteredNotification"]),
        ...mapGetters("user", ["getFacilityCd", "getResponse", "getSystemUseSetting", "getOtpFailureCnt"]),
        ...mapGetters("websocket-card", ["getSocketIsConnected", "getSocketMessages", "getSocketIsError", "getCardDeviceStatus"]),
    },
    watch:{
         getSocketIsConnected(value) {
            this.isCardDeviceConnected = false;
            if (!value === true) {
                // 再接続
                this.reconnectSocket();
            } else {
                clearInterval(this.socketInterval);
            }
        },
    },
    methods:{
        ...mapActions("account-edit", ["getUserAccountInfoSignIn","getUserAccountInfoSignInCheck","setTheme","clearUserAccountInfo"]),
        ...mapActions("app", ["setState", "clearApiResult", "setQueryParameters", "setFunctionCd","refreshFunction"]),
        ...mapActions("bread-crumb", ["resetKeepHistory"]),
        ...mapActions("facility", ["getUseFuncByFacilityCd"]),
        // 共通ローダー設定
        ...mapActions("loading-screen", {
            setLoadingScreenVisible: "setLoadingScreenVisible",
            setLoadingScreenMessage: "setLoadingScreenMessage",
            resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
        }),
        ...mapActions("data-list", ["setSelectedDynamicLayout"]),

        ...mapActions("mst-menu-group", ["getMenuGroupList"]),
        ...mapActions("mst-user", ["sendRequestUpdateSigninDate","setIsRegisteredShared"]),
        ...mapActions("notification", ["setIsRegisteredNotificationFromDb"]),
        ...mapActions("operation-viewer/machine", ["clearFacilityCd"]),
        ...mapActions("pat-info", ["selectPat","clearSearchedPatList"]),
        
        ...mapActions("pat-viewer",["setSelectedCondition"]),
        ...mapActions("pat-calendar", ["setExpandFlg"]),
        ...mapActions("daily-check", {
            dailySetCondition:"setCondition"
        }),
        ...mapActions("exam-record/list", {
            examRecordSetCondition:"setCondition"
        }),
        ...mapActions("rad-request/list", ["updateStartToEndDate","setShowDetailsDisplay","setIsShowHospPatId","setCommonConditionList"]),
        ...mapActions("exam-request/list", {
            examSetCommonConditionList:"setCommonConditionList",
            examSetShowDetailsDisplay:"setShowDetailsDisplay",
            examUpdateStartToEndDate:"updateStartToEndDate",
            examSetIsShowBloodGlucose:"setIsShowBloodGlucoseExam",
            examSetIsShowHospPatId:"setIsShowHospPatId"
        }),
        ...mapActions("exam-request/daily",{
            examSetCondition:"setCondition"
        }),
        ...mapActions("exam-request/daily", ["setPeriodType","setCondition"]),
        ...mapActions("account-edit", ["setDefaultSetting","setAuthorizedFunctions"]),
        ...mapActions("indication", ["setTreatmentSearchConditionNULL","setIndicationSearchConditionNULL"]),
        //...mapActions("rad-request/list", ["updateStartToEndDate"]),
        ...mapActions("bbs-info", {
            bbsSetIsOnlyUnread:"setIsOnlyUnread",
            bbsSetDefaultCondition:"setDefaultCondition",
        }),


        ...mapMutations("report-menu", ["setSelectedTreatDate"]),
        ...mapActions("toggle-dev-tool", ["lockDevTool"]),
        ...mapActions("websocket", {
            onCloseSocket:'close'
        }),
        ...mapActions("user", {
            setUserName:'setUserName',
            setSystemUseSetting:'setSystemUseSetting',
            userSignIn: "signIn",
            userSignOut: "signOut",
            cleanButNotSignOut:'cleanButNotSignOut',
            isSyncSignIn: "isSyncSignIn",
            /* del by chamaojia 2026-02-13 [11893] キャッシュ軽減対応 --start */
            // setPersonalUser: "setPersonalUser",
            /* del by chamaojia 2026-02-13 [11893] キャッシュ軽減対応 --end */
            fetchUserAuthorityCds:'fetchUserAuthorityCds',
            // add 10159 【因島データ】FNWで作成した患者カードがコンバート施設で使用できない　吉 start
            setDispUserId:"setDispUserId",
            // add 10159 【因島データ】FNWで作成した患者カードがコンバート施設で使用できない　吉 end
        }),


        ...mapActions("websocket-card", ["init", "connect", "close", "clearSocketMessage"]),
        ...mapActions("status-list/list", ["conditionSet","setIsShowMain"]),
        ...mapActions("status-map/map", ["initState","clearConditionTreatMap"]),
        ...mapActions("check-list/list", ["setCondition","changeIsDisplayTreatingMode"]),
        ...mapActions("water-quality-survey/list", {
            waterSetCondition:"setCondition",
            waterSetDefaultCondition:"setDefaultCondition"
        }),
        ...mapActions("facility-calendar", [
            "setViewMode",
            "setSelectedLayoutFacility"
        ]),
        //...mapActions("pat-event/list", ["resetInfoFromPatCalendar","setSelectInfo","setConditionDate"]),
        ...mapActions("pat-event/list", ["setSelectInfo","setConditionDate"]),
        ...mapActions("measure-history/list", {
            measureConditionSet:"conditionSet"
        }),
        ...mapActions("observe-record/list", ["setConditionListForSave"]),

        ...mapGetters("app", ["getApiResult", "getFunctionCd"]),

        ...mapMutations("notification", ["setIsRegisteredNotification"]),
        // add 8199 【デグレ】個人設定>定期点検の表示期間が適用されない 周安寧 start
        ...mapMutations("periodic-inspection",{ setperiodicinspection : "setSelectedCondition"}),
        //add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 start
        ...mapMutations("pat-info", ["addSearchedPatList", "setPatSearchType","setCardShowingCondition"]),
        
        ...mapMutations("periodic-inspection", ["setStorSimlpSearchQurey"]),
        ...mapMutations("status-list/list", ["clearConditionTreatList","clearConditionAll"]),
        ...mapMutations("status-map/map", ["clearConditionTreatMap","setTreatCondition","setTreatStateMode"]),
        // list
        async getFacilitiesList(){
            this.isRequest = true;
            //id
            let uId = this.getStateUserAccountInfo.userId
            await getCanLoginFacilities(uId)
            .then(response => {
              let tResData = response.data;

            this.facilitiesList = tResData;
            this.isRequest = false;
            })
            .catch(error => {
                console.log(error)
                this.isRequest = false;
              throw error;
            });
        },
        //liyanze-z list click 
        facilitiesListClick(item){
            this.$emit("childSendHidden",{class:'needHidden'})
            this.checkItem = item
            
            let newObj = {
                isTrusted: true
            }
            //
            this.proof = newObj;

            // this.onCloseSocket();
            // return

            this.logoutFN();
        },
        //logout
        logoutFN(){
            // 確認のダイアログを表示する
            this.$ons.notification.confirm({
                title: '施設切替確認',
                message: '施設を切り替えますが、よろしいでしょうか？',
                callback: answer => {
                    if (answer == 1) {
                        this.setLoadingScreenVisible(true);
                        this.setLoadingScreenMessage("処理中・・・");

                        //触发登陆行为
                        this.loginFN()
                    }
                    this.$emit("childSendHidden",{class:''})
                }
            })
        },

        //login
        async loginFN(){
            //close parent
            this.$emit("childSendClose",{})

            // パンくずリストをクリア
            //this.resetKeepHistory();
            
            //清除治疗状况抽出内容
            this.clearConditionAll({isClear:false})
            // storeを呼び出す為の引数作成
            let user = null;
            user = {
                userId: this.checkItem.username,
                password: this.checkItem.password,
                facilityCd:this.checkItem.facilityHash,
                funcCd: this.$route.query.FUNC,
                mode: this.$route.query.MODE,
                switchStatus : "true",
                autoSignInFlag : this.proof,
            };
            
            await this.userSignIn(user)
            .then(() =>{
                //localStorage.setItem(LOCAL_STORAGE_KEY.FACILITY_HASH, this.getKey);
                if(this.getResponseMessage.code == null) {
                    
                    this.setLoadingScreenVisible(false);
                    //return
                    // 選択中患者及び患者検索リストのクリア
                    this.clearSearchedPatList();
                    // 次回LoginView開始時にストアのクリアを行うフラグを立てる
                    this.setNeedsCleanStore(true);
                    // パンくずリストをクリア
                    //this.resetKeepHistory();

                    (async () => {
                        const userInfo = await this.getUserAccountInfoSignInCheck();
                        // liyanze-z hash again set
                        const ntssProtocol = window.location.protocol;
                        const ntssHost = window.location.host;
                        const ntssPathName = window.location.pathname.substring(1);
                        const hashedKey = this.checkItem.facilityHash;
                        this.setState({
                            protocol: ntssProtocol,
                            host: ntssHost,
                            pathname: ntssPathName,
                            key: hashedKey
                        });
                        // 利用者権限取得.
                        await this.fetchUserAuthorityCds();
                        //const userInfo = this.getStateUserAccountInfo;
                        // console.log(userInfo)
                        
                        // メニューグループマスタ取得
                        await this.getMenuGroupList(userInfo.facilityCd);
                        // add 10159 【因島データ】FNWで作成した患者カードがコンバート施設で使用できない　吉 start
                        this.setDispUserId(userInfo.dispUserId);
                        await this.setUserName(
                            userInfo.userLastName + " " + userInfo.userFirstName
                        );

                        /**
                         * liyanze-z 个人默认设置重置处理 start
                         */
                        await this.sendStoreAll(userInfo.userSettings);
                         /**
                         * liyanze-z 个人默认设置重置处理 end
                         */


                        // add FNSI-メニューに共有ON／共有OFFを追加する。 周 start
                        this.setIsRegisteredShared(userInfo.patientShared);
                        // add FNSI-メニューに共有ON／共有OFFを追加する。 周 end
                        // システム利用設定を追加
                        await this.setSystemUseSetting(userInfo.facilityCd);
                        //原来这个位置有个注册判定

                        // 同時サインイン可否設定の取得.
                        const isSyncSignIn = await this.isSyncSignIn(userInfo.facilityCd);
                        if(!isSyncSignIn){
                            console.log(isSyncSignIn)
                        }

                        await this.getUseFuncByFacilityCd();

                        //検索サイドバー初期検索コール
                        await this.defaultSearchPat(userInfo.facilityCd);
                        /* del by chamaojia 2026-02-13 [11893] キャッシュ軽減対応 --start */
                        // // xie add メモリにて利用者マスタ一覧取得 Start
                        // // 利用者マスタ一覧取得
                        // await this.setPersonalUser(userInfo.facilityCd).catch(error => {
                        //     console.log(error);
                        // });
                        // // xie add メモリにて利用者マスタ一覧取得 End
                        /* del by chamaojia 2026-02-13 [11893] キャッシュ軽減対応 --end */
                        //サインイン日時更新
                        const userId = {
                            userId : userInfo.userId
                        }
                        await this.sendRequestUpdateSigninDate(userId);

                        // URL指定かどうかで遷移先を変更
                        if (this.checkIsUrlDirect() === true) {
                            // URL指定で特定画面に遷移
                            const successTransition = await this.goSpecifyingPage();
                            if (!successTransition) {
                                // 遷移失敗時、初期表示メニューへ遷移
                                this.goInitialFunctionPage();
                            }
                            // 共通ローダー:初期値セット(非表示)
                            this.resetLoadingScreenVisibleCount();
                        } else {
                            const flagIsHave = (arr, name) => {
                                let isHave = false;
                                for(let a=0;a<arr.length;a++){
                                    let tName = getNameA(arr[a])
                                    if(name == tName){
                                        isHave = true
                                    }
                                }
                                return isHave
                            }
                            let tPath = this.$route.path
                            //判断 当前路由 在将要切替的用户所属权限中是否有 没有就跳转默认应该跳转的
                            let codeAll = userInfo.userSettings.authorized_functions;
                            if(codeAll){
                                let pathArr = tPath.split('/')
                                let isNeedPath = flagIsHave(codeAll,pathArr[0]!=''?pathArr[0]:pathArr[1])
                                //false-
                                if(isNeedPath == false){
                                    let showName = this.$route.meta.title
                                    this.$ons.notification.alert({
                                        title: "使用許可エラー",
                                        message: showName + 'の使用許可がありません。管理者に確認してください。'
                                    });
                                    //パンくずリストをクリア
                                    this.resetKeepHistory();
                                    // 初期表示メニューへ遷移
                                    this.goInitialFunctionPage();
                                    // 共通ローダー:初期値セット(非表示)
                                    //this.resetLoadingScreenVisibleCount();
                                }else{
                                    //add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 start
                                    // this.clearConditionTreatList();
                                    // this.clearConditionTreatMap();
                                    //add 6011 個人設定>デフォルト設定>治療状況マップで設定したレイアウトを表示しない 関俊楠 end
                                    //liyanze-z 获取当前路由 重新replace 重置一下路由内容
                                    // this.$router.replace({
                                    //     path:tPath,
                                    //     query: { switch: Date.now() }
                                    // })
                                    //监听vuex是否需要刷新页面路由
                                    let tObj = {
                                        status:true,
                                        date:Date.now()
                                    }
                                    this.refreshFunction(tObj)
                                }
                            }
                            // 初期表示メニューへ遷移
                            //this.goInitialFunctionPage();
                            // 共通ローダー:初期値セット(非表示)
                            //this.resetLoadingScreenVisibleCount();
                            this.setLoadingScreenVisible(false);

                        }
                        // WebPushに必要な情報を登録
                        await this.registWebPushData();

                        // localStorage.setItem(LOCAL_STORAGE_KEY.FACILITY_HASH, this.checkItem.facilityHash);
                        // // //刷新页面
                        // window.location.reload();
                        // userInfoのuserSettingsを見て、通知の有効無効を確認したい
                        if (userInfo.userSettings.personal_settings.length > 0 &&typeof(userInfo.userSettings.personal_settings[0].values) !== "undefined") {
                            const notifySetting = userInfo.userSettings.personal_settings.find(item => {
                                return item.tab_define_cd === 8;
                            }).values;
                            const KurNoSetting = "29"; // クール未登録通知 あとで定数化したい
                            const notifySettingKurNotSet = notifySetting.find(item => {
                                return item.setting_identifier === KurNoSetting && item.value === true;
                            });

                            if (notifySettingKurNotSet) {
                                // xie 5544 start
                                console.log("1s");
                                //await ApiHelper.get("/mainData/notifyKurNotSet");
                                await ApiHelper.get("/mainData/notifyKurNotSet").then(() => {
                                    console.log("1e");
                                });
                                // xie 5544 end
                            }

                            const BedNoSetting = "30"; // ベッド未登録通知 あとで定数化したい
                            const notifySettingBedNotSet = notifySetting.find(item => {
                                return item.setting_identifier === BedNoSetting && item.value === true;
                            });

                            if (notifySettingBedNotSet) {
                                // xie 5544 start
                                //await ApiHelper.get("/mainData/notifyBedNotSet");
                                console.log("2s");
                                await ApiHelper.get("/mainData/notifyBedNotSet").then(() => {
                                    console.log("2e");
                                });
                                // xie 5544 end
                            }
                        }



                        // LocalStorageに必要な情報を書込む
                        // サインイン時の施設ハッシュ値を格納
                        //localStorage.setItem(LOCAL_STORAGE_KEY.FACILITY_HASH, this.getKey);

                        // 自端末でサインインしているカウント数を格納
                        let signinCount = localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
                        // サインインカウント数がない場合
                        if (!signinCount) {
                            signinCount = 0;
                        }
                        // サインイン回数をインクリメントし格納
                        localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT, Number(signinCount) + 1);

                        // サインイン管理のパラメータ
                        const request = {
                            terminalUniqueString: createTerminalUniqueString(),
                            facilityCd: userInfo.facilityCd,
                            userId: userInfo.userId
                        };
                        // DB登録
                        // await sendRequestRegistSignin(request);

                        // 他のタブの自動サインイン処理発火 (初回サインイン時のみ)
                        if (localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT) == 1) {
                            await localStorage.setItem(LOCAL_STORAGE_KEY.SIGN_IN_TRIGGER, new Date());
                        }
                        // add FNSI-4200ポートを使用している 孫 start
                        // カードリーダーAPPを接続します
                        if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
                            // card appのwebsokcet以外場合、接続したサービスを閉じました
                            if (this.getSocketIsConnected) {
                                this.close();
                                await SleepNSeconds(100);
                            }
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
                        if (null !== userInfo.facilityCd && "" !== userInfo.facilityCd) {
                            if (!this.getSocketIsConnected || null === this.getCardDeviceStatus) {
                                // 「カードアプリポート管理」からportを取得する
                                let facilityCd = userInfo.facilityCd;
                                let cardPorts = await ApiHelper.get(`${uriGetCardAppPort}/${facilityCd}`).catch(() => {
                                    throw new Error("カードアプリポート管理から、ポートを取得しません。");
                                });

                                // portsをループする
                                let portList = new Array();
                                if (cardPorts.data.toString().indexOf(",") == -1) {
                                    portList[0] = cardPorts.data.toString();
                                }else {
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
                        }else {
                            this.isCardDeviceConnected = this.getCardDeviceStatus
                        }


                        function SleepNSeconds(num) {
                            return new Promise((resolve) => {
                                setTimeout(() => {
                                    resolve(1*num);
                                }, num);
                            } );
                        }


                        //debugger
                        // console.log(isSyncSignIn)
                        // sessionStorage.setItem('testKey',JSON.stringify(userInfo))
                    })().catch((error) => {
                        this.setLoadingScreenVisible(false);
                        this.$router.push({ name: "signin" });
                    })
                    // localStorage.setItem(LOCAL_STORAGE_KEY.FACILITY_HASH, this.checkItem.facilityHash);
                    // // //刷新页面
                    // window.location.reload();

                    // #8576 【デグレ】サインアウト後サインインすると強制サインアウトのメッセージが表示される dou start
                    //window.location.reload();
                }
                // ワンタイムパスワードを利用するための初回ログイン（QRコードによる秘密鍵の設定）
                // responseのサンプル {code: "2", message: "{"dispUserId": "nkk", "facilityCd": "009997"}"}
                else if(this.getResponseMessage.code == 2) {
                    this.resetLoadingScreenVisibleCount();
                    this.hasQRCodeImg = true;
                    this.createOTPData = JSON.parse(this.getResponseMessage.message);
                    this.isLoginSuccess = true;
                }
                // ワンタイムパスワードの設定が完了した後（二回目以降のログイン）
                else if(this.getResponseMessage.code == 1) {
                    this.preLoadOtpFailureCnt(this.getKey);
                    this.hasQRCodeImg = false;
                    this.resetLoadingScreenVisibleCount();
                    this.isLoginSuccess = true;
                }
                // デベロッパーツールが開かれている状態でログインしようとした場合
                else if (this.getResponseMessage.code === 999) {
                    this.setLoadingScreenVisible(false);
                    this.hasAuthError = this.getResponseMessage.hasAuthError ? true : false;
                    this.$ons.notification.alert({
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                    // title: "エラー",
                    title: DIALOG_MESSAGES['00300008'].title,
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    message: this.getResponseMessage.message,
                    callback: () => {
                        this.isAlerting = false;
                        this.clearApiResult();
                    }
                    });
                }
            }).catch((error) => {
                this.loginByUrlFlag = false;
                this.setLoadingScreenVisible(false);
            });
        },
        //用户默认检索内容
        async sendStoreAll(tObj){
            let userInfo = {
                userSettings:tObj
            }
            //一般撮影検査依頼一覧
            await this.sendRadRequest(userInfo.userSettings);
            //左侧检索
            await this.sendLeftSearch(userInfo.userSettings);
            //新規患者登録	
            await this.sendPatInfo(userInfo.userSettings);
            //指示受け・指示承認
            await this.sendIndication(userInfo.userSettings);
            //检查依赖一览	
            await this.sendExamRequest(userInfo.userSettings);
            //体重計測定記録
            await this.sendMeasure(userInfo.userSettings);
            //施設カレンダー
            await this.sendFacility(userInfo.userSettings);
            //患者カレンダー 
            await this.sendPatcalen(userInfo.userSettings);
            //观察记录
            await this.sendObserveRecord(userInfo.userSettings);
            //绍介状
            await this.sendPatInforLetter(userInfo.userSettings);
            //患者イベント
            await this.sendPatEvent(userInfo.userSettings);
            //检查结果
            await this.sendExamRecord(userInfo.userSettings);
            //定期检点
            await this.sendPeriodic(userInfo.userSettings);
            //データリスト
            await this.sendMultiPat(userInfo.userSettings);
            //揭示板
            await this.sendBBSInfo(userInfo.userSettings);
            //治療状況リスト
            await this.sendTreatment(userInfo.userSettings);
            //治療状況マップ
            await this.sendStatusMap(userInfo.userSettings);
            //チェックリスト 
            await this.sendCheckList(userInfo.userSettings)
            //日常点検
            await this.sendDaily(userInfo.userSettings);
            //水质
            await this.sendWater(userInfo.userSettings)
        },
        //左侧检索
        async sendLeftSearch(tObj){
            this.setStorSimlpSearchQurey(null);
        },
        //新規患者登録	
        async sendPatInfo (tObj){
            let forObj = tObj.default_setting
            if(forObj&&forObj['pat-info']){
                let sendObj = {
                    cardListName: "patInfoCreate",
                    cardShowingCondition: forObj['pat-info']
                }
                this.setCardShowingCondition(sendObj);
            }
        },
        //检查结果
        async sendExamRecord(tObj){
            let sendObj = {};
            this.examRecordSetCondition(sendObj)
            let forObj = tObj.default_setting
            if(forObj&&forObj['exam-record']){
                forObj['exam-record'].examDateSt = calcTargetDate(forObj['exam-record'].examDateSt);
                forObj['exam-record'].examDateEd = calcTargetDate(forObj['exam-record'].examDateEd);
                let item = forObj['exam-record'];
                for(let i in item ){
                    sendObj[i] = item[i]
                }
                this.examRecordSetCondition(sendObj);
            }
        },
        //一般撮影検査依頼一覧
        async sendRadRequest(tObj){
            let sendObj = {};
            // debugger
            // const defaultRadRequest = this.getDefaultSetting[RAD_REQUEST.KEY_NAME];
            // // 表示期間・開始
            // const defaultStartDate = defaultRadRequest[RAD_REQUEST.KEY_NAME_START_DATE];
            // if (defaultStartDate != null) {
            //     sendObj.showStartDate = calcTargetDate(defaultStartDate);
            // }
            // // 表示期間・終了
            // const defaultEndDate = defaultRadRequest[RAD_REQUEST.KEY_NAME_END_DATE];
            // if (defaultEndDate != null) {
            //     sendObj.showEndDate = calcTargetDate(defaultEndDate);
            // }
            // sendObj.showStartDate = '';
            // sendObj.showEndDate = '';
            //console.log(sendObj)
            //debugger
            // this.updateStartToEndDate(sendObj);
            let forObj = tObj.default_setting;
            this.setDefaultSetting(tObj.default_setting);
            this.setShowDetailsDisplay(true);
            this.setIsShowHospPatId(true);
            this.setCommonConditionList({
                endDate:"",
                selectedDayOfWeek:null,
                setInterval:1,
                setTime:'',
                startDate:calcTargetDate("20"),
            })
            if(forObj&&forObj['rad-request']){
                let item = forObj['rad-request'];
                this.setShowDetailsDisplay(item.isShowDetailsDisplay == 1?true:false);
                this.setIsShowHospPatId(item.isShowHospPatId);
                // sendObj.showStartDate = calcTargetDate(item.startDate);
                // sendObj.showEndDate = calcTargetDate(item.endDate);
                // this.updateStartToEndDate(sendObj);
            }
        },
        //指示受け・指示承認
        async sendIndication (tObj){
            //this.setIndicationSearchCondition(null)
            this.setIndicationSearchConditionNULL(null)
            this.setTreatmentSearchConditionNULL(null)
        },
        //检查依赖一览	
        async sendExamRequest(tObj){
            //选择
            this.setPeriodType(1)
            //时间
            // this.examUpdateStartToEndDate({
            //     showStartDate: startDate,
            //     showEndDate: endDate,
            // })
            //简易和详细
            this.examSetShowDetailsDisplay(true);
            this.examSetIsShowBloodGlucose(true);
            this.examSetIsShowHospPatId(true);
            this.examSetCondition({
                examType:false,
                scheduledDate:calcTargetDate("20"),
                showScheduledOnly:true,
            })
            let forObj = tObj.default_setting;
            if(forObj&&forObj['exam-request']){
                let item = forObj['exam-request'];
                this.setPeriodType(item.periodType)
                this.examUpdateStartToEndDate({
                    showStartDate: calcTargetDate(item.startDate),
                    showEndDate: calcTargetDate(item.endDate),
                })
                this.examSetShowDetailsDisplay(item.isShowDetailsDisplay == 1?true:false);
                this.examSetIsShowBloodGlucose(item.isShowBloodGlucoseExam);
                this.examSetIsShowHospPatId(item.isShowHospPatId);
                this.examSetCondition({
                    examType:item.examTypeList,
                    scheduledDate:calcTargetDate(item.scheduledDate),
                    showScheduledOnly:item.showScheduledOnly,
                })
                //this.setIsShowHospPatId(item.isShowHospPatId);
                // sendObj.showStartDate = calcTargetDate(item.startDate);
                // sendObj.showEndDate = calcTargetDate(item.endDate);
                // this.updateStartToEndDate(sendObj);
            }
            //this.examSetCommonConditionList();
        },
        //施設カレンダー
        async sendFacility(tObj){
            let forObj = tObj.default_setting
            this.setViewMode(Number.parseInt(3));
            this.setSelectedLayoutFacility(null)
            
            if(forObj&&forObj['facility-calendar']){
                let item = forObj['facility-calendar'];
                this.setViewMode(Number.parseInt(item.viewMode));
                let mstList = await getFacilityCalendarMasterLayout();
                let layoutMst = mstList.data.map(
                    ({ facilityCalendarLayoutCd, facilityCalendarLayoutName, dispItemInfo }) => ({
                        layoutCd: facilityCalendarLayoutCd,
                        layoutName: facilityCalendarLayoutName,
                        layoutInfo: JSON.parse(dispItemInfo)
                    })
                );
                let selectedLayout = layoutMst.find(
                    el => el.layoutCd === item.layoutCd
                );
                //console.log(selectedLayout)
                this.setSelectedLayoutFacility(selectedLayout)
                // this.setSelectedCondition()
            }
        },
        //体重計測定記録
        async sendMeasure (tObj){
            let sendObj = {
                bedGroupCd:0,
                clearflag:false,
                freeWord:"",
                kurCd:-1,
                measureDate:"",
                weightScaleStatus:-1,
            }
            this.measureConditionSet(sendObj);
            let forObj = tObj.default_setting;
            if(forObj&&forObj['measure-history']){
                let item = forObj['measure-history']
                sendObj.bedGroupCd = item.bedGroupCd;
                sendObj.freeWord = item.freeWord;
                sendObj.kurCd = item.kurCd;
                sendObj.weightScaleStatus = item.weightScaleStatus;
                this.measureConditionSet(sendObj);
            } 
        },
        //观察记录
        async sendObserveRecord(){
            this.setConditionDate({ startDate: null, endDate: null });
            this.setConditionListForSave(null);
        },
        //绍介状
        async sendPatInforLetter(tObj){
            //await this.resetInfoFromPatCalendar();
            let sendObj = {
                startDate:calcTargetDate('7'),
                endDate:calcTargetDate('20'),
                relationCategoryCd:["0-0"]
            }
            let forObj = tObj.default_setting
            this.setSelectInfo({patIntroLetter:sendObj})
            if(forObj&&forObj['pat-intro-letter']){
                let item = forObj['pat-intro-letter'];
                sendObj.startDate = calcTargetDate(item.startDate);
                sendObj.endDate = calcTargetDate(item.endDate);
                let newArr = ['' + item.relationCategoryCd]
                sendObj.relationCategoryCd = newArr;
                this.setSelectInfo({patIntroLetter:sendObj})
            }
        },
        //患者イベント
        async sendPatEvent(tObj){
            //await this.resetInfoFromPatCalendar();
            let sendObj = {
                startDate:calcTargetDate('7'),
                endDate:calcTargetDate('20'),
                relationCategoryCd:["0-0"]
            }
            let forObj = tObj.default_setting
            this.setSelectInfo({patEvent:sendObj})
            if(forObj&&forObj['pat-event']){
                let item = forObj['pat-event'];
                sendObj.startDate = calcTargetDate(item.startDate);
                sendObj.endDate = calcTargetDate(item.endDate);
                let newArr = ['' + item.relationCategoryCd]
                sendObj.relationCategoryCd = newArr;
                this.setSelectInfo({patEvent:sendObj})
            }
        },
        //患者カレンダー 
        async sendPatcalen (tObj){
            let forObj = tObj.default_setting
            if(forObj&&forObj['pat-calendar']){
                 this.setExpandFlg(forObj['pat-calendar'].expandFlg);
            }
        },
        //定期检点
        async sendPeriodic (tObj){
            let sendObj = {}
            sendObj.startDate = calcTargetDate(DATE_CHOICES.BEFORE_ONE_YEAR.value)
            sendObj.endDate = calcTargetDate(DATE_CHOICES.AFTER_ONE_YEAR.value)
            sendObj.bedGroupCd = null;
            sendObj.machineTypeList = []
            this.setperiodicinspection(sendObj);
            let forObj = tObj.default_setting
            if(forObj&&forObj['periodic-inspection']){
                sendObj.startDate = calcTargetDate(forObj['periodic-inspection'].fromDate);
                sendObj.endDate = calcTargetDate(forObj['periodic-inspection'].toDate);
                sendObj.bedGroupCd = forObj['periodic-inspection'].bedGroupCd;
                sendObj.machineTypeList = forObj['periodic-inspection'].machineTypeList;
                this.setperiodicinspection(sendObj);
            }
        },
        async sendMultiPat(tObj){
            this.setSelectedDynamicLayout(null);
            // let forObj = tObj.default_setting
            // if(forObj&&forObj['multi-pat-list']){

            // }
        },
        //揭示板
        async sendBBSInfo(tObj){
            this.bbsSetDefaultCondition(null);
            this.bbsSetIsOnlyUnread(true);
            let forObj = tObj.default_setting;
            if(forObj&&forObj['bbs-info']){
                let item = forObj['bbs-info'];
                this.bbsSetIsOnlyUnread(item.showOnlyUnread);
            }
            // let startData = {
            //     // カテゴリ機能
            //     categoryFuncList: [], // 初期値設定:すべて
            //     // カテゴリ種類
            //     categoryKindList: [],
            //     // フリーワード
            //     freeWord: "", // 初期値設定:未入力
            //     // 掲載開始日
            //     noticeStartDate: moment().format("YYYY-MM-DD"), // 初期値設定:本日
            //     // 掲載終了日
            //     noticeEndDate: moment().format("YYYY-MM-DD"), // 初期値設定:本日,
            //     // 透析日
            //     dialysisDate: null, // 初期値設定:未入力
            //     // クール
            //     kur: null, // 初期値設定:すべて
            //     // ベッドグループ
            //     roomBedGroup: { bedGroupCd: null, bedCdList: [] },// 初期値設定:すべて
            //     // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
            //     // 表示件数
            //     limitFrom: 0,
            //     limitTo: 0,
            //     userId: "",
            //     sortColumn: "",
            //     sortKind: "",
            //     targetUserId: ""
            //     // add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
            // }
            // this.bbsSetIsOnlyUnread(true);
            // this.bbsSetSelectedCondition(startData);
            // this.bbsSetDefaultCondition(startData);
            // let forObj = tObj.default_setting;
            // if(forObj&&forObj['bbs-info']){
            //     let item = forObj['bbs-info']
            //     startData.categoryKindList = item.categoryKindList;
            //     startData.noticeStartDate = calcTargetDate(item.noticeStartDate);
            //     startData.noticeEndDate = calcTargetDate(item.noticeEndDate);
            //     startData.dialysisDate = calcTargetDate(item.dialysisDate);
            //     startData.kur = item.kur
            //     startData.roomBedGroup.bedGroupCd = item.bedGroupCd;
            //     console.log(startData)
            //     this.bbsSetIsOnlyUnread(item.showOnlyUnread);
            //     this.bbsSetSelectedCondition(startData);
            //     this.bbsSetDefaultCondition(startData);

            // }
        },
        //iyanze-z 切替时 新保存  治療状況リスト ：抽出条件セット
        async sendTreatment(tObj){
            //左侧治疗状况和装置一览的选择重置
            this.setIsShowMain(true);
            this.conditionSet({
               bedGroupCd:0, 
               colItemGroupIndex:0, 
               colItemGroupName:'',
               colItemLayoutNo:'',
               colListChange:false,
               deviceColIndex:0,
               deviceNextIndex:2,
               isClear:false,
               isInitialized:true,
               kurCd:[],
               kurGroupList:[],
               kurGroupName:[],
               nextPatGroupIndex:0,
               notUsageGuide:false,
            })
            let forObj = tObj.default_setting
            if(forObj&&forObj['status-list']){
                let item = forObj['status-list']
                let conditionTreatList = {}
                for(let i in item ){
                    conditionTreatList[i] = item[i]
                }
                this.setIsShowMain(item['dispMode'==2?true:false]);
                this.conditionSet(conditionTreatList)
            }
        },
        //iyanze-z 切替时 新保存  治療状況マップ  ：抽出条件セット
        async sendStatusMap (tObj){
            let clearObj = {
                // クール：
                kurIndex: 0,
                kurCd: "",
                // ベッドグループ
                bedGroupIndex: 0,
                roomBedGroupCd: 0,
                // 治療状況レイアウト
                statusLayoutIndex: 0,
                statusLayoutNo: "",
                // 次患者表示
                nextPatGroupIndex: 2,
                isClear: true,
                // ベッドレイアウト
                bedLayoutIndex: 0,
                bedLayoutId: "",
                // 予定日
                currentDateTime: new Date(),
                // 指示者
                userIndex: 0,
                userId: ""
            }
            //先重置
            this.setTreatCondition({conditionTreatMap:clearObj})
            this.clearConditionTreatMap()
            this.setTreatStateMode(null);
        },
        async sendDaily(tObj){
            let sendObj = {
                bedGroupCd:null,
                isNon:true,
                isPass:true,
                isUnfinished:true,
                isUnpass:true,
                keyword:'',
                machineTypeList:[]
            }
            this.dailySetCondition(sendObj)
            let forObj = tObj.default_setting
            if(forObj&&forObj['daily-check']){
                let item = forObj['daily-check']
                item['isUnfinished'] = item['isFail']
                delete item['isFail']
                this.dailySetCondition(item)
            }
        },
        //チェックリスト 
        async sendCheckList (tObj){
            await this.setCondition({
                bedGroupCd: -1,
                nextPat: 0,
                treatDate: moment(new Date()).format("YYYY-MM-DD"),
                kurCd: -1,
                viewTreatDate: false,
                isAutoReload: false,
                isShowUsageGuide: false
            })
            await this.changeIsDisplayTreatingMode(true)
            let forObj = tObj.default_setting
            if(forObj&&forObj['check-list']){
                let item = forObj['check-list'];
                let newObj = {};
                newObj.bedGroupCd = item.bedGroupCd;
                newObj.viewTreatDate = item.viewTreatDate;
                newObj.isAutoReload = item.isAutoReload;
                newObj.isShowUsageGuide = item.isShowUsageGuide;
                newObj.kurCd = item.kurCd;
                newObj.nextPat = item.nextPatGroupIndex;
                newObj.treatDate = moment(new Date()).format("YYYY-MM-DD");
                await this.changeIsDisplayTreatingMode(item.dispMode==1?true:false)
                this.setCondition(newObj)
            }
        },
        async sendWater(tObj){
            let sendObj = {}
            sendObj.fromDate = calcTargetDate(DATE_CHOICES.BEFORE_ONE_YEAR.value)
            sendObj.toDate = calcTargetDate(DATE_CHOICES.AFTER_ONE_YEAR.value)
            sendObj.bedGroupCd = null;
            sendObj.isDispMachineName = true;
            sendObj.isDispSurveyType = true;
            sendObj.surveyTypeCd = [];
            this.waterSetCondition(sendObj)
            this.waterSetDefaultCondition(sendObj);
            let forObj = tObj.default_setting
            if(forObj&&forObj['water-quality-survey']){
                let item = forObj['water-quality-survey']
                sendObj.fromDate = calcTargetDate(item.fromDate);
                sendObj.toDate = calcTargetDate(item.toDate);
                sendObj.bedGroupCd = item.bedGroupCd;
                sendObj.isDispMachineName = item.isDispMachineName;
                sendObj.isDispSurveyType = item.isDispSurveyType;
                sendObj.surveyTypeCd = item.surveyTypeCd;
                this.waterSetCondition(sendObj);
                this.waterSetDefaultCondition(sendObj);
            }
        },

        /**
         * 利用者情報のクリア処理
         */
        clearUserInfo() {
            // storeに保持している利用者情報をクリア
            this.userSignOut();
            this.clearUserAccountInfo();
            this.setTheme(THEME_WHITE);
        },
        //storeに保持している患者経過総合ビューアレイアウトデータをクリア
        clearPatViewerCondition(){
            this.setSelectedCondition(null);
        },
        // add 8436 8199 【デグレ】患者検索の個人設定に設定している条件が表示されない 周安寧 start
        // clearCondition(){
        //     this.setStorSimlpSearchQurey(null);
        //     this.setperiodicinspection(null);
        // },
        //応答メッセージを取得
        getResponseMessage(){
            return this.getResponse;
        },

        setNeedsCleanStore(isNeeded) {
            sessionStorage.setItem(
                SESSION_STORAGE_KEY.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN,
                isNeeded
                ? SESSION_STORAGE_VALUE.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN.TRUE
                : SESSION_STORAGE_VALUE.NEEDS_CLEAN_STORE_BEFORE_SIGN_IN.FALSE
            );
        },

        /**
         * 初期患者検索
         *
         * @param {String} facilityCd 施設コード
         */
        async defaultSearchPat(facilityCd){
            // マスタ取得
            // 検索条件のベッドグループ、患者グループがマスタから削除済かの判定に使用
            try {
                const [responseBedGroup, patGroups] = await Promise.all([
                ApiHelper.get("/mstInfo/mstRoomBedGroup", {
                    facilityCd: facilityCd
                }),
                PatGroup.list(facilityCd)
                ]);
                this.mstBedGroup = responseBedGroup.data;
                this.patGroups = patGroups.data.patGroupInfo;
            } catch (error) {
                this.setLoadingScreenVisible(false);
                throw new Error("[LoginView.vue]defaultSearchPat(): マスタ取得失敗");
            }

            // 初回検索用条件-検索サイドバーと同じ手順
            const treatDate = moment().format("YYYYMMDD");
            this.setSelectedTreatDate(treatDate);
            const conditions = this.createDefaultConditions(treatDate, facilityCd);




            // 簡易検索
            const uriSimple = "/patInfo/getSimpleSearchResult";
            const resSimple = await ApiHelper.post(uriSimple, {...conditions,patIdList: []
            }).catch(() => {
                this.setLoadingScreenVisible(false);
                throw new Error("[LoginView.vue]defaultSearchPat(): 初期検索失敗");
            });
            this.setPatSearchType(1);
            // 必要なカラムのみ取り出す
            const patPersonalInfoList = resSimple.data.map(pat => {
                return {
                pat_id:pat.pat_id,hosp_pat_id:pat.hosp_pat_id,pat_sex: pat.pat_sex,
                pat_last_name:pat.pat_last_name,pat_first_name:pat.pat_first_name,is_same:pat.is_same
                // add FNSI-終了およびその結果を通知機能で教える 江 start
                ,pat_first_name_kana:pat.pat_first_name_kana,pat_last_name_kana:pat.pat_last_name_kana
                // add FNSI-終了およびその結果を通知機能で教える 江 end
                ,in_out_class:pat.in_out_class
                };
            });
            // 検索サイドバーと同じ手順でデータ抽出
            const filteredPatList = patPersonalInfoList.filter(pat => {
                const patName = `${pat.pat_last_name}${pat.pat_first_name}`;
                const regexp = new RegExp(`.*${""}.*`);
                return regexp.test(patName) || regexp.test(pat.hosp_pat_id);
            });
            // 患者リストに追加
            await this.addSearchedPatList(filteredPatList);
            /* del by chamaojia 2025-05-21 [11871]  --start */
            /*this.$nextTick(async () => {
                await this.loadSysFacility(true);
            });*/
            /* del by chamaojia 2025-05-21 [11871]  --end */
        },
        /**
         * 個人設定で登録した初期値を元に検索パラメータを作成
         *
         * @param {String} treatDate 治療日
         * @param {String} facilityCd 施設コード
         */
        createDefaultConditions(treatDate, facilityCd) {
            // 初期値を入れる
            let kurCdList = [];
            let bedGroupCd = null;
            let selectedPatGroups = [];
            let queryPatGroupsMethod = '2';

            // デフォルト設定
            const defaultCondition = deepCopy(this.getDefaultSetting[PATIENT_SEARCH.KEY_NAME]);
            // console.log("defaultCondition: %o", JSON.parse(JSON.stringify(defaultCondition)));
            if (defaultCondition) {
                // デフォルト設定が存在する場合は適用
                if (defaultCondition[PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST] != null) {
                    kurCdList = defaultCondition[PATIENT_SEARCH.KEY_NAME_KUR_CD_LIST];
                }
                if (defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST] != null) {
                    bedGroupCd = defaultCondition[PATIENT_SEARCH.KEY_NAME_BED_GROUP_LIST];
                    // ベッドグループがマスタから削除されている場合は初期値にする
                    if (!this.mstBedGroup.some(item => item.roomBedGroupCd === bedGroupCd)) {
                        bedGroupCd = 0;
                    }
                }
                if (defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS] != null) {
                    selectedPatGroups = defaultCondition[PATIENT_SEARCH.KEY_NAME_SELECTED_PAT_GROUPS];
                    // 患者グループがマスタから削除されている場合は配列内のから対象コードを削除
                    const validPatGroupCds = this.patGroups.map(item => item.patGroupCd);
                    selectedPatGroups = selectedPatGroups.filter(value => validPatGroupCds.includes(value));
                }
                if (defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD] != null) {
                    queryPatGroupsMethod = defaultCondition[PATIENT_SEARCH.KEY_NAME_QUERY_PAT_GROUPS_METHOD];
                }

                return {
                    ord_schedule:{
                        treatDate,
                        kurCdList,
                        bedGroupCd: bedGroupCd === 0 ? null : bedGroupCd,
                        treatDayOfWeekList:[]
                    },
                    facilityCdList:[facilityCd],
                    patGroupSearch:{
                        patGroupCd:selectedPatGroups,
                        searchType:parseInt(queryPatGroupsMethod)
                    }
                }
            }
        },
        /**
         * URL指定で呼びだされたかの確認
         * パラメータに機能コード(FUNC)があればtrueを返す
         */
        checkIsUrlDirect() {
            let parameters = JSON.parse(JSON.stringify(this.$route.query));
            return parameters.hasOwnProperty("FUNC");
        },
        /**
         * URL指定で呼びだされた場合
         */
        async goSpecifyingPage() {
            let parameters = JSON.parse(JSON.stringify(this.$route.query));
            const userType = this.getStateUserAccountInfo.userType;

            // 施設患者IDを内部患者IDに変換
            if (parameters.PATID) {
                try {
                const response = await ApiHelper.get(`/patPersonalMain/getPatIdByHospPatId/${parameters.PATID}`)
                parameters.PATID = response.data;
                } catch (err) {
                parameters.PATID = null;
                }
            }

            if (!parameters.FUNC) {
                parameters.FUNC = this.getFunctionCd();
            } else {
                this.setFunctionCd(parameters.FUNC);
                // 異なる施設の場合
                if (!await this.isDifferentFacaility()) {
                    return;
                }
                if (!this.hasNextAuthority(parameters.FUNC)) {
                    parameters.routerName = getRouterName(this.getInitialFunction, userType);
                    parameters.hasAuth = false;
                } else {
                    this.setQueryParameters(parameters);
                    parameters.routerName = getRouterName(parameters.FUNC, userType);
                    parameters.hasAuth = true;
                }
            }
            return this.moveTo(parameters);
        },
        /**
         * 既にサインインしている場合、サインイン済の施設と同じ施設かをチェックする.
         * @returns true : 同じ施設
         *          false : 異なる施設
         */
        isDifferentFacaility() {
            // アラート表示中の場合は何もしない.
            if (this.isAlerting) {
                return;
            }
            // 異なる施設コードの場合はエラーメッセージを表示して何もしない.
            const facilityHash = localStorage.getItem(LOCAL_STORAGE_KEY.FACILITY_HASH);
            const signInCount = localStorage.getItem(LOCAL_STORAGE_KEY.SIGN_IN_COUNT);
            if (signInCount && Number(signInCount) > 0 &&
                facilityHash && this.getKey && facilityHash !== this.getKey) {
                // アラート表示中フラグをオンにする.
                this.isAlerting = true;
                this.$ons.notification.alert({
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                    // title: "エラー",
                    // message: "既にサインイン済の為<br>別の施設ではサインイン出来ません。",
                    title: DIALOG_MESSAGES[12000278].title,
                    message: messageFormat(DIALOG_MESSAGES[12000278].message),
                    // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                    callback: () => {
                        // アラートを閉じる際に、アラート表示中フラグをオフにする.
                        this.isAlerting = false;
                        // FNSI-修正 4082対応 xiebzh add start
                        this.isDifferentFacailityFlg = true;
                        // FNSI-修正 4082対応 xiebzh add end
                    }
                });


                return false;
            }
            // FNSI-修正 4082対応 xiebzh add start
            this.isDifferentFacailityFlg = false;
            // FNSI-修正 4082対応 xiebzh add end
            return true;
        },
        /**
         * 初期表示メニュー遷移
         */
        goInitialFunctionPage() {
            this.$router.push({ name: getInitialRouterName(),params: { type: 'check' } });
        },
        // WebPushに必要な情報を登録
        async registWebPushData() {
            // 通知の登録状況をセット(初期状態はfalse)
            this.setIsRegisteredNotification(false);
            // 公開鍵
            let publicKey = null;
            // Subscription処理の戻り値
            let subscriptionObj = null;

            // ブラウザが通知非対応の場合は終了
            if ("Notification" in window === false) {
                return;
            }

            // [01] 通知許可
            // Chrome の 設定 -> 詳細設定 -> プライバシーとセキュリティ -> サイトの設定 -> 通知 から初期化する
            let permission = Notification.permission;

            // 通知がブロックされている場合は終了
            if (permission === "denied") {
                return;
            }

            // 承認処理
            await Notification.requestPermission(response => {
                permission = response;
            });

            // 承認失敗時(承認ダイアログを閉じるなど)またはブロックされた場合は終了、ボタンは通知OFFにする
            if (permission !== "granted") {
                return;
            }

            // [02] 鍵取得
            await ApiHelper.get( `/send-push/publicKey`)
            .then(response => {
                publicKey = response.data;
            })
            .catch(error => {
                throw error;
            });

            // [03] 端末固有文字列の生成
            // localStorage から端末固有文字列を取得(未保存の場合はnull)
            const terminalUniqueString =
                localStorage.getItem(LOCAL_STORAGE_KEY.TERMINAL_UNIQUE_STRING);

            if (terminalUniqueString === null) {
                // 端末固有文字列生成.
                createTerminalUniqueString();
            } else {
                // 保存済み時はsys_notification_listにレコードがあれば通知ON、なければ通知OFFのため処理を抜ける

                // DBから取得したデータを元に通知の登録状況をセット
                await this.setIsRegisteredNotificationFromDb(terminalUniqueString);
                // 通知OFF時に処理を抜ける
                if (this.getIsRegisteredNotification === false) {
                    return;
                }
            }

            // [04] Subscription
            await webPushSubscribe(publicKey)
            .then(response => {
                subscriptionObj = response;
            })
            .catch(error => {
                throw error;
            });

            // サブスクリプションエラー時、通知をOFFにする
            if (subscriptionObj === null) {
                // ブラウザの通知解除(unSubscribe)
                navigator.serviceWorker.ready.then(function(reg) {
                    reg.pushManager.getSubscription().then(function(subscription) {
                        subscription.unsubscribe();
                    })
                });

                if (terminalUniqueString !== null) {
                // 施設コード、ログイン者のIDに該当する送信先を削除する
                await ApiHelper.put(`/send-push/pushDelete/${terminalUniqueString}`)
                    .catch(error => {
                    throw error;
                    });
                }

                await this.setIsRegisteredNotificationFromDb(terminalUniqueString);
                return;
            }

            // [05] 宛先情報をサーバに保存
            await saveNotificationList(
                this.getFacilityCd,
                this.getStateUserAccountInfo.userId,
                terminalUniqueString,
                subscriptionObj
            );

            // DBから取得したデータを元に通知の登録状況をセット
            await this.setIsRegisteredNotificationFromDb(terminalUniqueString);

        },

        /**
         * ソケット再接続処理
         */
        reconnectSocket() {
            const param = this;
            this.socketInterval = setInterval(function() {
                param.connect();
                clearInterval(this.socketInterval);
            }, 10000);
        },
    }
}

</script>

<style scoped>
.showFacilities{
    padding-bottom:20px;
}
.listNot{
    cursor:not-allowed;
    color:#888888;
}
.warningSpan{
    color:red;
}
.notHave{
    text-align: center;
    line-height: 40px;
}
.facilitiesListBox{
    width:100%;
    /* height:30px;
    line-height: 30px; */
    box-sizing: border-box;
    padding-left:12px;
    cursor:pointer;
    margin-top:20px;
    position: relative;
}
.tooltipDiv{
    min-width:200px;
    min-height:50px;
    text-align: left;
    line-height: 30px;
    color:#ffffff;
    background: rgba(0,0,0,0.6);
    border-radius:10px;
    position: absolute;
    top:-56px;
    left:20px;
    display: none;
    padding:16px 16px;
}
.facilitiesNeedHover:hover .tooltipDiv{
    display: block;
}




</style>
