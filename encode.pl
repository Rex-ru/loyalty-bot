{{ plaintext = 100117 }}

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

<p>Исходная строка: {{ plaintext }}</p>
<p>Зашифрованная строка: {{ encrypted }}</p>
<p>Дешифрованная строка: {{ decrypted }}</p>