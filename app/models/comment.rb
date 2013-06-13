# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  hack_id    :integer
#  body       :text
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Comment < ActiveRecord::Base
  attr_accessible :body, :hack_id, :user_id

  belongs_to :hack, :user
end