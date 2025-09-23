#!/bin/bash

# リソース名変更用のterraform state mvコマンドをplanから作成する
# ※リソースタイプ1種類につき1リソースしか無い場合に限る

# プランファイルの生成
terraform plan -out=tfplan.binary
plan_status=$?

# plan コマンドが失敗した場合、スクリプトを終了
if [ $plan_status -ne 0 ]; then
    echo "Terraform plan failed with status $plan_status"
    exit $plan_status
fi

# プランを読みやすい形式に変換
terraform show -json tfplan.binary > tfplan.json

# 一時ファイルの削除
rm tfplan.binary

# 削除されたリソースと作成されたリソースを対応付ける
jq -r '
    .resource_changes[]
    | select(.change.actions | index("delete") or index("create"))
    | [.address, .type, .change.actions[]]
    | @csv
' tfplan.json | awk -F, '
    {
        gsub(/"/, "", $1);
        gsub(/"/, "", $2);
        gsub(/"/, "", $3);
        if ($3 == "delete") {
            deletes[$1]=$2;
        }
        if ($3 == "create") {
            creates[$1]=$2;
        }
    }
    END {
        for (del in deletes) {
            for (create in creates) {
                if (deletes[del] == creates[create]) {
                    print "terraform state mv \x27"del"\x27 \x27"create"\x27";
                }
            }
        }
    }
' | while read line; do
    echo "$line"
done

# JSONファイルの削除
rm tfplan.json