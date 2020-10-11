require "rails_helper"

RSpec.describe ScrapeGewobag do
  it "gets multiple apartments" do
    result = ScrapeGewobag.new.call

    expect(result.size).to eq 7
  end

  it "gets apartment address" do
    result = ScrapeGewobag.new.call

    expect(result.first.fetch(:address))
      .to eq "\n\t\t\t\tCosmarweg 105, 13591 Berlin/Staaken\t\t\t"
  end
end
