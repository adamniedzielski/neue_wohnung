# frozen_string_literal: true

class MockHTTPClient
  Response = Struct.new(:body)

  def initialize(response_filename)
    self.response_body = File.read(
      Rails.root.join("spec", "fixtures", response_filename)
    )
  end

  def get(_url)
    Response.new(response_body)
  end

  private

  attr_accessor :response_body
end
