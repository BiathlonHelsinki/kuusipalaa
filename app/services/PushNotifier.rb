

def self.sendPush(user)
  @message = get_message()
  if user.notification_data_id.present?
    @notification_data = NotificationData.find(user.notification_data_id)
    Webpush.payload_send(endpoint: @notification_data.endpoint,
                         message: @message,
                         p256dh: @notification_data.p256dh_key,
                         auth: @notification_data.auth_key,
                         ttl: 24 * 60 * 60,
                         vapid: {
                             subject: 'mailto:info@kuusipalaa.fi',
                             public_key: ENV['vapid_public_key'],
                             private_key: ENV['vapid_private_key']
                         }
    )
  end
end