Sentry.init do |config|
  config.dsn = "https://6b394d1774f5430d8a1653250bcc1c63@o1150717.ingest.sentry.io/6224141"
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end
