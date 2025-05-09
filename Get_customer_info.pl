{{# a178a1d345094088b8c8d3355ccc7445 }}
{{ phone = '79262241671'}}
{{ organizationId = '1de3cf75-0e83-4421-b219-b32e2147ab0b' }}
{{ api_key = '349133c5588f4f1e935a841145b803ef' }}
{{ headers = {
'Content-type' => 'application/json',
} }}

{{ content = toJson({
'apiLogin' => api_key
}) }}

{{ token_result = http.post(
'https://api-ru.iiko.services/api/1/access_token',
'content_type', 'application/json',
'headers', headers,
'content', content
) }}

{{ access_token = token_result.token }}
{{ access_token }}

{{ get_user_headers = {
'Content-type' => 'application/json',
'Authorization' => 'Bearer ' _ access_token
} }}

{{ get_user_content = toJson(
    {
    "phone" => phone,
    "type" => "phone",
    "organizationId" => organizationId
    }
) }}

{{ get_user_result = http.post(
'https://api-ru.iiko.services/api/1/loyalty/iiko/customer/info',
'content_type', 'application/json',
'headers', get_user_headers,
'content', get_user_content
) }}

{{# dump(get_user_result) }}
{{ setlog = storage.save('iiko_' _ user.id, get_user_result ) }}
{{ setlog }}