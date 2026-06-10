update mst_weight set telegram_format='{"telegram_format": "ST,+{0:00000.00} kg[CR][LF]"}'
where
device_class= 0;
update mst_weight set telegram_format='{"telegram_format": "ST,GS,+{0:0000.00} kg[CR][LF]"}'
where
device_class= 1;
update mst_weight set telegram_format='{"telegram_format": "[SOH][SOH]17  [STX]CD000,DTDATE,NW{0:00000.00}kg,TW999.99Kg,GW999.99Kg,CT999,VH999kg,VL999Kg,[ETX][BCC][CR]"}'
where
device_class= 2;