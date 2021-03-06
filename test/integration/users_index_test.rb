require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
	def setup
		@admin = users(:cirilla)
		@non_admin = users(:triss)

		30.times do |n|
			name = Faker::Name.name
			username = Faker::Internet.username
			email = Faker::Internet.email
			password = "password"
			User.create!(name: name,
									 email: email,
									 username: username,
									 password: password,
									 password_confirmation: password,
									 activated: true,
									 activated_at: Time.zone.now)
		end
	end

	test "index should include pagination and delete links" do 
		log_in_as(@admin)
		get users_path
		assert_template 'users/index'
		assert_select 'ul.pagination'
		first_page_of_users = User.paginate(page: 1)
		first_page_of_users.each do |user|
			unless user == @admin
				assert_select 'form > input[type=submit]', value: 'delete'
			end
		end
		assert_difference 'User.count', -1 do
			delete user_path(@non_admin)
		end
	end

	test "index as non-admin" do
		log_in_as(@non_admin)
		get users_path
		assert_select 'button', text: 'delete', count: 0
	end
end