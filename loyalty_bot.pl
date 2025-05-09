<% SWITCH cmd %>
<% CASE 'USER_NOT_FOUND' %>
{{ IF message.contact }}
    {{ IF message.contact }}
    {{ IF message.contact.user_id == message.from.id }}
        {{ phone = message.contact.phone_number.replace('\\+', '') }}
        {{ tg_api( 
            shmRegister = {
                partner_id = args.0 || start_args.pid
                user_login = phone
                callback_data = "/new_user " _ phone
            }
        ) }}
        {{ ELSE }}
        {{ tg_api( sendMessage = {
                text = "Вы не можете зарегистрироваться с чужим номером телефона"
            }
        )
        }}          

    {{ END }}
    {{ END }}
    
{{ ELSE }}
{{ TEXT = BLOCK }}
Для регистрация в программе лояльности отправьте мне номер телефона

Согласие на обработку данных и Политика конфиденциальности
https://cards.premiumbonus.su/FFkrdREDS/personal-data-agreement
Согласие на получение рассылок и Оферта
https://cards.premiumbonus.su/FFkrdREDS/newsletter-agreement
{{ END }}
{{ tg_api( sendMessage = {
        text = TEXT
        reply_markup = {
            keyboard = [
                [
                    {
                        text = "Поделиться номером телефона"
                        request_contact = true
                    }
                ]
            ]
            one_time_keyboard = true
            resize_keyboard = true
        }
    }
)
}}
{{ END }}
<% CASE '/new_user' %>
{{ set_phone = user.set( phone = args.0 ) }}
{{# phone = args.0 }}
{{ alp_phone = args.0.replace('^7', '', 1) }}
{{ set_alp_phone = user.set_settings({ 'discount_phone' => alp_phone }) }}
{{ tg_api( deleteMessage = { message_id = message.message_id - 1 } ) }}
{{ tg_api( deleteMessage = { message_id = message.message_id } ) }}
{{ tg_api( sendMessage = {
        text = "Спасибо, номер телефона принят"
        reply_markup = {
            remove_keyboard = true
            selective = true
        }
    }
)
}}
{{# tg_api( deleteMessage = { message_id = message.message_id + 1 } ) }}
{{ tg_api( shmRedirectCallback = { callback_data = '/start' } ) }}
<% CASE ['/start', '/menu'] %>
{{ TEXT = BLOCK }}
Для получения бонусной карты заполните коротку анкету

{{ END }}
{{ IF cmd == '/new_user' }}
{{ END }}
{{ tg_api( sendMessage = {
        text = TEXT
        reply_markup = {
            inline_keyboard = [
                    [{
                        text = "Заполнить анкету"
                                'web_app' = {
                                    url = config.api.url _ '/shm/v1/public/HTML_REGISTER?format=html&user_id=' _ user.id _ '&profile=' _ tpl.id
                                }
                    }]
                    [{
                        text = "Бонусная карта"
                        callback_data = '/main'
                    }]
            ]
        }
    }
)
}}
<% CASE '/main' %>
{{ IF callback_query.id }}
{
   "answerCallbackQuery": {
        "callback_query_id": {{ callback_query.id }}
    }
},
{{ END }}
{{# user_get_info = tpl.id( 'api_alp_get_custoner_info' ).parse }}
{{ data = storage.read('name','alp_' _ user.dogovor ) }}
{{ URL = user.settings.dicsount_shortURL }}
{{ SET type = data.type == '_Эверест (20%)' ? 'Эверест (20%)' : data.type }}
{{# img_url = config.loyalty.$type || config.loyalty.generic }}
{{ IF data.type == '_Эверест (20%)'}}
{{ SET img_url = config.loyalty.everest }}
{{ ELSE }}
{{ SET img_url = config.loyalty.generic }}
{{ END }}
{{ TEXT = BLOCK }}
<b>💳 Информация о клубной карте</b>

<b>🆔 Номер карты:</b> {{ data.id }}

<b>💰 Сумма покупок:</b> {{ data.summa }} руб.

<b>✨ Тип карты:</b> {{ type }}

{{ IF data.percent}}
<b>🏆 Остаток лимита:</b> {{ data.emprest }} руб.

<b>💵 Скидка:</b> {{ data.percent }}%
{{ ELSIF data.score_pc }}
<b>🏆 Накоплено баллов:</b> {{ data.score }}

<b>💵 Кешбэк:</b> {{ data.score_pc }}%
{{ END }}
{{ END }}
{{ IF cmd == '/new_user' }}
{{ set_phone = user.set( phone = args.0 ) }}
{{ END }}
{{ tg_api( sendPhoto = {
        caption = TEXT
        photo = img_url
        parse_mode = "HTML"
        reply_markup = {
            inline_keyboard = [
                [
                    {
                        text = "Добавить в Wallet / Google Pay"
                        url = URL
                    }
                ]                 
                [
                    {
                        text = "Показать QR-код"
                                'web_app' = {
                                    url = 'https://lk.111500.xyz/shm/v1/public/share_link?format=html&user_id=' _ user.id _ '&profile=' _ tpl.id
                                }
                    }
                ]
                [
                    {
                        text = "Условия программы лояльности"
                                'web_app' = {
                                    url = "https://alpindustria.ru/discount/"
                                }
                    }
                ]
            ]
        }
    }
)
}}
<% CASE '/card' %>
        {{ tg_api( 
            setChatMenuButton = {
                chat_id = user.settings.telegram.user_id
                menu_button = {
                    type = 'web_app'
                    text = 'Карта'
                    web_app = {
                        url = 'https://lk.111500.xyz/shm/v1/public/share_link?format=html&user_id=' _ user.id _ '&profile=' _ tpl.id
                    }
                }
            }
        ) }}   
<% CASE '/shop' %>
        {{ tg_api( 
            setChatMenuButton = {
                chat_id = user.settings.telegram.user_id
                menu_button = {
                    type = "default"
                }
            }
        ) }}  
<% CASE %>
{{ tg_api( sendMessage = { text = 'Я не знаю команды: ' _  cmd  } ) }}
<% END %>