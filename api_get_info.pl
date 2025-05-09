
Вот пример post запроса 
{{ token = config.telegram.$PROFILE.token || config.telegram.token }}
{{ content = toJson({ chat_id = user.settings.telegram.chat_id }) }}
{{ getChat = http.post( "https://api.telegram.org/bot${token}/getChat", 
 'content_type','application/json', 'content',content) }}

Вот пример get запроса с передачей заголовков


{{ headers = {
    'Authorization' => "Bearer $TOKEN"
}
}}
{{ result = http.get( URL, 'content_type','application/json', 'headers',headers ) }}

Напиши код для post запроса, который бы выполнял тоже самое, что и эта команда:
curl -H 'Content-type: application/json' -H 'Authorization: UlXB3jAYhy' -d '{"action": "get_dcard_tel","tel": "9030619086"}' https://alpindustria.ru/api/aiapps/

{{ IF user.settings.discount_phone }}
{{ headers = {
    'Content-type' => 'application/json',
    'Authorization' => 'UlXB3jAYhy'
} }}

{{ content = toJson({
    'action' => 'get_dcard_tel',
    'tel' => user.settings.discount_phone
}) }}

{{ result = http.post(
    'https://alpindustria.ru/api/aiapps/',
    'content_type', 'application/json',
    'headers', headers,
    'content', content
) }}
{{ toJson( result ) }}

{{ parsed_result = fromJson(result) }}

{{ ret = user.set_settings({
    'discount_id' => parsed_result.id,
    'discount_type' => parsed_result.type,
    'discount_percent' => parsed_result.percent,
    'discount_score_pc' => parsed_result.score_pc,
    'discount_score' => parsed_result.score,
    'discount_is_active' => parsed_result.is_active,
    'discount_fio' => parsed_result.fio,
    'discount_summa' => parsed_result.summa,
    'discount_emprest' => parsed_result.emprest,
    'discount_shop'=> parsed_result.shop
}) }}
{{ END }}
{{ IF user.settings.discount_id}}
{{ plaintext = user.settings.discount_id }}
{{ PERL }}
use strict;
use warnings;
use Crypt::AuthEnc::GCM;
use MIME::Base64;
use Bytes::Random::Secure qw(random_bytes);

# Функция генерации nonce (12 байт)
sub generate_nonce {
    return random_bytes(12);
}

# Функция шифрования строки
sub encrypt_string {
    my ($plaintext, $key) = @_;
    my $nonce = generate_nonce();
    my $gcm = Crypt::AuthEnc::GCM->new('AES', $key, $nonce);
    $gcm->adata_add('');
    my $ciphertext = $gcm->encrypt_add($plaintext);
    my $tag = $gcm->encrypt_done();
    my $result = $nonce . $ciphertext . $tag;
    return encode_base64($result, '');
}

# Функция дешифрования строки
sub decrypt_string {
    my ($encrypted, $key) = @_;
    my $decoded = decode_base64($encrypted);
    my $nonce = substr($decoded, 0, 12);
    my $tag = substr($decoded, -16, 16);
    my $ciphertext = substr($decoded, 12, length($decoded) - 12 - 16);
    my $gcm = Crypt::AuthEnc::GCM->new('AES', $key, $nonce);
    $gcm->adata_add('');
    my $plaintext = $gcm->decrypt_add($ciphertext);
    my $verify = $gcm->decrypt_done($tag);
    return $verify ? $plaintext : undef;
}

# Ключ (32 байта, base64, как в PHP)
my $key = decode_base64('MTZFWWc0eGtGVzZsTklPc2wxakJ3S0NxdWtnWWlDOEE=');

# Получаем строку для шифрования из переменной шаблона
my $plaintext = $stash->get('plaintext') // '';

# Шифруем строку
my $encrypted = encrypt_string($plaintext, $key);
$stash->set('encrypted', $encrypted);

# Дешифруем строку обратно (для проверки)
my $decrypted = decrypt_string($encrypted, $key);
$stash->set('decrypted', $decrypted);
{{ END }}
{{ ret = user.set_settings({
    'discount_encrypted_id' => encrypted
}) }}
{{ END }}

Вот пример ответа, который лежит в переменной result
"{\"id\":\"219602\",\"type\":\"\\u0422\\u0418\\u041f (\\u0421\\u043e\\u0442\\u0440\\u0443\\u0434\\u043d\\u0438\\u043a\\u0438)\",\"percent\":30,\"score_pc\":0,\"score\":0,\"is_active\":1,\"fio\":\"\\u0413\\u0443\\u0441\\u044c\\u043a\\u043e\\u0432\\u0430 \\u041b\\u0438\\u0440\\u0430 \\u041d\\u0438\\u043a\\u043e\\u043b\\u0430\\u0435\\u0432\\u043d\\u0430\",\"summa\":\"279187\",\"emprest\":103925,\"shop\":\"\\u0421\\u0430\\u0439\\u0442\"}"

Вот пример сохранения атрибутов в settings пользователя
{{ ret = user.set_settings({ 'discountActive' => 1 }) }}

Напиши запрос, который бы сохранял все атрибуты из ответа в settings пользователя