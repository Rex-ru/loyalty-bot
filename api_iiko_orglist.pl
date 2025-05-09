{{ headers = {
'Content-type' => 'application/json',
'Authorization' => '349133c5588f4f1e935a841145b803ef'
} }}

{{ content = toJson({
'apiLogin' => '349133c5588f4f1e935a841145b803ef'
}) }}

{{ token_result = http.post(
'https://api-ru.iiko.services/api/1/access_token',
'content_type', 'application/json',
'headers', headers,
'content', content
) }}

{{ token_data = fromJson(token_result) }}
{{ access_token = token_result.token }}

{{ user_headers = {
'Content-type' => 'application/json',
'Authorization' => 'Bearer ' _ access_token
} }}

{{ user_content = toJson({
'phone' => '79856824185'
'name' => 'Михаил Светлов',
'organizationId' => '1de3cf75-0e83-4421-b219-b32e2147ab0b'
}) }}

{{ user_result = http.post(
'https://api-ru.iiko.services/api/1/loyalty/iiko/customer/create_or_update',
'content_type', 'application/json',
'headers', user_headers,
'content', user_content
) }}

{{ org_headers = {
'Content-type' => 'application/json',
'Authorization' => 'Bearer ' _ access_token
} }}

{{ orgs_result = http.get(
'https://api-ru.iiko.services/api/1/organizations',
'content_type', 'application/json',
'headers', org_headers
) }}
{{ dump(user_result) }}
{{# access_token }}
{{# dump(token_result)  }}

{{ get_user_content = toJson({
'phone' => '79856824185'
'type' => 'phone',
'organizationId' => '1de3cf75-0e83-4421-b219-b32e2147ab0b'
}) }}

{{ get_user_result = http.post(
'https://api-ru.iiko.services/api/1/loyalty/iiko/customer/info',
'content_type', 'application/json',
'headers', user_headers,
'content', get_user_content
) }}
{{ parsed_result =  fromJson(get_user_result) }}
{{ parsed_result.phone}}
