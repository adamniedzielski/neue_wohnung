# neue_wohnung

This is an application that scrapes apartment offers from websites of
Wohnungsbaugesellschaften and Wohnungsgenossenschaften in Berlin and
sends notifications about them.

## Installation in development

1. Install Ruby - use version from `.ruby-version` file
2. Install PostgreSQL
3. `bundle install`
4. `rails db:setup`
5. `rails console` to test that it runs

## Telegram

You need to create your own Telegram bot and group to run the test suite and
send notifications in production.

1. Create the Telegram bot as described [here](https://core.telegram.org/bots#3-how-do-i-create-a-bot). This will give you `TELEGRAM_TOKEN`.
2. Create a new Telegram group and invite to it your bot and `@GroupIDbot`.
3. Send `/id` message in the group and the bot will give you the chat ID of
the group. This is `TELEGRAM_CHAT_ID`.

## Testing

```
TELEGRAM_TOKEN=your_token TELEGRAM_CHAT_ID=your_chat_id rails spec
```

Apart from all tests passing, a test message should appear in your Telegram
group.

## Deployment to production

The application is deployed to Heroku. The deployment happens automatically
after each push to the `main` branch.

If you'd like to deploy the application on your own - to Heroku or another
platform - here are the few things to pay attention to:

1. Set the environment variable `TELEGRAM_TOKEN` (Config Vars in Heroku)
2. The application has no own user interface at the moment. Telegram serves
the role of the user interface. The entry point to the application is the
Rake task that checks for offers.
3. You need to run the Rake task regularly - `rails apartments:get_new`. On
Heroku you can use [Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler) addon for that. On your own server this may be a Cron job.
4. Create at least one receiver. The receiver defines to which Telegram group
the notifications go and which filters need to be applied:

```
rails console
```

or:

```
heroku console
```

and then:

```ruby
Receiver.create!(
  name: "just a label",
  telegram_chat_id: "your_chat_id",
  include_wbs: true,
  minimum_rooms_number: 1,
  maximum_rooms_number: 10
)
```


