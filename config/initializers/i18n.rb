I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
I18n.default_locale = :en
I18n.available_locales = %i[en fi]
I18n.fallbacks[:en] = %i[en fi]

I18n.fallbacks[:fi] = %i[fi en]
