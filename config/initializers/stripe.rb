Rails.configuration.stripe = {
  :publishable_key => ENV['stripe_publishable'],
  :secret_key      => ENV['stripe_secret']
}
Stripe.api_key = Rails.configuration.stripe[:secret_key]