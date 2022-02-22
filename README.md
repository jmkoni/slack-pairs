# slack-pairs

This application is intended to be a self-hosted version of Donut.

## System Requirements

This application uses Ruby 3.0

## App Setup Instructions

1. Follow instructions and [create a new slack app](https://api.slack.com/authentication/basics)
2. Add the following Bot Token scopes to your slack app: `users:read`, `mpim:write`, `im:write`, `chat:write`, `channels:join`, `channels:manage`, `groups:write`, `groups:read`, `mpim:read`, `im:read`, and `channels:read`.
4. Create a new app in Heroku or your hosting service of choice. Go to wherever you can add environment variables.
5. Set `MIN_GROUP_SIZE` to 2.
6. Get your secret key base and the oauth token for your newly created slack app. Store those as `SECRET_KEY_BASE` and `SLACK_OAUTH_TOKEN`.
7. Open up the channel you want to use the app in in your browser and get the channel ID. It should start with a "C". Store this as `PAIR_CHANNEL`.
8. Set `PAIR_MESSAGE`to use whatever channel name you are adding it to and whatever message you want. Ex: `You've both been paired up for a coffee chat from #coffee-buddies! Find a time to meet (Calendly is great for this) and have fun!`
9. Currently, the job will [only run on Mondays on odd weeks](https://github.com/jmkoni/slack-pairs/blob/main/app/jobs/create_pairs_job.rb#L8). Update this if you want to change it.
10. Deploy app to Heroku (or your hosting service of choice).
11. If using Heroku, install Heroku Scheduler.
12. Schedule `rake create_pairs` to run every day at a time of your choice. If you have a hosting service that will allow you to run cron jobs, you can remove the code mentioned above that checks that day and week and just use cron format. If using Heroku, just run daily and it will quit if it's not the right day 🙂
13. PROFIT!
