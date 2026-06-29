require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  fixtures :users

  let(:user) { users(:michael) }

  describe "account_activation" do

    before do
      user.activation_token = User.new_token
    end
    let(:mail) { UserMailer.account_activation(user) }

    it "正しくメールが生成されること" do
      expect(mail.subject).to eq("Account activation")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["iriyama-y@dwango.co.jp"])
      expect(mail.body.encoded).to match(user.name)
      expect(mail.body.encoded).to match(user.activation_token)
      expect(mail.body.encoded).to match(CGI.escape(user.email))
    end
  end

  describe "password_reset" do
    before do
      user.reset_token = User.new_token
    end

    # 💡 この部屋専用の mail を定義
    let(:mail) { UserMailer.password_reset(user) }

    it "正しくメールが生成されること" do
      expect(mail.subject).to eq("Password reset")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["iriyama-y@dwango.co.jp"])
      expect(mail.body.encoded).to match(user.reset_token)
      expect(mail.body.encoded).to match(CGI.escape(user.email))
    end
  end
end