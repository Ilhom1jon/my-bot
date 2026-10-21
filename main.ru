import telebot
import yt_dlp
import os

TOKEN = "8641947710:AAEYxAOOlSWqlJ_pGIQjyxMfKSlQzlYpyZs"
bot = telebot.TeleBot(TOKEN)

@bot.message_handler(commands=['start'])
def start(message):
    # Эски тугмаларни экрандан олиб ташлаш учун буйруқ
    markup = telebot.types.ReplyKeyboardRemove()
    
    bot.send_message(
        message.chat.id, 
        "🎵🎬 Ассалому алайкум!\n\n"
        "Эски тугмалар ўчирилди.\n\n"
        "Менга:\n"
        "• **Instagram** ёки **TikTok** видео линкини юборсангиз — видео қилиб бераман;\n"
        "• **YouTube** линкини юборсангиз — аудио (музика) қилиб бераман;\n"
        "• Хофиз ёки қўшиқ номини ёзиб юборсангиз — ўзим қидириб топиб бераман!",
        reply_markup=markup
    )

@bot.message_handler(func=lambda message: True)
def download_media(message):
    text = message.text.strip()
    
    # Агар эски тугмачалар босилиб қолса
    if text in ["📋 Қолдиқларни кўриш", "➕ Маҳсулот қўшиш", "🔙 Орқага"]:
        markup = telebot.types.ReplyKeyboardRemove()
        bot.send_message(message.chat.id, "Бу эски тугмалар эди. Улар ўчирилди. Энди линк ёки қўшиқ номини юборинг:", reply_markup=markup)
        return
    
    bot.reply_to(message, "⏳ Қидирилмоқда ва юклаб олинмоқда, бироз кутинг...")
    
    if "http" in text:
        url = text
        if "instagram.com" in url or "tiktok.com" in url:
            ydl_opts = {
                'format': 'best',
                'outtmpl': 'downloaded_media.%(ext)s',
                'noplaylist': True,
            }
            is_video = True
        else:
            ydl_opts = {
                'format': 'bestaudio',
                'outtmpl': 'downloaded_media.%(ext)s',
                'noplaylist': True,
            }
            is_video = False
    else:
        url = f"ytsearch1:{text}"
        ydl_opts = {
            'format': 'bestaudio',
            'outtmpl': 'downloaded_media.%(ext)s',
            'noplaylist': True,
        }
        is_video = False
    
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=True)
            if 'entries' in info and info['entries']:
                info = info['entries'][0]
            filename = ydl.prepare_filename(info)
        
        with open(filename, 'rb') as file:
            if is_video:
                bot.send_video(message.chat.id, file, caption="✨ Сиз сўраган видео!")
            else:
                bot.send_audio(message.chat.id, file, caption=f"🎵 Қўшиқ: {text}")
        
        if os.path.exists(filename):
            os.remove(filename)
            
    except Exception as e:
        bot.send_message(message.chat.id, "⚠️ Юклаб олишда хатолик юз берди. Илтимос, линк ёки номни қайта текшириб кўринг.")

print("Бот барқарор ва тугмаларсиз ишга тушди...")
bot.infinity_polling(timeout=10, long_polling_timeout=5)
