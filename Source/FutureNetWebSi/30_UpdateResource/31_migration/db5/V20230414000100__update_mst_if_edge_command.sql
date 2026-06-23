delete from "mst_if_edge_command" where "ctl_no" = 11;
INSERT INTO "mst_if_edge_command" ("ctl_no", "command_key", "command", "add_setting", "is_del", "reg_date", "up_date", "processing", "processing_detail") VALUES (11, 'versionup', 'datapath=DATA_PATH

DESPATH=/home/ntss

SRCPATH=/home/ntss/if_edge/maint/$datapath/files/.node-red/
if [ -d "$SRCPATH" ]; then
    cp -R "$SRCPATH" "$DESPATH"
    if [ $? -ne 0 ];then
        echo ".node-red copy ng."
        exit 1
    fi
    echo ".node-red copy ok."
fi

SRCPATH=/home/ntss/if_edge/maint/$datapath/files/
if [ "" = "$(ls $SRCPATH)" ]; then
    echo "other not exists."
else
    cp -R $SRCPATH* "$DESPATH"
    if [ $? -ne 0 ];then
        echo "copy ng."
        exit 2
    fi
    echo "other copy ok."
fi

echo "copy ok."

chown -R ntss /home/ntss
chgrp -R ntss /home/ntss
#chmod -R 776 /home/ntss
chown syslog /home/ntss/if_edge/logs/nodered
chown syslog /home/ntss/if_edge/logs/nodered/node-red_*.log
chgrp syslog /home/ntss/if_edge/logs/nodered/node-red_*.log

systemctl stop nodered;
if [ $? -ne 0 ];then
    echo "stop nodered ng."
    exit 2
fi
echo "stop nodered ok."

systemctl daemon-reload;
if [ $? -ne 0 ];then
    echo "reload ng."
    exit 2
fi
echo "reload ok."

systemctl restart nodered
if [ $? -ne 0 ];then
    echo "restart nodered ng."
    exit 2
fi
echo "restart nodered ok."

systemctl restart ntssifmaint
if [ $? -ne 0 ];then
    echo "restart ntssifmaint ng."
    exit 2
fi
echo "restart ntssifmaint ok."

exit 0
', '0', '0', '2022-08-05 11:32:02.299', CURRENT_TIMESTAMP, 'ファイルアップロードとIFエッジ再起動', 'ファイルアップロードとIFエッジ再起動');
