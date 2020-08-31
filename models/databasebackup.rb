# encoding: utf-8

#Model.new(ENV["BACKUP_POSTGRES_BACKUP_NAME"] || :databasebackup, ENV["BACKUP_NAME_DATABASE"]) do
Model.new(:databasebackup, ENV["BACKUP_NAME_DATABASE"]) do
  database PostgreSQL do |db|
    db.name               = ENV["BACKUP_POSTGRES_DATABASE_NAME"]
    db.username           = ENV["BACKUP_POSTGRES_USER_NAME"]
    db.password           = ENV["BACKUP_POSTGRES_PASSWORD"]
    db.host               = ENV["BACKUP_POSTGRES_HOST_NAME"]
    db.port               = ENV["BACKUP_POSTGRES_DATABASE_PORT"]
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip if ENV["BACKUP_GZIP"]

  if ENV["BACKUP_ENCRYPTION_PASSWORD"]
    encrypt_with OpenSSL do |encryption|
      encryption.password = ENV["BACKUP_ENCRYPTION_PASSWORD"]
    end
  end

  # TODO SFTP storage
  # TODO Dropbox storage

  if ENV["BACKUP_LOCAL_STORAGE"]
    store_with Local, "#{ENV['BACKUP_KIND']}_#{ENV["BACKUP_POSTGRES_DATABASE_NAME"]}_#{ENV['BACKUP_DATABASE_KEY']}" do |local|
      local.path = ENV["BACKUP_LOCAL_STORAGE"]
      # Use a number or a Time object to specify how many backups to keep.
      local.keep = ENV["BACKUP_LOCAL_KEEP"]
    end
  ##
  # Amazon Simple Storage Service [Storage
  elsif ENV["BACKUP_S3_BUCKET"]
    store_with S3, "#{ENV['BACKUP_KIND']}_#{ENV["BACKUP_POSTGRES_DATABASE_NAME"]}_#{ENV['BACKUP_DATABASE_KEY']}}" do |s3|
       s3.access_key_id     = ENV["BACKUP_S3_ACCESS_KEY_ID"]
       s3.secret_access_key = ENV["BACKUP_S3_SECRET_ACCESS_KEY"]
       s3.region            = ENV["BACKUP_S3_REGION"]
       s3.bucket            = ENV["BACKUP_S3_BUCKET"]
       s3.path              = ENV["BACKUP_S3_BUCKET_PATH"]
       s3.keep              =ENV["BACKUP_S3_KEEP"] ? ENV["BACKUP_S3_KEEP"].to_i : 2
    end
  end


  if ENV["BACKUP_SLACK_WEBHOOK_URL"]
    notify_by Slack do |slack|
      slack.on_success = true
      slack.on_warning = true
      slack.on_failure = true

      # The integration token
      slack.webhook_url = ENV["BACKUP_SLACK_WEBHOOK_URL"]   # the webhook_url
      slack.username = ENV["BACKUP_SLACK_USERNAME"]   # the username to display along with the notification
      slack.channel = ENV["BACKUP_SLACK_CHANNEL"]   # the channel to which the message will be sent
      slack.icon_emoji = ENV["BACKUP_SLACK_ICON_EMOJI"]   # the emoji icon to use for notifications
    end
  end

end
