update V_PAT_INFO
   set NAME = '@name',
       NAME_KANA = '@nameKana'
 where PATID = '@hospPatId';