# typed: true

class User < ApplicationRecord
  extend T::Sig
  has_many :google_accounts

  sig { params(payload: T::Hash[String, T.nilable(String)]).returns(User) }
  def self.find_or_create_from_google_account!(payload)
    user = GoogleAccount.find_by(id: payload["sub"])&.user
    if user
      return user
    end

    User.create_from_google_account!(payload)
  end

  sig { params(payload: T::Hash[String, T.nilable(String)]).returns(User) }
  def self.create_from_google_account!(payload)
    T.unsafe(ActiveRecord::Base).transaction do
      user = T.unsafe(User).create!(
        nickname: payload["given_name"] || payload["name"]
      )

      T.unsafe(GoogleAccount).create!(
        id: payload["sub"],
        email: payload["email"],
        name: payload["name"],
        given_name: payload["given_name"],
        picture_url: payload["picture"],
        user: user
      )
    end
  end
end
