require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
	include ApplicationHelper

	def setup
		@user = users(:cirilla)
		log_in_as(@user)
	end

	test "profile display" do
		get user_path(@user)
		assert_template 'users/show'
		assert_select 'title', text: "#{@user.name} (@#{@user.username}) | Canary"
		assert_select 'img.gravatar'
		assert_match @user.posts.count.to_s, response.body
		assert_select 'div.pagination'
		@user.posts.paginate(page: 1).each do |post|
			assert_match post.content, response.body
		end
	end
end
