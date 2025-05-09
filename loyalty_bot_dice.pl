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
{{ URL = 'https://cards.doze.ru/detect-and-get/?id=' _ user.settings.discount_encrypted_id }}
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
                [
                    {
                        text = "Подписаться на канал"
                        url = "https://t.me/Alpindustria_ru"
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

<% CASE '/ludomania' %>
{{ IF callback_query.id }}
{ "answerCallbackQuery": { "callback_query_id": {{ callback_query.id }} }}
{{ END }}
{{ USE date }}
{{ IF user.settings.last_spin == date.format(date.now, '%Y-%m-%d') }}
{{ day_spin = 0 }}
{{ ELSE }}
{{ day_spin = 1 }}
{{ END }}
{{# spin_count = day_spin + user.settings.free_spin }}
{{ spin_count = user.settings.free_spin || 0 }}
{{ amount = spin_count }}
{{ last_digit = amount % 10 }}
{{ last_two_digits = amount % 100 }}

{{ IF last_two_digits >= 11 && last_two_digits <= 19 }}
{{ rubles = 'попыток' }}
{{ ELSIF last_digit == 1 }}
{{ rubles = 'попытка' }}
{{ ELSIF last_digit >= 2 && last_digit <= 4 }}
{{ rubles = 'попытки' }}
{{ ELSE }}
{{ rubles = 'попыток' }}
{{ END }}
{{ TEXT = BLOCK }}
<b>🎁 У вас есть возможность выиграть подписку на 1 месяц в нашей игре 🎰</b>

Дополнительно вы получаете по одной попытке за:
- покупку подписки или подарочного промокода
- продление подписки
- за каждого приглашенного друга

{{ IF spin_count == 0 }}
<b>У вас закончились попытки на сегодня!</b>
{{ ELSE }}
У вас есть {{ spin_count }}{{' '}}{{ rubles }} на сегодня!
{{ END }}
{{ END }}
{{ buttons = [] }}
{{ IF spin_count == 0 }}
{{ IF user.us.has_services_block }}
{{ buttons.push([
{ text = "💰 Продлить подписку", callback_data = "/balance" }
]) }}
{{ END }}
{{ buttons.push([
{ text = "👫 Пригласить друзей", callback_data = "/referrals" }
]) }}
{{ buttons.push([
{ text = "◄ В главное меню", callback_data = "/menu" }
]) }}
{{ ELSE }}
{{ buttons.push([
{ text = "🎰 Вращать барабан", callback_data = "спин" }
]) }}
{{ END }}
{{ tg_api( 
    editMessageText = {
        message_id = message.message_id
        text = TEXT
        parse_mode = "HTML"
        reply_markup = {
            inline_keyboard = buttons
        }
    }
)
        }}
<% CASE 'спин' %>
{{ IF callback_query.id }}
{ "answerCallbackQuery": { "callback_query_id": {{ callback_query.id }} }}
{{ END }}
{{ USE date }}
{{ IF user.settings.last_spin == date.format(date.now, '%Y-%m-%d') }}
{{ day_spin = 0 }}
{{ ELSE }}
{{ day_spin = 1 }}
{{ END }}
{{# spin_count = day_spin + user.settings.free_spin }}
{{ spin_count = user.settings.free_spin || 0 }}
{{ amount = spin_count }}
{{ last_digit = amount % 10 }}
{{ last_two_digits = amount % 100 }}

{{ IF last_two_digits >= 11 && last_two_digits <= 19 }}
{{ rubles = 'попыток' }}
{{ ELSIF last_digit == 1 }}
{{ rubles = 'попытка' }}
{{ ELSIF last_digit >= 2 && last_digit <= 4 }}
{{ rubles = 'попытки' }}
{{ ELSE }}
{{ rubles = 'попыток' }}
{{ END }}
{{ IF spin_count == 0 }}
{{ TEXT = BLOCK }}
<b>У вас закончились попытки на сегодня!</b>
{{ END }}
{{ buttons = [] }}
{{ IF user.us.has_services_block }}
{{ buttons.push([
{ text = "💰 Продлить подписку", callback_data = "/balance" }
]) }}
{{ END }}
{{ buttons.push([
{ text = "👫 Пригласить друзей", callback_data = "/referrals" }
]) }}
{{ buttons.push([
{ text = "◄ В главное меню", callback_data = "/menu" }
]) }}
{{ tg_api( sendMessage = {
        text = TEXT
        parse_mode = "HTML"
        reply_markup = {
            inline_keyboard = buttons
        }
    }
)
        }}
{{ ELSE }}
        {{ tg_api( 
    sendDice = {
        chat_id = message.chat.id,
        emoji = "🎰",
        disable_notification = true,
    }
        ) }}
{{ IF user.settings.free_spin > 0 }}
{{ set_free_spin = user.set_settings({ 'free_spin' => user.settings.free_spin - 1 })  }}
{{ set_total_spin_count = user.set_settings({ 'total_spin_count' => user.settings.total_spin_count + 1 })  }}
{{ IF user.settings.last_spin == date.format(date.now, '%Y-%m-%d') }}
{{ day_spin = 0 }}
{{ ELSE }}
{{ day_spin = 1 }}
{{ END }}
{{# spin_count = day_spin + user.settings.free_spin }}
{{ spin_count = user.settings.free_spin || 0 }}
{{ amount = spin_count }}
{{ last_digit = amount % 10 }}
{{ last_two_digits = amount % 100 }}

{{ IF last_two_digits >= 11 && last_two_digits <= 19 }}
{{ rubles = 'попыток' }}
{{ ELSIF last_digit == 1 }}
{{ rubles = 'попытка' }}
{{ ELSIF last_digit >= 2 && last_digit <= 4 }}
{{ rubles = 'попытки' }}
{{ ELSE }}
{{ rubles = 'попыток' }}
{{ END }}

{{ END }}
{{ USE date }}
{{ date = date.format(response.result.date, '%Y-%m-%d') }}
{{ set_last_spin = user.set_settings({ 'last_spin' => date }) }}  
{{ TEXT = BLOCK }}
{{ IF response.result.dice.value == 64 }}
{{ id = user.set_bonus('bonus', 200, 'comment', {'msg' => 'slot_prize'} )  }}
Поздравляем! Вы выиграли подписку на 1 месяц! 🎁

🎉 Начислили вам <b>200 бонусов</b> на счет! 💰

{{ ELSE  }}
Без выйгрыша! Попробуйте еще раз! 🎰

{{ END }}
{{ IF spin_count == 0 }}
<b>У вас закончились попытки на сегодня!</b>
{{ ELSE }}
У вас есть еще {{ spin_count }}{{' '}}{{ rubles }}
{{ END }}
{{ END }}
{{ buttons = [] }}
{{ IF spin_count == 0 }}
{{ IF user.us.has_services_block }}
{{ buttons.push([
{ text = "💰 Продлить подписку", callback_data = "/balance" }
]) }}
{{ END }}
{{ buttons.push([
{ text = "👫 Пригласить друзей", callback_data = "/referrals" }
]) }}
{{ buttons.push([
{ text = "◄ В главное меню", callback_data = "/menu" }
]) }}
{{ ELSE }}
{{ buttons.push([
{ text = "🎰 Вращать барабан", callback_data = "спин" }
]) }}
{{ END }}
{{ PERL }} sleep 3; {{ END }}
{{ tg_api( sendMessage = {
        text = TEXT
        parse_mode = "HTML"
        reply_markup = {
            inline_keyboard = buttons
        }
    }
)
}}        
{{ END}}
<% CASE %>
{{ tg_api( sendMessage = { text = 'Я не знаю команды: ' _  cmd  } ) }}
<% END %>