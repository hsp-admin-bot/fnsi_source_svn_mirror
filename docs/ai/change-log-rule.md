## 新規作成ファイルのSVN DIFF生成ルール

新規作成ファイルは、そのままでは `svn diff` に内容が出ない場合があります。
そのため、新規作成ファイルのDIFFを作成する場合は、以下の手順で一時的にSVNの追加予定状態にしてからDIFFを生成し、DIFF生成後に追加予定状態を解除してください。

## 基本方針

* 新規作成ファイルは、一時的に `svn add` してから `svn diff` を実行してください。
* `svn diff` の結果は、`>` リダイレクトではなく `Out-File -Encoding utf8` で `.patch` ファイルに保存してください。
* DIFF生成後は、必ず `svn revert` でSVNの追加予定状態を解除してください。
* 追加予定状態の解除後、新規作成ファイルは削除せず、作業ディレクトリ上に残してください。
* AIはSVNコミットを実行しないでください。
* AIはユーザーの許可なく既存ファイルの変更を `svn revert` で取り消さないでください。

## 新規作成ファイルの処理手順

新規作成ファイルの場合は、以下の順序で処理してください。

```text
1. 対象ファイルがSVN管理外であることを確認する
2. 対象ファイルを一時的に svn add する
3. svn diff でDIFFを生成し、Out-File -Encoding utf8 でpatchファイルに保存する
4. svn revert で svn add 状態を解除する
5. svn status で対象ファイルが追加予定状態ではなくなったことを確認する
6. descフォルダ内に、DIFF内容を説明するMDファイルをpatchと同じファイル名で作成してください
雛形
    N行目～M行目
        修正点：hogehogeに対する修正
            内容：fugaをhogeに変更
    N行目～M行目
        修正点：hogehogeに対する修正
            内容：fugaをhogeに変更
```

## descファイル及びpatch名の命名規則

descファイル及びpatch名は、以下の要素を連結して作成してください。

<ディレクトリパス>__<ファイル名>__<セッションID>.patch

ただし、Windowsのファイル名として安全に扱えるよう、以下の変換を行ってください。

1. パス区切り文字の \ と / は _ に置換する
2. Windowsで使用できない文字 < > : " / \ | ? * は _ に置換する
3. 連続する _ は1つにまとめる
4. 先頭・末尾のスペース、ドット、アンダースコアは削除する
5. 空文字になった場合は unknown を使用する

## 新規作成ファイルのコマンド例

```powershell
svn status "<対象ファイルパス>"
svn add "<対象ファイルパス>"
svn diff "<対象ファイルパス>" | Out-File -FilePath "<DIFFファイルパス>" -Encoding utf8
svn revert "<対象ファイルパス>"
svn status "<対象ファイルパス>"
```

例:

```powershell
svn status "C:\work\project\src\newFile.js"
svn add "C:\work\project\src\newFile.js"
svn diff "C:\work\project\src\newFile.js" | Out-File -FilePath "C:\FNW\CODEX_changed\patches\C_work_project_src__newFile.js__019ea5be-27b1-7b31-b676-d23f0e81585e.patch" -Encoding utf8
svn revert "C:\work\project\src\newFile.js"
svn status "C:\work\project\src\newFile.js"
```

## 期待される最終状態

DIFF生成後、対象ファイルは以下の状態になっていることを期待します。

```text
?       <対象ファイルパス>
```

これは、ファイル自体は作業ディレクトリに存在しているが、SVNの追加予定状態ではないことを意味します。


````markdown
## DIFF生成コマンド

```powershell
svn status "<対象ファイルパス>"
svn add "<対象ファイルパス>"
svn diff "<対象ファイルパス>" | Out-File -FilePath "<DIFFファイルパス>" -Encoding utf8
svn revert "<対象ファイルパス>"
svn status "<対象ファイルパス>"
```

## SVN状態

```text
DIFF生成のために一時的に svn add を実行した。
DIFF生成後、svn revert により追加予定状態を解除した。
対象ファイルは作業ディレクトリ上に残し、SVN管理外の状態に戻した。
```

````

## 注意事項

- `svn revert` は、新規作成ファイルの一時的な `svn add` 状態を解除する目的でのみ使用してください。
- 既存ファイルの変更に対して、ユーザーの許可なく `svn revert` を実行しないでください。
- `svn revert` 実行後、対象ファイルが削除されていないことを確認してください。
- `svn status` の結果が `A` のまま残っている場合は、追加予定状態の解除に失敗しているため、補足欄に記録してください。
- 新規ディレクトリ配下に新規ファイルを作成した場合は、ファイルだけでなく、追加予定状態になったディレクトリも確認してください。
- 一時的に `svn add` したディレクトリがある場合は、DIFF生成後にそのディレクトリの追加予定状態も解除してください。
- ただし、既存のSVN管理対象ディレクトリには `svn revert` を実行しないでください。