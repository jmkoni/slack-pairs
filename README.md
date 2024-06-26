# slack-pairs

This application is intended to be a self-hosted version of Donut, in addition to a bot that helps moderators of slack receive messages from their users. It can handle both groups and pairs.

## System Requirements

**NOTE: if you want to use a version manager, please skip to the next section. Using a version manager is highly recommended.**

This application uses [Ruby 3.3.1](https://www.ruby-lang.org/en/documentation/installation/). You'll need the following
- [RubyGems](https://rubygems.org/pages/download) (installed with rvm)
- bundler (`gem install bundler`)
- required libraries (run `bundle install` from the application home directory)

### If you want to use a version manager

You can use either [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io). Further instructions assume use of rvm.
1. Install rvm.
2. `rvm install ruby-3.3.1`
3. `cd` into `slack-pairing` directory
4. This should create a `slack-pairs` gemset (a self-contained set of installed gems to avoid conflicts).
5. `gem install bundler`
6. `bundle install`
7. You are good to go!

## Running(ish) Locally

You need four environment variables set:

1. `PAIRING CHANNEL` (if doing pairs)
2. `GROUPS_CHANNEL` (if doing groups)
3. `SLACK_OAUTH_TOKEN`
4. `SLACK_SIGNING_SECRET` (if doing the mod controller)

You get the channel ids from visiting slack in the browser, clicking on the channel, then looking at the URL. The ID starting with C is your channel ID. For the Slack tokens, you will likely need to talk to SRE to get access to the app within Slack. If you have all these set, you can run it locally! However, keep in mind that, if you run the job, it will generate the groups and send out messages. So run with care! To run:

`rake create_groups`

If you want to run individual methods, the best bet is to run `rails c` to open up the console. Then you can run any of the individual methods (at least if they aren't private). Example:

``` shell
> rails c
Loading development environment (Rails 6.1.7)
3.0.0 :001 > pairs = CreateGroupsJob.balance_pairs([[1,2],[3,4],[5]])
 => [[1, 2], [3, 4, 5]]
```
Note: You can do an example like this without setting the environment variables.

## Running tests

`bundle exec rspec`
That's it!

## Running the linter

`bundle exec standardrb --fix`

## Deploying to Slack

1. Follow instructions and [create a new slack app](https://api.slack.com/authentication/basics)
2. Add the following Bot Token scopes to your slack app: `users:read`, `mpim:write`, `im:write`, `chat:write`, `channels:join`, `channels:manage`, `groups:write`, `groups:read`, `mpim:read`, `im:read`, and `channels:read`. *OR* copy `.slack_manifest.yml`, update the app name, and save an hour of your time.
4. Create a new app in Heroku or your hosting service of choice. If you are not using `modbot`, you don't have to deploy! The jobs will run via GitHub Actions. Go to wherever you can add environment variables.
5. Get your oauth token for your newly created slack app. To do this, go to "OAuth & Permissions", then, after installing the app, get the token from "OAuth Tokens for Your Workspace". Store as `SLACK_OAUTH_TOKEN`.
6. Open up the channel you want to use the app in in your browser and get the channel ID. It should start with a "C". Store this as `PAIRING_CHANNEL`.
7. Open up the channel you want to use the app in in your browser and get the channel ID. It should start with a "C". Store this as `GROUPS_CHANNEL`.
8. Set environment variables in Github within your repo: Settings > Secrets > Actions > New Repository Secret

If you are using the modbot portion:

1. Add `MOD_CHANNEL` to Heroku environment variables. Get the channel by going to slack in your browser, opening up the mod channel, and getting the channel id.
2. Add `SLACK_SIGNING_SECRET` to Heroku environment variables. Get this from "Basic Information" -> "Signing Secret".
3. Deploy app to Heroku (or your hosting service of choice).
4. Go to your app in Slack (where you added the bot tokens), go to slash commands and create a new one. Command should be:

- Command: `/mods`
- Request URL: `https://your-app.herokuapp.com/mod`
- Short Description: `Notifies the mods channel`
- Usage Hint: `<message to mods>`

5. For the `/add-to-channel` functionality, add a second slash command:

- Command: `/add-to-channel`
- Request URL: `https://your-app.herokuapp.com/channels`
- Short Description: `Adds you to the requested private channel`
- Usage Hint: `<channel identifier> or help`

6. Make sure to update the channels with the correct names and channel IDs in `SlackMessage`.


## Updating the gems

Dependabot is turned on, but if you want to do it manually, run:

`bundle update`

## Updating the schedule

The job is run based on the schedule in `.github/workflows/create_groups.yml`. For help with cron, try [crontab.guru](https://crontab.guru).
