from discord.ext import commands

class BotClass(commands.Bot):
    def __init__(self):
        super().__init__(command_prefix=commands.when_mentioned_or("$"))

    async def on_ready(self):
        print(f"Logged in as {self.user} (ID: {self.user.id})")
        print("------")
        await parseChannel()
        # await getNumberofAllMessages()

async def parseChannel():
    channel = bot.get_channel(879789713530163211)
    print("Начинаю отгрузку анекдотов")
    count = 0

    async for message in channel.history(limit=None):
        with open("anekdots.txt", "a+", encoding="utf-8") as file:
            mes = str(message.content).replace('"', '`').replace("\n", "").replace("'", "`").replace("\\", '')
            file.write(f"'{mes}',\n")
        print(f"Анекдот {count} записан")
        count += 1
        if count >= 503:
            print("ВСЕ АНЕКДОТЫ ЗАПИСАННЫ!")

async def getNumberofAllMessages():
    channel = bot.get_channel(879789713530163211)
    count = 0
    async for _ in channel.history(limit=None):
        count += 1
    print(f"Сообщений в канале всего {count}")
bot = BotClass()

bot.run("TOKEN HERE!")