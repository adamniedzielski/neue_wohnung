# frozen_string_literal: true

class MockHTTPClient
  Response = Struct.new(:body)

  def initialize(response_filenames)
    self.responses = Array(response_filenames).map do |filename|
      Response.new(
        Rails.root.join("spec", "fixtures", filename).read
      )
    end
    self.current_index = 0
  end

  def get(_url)
    response = responses[current_index]
    self.current_index = current_index + 1
    response
  end

  private

  attr_accessor :responses, :current_index
end
