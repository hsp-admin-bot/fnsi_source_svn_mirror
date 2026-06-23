UPDATE "ntss"."mst_if_edge_command" SET "command_key" = 'versionup', "command" = 'datapath=DATA_PATH

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

cp -R /home/ntss/if_edge/maint/$datapath/files/* "$DESPATH"
if [ $? -ne 0 ];then
    echo "copy ng."
    exit 2
fi

echo "copy ok."

chown -R ntss /home/ntss
chgrp -R ntss /home/ntss
#chmod -R 776 /home/ntss

systemctl stop nodered;
if [ $? -ne 0 ];then
    echo "stop ng."
    exit 2
fi
echo "stop ok."

systemctl daemon-reload;
if [ $? -ne 0 ];then
    echo "reload ng."
    exit 2
fi
echo "reload ok."

systemctl restart nodered
if [ $? -ne 0 ];then
    echo "restart ng."
    exit 2
fi
echo "restart ok."

exit 0
', "up_date" = CURRENT_TIMESTAMP WHERE "ctl_no" = 11;
