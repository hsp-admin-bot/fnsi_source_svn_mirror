update mst_take_medicine set list_details = regexp_replace(list_details, ',', chr(13) || chr(10), 'g');
