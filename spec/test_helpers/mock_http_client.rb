# frozen_string_literal: true

class MockHTTPClient
  class Response
    def body
      File.read(Rails.root.join("spec", "fixtures", "gewobag.html"))
    end
  end

  def get(_url)
    Response.new
  end
end
