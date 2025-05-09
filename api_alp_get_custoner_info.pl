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
{{ set_id = user.set( dogovor = parsed_result.id ) }}
{{# ret = user.set_settings({
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
{{ IF user.dogovor }}
{{ plaintext = user.dogovor }}
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
{{ setlog = storage.save('alp_' _ user.dogovor, parsed_result ) }}
