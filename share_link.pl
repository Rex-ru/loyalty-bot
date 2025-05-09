{{ link = user.dogovor }}
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QR-код</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css" rel="stylesheet">
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
    <style>
        :root {
            color-scheme: light dark;
        }
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
        }
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
        }
        .content {
            padding: 20px 10px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            max-width: 95vw;
            width: 100%;
            margin: 0;
            text-align: center;
        }
        h5 {
            margin: 0 0 20px 0;
            font-size: 18px;
        }
        .qr-code {
            display: flex;
            justify-content: center;
            margin: 20px 0;
            padding: 15px;
            border: 2px solid #ddd;
            border-radius: 12px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.15);
        }
        .qr-code img {
            width: 300px;
            height: 300px;
        }
        .card-number {
            margin-top: 15px;
            font-size: 16px;
            font-weight: 500;
        }
        @media (max-width: 400px) {
            .qr-code img {
                width: 220px;
                height: 220px;
            }
        }
        @media (prefers-color-scheme: dark) {
            body {
                background-color: #121212;
                color: #f5f5f5;
            }
            .content {
                background-color: #1e1e1e;
                box-shadow: 0 2px 10px rgba(0,0,0,0.3);
            }
            .qr-code {
                background-color: #ffffff;
                border-color: #333;
            }
        }
        @media (prefers-color-scheme: light) {
            body {
                background-color: #f5f5f5;
                color: #333;
            }
            .content {
                background-color: #fff;
            }
            .qr-code {
                background-color: #fff;
            }
        }
    </style>
</head>
<body>
    <div class="content">
        <h5>Покажите этот QR-код на кассе</h5>
        <div class="qr-code">
            <img src="{{ config.api.url }}/shm/v1/public/referal_url?format=qrcode&partner_id={{ link }}" alt="QR Code">
        </div>
        <div class="card-number">
            Номер карты: {{ link }}
        </div>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js"></script>
    <script>
        let tg = window.Telegram.WebApp;
        tg.ready();
        tg.expand();
        
        // Автоматическое определение темы из Telegram
        document.documentElement.className = tg.colorScheme;
        
        tg.MainButton.setParams({
            text: 'Закрыть',
            is_visible: true
        });
        tg.MainButton.onClick(function() {
            tg.close();
        });
    </script>
</body>
</html>