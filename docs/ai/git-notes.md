# Git 確認時の補足

サンドボックス実行時に Git の `dubious ownership` が出る場合は、読み取り確認で以下を使う。

`git -c safe.directory=C:/FNW/fnsi_local -C C:\FNW\fnsi_local ...`

指定ハッシュ時点のファイル内容は、作業ツリーではなく以下で確認する。

`git show <hash>:<path>`

Git 管理側だけで差分の全体像が見えない場合は、`C:\FNW\Source` 側の実体も参照して比較すること。