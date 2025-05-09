{{# создать шаблон sys_free_spin_register, привязать его к событию USER_REGISTERED с транспортом LOCAL }}
{{# Даем фри спин за регистрацию }}
{{ set_free_spin = user.set_settings({ 'free_spin' => 1 })  }}
{{# Даем фри спин партнеру, если он есть }}
{{ IF user.partner_id }}
{{ set_free_spin = user.id(user.partner_id).set_settings({ 'free_spin' => user.id(user.partner_id).settings.free_spin + 1 })  }}
{{ END }}

{{# Добавить в уведомления по событиям CREATE, ACTIVATE, PROLONGATE, добавляем фри спин только если стоимость списания больше 0}}
{{ IF us.wd.cost > 0}}
{{ set_free_spin = user.set_settings({ 'free_spin' => user.settings.free_spin + 1 }) }}
{{ END }}


{{# Фильтруем уведомления о начислении бонусов }}
{{ SET is_partner_bonus = bonus.comment.msg.defined && bonus.comment.msg.match('Стань барином, партнер') }}
{{ SET is_slot_prize = bonus.comment.msg.defined && bonus.comment.msg.match('slot_prize') }}
{{ IF bonus.amount > 0 && !(is_partner_bonus || is_slot_prize) }}

Тут ваш текст уведомления о начислении бонусов

{{ END }}


{{# начисляем всем по одному фри спину }}
{{ FOR u IN user.items }}
{{ set_free_spin = u.set_settings({ 'free_spin' => 1 })  }}
{{ END }}
