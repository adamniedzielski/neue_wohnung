# neue_wohnung

This is an application that scrapes apartment offers from websites of
Wohnungsbaugesellschaften and Wohnungsgenossenschaften in Berlin and
sends notifications about them.

## Installation

1. Install Ruby - use version from `.ruby-version` file
2. Install PostgreSQL
3. `bundle install`
4. `rails db:setup`
5. `rails console` to test that it runs

## Testing

You need to create your own Telegram bot to run the test suite. Follow the
instructions [here](https://core.telegram.org/bots#3-how-do-i-create-a-bot)
and [here](https://spidermon.readthedocs.io/en/latest/howto/configuring-telegram-for-spidermon.html#steps)
so you have `TELEGRAM_TOKEN` and `TELEGRAM_CHAT_ID`.

After that you can run:

```
TELEGRAM_TOKEN=your_token TELEGRAM_CHAT_ID=your_chat_id rails spec
```

## Deployment

The application is deployed to Heroku. The deployment happens automatically
after each push to the `main` branch.
