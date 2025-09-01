import asyncio
import aiohttp
import feedparser
from bs4 import BeautifulSoup
from datetime import date, datetime, timedelta
import json
import logging
import re
import openai
from collections import deque
from yandex.cloud.ai.tts.v3 import tts_pb2, tts_service_pb2_grpc
import grpc
import os
import voicegen.voice_generation_pb2 as voice_generation_pb2
import boto3
import binascii

# Настройка логирования
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

YANDEX_CLOUD_FOLDER = os.environ['YANDEX_CLOUD_FOLDER']
YANDEX_CLOUD_API_KEY = os.environ['YANDEX_CLOUD_API_KEY']
AWS_ACCESS_KEY_ID = os.environ['AWS_ACCESS_KEY_ID']
AWS_SECRET_ACCESS_KEY = os.environ['AWS_SECRET_ACCESS_KEY']
QUEUE_URL = os.environ['QUEUE_URL']

# Конфигурация источников
SOURCES_CONFIG = {
    "rss": {
        "ria": "https://ria.ru/export/rss2/index.xml",
        "lenta": "https://lenta.ru/rss/news",
    }
}

class NewsAggregator:
    def __init__(self, session):
        self.session = session
        self.seen_news = deque(maxlen=1000)
        # ОБНОВЛЕННЫЕ СЕЛЕКТОРЫ ДЛЯ ТЕКСТА СТАТЕЙ
        self.article_selectors = {
            'ria': '.article__body',  # Селектор для RIA Novosti
            'lenta': '.topic-body__content',  # Селектор для Lenta.ru
        }

    def _generate_hash(self, news_item):
        return hash(f"{news_item['source']}_{news_item['title']}")

    def _clean_text(self, text):
        """
        Очищает и нормализует текст статьи.
        Удаляет лишние пробелы, добавляет пробелы после окончания предложений.
        """
        if not text:
            return text
        # Замена множественных переносов строк и пробелов на один пробел
        text = re.sub(r'\s+', ' ', text)
        # Добавление пробела после точек, если они идут перед буквой (исправляет склеивание слов)
        text = re.sub(r'\.([а-яА-Яa-zA-Z])', r'. \1', text)
        return text.strip()

    async def fetch_article_text(self, url, source_name):
        """
        Асинхронно загружает полную страницу новости и извлекает основной текст.
        """
        try:
            async with self.session.get(url) as response:
                if response.status == 200:
                    html = await response.text()
                    soup = BeautifulSoup(html, 'lxml')

                    # Получаем селектор для конкретного источника
                    selector = self.article_selectors.get(source_name)
                    if not selector:
                        logger.warning(f"Для источника {source_name} не задан селектор текста.")
                        return None

                    # ОБРАБОТКА ДЛЯ LENTA.RU
                    elif source_name == 'lenta':
                        article_body = soup.select_one(selector)
                        if article_body:
                            # Для Lenta извлекаем текст из всех параграфов
                            paragraphs = article_body.select('p')
                            text_content = ' '.join([p.get_text(" ", strip=True) for p in paragraphs])
                            cleaned_text = self._clean_text(text_content)
                            return cleaned_text[:5000]
                    
                    # ОБРАБОТКА ДЛЯ ДРУГИХ ИСТОЧНИКОВ
                    else:
                        article_body = soup.select_one(selector)
                        if article_body:
                            # Удаляем ненужные элементы
                            for element in article_body.select('.ad, script, style, .hidden, .social-share, .article__info, .article__meta, .inline-item'):
                                element.decompose()
                            
                            text_content = article_body.get_text(" ", strip=True)
                            cleaned_text = self._clean_text(text_content)
                            return cleaned_text[:5000]

                    logger.warning(f"Не удалось найти текст статьи для {source_name} по URL: {url} с селектором '{selector}'.")
                    return None
                else:
                    logger.error(f"Ошибка {response.status} при запросе статьи: {url}")
                    return None
        except Exception as e:
            logger.exception(f"Исключение при получении текста статьи {url}: {e}")
            return None

    async def fetch_rss_feed(self, source_name, url):
        """Асинхронно получает и парсит RSS-ленту, добавляя текст статьи."""
        news_list = []
        try:
            async with self.session.get(url) as response:
                if response.status == 200:
                    data = await response.text()
                    feed = feedparser.parse(data)
                    for entry in feed.entries:
                        published_time = datetime(*entry.published_parsed[:6]) if hasattr(entry, 'published_parsed') else datetime.now()
                        if datetime.now() - published_time < timedelta(hours=24):
                            news_item = {
                                "title": entry.title,
                                "link": entry.link,
                                "source": source_name,
                                "published": published_time.isoformat(),
                                "text": ""
                            }

                            news_hash = self._generate_hash(news_item)
                            if news_hash not in self.seen_news:
                                # full_text = await self.fetch_article_text(entry.link, source_name)
                                # if full_text:
                                #     news_item["text"] = full_text

                                self.seen_news.append(news_hash)
                                news_list.append(news_item)
                    logger.info(f"Успешно обработан RSS источник {source_name}. Новостей: {len(news_list)}")
                else:
                    logger.error(f"Ошибка при запросе к {url}: HTTP {response.status}")
        except Exception as e:
            logger.exception(f"Исключение при обработке RSS {source_name}: {e}")
        return news_list

    async def gather_news(self):
        """Собирает новости со всех источников."""
        all_news = []

        rss_tasks = []
        for source_name, url in SOURCES_CONFIG['rss'].items():
            task = asyncio.create_task(self.fetch_rss_feed(source_name, url))
            rss_tasks.append(task)
        rss_results = await asyncio.gather(*rss_tasks, return_exceptions=True)

        for result in rss_results:
            if isinstance(result, list):
                all_news.extend(result)

        all_news.sort(key=lambda x: x['published'], reverse=True)
        return all_news[:50]

async def receive_news_text():
    async with aiohttp.ClientSession(headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36'}) as session:
        aggregator = NewsAggregator(session)
        news = await aggregator.gather_news()
        logger.info(f"Всего собрано новостей: {len(news)}")

        client = openai.OpenAI(
            api_key=YANDEX_CLOUD_API_KEY,
            base_url="https://llm.api.cloud.yandex.net/v1"
        )

        response = client.chat.completions.create(
            model=f"gpt://{YANDEX_CLOUD_FOLDER}/qwen3-235b-a22b-fp8/latest",
            messages=[
                {"role": "system", "content": ""},
                {"role": "user", "content": "Ты - опытный редактор новостей. Выбери из списка заголовков новостей за сегодня только 5 самых важных для сводки новостей за сегодня, желательно из различных тематических блоков. В твоем ответе должен содержаться ТОЛЬКО json массив со списком заголовков и больше НИЧЕГО. Элементы массива должны быть взяты целиком из исходных данных, без изменений. Это должны быть ровно 5 элементов из исходного массива данных, содержащих полный json из объектов исходного массива. Отсортируй их в порядке важности, начиная от самой важной. Исходные данные:" + json.dumps(news, ensure_ascii=False, indent=2)}
            ],
            max_tokens=1000,
            temperature=0.3,
            stream=False
        )
        logger.info(f"Ответ от модели qwen3 (фильтр исходного списка): {response.choices[0].message.content}")
        news = json.loads(response.choices[0].message.content)
        for news_item in news:
            full_text = await aggregator.fetch_article_text(news_item["link"], news_item["source"])
            if full_text:
                news_item["text"] = full_text
        logger.info(f"Главные новости с текстом: {json.dumps(news, ensure_ascii=False, indent=2)}")

        prefix = """Ты - опытный редактор новостей. Составь из имеющихся данных текст для диктора для 3-х минутной сводки главных новостей за день.
                        1. Выдели из общего списка новостей ключевые
                        2. В 2-3 предложениях изложи суть новости
                        3. Оформи текст так, чтобы диктор мог прочитать его целиком (без дополнительных комментариев и замечаний)
                        4. Суммарная длина текста - меньше 1800 символов
                    Данные для сводки новостей:"""
        response = client.chat.completions.create(
            model=f"gpt://{YANDEX_CLOUD_FOLDER}/qwen3-235b-a22b-fp8/latest",
            messages=[
                {"role": "system", "content": ""},
                {"role": "user", "content": prefix + json.dumps(news, ensure_ascii=False, indent=2)}
            ],
            max_tokens=2000,
            temperature=0.3,
            stream=False
        )

        news_prefix = "Доброго времени суток! С Вами радио Искусственный звук. Только искусственные новости! "
        news_suffix = " На этом всё. Оставайтесь с нами! "
        news_text = news_prefix + response.choices[0].message.content + news_suffix
        logger.info(f"Ответ от модели qwen3 (сводка новостей): {response.choices[0].message.content}")
        return news_text

boto_session = None
ymq_queue = None
storage_client = None

def get_boto_session():
    global boto_session
    if boto_session is not None:
        return boto_session

    # extract values from secret
    access_key = AWS_ACCESS_KEY_ID
    secret_key = AWS_SECRET_ACCESS_KEY
    
    if access_key is None or secret_key is None:
        raise Exception("secrets required")

    # initialize boto session
    boto_session = boto3.session.Session(
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key
    )
    return boto_session

def get_ymq_queue():
    global ymq_queue
    if ymq_queue is not None:
        return ymq_queue

    ymq_queue = get_boto_session().resource(
        service_name='sqs',
        endpoint_url='https://message-queue.api.cloud.yandex.net',
        region_name='ru-central1'
    ).Queue(QUEUE_URL)
    return ymq_queue

def get_storage_client():
    global storage_client
    if storage_client is not None:
        return storage_client

    storage_client = get_boto_session().client(
        service_name='s3',
        endpoint_url='https://storage.yandexcloud.net',
        region_name='ru-central1'
    )
    return storage_client

def handler(event, context):
    filename = "main-" + str(datetime.now().hour)
    try:
        text = asyncio.run(receive_news_text())
        if not text:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Text not provided'})
            }

        voice_request = voice_generation_pb2.VoiceGenerationRequest()
        voice_request.text = text
        voice_request.result_file_type = voice_generation_pb2.MP3
        voice_request.speed = 12
        voice_request.tts_voice = voice_generation_pb2.ANTON
        voice_request.tts_role = voice_generation_pb2.NEUTRAL
        voice_request.s3_bucket = "ai-radio-music"
        voice_request.s3_folder = "news/" + str(date.today())
        voice_request.s3_unique_key = filename

        serialized_message = voice_request.SerializeToString()

    except Exception as e:
        logger.error(f"Error during message creation/serialization: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Failed to create protobuf message: {e}'})
        }

    try:
        resp = get_ymq_queue().send_message(MessageBody=binascii.hexlify(serialized_message).decode('utf-8'))
        logger.info(f"Response from ymq: {resp}")

    except Exception as e:
        logger.error(f"Error sending message to ymq: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': f'Failed to send message to yqm: {e}'})
        }

    # Создание объекта и запись данных
    try:
        bucket_name = "ai-radio-music"
        playlist_key = "playlists/news.m3u"
        playlist_str = "/music/jingles/news_start.mp3\n/music/news/" + filename + ".mp3\n/music/jingles/news_end.mp3"
        response = get_storage_client().put_object(Bucket=bucket_name, Key=playlist_key, Body=playlist_str)
        print(response)
        if response['ResponseMetadata']['HTTPStatusCode'] == 200:
            print(f"Плейлист успешно сохранён в s3://{bucket_name}/{playlist_key}")
        else:
            print("Произошла ошибка при загрузке")
    except s3_resource.meta.client.exceptions.NoSuchBucketError:
        print("Указанный бакет не существует.")
    except Exception as e:
        print(f"Произошла непредвиденная ошибка: {e}")

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Message sent to yqm', 'messageId': resp['MessageId']})
    }

def main():
    handler({}, {})

if __name__ == "__main__":
    main()