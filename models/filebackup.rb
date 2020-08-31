# encoding: utf-8

if ENV["BACKUP_DATA_MOUNT_VOLUME"]
Model.new(:filebackup, ENV["BACKUP_NAME_FILES"]) do

if ENV["BACKUP_ARCHIVE"]
  ##
  # Create an archive using the data that has been mounted by docker using -v BACKUP_DIR:/data/
  archive :data do |archive|
    archive.add ENV["BACKUP_DATA_MOUNT_VOLUME"]
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

  ##
  # Amazon Simple Storage Service [Storage]
  if ENV["BACKUP_S3_BUCKET"]
    store_with S3, "#{ENV['BACKUP_KIND']}_#{ENV["BACKUP_POSTGRES_DATABASE_NAME"]}_#{ENV['BACKUP_DATABASE_KEY']}" do |s3|
       s3.access_key_id     = ENV["BACKUP_S3_ACCESS_KEY_ID"]
       s3.secret_access_key = ENV["BACKUP_S3_SECRET_ACCESS_KEY"]
       s3.region            = ENV["BACKUP_S3_REGION"]
       s3.bucket            = ENV["BACKUP_S3_BUCKET"]
       s3.path              = ENV["BACKUP_S3_BUCKET_PATH"]
       s3.keep              = ENV["BACKUP_S3_KEEP"] ? ENV["BACKUP_S3_KEEP"].to_i : 2
    end
  end

end

if ENV["BACKUP_SYNC"]
  sync_with Cloud::S3 do |s3|
    # AWS Credentials
    s3.access_key_id     = ENV["BACKUP_S3_ACCESS_KEY_ID"]
    s3.secret_access_key = ENV["BACKUP_S3_SECRET_ACCESS_KEY"]
    s3.region            = ENV["BACKUP_S3_REGION"]
    s3.bucket            = ENV["BACKUP_S3_BUCKET"]
    s3.path              = ENV["BACKUP_S3_BUCKET_PATH"]
    s3.mirror            = true
    s3.thread_count      = 10

    s3.directories do |directory|
      directory.add ENV["BACKUP_DATA_MOUNT_VOLUME"]
      # Exclude files/folders.
      # The pattern may be a shell glob pattern (see `File.fnmatch`) or a Regexp.
      # All patterns will be applied when traversing each added directory.
      # directory.exclude '**/*~'
      # directory.exclude /\/tmp$/
    end
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

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  #
  #notify_by Mail do |mail|
  #  mail.on_success           = true
  #  mail.on_warning           = true
  #  mail.on_failure           = true

  #  mail.from                 = "sender@email.com"
  #  mail.to                   = "receiver@email.com"
  #  mail.address              = "smtp.gmail.com"
  #  mail.port                 = 587
  #  mail.domain               = "your.host.name"
  #  mail.user_name            = "sender@email.com"
  #  mail.password             = "my_password"
  #  mail.authentication       = "plain"
  #  mail.encryption           = :starttls
  #end

end
end
