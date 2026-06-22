#!/bin/sh

# usage: unzip -o {解凍元ファイル名} -d {解凍先フォルダ名}

# 解凍元ファイル名
zip=${1}
# 解凍先フォルダ名
output_dir=${2}

# 解凍処理
unzip -o ${zip} -d ${output_dir}
