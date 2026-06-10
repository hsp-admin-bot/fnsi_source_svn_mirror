--ALTER TABLE mst_self_measure_result ADD COLUMN fn_self_measure_result_cd VARCHAR(23) DEFAULT NULL;
--comment on column mst_self_measure_result.fn_self_measure_result_cd is 'FNW+で管理する施設内の一意な職種コード';

--ALTER TABLE mst_vital_graph ADD COLUMN fn_vital_graph_cd VARCHAR(3) DEFAULT NULL;
--comment on column mst_vital_graph.fn_vital_graph_cd is 'FNW+で管理する施設内の一意な職種コード';

--ALTER TABLE mst_medicine_support ADD COLUMN fn_medicine_support_cd VARCHAR(5) DEFAULT NULL;
--comment on column mst_medicine_support.fn_medicine_support_cd is 'FNW+で管理する施設内の一意な職種コード';

--ALTER TABLE mst_pat_viewer_layout ADD COLUMN fn_layout_cd VARCHAR(5) DEFAULT NULL;
--comment on column mst_pat_viewer_layout.fn_layout_cd is 'FNW+で管理する施設内の一意な職種コード';
