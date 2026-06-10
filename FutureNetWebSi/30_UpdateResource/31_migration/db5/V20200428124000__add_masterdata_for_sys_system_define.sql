-- システム設定
DELETE FROM sys_system_define Where ctl_no = 26;

INSERT INTO sys_system_define (
  ctl_no, 
  service_cd, 
  name, 
  value, 
  description, 
  is_enable, 
  up_date
) VALUES (
  26, 
  '003', 
  '個人情報取扱い規約', 
  '{"html": "<dl><dt><strong>TEST:個人情報の管理</strong></dt><dd>TEST：当社は、お客さまの個人情報を正確かつ最新の状態に保ち、個人情報への不正アクセス・紛失・破損・改ざん・漏洩などを防止するため、セキュリティシステムの維持・管理体制の整備・社員教育の徹底等の必要な措置を講じ、安全対策を実施し個人情報の厳重な管理を行ないます。</dd><dt><strong>個人情報の利用目的</strong></dt><dd>お客さまからお預かりした個人情報は、当社からのご連絡や業務のご案内やご質問に対する回答として、電子メールや資料のご送付に利用いたします。</dd><dt><strong>個人情報の第三者への開示・提供の禁止</strong></dt><dd>当社は、お客さまよりお預かりした個人情報を適切に管理し、次のいずれかに該当する場合を除き、個人情報を第三者に開示いたしません。<ul><li>お客さまの同意がある場合</li><li>お客さまが希望されるサービスを行なうために当社が業務を委託する業者に対して開示する場合</li><li>法令に基づき開示することが必要である場合</li></ul></dd><dt><strong>個人情報の安全対策</strong></dt><dd>当社は、個人情報の正確性及び安全性確保のために、セキュリティに万全の対策を講じています。</dd><dt><strong>ご本人の照会</strong></dt><dd>お客さまがご本人の個人情報の照会・修正・削除などをご希望される場合には、ご本人であることを確認の上、対応させていただきます。</dd><dt><strong>法令、規範の遵守と見直し</strong></dt><dd>当社は、保有する個人情報に関して適用される日本の法令、その他規範を遵守するとともに、本ポリシーの内容を適宜見直し、その改善に努めます。</dd><dt><strong>お問い合せ</strong></dt><dd>当社の個人情報の取扱に関するお問い合せは下記までご連絡ください。<br>株式会社 xxx<br>〒xxx-xxxx　xx県xx市xx町x-x-x<br>TEL:XXX-XXX-XXXX FAX:XXX-XXX-XXXX<br>Mail:info@example.co.jp</dd></dl>"}', 
  '個人情報取扱い規約の本文。次世代FN用。', 
  '1', 
  current_timestamp
);
