# ca_main_spec.rb
require_relative 'ca_main'

describe Main, "#fake_method" do
  it "returns true for my totally fake method" do
    main = Main.new
    expect(main.fake_method('parameter')).to eq(true)
  end
end

describe Main, "#fake_method" do
  it "returns true for my totally fake method 2" do
    main = Main.new
    expect(main.fake_method('parameter')).to eq(true)
  end
end