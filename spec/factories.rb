FactoryGirl.define do
	factory :user do
		name 					"Test User"
		email 					"example@railstutorial.org"
		password 				"foobar"
		password_confirmation 	"foobar"
	end
end
