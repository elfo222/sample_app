require 'spec_helper'

describe User do

	before do
		@user = User.new(name: "Example User", email: "user@example.com",
			password: "foobar", password_confirmation: "foobar")
	end

	subject { @user }

	describe "functionality validation" do
		it { should respond_to(:name) }
		it { should respond_to(:email) }
		it { should respond_to(:password_digest) }
		it { should respond_to(:password) }
		it { should respond_to(:password_confirmation) }
		it { should respond_to(:remember_token) }

		it { should respond_to(:authenticate) }
		it { should respond_to(:admin) }

		it { should be_valid }
	end

	describe "name validation" do
		describe "when name is not present" do
			before { @user.name = " " }
			it { should_not be_valid }
		end

		describe "when the name is too long" do
			before { @user.name = "a" * 51 }
			it { should_not be_valid }
		end

		describe "when the name is too short" do
			before { @user.name = "a" }
			it { should_not be_valid }
		end
	end

	describe "email validation" do
		describe "when the email is not present" do
			before { @user.email = " " }
			it { should_not be_valid }
		end

		describe "when the email format is invalid" do
			it "should be invalid" do
				addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
				addresses.each do |invalid_address|
					@user.email = invalid_address
					expect(@user).not_to be_valid
				end
			end
		end

		describe "when the email format is valid" do
			it "should be valid" do		
				addresses = %w[user@foo.COM A_US@f.b.org frst.lst@foo.jp a+b@baz.cn.us]
				addresses.each do |valid_address|
					@user.email = valid_address
					expect(@user).to be_valid
				end
			end
		end

		describe "when the email is already taken" do
			before do
				user_with_same_email = @user.dup
				user_with_same_email.email = @user.email.upcase
				user_with_same_email.save
			end

			it "should not be valid" do
				expect(@user).not_to be_valid
			end
		end

		describe "when the email is saved" do
			before do
				@user.email = "FOO@TEST.COM"
				@user.save
			end

			it "should be lower case" do
				expect(@user.email).to eq(@user.email.downcase)
			end
		end
	end

	describe "password validation" do
		describe "when the password is not present" do
			before do
				@user = User.new(name: "Example User", email: "user@example.com",
					password: " ", password_confirmation: " ")
			end

			it "shold not be invalid" do
				expect(@user).not_to be_valid
			end
		end

		describe "when the password confirmation doesn't match" do
			before { @user.password_confirmation = "bar" }
			it "should not be valid" do
				expect(@user).not_to be_valid
			end
		end

		describe "when the password is too short" do
			before { @user.password = @user.password_confirmation = "a" * 5 }
			it { should be_invalid }
		end
	end

	describe "password authentication" do
		before { @user.save }
		let(:found_user) { User.find_by(email: @user.email) }

		describe "when the password is correct" do
			it { should eq found_user.authenticate(@user.password) }
		end

		describe "when the password is incorrect" do
			let(:user_for_invalid_password) { found_user.authenticate("invalid") }

			it { should_not eq user_for_invalid_password }
			specify { expect(user_for_invalid_password).to be_false }
		end
	end

	describe "remember token validation" do
		describe "remember token" do
			before { @user.save }
			its(:remember_token) { should_not be_blank }
		end
	end

	describe "admin validation" do
		it "with default setting" do
			should_not be_admin
		end

		describe "with admin set to true" do
			before do
				@user.save!
				@user.toggle!(:admin)
			end

			it { should be_admin }
		end
	end
end
