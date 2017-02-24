require "spec_helper"

RSpec.describe FidorApi::Beneficiary::Base do
  describe ".register_routing_type_class" do
    it "registers a new class" do
      current_count = described_class::ROUTING_TYPE_CLASSES.count

      expect{
        described_class.register_routing_type_class(routing_type: "EXTERNAL", klass: "FidorApi::Beneficiary::External")
      }.to change{ described_class::ROUTING_TYPE_CLASSES.count }.from(current_count).to(current_count + 1)
    end
  end
end
