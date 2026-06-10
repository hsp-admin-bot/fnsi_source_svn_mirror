## URLダイレクト機能での画面遷移方法

### URLダイレクト機能で実現できること
1. URLに機能コードを埋め込むことで、サインイン後に初期表示する機能を指定することができます。
1. その他の情報（対象の患者IDなど）をURLに埋め込むことにより、表示対象の画面側から指定された値を参照することができ、初期表示時に情報を取得して表示することができます。
1. URLにユーザーIDを埋め込むと、そのユーザーで自動サインインできます。

### URLの指定方法

下記URLは装置記録画面に遷移する場合の例です。

```
http://localhost:8000/ntss-admin-web/#/?key=<施設コードハッシュ値>&USERID=nkk&FUNC=00103&FACILITYCD=009999&MACHINETYPECD=026&MACHINESERIAL=00999901
```

下記URLは患者経過総合ビューア画面に遷移する場合の例です。

```
http://localhost:8000/ntss-admin-web/#/?key=<施設コードハッシュ値>&USERID=nkk&FUNC=004&PATID=000000000001
```


#### 機能コード
`FUNC` は、遷移先画面の機能コードを指定してください。  

※機能コードは基本3桁の数値です。（`001`:遠隔監視、`002`:生体モニタリング etc.）  
上記の例では5桁になっていますが、装置記録への遷移は特殊ケースのため例外になっています。

#### ユーザーID
`USERID`にその施設で登録されているユーザーIDを設定すると、サインイン操作を省略して画面遷移することができます。  
設定しない場合は、サインイン画面で通常のサインイン操作を行ってください。

#### 患者ID
`PATID`に患者IDを設定すると、その患者が選択された状態で遷移先画面が開きます。  
設定しない場合はなにもしません。

#### 任意パラメータ
その他のパラメータは全て任意指定です。  
遷移先画面でその情報を参照することができるので、初期表示時に必要な処理を実装してください。  
以下に例を示します。(`MotionRecordsMainComponent.vue`より)

```js
  ...mapGetters("app", ["getQueryParameters"]),
```
```js
  const queryParameters = this.getQueryParameters();
  const condition = {
    facilityCd: queryParameters.FACILITYCD,
    machineTypeCd: queryParameters.MACHINETYPECD,
    machineSerial: queryParameters.MACHINESERIAL
  }
  await this.getMachine(condition);
  await this.setHeaderInfo(this.getSelectMachine());
```
`ApplicationStore`の`getQueryParameters()`でURLのクエリパラメータが参照できますので、初期処理などで必要な情報取得を行ってください。
